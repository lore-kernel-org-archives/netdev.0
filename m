From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 3/3] net: dsa: Initialize all CPU and enabled ports masks in dsa_ds_parse()
Date: Fri,  2 Jun 2017 12:31:23 -0700
Message-ID: <20170602193123.23930-4-f.fainelli@gmail.com>
References: <20170602193123.23930-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        john@phrozen.org, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33779 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751150AbdFBTbj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 15:31:39 -0400
Received: by mail-wm0-f66.google.com with SMTP id b84so20478137wmh.0
        for <netdev@vger.kernel.org>; Fri, 02 Jun 2017 12:31:38 -0700 (PDT)
In-Reply-To: <20170602193123.23930-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was no reason for duplicating the code that initializes
ds->enabled_port_mask in both dsa_parse_ports_dn() and
dsa_parse_ports(), instead move this to dsa_ds_parse() which is early
enough before ops->setup() has run.

While at it, we can now make dsa_is_cpu_port() check ds->cpu_port_mask
which is a step towards being multi-CPU port capable.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h |  2 +-
 net/dsa/dsa2.c    | 33 +++++++++++++++------------------
 2 files changed, 16 insertions(+), 19 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 448d8bc77707..2effb0af9d7c 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -254,7 +254,7 @@ struct dsa_switch {
 
 static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
 {
-	return ds->dst->cpu_dp == &ds->ports[p];
+	return !!(ds->cpu_port_mask & (1 << p));
 }
 
 static inline bool dsa_is_dsa_port(struct dsa_switch *ds, int p)
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 067daec644c1..cd13bb54a30c 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -250,8 +250,6 @@ static int dsa_cpu_port_apply(struct dsa_port *port)
 		return err;
 	}
 
-	ds->cpu_port_mask |= BIT(port->index);
-
 	memset(&port->devlink_port, 0, sizeof(port->devlink_port));
 	err = devlink_port_register(ds->devlink, &port->devlink_port,
 				    port->index);
@@ -522,6 +520,12 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 
 	dst->rcv = dst->tag_ops->rcv;
 
+	/* Initialize cpu_port_mask now for drv->setup()
+	 * to have access to a correct value, just like what
+	 * net/dsa/dsa.c::dsa_switch_setup_one does.
+	 */
+	ds->cpu_port_mask |= BIT(index);
+
 	return 0;
 }
 
@@ -533,14 +537,22 @@ static int dsa_ds_parse(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 
 	for (index = 0; index < ds->num_ports; index++) {
 		port = &ds->ports[index];
-		if (!dsa_port_is_valid(port))
+		if (!dsa_port_is_valid(port) ||
+		    dsa_port_is_dsa(port))
 			continue;
 
 		if (dsa_port_is_cpu(port)) {
 			err = dsa_cpu_parse(port, index, dst, ds);
 			if (err)
 				return err;
+		} else {
+			/* Initialize enabled_port_mask now for drv->setup()
+			 * to have access to a correct value, just like what
+			 * net/dsa/dsa.c::dsa_switch_setup_one does.
+			 */
+			ds->enabled_port_mask |= BIT(index);
 		}
+
 	}
 
 	pr_info("DSA: switch %d %d parsed\n", dst->tree, ds->index);
@@ -589,13 +601,6 @@ static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)
 			return -EINVAL;
 
 		ds->ports[reg].dn = port;
-
-		/* Initialize enabled_port_mask now for ops->setup()
-		 * to have access to a correct value, just like what
-		 * net/dsa/dsa.c::dsa_switch_setup_one does.
-		 */
-		if (!dsa_port_is_cpu(&ds->ports[reg]))
-			ds->enabled_port_mask |= 1 << reg;
 	}
 
 	return 0;
@@ -611,14 +616,6 @@ static int dsa_parse_ports(struct dsa_chip_data *cd, struct dsa_switch *ds)
 			continue;
 
 		ds->ports[i].name = cd->port_names[i];
-
-		/* Initialize enabled_port_mask now for drv->setup()
-		 * to have access to a correct value, just like what
-		 * net/dsa/dsa.c::dsa_switch_setup_one does.
-		 */
-		if (!dsa_port_is_cpu(&ds->ports[i]))
-			ds->enabled_port_mask |= 1 << i;
-
 		valid_name_found = true;
 	}
 
-- 
2.9.3
