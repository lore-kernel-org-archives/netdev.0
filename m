From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 7/9] net: dsa: define port types
Date: Thu, 26 Oct 2017 11:22:57 -0400
Message-ID: <20171026152259.3123-8-vivien.didelot@savoirfairelinux.com>
References: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:44356 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932351AbdJZPXR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:23:17 -0400
In-Reply-To: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce an enumerated type for ports, which will be way more explicit
to identify a port type instead of digging into switch port masks.

A port can be of type CPU, DSA, user, or unused by default. This is a
static parsed information that cannot be changed at runtime.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 7 +++++++
 net/dsa/dsa2.c    | 3 +++
 net/dsa/legacy.c  | 6 ++++++
 3 files changed, 16 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index dc7728062396..8da20c4a6552 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -180,6 +180,13 @@ struct dsa_port {
 	struct sk_buff *(*rcv)(struct sk_buff *skb, struct net_device *dev,
 			       struct packet_type *pt);
 
+	enum {
+		DSA_PORT_TYPE_UNUSED = 0,
+		DSA_PORT_TYPE_CPU,
+		DSA_PORT_TYPE_DSA,
+		DSA_PORT_TYPE_USER,
+	} type;
+
 	struct dsa_switch	*ds;
 	unsigned int		index;
 	const char		*name;
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index d43c59c91058..dd6f35b92937 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -185,6 +185,7 @@ static int dsa_ds_complete(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 			return err;
 
 		ds->dsa_port_mask |= BIT(index);
+		port->type = DSA_PORT_TYPE_DSA;
 	}
 
 	return 0;
@@ -504,6 +505,7 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 	 * net/dsa/dsa.c::dsa_switch_setup_one does.
 	 */
 	ds->cpu_port_mask |= BIT(index);
+	port->type = DSA_PORT_TYPE_CPU;
 
 	tag_protocol = ds->ops->get_tag_protocol(ds);
 	tag_ops = dsa_resolve_tag_protocol(tag_protocol);
@@ -543,6 +545,7 @@ static int dsa_ds_parse(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 			 * net/dsa/dsa.c::dsa_switch_setup_one does.
 			 */
 			ds->enabled_port_mask |= BIT(index);
+			port->type = DSA_PORT_TYPE_USER;
 		}
 
 	}
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index fa543c4a6061..9fd5b3adab1e 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -101,6 +101,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 	struct dsa_chip_data *cd = ds->cd;
 	bool valid_name_found = false;
 	int index = ds->index;
+	struct dsa_port *dp;
 	int i, ret;
 
 	/*
@@ -109,6 +110,8 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 	for (i = 0; i < ds->num_ports; i++) {
 		char *name;
 
+		dp = &ds->ports[i];
+
 		name = cd->port_names[i];
 		if (name == NULL)
 			continue;
@@ -122,10 +125,13 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 			dst->cpu_dp = &ds->ports[i];
 			dst->cpu_dp->master = master;
 			ds->cpu_port_mask |= 1 << i;
+			dp->type = DSA_PORT_TYPE_CPU;
 		} else if (!strcmp(name, "dsa")) {
 			ds->dsa_port_mask |= 1 << i;
+			dp->type = DSA_PORT_TYPE_DSA;
 		} else {
 			ds->enabled_port_mask |= 1 << i;
+			dp->type = DSA_PORT_TYPE_USER;
 		}
 		valid_name_found = true;
 	}
-- 
2.14.3
