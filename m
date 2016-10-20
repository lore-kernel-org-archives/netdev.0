From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH net-next] net/sched: em_meta: Fix 'meta vlan' to correctly recognize zero VID frames
Date: Fri, 21 Oct 2016 00:18:08 +0300
Message-ID: <1476998288-13341-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@resnulli.us>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:36854 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754626AbcJTVSX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 17:18:23 -0400
Received: by mail-lf0-f68.google.com with SMTP id b75so2435975lfg.3
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 14:18:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

META_COLLECTOR int_vlan_tag() assumes that if the accel tag (vlan_tci)
is zero, then no vlan accel tag is present.

This is incorrect for zero VID vlan accel packets, making the following
match fail:
  tc filter add ... basic match 'meta(vlan mask 0xfff eq 0)' ...

Apparently 'int_vlan_tag' was implemented prior VLAN_TAG_PRESENT was
introduced in 05423b2 "vlan: allow null VLAN ID to be used"
(and at time introduced, the 'vlan_tx_tag_get' call in em_meta was not
 adapted).

Fix, testing skb_vlan_tag_present instead of testing skb_vlan_tag_get's
value.

Fixes: 05423b2413 ("vlan: allow null VLAN ID to be used")
Fixes: 1a31f2042e ("netsched: Allow meta match on vlan tag on receive")

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
---
 net/sched/em_meta.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index a309a07ccb..41c80b6c39 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -176,11 +176,12 @@ META_COLLECTOR(int_vlan_tag)
 {
 	unsigned short tag;
 
-	tag = skb_vlan_tag_get(skb);
-	if (!tag && __vlan_get_tag(skb, &tag))
-		*err = -1;
-	else
+	if (skb_vlan_tag_present(skb))
+		dst->value = skb_vlan_tag_get(skb);
+	else if (!__vlan_get_tag(skb, &tag))
 		dst->value = tag;
+	else
+		*err = -1;
 }
 
 
-- 
2.7.4
