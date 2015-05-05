From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 02/10] net: dsa: Centralize setting up ports
Date: Wed,  6 May 2015 01:09:48 +0200
Message-ID: <1430867396-2268-3-git-send-email-andrew@lunn.ch>
References: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44516 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752216AbbEEXPN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 19:15:13 -0400
In-Reply-To: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that setting up a port is identical for all switches, centralisers
the code looping over all the ports to set them up.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6123_61_65.c |  9 +--------
 drivers/net/dsa/mv88e6131.c       |  9 +--------
 drivers/net/dsa/mv88e6171.c       | 12 +-----------
 drivers/net/dsa/mv88e6352.c       |  9 +--------
 drivers/net/dsa/mv88e6xxx.c       | 16 +++++++++++++++-
 drivers/net/dsa/mv88e6xxx.h       |  2 +-
 6 files changed, 20 insertions(+), 37 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index 73325ab520f2..c7c8b1e232ef 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -83,7 +83,6 @@ static int mv88e6123_61_65_setup_global(struct dsa_switch *ds)
 static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int i;
 	int ret;
 
 	ret = mv88e6xxx_setup_common(ds);
@@ -110,13 +109,7 @@ static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	for (i = 0; i < ps->num_ports; i++) {
-		ret = mv88e6xxx_setup_port(ds, i);
-		if (ret < 0)
-			return ret;
-	}
-
-	return 0;
+	return mv88e6xxx_setup_ports(ds);
 }
 
 struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 310c1cf37830..1a5a15bf16df 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -86,7 +86,6 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 static int mv88e6131_setup(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int i;
 	int ret;
 
 	ret = mv88e6xxx_setup_common(ds);
@@ -118,13 +117,7 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	for (i = 0; i < ps->num_ports; i++) {
-		ret = mv88e6xxx_setup_port(ds, i);
-		if (ret < 0)
-			return ret;
-	}
-
-	return 0;
+	return mv88e6xxx_setup_ports(ds);
 }
 
 static int mv88e6131_port_to_phy_addr(struct dsa_switch *ds, int port)
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 2b733f0cd6b9..a036d0d15a13 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -69,7 +69,6 @@ static int mv88e6171_setup_global(struct dsa_switch *ds)
 static int mv88e6171_setup(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int i;
 	int ret;
 
 	ret = mv88e6xxx_setup_common(ds);
@@ -86,16 +85,7 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	for (i = 0; i < ps->num_ports; i++) {
-		if (!(dsa_is_cpu_port(ds, i) || ds->phys_port_mask & (1 << i)))
-			continue;
-
-		ret = mv88e6xxx_setup_port(ds, i);
-		if (ret < 0)
-			return ret;
-	}
-
-	return 0;
+	return mv88e6xxx_setup_ports(ds);
 }
 
 static int mv88e6171_get_eee(struct dsa_switch *ds, int port,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index b32ec3e9bd6d..41d113749878 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -136,7 +136,6 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
-	int i;
 
 	ret = mv88e6xxx_setup_common(ds);
 	if (ret < 0)
@@ -154,13 +153,7 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	for (i = 0; i < ps->num_ports; i++) {
-		ret = mv88e6xxx_setup_port(ds, i);
-		if (ret < 0)
-			return ret;
-	}
-
-	return 0;
+	return mv88e6xxx_setup_ports(ds);
 }
 
 static int mv88e6352_read_eeprom_word(struct dsa_switch *ds, int addr)
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 84496066f21b..f38d8dfa934a 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1309,7 +1309,7 @@ static void mv88e6xxx_bridge_work(struct work_struct *work)
 	}
 }
 
-int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
+static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret, fid;
@@ -1548,6 +1548,20 @@ abort:
 	return ret;
 }
 
+int mv88e6xxx_setup_ports(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
+	int i;
+
+	for (i = 0; i < ps->num_ports; i++) {
+		ret = mv88e6xxx_setup_port(ds, i);
+		if (ret < 0)
+			return ret;
+	}
+	return 0;
+}
+
 int mv88e6xxx_setup_common(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 2aa1a6b31980..46c5ea3801df 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -336,7 +336,7 @@ struct mv88e6xxx_hw_stat {
 };
 
 int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active);
-int mv88e6xxx_setup_port(struct dsa_switch *ds, int port);
+int mv88e6xxx_setup_ports(struct dsa_switch *ds);
 int mv88e6xxx_setup_common(struct dsa_switch *ds);
 int mv88e6xxx_setup_global(struct dsa_switch *ds);
 int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg);
-- 
2.1.4
