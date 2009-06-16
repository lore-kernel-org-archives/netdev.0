From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT]: Networking
Date: Tue, 16 Jun 2009 16:19:56 +0200
Message-ID: <4A37AA0C.40507@gmail.com>
References: <20090616094813.GA1686@elte.hu>	<20090616.025659.224075454.davem@davemloft.net>	<20090616101132.GA28204@elte.hu> <20090616.033554.102149558.davem@davemloft.net> <4A37A058.1030701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mingo@elte.hu,
	alan@lxorguk.ukuu.org.uk, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42428 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484AbZFPOUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 10:20:43 -0400
In-Reply-To: <4A37A058.1030701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> David Miller a =E9crit :
>> From: Ingo Molnar <mingo@elte.hu>
>> Date: Tue, 16 Jun 2009 12:11:32 +0200
>>
>>> sure, here you go (i also added a stack dump, just in case it's som=
e=20
>>> kernel-internal socket open):
>>>
>>>  [ifconfig:3516]: Creates X25 socket.
>>>
>>> so plain ifconfig. Part of the ~1.5 years old net-tools-1.60-84.fc8=
=2E
>> Ok, ifconfig seems to open one of every socket type when it starts u=
p.
>> That explains why an X25 socket is openned and then closed.
>>
>> Now the question is why is the X25 socket released by a timer?  This
>> should only happen if some socket memory is still pending in the
>> socket buffers.
>>
>> Wait, I know why this is triggering now.  It's Eric Dumazet's SKB
>> accounting optimizations.
>>
>> So, I'll fix the X25 timer bug.  It's always been there, but
>> beforehand this deferred-via-timer x25 socket destruction path almos=
t
>> never triggers.  So we never saw it.  Now it happens every time.
>>
>> Eric can you sniff around and see what you think about this unforsee=
n
>> (at least for me) consequence of your changes?  Socket layers that u=
se
>> the current sk_wmem_alloc/sk_rmem_alloc value at destroy time to
>> determine if a socket can be killed immediately, or need to be kille=
d
>> later via timer, will always see that dummy one byte allocation you
>> now put there.
>>
>> Can you look into that?
>>
>> Thanks.
>=20
>=20
> Sure I can look if a layer uses sk_wmem_alloc as you describe.
>=20
> (I take you refer to commit 2b85a34e911bf483c27cfdd124aeb1605145dc80 =
:
> net: No more expensive sock_hold()/sock_put() on each tx)
>=20
> So there is no impact for sk_rmem_alloc AFAIK
>=20

Here is first patch to take into account this initial offset in sk_wmem=
_alloc

(Only compiled, not tested)

A second patch will follow to correct /prov/net/udp and other PROC_FS f=
iles, and
also SIOCOUTQ/TIOCOUTQ, as we currently give off-by-one values, it cert=
ainly can
break some apps.

Thank you

[PATCH] net: sk_wmem_alloc has initial value of one, not zero

commit 2b85a34e911bf483c27cfdd124aeb1605145dc80=20
(net: No more expensive sock_hold()/sock_put() on each tx)
changed initial sk_wmem_alloc value.

Some protocols check sk_wmem_alloc value to determine if a timer
must delay socket deallocation. We must take care of the sk_wmem_alloc
value being one instead of zero.

Reported by Ingo Molnar, and full diagnostic from David Miller.

Reported-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/appletalk/ddp.c    |    4 ++--
 net/ax25/af_ax25.c     |    2 +-
 net/econet/af_econet.c |    4 ++--
 net/netrom/af_netrom.c |    2 +-
 net/rose/af_rose.c     |    2 +-
 net/x25/af_x25.c       |    2 +-
 6 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index b603cba..048cfd0 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -162,7 +162,7 @@ static void atalk_destroy_timer(unsigned long data)
 {
 	struct sock *sk =3D (struct sock *)data;
=20
-	if (atomic_read(&sk->sk_wmem_alloc) ||
+	if (atomic_read(&sk->sk_wmem_alloc) > 1 ||
 	    atomic_read(&sk->sk_rmem_alloc)) {
 		sk->sk_timer.expires =3D jiffies + SOCK_DESTROY_TIME;
 		add_timer(&sk->sk_timer);
@@ -175,7 +175,7 @@ static inline void atalk_destroy_socket(struct sock=
 *sk)
 	atalk_remove_socket(sk);
 	skb_queue_purge(&sk->sk_receive_queue);
=20
-	if (atomic_read(&sk->sk_wmem_alloc) ||
+	if (atomic_read(&sk->sk_wmem_alloc) > 1 ||
 	    atomic_read(&sk->sk_rmem_alloc)) {
 		setup_timer(&sk->sk_timer, atalk_destroy_timer,
 				(unsigned long)sk);
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index fd9d06f..2e81b1d 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -330,7 +330,7 @@ void ax25_destroy_socket(ax25_cb *ax25)
 	}
=20
 	if (ax25->sk !=3D NULL) {
-		if (atomic_read(&ax25->sk->sk_wmem_alloc) ||
+		if (atomic_read(&ax25->sk->sk_wmem_alloc) > 1 ||
 		    atomic_read(&ax25->sk->sk_rmem_alloc)) {
 			/* Defer: outstanding buffers */
 			setup_timer(&ax25->dtimer, ax25_destroy_timer,
diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 8121bf0..051dcb6 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -540,7 +540,7 @@ static void econet_destroy_timer(unsigned long data=
)
 {
 	struct sock *sk=3D(struct sock *)data;
=20
-	if (!atomic_read(&sk->sk_wmem_alloc) &&
+	if (atomic_read(&sk->sk_wmem_alloc) <=3D 1 &&
 	    !atomic_read(&sk->sk_rmem_alloc)) {
 		sk_free(sk);
 		return;
@@ -580,7 +580,7 @@ static int econet_release(struct socket *sock)
 	skb_queue_purge(&sk->sk_receive_queue);
=20
 	if (atomic_read(&sk->sk_rmem_alloc) ||
-	    atomic_read(&sk->sk_wmem_alloc)) {
+	    atomic_read(&sk->sk_wmem_alloc) > 1) {
 		sk->sk_timer.data     =3D (unsigned long)sk;
 		sk->sk_timer.expires  =3D jiffies + HZ;
 		sk->sk_timer.function =3D econet_destroy_timer;
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 3be0e01..8126bd4 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -286,7 +286,7 @@ void nr_destroy_socket(struct sock *sk)
 		kfree_skb(skb);
 	}
=20
-	if (atomic_read(&sk->sk_wmem_alloc) ||
+	if (atomic_read(&sk->sk_wmem_alloc) > 1 ||
 	    atomic_read(&sk->sk_rmem_alloc)) {
 		/* Defer: outstanding buffers */
 		sk->sk_timer.function =3D nr_destroy_timer;
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 877a7f6..0ab0f4d 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -356,7 +356,7 @@ void rose_destroy_socket(struct sock *sk)
 		kfree_skb(skb);
 	}
=20
-	if (atomic_read(&sk->sk_wmem_alloc) ||
+	if (atomic_read(&sk->sk_wmem_alloc) > 1 ||
 	    atomic_read(&sk->sk_rmem_alloc)) {
 		/* Defer: outstanding buffers */
 		setup_timer(&sk->sk_timer, rose_destroy_timer,
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index c51f309..57dd5d3 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -372,7 +372,7 @@ static void __x25_destroy_socket(struct sock *sk)
 		kfree_skb(skb);
 	}
=20
-	if (atomic_read(&sk->sk_wmem_alloc) ||
+	if (atomic_read(&sk->sk_wmem_alloc) > 1 ||
 	    atomic_read(&sk->sk_rmem_alloc)) {
 		/* Defer: outstanding buffers */
 		sk->sk_timer.expires  =3D jiffies + 10 * HZ;
