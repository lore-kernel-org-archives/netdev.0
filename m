From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 3/9] vlan: kill vlan_put_tag helper
Date: Tue, 18 Nov 2014 22:37:38 +0100
Message-ID: <1416346664-9290-4-git-send-email-jiri@resnulli.us>
References: <1416346664-9290-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, pshelar@nicira.com,
	therbert@google.com, edumazet@google.com, willemb@google.com,
	dborkman@redhat.com, mst@redhat.com, fw@strlen.de,
	Paul.Durrant@citrix.com, tgraf@suug.ch, cwang@twopensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:54915 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754874AbaKRVhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 16:37:50 -0500
Received: by mail-wi0-f174.google.com with SMTP id h11so3378336wiw.13
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 13:37:49 -0800 (PST)
In-Reply-To: <1416346664-9290-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since both tx and rx paths work with skb->vlan_tci, there's no need for
this function anymore. Switch users directly to __vlan_hwaccel_put_tag.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_alb.c  | 17 ++++-------------
 drivers/net/bonding/bond_main.c |  8 ++------
 drivers/net/usb/cdc_mbim.c      |  2 +-
 include/linux/if_vlan.h         | 19 -------------------
 4 files changed, 7 insertions(+), 39 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index e1f1a00..bb9e9fc 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -475,12 +475,8 @@ static void rlb_update_client(struct rlb_client_info *client_info)
 		skb->dev = client_info->slave->dev;
 
 		if (client_info->vlan_id) {
-			skb = vlan_put_tag(skb, htons(ETH_P_8021Q), client_info->vlan_id);
-			if (!skb) {
-				netdev_err(client_info->slave->bond->dev,
-					   "failed to insert VLAN tag\n");
-				continue;
-			}
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+					       client_info->vlan_id);
 		}
 
 		arp_xmit(skb);
@@ -951,13 +947,8 @@ static void alb_send_lp_vid(struct slave *slave, u8 mac_addr[],
 	skb->priority = TC_PRIO_CONTROL;
 	skb->dev = slave->dev;
 
-	if (vid) {
-		skb = vlan_put_tag(skb, vlan_proto, vid);
-		if (!skb) {
-			netdev_err(slave->bond->dev, "failed to insert VLAN tag\n");
-			return;
-		}
-	}
+	if (vid)
+		__vlan_hwaccel_put_tag(skb, vlan_proto, vid);
 
 	dev_queue_xmit(skb);
 }
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8575fee..e26c682 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2159,12 +2159,8 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op,
 	if (outer_tag->vlan_id) {
 		netdev_dbg(slave_dev, "outer tag: proto %X vid %X\n",
 			   ntohs(outer_tag->vlan_proto), outer_tag->vlan_id);
-		skb = vlan_put_tag(skb, outer_tag->vlan_proto,
-				   outer_tag->vlan_id);
-		if (!skb) {
-			net_err_ratelimited("failed to insert outer VLAN tag\n");
-			return;
-		}
+		__vlan_hwaccel_put_tag(skb, outer_tag->vlan_proto,
+				       outer_tag->vlan_id);
 	}
 
 xmit:
diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 5ee7a1d..96fc8a5 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -402,7 +402,7 @@ static struct sk_buff *cdc_mbim_process_dgram(struct usbnet *dev, u8 *buf, size_
 
 	/* map MBIM session to VLAN */
 	if (tci)
-		vlan_put_tag(skb, htons(ETH_P_8021Q), tci);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), tci);
 err:
 	return skb;
 }
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 1b5dbc2..75b70a5 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -355,25 +355,6 @@ static inline void __vlan_hwaccel_put_tag(struct sk_buff *skb,
 }
 
 /**
- * vlan_put_tag - inserts VLAN tag according to device features
- * @skb: skbuff to tag
- * @vlan_tci: VLAN TCI to insert
- *
- * Assumes skb->dev is the target that will xmit this frame.
- * Returns a VLAN tagged skb.
- */
-static inline struct sk_buff *vlan_put_tag(struct sk_buff *skb,
-					   __be16 vlan_proto, u16 vlan_tci)
-{
-	if (vlan_hw_offload_capable(skb->dev->features, vlan_proto)) {
-		__vlan_hwaccel_put_tag(skb, vlan_proto, vlan_tci);
-		return skb;
-	} else {
-		return __vlan_put_tag(skb, vlan_proto, vlan_tci);
-	}
-}
-
-/**
  * __vlan_get_tag - get the VLAN ID that is part of the payload
  * @skb: skbuff to query
  * @vlan_tci: buffer to store vlaue
-- 
1.9.3
