From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 09/10] dsa: use prepare/commit switchdev transaction helpers
Date: Thu, 24 Sep 2015 10:02:48 +0200
Message-ID: <1443081769-11193-10-git-send-email-jiri@resnulli.us>
References: <1443081769-11193-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36773 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108AbbIXIDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 04:03:03 -0400
Received: by wicgb1 with SMTP id gb1so238169600wic.1
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 01:03:02 -0700 (PDT)
In-Reply-To: <1443081769-11193-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The enum is going to disappear, use the helpers instead.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/dsa/slave.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 748cc63..71a1155 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -251,8 +251,7 @@ static int dsa_slave_port_vlan_add(struct net_device *dev,
 	u16 vid;
 	int err;
 
-	switch (trans->ph) {
-	case SWITCHDEV_TRANS_PREPARE:
+	if (switchdev_trans_ph_prepare(trans)) {
 		if (!ds->drv->port_vlan_add || !ds->drv->port_pvid_set)
 			return -EOPNOTSUPP;
 
@@ -264,8 +263,7 @@ static int dsa_slave_port_vlan_add(struct net_device *dev,
 						  vlan->vid_end);
 		if (err)
 			return err;
-		break;
-	case SWITCHDEV_TRANS_COMMIT:
+	} else {
 		for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
 			err = ds->drv->port_vlan_add(ds, p->port, vid,
 						     vlan->flags &
@@ -275,9 +273,6 @@ static int dsa_slave_port_vlan_add(struct net_device *dev,
 			if (err)
 				return err;
 		}
-		break;
-	default:
-		return -EOPNOTSUPP;
 	}
 
 	return 0;
@@ -356,9 +351,9 @@ static int dsa_slave_port_fdb_add(struct net_device *dev,
 	struct dsa_switch *ds = p->parent;
 	int ret = -EOPNOTSUPP;
 
-	if (trans->ph == SWITCHDEV_TRANS_PREPARE)
+	if (switchdev_trans_ph_prepare(trans))
 		ret = ds->drv->port_fdb_add ? 0 : -EOPNOTSUPP;
-	else if (trans->ph == SWITCHDEV_TRANS_COMMIT)
+	else
 		ret = ds->drv->port_fdb_add(ds, p->port, fdb->addr, fdb->vid);
 
 	return ret;
@@ -465,7 +460,7 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_STP_STATE:
-		if (trans->ph == SWITCHDEV_TRANS_COMMIT)
+		if (switchdev_trans_ph_commit(trans))
 			ret = dsa_slave_stp_update(dev, attr->u.stp_state);
 		break;
 	default:
-- 
1.9.3
