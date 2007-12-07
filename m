From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Fri, 7 Dec 2007 15:31:34 -0500
Message-ID: <20071207203134.GA28922@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:39474 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753761AbXLGUbf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2007 15:31:35 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nothing remarkable.  Mainly bonding fixes and bringing ibm_newemac up to
snuff.


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 Documentation/networking/bonding.txt |   29 ++++++++-
 arch/powerpc/boot/dts/sequoia.dts    |    5 ++
 drivers/net/Kconfig                  |    1 +
 drivers/net/bonding/bond_main.c      |  116 +++++++++++++++++++++-------------
 drivers/net/bonding/bond_sysfs.c     |   94 +++++++++-------------------
 drivers/net/bonding/bonding.h        |    4 +-
 drivers/net/cxgb3/regs.h             |   27 ++++++++-
 drivers/net/cxgb3/t3_hw.c            |    6 +-
 drivers/net/cxgb3/xgmac.c            |   44 +++++++++-----
 drivers/net/e100.c                   |    6 +-
 drivers/net/e1000/e1000_ethtool.c    |    2 +-
 drivers/net/e1000e/ethtool.c         |    2 +-
 drivers/net/ibm_newemac/core.c       |   56 +++++++++++-----
 drivers/net/ibm_newemac/core.h       |   11 +++-
 drivers/net/ibm_newemac/debug.c      |    5 ++
 drivers/net/ibm_newemac/debug.h      |    5 ++
 drivers/net/ibm_newemac/emac.h       |    5 ++
 drivers/net/ibm_newemac/mal.c        |    5 ++
 drivers/net/ibm_newemac/mal.h        |    5 ++
 drivers/net/ibm_newemac/phy.c        |   81 +++++++++++++++++++++++
 drivers/net/ibm_newemac/phy.h        |    5 ++
 drivers/net/ibm_newemac/rgmii.c      |   25 +++++---
 drivers/net/ibm_newemac/rgmii.h      |   10 +++-
 drivers/net/ibm_newemac/tah.c        |    8 ++-
 drivers/net/ibm_newemac/tah.h        |    5 ++
 drivers/net/ibm_newemac/zmii.c       |    9 +++-
 drivers/net/ibm_newemac/zmii.h       |    5 ++
 drivers/net/s2io-regs.h              |    1 +
 drivers/net/s2io.c                   |   16 +++++-
 include/linux/if_bonding.h           |    3 +-
 30 files changed, 423 insertions(+), 173 deletions(-)

Auke Kok (1):
      e100: cleanup unneeded math

Benjamin Herrenschmidt (5):
      ibm_newemac: Fix ZMII refcounting bug
      ibm_newemac: Workaround reset timeout when no link
      ibm_newemac: Cleanup/Fix RGMII MDIO support detection
      ibm_newemac: Cleanup/fix support for STACR register variants
      ibm_newemac: Update file headers copyright notices

David Sterba (1):
      bonding: Fix time comparison

Divy Le Ray (1):
      cxgb3 - T3C support update

Eliezer Tamir (1):
      make bnx2x select ZLIB_INFLATE

Hugh Blemings (1):
      ibm_newemac: Skip EMACs that are marked unused by the firmware

Jay Vosburgh (2):
      bonding: Add new layer2+3 hash for xor/802.3ad modes
      bonding: Fix race at module unload

Roel Kluin (1):
      e1000: fix memcpy in e1000_get_strings

Sreenivasa Honnur (1):
      S2io: Check for register initialization completion before accesing device registers

Stefan Roese (2):
      ibm_newemac: Add BCM5248 and Marvell 88E1111 PHY support
      ibm_newemac: Add ET1011c PHY support

Valentine Barshak (3):
      ibm_newemac: Correct opb_bus_freq value
      ibm_newemac: Fix typo reading TAH channel info
      ibm_newemac: Call dev_set_drvdata() before tah_reset()

Wagner Ferenc (5):
      bonding: Remove trailing NULs from sysfs interface.
      bonding: Return nothing for not applicable values
      bonding: Purely cosmetic: rename a local variable
      bonding: Coding style: break line after the if condition
      bonding: Allow setting and querying xmit policy regardless of mode

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 1134062..6cc30e0 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -554,6 +554,30 @@ xmit_hash_policy
 
 		This algorithm is 802.3ad compliant.
 
+	layer2+3
+
+		This policy uses a combination of layer2 and layer3
+		protocol information to generate the hash.
+
+		Uses XOR of hardware MAC addresses and IP addresses to
+		generate the hash.  The formula is
+
+		(((source IP XOR dest IP) AND 0xffff) XOR
+			( source MAC XOR destination MAC ))
+				modulo slave count
+
+		This algorithm will place all traffic to a particular
+		network peer on the same slave.  For non-IP traffic,
+		the formula is the same as for the layer2 transmit
+		hash policy.
+
+		This policy is intended to provide a more balanced
+		distribution of traffic than layer2 alone, especially
+		in environments where a layer3 gateway device is
+		required to reach most destinations.
+
+		This algorithm is 802.3ad complient.
+
 	layer3+4
 
 		This policy uses upper layer protocol information,
@@ -589,8 +613,9 @@ xmit_hash_policy
 		or may not tolerate this noncompliance.
 
 	The default value is layer2.  This option was added in bonding
-version 2.6.3.  In earlier versions of bonding, this parameter does
-not exist, and the layer2 policy is the only policy.
+	version 2.6.3.  In earlier versions of bonding, this parameter
+	does not exist, and the layer2 policy is the only policy.  The
+	layer2+3 value was added for bonding version 3.2.2.
 
 
 3. Configuring Bonding Devices
diff --git a/arch/powerpc/boot/dts/sequoia.dts b/arch/powerpc/boot/dts/sequoia.dts
index 8833dfe..10784ff 100644
--- a/arch/powerpc/boot/dts/sequoia.dts
+++ b/arch/powerpc/boot/dts/sequoia.dts
@@ -245,6 +245,7 @@
 				device_type = "rgmii-interface";
 				compatible = "ibm,rgmii-440epx", "ibm,rgmii";
 				reg = <ef601000 8>;
+				has-mdio;
 			};
 
 			EMAC0: ethernet@ef600e00 {
@@ -273,6 +274,8 @@
 				zmii-channel = <0>;
 				rgmii-device = <&RGMII0>;
 				rgmii-channel = <0>;
+				has-inverted-stacr-oc;
+				has-new-stacr-staopc;
 			};
 
 			EMAC1: ethernet@ef600f00 {
@@ -301,6 +304,8 @@
 				zmii-channel = <1>;
 				rgmii-device = <&RGMII0>;
 				rgmii-channel = <1>;
+				has-inverted-stacr-oc;
+				has-new-stacr-staopc;
 			};
 		};
 	};
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d9107e5..6cde4ed 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2588,6 +2588,7 @@ config MLX4_DEBUG
 config TEHUTI
 	tristate "Tehuti Networks 10G Ethernet"
 	depends on PCI
+	select ZLIB_INFLATE
 	help
 	  Tehuti Networks 10G Ethernet NIC
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 423298c..b0b2603 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -74,6 +74,7 @@
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
 #include <linux/if_bonding.h>
+#include <linux/jiffies.h>
 #include <net/route.h>
 #include <net/net_namespace.h>
 #include "bonding.h"
@@ -174,6 +175,7 @@ struct bond_parm_tbl bond_mode_tbl[] = {
 struct bond_parm_tbl xmit_hashtype_tbl[] = {
 {	"layer2",		BOND_XMIT_POLICY_LAYER2},
 {	"layer3+4",		BOND_XMIT_POLICY_LAYER34},
+{	"layer2+3",		BOND_XMIT_POLICY_LAYER23},
 {	NULL,			-1},
 };
 
@@ -2722,8 +2724,8 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	 */
 	bond_for_each_slave(bond, slave, i) {
 		if (slave->link != BOND_LINK_UP) {
-			if (((jiffies - slave->dev->trans_start) <= delta_in_ticks) &&
-			    ((jiffies - slave->dev->last_rx) <= delta_in_ticks)) {
+			if (time_before_eq(jiffies, slave->dev->trans_start + delta_in_ticks) &&
+			    time_before_eq(jiffies, slave->dev->last_rx + delta_in_ticks)) {
 
 				slave->link  = BOND_LINK_UP;
 				slave->state = BOND_STATE_ACTIVE;
@@ -2754,8 +2756,8 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 			 * when the source ip is 0, so don't take the link down
 			 * if we don't know our ip yet
 			 */
-			if (((jiffies - slave->dev->trans_start) >= (2*delta_in_ticks)) ||
-			    (((jiffies - slave->dev->last_rx) >= (2*delta_in_ticks)) &&
+			if (time_after_eq(jiffies, slave->dev->trans_start + 2*delta_in_ticks) ||
+			    (time_after_eq(jiffies, slave->dev->last_rx + 2*delta_in_ticks) &&
 			     bond_has_ip(bond))) {
 
 				slave->link  = BOND_LINK_DOWN;
@@ -2848,8 +2850,8 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 	 */
 	bond_for_each_slave(bond, slave, i) {
 		if (slave->link != BOND_LINK_UP) {
-			if ((jiffies - slave_last_rx(bond, slave)) <=
-			     delta_in_ticks) {
+			if (time_before_eq(jiffies,
+			    slave_last_rx(bond, slave) + delta_in_ticks)) {
 
 				slave->link = BOND_LINK_UP;
 
@@ -2858,7 +2860,7 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 				write_lock_bh(&bond->curr_slave_lock);
 
 				if ((!bond->curr_active_slave) &&
-				    ((jiffies - slave->dev->trans_start) <= delta_in_ticks)) {
+				    time_before_eq(jiffies, slave->dev->trans_start + delta_in_ticks)) {
 					bond_change_active_slave(bond, slave);
 					bond->current_arp_slave = NULL;
 				} else if (bond->curr_active_slave != slave) {
@@ -2897,7 +2899,7 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 
 			if ((slave != bond->curr_active_slave) &&
 			    (!bond->current_arp_slave) &&
-			    (((jiffies - slave_last_rx(bond, slave)) >= 3*delta_in_ticks) &&
+			    (time_after_eq(jiffies, slave_last_rx(bond, slave) + 3*delta_in_ticks) &&
 			     bond_has_ip(bond))) {
 				/* a backup slave has gone down; three times
 				 * the delta allows the current slave to be
@@ -2943,10 +2945,10 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 		 * before being taken out. if a primary is being used, check
 		 * if it is up and needs to take over as the curr_active_slave
 		 */
-		if ((((jiffies - slave->dev->trans_start) >= (2*delta_in_ticks)) ||
-	    (((jiffies - slave_last_rx(bond, slave)) >= (2*delta_in_ticks)) &&
-	     bond_has_ip(bond))) &&
-		    ((jiffies - slave->jiffies) >= 2*delta_in_ticks)) {
+		if ((time_after_eq(jiffies, slave->dev->trans_start + 2*delta_in_ticks) ||
+			(time_after_eq(jiffies, slave_last_rx(bond, slave) + 2*delta_in_ticks) &&
+			 bond_has_ip(bond))) &&
+			time_after_eq(jiffies, slave->jiffies + 2*delta_in_ticks)) {
 
 			slave->link  = BOND_LINK_DOWN;
 
@@ -3604,6 +3606,24 @@ void bond_unregister_arp(struct bonding *bond)
 /*---------------------------- Hashing Policies -----------------------------*/
 
 /*
+ * Hash for the output device based upon layer 2 and layer 3 data. If
+ * the packet is not IP mimic bond_xmit_hash_policy_l2()
+ */
+static int bond_xmit_hash_policy_l23(struct sk_buff *skb,
+				     struct net_device *bond_dev, int count)
+{
+	struct ethhdr *data = (struct ethhdr *)skb->data;
+	struct iphdr *iph = ip_hdr(skb);
+
+	if (skb->protocol == __constant_htons(ETH_P_IP)) {
+		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
+			(data->h_dest[5] ^ bond_dev->dev_addr[5])) % count;
+	}
+
+	return (data->h_dest[5] ^ bond_dev->dev_addr[5]) % count;
+}
+
+/*
  * Hash for the output device based upon layer 3 and layer 4 data. If
  * the packet is a frag or not TCP or UDP, just use layer 3 data.  If it is
  * altogether not IP, mimic bond_xmit_hash_policy_l2()
@@ -4305,6 +4325,22 @@ out:
 
 /*------------------------- Device initialization ---------------------------*/
 
+static void bond_set_xmit_hash_policy(struct bonding *bond)
+{
+	switch (bond->params.xmit_policy) {
+	case BOND_XMIT_POLICY_LAYER23:
+		bond->xmit_hash_policy = bond_xmit_hash_policy_l23;
+		break;
+	case BOND_XMIT_POLICY_LAYER34:
+		bond->xmit_hash_policy = bond_xmit_hash_policy_l34;
+		break;
+	case BOND_XMIT_POLICY_LAYER2:
+	default:
+		bond->xmit_hash_policy = bond_xmit_hash_policy_l2;
+		break;
+	}
+}
+
 /*
  * set bond mode specific net device operations
  */
@@ -4321,10 +4357,7 @@ void bond_set_mode_ops(struct bonding *bond, int mode)
 		break;
 	case BOND_MODE_XOR:
 		bond_dev->hard_start_xmit = bond_xmit_xor;
-		if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER34)
-			bond->xmit_hash_policy = bond_xmit_hash_policy_l34;
-		else
-			bond->xmit_hash_policy = bond_xmit_hash_policy_l2;
+		bond_set_xmit_hash_policy(bond);
 		break;
 	case BOND_MODE_BROADCAST:
 		bond_dev->hard_start_xmit = bond_xmit_broadcast;
@@ -4332,10 +4365,7 @@ void bond_set_mode_ops(struct bonding *bond, int mode)
 	case BOND_MODE_8023AD:
 		bond_set_master_3ad_flags(bond);
 		bond_dev->hard_start_xmit = bond_3ad_xmit_xor;
-		if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER34)
-			bond->xmit_hash_policy = bond_xmit_hash_policy_l34;
-		else
-			bond->xmit_hash_policy = bond_xmit_hash_policy_l2;
+		bond_set_xmit_hash_policy(bond);
 		break;
 	case BOND_MODE_ALB:
 		bond_set_master_alb_flags(bond);
@@ -4462,6 +4492,27 @@ static void bond_deinit(struct net_device *bond_dev)
 #endif
 }
 
+static void bond_work_cancel_all(struct bonding *bond)
+{
+	write_lock_bh(&bond->lock);
+	bond->kill_timers = 1;
+	write_unlock_bh(&bond->lock);
+
+	if (bond->params.miimon && delayed_work_pending(&bond->mii_work))
+		cancel_delayed_work(&bond->mii_work);
+
+	if (bond->params.arp_interval && delayed_work_pending(&bond->arp_work))
+		cancel_delayed_work(&bond->arp_work);
+
+	if (bond->params.mode == BOND_MODE_ALB &&
+	    delayed_work_pending(&bond->alb_work))
+		cancel_delayed_work(&bond->alb_work);
+
+	if (bond->params.mode == BOND_MODE_8023AD &&
+	    delayed_work_pending(&bond->ad_work))
+		cancel_delayed_work(&bond->ad_work);
+}
+
 /* Unregister and free all bond devices.
  * Caller must hold rtnl_lock.
  */
@@ -4472,6 +4523,7 @@ static void bond_free_all(void)
 	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
 		struct net_device *bond_dev = bond->dev;
 
+		bond_work_cancel_all(bond);
 		bond_mc_list_destroy(bond);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
@@ -4497,8 +4549,7 @@ int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl)
 	for (i = 0; tbl[i].modename; i++) {
 		if ((isdigit(*mode_arg) &&
 		     tbl[i].mode == simple_strtol(mode_arg, NULL, 0)) ||
-		    (strncmp(mode_arg, tbl[i].modename,
-			     strlen(tbl[i].modename)) == 0)) {
+		    (strcmp(mode_arg, tbl[i].modename) == 0)) {
 			return tbl[i].mode;
 		}
 	}
@@ -4873,27 +4924,6 @@ out_rtnl:
 	return res;
 }
 
-static void bond_work_cancel_all(struct bonding *bond)
-{
-	write_lock_bh(&bond->lock);
-	bond->kill_timers = 1;
-	write_unlock_bh(&bond->lock);
-
-	if (bond->params.miimon && delayed_work_pending(&bond->mii_work))
-		cancel_delayed_work(&bond->mii_work);
-
-	if (bond->params.arp_interval && delayed_work_pending(&bond->arp_work))
-		cancel_delayed_work(&bond->arp_work);
-
-	if (bond->params.mode == BOND_MODE_ALB &&
-	    delayed_work_pending(&bond->alb_work))
-		cancel_delayed_work(&bond->alb_work);
-
-	if (bond->params.mode == BOND_MODE_8023AD &&
-	    delayed_work_pending(&bond->ad_work))
-		cancel_delayed_work(&bond->ad_work);
-}
-
 static int __init bonding_init(void)
 {
 	int i;
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index b29330d..11b76b3 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -74,7 +74,7 @@ struct rw_semaphore bonding_rwsem;
  * "show" function for the bond_masters attribute.
  * The class parameter is ignored.
  */
-static ssize_t bonding_show_bonds(struct class *cls, char *buffer)
+static ssize_t bonding_show_bonds(struct class *cls, char *buf)
 {
 	int res = 0;
 	struct bonding *bond;
@@ -86,14 +86,13 @@ static ssize_t bonding_show_bonds(struct class *cls, char *buffer)
 			/* not enough space for another interface name */
 			if ((PAGE_SIZE - res) > 10)
 				res = PAGE_SIZE - 10;
-			res += sprintf(buffer + res, "++more++");
+			res += sprintf(buf + res, "++more++ ");
 			break;
 		}
-		res += sprintf(buffer + res, "%s ",
-			       bond->dev->name);
+		res += sprintf(buf + res, "%s ", bond->dev->name);
 	}
-	res += sprintf(buffer + res, "\n");
-	res++;
+	if (res)
+		buf[res-1] = '\n'; /* eat the leftover space */
 	up_read(&(bonding_rwsem));
 	return res;
 }
@@ -235,14 +234,14 @@ static ssize_t bonding_show_slaves(struct device *d,
 			/* not enough space for another interface name */
 			if ((PAGE_SIZE - res) > 10)
 				res = PAGE_SIZE - 10;
-			res += sprintf(buf + res, "++more++");
+			res += sprintf(buf + res, "++more++ ");
 			break;
 		}
 		res += sprintf(buf + res, "%s ", slave->dev->name);
 	}
 	read_unlock(&bond->lock);
-	res += sprintf(buf + res, "\n");
-	res++;
+	if (res)
+		buf[res-1] = '\n'; /* eat the leftover space */
 	return res;
 }
 
@@ -406,7 +405,7 @@ static ssize_t bonding_show_mode(struct device *d,
 
 	return sprintf(buf, "%s %d\n",
 			bond_mode_tbl[bond->params.mode].modename,
-			bond->params.mode) + 1;
+			bond->params.mode);
 }
 
 static ssize_t bonding_store_mode(struct device *d,
@@ -457,20 +456,11 @@ static ssize_t bonding_show_xmit_hash(struct device *d,
 				      struct device_attribute *attr,
 				      char *buf)
 {
-	int count;
 	struct bonding *bond = to_bond(d);
 
-	if ((bond->params.mode != BOND_MODE_XOR) &&
-	    (bond->params.mode != BOND_MODE_8023AD)) {
-		// Not Applicable
-		count = sprintf(buf, "NA\n") + 1;
-	} else {
-		count = sprintf(buf, "%s %d\n",
-			xmit_hashtype_tbl[bond->params.xmit_policy].modename,
-			bond->params.xmit_policy) + 1;
-	}
-
-	return count;
+	return sprintf(buf, "%s %d\n",
+		       xmit_hashtype_tbl[bond->params.xmit_policy].modename,
+		       bond->params.xmit_policy);
 }
 
 static ssize_t bonding_store_xmit_hash(struct device *d,
@@ -488,15 +478,6 @@ static ssize_t bonding_store_xmit_hash(struct device *d,
 		goto out;
 	}
 
-	if ((bond->params.mode != BOND_MODE_XOR) &&
-	    (bond->params.mode != BOND_MODE_8023AD)) {
-		printk(KERN_ERR DRV_NAME
-		       "%s: Transmit hash policy is irrelevant in this mode.\n",
-		       bond->dev->name);
-		ret = -EPERM;
-		goto out;
-	}
-
 	new_value = bond_parse_parm((char *)buf, xmit_hashtype_tbl);
 	if (new_value < 0)  {
 		printk(KERN_ERR DRV_NAME
@@ -527,7 +508,7 @@ static ssize_t bonding_show_arp_validate(struct device *d,
 
 	return sprintf(buf, "%s %d\n",
 		       arp_validate_tbl[bond->params.arp_validate].modename,
-		       bond->params.arp_validate) + 1;
+		       bond->params.arp_validate);
 }
 
 static ssize_t bonding_store_arp_validate(struct device *d,
@@ -627,7 +608,7 @@ static ssize_t bonding_show_arp_interval(struct device *d,
 {
 	struct bonding *bond = to_bond(d);
 
-	return sprintf(buf, "%d\n", bond->params.arp_interval) + 1;
+	return sprintf(buf, "%d\n", bond->params.arp_interval);
 }
 
 static ssize_t bonding_store_arp_interval(struct device *d,
@@ -712,9 +693,7 @@ static ssize_t bonding_show_arp_targets(struct device *d,
 			       NIPQUAD(bond->params.arp_targets[i]));
 	}
 	if (res)
-		res--;  /* eat the leftover space */
-	res += sprintf(buf + res, "\n");
-	res++;
+		buf[res-1] = '\n'; /* eat the leftover space */
 	return res;
 }
 
@@ -815,7 +794,7 @@ static ssize_t bonding_show_downdelay(struct device *d,
 {
 	struct bonding *bond = to_bond(d);
 
-	return sprintf(buf, "%d\n", bond->params.downdelay * bond->params.miimon) + 1;
+	return sprintf(buf, "%d\n", bond->params.downdelay * bond->params.miimon);
 }
 
 static ssize_t bonding_store_downdelay(struct device *d,
@@ -872,7 +851,7 @@ static ssize_t bonding_show_updelay(struct device *d,
 {
 	struct bonding *bond = to_bond(d);
 
-	return sprintf(buf, "%d\n", bond->params.updelay * bond->params.miimon) + 1;
+	return sprintf(buf, "%d\n", bond->params.updelay * bond->params.miimon);
 
 }
 
@@ -936,7 +915,7 @@ static ssize_t bonding_show_lacp(struct device *d,
 
 	return sprintf(buf, "%s %d\n",
 		bond_lacp_tbl[bond->params.lacp_fast].modename,
-		bond->params.lacp_fast) + 1;
+		bond->params.lacp_fast);
 }
 
 static ssize_t bonding_store_lacp(struct device *d,
@@ -992,7 +971,7 @@ static ssize_t bonding_show_miimon(struct device *d,
 {
 	struct bonding *bond = to_bond(d);
 
-	return sprintf(buf, "%d\n", bond->params.miimon) + 1;
+	return sprintf(buf, "%d\n", bond->params.miimon);
 }
 
 static ssize_t bonding_store_miimon(struct device *d,
@@ -1083,9 +1062,7 @@ static ssize_t bonding_show_primary(struct device *d,
 	struct bonding *bond = to_bond(d);
 
 	if (bond->primary_slave)
-		count = sprintf(buf, "%s\n", bond->primary_slave->dev->name) + 1;
-	else
-		count = sprintf(buf, "\n") + 1;
+		count = sprintf(buf, "%s\n", bond->primary_slave->dev->name);
 
 	return count;
 }
@@ -1149,7 +1126,7 @@ static ssize_t bonding_show_carrier(struct device *d,
 {
 	struct bonding *bond = to_bond(d);
 
-	return sprintf(buf, "%d\n", bond->params.use_carrier) + 1;
+	return sprintf(buf, "%d\n", bond->params.use_carrier);
 }
 
 static ssize_t bonding_store_carrier(struct device *d,
@@ -1191,16 +1168,14 @@ static ssize_t bonding_show_active_slave(struct device *d,
 {
 	struct slave *curr;
 	struct bonding *bond = to_bond(d);
-	int count;
+	int count = 0;
 
 	read_lock(&bond->curr_slave_lock);
 	curr = bond->curr_active_slave;
 	read_unlock(&bond->curr_slave_lock);
 
 	if (USES_PRIMARY(bond->params.mode) && curr)
-		count = sprintf(buf, "%s\n", curr->dev->name) + 1;
-	else
-		count = sprintf(buf, "\n") + 1;
+		count = sprintf(buf, "%s\n", curr->dev->name);
 	return count;
 }
 
@@ -1295,7 +1270,7 @@ static ssize_t bonding_show_mii_status(struct device *d,
 	curr = bond->curr_active_slave;
 	read_unlock(&bond->curr_slave_lock);
 
-	return sprintf(buf, "%s\n", (curr) ? "up" : "down") + 1;
+	return sprintf(buf, "%s\n", (curr) ? "up" : "down");
 }
 static DEVICE_ATTR(mii_status, S_IRUGO, bonding_show_mii_status, NULL);
 
@@ -1312,10 +1287,8 @@ static ssize_t bonding_show_ad_aggregator(struct device *d,
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
-		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0 : ad_info.aggregator_id) + 1;
+		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0 : ad_info.aggregator_id);
 	}
-	else
-		count = sprintf(buf, "\n") + 1;
 
 	return count;
 }
@@ -1334,10 +1307,8 @@ static ssize_t bonding_show_ad_num_ports(struct device *d,
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
-		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0: ad_info.ports) + 1;
+		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0: ad_info.ports);
 	}
-	else
-		count = sprintf(buf, "\n") + 1;
 
 	return count;
 }
@@ -1356,10 +1327,8 @@ static ssize_t bonding_show_ad_actor_key(struct device *d,
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
-		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0 : ad_info.actor_key) + 1;
+		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0 : ad_info.actor_key);
 	}
-	else
-		count = sprintf(buf, "\n") + 1;
 
 	return count;
 }
@@ -1378,10 +1347,8 @@ static ssize_t bonding_show_ad_partner_key(struct device *d,
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
-		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0 : ad_info.partner_key) + 1;
+		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0 : ad_info.partner_key);
 	}
-	else
-		count = sprintf(buf, "\n") + 1;
 
 	return count;
 }
@@ -1403,12 +1370,9 @@ static ssize_t bonding_show_ad_partner_mac(struct device *d,
 		struct ad_info ad_info;
 		if (!bond_3ad_get_active_agg_info(bond, &ad_info)) {
 			count = sprintf(buf,"%s\n",
-					print_mac(mac, ad_info.partner_system))
-				+ 1;
+					print_mac(mac, ad_info.partner_system));
 		}
 	}
-	else
-		count = sprintf(buf, "\n") + 1;
 
 	return count;
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 61c1b45..e1e4734 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,8 +22,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.2.1"
-#define DRV_RELDATE	"October 15, 2007"
+#define DRV_VERSION	"3.2.3"
+#define DRV_RELDATE	"December 6, 2007"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index 5e1bc0d..6e12bf4 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -1937,6 +1937,10 @@
 
 #define A_XGM_RXFIFO_CFG 0x884
 
+#define S_RXFIFO_EMPTY    31
+#define V_RXFIFO_EMPTY(x) ((x) << S_RXFIFO_EMPTY)
+#define F_RXFIFO_EMPTY    V_RXFIFO_EMPTY(1U)
+
 #define S_RXFIFOPAUSEHWM    17
 #define M_RXFIFOPAUSEHWM    0xfff
 
@@ -1961,6 +1965,10 @@
 
 #define A_XGM_TXFIFO_CFG 0x888
 
+#define S_UNDERUNFIX    22
+#define V_UNDERUNFIX(x) ((x) << S_UNDERUNFIX)
+#define F_UNDERUNFIX    V_UNDERUNFIX(1U)
+
 #define S_TXIPG    13
 #define M_TXIPG    0xff
 #define V_TXIPG(x) ((x) << S_TXIPG)
@@ -2034,10 +2042,27 @@
 #define V_XAUIIMP(x) ((x) << S_XAUIIMP)
 
 #define A_XGM_RX_MAX_PKT_SIZE 0x8a8
-#define A_XGM_RX_MAX_PKT_SIZE_ERR_CNT 0x9a4
+
+#define S_RXMAXFRAMERSIZE    17
+#define M_RXMAXFRAMERSIZE    0x3fff
+#define V_RXMAXFRAMERSIZE(x) ((x) << S_RXMAXFRAMERSIZE)
+#define G_RXMAXFRAMERSIZE(x) (((x) >> S_RXMAXFRAMERSIZE) & M_RXMAXFRAMERSIZE)
+
+#define S_RXENFRAMER    14
+#define V_RXENFRAMER(x) ((x) << S_RXENFRAMER)
+#define F_RXENFRAMER    V_RXENFRAMER(1U)
+
+#define S_RXMAXPKTSIZE    0
+#define M_RXMAXPKTSIZE    0x3fff
+#define V_RXMAXPKTSIZE(x) ((x) << S_RXMAXPKTSIZE)
+#define G_RXMAXPKTSIZE(x) (((x) >> S_RXMAXPKTSIZE) & M_RXMAXPKTSIZE)
 
 #define A_XGM_RESET_CTRL 0x8ac
 
+#define S_XGMAC_STOP_EN    4
+#define V_XGMAC_STOP_EN(x) ((x) << S_XGMAC_STOP_EN)
+#define F_XGMAC_STOP_EN    V_XGMAC_STOP_EN(1U)
+
 #define S_XG2G_RESET_    3
 #define V_XG2G_RESET_(x) ((x) << S_XG2G_RESET_)
 #define F_XG2G_RESET_    V_XG2G_RESET_(1U)
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index d4ee00d..522834c 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -447,8 +447,8 @@ static const struct adapter_info t3_adap_info[] = {
 	 &mi1_mdio_ops, "Chelsio T302"},
 	{1, 0, 0, 0,
 	 F_GPIO1_OEN | F_GPIO6_OEN | F_GPIO7_OEN | F_GPIO10_OEN |
-	 F_GPIO1_OUT_VAL | F_GPIO6_OUT_VAL | F_GPIO10_OUT_VAL, 0,
-	 SUPPORTED_10000baseT_Full | SUPPORTED_AUI,
+	 F_GPIO11_OEN | F_GPIO1_OUT_VAL | F_GPIO6_OUT_VAL | F_GPIO10_OUT_VAL,
+	 0, SUPPORTED_10000baseT_Full | SUPPORTED_AUI,
 	 &mi1_mdio_ext_ops, "Chelsio T310"},
 	{2, 0, 0, 0,
 	 F_GPIO1_OEN | F_GPIO2_OEN | F_GPIO4_OEN | F_GPIO5_OEN | F_GPIO6_OEN |
@@ -2613,7 +2613,7 @@ static void __devinit init_mtus(unsigned short mtus[])
 	 * it can accomodate max size TCP/IP headers when SACK and timestamps
 	 * are enabled and still have at least 8 bytes of payload.
 	 */
-	mtus[1] = 88;
+	mtus[0] = 88;
 	mtus[1] = 88;
 	mtus[2] = 256;
 	mtus[3] = 512;
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index eeb766a..efcf09a 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -106,6 +106,7 @@ int t3_mac_reset(struct cmac *mac)
 	t3_set_reg_field(adap, A_XGM_RXFIFO_CFG + oft,
 			 F_RXSTRFRWRD | F_DISERRFRAMES,
 			 uses_xaui(adap) ? 0 : F_RXSTRFRWRD);
+	t3_set_reg_field(adap, A_XGM_TXFIFO_CFG + oft, 0, F_UNDERUNFIX);
 
 	if (uses_xaui(adap)) {
 		if (adap->params.rev == 0) {
@@ -124,7 +125,11 @@ int t3_mac_reset(struct cmac *mac)
 			xaui_serdes_reset(mac);
 	}
 
-	val = F_MAC_RESET_;
+	t3_set_reg_field(adap, A_XGM_RX_MAX_PKT_SIZE + oft,
+			 V_RXMAXFRAMERSIZE(M_RXMAXFRAMERSIZE),
+			 V_RXMAXFRAMERSIZE(MAX_FRAME_SIZE) | F_RXENFRAMER);
+	val = F_MAC_RESET_ | F_XGMAC_STOP_EN;
+
 	if (is_10G(adap))
 		val |= F_PCS_RESET_;
 	else if (uses_xaui(adap))
@@ -313,8 +318,9 @@ static int rx_fifo_hwm(int mtu)
 
 int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 {
-	int hwm, lwm;
-	unsigned int thres, v;
+	int hwm, lwm, divisor;
+	int ipg;
+	unsigned int thres, v, reg;
 	struct adapter *adap = mac->adapter;
 
 	/*
@@ -335,27 +341,32 @@ int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 	hwm = min(hwm, MAC_RXFIFO_SIZE - 8192);
 	lwm = min(3 * (int)mtu, MAC_RXFIFO_SIZE / 4);
 
-	if (adap->params.rev == T3_REV_B2 &&
+	if (adap->params.rev >= T3_REV_B2 &&
 	    (t3_read_reg(adap, A_XGM_RX_CTRL + mac->offset) & F_RXEN)) {
 		disable_exact_filters(mac);
 		v = t3_read_reg(adap, A_XGM_RX_CFG + mac->offset);
 		t3_set_reg_field(adap, A_XGM_RX_CFG + mac->offset,
 				 F_ENHASHMCAST | F_COPYALLFRAMES, F_DISBCAST);
 
-		/* drain rx FIFO */
-		if (t3_wait_op_done(adap,
-				    A_XGM_RX_MAX_PKT_SIZE_ERR_CNT +
-				    mac->offset,
-				    1 << 31, 1, 20, 5)) {
+		reg = adap->params.rev == T3_REV_B2 ?
+			A_XGM_RX_MAX_PKT_SIZE_ERR_CNT : A_XGM_RXFIFO_CFG;
+
+		/* drain RX FIFO */
+		if (t3_wait_op_done(adap, reg + mac->offset,
+				    F_RXFIFO_EMPTY, 1, 20, 5)) {
 			t3_write_reg(adap, A_XGM_RX_CFG + mac->offset, v);
 			enable_exact_filters(mac);
 			return -EIO;
 		}
-		t3_write_reg(adap, A_XGM_RX_MAX_PKT_SIZE + mac->offset, mtu);
+		t3_set_reg_field(adap, A_XGM_RX_MAX_PKT_SIZE + mac->offset,
+				 V_RXMAXPKTSIZE(M_RXMAXPKTSIZE),
+				 V_RXMAXPKTSIZE(mtu));
 		t3_write_reg(adap, A_XGM_RX_CFG + mac->offset, v);
 		enable_exact_filters(mac);
 	} else
-		t3_write_reg(adap, A_XGM_RX_MAX_PKT_SIZE + mac->offset, mtu);
+		t3_set_reg_field(adap, A_XGM_RX_MAX_PKT_SIZE + mac->offset,
+				 V_RXMAXPKTSIZE(M_RXMAXPKTSIZE),
+				 V_RXMAXPKTSIZE(mtu));
 
 	/*
 	 * Adjust the PAUSE frame watermarks.  We always set the LWM, and the
@@ -379,13 +390,16 @@ int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 		thres /= 10;
 	thres = mtu > thres ? (mtu - thres + 7) / 8 : 0;
 	thres = max(thres, 8U);	/* need at least 8 */
+	ipg = (adap->params.rev == T3_REV_C) ? 0 : 1;
 	t3_set_reg_field(adap, A_XGM_TXFIFO_CFG + mac->offset,
 			 V_TXFIFOTHRESH(M_TXFIFOTHRESH) | V_TXIPG(M_TXIPG),
-			 V_TXFIFOTHRESH(thres) | V_TXIPG(1));
+			 V_TXFIFOTHRESH(thres) | V_TXIPG(ipg));
 
-	if (adap->params.rev > 0)
+	if (adap->params.rev > 0) {
+		divisor = (adap->params.rev == T3_REV_C) ? 64 : 8;
 		t3_write_reg(adap, A_XGM_PAUSE_TIMER + mac->offset,
-			     (hwm - lwm) * 4 / 8);
+			     (hwm - lwm) * 4 / divisor);
+	}
 	t3_write_reg(adap, A_XGM_TX_PAUSE_QUANTA + mac->offset,
 		     MAC_RXFIFO_SIZE * 4 * 8 / 512);
 	return 0;
@@ -522,7 +536,7 @@ int t3b2_mac_watchdog_task(struct cmac *mac)
 		goto rxcheck;
 	}
 
-	if ((tx_tcnt != mac->tx_tcnt) && (mac->tx_xcnt == 0))  {
+	if ((tx_tcnt != mac->tx_tcnt) && (mac->tx_xcnt == 0)) {
 		if (mac->toggle_cnt > 4) {
 			status = 2;
 			goto out;
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 3dbaec6..e1c8a0d 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2214,13 +2214,11 @@ static void e100_get_drvinfo(struct net_device *netdev,
 	strcpy(info->bus_info, pci_name(nic->pdev));
 }
 
+#define E100_PHY_REGS 0x1C
 static int e100_get_regs_len(struct net_device *netdev)
 {
 	struct nic *nic = netdev_priv(netdev);
-#define E100_PHY_REGS		0x1C
-#define E100_REGS_LEN		1 + E100_PHY_REGS + \
-	sizeof(nic->mem->dump_buf) / sizeof(u32)
-	return E100_REGS_LEN * sizeof(u32);
+	return 1 + E100_PHY_REGS + sizeof(nic->mem->dump_buf);
 }
 
 static void e100_get_regs(struct net_device *netdev,
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 667f18b..b83ccce 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1923,7 +1923,7 @@ e1000_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
 	switch (stringset) {
 	case ETH_SS_TEST:
 		memcpy(data, *e1000_gstrings_test,
-			E1000_TEST_LEN*ETH_GSTRING_LEN);
+			sizeof(e1000_gstrings_test));
 		break;
 	case ETH_SS_STATS:
 		for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 6a39784..87f9da1 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1739,7 +1739,7 @@ static void e1000_get_strings(struct net_device *netdev, u32 stringset,
 	switch (stringset) {
 	case ETH_SS_TEST:
 		memcpy(data, *e1000_gstrings_test,
-			E1000_TEST_LEN*ETH_GSTRING_LEN);
+			sizeof(e1000_gstrings_test));
 		break;
 	case ETH_SS_STATS:
 		for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index eb0718b..cb06280 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies.
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
@@ -402,7 +407,7 @@ static u32 __emac_calc_base_mr1(struct emac_instance *dev, int tx_size, int rx_s
 static u32 __emac4_calc_base_mr1(struct emac_instance *dev, int tx_size, int rx_size)
 {
 	u32 ret = EMAC_MR1_VLE | EMAC_MR1_IST | EMAC4_MR1_TR |
-		EMAC4_MR1_OBCI(dev->opb_bus_freq);
+		EMAC4_MR1_OBCI(dev->opb_bus_freq / 1000000);
 
 	DBG2(dev, "__emac4_calc_base_mr1" NL);
 
@@ -464,26 +469,34 @@ static int emac_configure(struct emac_instance *dev)
 {
 	struct emac_regs __iomem *p = dev->emacp;
 	struct net_device *ndev = dev->ndev;
-	int tx_size, rx_size;
+	int tx_size, rx_size, link = netif_carrier_ok(dev->ndev);
 	u32 r, mr1 = 0;
 
 	DBG(dev, "configure" NL);
 
-	if (emac_reset(dev) < 0)
+	if (!link) {
+		out_be32(&p->mr1, in_be32(&p->mr1)
+			 | EMAC_MR1_FDE | EMAC_MR1_ILE);
+		udelay(100);
+	} else if (emac_reset(dev) < 0)
 		return -ETIMEDOUT;
 
 	if (emac_has_feature(dev, EMAC_FTR_HAS_TAH))
 		tah_reset(dev->tah_dev);
 
-	DBG(dev, " duplex = %d, pause = %d, asym_pause = %d\n",
-	    dev->phy.duplex, dev->phy.pause, dev->phy.asym_pause);
+	DBG(dev, " link = %d duplex = %d, pause = %d, asym_pause = %d\n",
+	    link, dev->phy.duplex, dev->phy.pause, dev->phy.asym_pause);
 
 	/* Default fifo sizes */
 	tx_size = dev->tx_fifo_size;
 	rx_size = dev->rx_fifo_size;
 
+	/* No link, force loopback */
+	if (!link)
+		mr1 = EMAC_MR1_FDE | EMAC_MR1_ILE;
+
 	/* Check for full duplex */
-	if (dev->phy.duplex == DUPLEX_FULL)
+	else if (dev->phy.duplex == DUPLEX_FULL)
 		mr1 |= EMAC_MR1_FDE | EMAC_MR1_MWSW_001;
 
 	/* Adjust fifo sizes, mr1 and timeouts based on link speed */
@@ -703,7 +716,7 @@ static int __emac_mdio_read(struct emac_instance *dev, u8 id, u8 reg)
 		r = EMAC_STACR_BASE(dev->opb_bus_freq);
 	if (emac_has_feature(dev, EMAC_FTR_STACR_OC_INVERT))
 		r |= EMAC_STACR_OC;
-	if (emac_has_feature(dev, EMAC_FTR_HAS_AXON_STACR))
+	if (emac_has_feature(dev, EMAC_FTR_HAS_NEW_STACR))
 		r |= EMACX_STACR_STAC_READ;
 	else
 		r |= EMAC_STACR_STAC_READ;
@@ -775,7 +788,7 @@ static void __emac_mdio_write(struct emac_instance *dev, u8 id, u8 reg,
 		r = EMAC_STACR_BASE(dev->opb_bus_freq);
 	if (emac_has_feature(dev, EMAC_FTR_STACR_OC_INVERT))
 		r |= EMAC_STACR_OC;
-	if (emac_has_feature(dev, EMAC_FTR_HAS_AXON_STACR))
+	if (emac_has_feature(dev, EMAC_FTR_HAS_NEW_STACR))
 		r |= EMACX_STACR_STAC_WRITE;
 	else
 		r |= EMAC_STACR_STAC_WRITE;
@@ -1165,9 +1178,9 @@ static void emac_link_timer(struct work_struct *work)
 		link_poll_interval = PHY_POLL_LINK_ON;
 	} else {
 		if (netif_carrier_ok(dev->ndev)) {
-			emac_reinitialize(dev);
 			netif_carrier_off(dev->ndev);
 			netif_tx_disable(dev->ndev);
+			emac_reinitialize(dev);
 			emac_print_link_status(dev);
 		}
 		link_poll_interval = PHY_POLL_LINK_OFF;
@@ -2434,7 +2447,7 @@ static int __devinit emac_init_config(struct emac_instance *dev)
 	if (emac_read_uint_prop(np, "tah-device", &dev->tah_ph, 0))
 		dev->tah_ph = 0;
 	if (emac_read_uint_prop(np, "tah-channel", &dev->tah_port, 0))
-		dev->tah_ph = 0;
+		dev->tah_port = 0;
 	if (emac_read_uint_prop(np, "mdio-device", &dev->mdio_ph, 0))
 		dev->mdio_ph = 0;
 	if (emac_read_uint_prop(np, "zmii-device", &dev->zmii_ph, 0))
@@ -2472,16 +2485,19 @@ static int __devinit emac_init_config(struct emac_instance *dev)
 	/* Check EMAC version */
 	if (of_device_is_compatible(np, "ibm,emac4"))
 		dev->features |= EMAC_FTR_EMAC4;
-	if (of_device_is_compatible(np, "ibm,emac-axon")
-	    || of_device_is_compatible(np, "ibm,emac-440epx"))
-		dev->features |= EMAC_FTR_HAS_AXON_STACR
-			| EMAC_FTR_STACR_OC_INVERT;
-	if (of_device_is_compatible(np, "ibm,emac-440spe"))
+
+	/* Fixup some feature bits based on the device tree */
+	if (of_get_property(np, "has-inverted-stacr-oc", NULL))
 		dev->features |= EMAC_FTR_STACR_OC_INVERT;
+	if (of_get_property(np, "has-new-stacr-staopc", NULL))
+		dev->features |= EMAC_FTR_HAS_NEW_STACR;
 
-	/* Fixup some feature bits based on the device tree and verify
-	 * we have support for them compiled in
-	 */
+	/* CAB lacks the appropriate properties */
+	if (of_device_is_compatible(np, "ibm,emac-axon"))
+		dev->features |= EMAC_FTR_HAS_NEW_STACR |
+			EMAC_FTR_STACR_OC_INVERT;
+
+	/* Enable TAH/ZMII/RGMII features as found */
 	if (dev->tah_ph != 0) {
 #ifdef CONFIG_IBM_NEW_EMAC_TAH
 		dev->features |= EMAC_FTR_HAS_TAH;
@@ -2539,6 +2555,10 @@ static int __devinit emac_probe(struct of_device *ofdev,
 	struct device_node **blist = NULL;
 	int err, i;
 
+	/* Skip unused/unwired EMACS */
+	if (of_get_property(np, "unused", NULL))
+		return -ENODEV;
+
 	/* Find ourselves in the bootlist if we are there */
 	for (i = 0; i < EMAC_BOOT_LIST_SIZE; i++)
 		if (emac_boot_list[i] == np)
diff --git a/drivers/net/ibm_newemac/core.h b/drivers/net/ibm_newemac/core.h
index a010b24..4e74d82 100644
--- a/drivers/net/ibm_newemac/core.h
+++ b/drivers/net/ibm_newemac/core.h
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies.
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
@@ -293,9 +298,9 @@ struct emac_instance {
  */
 #define EMAC_FTR_HAS_RGMII		0x00000020
 /*
- * Set if we have axon-type STACR
+ * Set if we have new type STACR with STAOPC
  */
-#define EMAC_FTR_HAS_AXON_STACR		0x00000040
+#define EMAC_FTR_HAS_NEW_STACR		0x00000040
 
 
 /* Right now, we don't quite handle the always/possible masks on the
@@ -307,7 +312,7 @@ enum {
 
 	EMAC_FTRS_POSSIBLE	=
 #ifdef CONFIG_IBM_NEW_EMAC_EMAC4
-	    EMAC_FTR_EMAC4	| EMAC_FTR_HAS_AXON_STACR	|
+	    EMAC_FTR_EMAC4	| EMAC_FTR_HAS_NEW_STACR	|
 	    EMAC_FTR_STACR_OC_INVERT	|
 #endif
 #ifdef CONFIG_IBM_NEW_EMAC_TAH
diff --git a/drivers/net/ibm_newemac/debug.c b/drivers/net/ibm_newemac/debug.c
index 170524e..a2fc660 100644
--- a/drivers/net/ibm_newemac/debug.c
+++ b/drivers/net/ibm_newemac/debug.c
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, debug print routines.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
diff --git a/drivers/net/ibm_newemac/debug.h b/drivers/net/ibm_newemac/debug.h
index 1dd2dcb..b631842 100644
--- a/drivers/net/ibm_newemac/debug.h
+++ b/drivers/net/ibm_newemac/debug.h
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, debug print routines.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
diff --git a/drivers/net/ibm_newemac/emac.h b/drivers/net/ibm_newemac/emac.h
index bef92ef..91cb096 100644
--- a/drivers/net/ibm_newemac/emac.h
+++ b/drivers/net/ibm_newemac/emac.h
@@ -3,6 +3,11 @@
  *
  * Register definitions for PowerPC 4xx on-chip ethernet contoller
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies.
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ibm_newemac/mal.c
index 9a88f71..6869f08 100644
--- a/drivers/net/ibm_newemac/mal.c
+++ b/drivers/net/ibm_newemac/mal.c
@@ -3,6 +3,11 @@
  *
  * Memory Access Layer (MAL) support
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies.
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
diff --git a/drivers/net/ibm_newemac/mal.h b/drivers/net/ibm_newemac/mal.h
index 784edb8..eaa7262 100644
--- a/drivers/net/ibm_newemac/mal.h
+++ b/drivers/net/ibm_newemac/mal.h
@@ -3,6 +3,11 @@
  *
  * Memory Access Layer (MAL) support
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies.
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
diff --git a/drivers/net/ibm_newemac/phy.c b/drivers/net/ibm_newemac/phy.c
index aa1f0dd..37bfeea 100644
--- a/drivers/net/ibm_newemac/phy.c
+++ b/drivers/net/ibm_newemac/phy.c
@@ -8,6 +8,11 @@
  * This file should be shared with other drivers or eventually
  * merged as the "low level" part of miilib
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * (c) 2003, Benjamin Herrenscmidt (benh@kernel.crashing.org)
  * (c) 2004-2005, Eugene Surovegin <ebs@ebshome.net>
  *
@@ -306,8 +311,84 @@ static struct mii_phy_def cis8201_phy_def = {
 	.ops		= &cis8201_phy_ops
 };
 
+static struct mii_phy_def bcm5248_phy_def = {
+
+	.phy_id		= 0x0143bc00,
+	.phy_id_mask	= 0x0ffffff0,
+	.name		= "BCM5248 10/100 SMII Ethernet",
+	.ops		= &generic_phy_ops
+};
+
+static int m88e1111_init(struct mii_phy *phy)
+{
+	pr_debug("%s: Marvell 88E1111 Ethernet\n", __FUNCTION__);
+	phy_write(phy, 0x14, 0x0ce3);
+	phy_write(phy, 0x18, 0x4101);
+	phy_write(phy, 0x09, 0x0e00);
+	phy_write(phy, 0x04, 0x01e1);
+	phy_write(phy, 0x00, 0x9140);
+	phy_write(phy, 0x00, 0x1140);
+
+	return  0;
+}
+
+static int et1011c_init(struct mii_phy *phy)
+{
+	u16 reg_short;
+
+	reg_short = (u16)(phy_read(phy, 0x16));
+	reg_short &= ~(0x7);
+	reg_short |= 0x6;	/* RGMII Trace Delay*/
+	phy_write(phy, 0x16, reg_short);
+
+	reg_short = (u16)(phy_read(phy, 0x17));
+	reg_short &= ~(0x40);
+	phy_write(phy, 0x17, reg_short);
+
+	phy_write(phy, 0x1c, 0x74f0);
+	return 0;
+}
+
+static struct mii_phy_ops et1011c_phy_ops = {
+	.init		= et1011c_init,
+	.setup_aneg	= genmii_setup_aneg,
+	.setup_forced	= genmii_setup_forced,
+	.poll_link	= genmii_poll_link,
+	.read_link	= genmii_read_link
+};
+
+static struct mii_phy_def et1011c_phy_def = {
+	.phy_id		= 0x0282f000,
+	.phy_id_mask	= 0x0fffff00,
+	.name		= "ET1011C Gigabit Ethernet",
+	.ops		= &et1011c_phy_ops
+};
+
+
+
+
+
+static struct mii_phy_ops m88e1111_phy_ops = {
+	.init		= m88e1111_init,
+	.setup_aneg	= genmii_setup_aneg,
+	.setup_forced	= genmii_setup_forced,
+	.poll_link	= genmii_poll_link,
+	.read_link	= genmii_read_link
+};
+
+static struct mii_phy_def m88e1111_phy_def = {
+
+	.phy_id		= 0x01410CC0,
+	.phy_id_mask	= 0x0ffffff0,
+	.name		= "Marvell 88E1111 Ethernet",
+	.ops		= &m88e1111_phy_ops,
+};
+
 static struct mii_phy_def *mii_phy_table[] = {
+	&et1011c_phy_def,
 	&cis8201_phy_def,
+	&bcm5248_phy_def,
+	&m88e1111_phy_def,
 	&genmii_phy_def,
 	NULL
 };
diff --git a/drivers/net/ibm_newemac/phy.h b/drivers/net/ibm_newemac/phy.h
index 6feca26..1b65c81 100644
--- a/drivers/net/ibm_newemac/phy.h
+++ b/drivers/net/ibm_newemac/phy.h
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, PHY support
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Benjamin Herrenschmidt <benh@kernel.crashing.org>
  * February 2003
  *
diff --git a/drivers/net/ibm_newemac/rgmii.c b/drivers/net/ibm_newemac/rgmii.c
index de41695..9bc1132 100644
--- a/drivers/net/ibm_newemac/rgmii.c
+++ b/drivers/net/ibm_newemac/rgmii.c
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, RGMII bridge support.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies.
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
@@ -140,7 +145,7 @@ void rgmii_get_mdio(struct of_device *ofdev, int input)
 
 	RGMII_DBG2(dev, "get_mdio(%d)" NL, input);
 
-	if (dev->type != RGMII_AXON)
+	if (!(dev->flags & EMAC_RGMII_FLAG_HAS_MDIO))
 		return;
 
 	mutex_lock(&dev->lock);
@@ -161,7 +166,7 @@ void rgmii_put_mdio(struct of_device *ofdev, int input)
 
 	RGMII_DBG2(dev, "put_mdio(%d)" NL, input);
 
-	if (dev->type != RGMII_AXON)
+	if (!(dev->flags & EMAC_RGMII_FLAG_HAS_MDIO))
 		return;
 
 	fer = in_be32(&p->fer);
@@ -250,11 +255,13 @@ static int __devinit rgmii_probe(struct of_device *ofdev,
 		goto err_free;
 	}
 
-	/* Check for RGMII type */
+	/* Check for RGMII flags */
+	if (of_get_property(ofdev->node, "has-mdio", NULL))
+		dev->flags |= EMAC_RGMII_FLAG_HAS_MDIO;
+
+	/* CAB lacks the right properties, fix this up */
 	if (of_device_is_compatible(ofdev->node, "ibm,rgmii-axon"))
-		dev->type = RGMII_AXON;
-	else
-		dev->type = RGMII_STANDARD;
+		dev->flags |= EMAC_RGMII_FLAG_HAS_MDIO;
 
 	DBG2(dev, " Boot FER = 0x%08x, SSR = 0x%08x\n",
 	     in_be32(&dev->base->fer), in_be32(&dev->base->ssr));
@@ -263,9 +270,9 @@ static int __devinit rgmii_probe(struct of_device *ofdev,
 	out_be32(&dev->base->fer, 0);
 
 	printk(KERN_INFO
-	       "RGMII %s %s initialized\n",
-	       dev->type == RGMII_STANDARD ? "standard" : "axon",
-	       ofdev->node->full_name);
+	       "RGMII %s initialized with%s MDIO support\n",
+	       ofdev->node->full_name,
+	       (dev->flags & EMAC_RGMII_FLAG_HAS_MDIO) ? "" : "out");
 
 	wmb();
 	dev_set_drvdata(&ofdev->dev, dev);
diff --git a/drivers/net/ibm_newemac/rgmii.h b/drivers/net/ibm_newemac/rgmii.h
index 5780683..c4a4b35 100644
--- a/drivers/net/ibm_newemac/rgmii.h
+++ b/drivers/net/ibm_newemac/rgmii.h
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, RGMII bridge support.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Based on ocp_zmii.h/ibm_emac_zmii.h
  * Armin Kuster akuster@mvista.com
  *
@@ -35,8 +40,9 @@ struct rgmii_regs {
 struct rgmii_instance {
 	struct rgmii_regs __iomem	*base;
 
-	/* Type of RGMII bridge */
-	int				type;
+	/* RGMII bridge flags */
+	int				flags;
+#define EMAC_RGMII_FLAG_HAS_MDIO	0x00000001
 
 	/* Only one EMAC whacks us at a time */
 	struct mutex			lock;
diff --git a/drivers/net/ibm_newemac/tah.c b/drivers/net/ibm_newemac/tah.c
index f161fb1..96417ad 100644
--- a/drivers/net/ibm_newemac/tah.c
+++ b/drivers/net/ibm_newemac/tah.c
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, TAH support.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright 2004 MontaVista Software, Inc.
  * Matt Porter <mporter@kernel.crashing.org>
  *
@@ -116,13 +121,14 @@ static int __devinit tah_probe(struct of_device *ofdev,
 		goto err_free;
 	}
 
+	dev_set_drvdata(&ofdev->dev, dev);
+
 	/* Initialize TAH and enable IPv4 checksum verification, no TSO yet */
 	tah_reset(ofdev);
 
 	printk(KERN_INFO
 	       "TAH %s initialized\n", ofdev->node->full_name);
 	wmb();
-	dev_set_drvdata(&ofdev->dev, dev);
 
 	return 0;
 
diff --git a/drivers/net/ibm_newemac/tah.h b/drivers/net/ibm_newemac/tah.h
index bc41853..a068b56 100644
--- a/drivers/net/ibm_newemac/tah.h
+++ b/drivers/net/ibm_newemac/tah.h
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, TAH support.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright 2004 MontaVista Software, Inc.
  * Matt Porter <mporter@kernel.crashing.org>
  *
diff --git a/drivers/net/ibm_newemac/zmii.c b/drivers/net/ibm_newemac/zmii.c
index 2219ec2..2ea472a 100644
--- a/drivers/net/ibm_newemac/zmii.c
+++ b/drivers/net/ibm_newemac/zmii.c
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, ZMII bridge support.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies.
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
@@ -83,12 +88,14 @@ int __devinit zmii_attach(struct of_device *ofdev, int input, int *mode)
 
 	ZMII_DBG(dev, "init(%d, %d)" NL, input, *mode);
 
-	if (!zmii_valid_mode(*mode))
+	if (!zmii_valid_mode(*mode)) {
 		/* Probably an EMAC connected to RGMII,
 		 * but it still may need ZMII for MDIO so
 		 * we don't fail here.
 		 */
+		dev->users++;
 		return 0;
+	}
 
 	mutex_lock(&dev->lock);
 
diff --git a/drivers/net/ibm_newemac/zmii.h b/drivers/net/ibm_newemac/zmii.h
index 82a9968..6c9beba 100644
--- a/drivers/net/ibm_newemac/zmii.h
+++ b/drivers/net/ibm_newemac/zmii.h
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, ZMII bridge support.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies.
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
diff --git a/drivers/net/s2io-regs.h b/drivers/net/s2io-regs.h
index 01f08d7..f25264f 100644
--- a/drivers/net/s2io-regs.h
+++ b/drivers/net/s2io-regs.h
@@ -66,6 +66,7 @@ struct XENA_dev_config {
 #define ADAPTER_STATUS_RC_PRC_QUIESCENT    vBIT(0xFF,16,8)
 #define ADAPTER_STATUS_MC_DRAM_READY       s2BIT(24)
 #define ADAPTER_STATUS_MC_QUEUES_READY     s2BIT(25)
+#define ADAPTER_STATUS_RIC_RUNNING         s2BIT(26)
 #define ADAPTER_STATUS_M_PLL_LOCK          s2BIT(30)
 #define ADAPTER_STATUS_P_PLL_LOCK          s2BIT(31)
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index d5113dd..121cb10 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.6"
+#define DRV_VERSION "2.0.26.10"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -1100,6 +1100,20 @@ static int init_nic(struct s2io_nic *nic)
 	msleep(500);
 	val64 = readq(&bar0->sw_reset);
 
+	/* Ensure that it's safe to access registers by checking
+	 * RIC_RUNNING bit is reset. Check is valid only for XframeII.
+	 */
+	if (nic->device_type == XFRAME_II_DEVICE) {
+		for (i = 0; i < 50; i++) {
+			val64 = readq(&bar0->adapter_status);
+			if (!(val64 & ADAPTER_STATUS_RIC_RUNNING))
+				break;
+			msleep(10);
+		}
+		if (i == 50)
+			return -ENODEV;
+	}
+
 	/*  Enable Receiving broadcasts */
 	add = &bar0->mac_cfg;
 	val64 = readq(&bar0->mac_cfg);
diff --git a/include/linux/if_bonding.h b/include/linux/if_bonding.h
index 84598fa..65c2d24 100644
--- a/include/linux/if_bonding.h
+++ b/include/linux/if_bonding.h
@@ -85,7 +85,8 @@
 
 /* hashing types */
 #define BOND_XMIT_POLICY_LAYER2		0 /* layer 2 (MAC only), default */
-#define BOND_XMIT_POLICY_LAYER34	1 /* layer 3+4 (IP ^ MAC) */
+#define BOND_XMIT_POLICY_LAYER34	1 /* layer 3+4 (IP ^ (TCP || UDP)) */
+#define BOND_XMIT_POLICY_LAYER23	2 /* layer 2+3 (IP ^ MAC) */
 
 typedef struct ifbond {
 	__s32 bond_mode;
