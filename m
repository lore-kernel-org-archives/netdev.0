From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 07/12] vxlan: make vxlan_xmit_one void
Date: Mon, 10 Jun 2013 13:24:46 -0700
Message-ID: <20130610132446.0783e4fb@nehalam.linuxnetplumber.net>
References: <20130610200524.721617349@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	David L Stevens <dlstevens@us.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:40475 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599Ab3FJUZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 16:25:52 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so7691026pbb.36
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 13:25:52 -0700 (PDT)
In-Reply-To: <20130610200524.721617349@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function vxlan_xmit_one always returns NETDEV_TX_OK, so there
is no point in keeping track of return values etc.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Acked-by: David L Stevens <dlstevens@us.ibm.com>

--- a/drivers/net/vxlan.c	2013-06-10 12:20:00.590079878 -0700
+++ b/drivers/net/vxlan.c	2013-06-10 12:20:01.314071646 -0700
@@ -1008,8 +1008,8 @@ static void vxlan_encap_bypass(struct sk
 	}
 }
 
-static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
-				  struct vxlan_rdst *rdst, bool did_rsc)
+static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
+			   struct vxlan_rdst *rdst, bool did_rsc)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct rtable *rt;
@@ -1032,7 +1032,7 @@ static netdev_tx_t vxlan_xmit_one(struct
 		if (did_rsc) {
 			/* short-circuited back to local bridge */
 			vxlan_encap_bypass(skb, vxlan, vxlan);
-			return NETDEV_TX_OK;
+			return;
 		}
 		goto drop;
 	}
@@ -1088,7 +1088,7 @@ static netdev_tx_t vxlan_xmit_one(struct
 		if (!dst_vxlan)
 			goto tx_error;
 		vxlan_encap_bypass(skb, vxlan, dst_vxlan);
-		return NETDEV_TX_OK;
+		return;
 	}
 
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
@@ -1132,7 +1132,7 @@ static netdev_tx_t vxlan_xmit_one(struct
 		goto drop;
 
 	iptunnel_xmit(skb, dev);
-	return NETDEV_TX_OK;
+	return;
 
 drop:
 	dev->stats.tx_dropped++;
@@ -1142,7 +1142,6 @@ tx_error:
 	dev->stats.tx_errors++;
 tx_free:
 	dev_kfree_skb(skb);
-	return NETDEV_TX_OK;
 }
 
 /* Transmit local packets over Vxlan
@@ -1158,7 +1157,6 @@ static netdev_tx_t vxlan_xmit(struct sk_
 	bool did_rsc = false;
 	struct vxlan_rdst *rdst0, *rdst;
 	struct vxlan_fdb *f;
-	int rc1, rc;
 
 	skb_reset_mac_header(skb);
 	eth = eth_hdr(skb);
@@ -1186,24 +1184,18 @@ static netdev_tx_t vxlan_xmit(struct sk_
 	} else
 		rdst0 = &f->remote;
 
-	rc = NETDEV_TX_OK;
 
 	/* if there are multiple destinations, send copies */
 	for (rdst = rdst0->remote_next; rdst; rdst = rdst->remote_next) {
 		struct sk_buff *skb1;
 
 		skb1 = skb_clone(skb, GFP_ATOMIC);
-		if (skb1) {
-			rc1 = vxlan_xmit_one(skb1, dev, rdst, did_rsc);
-			if (rc == NETDEV_TX_OK)
-				rc = rc1;
-		}
+		if (skb1)
+			vxlan_xmit_one(skb1, dev, rdst, did_rsc);
 	}
 
-	rc1 = vxlan_xmit_one(skb, dev, rdst0, did_rsc);
-	if (rc == NETDEV_TX_OK)
-		rc = rc1;
-	return rc;
+	vxlan_xmit_one(skb, dev, rdst0, did_rsc);
+	return NETDEV_TX_OK;
 }
 
 /* Walk the forwarding table and purge stale entries */
