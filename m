From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Wed, 21 Dec 2011 18:11:44 +0100
Message-ID: <1324487504.2301.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EF1B0D9.2010007@monstr.eu>
	 <1324463334.2728.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324463452.2728.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1B5BC.5020103@monstr.eu>
	 <1324463838.2728.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1B7E4.4010602@monstr.eu>
	 <1324464308.2728.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324465386.2728.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1BEA4.7080005@monstr.eu>
	 <1324466023.2728.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1C80B.4060701@monstr.eu>
	 <1324471194.2728.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1DF00.1090309@monstr.eu>
	 <1324474811.2728.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1EC28.90008@monstr.eu>
	 <1324483144.2301.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:59581 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009Ab1LURLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 12:11:48 -0500
Received: by vcbfk14 with SMTP id fk14so5912516vcb.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 09:11:47 -0800 (PST)
In-Reply-To: <1324483144.2301.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 16:59 +0100, Eric Dumazet a =C3=
=A9crit :

> I wonder if you applied/tested my patch correctly, since it really
> should had help in your case  (allowing first received packet to be
> queued, even if very big)

Hmm, I missed another spot in sock_queue_rcv_skb().
(RAW sockets are not PACKET :) )

Here is the patch again, I tested it with 'busybox ping' and MTU=3D9000=
,
it solved the problem for me.

Thanks

[PATCH net-next] net: relax rcvbuf limits

skb->truesize might be big even for a small packet.

Its even bigger after commit 87fb4b7b533 (net: more accurate skb
truesize) and big MTU.

We should allow queueing at least one packet per receiver, even with a
low RCVBUF setting.

Reported-by: Michal Simek <monstr@monstr.eu>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h     |    4 +++-
 net/core/sock.c        |    6 +-----
 net/packet/af_packet.c |    6 ++----
 3 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index bf6b9fd..21bb3b5 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -662,12 +662,14 @@ static inline void __sk_add_backlog(struct sock *=
sk, struct sk_buff *skb)
=20
 /*
  * Take into account size of receive queue and backlog queue
+ * Do not take into account this skb truesize,
+ * to allow even a single big packet to come.
  */
 static inline bool sk_rcvqueues_full(const struct sock *sk, const stru=
ct sk_buff *skb)
 {
 	unsigned int qsize =3D sk->sk_backlog.len + atomic_read(&sk->sk_rmem_=
alloc);
=20
-	return qsize + skb->truesize > sk->sk_rcvbuf;
+	return qsize > sk->sk_rcvbuf;
 }
=20
 /* The per-socket spinlock must be held here. */
diff --git a/net/core/sock.c b/net/core/sock.c
index a343286..347b6d9 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -339,11 +339,7 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_=
buff *skb)
 	unsigned long flags;
 	struct sk_buff_head *list =3D &sk->sk_receive_queue;
=20
-	/* Cast sk->rcvbuf to unsigned... It's pointless, but reduces
-	   number of warnings when compiling with -W --ANK
-	 */
-	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=3D
-	    (unsigned)sk->sk_rcvbuf) {
+	if (atomic_read(&sk->sk_rmem_alloc) >=3D sk->sk_rcvbuf) {
 		atomic_inc(&sk->sk_drops);
 		trace_sock_rcvqueue_full(sk, skb);
 		return -ENOMEM;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 0da505c..e56ca75 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1631,8 +1631,7 @@ static int packet_rcv(struct sk_buff *skb, struct=
 net_device *dev,
 	if (snaplen > res)
 		snaplen =3D res;
=20
-	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=3D
-	    (unsigned)sk->sk_rcvbuf)
+	if (atomic_read(&sk->sk_rmem_alloc) >=3D sk->sk_rcvbuf)
 		goto drop_n_acct;
=20
 	if (skb_shared(skb)) {
@@ -1763,8 +1762,7 @@ static int tpacket_rcv(struct sk_buff *skb, struc=
t net_device *dev,
 	if (po->tp_version <=3D TPACKET_V2) {
 		if (macoff + snaplen > po->rx_ring.frame_size) {
 			if (po->copy_thresh &&
-				atomic_read(&sk->sk_rmem_alloc) + skb->truesize
-				< (unsigned)sk->sk_rcvbuf) {
+			    atomic_read(&sk->sk_rmem_alloc) < sk->sk_rcvbuf) {
 				if (skb_shared(skb)) {
 					copy_skb =3D skb_clone(skb, GFP_ATOMIC);
 				} else {
