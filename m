From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: [net-next 3/3] net: ipv4 only populate IP_PKTINFO when needed
Date: Tue,  1 Oct 2013 14:33:45 -0500
Message-ID: <1380656025-8847-4-git-send-email-sbohrer@rgmadvisors.com>
References: <1380656025-8847-1-git-send-email-sbohrer@rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>, tomk@rgmadvisors.com,
	netdev <netdev@vger.kernel.org>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:32995 "EHLO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751716Ab3JATe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 15:34:26 -0400
Received: by mail-oa0-f46.google.com with SMTP id k14so5321053oag.33
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 12:34:26 -0700 (PDT)
In-Reply-To: <1380656025-8847-1-git-send-email-sbohrer@rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The since the removal of the routing cache computing
fib_compute_spec_dst() does a fib_table lookup for each UDP multicast
packet received.  This has introduced a performance regression for some
UDP workloads.

This change skips populating the packet info for sockets that do not have
IP_PKTINFO set.

Benchmark results from a netperf UDP_RR test:
Before 91296.97 transactions/s
After  91792.70 transactions/s

Benchmark results from a fio 1 byte UDP multicast pingpong test
(Multicast one way unicast response):
Before 12.647us RTT
After  12.233us RTT

Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
---
 include/net/ip.h       |    2 +-
 net/ipv4/ip_sockglue.c |    5 +++--
 net/ipv4/raw.c         |    2 +-
 net/ipv4/udp.c         |    2 +-
 4 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 16078f4..bc98241 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -459,7 +459,7 @@ int ip_options_rcv_srr(struct sk_buff *skb);
  *	Functions provided by ip_sockglue.c
  */
 
-void ipv4_pktinfo_prepare(struct sk_buff *skb);
+void	ipv4_pktinfo_prepare(struct sock *sk, struct sk_buff *skb);
 void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb);
 int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc);
 int ip_setsockopt(struct sock *sk, int level, int optname, char __user *optval,
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 56e3445..dda9866 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1052,11 +1052,12 @@ e_inval:
  * destination in skb->cb[] before dst drop.
  * This way, receiver doesnt make cache line misses to read rtable.
  */
-void ipv4_pktinfo_prepare(struct sk_buff *skb)
+void ipv4_pktinfo_prepare(struct sock *sk, struct sk_buff *skb)
 {
 	struct in_pktinfo *pktinfo = PKTINFO_SKB_CB(skb);
 
-	if (skb_rtable(skb)) {
+	if ((inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO) &&
+	    skb_rtable(skb)) {
 		pktinfo->ipi_ifindex = inet_iif(skb);
 		pktinfo->ipi_spec_dst.s_addr = fib_compute_spec_dst(skb);
 	} else {
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index a3fe534..28694f8 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -297,7 +297,7 @@ static int raw_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	/* Charge it to the socket. */
 
-	ipv4_pktinfo_prepare(skb);
+	ipv4_pktinfo_prepare(sk, skb);
 	if (sock_queue_rcv_skb(sk, skb) < 0) {
 		kfree_skb(skb);
 		return NET_RX_DROP;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ca54886..02185a5 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1543,7 +1543,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 	rc = 0;
 
-	ipv4_pktinfo_prepare(skb);
+	ipv4_pktinfo_prepare(sk, skb);
 	bh_lock_sock(sk);
 	if (!sock_owned_by_user(sk))
 		rc = __udp_queue_rcv_skb(sk, skb);
-- 
1.7.7.6


-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
