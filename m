From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 09/20] net: dsa: move port state setters
Date: Fri, 19 May 2017 17:00:44 -0400
Message-ID: <20170519210055.9366-10-vivien.didelot@savoirfairelinux.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new port.c file to hold all DSA port-wide logic. This patch moves
in the code which sets a port state.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/Makefile   |  2 +-
 net/dsa/dsa_priv.h |  5 +++++
 net/dsa/port.c     | 55 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/dsa/slave.c    | 40 ---------------------------------------
 4 files changed, 61 insertions(+), 41 deletions(-)
 create mode 100644 net/dsa/port.c

diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index f8c0251d1f43..90e5aa6f7d0f 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -1,6 +1,6 @@
 # the core
 obj-$(CONFIG_NET_DSA) += dsa_core.o
-dsa_core-y += dsa.o slave.o dsa2.o switch.o legacy.o
+dsa_core-y += dsa.o dsa2.o legacy.o port.o slave.o switch.o
 
 # tagging formats
 dsa_core-$(CONFIG_NET_DSA_TAG_BRCM) += tag_brcm.o
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index c274130e3ac9..cda218cd9b05 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -60,6 +60,11 @@ void dsa_cpu_port_ethtool_restore(struct dsa_switch *ds);
 int dsa_legacy_register(void);
 void dsa_legacy_unregister(void);
 
+/* port.c */
+int dsa_port_set_state(struct dsa_port *dp, u8 state,
+		       struct switchdev_trans *trans);
+void dsa_port_set_state_now(struct dsa_port *dp, u8 state);
+
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
diff --git a/net/dsa/port.c b/net/dsa/port.c
new file mode 100644
index 000000000000..6cc4704190fd
--- /dev/null
+++ b/net/dsa/port.c
@@ -0,0 +1,55 @@
+/*
+ * Handling of a single switch port
+ *
+ * Copyright (c) 2017 Savoir-faire Linux Inc.
+ *	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/if_bridge.h>
+
+#include "dsa_priv.h"
+
+int dsa_port_set_state(struct dsa_port *dp, u8 state,
+		       struct switchdev_trans *trans)
+{
+	struct dsa_switch *ds = dp->ds;
+	int port = dp->index;
+
+	if (switchdev_trans_ph_prepare(trans))
+		return ds->ops->port_stp_state_set ? 0 : -EOPNOTSUPP;
+
+	if (ds->ops->port_stp_state_set)
+		ds->ops->port_stp_state_set(ds, port, state);
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
+
+	return 0;
+}
+
+void dsa_port_set_state_now(struct dsa_port *dp, u8 state)
+{
+	int err;
+
+	err = dsa_port_set_state(dp, state, NULL);
+	if (err)
+		pr_err("DSA: failed to set STP state %u (%d)\n", state, err);
+}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index b0150f79dcdd..2c57c7205aa3 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -84,46 +84,6 @@ static inline bool dsa_port_is_bridged(struct dsa_port *dp)
 	return !!dp->bridge_dev;
 }
 
-static int dsa_port_set_state(struct dsa_port *dp, u8 state,
-			      struct switchdev_trans *trans)
-{
-	struct dsa_switch *ds = dp->ds;
-	int port = dp->index;
-
-	if (switchdev_trans_ph_prepare(trans))
-		return ds->ops->port_stp_state_set ? 0 : -EOPNOTSUPP;
-
-	if (ds->ops->port_stp_state_set)
-		ds->ops->port_stp_state_set(ds, port, state);
-
-	if (ds->ops->port_fast_age) {
-		/* Fast age FDB entries or flush appropriate forwarding database
-		 * for the given port, if we are moving it from Learning or
-		 * Forwarding state, to Disabled or Blocking or Listening state.
-		 */
-
-		if ((dp->stp_state == BR_STATE_LEARNING ||
-		     dp->stp_state == BR_STATE_FORWARDING) &&
-		    (state == BR_STATE_DISABLED ||
-		     state == BR_STATE_BLOCKING ||
-		     state == BR_STATE_LISTENING))
-			ds->ops->port_fast_age(ds, port);
-	}
-
-	dp->stp_state = state;
-
-	return 0;
-}
-
-static void dsa_port_set_state_now(struct dsa_port *dp, u8 state)
-{
-	int err;
-
-	err = dsa_port_set_state(dp, state, NULL);
-	if (err)
-		pr_err("DSA: failed to set STP state %u (%d)\n", state, err);
-}
-
 static int dsa_slave_open(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-- 
2.13.0
