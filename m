From: Tobias Jungel <tobias.jungel@bisdn.de>
Subject: [PATCH v2] bridge: netlink: check vlan_default_pvid range
Date: Mon, 15 May 2017 15:23:40 +0200
Message-ID: <20170515132340.27230-1-tobias.jungel@bisdn.de>
To: Sabrina Dubroca <sd@queasysnail.net>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.bisdn.de ([185.27.182.31]:44991 "EHLO mx.bisdn.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933799AbdEONXz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 09:23:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently it is allowed to set the default pvid of a bridge to a value
above VLAN_VID_MASK (0xfff). This patch checks the passed pvid and
returns an returns -EINVAL in case the pvid is out of bounds.

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

Fixes: 0f963b7592ef ("bridge: netlink: add support for default_pvid")
Signed-off-by: Tobias Jungel <tobias.jungel@bisdn.de>
---
 net/bridge/br_vlan.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index b838213..95a565e 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -825,6 +825,9 @@ int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 		return 0;
 	}
 
+	if (pvid >= VLAN_VID_MASK)
+		return -EINVAL;
+
 	changed = kcalloc(BITS_TO_LONGS(BR_MAX_PORTS), sizeof(unsigned long),
 			  GFP_KERNEL);
 	if (!changed)
-- 
2.9.4
