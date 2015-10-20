From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 2/6] net: dsa: mv88e6xxx: write VID outside of VTU Get Next code
Date: Tue, 20 Oct 2015 12:17:22 -0400
Message-ID: <1445357846-25720-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1445357846-25720-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:39742 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbbJTQ1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 12:27:32 -0400
In-Reply-To: <1445357846-25720-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to write the VLAN ID before every Get Next operation,
since the VTU VID register is not cleared between calls.

Move the VID write call in a _mv88e6xxx_vtu_vid_write function outside
of _mv88e6xxx_vtu_getnext so future code could call VTU Get Next
multiple times and save a few register accesses.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 45 ++++++++++++++++++++++++++++++++++-----------
 1 file changed, 34 insertions(+), 11 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 52b74f1..5b58323 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1259,7 +1259,13 @@ static int _mv88e6xxx_vtu_stu_data_write(struct dsa_switch *ds,
 	return 0;
 }
 
-static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds, u16 vid,
+static int _mv88e6xxx_vtu_vid_write(struct dsa_switch *ds, u16 vid)
+{
+	return _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_VID,
+				    vid & GLOBAL_VTU_VID_MASK);
+}
+
+static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds,
 				  struct mv88e6xxx_vtu_stu_entry *entry)
 {
 	struct mv88e6xxx_vtu_stu_entry next = { 0 };
@@ -1269,11 +1275,6 @@ static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds, u16 vid,
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_VID,
-				   vid & GLOBAL_VTU_VID_MASK);
-	if (ret < 0)
-		return ret;
-
 	ret = _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_VTU_GET_NEXT);
 	if (ret < 0)
 		return ret;
@@ -1485,7 +1486,12 @@ int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
 	int err;
 
 	mutex_lock(&ps->smi_mutex);
-	err = _mv88e6xxx_vtu_getnext(ds, vid - 1, &vlan);
+
+	err = _mv88e6xxx_vtu_vid_write(ds, vid - 1);
+	if (err)
+		goto unlock;
+
+	err = _mv88e6xxx_vtu_getnext(ds, &vlan);
 	if (err)
 		goto unlock;
 
@@ -1514,7 +1520,11 @@ int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
 
 	mutex_lock(&ps->smi_mutex);
 
-	err = _mv88e6xxx_vtu_getnext(ds, vid - 1, &vlan);
+	err = _mv88e6xxx_vtu_vid_write(ds, vid - 1);
+	if (err)
+		goto unlock;
+
+	err = _mv88e6xxx_vtu_getnext(ds, &vlan);
 	if (err)
 		goto unlock;
 
@@ -1558,7 +1568,11 @@ static int _mv88e6xxx_port_vtu_getnext(struct dsa_switch *ds, int port, u16 vid,
 		if (vid == 4095)
 			return -ENOENT;
 
-		err = _mv88e6xxx_vtu_getnext(ds, vid, entry);
+		err = _mv88e6xxx_vtu_vid_write(ds, vid);
+		if (err)
+			return err;
+
+		err = _mv88e6xxx_vtu_getnext(ds, entry);
 		if (err)
 			return err;
 
@@ -1584,7 +1598,12 @@ int mv88e6xxx_vlan_getnext(struct dsa_switch *ds, u16 *vid,
 		return -ENOENT;
 
 	mutex_lock(&ps->smi_mutex);
-	err = _mv88e6xxx_vtu_getnext(ds, *vid, &next);
+	err = _mv88e6xxx_vtu_vid_write(ds, *vid);
+	if (err)
+		goto unlock;
+
+	err = _mv88e6xxx_vtu_getnext(ds, &next);
+unlock:
 	mutex_unlock(&ps->smi_mutex);
 
 	if (err)
@@ -2272,10 +2291,14 @@ static int mv88e6xxx_vtu_show(struct seq_file *s, void *p)
 
 	mutex_lock(&ps->smi_mutex);
 
+	ret = _mv88e6xxx_vtu_vid_write(ds, vid);
+	if (ret < 0)
+		goto unlock;
+
 	do {
 		struct mv88e6xxx_vtu_stu_entry next = { 0 };
 
-		ret = _mv88e6xxx_vtu_getnext(ds, vid, &next);
+		ret = _mv88e6xxx_vtu_getnext(ds, &next);
 		if (ret < 0)
 			goto unlock;
 
-- 
2.6.1
