From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH net] switchdev: bridge: Check return code is not EOPNOTSUPP
Date: Fri, 13 Nov 2015 13:06:12 +0200
Message-ID: <1447412772-29745-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>, <davem@davemloft.net>,
	<eladr@mellanox.com>, <linux@eikelenboom.it>,
	Ido Schimmel <idosch@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0089.outbound.protection.outlook.com ([157.56.112.89]:31663
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751032AbbKMLG4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 06:06:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When NET_SWITCHDEV=n, switchdev_port_attr_set simply returns EOPNOTSUPP.
In this case we should not emit errors and warnings to the kernel log.

Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
Fixes: 0bc05d585d38 ("switchdev: allow caller to explicitly request
attr_set as deferred")
Fixes: 6ac311ae8bfb ("Adding switchdev ageing notification on port
bridged")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/bridge/br_stp.c    | 2 +-
 net/bridge/br_stp_if.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index f7e8dee..5f3f645 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -48,7 +48,7 @@ void br_set_state(struct net_bridge_port *p, unsigned int state)
 
 	p->state = state;
 	err = switchdev_port_attr_set(p->dev, &attr);
-	if (err)
+	if (err && err != -EOPNOTSUPP)
 		br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
 				(unsigned int) p->port_no, p->dev->name);
 }
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index fa53d7a..5396ff08 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -50,7 +50,7 @@ void br_init_port(struct net_bridge_port *p)
 	p->config_pending = 0;
 
 	err = switchdev_port_attr_set(p->dev, &attr);
-	if (err)
+	if (err && err != -EOPNOTSUPP)
 		netdev_err(p->dev, "failed to set HW ageing time\n");
 }
 
-- 
2.4.10
