From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: initialize the routing table
Date: Wed,  6 Jul 2016 20:03:54 -0400
Message-ID: <20160707000354.18217-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:56321 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932235AbcGGAEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 20:04:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The routing table of every switch in a tree is currently initialized to
all zeros. This is an issue since 0 is a valid port number.

Add a DSA_RTABLE_NONE=-1 constant to initialize the signed values of the
routing table pointing to other switches.

This fixes the device mapping of the mv88e6xxx driver where the port
pointing to the switch itself and to non-existent switches was wrongly
configured to be 0. It is now set to the expected 0xf value.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 2 ++
 net/dsa/dsa.c     | 6 ++++++
 net/dsa/dsa2.c    | 7 ++++++-
 3 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 20b3087..52ab18b 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -32,6 +32,8 @@ enum dsa_tag_protocol {
 #define DSA_MAX_SWITCHES	4
 #define DSA_MAX_PORTS		12
 
+#define DSA_RTABLE_NONE		-1
+
 struct dsa_chip_data {
 	/*
 	 * How to access the switch configuration registers.
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 766d2a5..7e68bc6 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -774,11 +774,17 @@ static int dsa_of_probe(struct device *dev)
 
 	chip_index = -1;
 	for_each_available_child_of_node(np, child) {
+		int i;
+
 		chip_index++;
 		cd = &pd->chip[chip_index];
 
 		cd->of_node = child;
 
+		/* Initialize the routing table */
+		for (i = 0; i < DSA_MAX_SWITCHES; ++i)
+			cd->rtable[i] = DSA_RTABLE_NONE;
+
 		/* When assigning the host device, increment its refcount */
 		cd->host_dev = get_device(&mdio_bus->dev);
 
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 83b95fc..78e4c01 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -595,7 +595,7 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
 	struct device_node *ports = dsa_get_ports(ds, np);
 	struct dsa_switch_tree *dst;
 	u32 tree, index;
-	int err;
+	int i, err;
 
 	err = dsa_parse_member(np, &tree, &index);
 	if (err)
@@ -622,6 +622,11 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
 
 	ds->dst = dst;
 	ds->index = index;
+
+	/* Initialize the routing table */
+	for (i = 0; i < DSA_MAX_SWITCHES; ++i)
+		ds->rtable[i] = DSA_RTABLE_NONE;
+
 	dsa_dst_add_ds(dst, ds, index);
 
 	err = dsa_dst_complete(dst);
-- 
2.9.0
