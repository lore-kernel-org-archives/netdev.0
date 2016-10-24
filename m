From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v3 net] flow_dissector: fix vlan tag handling
Date: Mon, 24 Oct 2016 23:40:30 +0200
Message-ID: <20161024214058.1896091-1-arnd@arndb.de>
Cc: Eric Garver <e@erig.me>, Hadar Hen Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, Arnd Bergmann <arnd@arndb.de>,
        Alexander Duyck <aduyck@mirantis.com>,
        Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:57447 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756713AbcJXVlN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 17:41:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gcc warns about an uninitialized pointer dereference in the vlan
priority handling:

net/core/flow_dissector.c: In function '__skb_flow_dissect':
net/core/flow_dissector.c:281:61: error: 'vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]

As pointed out by Jiri Pirko, the variable is never actually used
without being initialized first as the only way it end up uninitialized
is with skb_vlan_tag_present(skb)==true, and that means it does not
get accessed.

However, the warning hints at some related issues that I'm addressing
here:

- the second check for the vlan tag is different from the first one
  that tests the skb for being NULL first, causing both the warning
  and a possible NULL pointer dereference that was not entirely fixed.
- The same patch that introduced the NULL pointer check dropped an
  earlier optimization that skipped the repeated check of the
  protocol type
- The local '_vlan' variable is referenced through the 'vlan' pointer
  but the variable has gone out of scope by the time that it is
  accessed, causing undefined behavior

Caching the result of the 'skb && skb_vlan_tag_present(skb)' check
in a local variable allows the compiler to further optimize the
later check. With those changes, the warning also disappears.

Fixes: 3805a938a6c2 ("flow_dissector: Check skb for VLAN only if skb specified.")
Fixes: d5709f7ab776 ("flow_dissector: For stripped vlan, get vlan info from skb->vlan_tci")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
v3: set 'proto' variable correct again
    mark it for net, rather than net-next, as both patches that
      introduced the bugs are in mainline or in net/master

v2: fix multiple issues found in the initial review beyond the
    uninitialized access that turned out to be ok

 net/core/flow_dissector.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 44e6ba9d3a6b..ab193e5def07 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -246,13 +246,13 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	case htons(ETH_P_8021AD):
 	case htons(ETH_P_8021Q): {
 		const struct vlan_hdr *vlan;
+		struct vlan_hdr _vlan;
+		bool vlan_tag_present = skb && skb_vlan_tag_present(skb);
 
-		if (skb && skb_vlan_tag_present(skb))
+		if (vlan_tag_present)
 			proto = skb->protocol;
 
-		if (eth_type_vlan(proto)) {
-			struct vlan_hdr _vlan;
-
+		if (!vlan_tag_present || eth_type_vlan(skb->protocol)) {
 			vlan = __skb_header_pointer(skb, nhoff, sizeof(_vlan),
 						    data, hlen, &_vlan);
 			if (!vlan)
@@ -270,7 +270,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 							     FLOW_DISSECTOR_KEY_VLAN,
 							     target_container);
 
-			if (skb_vlan_tag_present(skb)) {
+			if (vlan_tag_present) {
 				key_vlan->vlan_id = skb_vlan_tag_get_id(skb);
 				key_vlan->vlan_priority =
 					(skb_vlan_tag_get_prio(skb) >> VLAN_PRIO_SHIFT);
-- 
2.9.0
