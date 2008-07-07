From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 1/7] ICMP: add struct net argument to icmp_out_count
Date: Mon, 07 Jul 2008 14:44:06 +0400
Message-ID: <4871F376.3060609@openvz.org>
References: <4871F2D8.8030502@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56482 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752573AbYGGKqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 06:46:39 -0400
In-Reply-To: <4871F2D8.8030502@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This routine deals with ICMP statistics, but doesn't have a
struct net at hands, so add one.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/icmp.h   |    3 ++-
 net/ipv4/icmp.c      |    2 +-
 net/ipv4/ip_output.c |    3 ++-
 net/ipv4/raw.c       |    3 ++-
 4 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/net/icmp.h b/include/net/icmp.h
index dddb839..38ca2f3 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -44,12 +44,13 @@ DECLARE_SNMP_STAT(struct icmpmsg_mib, icmpmsg_statistics);
 struct dst_entry;
 struct net_proto_family;
 struct sk_buff;
+struct net;
 
 extern void	icmp_send(struct sk_buff *skb_in,  int type, int code, __be32 info);
 extern int	icmp_rcv(struct sk_buff *skb);
 extern int	icmp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 extern int	icmp_init(void);
-extern void	icmp_out_count(unsigned char type);
+extern void	icmp_out_count(struct net *net, unsigned char type);
 
 /* Move into dst.h ? */
 extern int 	xrlim_allow(struct dst_entry *dst, int timeout);
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index aa7cf46..1ffe7ad 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -296,7 +296,7 @@ out:
 /*
  *	Maintain the counters used in the SNMP statistics for outgoing ICMP
  */
-void icmp_out_count(unsigned char type)
+void icmp_out_count(struct net *net, unsigned char type)
 {
 	ICMPMSGOUT_INC_STATS(type);
 	ICMP_INC_STATS(ICMP_MIB_OUTMSGS);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index f1278ee..f003186 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1211,6 +1211,7 @@ int ip_push_pending_frames(struct sock *sk)
 	struct sk_buff *skb, *tmp_skb;
 	struct sk_buff **tail_skb;
 	struct inet_sock *inet = inet_sk(sk);
+	struct net *net = sock_net(sk);
 	struct ip_options *opt = NULL;
 	struct rtable *rt = (struct rtable *)inet->cork.dst;
 	struct iphdr *iph;
@@ -1280,7 +1281,7 @@ int ip_push_pending_frames(struct sock *sk)
 	skb->dst = dst_clone(&rt->u.dst);
 
 	if (iph->protocol == IPPROTO_ICMP)
-		icmp_out_count(((struct icmphdr *)
+		icmp_out_count(net, ((struct icmphdr *)
 			skb_transport_header(skb))->type);
 
 	/* Netfilter gets whole the not fragmented skb. */
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 925fdf1..7f39ea4 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -320,6 +320,7 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 			unsigned int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
+	struct net *net = sock_net(sk);
 	struct iphdr *iph;
 	struct sk_buff *skb;
 	unsigned int iphlen;
@@ -368,7 +369,7 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 		iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
 	}
 	if (iph->protocol == IPPROTO_ICMP)
-		icmp_out_count(((struct icmphdr *)
+		icmp_out_count(net, ((struct icmphdr *)
 			skb_transport_header(skb))->type);
 
 	err = NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-- 
1.5.3.4

