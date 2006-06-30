From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] tg3: Add ipv6 TSO feature
Date: Fri, 30 Jun 2006 16:35:12 -0700
Message-ID: <1151710512.3645.5.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:27154 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S932233AbWF3XeG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 19:34:06 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable ipv6 TSO feature on chips that support it.

Update version to 3.61.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 47c96fc..b992c0a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -69,8 +69,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.61"
-#define DRV_MODULE_RELDATE	"June 29, 2006"
+#define DRV_MODULE_VERSION	"3.62"
+#define DRV_MODULE_RELDATE	"June 30, 2006"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
@@ -3799,18 +3799,24 @@ static int tg3_start_xmit(struct sk_buff
 			goto out_unlock;
 		}
 
-		tcp_opt_len = ((skb->h.th->doff - 5) * 4);
-		ip_tcp_len = (skb->nh.iph->ihl * 4) + sizeof(struct tcphdr);
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+			mss |= (skb_headlen(skb) - ETH_HLEN) << 9;
+		else {
+			tcp_opt_len = ((skb->h.th->doff - 5) * 4);
+			ip_tcp_len = (skb->nh.iph->ihl * 4) +
+				     sizeof(struct tcphdr);
+
+			skb->nh.iph->check = 0;
+			skb->nh.iph->tot_len = htons(mss + ip_tcp_len +
+						     tcp_opt_len);
+			mss |= (ip_tcp_len + tcp_opt_len) << 9;
+		}
 
 		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
 			       TXD_FLAG_CPU_POST_DMA);
 
-		skb->nh.iph->check = 0;
-		skb->nh.iph->tot_len = htons(mss + ip_tcp_len + tcp_opt_len);
-
 		skb->h.th->check = 0;
 
-		mss |= (ip_tcp_len + tcp_opt_len) << 9;
 	}
 	else if (skb->ip_summed == CHECKSUM_HW)
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
@@ -7888,6 +7894,12 @@ static int tg3_set_tso(struct net_device
 			return -EINVAL;
 		return 0;
 	}
+	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_2) {
+		if (value)
+			dev->features |= NETIF_F_TSO6;
+		else
+			dev->features &= ~NETIF_F_TSO6;
+	}
 	return ethtool_op_set_tso(dev, value);
 }
 #endif
@@ -11508,8 +11520,11 @@ static int __devinit tg3_init_one(struct
 	 * Firmware TSO on older chips gives lower performance, so it
 	 * is off by default, but can be enabled using ethtool.
 	 */
-	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO)
+	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
 		dev->features |= NETIF_F_TSO;
+		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_2)
+			dev->features |= NETIF_F_TSO6;
+	}
 
 #endif
 


