From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: [PATCH v3 net-next 1/2] net: skbuff: Remove errornous length validation in skb_vlan_pop()
Date: Tue, 20 Sep 2016 12:48:36 +0300
Message-ID: <1474364917-31710-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Jiri Pirko <jiri@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Pravin Shelar <pshelar@ovn.org>,
        Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36429 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932655AbcITJtJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 05:49:09 -0400
Received: by mail-wm0-f47.google.com with SMTP id w84so123306188wmg.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 02:49:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In 93515d53b1
  "net: move vlan pop/push functions into common code"
skb_vlan_pop was moved from its private location in openvswitch to
skbuff common code.

In case skb has non hw-accel vlan tag, the original 'pop_vlan()' assured
that skb->len is sufficient (if skb->len < VLAN_ETH_HLEN then pop was
considered a no-op).

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

Note this presents a slight change to skb_vlan_pop() users:
In case total length is smaller than VLAN_ETH_HLEN, skb_vlan_pop() now
returns an error, as opposed to previous "no-op" behavior.
Existing callers (e.g. tc act vlan, ovs) usually drop the packet if
'skb_vlan_pop' fails.

Fixes: 93515d53b1 ("net: move vlan pop/push functions into common code")
Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Cc: Pravin Shelar <pshelar@ovn.org>
---
 v3: Elaborate log message to explain the change presented to
     'skb_vlan_pop' users for packets smaller than VLAN_ETH_HLEN

 v2: Remove 'skb->len < VLAN_ETH_HLEN' condition entirely (instead of
     testing skb->mac_len as was in v1), suggested by Pravin Shelar
 
 net/core/skbuff.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7bf82a2..93d6c5c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4564,9 +4564,8 @@ int skb_vlan_pop(struct sk_buff *skb)
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
@@ -4574,9 +4573,8 @@ int skb_vlan_pop(struct sk_buff *skb)
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
1.9.1
