From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] ipv4: fix error handling in icmp_protocol.
Date: Fri, 22 Feb 2013 16:18:44 +0800
Message-ID: <1361521124-1135-1-git-send-email-lw@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, lw@cn.fujitsu.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:20543 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754910Ab3BVI2p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2013 03:28:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now we handle icmp errors in each transport protocol's err_handler,
for icmp protocols, that is ping_err. Since this handler only care
of those icmp errors triggered by echo request, errors triggered
by echo reply(which sent by kernel) are sliently ignored.

So wrap ping_err() with icmp_err() to deal with those icmp errors.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 include/net/icmp.h |  1 +
 net/ipv4/af_inet.c |  2 +-
 net/ipv4/icmp.c    | 23 +++++++++++++++++++++++
 3 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/include/net/icmp.h b/include/net/icmp.h
index 9ac2524..081439f 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -41,6 +41,7 @@ struct net;
 
 extern void	icmp_send(struct sk_buff *skb_in,  int type, int code, __be32 info);
 extern int	icmp_rcv(struct sk_buff *skb);
+extern void	icmp_err(struct sk_buff *, u32 info);
 extern int	icmp_init(void);
 extern void	icmp_out_count(struct net *net, unsigned char type);
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e225a4e..334b461 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1572,7 +1572,7 @@ static const struct net_offload udp_offload = {
 
 static const struct net_protocol icmp_protocol = {
 	.handler =	icmp_rcv,
-	.err_handler =	ping_err,
+	.err_handler =	icmp_err,
 	.no_policy =	1,
 	.netns_ok =	1,
 };
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 17ff9fd..3ac5dff 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -934,6 +934,29 @@ error:
 	goto drop;
 }
 
+void icmp_err(struct sk_buff *skb, u32 info)
+{
+	struct iphdr *iph = (struct iphdr *)skb->data;
+	struct icmphdr *icmph = (struct icmphdr *)(skb->data+(iph->ihl<<2));
+	int type = icmp_hdr(skb)->type;
+	int code = icmp_hdr(skb)->code;
+	struct net *net = dev_net(skb->dev);
+
+	/*
+	 * Use ping_err to handle all icmp errors except those
+	 * triggered by ICMP_ECHOREPLY which sent from kernel.
+	 */
+	if (icmph->type != ICMP_ECHOREPLY) {
+		ping_err(skb, info);
+		return;
+	}
+
+	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED)
+		ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_ICMP, 0);
+	else if (type == ICMP_REDIRECT)
+		ipv4_redirect(skb, net, 0, 0, IPPROTO_ICMP, 0);
+}
+
 /*
  *	This table is the definition of how we handle ICMP.
  */
-- 
1.8.0.2
