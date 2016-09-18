From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH] net: skbuff: Fix length validation in skb_vlan_pop()
Date: Sun, 18 Sep 2016 13:09:18 +0300
Message-ID: <1474193358-20133-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: netdev@vger.kernel.org, Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33507 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755670AbcIRKJi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 06:09:38 -0400
Received: by mail-wm0-f68.google.com with SMTP id w84so3202272wmg.0
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 03:09:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In 93515d53b1
  "net: move vlan pop/push functions into common code"
skb_vlan_pop was moved from its private location in openvswitch to
skbuff common code.

In case !vlan_tx_tag_present, the original 'pop_vlan()' assured
that skb->len is sufficient for the existence of a vlan_ethhdr
(if skb->len < VLAN_ETH_HLEN then pop was a no-op).

This validation was moved as is into the new common 'skb_vlan_pop'.

Alas, in its original location (openvswitch), there's a guarantee that
'data' points to the mac_header, therefore the 'skb->len < VLAN_ETH_HLEN'
condition made sense.
However there's no such guarantee in the generic 'skb_vlan_pop'.

For short packets received in rx path going through 'skb_vlan_pop',
this causes 'skb_vlan_pop' to fail pop-ing a valid vlan hdr (in case tag
is in payload), or to fail moving next tag into hw-accel tag.

Instead, verify that 'skb->mac_len' is sufficient.

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 Spotted by code review while doing work augmenting tc act vlan.

 net/core/skbuff.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 1e329d4112..cc2c004838 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4537,7 +4537,7 @@ int skb_vlan_pop(struct sk_buff *skb)
 	} else {
 		if (unlikely((skb->protocol != htons(ETH_P_8021Q) &&
 			      skb->protocol != htons(ETH_P_8021AD)) ||
-			     skb->len < VLAN_ETH_HLEN))
+			     skb->mac_len < VLAN_ETH_HLEN))
 			return 0;
 
 		err = __skb_vlan_pop(skb, &vlan_tci);
@@ -4547,7 +4547,7 @@ int skb_vlan_pop(struct sk_buff *skb)
 	/* move next vlan tag to hw accel tag */
 	if (likely((skb->protocol != htons(ETH_P_8021Q) &&
 		    skb->protocol != htons(ETH_P_8021AD)) ||
-		   skb->len < VLAN_ETH_HLEN))
+		   skb->mac_len < VLAN_ETH_HLEN))
 		return 0;
 
 	vlan_proto = skb->protocol;
-- 
2.7.4
