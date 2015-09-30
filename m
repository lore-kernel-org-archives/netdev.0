From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 2/5] bridge: vlan: fix possible null vlgrp deref while registering new port
Date: Wed, 30 Sep 2015 20:16:52 +0200
Message-ID: <1443637015-4153-3-git-send-email-razor@blackwall.org>
References: <1443637015-4153-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, vyasevich@gmail.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:37657 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933103AbbI3SRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 14:17:03 -0400
Received: by wicfx3 with SMTP id fx3so74253369wic.0
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 11:17:01 -0700 (PDT)
In-Reply-To: <1443637015-4153-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

While a new port is being initialized the rx_handler gets set, but the
vlans get initialized later in br_add_if() and in that window if we
receive a frame with a link-local address we can try to dereference
p->vlgrp in:
br_handle_frame() -> br_handle_local_finish() -> br_should_learn()

Fix this by checking vlgrp before using it.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_vlan.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 283d012c3d89..678d5c41b551 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -476,13 +476,15 @@ bool br_allowed_egress(struct net_bridge_vlan_group *vg,
 /* Called under RCU */
 bool br_should_learn(struct net_bridge_port *p, struct sk_buff *skb, u16 *vid)
 {
+	struct net_bridge_vlan_group *vg;
 	struct net_bridge *br = p->br;
 
 	/* If filtering was disabled at input, let it pass. */
 	if (!br->vlan_enabled)
 		return true;
 
-	if (!p->vlgrp->num_vlans)
+	vg = p->vlgrp;
+	if (!vg || !vg->num_vlans)
 		return false;
 
 	if (!br_vlan_get_tag(skb, vid) && skb->vlan_proto != br->vlan_proto)
-- 
2.4.3
