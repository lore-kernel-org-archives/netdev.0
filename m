From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 1/2] ipip: Use tunnel_ip_select_ident() for tunnel IP-Identification.
Date: Fri,  8 Mar 2013 17:12:45 -0800
Message-ID: <1362791565-1800-1-git-send-email-pshelar@nicira.com>
Cc: jesse@nicira.com, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:57950 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759941Ab3CIBLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 20:11:45 -0500
Received: by mail-oa0-f71.google.com with SMTP id o6so13886281oag.10
        for <netdev@vger.kernel.org>; Fri, 08 Mar 2013 17:11:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tunnel_ip_select_ident() is more efficient when generating ip-header
id given inner packet is of ipv4 type.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/ipip.c |   21 ++++++++++++++++++++-
 1 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 8f024d4..18f5352 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -478,6 +478,8 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	__be32 dst = tiph->daddr;
 	struct flowi4 fl4;
 	int    mtu;
+	int err;
+	int pkt_len;
 
 	if (skb->protocol != htons(ETH_P_IP))
 		goto tx_error;
@@ -591,11 +593,28 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	iph->tos		=	INET_ECN_encapsulate(tos, old_iph->tos);
 	iph->daddr		=	fl4.daddr;
 	iph->saddr		=	fl4.saddr;
+	tunnel_ip_select_ident(skb, old_iph, &rt->dst);
 
 	if ((iph->ttl = tiph->ttl) == 0)
 		iph->ttl	=	old_iph->ttl;
 
-	iptunnel_xmit(skb, dev);
+	nf_reset(skb);
+	skb->ip_summed = CHECKSUM_NONE;
+
+	pkt_len = skb->len - skb_transport_offset(skb);
+	err = ip_local_out(skb);
+	if (likely(net_xmit_eval(err) == 0)) {
+		struct pcpu_tstats *tstats = this_cpu_ptr(dev->tstats);
+
+		u64_stats_update_begin(&tstats->syncp);
+		tstats->tx_bytes += pkt_len;
+		tstats->tx_packets++;
+		u64_stats_update_end(&tstats->syncp);
+	} else {
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
+	}
+
 	return NETDEV_TX_OK;
 
 tx_error_icmp:
-- 
1.7.1
