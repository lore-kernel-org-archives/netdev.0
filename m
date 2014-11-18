From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 2/9] vlan: make __vlan_hwaccel_put_tag return void
Date: Tue, 18 Nov 2014 22:37:37 +0100
Message-ID: <1416346664-9290-3-git-send-email-jiri@resnulli.us>
References: <1416346664-9290-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, pshelar@nicira.com,
	therbert@google.com, edumazet@google.com, willemb@google.com,
	dborkman@redhat.com, mst@redhat.com, fw@strlen.de,
	Paul.Durrant@citrix.com, tgraf@suug.ch, cwang@twopensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:44855 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754178AbaKRVht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 16:37:49 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so7755133wiv.14
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 13:37:48 -0800 (PST)
In-Reply-To: <1416346664-9290-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Always returns the same skb it gets, so change to void.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/scsi/fcoe/fcoe.c | 6 ++----
 include/linux/if_vlan.h  | 9 ++++-----
 net/8021q/vlan_dev.c     | 2 +-
 3 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 4a8ac7d..73a8cc4 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -1669,10 +1669,8 @@ static int fcoe_xmit(struct fc_lport *lport, struct fc_frame *fp)
 	    fcoe->realdev->features & NETIF_F_HW_VLAN_CTAG_TX) {
 		/* must set skb->dev before calling vlan_put_tag */
 		skb->dev = fcoe->realdev;
-		skb = __vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
-					     vlan_dev_vlan_id(fcoe->netdev));
-		if (!skb)
-			return -ENOMEM;
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+				       vlan_dev_vlan_id(fcoe->netdev));
 	} else
 		skb->dev = fcoe->netdev;
 
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index d69f057..1b5dbc2 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -347,13 +347,11 @@ static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb,
  *
  * Puts the VLAN TCI in @skb->vlan_tci and lets the device do the rest
  */
-static inline struct sk_buff *__vlan_hwaccel_put_tag(struct sk_buff *skb,
-						     __be16 vlan_proto,
-						     u16 vlan_tci)
+static inline void __vlan_hwaccel_put_tag(struct sk_buff *skb,
+					  __be16 vlan_proto, u16 vlan_tci)
 {
 	skb->vlan_proto = vlan_proto;
 	skb->vlan_tci = VLAN_TAG_PRESENT | vlan_tci;
-	return skb;
 }
 
 /**
@@ -368,7 +366,8 @@ static inline struct sk_buff *vlan_put_tag(struct sk_buff *skb,
 					   __be16 vlan_proto, u16 vlan_tci)
 {
 	if (vlan_hw_offload_capable(skb->dev->features, vlan_proto)) {
-		return __vlan_hwaccel_put_tag(skb, vlan_proto, vlan_tci);
+		__vlan_hwaccel_put_tag(skb, vlan_proto, vlan_tci);
+		return skb;
 	} else {
 		return __vlan_put_tag(skb, vlan_proto, vlan_tci);
 	}
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 0d441ec..d6524b2 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -150,7 +150,7 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 		u16 vlan_tci;
 		vlan_tci = vlan->vlan_id;
 		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb->priority);
-		skb = __vlan_hwaccel_put_tag(skb, vlan->vlan_proto, vlan_tci);
+		__vlan_hwaccel_put_tag(skb, vlan->vlan_proto, vlan_tci);
 	}
 
 	skb->dev = vlan->real_dev;
-- 
1.9.3
