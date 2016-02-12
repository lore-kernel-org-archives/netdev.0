From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH RFC 2/3] net: bridge: set forwarding state on port removal
Date: Fri, 12 Feb 2016 16:34:19 -0500
Message-ID: <1455312860-24666-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1455312860-24666-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48897 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbcBLVfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 16:35:02 -0500
In-Reply-To: <1455312860-24666-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a port leaves a bridge, the bridge layer puts its STP state to
Disabled. If the port is part of an hardware switch, the mode needs to
be set to Forwarding in order to restore communication with the CPU.

Call br_set_state() in del_nbp(), which only affects switchdev users.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/bridge/br_if.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index c367b3e..93e7b24 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -251,6 +251,11 @@ static void del_nbp(struct net_bridge_port *p)
 
 	nbp_vlan_flush(p);
 	br_fdb_delete_by_port(br, p, 0, 1);
+
+	/* If the port is part of an hardware switch, set its STP state to
+	 * forwarding to restore communication with the CPU port.
+	 */
+	br_set_state(p, BR_STATE_FORWARDING);
 	switchdev_deferred_process();
 
 	nbp_update_port_count(br);
-- 
2.7.1
