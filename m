From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: ip_queue_rcv_skb() helper
Date: Thu, 29 Apr 2010 00:22:44 +0200
Message-ID: <1272493364.2201.67.camel@edumazet-laptop>
References: <1272458001.2267.0.camel@edumazet-laptop>
	 <1272458174.14068.16.camel@bigi> <1272463605.2267.70.camel@edumazet-laptop>
	 <20100428.143610.232922250.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:58384 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932236Ab0D1WWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 18:22:50 -0400
Received: by bwz19 with SMTP id 19so68216bwz.21
        for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 15:22:47 -0700 (PDT)
In-Reply-To: <20100428.143610.232922250.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 28 avril 2010 =C3=A0 14:36 -0700, David Miller a =C3=A9crit=
 :

>=20
> Clever, let's see what this breaks :-)
>=20
> Applied, thanks Eric.

Thanks ;)

Let's respin an old work about dst, with a first small work unit :

Next patch will try to not touch dst refcount in input path (previously
attempted in July 2009)
Ref : http://kerneltrap.org/mailarchive/linux-netdev/2009/7/22/6248753


[PATCH net-next-2.6] net: ip_queue_rcv_skb() helper

When queueing a skb to socket, we can immediately release its dst if
target socket do not use IP_CMSG_PKTINFO.

tcp_data_queue() can drop dst too.

This to benefit from a hot cache line and avoid the receiver, possibly
on another cpu, to dirty this cache line himself.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/ip.h       |    1 +
 net/ipv4/ip_sockglue.c |   16 ++++++++++++++++
 net/ipv4/raw.c         |    2 +-
 net/ipv4/tcp_input.c   |    1 +
 net/ipv4/udp.c         |    2 +-
 net/ipv6/raw.c         |    2 +-
 net/ipv6/udp.c         |    2 +-
 7 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index a84ceb6..8149b77 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -393,6 +393,7 @@ extern int ip_options_rcv_srr(struct sk_buff *skb);
  *	Functions provided by ip_sockglue.c
  */
=20
+extern int	ip_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 extern void	ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb);
 extern int	ip_cmsg_send(struct net *net,
 			     struct msghdr *msg, struct ipcm_cookie *ipc);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index b0aa054..ce23178 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -954,6 +954,22 @@ e_inval:
 	return -EINVAL;
 }
=20
+/**
+ * ip_queue_rcv_skb - Queue an skb into sock receive queue
+ * @sk: socket
+ * @skb: buffer
+ *
+ * Queues an skb into socket receive queue. If IP_CMSG_PKTINFO option
+ * is not set, we drop skb dst entry now, while dst cache line is hot.
+ */
+int ip_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	if (!(inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO))
+		skb_dst_drop(skb);
+	return sock_queue_rcv_skb(sk, skb);
+}
+EXPORT_SYMBOL(ip_queue_rcv_skb);
+
 int ip_setsockopt(struct sock *sk, int level,
 		int optname, char __user *optval, unsigned int optlen)
 {
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index cc6f097..52ef5af 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -290,7 +290,7 @@ static int raw_rcv_skb(struct sock * sk, struct sk_=
buff * skb)
 {
 	/* Charge it to the socket. */
=20
-	if (sock_queue_rcv_skb(sk, skb) < 0) {
+	if (ip_queue_rcv_skb(sk, skb) < 0) {
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ae3ec15..e82162c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4367,6 +4367,7 @@ static void tcp_data_queue(struct sock *sk, struc=
t sk_buff *skb)
 	if (TCP_SKB_CB(skb)->seq =3D=3D TCP_SKB_CB(skb)->end_seq)
 		goto drop;
=20
+	skb_dst_drop(skb);
 	__skb_pull(skb, th->doff * 4);
=20
 	TCP_ECN_accept_cwr(tp, skb);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 63eb56b..8591398 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1264,7 +1264,7 @@ static int __udp_queue_rcv_skb(struct sock *sk, s=
truct sk_buff *skb)
 	if (inet_sk(sk)->inet_daddr)
 		sock_rps_save_rxhash(sk, skb->rxhash);
=20
-	rc =3D sock_queue_rcv_skb(sk, skb);
+	rc =3D ip_queue_rcv_skb(sk, skb);
 	if (rc < 0) {
 		int is_udplite =3D IS_UDPLITE(sk);
=20
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 8562738..0e3d2dd 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -381,7 +381,7 @@ static inline int rawv6_rcv_skb(struct sock * sk, s=
truct sk_buff * skb)
 	}
=20
 	/* Charge it to the socket. */
-	if (sock_queue_rcv_skb(sk, skb) < 0) {
+	if (ip_queue_rcv_skb(sk, skb) < 0) {
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 3ead20a..aa0e47a 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -514,7 +514,7 @@ int udpv6_queue_rcv_skb(struct sock * sk, struct sk=
_buff *skb)
 			goto drop;
 	}
=20
-	if ((rc =3D sock_queue_rcv_skb(sk, skb)) < 0) {
+	if ((rc =3D ip_queue_rcv_skb(sk, skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc =3D=3D -ENOMEM)
 			UDP6_INC_STATS_BH(sock_net(sk),


