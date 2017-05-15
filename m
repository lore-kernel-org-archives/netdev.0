From: Tobias Jungel <tobias.jungel@bisdn.de>
Subject: [PATCH] bridge: netlink: check vlan_default_pvid range
Date: Mon, 15 May 2017 13:08:19 +0200
Message-ID: <20170515110819.11847-1-tobias.jungel@bisdn.de>
To: Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.bisdn.de ([185.27.182.31]:44873 "EHLO mx.bisdn.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752677AbdEOLQL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 07:16:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently it is allowed to set the default pvid of a bridge to a value
above VLAN_VID_MASK (0xfff). This patch checks the passed pvid and
disables the pvid in case it is out of bounds.

Reproduce by calling:

[root@test ~]# ip l a type bridge
[root@test ~]# ip l a type dummy
[root@test ~]# ip l s bridge0 type bridge vlan_filtering 1
[root@test ~]# ip l s bridge0 type bridge vlan_default_pvid 9999
[root@test ~]# ip l s dummy0 master bridge0
[root@test ~]# bridge vlan
port	vlan ids
bridge0	 9999 PVID Egress Untagged

dummy0	 9999 PVID Egress Untagged
---
 net/bridge/br_vlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index b838213..e363d75 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -820,7 +820,7 @@ int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 	int err = 0;
 	unsigned long *changed;
 
-	if (!pvid) {
+	if (!pvid || pvid >= VLAN_VID_MASK) {
 		br_vlan_disable_default_pvid(br);
 		return 0;
 	}
-- 
2.9.4
