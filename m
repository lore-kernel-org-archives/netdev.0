From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 1/2] vlan: Fix untag operations of stacked vlans with REORDER_HEADER off
Date: Mon, 16 Nov 2015 15:43:44 -0500
Message-ID: <1447706625-25979-2-git-send-email-vyasevic@redhat.com>
References: <1447706625-25979-1-git-send-email-vyasevic@redhat.com>
Cc: phil@nwl.cc, kaber@trash.net,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:32876 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbbKPUnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 15:43:55 -0500
Received: by qgea14 with SMTP id a14so58328869qge.0
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 12:43:54 -0800 (PST)
In-Reply-To: <1447706625-25979-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we have multiple stacked vlan devices all of which have
turned off REORDER_HEADER flag, the untag operation does not
locate the ethernet addresses correctly for nested vlans.
The reason is that in case of REORDER_HEADER flag being off,
the outer vlan headers are put back and the mac_len is adjusted
to account for the presense of the header.  Then, the subsequent
untag operation, for the next level vlan, always use VLAN_ETH_HLEN
to locate the begining of the ethernet header and that ends up
being a multiple of 4 bytes short of the actuall beginning
of the mac header (the multiple depending on the how many vlan
encapsulations ethere are).

As a reslult, if there are multiple levles of vlan devices
with REODER_HEADER being off, the recevied packets end up
being dropped.

To solve this, we use skb->mac_len as the offset.  The value
is always set on receive path and starts out as a ETH_HLEN.
The value is also updated when the vlan header manupations occur
so we know it will be correct.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/core/skbuff.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index fab4599..160193f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4268,7 +4268,8 @@ static struct sk_buff *skb_reorder_vlan_header(struct sk_buff *skb)
 		return NULL;
 	}
 
-	memmove(skb->data - ETH_HLEN, skb->data - VLAN_ETH_HLEN, 2 * ETH_ALEN);
+	memmove(skb->data - ETH_HLEN, skb->data - skb->mac_len,
+		2 * ETH_ALEN);
 	skb->mac_header += VLAN_HLEN;
 	return skb;
 }
-- 
1.9.3
