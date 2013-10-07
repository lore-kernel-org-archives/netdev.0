From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: [PATCH net-next v3 3/3] net: ipv4 only populate IP_PKTINFO when needed
Date: Mon,  7 Oct 2013 11:01:40 -0500
Message-ID: <1381161700-14453-4-git-send-email-shawn.bohrer@gmail.com>
References: <1381161700-14453-1-git-send-email-shawn.bohrer@gmail.com>
Cc: netdev <netdev@vger.kernel.org>, tomk@rgmadvisors.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:34814 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755876Ab3JGQCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 12:02:15 -0400
Received: by mail-oa0-f54.google.com with SMTP id n5so6270810oag.41
        for <netdev@vger.kernel.org>; Mon, 07 Oct 2013 09:02:14 -0700 (PDT)
In-Reply-To: <1381161700-14453-1-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Bohrer <sbohrer@rgmadvisors.com>

The since the removal of the routing cache computing
fib_compute_spec_dst() does a fib_table lookup for each UDP multicast
packet received.  This has introduced a performance regression for some
UDP workloads.

This change skips populating the packet info for sockets that do not have
IP_PKTINFO set.

Benchmark results from a netperf UDP_RR test:
Before 89789.68 transactions/s
After  90587.62 transactions/s

Benchmark results from a fio 1 byte UDP multicast pingpong test
(Multicast one way unicast response):
Before 12.63us RTT
After  12.48us RTT

Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip.h       |    2 +-
 net/ipv4/ip_sockglue.c |    5 +++--
 net/ipv4/raw.c         |    2 +-
 net/ipv4/udp.c         |    2 +-
 4 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 16078f4..b39ebe5 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -459,7 +459,7 @@ int ip_options_rcv_srr(struct sk_buff *skb);
  *	Functions provided by ip_sockglue.c
  */
 
-void ipv4_pktinfo_prepare(struct sk_buff *skb);
+void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb);
 void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb);
 int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc);
 int ip_setsockopt(struct sock *sk, int level, int optname, char __user *optval,
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 56e3445..0626f2c 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1052,11 +1052,12 @@ e_inval:
  * destination in skb->cb[] before dst drop.
  * This way, receiver doesnt make cache line misses to read rtable.
  */
-void ipv4_pktinfo_prepare(struct sk_buff *skb)
+void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb)
 {
 	struct in_pktinfo *pktinfo = PKTINFO_SKB_CB(skb);
 
-	if (skb_rtable(skb)) {
+	if ((inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO) &&
+	    skb_rtable(skb)) {
 		pktinfo->ipi_ifindex = inet_iif(skb);
 		pktinfo->ipi_spec_dst.s_addr = fib_compute_spec_dst(skb);
 	} else {
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index b2fa14c..41e1d28 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -299,7 +299,7 @@ static int raw_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	/* Charge it to the socket. */
 
-	ipv4_pktinfo_prepare(skb);
+	ipv4_pktinfo_prepare(sk, skb);
 	if (sock_queue_rcv_skb(sk, skb) < 0) {
 		kfree_skb(skb);
 		return NET_RX_DROP;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 262ea39..4226c53 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1544,7 +1544,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 	rc = 0;
 
-	ipv4_pktinfo_prepare(skb);
+	ipv4_pktinfo_prepare(sk, skb);
 	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk))
 		rc = __udp_queue_rcv_skb(sk, skb);
-- 
1.7.7.6
