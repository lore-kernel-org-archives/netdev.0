From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 3/5] ip6gre: Add support for basic offloads
 offloads excluding GSO
Date: Thu, 14 Apr 2016 15:33:51 -0400
Message-ID: <20160414193351.12934.34039.stgit@ahduyck-xeon-server>
References: <20160414192709.12934.82858.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: jesse@kernel.org, netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34225 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbcDNTd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 15:33:58 -0400
Received: by mail-pa0-f48.google.com with SMTP id ot11so47595205pab.1
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 12:33:58 -0700 (PDT)
In-Reply-To: <20160414192709.12934.82858.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the basic offloads we support on most devices.
Specifically with this patch set we can support checksum offload, basic
scatter-gather, and highdma.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv6/ip6_gre.c |   23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 2be66e7b4a78..1a5ad143be40 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -598,6 +598,18 @@ static void init_tel_txopt(struct ipv6_tel_txoption *opt, __u8 encap_limit)
 	opt->ops.opt_nflen = 8;
 }
 
+static __sum16 gre6_checksum(struct sk_buff *skb)
+{
+	__wsum csum;
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		csum = lco_csum(skb);
+	else
+		csum = skb_checksum(skb, sizeof(struct ipv6hdr),
+				    skb->len - sizeof(struct ipv6hdr), 0);
+	return csum_fold(csum);
+}
+
 static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 			 struct net_device *dev,
 			 __u8 dsfield,
@@ -750,8 +762,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 		}
 		if (tunnel->parms.o_flags&GRE_CSUM) {
 			*ptr = 0;
-			*(__sum16 *)ptr = ip_compute_csum((void *)(ipv6h+1),
-				skb->len - sizeof(struct ipv6hdr));
+			*(__sum16 *)ptr = gre6_checksum(skb);
 		}
 	}
 
@@ -1507,6 +1518,11 @@ static const struct net_device_ops ip6gre_tap_netdev_ops = {
 	.ndo_get_iflink = ip6_tnl_get_iflink,
 };
 
+#define GRE6_FEATURES (NETIF_F_SG |		\
+		       NETIF_F_FRAGLIST |	\
+		       NETIF_F_HIGHDMA |		\
+		       NETIF_F_HW_CSUM)
+
 static void ip6gre_tap_setup(struct net_device *dev)
 {
 
@@ -1540,6 +1556,9 @@ static int ip6gre_newlink(struct net *src_net, struct net_device *dev,
 	nt->net = dev_net(dev);
 	ip6gre_tnl_link_config(nt, !tb[IFLA_MTU]);
 
+	dev->features		|= GRE6_FEATURES;
+	dev->hw_features	|= GRE6_FEATURES;
+
 	/* Can use a lockless transmit, unless we generate output sequences */
 	if (!(nt->parms.o_flags & GRE_SEQ))
 		dev->features |= NETIF_F_LLTX;
