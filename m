From: Davide Caratti <dcaratti@redhat.com>
Subject: [RFC PATCH net-next 4/5] net: more accurate checksumming in validate_xmit_skb
Date: Mon, 23 Jan 2017 17:52:45 +0100
Message-ID: <330fd75699b574ca577b884f0c57a763a33ef538.1485177252.git.dcaratti@redhat.com>
References: <cover.1485177252.git.dcaratti@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38578 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750828AbdAWQ7W (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 11:59:22 -0500
In-Reply-To: <cover.1485177252.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

introduce skb_csum_hwoffload_help and use it as a replacement for
skb_checksum_help in validate_xmit_skb, to compute checksum using crc32c or
2-complement Internet Checksum (or leave the packet unchanged and let the
NIC do the checksum), depending on netdev checksum offloading capabilities
and on presence of IPPROTO_SCTP as protocol number in IPv4/IPv6 header.

Reviewed-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 net/core/dev.c | 52 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 50 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 45cee84..f8cb3ba 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -140,6 +140,7 @@
 #include <linux/hrtimer.h>
 #include <linux/netfilter_ingress.h>
 #include <linux/crash_dump.h>
+#include <linux/sctp.h>
 
 #include "net-sysfs.h"
 
@@ -2960,6 +2961,54 @@ static struct sk_buff *validate_xmit_vlan(struct sk_buff *skb,
 	return skb;
 }
 
+static int skb_csum_hwoffload_help(struct sk_buff *skb,
+				   netdev_features_t features)
+{
+	bool encap = skb->encapsulation;
+	unsigned int offset = 0;
+	__be16 protocol;
+
+	if (likely((features & (NETIF_F_SCTP_CRC | NETIF_F_CSUM_MASK)) ==
+	    (NETIF_F_SCTP_CRC | NETIF_F_CSUM_MASK)))
+		return 0;
+
+	if (skb->csum_offset != offsetof(struct sctphdr, checksum))
+		goto inet_csum;
+
+	if (encap) {
+		protocol = skb->inner_protocol;
+		if (skb->inner_protocol_type == ENCAP_TYPE_IPPROTO)
+			switch (protocol) {
+			case IPPROTO_IPV6:
+				protocol = ntohs(ETH_P_IPV6);
+				break;
+			case IPPROTO_IP:
+				protocol = ntohs(ETH_P_IP);
+				break;
+			default:
+				goto inet_csum;
+			}
+	} else {
+		protocol = vlan_get_protocol(skb);
+	}
+	switch (protocol) {
+	case ntohs(ETH_P_IP):
+		if ((encap ? inner_ip_hdr(skb) : ip_hdr(skb))->protocol ==
+		    IPPROTO_SCTP)
+			goto sctp_csum;
+		break;
+	case ntohs(ETH_P_IPV6):
+		if (ipv6_find_hdr(skb, &offset, IPPROTO_SCTP, NULL, NULL) ==
+		    IPPROTO_SCTP)
+			goto sctp_csum;
+		break;
+	}
+inet_csum:
+	return !(features & NETIF_F_CSUM_MASK) ? skb_checksum_help(skb) : 0;
+sctp_csum:
+	return !(features & NETIF_F_SCTP_CRC) ? skb_sctp_csum_help(skb) : 0;
+}
+
 static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev)
 {
 	netdev_features_t features;
@@ -2995,8 +3044,7 @@ static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device
 			else
 				skb_set_transport_header(skb,
 							 skb_checksum_start_offset(skb));
-			if (!(features & NETIF_F_CSUM_MASK) &&
-			    skb_checksum_help(skb))
+			if (skb_csum_hwoffload_help(skb, features))
 				goto out_kfree_skb;
 		}
 	}
-- 
2.7.4
