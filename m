From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next] net/bridge: Enable bridge also when switchdev can't be built
Date: Wed, 13 May 2015 13:08:43 +0300
Message-ID: <1431511723-26323-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:54952 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933306AbbEMKJK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 06:09:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently switchdev doesn't build on older gcc version such as 4.4.6

The reason for the compile error is such that it causes a failure
to build the bridge too, even when switchdev isn't configured (the
stub isn't enough), fix it.

CC [M]  net/bridge/br_stp.o
net/bridge/br_stp.c: In function 'br_set_state':
net/bridge/br_stp.c:44: error: unknown field 'stp_state' specified in initializer

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 net/bridge/br_stp.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index b9300da..752783a 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -39,17 +39,19 @@ void br_log_state(const struct net_bridge_port *p)
 
 void br_set_state(struct net_bridge_port *p, unsigned int state)
 {
+#ifdef CONFIG_NET_SWITCHDEV
 	struct switchdev_attr attr = {
 		.id = SWITCHDEV_ATTR_PORT_STP_STATE,
 		.stp_state = state,
 	};
 	int err;
 
-	p->state = state;
 	err = switchdev_port_attr_set(p->dev, &attr);
 	if (err && err != -EOPNOTSUPP)
 		br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
 				(unsigned int) p->port_no, p->dev->name);
+#endif
+	p->state = state;
 }
 
 /* called under bridge lock */
-- 
1.7.1
