From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: PKTINFO doesnt need dst reference
Date: Wed, 09 Nov 2011 18:24:35 +0100
Message-ID: <1320859475.3916.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EB6AE62.5050803@itcare.pl>
	 <1320600597.6506.7.camel@edumazet-laptop> <4EB6D1D8.8040604@itcare.pl>
	 <1320605326.6506.27.camel@edumazet-laptop> <4EB6DE06.7050009@itcare.pl>
	 <1320608290.6506.33.camel@edumazet-laptop>
	 <1320673364.3020.21.camel@bwh-desktop>
	 <1320676422.2361.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50490 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285Ab1KIRYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 12:24:39 -0500
Received: by wyh15 with SMTP id 15so1832887wyh.19
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2011 09:24:38 -0800 (PST)
In-Reply-To: <1320676422.2361.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 07 novembre 2011 =C3=A0 15:33 +0100, Eric Dumazet a =C3=A9crit=
 :

> At least, in recent kernels we dont change dst->refcnt in forwarding
> patch (usinf NOREF skb->dst)
>=20
> One particular point is the atomic_inc(dst->refcnt) we have to perfor=
m
> when queuing an UDP packet if socket asked PKTINFO stuff (for example=
 a
> typical DNS server has to setup this option)
>=20
> I have one patch somewhere that stores the information in skb->cb[] a=
nd
> avoid the atomic_{inc|dec}(dst->refcnt).
>=20

OK I found it, I did some extra tests and believe its ready.

[PATCH net-next] ipv4: IP_PKTINFO doesnt need dst reference

When a socket uses IP_PKTINFO notifications, we currently force a dst
reference for each received skb. Reader has to access dst to get needed
information (rt_iif & rt_spec_dst) and must release dst reference.

We also forced a dst reference if skb was put in socket backlog, even
without IP_PKTINFO handling. This happens under stress/load.

We can instead store the needed information in skb->cb[], so that only
softirq handler really access dst, improving cache hit ratios.

This removes two atomic operations per packet, and false sharing as
well.

On a benchmark using a mono threaded receiver (doing only recvmsg()
calls), I can reach 720.000 pps instead of 570.000 pps.

IP_PKTINFO is typically used by DNS servers, and any multihomed aware
UDP application.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/ip.h       |    2 +-
 net/ipv4/ip_sockglue.c |   37 +++++++++++++++++++------------------
 net/ipv4/raw.c         |    3 ++-
 net/ipv4/udp.c         |    3 ++-
 net/ipv6/raw.c         |    3 ++-
 net/ipv6/udp.c         |    4 +++-
 6 files changed, 29 insertions(+), 23 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index eca0ef7..fd1561e 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -450,7 +450,7 @@ extern int ip_options_rcv_srr(struct sk_buff *skb);
  *	Functions provided by ip_sockglue.c
  */
=20
-extern int	ip_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
+extern void	ipv4_pktinfo_prepare(struct sk_buff *skb);
 extern void	ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb);
 extern int	ip_cmsg_send(struct net *net,
 			     struct msghdr *msg, struct ipcm_cookie *ipc);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 09ff51b..b516030 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -55,20 +55,13 @@
 /*
  *	SOL_IP control messages.
  */
+#define PKTINFO_SKB_CB(__skb) ((struct in_pktinfo *)((__skb)->cb))
=20
 static void ip_cmsg_recv_pktinfo(struct msghdr *msg, struct sk_buff *s=
kb)
 {
-	struct in_pktinfo info;
-	struct rtable *rt =3D skb_rtable(skb);
-
+	struct in_pktinfo info =3D *PKTINFO_SKB_CB(skb);
+	=09
 	info.ipi_addr.s_addr =3D ip_hdr(skb)->daddr;
-	if (rt) {
-		info.ipi_ifindex =3D rt->rt_iif;
-		info.ipi_spec_dst.s_addr =3D rt->rt_spec_dst;
-	} else {
-		info.ipi_ifindex =3D 0;
-		info.ipi_spec_dst.s_addr =3D 0;
-	}
=20
 	put_cmsg(msg, SOL_IP, IP_PKTINFO, sizeof(info), &info);
 }
@@ -992,20 +985,28 @@ e_inval:
 }
=20
 /**
- * ip_queue_rcv_skb - Queue an skb into sock receive queue
+ * ipv4_pktinfo_prepare - transfert some info from rtable to skb
  * @sk: socket
  * @skb: buffer
  *
- * Queues an skb into socket receive queue. If IP_CMSG_PKTINFO option
- * is not set, we drop skb dst entry now, while dst cache line is hot.
+ * To support IP_CMSG_PKTINFO option, we store rt_iif and rt_spec_dst
+ * in skb->cb[] before dst drop.
+ * This way, receiver doesnt make cache line misses to read rtable.
  */
-int ip_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+void ipv4_pktinfo_prepare(struct sk_buff *skb)
 {
-	if (!(inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO))
-		skb_dst_drop(skb);
-	return sock_queue_rcv_skb(sk, skb);
+	struct in_pktinfo *pktinfo =3D PKTINFO_SKB_CB(skb);
+	const struct rtable *rt =3D skb_rtable(skb);
+
+	if (rt) {
+		pktinfo->ipi_ifindex =3D rt->rt_iif;
+		pktinfo->ipi_spec_dst.s_addr =3D rt->rt_spec_dst;
+	} else {
+		pktinfo->ipi_ifindex =3D 0;
+		pktinfo->ipi_spec_dst.s_addr =3D 0;
+	}
+	skb_dst_drop(skb);
 }
-EXPORT_SYMBOL(ip_queue_rcv_skb);
=20
 int ip_setsockopt(struct sock *sk, int level,
 		int optname, char __user *optval, unsigned int optlen)
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 007e2eb..7a8410d 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -292,7 +292,8 @@ static int raw_rcv_skb(struct sock * sk, struct sk_=
buff * skb)
 {
 	/* Charge it to the socket. */
=20
-	if (ip_queue_rcv_skb(sk, skb) < 0) {
+	ipv4_pktinfo_prepare(skb);
+	if (sock_queue_rcv_skb(sk, skb) < 0) {
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ab0966d..6854f58 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1357,7 +1357,7 @@ static int __udp_queue_rcv_skb(struct sock *sk, s=
truct sk_buff *skb)
 	if (inet_sk(sk)->inet_daddr)
 		sock_rps_save_rxhash(sk, skb);
=20
-	rc =3D ip_queue_rcv_skb(sk, skb);
+	rc =3D sock_queue_rcv_skb(sk, skb);
 	if (rc < 0) {
 		int is_udplite =3D IS_UDPLITE(sk);
=20
@@ -1473,6 +1473,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_=
buff *skb)
=20
 	rc =3D 0;
=20
+	ipv4_pktinfo_prepare(skb);
 	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk))
 		rc =3D __udp_queue_rcv_skb(sk, skb);
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 331af3b..204f2e8 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -383,7 +383,8 @@ static inline int rawv6_rcv_skb(struct sock *sk, st=
ruct sk_buff *skb)
 	}
=20
 	/* Charge it to the socket. */
-	if (ip_queue_rcv_skb(sk, skb) < 0) {
+	skb_dst_drop(skb);
+	if (sock_queue_rcv_skb(sk, skb) < 0) {
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 846f475..b4a4a15 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -538,7 +538,9 @@ int udpv6_queue_rcv_skb(struct sock * sk, struct sk=
_buff *skb)
 			goto drop;
 	}
=20
-	if ((rc =3D ip_queue_rcv_skb(sk, skb)) < 0) {
+	skb_dst_drop(skb);
+	rc =3D sock_queue_rcv_skb(sk, skb);
+	if (rc < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc =3D=3D -ENOMEM)
 			UDP6_INC_STATS_BH(sock_net(sk),
