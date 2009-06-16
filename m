From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT]: Networking
Date: Tue, 16 Jun 2009 22:12:03 +0200
Message-ID: <4A37FC93.7070403@gmail.com>
References: <4A37A058.1030701@gmail.com>	<4A37AA0C.40507@gmail.com>	<alpine.LFD.2.01.0906161155400.3282@localhost.localdomain> <20090616.120829.182011393.davem@davemloft.net> <4A37F495.9030101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, mingo@elte.hu,
	alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44925 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205AbZFPUMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 16:12:21 -0400
In-Reply-To: <4A37F495.9030101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> David Miller a =E9crit :
>> From: Linus Torvalds <torvalds@linux-foundation.org>
>> Date: Tue, 16 Jun 2009 11:59:34 -0700 (PDT)
>>
>>> At the very least, add a helper function for "do I actually have=20
>>> outstanding allocations" or something like that. IOW, do a=20
>>>
>>> 	/*
>>> 	 * Comment here about that magical "1"
>>> 	 */
>>> 	static inline int sk_has_allocations(struct sock *sk)
>>> 	{
>>> 		return atomic_read(&sk->sk_wmem_alloc) > 1 ||
>>> 			atomic_read(&sk->sk_rmem_alloc);
>>> 	}
>>>
>>> and then make the various network protocols use that, rather than=20
>>> open-coding some random internal implementation magic.
>> I agree, this should be handled with a helper function
>> abstraction rather than putting "1" checks all over the place.
>=20
> Fair enough, I'll submit an updated patch in following hour.
>=20

[PATCH] net: sk_wmem_alloc has initial value of one, not zero

commit 2b85a34e911bf483c27cfdd124aeb1605145dc80=20
(net: No more expensive sock_hold()/sock_put() on each tx)
changed initial sk_wmem_alloc value.

Some protocols check sk_wmem_alloc value to determine if a timer
must delay socket deallocation. We must take care of the sk_wmem_alloc
value being one instead of zero when no write allocations are pending.

Reported by Ingo Molnar, and full diagnostic from David Miller.

This patch introduces three helpers to get read/write allocations
and a followup patch will use these helpers to report correct
write allocations to user.

Reported-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h     |   33 +++++++++++++++++++++++++++++++++
 net/appletalk/ddp.c    |    6 ++----
 net/ax25/af_ax25.c     |    3 +--
 net/econet/af_econet.c |    6 ++----
 net/netrom/af_netrom.c |    3 +--
 net/rose/af_rose.c     |    3 +--
 net/x25/af_x25.c       |    3 +--
 7 files changed, 41 insertions(+), 16 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 010e14a..570c7a1 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1206,6 +1206,39 @@ static inline int skb_copy_to_page(struct sock *=
sk, char __user *from,
 	return 0;
 }
=20
+/**
+ * sk_wmem_alloc_get - returns write allocations
+ * @sk: socket
+ *
+ * Returns sk_wmem_alloc minus initial offset of one
+ */
+static inline int sk_wmem_alloc_get(const struct sock *sk)
+{
+	return atomic_read(&sk->sk_wmem_alloc) - 1;
+}
+
+/**
+ * sk_rmem_alloc_get - returns read allocations
+ * @sk: socket
+ *
+ * Returns sk_rmem_alloc
+ */
+static inline int sk_rmem_alloc_get(const struct sock *sk)
+{
+	return atomic_read(&sk->sk_rmem_alloc);
+}
+
+/**
+ * sk_has_allocations - check if allocations are outstanding
+ * @sk: socket
+ *
+ * Returns true if socket has write or read allocations
+ */
+static inline int sk_has_allocations(const struct sock *sk)
+{
+	return sk_wmem_alloc_get(sk) || sk_rmem_alloc_get(sk);
+}
+
 /*
  * 	Queue a received datagram if it will fit. Stream and sequenced
  *	protocols can't normally use this as they need to fit buffers in
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index b603cba..f7a53b2 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -162,8 +162,7 @@ static void atalk_destroy_timer(unsigned long data)
 {
 	struct sock *sk =3D (struct sock *)data;
=20
-	if (atomic_read(&sk->sk_wmem_alloc) ||
-	    atomic_read(&sk->sk_rmem_alloc)) {
+	if (sk_has_allocations(sk)) {
 		sk->sk_timer.expires =3D jiffies + SOCK_DESTROY_TIME;
 		add_timer(&sk->sk_timer);
 	} else
@@ -175,8 +174,7 @@ static inline void atalk_destroy_socket(struct sock=
 *sk)
 	atalk_remove_socket(sk);
 	skb_queue_purge(&sk->sk_receive_queue);
=20
-	if (atomic_read(&sk->sk_wmem_alloc) ||
-	    atomic_read(&sk->sk_rmem_alloc)) {
+	if (sk_has_allocations(sk)) {
 		setup_timer(&sk->sk_timer, atalk_destroy_timer,
 				(unsigned long)sk);
 		sk->sk_timer.expires	=3D jiffies + SOCK_DESTROY_TIME;
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index fd9d06f..61b35b9 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -330,8 +330,7 @@ void ax25_destroy_socket(ax25_cb *ax25)
 	}
=20
 	if (ax25->sk !=3D NULL) {
-		if (atomic_read(&ax25->sk->sk_wmem_alloc) ||
-		    atomic_read(&ax25->sk->sk_rmem_alloc)) {
+		if (sk_has_allocations(ax25->sk)) {
 			/* Defer: outstanding buffers */
 			setup_timer(&ax25->dtimer, ax25_destroy_timer,
 					(unsigned long)ax25);
diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 8121bf0..2e1f836 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -540,8 +540,7 @@ static void econet_destroy_timer(unsigned long data=
)
 {
 	struct sock *sk=3D(struct sock *)data;
=20
-	if (!atomic_read(&sk->sk_wmem_alloc) &&
-	    !atomic_read(&sk->sk_rmem_alloc)) {
+	if (!sk_has_allocations(sk)) {
 		sk_free(sk);
 		return;
 	}
@@ -579,8 +578,7 @@ static int econet_release(struct socket *sock)
=20
 	skb_queue_purge(&sk->sk_receive_queue);
=20
-	if (atomic_read(&sk->sk_rmem_alloc) ||
-	    atomic_read(&sk->sk_wmem_alloc)) {
+	if (sk_has_allocations(sk)) {
 		sk->sk_timer.data     =3D (unsigned long)sk;
 		sk->sk_timer.expires  =3D jiffies + HZ;
 		sk->sk_timer.function =3D econet_destroy_timer;
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 3be0e01..cd91190 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -286,8 +286,7 @@ void nr_destroy_socket(struct sock *sk)
 		kfree_skb(skb);
 	}
=20
-	if (atomic_read(&sk->sk_wmem_alloc) ||
-	    atomic_read(&sk->sk_rmem_alloc)) {
+	if (sk_has_allocations(sk)) {
 		/* Defer: outstanding buffers */
 		sk->sk_timer.function =3D nr_destroy_timer;
 		sk->sk_timer.expires  =3D jiffies + 2 * HZ;
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 877a7f6..4dd9a7d 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -356,8 +356,7 @@ void rose_destroy_socket(struct sock *sk)
 		kfree_skb(skb);
 	}
=20
-	if (atomic_read(&sk->sk_wmem_alloc) ||
-	    atomic_read(&sk->sk_rmem_alloc)) {
+	if (sk_has_allocations(sk)) {
 		/* Defer: outstanding buffers */
 		setup_timer(&sk->sk_timer, rose_destroy_timer,
 				(unsigned long)sk);
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index c51f309..8cd2390 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -372,8 +372,7 @@ static void __x25_destroy_socket(struct sock *sk)
 		kfree_skb(skb);
 	}
=20
-	if (atomic_read(&sk->sk_wmem_alloc) ||
-	    atomic_read(&sk->sk_rmem_alloc)) {
+	if (sk_has_allocations(sk)) {
 		/* Defer: outstanding buffers */
 		sk->sk_timer.expires  =3D jiffies + 10 * HZ;
 		sk->sk_timer.function =3D x25_destroy_timer;
