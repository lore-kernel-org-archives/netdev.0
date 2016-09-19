From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH v2 1/2] net: skbuff: Remove errornous length validation in skb_vlan_pop()
Date: Mon, 19 Sep 2016 18:53:19 +0300
Message-ID: <1474300400-32362-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Jiri Pirko <jiri@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Pravin Shelar <pshelar@ovn.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36789 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbcISPxp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 11:53:45 -0400
Received: by mail-wm0-f65.google.com with SMTP id b184so15724989wma.3
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 08:53:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In 93515d53b1
  "net: move vlan pop/push functions into common code"
skb_vlan_pop was moved from its private location in openvswitch to
skbuff common code.

In case !vlan_tx_tag_present, the original 'pop_vlan()' assured
that skb->len is sufficient (if skb->len < VLAN_ETH_HLEN then pop was a
no-op).

This validation was moved as is into the new common 'skb_vlan_pop'.

Alas, in its original location (openvswitch), there was a guarantee that
'data' points to the mac_header, therefore the 'skb->len < VLAN_ETH_HLEN'
condition made sense.
However there's no such guarantee in the generic 'skb_vlan_pop'.

For short packets received in rx path going through 'skb_vlan_pop',
this causes 'skb_vlan_pop' to fail pop-ing a valid vlan hdr (in the non
hw-accel case) or to fail moving next tag into hw-accel tag.

Remove the 'skb->len < VLAN_ETH_HLEN' condition entirely:
It is superfluous since inner '__skb_vlan_pop' already verifies there
are VLAN_ETH_HLEN writable bytes at the mac_header.

Fixes: 93515d53b1 ("net: move vlan pop/push functions into common code")
Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Cc: Pravin Shelar <pshelar@ovn.org>
---
 net/core/skbuff.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 1e329d4112..4dbaedb745 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4535,9 +4535,8 @@ int skb_vlan_pop(struct sk_buff *skb)
 	if (likely(skb_vlan_tag_present(skb))) {
 		skb->vlan_tci = 0;
 	} else {
-		if (unlikely((skb->protocol != htons(ETH_P_8021Q) &&
-			      skb->protocol != htons(ETH_P_8021AD)) ||
-			     skb->len < VLAN_ETH_HLEN))
+		if (unlikely(skb->protocol != htons(ETH_P_8021Q) &&
+			     skb->protocol != htons(ETH_P_8021AD)))
 			return 0;
 
 		err = __skb_vlan_pop(skb, &vlan_tci);
@@ -4545,9 +4544,8 @@ int skb_vlan_pop(struct sk_buff *skb)
 			return err;
 	}
 	/* move next vlan tag to hw accel tag */
-	if (likely((skb->protocol != htons(ETH_P_8021Q) &&
-		    skb->protocol != htons(ETH_P_8021AD)) ||
-		   skb->len < VLAN_ETH_HLEN))
+	if (likely(skb->protocol != htons(ETH_P_8021Q) &&
+		   skb->protocol != htons(ETH_P_8021AD)))
 		return 0;
 
 	vlan_proto = skb->protocol;
-- 
2.7.4
