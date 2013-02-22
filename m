From: Cong Wang <amwang@redhat.com>
Subject: [Patch] openvswitch: fix the calculation of checksum for vlan header
Date: Fri, 22 Feb 2013 13:25:22 +0800
Message-ID: <1361510722-27831-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47040 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750790Ab3BVFZs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2013 00:25:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

In vlan_insert_tag(), we insert a 4-byte VLAN header _after_
mac header:

        memmove(skb->data, skb->data + VLAN_HLEN, 2 * ETH_ALEN);
	...
        veth->h_vlan_proto = htons(ETH_P_8021Q);
	...
        veth->h_vlan_TCI = htons(vlan_tci);

so after it, we should recompute the checksum to include these 4 bytes.
skb->data still points to the mac header, therefore VLAN header is at
(2 * ETH_ALEN = 12) bytes after it, not (ETH_HLEN = 14) bytes.

This can also be observed via tcpdump:

         0x0000:  ffff ffff ffff 5254 005d 6f6e 8100 000a
         0x0010:  0806 0001 0800 0604 0001 5254 005d 6f6e
         0x0020:  c0a8 026e 0000 0000 0000 c0a8 0282

Cc: David S. Miller <davem@davemloft.net>
Cc: Jesse Gross <jesse@nicira.com>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index ac2defe..a0e202c 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -115,7 +115,7 @@ static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vla
 
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
 			skb->csum = csum_add(skb->csum, csum_partial(skb->data
-					+ ETH_HLEN, VLAN_HLEN, 0));
+					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
 
 	}
 	__vlan_hwaccel_put_tag(skb, ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
