From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 2/2] vlan: adjust vlan_set_encap_proto() for its callers
Date: Fri, 22 Feb 2013 17:32:27 +0800
Message-ID: <1361525547-21808-2-git-send-email-amwang@redhat.com>
References: <1361525547-21808-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40074 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756489Ab3BVJc5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2013 04:32:57 -0500
In-Reply-To: <1361525547-21808-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

There are two places to call vlan_set_encap_proto():
vlan_untag() and __pop_vlan_tci().

vlan_untag() assumes skb->data points after mac addr, otherwise
the following code

        vhdr = (struct vlan_hdr *) skb->data;
        vlan_tci = ntohs(vhdr->h_vlan_TCI);
        __vlan_hwaccel_put_tag(skb, vlan_tci);

        skb_pull_rcsum(skb, VLAN_HLEN);

won't be correct. But __pop_vlan_tci() assumes points _before_
mac addr.

In vlan_set_encap_proto(), it looks for some magic L2 value
after mac addr:

        rawp = skb->data;
        if (*(unsigned short *) rawp == 0xFFFF)
	...

Therefore __pop_vlan_tci() is obviously wrong.

A quick fix is avoiding using skb->data in vlan_set_encap_proto(),
use 'vhdr+1' is always correct in both cases.

Cc: David S. Miller <davem@davemloft.net>
Cc: Jesse Gross <jesse@nicira.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/linux/if_vlan.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index d06cc5c..218a3b6 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -331,7 +331,7 @@ static inline void vlan_set_encap_proto(struct sk_buff *skb,
 					struct vlan_hdr *vhdr)
 {
 	__be16 proto;
-	unsigned char *rawp;
+	unsigned short *rawp;
 
 	/*
 	 * Was a VLAN packet, grab the encapsulated protocol, which the layer
@@ -344,8 +344,8 @@ static inline void vlan_set_encap_proto(struct sk_buff *skb,
 		return;
 	}
 
-	rawp = skb->data;
-	if (*(unsigned short *) rawp == 0xFFFF)
+	rawp = (unsigned short *)(vhdr + 1);
+	if (*rawp == 0xFFFF)
 		/*
 		 * This is a magic hack to spot IPX packets. Older Novell
 		 * breaks the protocol design and runs IPX over 802.3 without
-- 
1.7.7.6
