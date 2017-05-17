From: Tobias Jungel <tobias.jungel@bisdn.de>
Subject: [PATCH v4] bridge: netlink: check vlan_default_pvid range
Date: Wed, 17 May 2017 09:29:12 +0200
Message-ID: <20170517072912.13063-1-tobias.jungel@bisdn.de>
To: Sabrina Dubroca <sd@queasysnail.net>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.bisdn.de ([185.27.182.31]:47492 "EHLO mx.bisdn.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753172AbdEQH3k (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 03:29:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently it is allowed to set the default pvid of a bridge to a value
above VLAN_VID_MASK (0xfff). This patch adds a check to br_validate and
returns -EINVAL in case the pvid is out of bounds.

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
Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Tobias Jungel <tobias.jungel@bisdn.de>
---
 net/bridge/br_netlink.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index c5ce774..574f788 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -835,6 +835,13 @@ static int br_validate(struct nlattr *tb[], struct nlattr *data[])
 			return -EPROTONOSUPPORT;
 		}
 	}
+
+	if (data[IFLA_BR_VLAN_DEFAULT_PVID]) {
+		__u16 defpvid = nla_get_u16(data[IFLA_BR_VLAN_DEFAULT_PVID]);
+
+		if (defpvid >= VLAN_VID_MASK)
+			return -EINVAL;
+	}
 #endif
 
 	return 0;
-- 
2.9.4
