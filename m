From: Patrick Uiterwijk <patrick@puiterwijk.org>
Subject: [PATCH net-next v2 1/2] net: dsa: mv88e6xxx: Introduce _mv88e6xxx_phy_page_{read,write}
Date: Tue, 29 Mar 2016 11:11:47 +0000
Message-ID: <1459249908-4556-1-git-send-email-patrick@puiterwijk.org>
Cc: netdev@vger.kernel.org, dennis@ausil.us, pbrobinson@gmail.com,
	Patrick Uiterwijk <patrick@puiterwijk.org>
To: linux@roeck-us.net, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34400 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753911AbcC2LM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 07:12:26 -0400
Received: by mail-wm0-f42.google.com with SMTP id p65so134086183wmp.1
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 04:12:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add versions of the phy_page_read and _write functions to
be used in a context where the SMI mutex is held.

Signed-off-by: Patrick Uiterwijk <patrick@puiterwijk.org>
---
 drivers/net/dsa/mv88e6xxx.c | 49 +++++++++++++++++++++++++++++++++------------
 1 file changed, 36 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index fa086e0..86a2029 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2264,6 +2264,38 @@ static void mv88e6xxx_bridge_work(struct work_struct *work)
 	mutex_unlock(&ps->smi_mutex);
 }
 
+static int _mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
+				     int reg, int val)
+{
+	int ret;
+
+	ret = _mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
+	if (ret < 0)
+		goto restore_page_0;
+
+	ret = _mv88e6xxx_phy_write_indirect(ds, port, reg, val);
+restore_page_0:
+	_mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
+
+	return ret;
+}
+
+static int _mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page,
+				    int reg)
+{
+	int ret;
+
+	ret = _mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
+	if (ret < 0)
+		goto restore_page_0;
+
+	ret = _mv88e6xxx_phy_read_indirect(ds, port, reg);
+restore_page_0:
+	_mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
+
+	return ret;
+}
+
 static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -2714,13 +2746,9 @@ int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
-	if (ret < 0)
-		goto error;
-	ret = _mv88e6xxx_phy_read_indirect(ds, port, reg);
-error:
-	_mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
+	ret = _mv88e6xxx_phy_page_read(ds, port, page, reg);
 	mutex_unlock(&ps->smi_mutex);
+
 	return ret;
 }
 
@@ -2731,14 +2759,9 @@ int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
-	if (ret < 0)
-		goto error;
-
-	ret = _mv88e6xxx_phy_write_indirect(ds, port, reg, val);
-error:
-	_mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
+	ret = _mv88e6xxx_phy_page_write(ds, port, page, reg, val);
 	mutex_unlock(&ps->smi_mutex);
+
 	return ret;
 }
 
-- 
2.7.4
