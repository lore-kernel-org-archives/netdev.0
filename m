From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problems with /proc/net/tcp6  - possible bug - ipv6
Date: Sat, 22 Jan 2011 16:15:44 +0100
Message-ID: <1295709344.2651.55.camel@edumazet-laptop>
References: <702550.61465.qm@web63902.mail.re1.yahoo.com>
	 <1295686781.2609.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: PK <runningdoglackey@yahoo.com>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295686781.2609.37.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 22 janvier 2011 =C3=A0 09:59 +0100, Eric Dumazet a =C3=A9crit=
 :=20
> Le vendredi 21 janvier 2011 =C3=A0 22:30 -0800, PK a =C3=A9crit :
> > Creating many ipv6 connections hits a ceiling on connections/fds ; =
okay, fine.
> >=20
> > But in my case I'm seeing millions of entries spring up within a fe=
w seconds and=20
> > then vanish within a few minutes, in /proc/net/tcp6 (vanish due to =
garbage=20
> > collection?)
> >=20
> > Furthermore I can trigger this easily on vanilla kernels from 2.6.3=
6 to=20
> > 2.6.38-rc1-next-20110121  inside a ubuntu 10.10 amd64 vm, causing t=
he kernel to=20
> > spew warnings.  There is also some corruption in the logs (see kern=
el-sample.log=20
> > line 296), but that may be unrelated.
> >=20
> > More explanation, kernel config of the primary machine I saw this o=
n, sample=20
> > ruby script to reproduce (inside the ubuntu VMs I apt-get and use r=
uby-1.9.1),=20
> > are located at
> > https://github.com/runningdogx/net6-bug
> >=20
> > Seems to only affect 64-bit.  So far I have not been able to reprod=
uce on 32-bit=20
> > ubuntu VMs of any kernel version.
> > Seems to only affect IPv6.  So far I have not been able to reproduc=
e using IPv4=20
> > connections (and watching /proc/net/tcp of course).
> > Does not trigger the bug if the connections are made to ::1.  Only =
externally=20
> > routable local and global IPv6 addresses seem to cause problems.
> > Seems to have been introduced between 2.6.35 and 2.6.36 (see README=
 on github=20
> > for more kernels I've tried)
> >=20
> > All the tested Ubuntu VMs are stock 10.10 userland, with vanilla ke=
rnels (the=20
> > latest ubuntu kernel is 2.6.35-something, and my initial test didn'=
t show it=20
> > suffering from this problem)
> >=20
> > Originally noticed on separate Gentoo 64-bit non-vm system when doi=
ng web=20
> > benchmarking.
> >=20
> > not subscribed, so please keep me in cc although I'll try to follow=
 the thread
> >=20
> >=20


I had some incidents, after hours of testing...

After following patch, I could not reproduce it.

I cant believe this bug was not noticed before today.

Thanks !

[PATCH] tcp: fix bug in listening_get_next()

commit a8b690f98baf9fb19 (tcp: Fix slowness in read /proc/net/tcp)
introduced a bug in handling of SYN_RECV sockets.

st->offset represents number of sockets found since beginning of
listening_hash[st->bucket].

We should not reset st->offset when iterating through
syn_table[st->sbucket], or else if more than ~25 sockets (if
PAGE_SIZE=3D4096) are in SYN_RECV state, we exit from listening_get_nex=
t()
with a too small st->offset

Next time we enter tcp_seek_last_pos(), we are not able to seek past
already found sockets.

Reported-by: PK <runningdoglackey@yahoo.com>
CC: Tom Herbert <therbert@google.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp_ipv4.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 856f684..02f583b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1994,7 +1994,6 @@ static void *listening_get_next(struct seq_file *=
seq, void *cur)
 				}
 				req =3D req->dl_next;
 			}
-			st->offset =3D 0;
 			if (++st->sbucket >=3D icsk->icsk_accept_queue.listen_opt->nr_table=
_entries)
 				break;
 get_req:
