From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 3/3] net: dsa: b53: Remove CPU port specific VLAN programming
Date: Mon, 21 Nov 2016 11:09:25 -0800
Message-ID: <20161121190925.14530-4-f.fainelli@gmail.com>
References: <20161121190925.14530-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, bridge@lists.linux-foundation.org,
        stephen@networkplumber.org, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, jiri@mellanox.com, idosch@mellanox.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34120 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754587AbcKUTKM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 14:10:12 -0500
Received: by mail-pg0-f66.google.com with SMTP id e9so28912546pgc.1
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 11:10:07 -0800 (PST)
In-Reply-To: <20161121190925.14530-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that DSA calls into the switch driver to program the CPU port's VLAN
attributes, we can get rid of the code that dealt with adding/removing
the CPU port to a downstream facing port VLAN membership.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 22 ++++++----------------
 1 file changed, 6 insertions(+), 16 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 7717b19dc806..6577286a2721 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -951,7 +951,6 @@ static void b53_vlan_add(struct dsa_switch *ds, int port,
 	struct b53_device *dev = ds->priv;
 	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
 	bool pvid = vlan->flags & BRIDGE_VLAN_INFO_PVID;
-	unsigned int cpu_port = dev->cpu_port;
 	struct b53_vlan *vl;
 	u16 vid;
 
@@ -960,11 +959,11 @@ static void b53_vlan_add(struct dsa_switch *ds, int port,
 
 		b53_get_vlan_entry(dev, vid, vl);
 
-		vl->members |= BIT(port) | BIT(cpu_port);
+		vl->members |= BIT(port);
 		if (untagged)
-			vl->untag |= BIT(port) | BIT(cpu_port);
+			vl->untag |= BIT(port);
 		else
-			vl->untag &= ~(BIT(port) | BIT(cpu_port));
+			vl->untag &= ~BIT(port);
 
 		b53_set_vlan_entry(dev, vid, vl);
 		b53_fast_age_vlan(dev, vid);
@@ -973,8 +972,6 @@ static void b53_vlan_add(struct dsa_switch *ds, int port,
 	if (pvid) {
 		b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_PORT_DEF_TAG(port),
 			    vlan->vid_end);
-		b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_PORT_DEF_TAG(cpu_port),
-			    vlan->vid_end);
 		b53_fast_age_vlan(dev, vid);
 	}
 }
@@ -984,7 +981,6 @@ static int b53_vlan_del(struct dsa_switch *ds, int port,
 {
 	struct b53_device *dev = ds->priv;
 	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
-	unsigned int cpu_port = dev->cpu_port;
 	struct b53_vlan *vl;
 	u16 vid;
 	u16 pvid;
@@ -997,8 +993,6 @@ static int b53_vlan_del(struct dsa_switch *ds, int port,
 		b53_get_vlan_entry(dev, vid, vl);
 
 		vl->members &= ~BIT(port);
-		if ((vl->members & BIT(cpu_port)) == BIT(cpu_port))
-			vl->members = 0;
 
 		if (pvid == vid) {
 			if (is5325(dev) || is5365(dev))
@@ -1007,18 +1001,14 @@ static int b53_vlan_del(struct dsa_switch *ds, int port,
 				pvid = 0;
 		}
 
-		if (untagged) {
+		if (untagged)
 			vl->untag &= ~(BIT(port));
-			if ((vl->untag & BIT(cpu_port)) == BIT(cpu_port))
-				vl->untag = 0;
-		}
 
 		b53_set_vlan_entry(dev, vid, vl);
 		b53_fast_age_vlan(dev, vid);
 	}
 
 	b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_PORT_DEF_TAG(port), pvid);
-	b53_write16(dev, B53_VLAN_PAGE, B53_VLAN_PORT_DEF_TAG(cpu_port), pvid);
 	b53_fast_age_vlan(dev, pvid);
 
 	return 0;
@@ -1396,8 +1386,8 @@ static void b53_br_leave(struct dsa_switch *ds, int port)
 		b53_write16(dev, B53_VLAN_PAGE, B53_JOIN_ALL_VLAN_EN, reg);
 	} else {
 		b53_get_vlan_entry(dev, pvid, vl);
-		vl->members |= BIT(port) | BIT(dev->cpu_port);
-		vl->untag |= BIT(port) | BIT(dev->cpu_port);
+		vl->members |= BIT(port);
+		vl->untag |= BIT(port);
 		b53_set_vlan_entry(dev, pvid, vl);
 	}
 }
-- 
2.9.3
