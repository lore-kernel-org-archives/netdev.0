From: Yakov Lerner <iler.ml@gmail.com>
Subject: Re: [PATCH] /proc/net/tcp, overhead removed
Date: Tue, 29 Sep 2009 10:43:09 +0300
Message-ID: <f36b08ee0909290043l654892eblae494c0caebdadb5@mail.gmail.com>
References: <1254000675-8327-1-git-send-email-iler.ml@gmail.com>
	 <4ABF360E.7080301@gmail.com>
	 <f36b08ee0909281510y282d621etb4264ecd92cbe8f0@mail.gmail.com>
	 <4AC13697.4090707@gmail.com> <20090928162417.59640672@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:30171 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbZI2HnI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 03:43:08 -0400
Received: by fg-out-1718.google.com with SMTP id 22so1692171fge.1
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2009 00:43:11 -0700 (PDT)
In-Reply-To: <20090928162417.59640672@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 29, 2009 at 02:24, Stephen Hemminger <shemminger@vyatta.com=
> wrote:
> On Tue, 29 Sep 2009 00:20:07 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> Yakov Lerner a =E9crit :
>> > On Sun, Sep 27, 2009 at 12:53, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> >> Yakov Lerner a =E9crit :
>> >>> /proc/net/tcp does 20,000 sockets in 60-80 milliseconds, with th=
is patch.
>> >>>
>> >>> The overhead was in tcp_seq_start(). See analysis (3) below.
>> >>> The patch is against Linus git tree (1). The patch is small.
>> >>>
>> >>> ------------ =A0----------- =A0 --------------------------------=
----
>> >>> Before patch =A0After patch =A0 20,000 sockets (10,000 tw + 10,0=
00 estab)(2)
>> >>> ------------ =A0----------- =A0 --------------------------------=
----
>> >>> 6 sec =A0 =A0 =A0 =A0 =A00.06 sec =A0 =A0 dd bs=3D1k if=3D/proc/=
net/tcp >/dev/null
>> >>> 1.5 sec =A0 =A0 =A0 =A00.06 sec =A0 =A0 dd bs=3D4k if=3D/proc/ne=
t/tcp >/dev/null
>> >>>
>> >>> 1.9 sec =A0 =A0 =A0 =A00.16 sec =A0 =A0 netstat -4ant >/dev/null
>> >>> ------------ =A0----------- =A0 --------------------------------=
----
>> >>>
>> >>> This is ~ x25 improvement.
>> >>> The new time is not dependent on read blockize.
>> >>> Speed of netstat, naturally, improves, too; both -4 and -6.
>> >>> /proc/net/tcp6 does 20,000 sockets in 100 millisec.
>> >>>
>> >>> (1) against git://git.kernel.org/pub/scm/linux/kernel/git/torval=
ds/linux-2.6.git
>> >>>
>> >>> (2) Used 'manysock' utility to stress system with large number o=
f sockets:
>> >>> =A0 "manysock 10000 10000" =A0 =A0- 10,000 tw + 10,000 estab ip4=
 sockets.
>> >>> =A0 "manysock -6 10000 10000" - 10,000 tw + 10,000 estab ip6 soc=
kets.
>> >>> Found at http://ilerner.3b1.org/manysock/manysock.c
>> >>>
>> >>> (3) Algorithmic analysis.
>> >>> =A0 =A0 Old algorithm.
>> >>>
>> >>> During 'cat </proc/net/tcp', tcp_seq_start() is called O(numsock=
ets) times (4).
>> >>> On average, every call to tcp_seq_start() scans half the whole h=
ashtable. Ouch.
>> >>> This is O(numsockets * hashsize). 95-99% of 'cat </proc/net/tcp'=
 is spent in
>> >>> tcp_seq_start()->tcp_get_idx. This overhead is eliminated by new=
 algorithm,
>> >>> which is O(numsockets + hashsize).
>> >>>
>> >>> =A0 =A0 New algorithm.
>> >>>
>> >>> New algorithms is O(numsockets + hashsize). We jump to the right
>> >>> hash bucket in tcp_seq_start(), without scanning half the hash.
>> >>> To jump right to the hash bucket corresponding to *pos in tcp_se=
q_start(),
>> >>> we reuse three pieces of state (st->num, st->bucket, st->sbucket=
)
>> >>> as follows:
>> >>> =A0- we check that requested pos >=3D last seen pos (st->num), t=
he typical case.
>> >>> =A0- if so, we jump to bucket st->bucket
>> >>> =A0- to arrive to the right item after beginning of st->bucket, =
we
>> >>> keep in st->sbucket the position corresponding to the beginning =
of
>> >>> bucket.
>> >>>
>> >>> (4) Explanation of O( numsockets * hashsize) of old algorithm.
>> >>>
>> >>> tcp_seq_start() is called once for every ~7 lines of netstat out=
put
>> >>> if readsize is 1kb, or once for every ~28 lines if readsize >=3D=
 4kb.
>> >>> Since record length of /proc/net/tcp records is 150 bytes, formu=
la for
>> >>> number of calls to tcp_seq_start() is
>> >>> =A0 =A0 =A0 =A0 =A0 =A0 (numsockets * 150 / min(4096,readsize)).
>> >>> Netstat uses 4kb readsize (newer versions), or 1kb (older versio=
ns).
>> >>> Note that speed of old algorithm does not improve above 4kb bloc=
ksize.
>> >>>
>> >>> Speed of the new algorithm does not depend on blocksize.
>> >>>
>> >>> Speed of the new algorithm does not perceptibly depend on hashsi=
ze (which
>> >>> depends on ramsize). Speed of old algorithm drops with bigger ha=
shsize.
>> >>>
>> >>> (5) Reporting order.
>> >>>
>> >>> Reporting order is exactly same as before if hash does not chang=
e underfoot.
>> >>> When hash elements come and go during report, reporting order wi=
ll be
>> >>> same as that of tcpdiag.
>> >>>
>> >>> Signed-off-by: Yakov Lerner <iler.ml@gmail.com>
>
> Does the netlink interface used by ss command have the problem?

No. It's  /proc/net/tcp that has fixable problem.

Yakov
