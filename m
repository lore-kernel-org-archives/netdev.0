From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-2.6 v2 1/3] vlan: Add function to retrieve EtherType from vlan packets.
Date: Thu, 11 Nov 2010 15:47:57 -0800
Message-ID: <1289519279-20641-1-git-send-email-jesse@nicira.com>
Cc: netdev <netdev@vger.kernel.org>, Hao Zheng <hzheng@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:49442 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518Ab0KKXsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 18:48:08 -0500
Received: by vws13 with SMTP id 13so732754vws.19
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 15:48:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hao Zheng <hzheng@nicira.com>

Depending on how a packet is vlan tagged (i.e. hardware accelerated or
not), the encapsulated protocol is stored in different locations.  This
provides a consistent method of accessing that protocol, which is needed
by drivers, security checks, etc.

Signed-off-by: Hao Zheng <hzheng@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
--
Changes from v1:
* Use skb_header_pointer() instead of pskb_may_pull() when retrieving
possibly paged data inside the vlan header to avoid invalidating the
pointers of callers.
---
 include/linux/if_vlan.h |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index c2f3a72..635e1fa 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -339,6 +339,31 @@ static inline int vlan_get_tag(const struct sk_buff *skb, u16 *vlan_tci)
 	}
 }
 
+/**
+ * vlan_get_protocol - get protocol EtherType.
+ * @skb: skbuff to query
+ *
+ * Returns the EtherType of the packet, regardless of whether it is
+ * vlan encapsulated (normal or hardware accelerated) or not.
+ */
+static inline __be16 vlan_get_protocol(const struct sk_buff *skb)
+{
+	__be16 protocol = 0;
+
+	if (vlan_tx_tag_present(skb) ||
+	     skb->protocol != cpu_to_be16(ETH_P_8021Q))
+		protocol = skb->protocol;
+	else {
+		__be16 proto, *protop;
+		protop = skb_header_pointer(skb, offsetof(struct vlan_ethhdr,
+						h_vlan_encapsulated_proto),
+						sizeof(proto), &proto);
+		if (likely(protop))
+			protocol = *protop;
+	}
+
+	return protocol;
+}
 #endif /* __KERNEL__ */
 
 /* VLAN IOCTLs are found in sockios.h */
-- 
1.7.1

