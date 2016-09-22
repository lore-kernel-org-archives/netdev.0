From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/4] net: dsa: add port fast ageing
Date: Thu, 22 Sep 2016 16:49:22 -0400
Message-ID: <20160922204924.16229-3-vivien.didelot@savoirfairelinux.com>
References: <20160922204924.16229-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160922204924.16229-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Today the DSA drivers are in charge of flushing the MAC addresses
associated to a port when its STP state changes from Learning or
Forwarding, to Disabled or Blocking or Listening.

This makes the drivers more complex and hides the generic switch logic.
Introduce a new optional port_fast_age operation to dsa_switch_ops, to
move this logic to the DSA layer and keep drivers simple.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h |  2 ++
 net/dsa/slave.c   | 18 ++++++++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 7556646..b122196 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -143,6 +143,7 @@ struct dsa_port {
 	struct net_device	*netdev;
 	struct device_node	*dn;
 	unsigned int		ageing_time;
+	u8			stp_state;
 };
 
 struct dsa_switch {
@@ -339,6 +340,7 @@ struct dsa_switch_ops {
 	void	(*port_bridge_leave)(struct dsa_switch *ds, int port);
 	void	(*port_stp_state_set)(struct dsa_switch *ds, int port,
 				      u8 state);
+	void	(*port_fast_age)(struct dsa_switch *ds, int port);
 
 	/*
 	 * VLAN support
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index fd78d4c..6b1282c 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -71,8 +71,26 @@ static inline bool dsa_port_is_bridged(struct dsa_slave_priv *p)
 
 static void dsa_port_set_stp_state(struct dsa_switch *ds, int port, u8 state)
 {
+	struct dsa_port *dp = &ds->ports[port];
+
 	if (ds->ops->port_stp_state_set)
 		ds->ops->port_stp_state_set(ds, port, state);
+
+	if (ds->ops->port_fast_age) {
+		/* Fast age FDB entries or flush appropriate forwarding database
+		 * for the given port, if we are moving it from Learning or
+		 * Forwarding state, to Disabled or Blocking or Listening state.
+		 */
+
+		if ((dp->stp_state == BR_STATE_LEARNING ||
+		     dp->stp_state == BR_STATE_FORWARDING) &&
+		    (state == BR_STATE_DISABLED ||
+		     state == BR_STATE_BLOCKING ||
+		     state == BR_STATE_LISTENING))
+			ds->ops->port_fast_age(ds, port);
+	}
+
+	dp->stp_state = state;
 }
 
 static int dsa_slave_open(struct net_device *dev)
-- 
2.10.0
