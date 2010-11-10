From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-2.6 1/3] vlan: Add function to retrieve EtherType from vlan packets.
Date: Tue,  9 Nov 2010 17:09:02 -0800
Message-ID: <1289351344-14340-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, Hao Zheng <hzheng@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:58037 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315Ab0KJBJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 20:09:10 -0500
Received: by vws13 with SMTP id 13so6183vws.19
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 17:09:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hao Zheng <hzheng@nicira.com>

Depending on how a packet is vlan tagged (i.e. hardware accelerated or
not), the encapsulated protocol is stored in different locations.  This
provides a consistent method of accessing that protocol, which is needed
by drivers, security checks, etc.

Signed-off-by: Hao Zheng <hzheng@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/linux/if_vlan.h |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index c2f3a72..ee06c52 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -339,6 +339,26 @@ static inline int vlan_get_tag(const struct sk_buff *skb, u16 *vlan_tci)
 	}
 }
 
+/**
+ * vlan_get_protocol - get protocol EtherType.
+ * @skb: skbuff to query
+ *
+ * Returns the EtherType of the packet, regardless of whether it is
+ * vlan encapsulated (normal or hardware accelerated) or not.
+ */
+static inline __be16 vlan_get_protocol(struct sk_buff *skb)
+{
+	__be16 protocol = 0;
+
+	if (vlan_tx_tag_present(skb) ||
+	     skb->protocol != cpu_to_be16(ETH_P_8021Q))
+		protocol = skb->protocol;
+	else if (likely(pskb_may_pull(skb, VLAN_ETH_HLEN)))
+		protocol = ((const struct vlan_ethhdr *)skb->data)->
+			   h_vlan_encapsulated_proto;
+
+	return protocol;
+}
 #endif /* __KERNEL__ */
 
 /* VLAN IOCTLs are found in sockios.h */
-- 
1.7.1

