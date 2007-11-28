From: =?us-ascii?Q?=3D=3Futf-8=3Fq=3FFerenc=5FW=3DC3=3DA1gner=3F=3D?=
	<wferi@niif.hu>
Subject: [PATCH 1/3] Remove trailing NULs from network bonding sysfs interface.
Date: Wed, 28 Nov 2007 01:49:54 +0100
Message-ID: <871wabkxcd.fsf@szonett.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, wferi@niif.hu
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:51636 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758117AbXK1At6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 19:49:58 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Also remove trailing spaces from multivalued files.

This fixes output like for example:

$ od -c /sys/class/net/bond0/bonding/slaves
0000000   e   t   h   -   l   e   f   t       e   t   h   -   r   i   g
0000020   h   t      \n  \0
0000025

It mostly entails deleting '+1'-s after sprintf() calls: the return val=
ue
of sprintf is the number of characters printed, without the closing NUL=
,
ie. exactly what the sysfs interface requires.  The three multivalue
cases are different, because they also have to swallow back a trailing
space.

Signed-off-by: Ferenc W=C3=A1gner <wferi@niif.hu>
---
 drivers/net/bonding/bond_sysfs.c |   66 +++++++++++++++++-------------=
-------
 1 files changed, 30 insertions(+), 36 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bon=
d_sysfs.c
index b29330d..a3f1b4a 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -86,14 +86,13 @@ static ssize_t bonding_show_bonds(struct class *cls=
, char *buffer)
 			/* not enough space for another interface name */
 			if ((PAGE_SIZE - res) > 10)
 				res =3D PAGE_SIZE - 10;
-			res +=3D sprintf(buffer + res, "++more++");
+			res +=3D sprintf(buffer + res, "++more++ ");
 			break;
 		}
 		res +=3D sprintf(buffer + res, "%s ",
 			       bond->dev->name);
 	}
-	res +=3D sprintf(buffer + res, "\n");
-	res++;
+	if (res) buffer[res-1] =3D '\n'; /* eat the leftover space */
 	up_read(&(bonding_rwsem));
 	return res;
 }
@@ -235,14 +234,13 @@ static ssize_t bonding_show_slaves(struct device =
*d,
 			/* not enough space for another interface name */
 			if ((PAGE_SIZE - res) > 10)
 				res =3D PAGE_SIZE - 10;
-			res +=3D sprintf(buf + res, "++more++");
+			res +=3D sprintf(buf + res, "++more++ ");
 			break;
 		}
 		res +=3D sprintf(buf + res, "%s ", slave->dev->name);
 	}
 	read_unlock(&bond->lock);
-	res +=3D sprintf(buf + res, "\n");
-	res++;
+	if (res) buf[res-1] =3D '\n'; /* eat the leftover space */
 	return res;
 }
=20
@@ -406,7 +404,7 @@ static ssize_t bonding_show_mode(struct device *d,
=20
 	return sprintf(buf, "%s %d\n",
 			bond_mode_tbl[bond->params.mode].modename,
-			bond->params.mode) + 1;
+			bond->params.mode);
 }
=20
 static ssize_t bonding_store_mode(struct device *d,
@@ -463,11 +461,11 @@ static ssize_t bonding_show_xmit_hash(struct devi=
ce *d,
 	if ((bond->params.mode !=3D BOND_MODE_XOR) &&
 	    (bond->params.mode !=3D BOND_MODE_8023AD)) {
 		// Not Applicable
-		count =3D sprintf(buf, "NA\n") + 1;
+		count =3D sprintf(buf, "NA\n");
 	} else {
 		count =3D sprintf(buf, "%s %d\n",
 			xmit_hashtype_tbl[bond->params.xmit_policy].modename,
-			bond->params.xmit_policy) + 1;
+			bond->params.xmit_policy);
 	}
=20
 	return count;
@@ -527,7 +525,7 @@ static ssize_t bonding_show_arp_validate(struct dev=
ice *d,
=20
 	return sprintf(buf, "%s %d\n",
 		       arp_validate_tbl[bond->params.arp_validate].modename,
-		       bond->params.arp_validate) + 1;
+		       bond->params.arp_validate);
 }
=20
 static ssize_t bonding_store_arp_validate(struct device *d,
@@ -627,7 +625,7 @@ static ssize_t bonding_show_arp_interval(struct dev=
ice *d,
 {
 	struct bonding *bond =3D to_bond(d);
=20
-	return sprintf(buf, "%d\n", bond->params.arp_interval) + 1;
+	return sprintf(buf, "%d\n", bond->params.arp_interval);
 }
=20
 static ssize_t bonding_store_arp_interval(struct device *d,
@@ -711,10 +709,7 @@ static ssize_t bonding_show_arp_targets(struct dev=
ice *d,
 			res +=3D sprintf(buf + res, "%u.%u.%u.%u ",
 			       NIPQUAD(bond->params.arp_targets[i]));
 	}
-	if (res)
-		res--;  /* eat the leftover space */
-	res +=3D sprintf(buf + res, "\n");
-	res++;
+	if (res) buf[res-1] =3D '\n'; /* eat the leftover space */
 	return res;
 }
=20
@@ -815,7 +810,7 @@ static ssize_t bonding_show_downdelay(struct device=
 *d,
 {
 	struct bonding *bond =3D to_bond(d);
=20
-	return sprintf(buf, "%d\n", bond->params.downdelay * bond->params.mii=
mon) + 1;
+	return sprintf(buf, "%d\n", bond->params.downdelay * bond->params.mii=
mon);
 }
=20
 static ssize_t bonding_store_downdelay(struct device *d,
@@ -872,7 +867,7 @@ static ssize_t bonding_show_updelay(struct device *=
d,
 {
 	struct bonding *bond =3D to_bond(d);
=20
-	return sprintf(buf, "%d\n", bond->params.updelay * bond->params.miimo=
n) + 1;
+	return sprintf(buf, "%d\n", bond->params.updelay * bond->params.miimo=
n);
=20
 }
=20
@@ -936,7 +931,7 @@ static ssize_t bonding_show_lacp(struct device *d,
=20
 	return sprintf(buf, "%s %d\n",
 		bond_lacp_tbl[bond->params.lacp_fast].modename,
-		bond->params.lacp_fast) + 1;
+		bond->params.lacp_fast);
 }
=20
 static ssize_t bonding_store_lacp(struct device *d,
@@ -992,7 +987,7 @@ static ssize_t bonding_show_miimon(struct device *d=
,
 {
 	struct bonding *bond =3D to_bond(d);
=20
-	return sprintf(buf, "%d\n", bond->params.miimon) + 1;
+	return sprintf(buf, "%d\n", bond->params.miimon);
 }
=20
 static ssize_t bonding_store_miimon(struct device *d,
@@ -1083,9 +1078,9 @@ static ssize_t bonding_show_primary(struct device=
 *d,
 	struct bonding *bond =3D to_bond(d);
=20
 	if (bond->primary_slave)
-		count =3D sprintf(buf, "%s\n", bond->primary_slave->dev->name) + 1;
+		count =3D sprintf(buf, "%s\n", bond->primary_slave->dev->name);
 	else
-		count =3D sprintf(buf, "\n") + 1;
+		count =3D sprintf(buf, "\n");
=20
 	return count;
 }
@@ -1149,7 +1144,7 @@ static ssize_t bonding_show_carrier(struct device=
 *d,
 {
 	struct bonding *bond =3D to_bond(d);
=20
-	return sprintf(buf, "%d\n", bond->params.use_carrier) + 1;
+	return sprintf(buf, "%d\n", bond->params.use_carrier);
 }
=20
 static ssize_t bonding_store_carrier(struct device *d,
@@ -1198,9 +1193,9 @@ static ssize_t bonding_show_active_slave(struct d=
evice *d,
 	read_unlock(&bond->curr_slave_lock);
=20
 	if (USES_PRIMARY(bond->params.mode) && curr)
-		count =3D sprintf(buf, "%s\n", curr->dev->name) + 1;
+		count =3D sprintf(buf, "%s\n", curr->dev->name);
 	else
-		count =3D sprintf(buf, "\n") + 1;
+		count =3D sprintf(buf, "\n");
 	return count;
 }
=20
@@ -1295,7 +1290,7 @@ static ssize_t bonding_show_mii_status(struct dev=
ice *d,
 	curr =3D bond->curr_active_slave;
 	read_unlock(&bond->curr_slave_lock);
=20
-	return sprintf(buf, "%s\n", (curr) ? "up" : "down") + 1;
+	return sprintf(buf, "%s\n", (curr) ? "up" : "down");
 }
 static DEVICE_ATTR(mii_status, S_IRUGO, bonding_show_mii_status, NULL)=
;
=20
@@ -1312,10 +1307,10 @@ static ssize_t bonding_show_ad_aggregator(struc=
t device *d,
=20
 	if (bond->params.mode =3D=3D BOND_MODE_8023AD) {
 		struct ad_info ad_info;
-		count =3D sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &=
ad_info)) ?  0 : ad_info.aggregator_id) + 1;
+		count =3D sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &=
ad_info)) ?  0 : ad_info.aggregator_id);
 	}
 	else
-		count =3D sprintf(buf, "\n") + 1;
+		count =3D sprintf(buf, "\n");
=20
 	return count;
 }
@@ -1334,10 +1329,10 @@ static ssize_t bonding_show_ad_num_ports(struct=
 device *d,
=20
 	if (bond->params.mode =3D=3D BOND_MODE_8023AD) {
 		struct ad_info ad_info;
-		count =3D sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &=
ad_info)) ?  0: ad_info.ports) + 1;
+		count =3D sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &=
ad_info)) ?  0: ad_info.ports);
 	}
 	else
-		count =3D sprintf(buf, "\n") + 1;
+		count =3D sprintf(buf, "\n");
=20
 	return count;
 }
@@ -1356,10 +1351,10 @@ static ssize_t bonding_show_ad_actor_key(struct=
 device *d,
=20
 	if (bond->params.mode =3D=3D BOND_MODE_8023AD) {
 		struct ad_info ad_info;
-		count =3D sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &=
ad_info)) ?  0 : ad_info.actor_key) + 1;
+		count =3D sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &=
ad_info)) ?  0 : ad_info.actor_key);
 	}
 	else
-		count =3D sprintf(buf, "\n") + 1;
+		count =3D sprintf(buf, "\n");
=20
 	return count;
 }
@@ -1378,10 +1373,10 @@ static ssize_t bonding_show_ad_partner_key(stru=
ct device *d,
=20
 	if (bond->params.mode =3D=3D BOND_MODE_8023AD) {
 		struct ad_info ad_info;
-		count =3D sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &=
ad_info)) ?  0 : ad_info.partner_key) + 1;
+		count =3D sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &=
ad_info)) ?  0 : ad_info.partner_key);
 	}
 	else
-		count =3D sprintf(buf, "\n") + 1;
+		count =3D sprintf(buf, "\n");
=20
 	return count;
 }
@@ -1403,12 +1398,11 @@ static ssize_t bonding_show_ad_partner_mac(stru=
ct device *d,
 		struct ad_info ad_info;
 		if (!bond_3ad_get_active_agg_info(bond, &ad_info)) {
 			count =3D sprintf(buf,"%s\n",
-					print_mac(mac, ad_info.partner_system))
-				+ 1;
+					print_mac(mac, ad_info.partner_system));
 		}
 	}
 	else
-		count =3D sprintf(buf, "\n") + 1;
+		count =3D sprintf(buf, "\n");
=20
 	return count;
 }
--=20
1.4.4.4

