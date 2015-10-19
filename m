From: Elad Raz <eladr@mellanox.com>
Subject: [PATCH net-next] Adding switchdev ageing notification on port bridged
Date: Mon, 19 Oct 2015 15:37:25 +0300
Message-ID: <1445258245-12601-1-git-send-email-eladr@mellanox.com>
Cc: Ido Schimmel <idosch@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Jiri Pirko <jiri@mellanox.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38957 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750863AbbJSMhq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 08:37:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Configure ageing time to the HW for newly bridged device

CC: Scott Feldman <sfeldma@gmail.com>
CC: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Elad Raz <eladr@mellanox.com>
---
 net/bridge/br_stp_if.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 4ca449a..fa53d7a 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -15,6 +15,7 @@
 #include <linux/kmod.h>
 #include <linux/etherdevice.h>
 #include <linux/rtnetlink.h>
+#include <net/switchdev.h>
 
 #include "br_private.h"
 #include "br_private_stp.h"
@@ -35,11 +36,22 @@ static inline port_id br_make_port_id(__u8 priority, __u16 port_no)
 /* called under bridge lock */
 void br_init_port(struct net_bridge_port *p)
 {
+	struct switchdev_attr attr = {
+		.id = SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
+		.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP | SWITCHDEV_F_DEFER,
+		.u.ageing_time = p->br->ageing_time,
+	};
+	int err;
+
 	p->port_id = br_make_port_id(p->priority, p->port_no);
 	br_become_designated_port(p);
 	br_set_state(p, BR_STATE_BLOCKING);
 	p->topology_change_ack = 0;
 	p->config_pending = 0;
+
+	err = switchdev_port_attr_set(p->dev, &attr);
+	if (err)
+		netdev_err(p->dev, "failed to set HW ageing time\n");
 }
 
 /* called under bridge lock */
-- 
2.4.3
