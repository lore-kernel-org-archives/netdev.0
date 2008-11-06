From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates for 2.6.29
Date: Thu, 6 Nov 2008 01:50:59 -0500
Message-ID: <20081106065059.GA19202@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753918AbYKFGvo@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'davem-next' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-next

to receive the following updates:

 Documentation/networking/bonding.txt |   52 +
 MAINTAINERS                          |    6 +
 drivers/net/Kconfig                  |   15 +
 drivers/net/Makefile                 |    1 +
 drivers/net/bonding/Makefile         |    3 +
 drivers/net/bonding/bond_3ad.c       |  326 ++++--
 drivers/net/bonding/bond_3ad.h       |   10 +-
 drivers/net/bonding/bond_alb.c       |   13 +-
 drivers/net/bonding/bond_ipv6.c      |  218 ++++
 drivers/net/bonding/bond_main.c      |   63 +-
 drivers/net/bonding/bond_sysfs.c     |   91 ++
 drivers/net/bonding/bonding.h        |   35 +-
 drivers/net/ehea/ehea.h              |    2 +-
 drivers/net/ehea/ehea_qmr.c          |   10 +-
 drivers/net/pcmcia/fmvj18x_cs.c      |   73 +-
 drivers/net/phy/smsc.c               |   28 +
 drivers/net/sfc/Kconfig              |    8 +
 drivers/net/sfc/Makefile             |    1 +
 drivers/net/sfc/boards.c             |  136 +++
 drivers/net/sfc/efx.c                |   32 +-
 drivers/net/sfc/efx.h                |   10 +
 drivers/net/sfc/enum.h               |    4 +-
 drivers/net/sfc/ethtool.c            |   15 +-
 drivers/net/sfc/falcon.c             |   23 +-
 drivers/net/sfc/falcon_hwdefs.h      |    1 -
 drivers/net/sfc/mdio_10g.c           |   35 +
 drivers/net/sfc/mdio_10g.h           |    7 +
 drivers/net/sfc/mtd.c                |  268 +++++
 drivers/net/sfc/net_driver.h         |    8 +
 drivers/net/sfc/sfe4001.c            |  116 +-
 drivers/net/sfc/spi.h                |   34 +-
 drivers/net/sfc/tenxpress.c          |   18 +-
 drivers/net/sfc/workarounds.h        |    2 +
 drivers/net/sfc/xfp_phy.c            |    9 +
 drivers/net/smsc911x.c               | 2091 ++++++++++++++++++++++++++++++++++
 drivers/net/smsc911x.h               |  394 +++++++
 drivers/net/usb/usbnet.c             |  140 ++-
 include/linux/smsc911x.h             |   42 +
 include/linux/usb/usbnet.h           |    6 +
 include/net/ndisc.h                  |   14 +
 net/ipv6/ndisc.c                     |   92 ++-
 41 files changed, 4144 insertions(+), 308 deletions(-)
 create mode 100644 drivers/net/bonding/bond_ipv6.c
 create mode 100644 drivers/net/sfc/mtd.c
 create mode 100644 drivers/net/smsc911x.c
 create mode 100644 drivers/net/smsc911x.h
 create mode 100644 include/linux/smsc911x.h

Ben Hutchings (5):
      sfc: Correct address of gPXE boot configuration in EEPROM
      sfc: Clean up non-volatile memory partitioning
      sfc: Expose flash region storing boot code as MTD
      sfc: Use lm87 and lm90 drivers for board temperature/power monitoring
      sfc: Do not reset when hardware monitor detects a fault

Brian Haley (1):
      bonding: send IPv6 neighbor advertisement on failover

Hannes Hering (1):
      ehea: Fix some whitespace issues

Jay Vosburgh (2):
      bonding: Fix ALB mode to balance traffic on VLANs
      bonding: alternate agg selection policies for 802.3ad

Komuro (1):
      fmvj18x_cs: write interrupt ack bit for lan and modem to work simultaneously.

Per Hallsmark (1):
      usbnet: enable more aggressive autosuspend

Steve Glendinning (1):
      SMSC LAN911x and LAN921x vendor driver

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index d733a42..5ede747 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -194,6 +194,48 @@ or, for backwards compatibility, the option value.  E.g.,
 
 	The parameters are as follows:
 
+ad_select
+
+	Specifies the 802.3ad aggregation selection logic to use.  The
+	possible values and their effects are:
+
+	stable or 0
+
+		The active aggregator is chosen by largest aggregate
+		bandwidth.
+
+		Reselection of the active aggregator occurs only when all
+		slaves of the active aggregator are down or the active
+		aggregator has no slaves.
+
+		This is the default value.
+
+	bandwidth or 1
+
+		The active aggregator is chosen by largest aggregate
+		bandwidth.  Reselection occurs if:
+
+		- A slave is added to or removed from the bond
+
+		- Any slave's link state changes
+
+		- Any slave's 802.3ad association state changes
+
+		- The bond's adminstrative state changes to up
+
+	count or 2
+
+		The active aggregator is chosen by the largest number of
+		ports (slaves).  Reselection occurs as described under the
+		"bandwidth" setting, above.
+
+	The bandwidth and count selection policies permit failover of
+	802.3ad aggregations when partial failure of the active aggregator
+	occurs.  This keeps the aggregator with the highest availability
+	(either in bandwidth or in number of ports) active at all times.
+
+	This option was added in bonding version 3.4.0.
+
 arp_interval
 
 	Specifies the ARP link monitoring frequency in milliseconds.
@@ -551,6 +593,16 @@ num_grat_arp
 	affects only the active-backup mode.  This option was added for
 	bonding version 3.3.0.
 
+num_unsol_na
+
+	Specifies the number of unsolicited IPv6 Neighbor Advertisements
+	to be issued after a failover event.  One unsolicited NA is issued
+	immediately after the failover.
+
+	The valid range is 0 - 255; the default value is 1.  This option
+	affects only the active-backup mode.  This option was added for
+	bonding version 3.4.0.
+
 primary
 
 	A string (eth0, eth2, etc) specifying which slave is the
diff --git a/MAINTAINERS b/MAINTAINERS
index 129117f..5d951f3 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3853,6 +3853,12 @@ M:	mhoffman@lightlink.com
 L:	lm-sensors@lm-sensors.org
 S:	Maintained
 
+SMSC911x ETHERNET DRIVER
+P:	Steve Glendinning
+M:	steve.glendinning@smsc.com
+L:	netdev@vger.kernel.org
+S:	Supported
+
 SMX UIO Interface
 P:	Ben Nizette
 M:	bn@niasdigital.com
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0f3e6b2..74a18a7 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -61,6 +61,7 @@ config DUMMY
 config BONDING
 	tristate "Bonding driver support"
 	depends on INET
+	depends on IPV6 || IPV6=n
 	---help---
 	  Say 'Y' or 'M' if you wish to be able to 'bond' multiple Ethernet
 	  Channels together. This is called 'Etherchannel' by Cisco,
@@ -978,6 +979,20 @@ config SMC911X
 	  called smc911x.  If you want to compile it as a module, say M 
 	  here and read <file:Documentation/kbuild/modules.txt>
 
+config SMSC911X
+	tristate "SMSC LAN911x/LAN921x families embedded ethernet support"
+	depends on ARM || SUPERH
+	select CRC32
+	select MII
+	select PHYLIB
+	---help---
+	  Say Y here if you want support for SMSC LAN911x and LAN921x families
+	  of ethernet controllers.
+
+	  To compile this driver as a module, choose M here and read
+	  <file:Documentation/networking/net-modules.txt>. The module
+	  will be called smsc911x.
+
 config NET_VENDOR_RACAL
 	bool "Racal-Interlan (Micom) NI cards"
 	depends on ISA
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 657c47b..e06829a 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -219,6 +219,7 @@ obj-$(CONFIG_S2IO) += s2io.o
 obj-$(CONFIG_MYRI10GE) += myri10ge/
 obj-$(CONFIG_SMC91X) += smc91x.o
 obj-$(CONFIG_SMC911X) += smc911x.o
+obj-$(CONFIG_SMSC911X) += smsc911x.o
 obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
 obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_PASEMI_MAC) += pasemi_mac_driver.o
diff --git a/drivers/net/bonding/Makefile b/drivers/net/bonding/Makefile
index 5cdae2b..6f9c6fa 100644
--- a/drivers/net/bonding/Makefile
+++ b/drivers/net/bonding/Makefile
@@ -6,3 +6,6 @@ obj-$(CONFIG_BONDING) += bonding.o
 
 bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o
 
+ipv6-$(subst m,y,$(CONFIG_IPV6)) += bond_ipv6.o
+bonding-objs += $(ipv6-y)
+
diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 6106660..ba1372f 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -27,6 +27,7 @@
 #include <linux/netdevice.h>
 #include <linux/spinlock.h>
 #include <linux/ethtool.h>
+#include <linux/etherdevice.h>
 #include <linux/if_bonding.h>
 #include <linux/pkt_sched.h>
 #include <net/net_namespace.h>
@@ -236,6 +237,17 @@ static inline struct aggregator *__get_next_agg(struct aggregator *aggregator)
 	return &(SLAVE_AD_INFO(slave->next).aggregator);
 }
 
+/*
+ * __agg_has_partner
+ *
+ * Return nonzero if aggregator has a partner (denoted by a non-zero ether
+ * address for the partner).  Return 0 if not.
+ */
+static inline int __agg_has_partner(struct aggregator *agg)
+{
+	return !is_zero_ether_addr(agg->partner_system.mac_addr_value);
+}
+
 /**
  * __disable_port - disable the port's slave
  * @port: the port we're looking at
@@ -274,14 +286,14 @@ static inline int __port_is_enabled(struct port *port)
  * __get_agg_selection_mode - get the aggregator selection mode
  * @port: the port we're looking at
  *
- * Get the aggregator selection mode. Can be %BANDWIDTH or %COUNT.
+ * Get the aggregator selection mode. Can be %STABLE, %BANDWIDTH or %COUNT.
  */
 static inline u32 __get_agg_selection_mode(struct port *port)
 {
 	struct bonding *bond = __get_bond_by_port(port);
 
 	if (bond == NULL) {
-		return AD_BANDWIDTH;
+		return BOND_AD_STABLE;
 	}
 
 	return BOND_AD_INFO(bond).agg_select_mode;
@@ -1414,9 +1426,82 @@ static void ad_port_selection_logic(struct port *port)
 	// else set ready=FALSE in all aggregator's ports
 	__set_agg_ports_ready(port->aggregator, __agg_ports_are_ready(port->aggregator));
 
-	if (!__check_agg_selection_timer(port) && (aggregator = __get_first_agg(port))) {
-		ad_agg_selection_logic(aggregator);
+	aggregator = __get_first_agg(port);
+	ad_agg_selection_logic(aggregator);
+}
+
+/*
+ * Decide if "agg" is a better choice for the new active aggregator that
+ * the current best, according to the ad_select policy.
+ */
+static struct aggregator *ad_agg_selection_test(struct aggregator *best,
+						struct aggregator *curr)
+{
+	/*
+	 * 0. If no best, select current.
+	 *
+	 * 1. If the current agg is not individual, and the best is
+	 *    individual, select current.
+	 *
+	 * 2. If current agg is individual and the best is not, keep best.
+	 *
+	 * 3. Therefore, current and best are both individual or both not
+	 *    individual, so:
+	 *
+	 * 3a. If current agg partner replied, and best agg partner did not,
+	 *     select current.
+	 *
+	 * 3b. If current agg partner did not reply and best agg partner
+	 *     did reply, keep best.
+	 *
+	 * 4.  Therefore, current and best both have partner replies or
+	 *     both do not, so perform selection policy:
+	 *
+	 * BOND_AD_COUNT: Select by count of ports.  If count is equal,
+	 *     select by bandwidth.
+	 *
+	 * BOND_AD_STABLE, BOND_AD_BANDWIDTH: Select by bandwidth.
+	 */
+	if (!best)
+		return curr;
+
+	if (!curr->is_individual && best->is_individual)
+		return curr;
+
+	if (curr->is_individual && !best->is_individual)
+		return best;
+
+	if (__agg_has_partner(curr) && !__agg_has_partner(best))
+		return curr;
+
+	if (!__agg_has_partner(curr) && __agg_has_partner(best))
+		return best;
+
+	switch (__get_agg_selection_mode(curr->lag_ports)) {
+	case BOND_AD_COUNT:
+		if (curr->num_of_ports > best->num_of_ports)
+			return curr;
+
+		if (curr->num_of_ports < best->num_of_ports)
+			return best;
+
+		/*FALLTHROUGH*/
+	case BOND_AD_STABLE:
+	case BOND_AD_BANDWIDTH:
+		if (__get_agg_bandwidth(curr) > __get_agg_bandwidth(best))
+			return curr;
+
+		break;
+
+	default:
+		printk(KERN_WARNING DRV_NAME
+		       ": %s: Impossible agg select mode %d\n",
+		       curr->slave->dev->master->name,
+		       __get_agg_selection_mode(curr->lag_ports));
+		break;
 	}
+
+	return best;
 }
 
 /**
@@ -1424,156 +1509,138 @@ static void ad_port_selection_logic(struct port *port)
  * @aggregator: the aggregator we're looking at
  *
  * It is assumed that only one aggregator may be selected for a team.
- * The logic of this function is to select (at first time) the aggregator with
- * the most ports attached to it, and to reselect the active aggregator only if
- * the previous aggregator has no more ports related to it.
+ *
+ * The logic of this function is to select the aggregator according to
+ * the ad_select policy:
+ *
+ * BOND_AD_STABLE: select the aggregator with the most ports attached to
+ * it, and to reselect the active aggregator only if the previous
+ * aggregator has no more ports related to it.
+ *
+ * BOND_AD_BANDWIDTH: select the aggregator with the highest total
+ * bandwidth, and reselect whenever a link state change takes place or the
+ * set of slaves in the bond changes.
+ *
+ * BOND_AD_COUNT: select the aggregator with largest number of ports
+ * (slaves), and reselect whenever a link state change takes place or the
+ * set of slaves in the bond changes.
  *
  * FIXME: this function MUST be called with the first agg in the bond, or
  * __get_active_agg() won't work correctly. This function should be better
  * called with the bond itself, and retrieve the first agg from it.
  */
-static void ad_agg_selection_logic(struct aggregator *aggregator)
+static void ad_agg_selection_logic(struct aggregator *agg)
 {
-	struct aggregator *best_aggregator = NULL, *active_aggregator = NULL;
-	struct aggregator *last_active_aggregator = NULL, *origin_aggregator;
+	struct aggregator *best, *active, *origin;
 	struct port *port;
-	u16 num_of_aggs=0;
 
-	origin_aggregator = aggregator;
+	origin = agg;
 
-	//get current active aggregator
-	last_active_aggregator = __get_active_agg(aggregator);
+	active = __get_active_agg(agg);
+	best = active;
 
-	// search for the aggregator with the most ports attached to it.
 	do {
-		// count how many candidate lag's we have
-		if (aggregator->lag_ports) {
-			num_of_aggs++;
-		}
-		if (aggregator->is_active && !aggregator->is_individual &&   // if current aggregator is the active aggregator
-		    MAC_ADDRESS_COMPARE(&(aggregator->partner_system), &(null_mac_addr))) {   // and partner answers to 802.3ad PDUs
-			if (aggregator->num_of_ports) {	// if any ports attached to the current aggregator
-				best_aggregator=NULL;	 // disregard the best aggregator that was chosen by now
-				break;		 // stop the selection of other aggregator if there are any ports attached to this active aggregator
-			} else { // no ports attached to this active aggregator
-				aggregator->is_active = 0; // mark this aggregator as not active anymore
+		agg->is_active = 0;
+
+		if (agg->num_of_ports)
+			best = ad_agg_selection_test(best, agg);
+
+	} while ((agg = __get_next_agg(agg)));
+
+	if (best &&
+	    __get_agg_selection_mode(best->lag_ports) == BOND_AD_STABLE) {
+		/*
+		 * For the STABLE policy, don't replace the old active
+		 * aggregator if it's still active (it has an answering
+		 * partner) or if both the best and active don't have an
+		 * answering partner.
+		 */
+		if (active && active->lag_ports &&
+		    active->lag_ports->is_enabled &&
+		    (__agg_has_partner(active) ||
+		     (!__agg_has_partner(active) && !__agg_has_partner(best)))) {
+			if (!(!active->actor_oper_aggregator_key &&
+			      best->actor_oper_aggregator_key)) {
+				best = NULL;
+				active->is_active = 1;
 			}
 		}
-		if (aggregator->num_of_ports) {	// if any ports attached
-			if (best_aggregator) {	// if there is a candidte aggregator
-				//The reasons for choosing new best aggregator:
-				// 1. if current agg is NOT individual and the best agg chosen so far is individual OR
-				// current and best aggs are both individual or both not individual, AND
-				// 2a.  current agg partner reply but best agg partner do not reply OR
-				// 2b.  current agg partner reply OR current agg partner do not reply AND best agg partner also do not reply AND
-				//      current has more ports/bandwidth, or same amount of ports but current has faster ports, THEN
-				//      current agg become best agg so far
-
-				//if current agg is NOT individual and the best agg chosen so far is individual change best_aggregator
-				if (!aggregator->is_individual && best_aggregator->is_individual) {
-					best_aggregator=aggregator;
-				}
-				// current and best aggs are both individual or both not individual
-				else if ((aggregator->is_individual && best_aggregator->is_individual) ||
-					 (!aggregator->is_individual && !best_aggregator->is_individual)) {
-					//  current and best aggs are both individual or both not individual AND
-					//  current agg partner reply but best agg partner do not reply
-					if ((MAC_ADDRESS_COMPARE(&(aggregator->partner_system), &(null_mac_addr)) &&
-					     !MAC_ADDRESS_COMPARE(&(best_aggregator->partner_system), &(null_mac_addr)))) {
-						best_aggregator=aggregator;
-					}
-					//  current agg partner reply OR current agg partner do not reply AND best agg partner also do not reply
-					else if (! (!MAC_ADDRESS_COMPARE(&(aggregator->partner_system), &(null_mac_addr)) &&
-						    MAC_ADDRESS_COMPARE(&(best_aggregator->partner_system), &(null_mac_addr)))) {
-						if ((__get_agg_selection_mode(aggregator->lag_ports) == AD_BANDWIDTH)&&
-						    (__get_agg_bandwidth(aggregator) > __get_agg_bandwidth(best_aggregator))) {
-							best_aggregator=aggregator;
-						} else if (__get_agg_selection_mode(aggregator->lag_ports) == AD_COUNT) {
-							if (((aggregator->num_of_ports > best_aggregator->num_of_ports) &&
-							     (aggregator->actor_oper_aggregator_key & AD_SPEED_KEY_BITS))||
-							    ((aggregator->num_of_ports == best_aggregator->num_of_ports) &&
-							     ((u16)(aggregator->actor_oper_aggregator_key & AD_SPEED_KEY_BITS) >
-							      (u16)(best_aggregator->actor_oper_aggregator_key & AD_SPEED_KEY_BITS)))) {
-								best_aggregator=aggregator;
-							}
-						}
-					}
-				}
-			} else {
-				best_aggregator=aggregator;
-			}
-		}
-		aggregator->is_active = 0; // mark all aggregators as not active anymore
-	} while ((aggregator = __get_next_agg(aggregator)));
-
-	// if we have new aggregator selected, don't replace the old aggregator if it has an answering partner,
-	// or if both old aggregator and new aggregator don't have answering partner
-	if (best_aggregator) {
-		if (last_active_aggregator && last_active_aggregator->lag_ports && last_active_aggregator->lag_ports->is_enabled &&
-		    (MAC_ADDRESS_COMPARE(&(last_active_aggregator->partner_system), &(null_mac_addr)) ||   // partner answers OR
-		     (!MAC_ADDRESS_COMPARE(&(last_active_aggregator->partner_system), &(null_mac_addr)) &&	// both old and new
-		      !MAC_ADDRESS_COMPARE(&(best_aggregator->partner_system), &(null_mac_addr))))     // partner do not answer
-		   ) {
-			// if new aggregator has link, and old aggregator does not, replace old aggregator.(do nothing)
-			// -> don't replace otherwise.
-			if (!(!last_active_aggregator->actor_oper_aggregator_key && best_aggregator->actor_oper_aggregator_key)) {
-				best_aggregator=NULL;
-				last_active_aggregator->is_active = 1; // don't replace good old aggregator
+	}
 
-			}
-		}
+	if (best && (best == active)) {
+		best = NULL;
+		active->is_active = 1;
 	}
 
 	// if there is new best aggregator, activate it
-	if (best_aggregator) {
-		for (aggregator = __get_first_agg(best_aggregator->lag_ports);
-		    aggregator;
-		    aggregator = __get_next_agg(aggregator)) {
-
-			dprintk("Agg=%d; Ports=%d; a key=%d; p key=%d; Indiv=%d; Active=%d\n",
-					aggregator->aggregator_identifier, aggregator->num_of_ports,
-					aggregator->actor_oper_aggregator_key, aggregator->partner_oper_aggregator_key,
-					aggregator->is_individual, aggregator->is_active);
+	if (best) {
+		dprintk("best Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
+		       best->aggregator_identifier, best->num_of_ports,
+		       best->actor_oper_aggregator_key,
+		       best->partner_oper_aggregator_key,
+		       best->is_individual, best->is_active);
+		dprintk("best ports %p slave %p %s\n",
+		       best->lag_ports, best->slave,
+		       best->slave ? best->slave->dev->name : "NULL");
+
+		for (agg = __get_first_agg(best->lag_ports); agg;
+		     agg = __get_next_agg(agg)) {
+
+			dprintk("Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
+				agg->aggregator_identifier, agg->num_of_ports,
+				agg->actor_oper_aggregator_key,
+				agg->partner_oper_aggregator_key,
+				agg->is_individual, agg->is_active);
 		}
 
 		// check if any partner replys
-		if (best_aggregator->is_individual) {
-			printk(KERN_WARNING DRV_NAME ": %s: Warning: No 802.3ad response from "
-			       "the link partner for any adapters in the bond\n",
-			       best_aggregator->slave->dev->master->name);
-		}
-
-		// check if there are more than one aggregator
-		if (num_of_aggs > 1) {
-			dprintk("Warning: More than one Link Aggregation Group was "
-				"found in the bond. Only one group will function in the bond\n");
+		if (best->is_individual) {
+			printk(KERN_WARNING DRV_NAME ": %s: Warning: No 802.3ad"
+			       " response from the link partner for any"
+			       " adapters in the bond\n",
+			       best->slave->dev->master->name);
 		}
 
-		best_aggregator->is_active = 1;
-		dprintk("LAG %d choosed as the active LAG\n", best_aggregator->aggregator_identifier);
-		dprintk("Agg=%d; Ports=%d; a key=%d; p key=%d; Indiv=%d; Active=%d\n",
-				best_aggregator->aggregator_identifier, best_aggregator->num_of_ports,
-				best_aggregator->actor_oper_aggregator_key, best_aggregator->partner_oper_aggregator_key,
-				best_aggregator->is_individual, best_aggregator->is_active);
+		best->is_active = 1;
+		dprintk("LAG %d chosen as the active LAG\n",
+			best->aggregator_identifier);
+		dprintk("Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
+			best->aggregator_identifier, best->num_of_ports,
+			best->actor_oper_aggregator_key,
+			best->partner_oper_aggregator_key,
+			best->is_individual, best->is_active);
 
 		// disable the ports that were related to the former active_aggregator
-		if (last_active_aggregator) {
-			for (port=last_active_aggregator->lag_ports; port; port=port->next_port_in_aggregator) {
+		if (active) {
+			for (port = active->lag_ports; port;
+			     port = port->next_port_in_aggregator) {
 				__disable_port(port);
 			}
 		}
 	}
 
-	// if the selected aggregator is of join individuals(partner_system is NULL), enable their ports
-	active_aggregator = __get_active_agg(origin_aggregator);
+	/*
+	 * if the selected aggregator is of join individuals
+	 * (partner_system is NULL), enable their ports
+	 */
+	active = __get_active_agg(origin);
 
-	if (active_aggregator) {
-		if (!MAC_ADDRESS_COMPARE(&(active_aggregator->partner_system), &(null_mac_addr))) {
-			for (port=active_aggregator->lag_ports; port; port=port->next_port_in_aggregator) {
+	if (active) {
+		if (!__agg_has_partner(active)) {
+			for (port = active->lag_ports; port;
+			     port = port->next_port_in_aggregator) {
 				__enable_port(port);
 			}
 		}
 	}
+
+	if (origin->slave) {
+		struct bonding *bond;
+
+		bond = bond_get_bond_by_slave(origin->slave);
+		if (bond)
+			bond_3ad_set_carrier(bond);
+	}
 }
 
 /**
@@ -1830,6 +1897,19 @@ static void ad_initialize_lacpdu(struct lacpdu *lacpdu)
 // Check aggregators status in team every T seconds
 #define AD_AGGREGATOR_SELECTION_TIMER  8
 
+/*
+ * bond_3ad_initiate_agg_selection(struct bonding *bond)
+ *
+ * Set the aggregation selection timer, to initiate an agg selection in
+ * the very near future.  Called during first initialization, and during
+ * any down to up transitions of the bond.
+ */
+void bond_3ad_initiate_agg_selection(struct bonding *bond, int timeout)
+{
+	BOND_AD_INFO(bond).agg_select_timer = timeout;
+	BOND_AD_INFO(bond).agg_select_mode = bond->params.ad_select;
+}
+
 static u16 aggregator_identifier;
 
 /**
@@ -1854,9 +1934,9 @@ void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fas
 		// initialize how many times this module is called in one second(should be about every 100ms)
 		ad_ticks_per_sec = tick_resolution;
 
-		// initialize the aggregator selection timer(to activate an aggregation selection after initialize)
-		BOND_AD_INFO(bond).agg_select_timer = (AD_AGGREGATOR_SELECTION_TIMER * ad_ticks_per_sec);
-		BOND_AD_INFO(bond).agg_select_mode = AD_BANDWIDTH;
+		bond_3ad_initiate_agg_selection(bond,
+						AD_AGGREGATOR_SELECTION_TIMER *
+						ad_ticks_per_sec);
 	}
 }
 
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index b5ee45f..a803fe0 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -42,10 +42,11 @@ typedef struct mac_addr {
 	u8 mac_addr_value[ETH_ALEN];
 } mac_addr_t;
 
-typedef enum {
-	AD_BANDWIDTH = 0,
-	AD_COUNT
-} agg_selection_t;
+enum {
+	BOND_AD_STABLE = 0,
+	BOND_AD_BANDWIDTH = 1,
+	BOND_AD_COUNT = 2,
+};
 
 // rx machine states(43.4.11 in the 802.3ad standard)
 typedef enum {
@@ -277,6 +278,7 @@ void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fas
 int  bond_3ad_bind_slave(struct slave *slave);
 void bond_3ad_unbind_slave(struct slave *slave);
 void bond_3ad_state_machine_handler(struct work_struct *);
+void bond_3ad_initiate_agg_selection(struct bonding *bond, int timeout);
 void bond_3ad_adapter_speed_changed(struct slave *slave);
 void bond_3ad_adapter_duplex_changed(struct slave *slave);
 void bond_3ad_handle_link_change(struct slave *slave, char link);
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 87437c7..e170fa2 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -346,14 +346,18 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
 
 static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct packet_type *ptype, struct net_device *orig_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond;
 	struct arp_pkt *arp = (struct arp_pkt *)skb->data;
 	int res = NET_RX_DROP;
 
 	if (dev_net(bond_dev) != &init_net)
 		goto out;
 
-	if (!(bond_dev->flags & IFF_MASTER))
+	while (bond_dev->priv_flags & IFF_802_1Q_VLAN)
+		bond_dev = vlan_dev_real_dev(bond_dev);
+
+	if (!(bond_dev->priv_flags & IFF_BONDING) ||
+	    !(bond_dev->flags & IFF_MASTER))
 		goto out;
 
 	if (!arp) {
@@ -368,6 +372,9 @@ static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct
 
 	if (arp->op_code == htons(ARPOP_REPLY)) {
 		/* update rx hash table for this ARP */
+		printk("rar: update orig %s bond_dev %s\n", orig_dev->name,
+		       bond_dev->name);
+		bond = bond_dev->priv;
 		rlb_update_entry_from_arp(bond, arp);
 		dprintk("Server received an ARP Reply from client\n");
 	}
@@ -818,7 +825,7 @@ static int rlb_initialize(struct bonding *bond)
 
 	/*initialize packet type*/
 	pk_type->type = __constant_htons(ETH_P_ARP);
-	pk_type->dev = bond->dev;
+	pk_type->dev = NULL;
 	pk_type->func = rlb_arp_recv;
 
 	/* register to receive ARPs */
diff --git a/drivers/net/bonding/bond_ipv6.c b/drivers/net/bonding/bond_ipv6.c
new file mode 100644
index 0000000..7c78b7b
--- /dev/null
+++ b/drivers/net/bonding/bond_ipv6.c
@@ -0,0 +1,218 @@
+/*
+ * Copyright(c) 2008 Hewlett-Packard Development Company, L.P.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
+ * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ */
+
+//#define BONDING_DEBUG 1
+
+#include <linux/types.h>
+#include <linux/if_vlan.h>
+#include <net/ipv6.h>
+#include <net/ndisc.h>
+#include <net/addrconf.h>
+#include "bonding.h"
+
+/*
+ * Assign bond->master_ipv6 to the next IPv6 address in the list, or
+ * zero it out if there are none.
+ */
+static void bond_glean_dev_ipv6(struct net_device *dev, struct in6_addr *addr)
+{
+	struct inet6_dev *idev;
+	struct inet6_ifaddr *ifa;
+
+	if (!dev)
+		return;
+
+	idev = in6_dev_get(dev);
+	if (!idev)
+		return;
+
+	read_lock_bh(&idev->lock);
+	ifa = idev->addr_list;
+	if (ifa)
+		ipv6_addr_copy(addr, &ifa->addr);
+	else
+		ipv6_addr_set(addr, 0, 0, 0, 0);
+
+	read_unlock_bh(&idev->lock);
+
+	in6_dev_put(idev);
+}
+
+static void bond_na_send(struct net_device *slave_dev,
+			 struct in6_addr *daddr,
+			 int router,
+			 unsigned short vlan_id)
+{
+	struct in6_addr mcaddr;
+	struct icmp6hdr icmp6h = {
+		.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT,
+	};
+	struct sk_buff *skb;
+
+	icmp6h.icmp6_router = router;
+	icmp6h.icmp6_solicited = 0;
+	icmp6h.icmp6_override = 1;
+
+	addrconf_addr_solict_mult(daddr, &mcaddr);
+
+	dprintk("ipv6 na on slave %s: dest %pI6, src %pI6\n",
+	       slave->name, &mcaddr, daddr);
+
+	skb = ndisc_build_skb(slave_dev, &mcaddr, daddr, &icmp6h, daddr,
+			      ND_OPT_TARGET_LL_ADDR);
+
+	if (!skb) {
+		printk(KERN_ERR DRV_NAME ": NA packet allocation failed\n");
+		return;
+	}
+
+	if (vlan_id) {
+		skb = vlan_put_tag(skb, vlan_id);
+		if (!skb) {
+			printk(KERN_ERR DRV_NAME ": failed to insert VLAN tag\n");
+			return;
+		}
+	}
+
+	ndisc_send_skb(skb, slave_dev, NULL, &mcaddr, daddr, &icmp6h);
+}
+
+/*
+ * Kick out an unsolicited Neighbor Advertisement for an IPv6 address on
+ * the bonding master.  This will help the switch learn our address
+ * if in active-backup mode.
+ *
+ * Caller must hold curr_slave_lock for read or better
+ */
+void bond_send_unsolicited_na(struct bonding *bond)
+{
+	struct slave *slave = bond->curr_active_slave;
+	struct vlan_entry *vlan;
+	struct inet6_dev *idev;
+	int is_router;
+
+	dprintk("bond_send_unsol_na: bond %s slave %s\n", bond->dev->name,
+				slave ? slave->dev->name : "NULL");
+
+	if (!slave || !bond->send_unsol_na ||
+	    test_bit(__LINK_STATE_LINKWATCH_PENDING, &slave->dev->state))
+		return;
+
+	bond->send_unsol_na--;
+
+	idev = in6_dev_get(bond->dev);
+	if (!idev)
+		return;
+
+	is_router = !!idev->cnf.forwarding;
+
+	in6_dev_put(idev);
+
+	if (!ipv6_addr_any(&bond->master_ipv6))
+		bond_na_send(slave->dev, &bond->master_ipv6, is_router, 0);
+
+	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
+		if (!ipv6_addr_any(&vlan->vlan_ipv6)) {
+			bond_na_send(slave->dev, &vlan->vlan_ipv6, is_router,
+				     vlan->vlan_id);
+		}
+	}
+}
+
+/*
+ * bond_inet6addr_event: handle inet6addr notifier chain events.
+ *
+ * We keep track of device IPv6 addresses primarily to use as source
+ * addresses in NS probes.
+ *
+ * We track one IPv6 for the main device (if it has one).
+ */
+static int bond_inet6addr_event(struct notifier_block *this,
+				unsigned long event,
+				void *ptr)
+{
+	struct inet6_ifaddr *ifa = ptr;
+	struct net_device *vlan_dev, *event_dev = ifa->idev->dev;
+	struct bonding *bond;
+	struct vlan_entry *vlan;
+
+	if (dev_net(event_dev) != &init_net)
+		return NOTIFY_DONE;
+
+	list_for_each_entry(bond, &bond_dev_list, bond_list) {
+		if (bond->dev == event_dev) {
+			switch (event) {
+			case NETDEV_UP:
+				if (ipv6_addr_any(&bond->master_ipv6))
+					ipv6_addr_copy(&bond->master_ipv6,
+						       &ifa->addr);
+				return NOTIFY_OK;
+			case NETDEV_DOWN:
+				if (ipv6_addr_equal(&bond->master_ipv6,
+						    &ifa->addr))
+					bond_glean_dev_ipv6(bond->dev,
+							    &bond->master_ipv6);
+				return NOTIFY_OK;
+			default:
+				return NOTIFY_DONE;
+			}
+		}
+
+		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
+			vlan_dev = vlan_group_get_device(bond->vlgrp,
+							 vlan->vlan_id);
+			if (vlan_dev == event_dev) {
+				switch (event) {
+				case NETDEV_UP:
+					if (ipv6_addr_any(&vlan->vlan_ipv6))
+						ipv6_addr_copy(&vlan->vlan_ipv6,
+							       &ifa->addr);
+					return NOTIFY_OK;
+				case NETDEV_DOWN:
+					if (ipv6_addr_equal(&vlan->vlan_ipv6,
+							    &ifa->addr))
+						bond_glean_dev_ipv6(vlan_dev,
+								    &vlan->vlan_ipv6);
+					return NOTIFY_OK;
+				default:
+					return NOTIFY_DONE;
+				}
+			}
+		}
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block bond_inet6addr_notifier = {
+	.notifier_call = bond_inet6addr_event,
+};
+
+void bond_register_ipv6_notifier(void)
+{
+	register_inet6addr_notifier(&bond_inet6addr_notifier);
+}
+
+void bond_unregister_ipv6_notifier(void)
+{
+	unregister_inet6addr_notifier(&bond_inet6addr_notifier);
+}
+
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 39575d7..02de3e0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -89,6 +89,7 @@
 
 static int max_bonds	= BOND_DEFAULT_MAX_BONDS;
 static int num_grat_arp = 1;
+static int num_unsol_na = 1;
 static int miimon	= BOND_LINK_MON_INTERV;
 static int updelay	= 0;
 static int downdelay	= 0;
@@ -96,6 +97,7 @@ static int use_carrier	= 1;
 static char *mode	= NULL;
 static char *primary	= NULL;
 static char *lacp_rate	= NULL;
+static char *ad_select  = NULL;
 static char *xmit_hash_policy = NULL;
 static int arp_interval = BOND_LINK_ARP_INTERV;
 static char *arp_ip_target[BOND_MAX_ARP_TARGETS] = { NULL, };
@@ -107,6 +109,8 @@ module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
 module_param(num_grat_arp, int, 0644);
 MODULE_PARM_DESC(num_grat_arp, "Number of gratuitous ARP packets to send on failover event");
+module_param(num_unsol_na, int, 0644);
+MODULE_PARM_DESC(num_unsol_na, "Number of unsolicited IPv6 Neighbor Advertisements packets to send on failover event");
 module_param(miimon, int, 0);
 MODULE_PARM_DESC(miimon, "Link check interval in milliseconds");
 module_param(updelay, int, 0);
@@ -127,6 +131,8 @@ MODULE_PARM_DESC(primary, "Primary network device to use");
 module_param(lacp_rate, charp, 0);
 MODULE_PARM_DESC(lacp_rate, "LACPDU tx rate to request from 802.3ad partner "
 			    "(slow/fast)");
+module_param(ad_select, charp, 0);
+MODULE_PARM_DESC(ad_select, "803.ad aggregation selection logic: stable (0, default), bandwidth (1), count (2)");
 module_param(xmit_hash_policy, charp, 0);
 MODULE_PARM_DESC(xmit_hash_policy, "XOR hashing method: 0 for layer 2 (default)"
 				   ", 1 for layer 3+4");
@@ -197,6 +203,13 @@ struct bond_parm_tbl fail_over_mac_tbl[] = {
 {	NULL,			-1},
 };
 
+struct bond_parm_tbl ad_select_tbl[] = {
+{	"stable",	BOND_AD_STABLE},
+{	"bandwidth",	BOND_AD_BANDWIDTH},
+{	"count",	BOND_AD_COUNT},
+{	NULL,		-1},
+};
+
 /*-------------------------- Forward declarations ---------------------------*/
 
 static void bond_send_gratuitous_arp(struct bonding *bond);
@@ -242,14 +255,13 @@ static int bond_add_vlan(struct bonding *bond, unsigned short vlan_id)
 	dprintk("bond: %s, vlan id %d\n",
 		(bond ? bond->dev->name: "None"), vlan_id);
 
-	vlan = kmalloc(sizeof(struct vlan_entry), GFP_KERNEL);
+	vlan = kzalloc(sizeof(struct vlan_entry), GFP_KERNEL);
 	if (!vlan) {
 		return -ENOMEM;
 	}
 
 	INIT_LIST_HEAD(&vlan->vlan_list);
 	vlan->vlan_id = vlan_id;
-	vlan->vlan_ip = 0;
 
 	write_lock_bh(&bond->lock);
 
@@ -1208,6 +1220,9 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 			bond->send_grat_arp = bond->params.num_grat_arp;
 			bond_send_gratuitous_arp(bond);
 
+			bond->send_unsol_na = bond->params.num_unsol_na;
+			bond_send_unsolicited_na(bond);
+
 			write_unlock_bh(&bond->curr_slave_lock);
 			read_unlock(&bond->lock);
 
@@ -2463,6 +2478,12 @@ void bond_mii_monitor(struct work_struct *work)
 		read_unlock(&bond->curr_slave_lock);
 	}
 
+	if (bond->send_unsol_na) {
+		read_lock(&bond->curr_slave_lock);
+		bond_send_unsolicited_na(bond);
+		read_unlock(&bond->curr_slave_lock);
+	}
+
 	if (bond_miimon_inspect(bond)) {
 		read_unlock(&bond->lock);
 		rtnl_lock();
@@ -3158,6 +3179,12 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 		read_unlock(&bond->curr_slave_lock);
 	}
 
+	if (bond->send_unsol_na) {
+		read_lock(&bond->curr_slave_lock);
+		bond_send_unsolicited_na(bond);
+		read_unlock(&bond->curr_slave_lock);
+	}
+
 	if (bond_ab_arp_inspect(bond, delta_in_ticks)) {
 		read_unlock(&bond->lock);
 		rtnl_lock();
@@ -3301,6 +3328,8 @@ static void bond_info_show_master(struct seq_file *seq)
 		seq_puts(seq, "\n802.3ad info\n");
 		seq_printf(seq, "LACP rate: %s\n",
 			   (bond->params.lacp_fast) ? "fast" : "slow");
+		seq_printf(seq, "Aggregator selection policy (ad_select): %s\n",
+			   ad_select_tbl[bond->params.ad_select].modename);
 
 		if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
 			seq_printf(seq, "bond %s has no active aggregator\n",
@@ -3807,6 +3836,7 @@ static int bond_open(struct net_device *bond_dev)
 		queue_delayed_work(bond->wq, &bond->ad_work, 0);
 		/* register to receive LACPDUs */
 		bond_register_lacpdu(bond);
+		bond_3ad_initiate_agg_selection(bond, 1);
 	}
 
 	return 0;
@@ -3827,6 +3857,7 @@ static int bond_close(struct net_device *bond_dev)
 	write_lock_bh(&bond->lock);
 
 	bond->send_grat_arp = 0;
+	bond->send_unsol_na = 0;
 
 	/* signal timers not to re-arm */
 	bond->kill_timers = 1;
@@ -4542,6 +4573,7 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 	bond->primary_slave = NULL;
 	bond->dev = bond_dev;
 	bond->send_grat_arp = 0;
+	bond->send_unsol_na = 0;
 	bond->setup_by_slave = 0;
 	INIT_LIST_HEAD(&bond->vlan_list);
 
@@ -4744,6 +4776,23 @@ static int bond_check_params(struct bond_params *params)
 		}
 	}
 
+	if (ad_select) {
+		params->ad_select = bond_parse_parm(ad_select, ad_select_tbl);
+		if (params->ad_select == -1) {
+			printk(KERN_ERR DRV_NAME
+			       ": Error: Invalid ad_select \"%s\"\n",
+			       ad_select == NULL ? "NULL" : ad_select);
+			return -EINVAL;
+		}
+
+		if (bond_mode != BOND_MODE_8023AD) {
+			printk(KERN_WARNING DRV_NAME
+			       ": ad_select param only affects 802.3ad mode\n");
+		}
+	} else {
+		params->ad_select = BOND_AD_STABLE;
+	}
+
 	if (max_bonds < 0 || max_bonds > INT_MAX) {
 		printk(KERN_WARNING DRV_NAME
 		       ": Warning: max_bonds (%d) not in range %d-%d, so it "
@@ -4791,6 +4840,13 @@ static int bond_check_params(struct bond_params *params)
 		num_grat_arp = 1;
 	}
 
+	if (num_unsol_na < 0 || num_unsol_na > 255) {
+		printk(KERN_WARNING DRV_NAME
+		       ": Warning: num_unsol_na (%d) not in range 0-255 so it "
+		       "was reset to 1 \n", num_unsol_na);
+		num_unsol_na = 1;
+	}
+
 	/* reset values for 802.3ad */
 	if (bond_mode == BOND_MODE_8023AD) {
 		if (!miimon) {
@@ -4992,6 +5048,7 @@ static int bond_check_params(struct bond_params *params)
 	params->xmit_policy = xmit_hashtype;
 	params->miimon = miimon;
 	params->num_grat_arp = num_grat_arp;
+	params->num_unsol_na = num_unsol_na;
 	params->arp_interval = arp_interval;
 	params->arp_validate = arp_validate_value;
 	params->updelay = updelay;
@@ -5144,6 +5201,7 @@ static int __init bonding_init(void)
 
 	register_netdevice_notifier(&bond_netdev_notifier);
 	register_inetaddr_notifier(&bond_inetaddr_notifier);
+	bond_register_ipv6_notifier();
 
 	goto out;
 err:
@@ -5166,6 +5224,7 @@ static void __exit bonding_exit(void)
 {
 	unregister_netdevice_notifier(&bond_netdev_notifier);
 	unregister_inetaddr_notifier(&bond_inetaddr_notifier);
+	bond_unregister_ipv6_notifier();
 
 	bond_destroy_sysfs();
 
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index e400d7d..aaf2927 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -48,6 +48,7 @@ extern struct list_head bond_dev_list;
 extern struct bond_params bonding_defaults;
 extern struct bond_parm_tbl bond_mode_tbl[];
 extern struct bond_parm_tbl bond_lacp_tbl[];
+extern struct bond_parm_tbl ad_select_tbl[];
 extern struct bond_parm_tbl xmit_hashtype_tbl[];
 extern struct bond_parm_tbl arp_validate_tbl[];
 extern struct bond_parm_tbl fail_over_mac_tbl[];
@@ -944,6 +945,53 @@ out:
 }
 static DEVICE_ATTR(lacp_rate, S_IRUGO | S_IWUSR, bonding_show_lacp, bonding_store_lacp);
 
+static ssize_t bonding_show_ad_select(struct device *d,
+				      struct device_attribute *attr,
+				      char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%s %d\n",
+		ad_select_tbl[bond->params.ad_select].modename,
+		bond->params.ad_select);
+}
+
+
+static ssize_t bonding_store_ad_select(struct device *d,
+				       struct device_attribute *attr,
+				       const char *buf, size_t count)
+{
+	int new_value, ret = count;
+	struct bonding *bond = to_bond(d);
+
+	if (bond->dev->flags & IFF_UP) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Unable to update ad_select because interface "
+		       "is up.\n", bond->dev->name);
+		ret = -EPERM;
+		goto out;
+	}
+
+	new_value = bond_parse_parm(buf, ad_select_tbl);
+
+	if (new_value != -1) {
+		bond->params.ad_select = new_value;
+		printk(KERN_INFO DRV_NAME
+		       ": %s: Setting ad_select to %s (%d).\n",
+		       bond->dev->name, ad_select_tbl[new_value].modename,
+		       new_value);
+	} else {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Ignoring invalid ad_select value %.*s.\n",
+		       bond->dev->name, (int)strlen(buf) - 1, buf);
+		ret = -EINVAL;
+	}
+out:
+	return ret;
+}
+
+static DEVICE_ATTR(ad_select, S_IRUGO | S_IWUSR, bonding_show_ad_select, bonding_store_ad_select);
+
 /*
  * Show and set the number of grat ARP to send after a failover event.
  */
@@ -983,6 +1031,47 @@ out:
 	return ret;
 }
 static DEVICE_ATTR(num_grat_arp, S_IRUGO | S_IWUSR, bonding_show_n_grat_arp, bonding_store_n_grat_arp);
+
+/*
+ * Show and set the number of unsolicted NA's to send after a failover event.
+ */
+static ssize_t bonding_show_n_unsol_na(struct device *d,
+				       struct device_attribute *attr,
+				       char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%d\n", bond->params.num_unsol_na);
+}
+
+static ssize_t bonding_store_n_unsol_na(struct device *d,
+					struct device_attribute *attr,
+					const char *buf, size_t count)
+{
+	int new_value, ret = count;
+	struct bonding *bond = to_bond(d);
+
+	if (sscanf(buf, "%d", &new_value) != 1) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: no num_unsol_na value specified.\n",
+		       bond->dev->name);
+		ret = -EINVAL;
+		goto out;
+	}
+	if (new_value < 0 || new_value > 255) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Invalid num_unsol_na value %d not in range 0-255; rejected.\n",
+		       bond->dev->name, new_value);
+		ret = -EINVAL;
+		goto out;
+	} else {
+		bond->params.num_unsol_na = new_value;
+	}
+out:
+	return ret;
+}
+static DEVICE_ATTR(num_unsol_na, S_IRUGO | S_IWUSR, bonding_show_n_unsol_na, bonding_store_n_unsol_na);
+
 /*
  * Show and set the MII monitor interval.  There are two tricky bits
  * here.  First, if MII monitoring is activated, then we must disable
@@ -1418,8 +1507,10 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_downdelay.attr,
 	&dev_attr_updelay.attr,
 	&dev_attr_lacp_rate.attr,
+	&dev_attr_ad_select.attr,
 	&dev_attr_xmit_hash_policy.attr,
 	&dev_attr_num_grat_arp.attr,
+	&dev_attr_num_unsol_na.attr,
 	&dev_attr_miimon.attr,
 	&dev_attr_primary.attr,
 	&dev_attr_use_carrier.attr,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ffb668d..b5eb8e6 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -19,16 +19,19 @@
 #include <linux/proc_fs.h>
 #include <linux/if_bonding.h>
 #include <linux/kobject.h>
+#include <linux/in6.h>
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.3.0"
-#define DRV_RELDATE	"June 10, 2008"
+#define DRV_VERSION	"3.5.0"
+#define DRV_RELDATE	"November 4, 2008"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
 #define BOND_MAX_ARP_TARGETS	16
 
+extern struct list_head bond_dev_list;
+
 #ifdef BONDING_DEBUG
 #define dprintk(fmt, args...) \
 	printk(KERN_DEBUG     \
@@ -126,6 +129,7 @@ struct bond_params {
 	int xmit_policy;
 	int miimon;
 	int num_grat_arp;
+	int num_unsol_na;
 	int arp_interval;
 	int arp_validate;
 	int use_carrier;
@@ -133,6 +137,7 @@ struct bond_params {
 	int updelay;
 	int downdelay;
 	int lacp_fast;
+	int ad_select;
 	char primary[IFNAMSIZ];
 	__be32 arp_targets[BOND_MAX_ARP_TARGETS];
 };
@@ -148,6 +153,9 @@ struct vlan_entry {
 	struct list_head vlan_list;
 	__be32 vlan_ip;
 	unsigned short vlan_id;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	struct in6_addr vlan_ipv6;
+#endif
 };
 
 struct slave {
@@ -195,6 +203,7 @@ struct bonding {
 	rwlock_t curr_slave_lock;
 	s8       kill_timers;
 	s8	 send_grat_arp;
+	s8	 send_unsol_na;
 	s8	 setup_by_slave;
 	struct   net_device_stats stats;
 #ifdef CONFIG_PROC_FS
@@ -218,6 +227,9 @@ struct bonding {
 	struct   delayed_work arp_work;
 	struct   delayed_work alb_work;
 	struct   delayed_work ad_work;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	struct   in6_addr master_ipv6;
+#endif
 };
 
 /**
@@ -341,5 +353,24 @@ extern struct bond_parm_tbl xmit_hashtype_tbl[];
 extern struct bond_parm_tbl arp_validate_tbl[];
 extern struct bond_parm_tbl fail_over_mac_tbl[];
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+void bond_send_unsolicited_na(struct bonding *bond);
+void bond_register_ipv6_notifier(void);
+void bond_unregister_ipv6_notifier(void);
+#else
+static inline void bond_send_unsolicited_na(struct bonding *bond)
+{
+	return;
+}
+static inline void bond_register_ipv6_notifier(void)
+{
+	return;
+}
+static inline void bond_unregister_ipv6_notifier(void)
+{
+	return;
+}
+#endif
+
 #endif /* _LINUX_BONDING_H */
 
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 002d918..9930d5f 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0095"
+#define DRV_VERSION	"EHEA_0096"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index 9d00687..3c0ec82 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -653,7 +653,7 @@ static int ehea_update_busmap(unsigned long pfn, unsigned long nr_pages, int add
 		int top = ehea_calc_index(i, EHEA_TOP_INDEX_SHIFT);
 		int dir = ehea_calc_index(i, EHEA_DIR_INDEX_SHIFT);
 		int idx = i & EHEA_INDEX_MASK;
-		
+
 		if (add) {
 			int ret = ehea_init_bmap(ehea_bmap, top, dir);
 			if (ret)
@@ -780,7 +780,7 @@ void ehea_destroy_busmap(void)
 
 	kfree(ehea_bmap);
 	ehea_bmap = NULL;
-out_destroy:	
+out_destroy:
 	mutex_unlock(&ehea_busmap_mutex);
 }
 
@@ -858,10 +858,10 @@ static u64 ehea_reg_mr_sections(int top, int dir, u64 *pt,
 	for (idx = 0; idx < EHEA_MAP_ENTRIES; idx++) {
 		if (!ehea_bmap->top[top]->dir[dir]->ent[idx])
 			continue;
-		
+
 		hret = ehea_reg_mr_section(top, dir, idx, pt, adapter, mr);
 		if ((hret != H_SUCCESS) && (hret != H_PAGE_REGISTERED))
-			    	return hret;
+			return hret;
 	}
 	return hret;
 }
@@ -879,7 +879,7 @@ static u64 ehea_reg_mr_dir_sections(int top, u64 *pt,
 
 		hret = ehea_reg_mr_sections(top, dir, pt, adapter, mr);
 		if ((hret != H_SUCCESS) && (hret != H_PAGE_REGISTERED))
-			    	return hret;
+			return hret;
 	}
 	return hret;
 }
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index e4f8fe3..69dcfbb 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -125,6 +125,7 @@ typedef struct local_info_t {
     u_short tx_queue_len;
     cardtype_t cardtype;
     u_short sent;
+    u_char __iomem *base;
 } local_info_t;
 
 #define MC_FILTERBREAK 64
@@ -242,6 +243,7 @@ static int fmvj18x_probe(struct pcmcia_device *link)
     lp = netdev_priv(dev);
     link->priv = dev;
     lp->p_dev = link;
+    lp->base = NULL;
 
     /* The io structure describes IO port mapping */
     link->io.NumPorts1 = 32;
@@ -442,8 +444,10 @@ static int fmvj18x_config(struct pcmcia_device *link)
     dev->irq = link->irq.AssignedIRQ;
     dev->base_addr = link->io.BasePort1;
 
-    if (link->io.BasePort2 != 0)
-	fmvj18x_setup_mfc(link);
+    if (link->io.BasePort2 != 0) {
+	ret = fmvj18x_setup_mfc(link);
+	if (ret != 0) goto failed;
+    }
 
     ioaddr = dev->base_addr;
 
@@ -610,10 +614,10 @@ static int fmvj18x_setup_mfc(struct pcmcia_device *link)
 {
     win_req_t req;
     memreq_t mem;
-    u_char __iomem *base;
-    int i, j;
+    int i;
     struct net_device *dev = link->priv;
     unsigned int ioaddr;
+    local_info_t *lp = netdev_priv(dev);
 
     /* Allocate a small memory window */
     req.Attributes = WIN_DATA_WIDTH_8|WIN_MEMORY_TYPE_AM|WIN_ENABLE;
@@ -625,25 +629,32 @@ static int fmvj18x_setup_mfc(struct pcmcia_device *link)
 	return -1;
     }
 
-    base = ioremap(req.Base, req.Size);
+    lp->base = ioremap(req.Base, req.Size);
+    if (lp->base == NULL) {
+	printk(KERN_NOTICE "fmvj18x_cs: ioremap failed\n");
+	return -1;
+    }
+
     mem.Page = 0;
     mem.CardOffset = 0;
-    pcmcia_map_mem_page(link->win, &mem);
-
+    i = pcmcia_map_mem_page(link->win, &mem);
+    if (i != 0) {
+	iounmap(lp->base);
+	lp->base = NULL;
+	cs_error(link, MapMemPage, i);
+	return -1;
+    }
+    
     ioaddr = dev->base_addr;
-    writeb(0x47, base+0x800);	/* Config Option Register of LAN */
-    writeb(0x0, base+0x802);	/* Config and Status Register */
+    writeb(0x47, lp->base+0x800);	/* Config Option Register of LAN */
+    writeb(0x0,  lp->base+0x802);	/* Config and Status Register */
 
-    writeb(ioaddr & 0xff, base+0x80a);		/* I/O Base(Low) of LAN */
-    writeb((ioaddr >> 8) & 0xff, base+0x80c);	/* I/O Base(High) of LAN */
+    writeb(ioaddr & 0xff, lp->base+0x80a);	  /* I/O Base(Low) of LAN */
+    writeb((ioaddr >> 8) & 0xff, lp->base+0x80c); /* I/O Base(High) of LAN */
    
-    writeb(0x45, base+0x820);	/* Config Option Register of Modem */
-    writeb(0x8, base+0x822);	/* Config and Status Register */
+    writeb(0x45, lp->base+0x820);	/* Config Option Register of Modem */
+    writeb(0x8,  lp->base+0x822);	/* Config and Status Register */
 
-    iounmap(base);
-    j = pcmcia_release_window(link->win);
-    if (j != 0)
-	cs_error(link, ReleaseWindow, j);
     return 0;
 
 }
@@ -651,8 +662,25 @@ static int fmvj18x_setup_mfc(struct pcmcia_device *link)
 
 static void fmvj18x_release(struct pcmcia_device *link)
 {
-	DEBUG(0, "fmvj18x_release(0x%p)\n", link);
-	pcmcia_disable_device(link);
+
+    struct net_device *dev = link->priv;
+    local_info_t *lp = netdev_priv(dev);
+    u_char __iomem *tmp;
+    int j;
+
+    DEBUG(0, "fmvj18x_release(0x%p)\n", link);
+
+    if (lp->base != NULL) {
+	tmp = lp->base;
+	lp->base = NULL;    /* set NULL before iounmap */
+	iounmap(tmp);
+	j = pcmcia_release_window(link->win);
+	if (j != 0)
+	    cs_error(link, ReleaseWindow, j);
+    }
+
+    pcmcia_disable_device(link);
+
 }
 
 static int fmvj18x_suspend(struct pcmcia_device *link)
@@ -783,6 +811,13 @@ static irqreturn_t fjn_interrupt(int dummy, void *dev_id)
 
     outb(D_TX_INTR, ioaddr + TX_INTR);
     outb(D_RX_INTR, ioaddr + RX_INTR);
+
+    if (lp->base != NULL) {
+	/* Ack interrupt for multifunction card */
+	writeb(0x01, lp->base+0x802);
+	writeb(0x09, lp->base+0x822);
+    }
+
     return IRQ_HANDLED;
 
 } /* fjn_interrupt */
diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 73baa7a..c05d38d 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -126,6 +126,27 @@ static struct phy_driver lan8700_driver = {
 	.driver		= { .owner = THIS_MODULE, }
 };
 
+static struct phy_driver lan911x_int_driver = {
+	.phy_id		= 0x0007c0d0, /* OUI=0x00800f, Model#=0x0d */
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "SMSC LAN911x Internal PHY",
+
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
+				| SUPPORTED_Asym_Pause),
+	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
+
+	/* basic functions */
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.config_init	= smsc_phy_config_init,
+
+	/* IRQ related */
+	.ack_interrupt	= smsc_phy_ack_interrupt,
+	.config_intr	= smsc_phy_config_intr,
+
+	.driver		= { .owner = THIS_MODULE, }
+};
+
 static int __init smsc_init(void)
 {
 	int ret;
@@ -142,8 +163,14 @@ static int __init smsc_init(void)
 	if (ret)
 		goto err3;
 
+	ret = phy_driver_register (&lan911x_int_driver);
+	if (ret)
+		goto err4;
+
 	return 0;
 
+err4:
+	phy_driver_unregister (&lan8700_driver);
 err3:
 	phy_driver_unregister (&lan8187_driver);
 err2:
@@ -154,6 +181,7 @@ err1:
 
 static void __exit smsc_exit(void)
 {
+	phy_driver_unregister (&lan911x_int_driver);
 	phy_driver_unregister (&lan8700_driver);
 	phy_driver_unregister (&lan8187_driver);
 	phy_driver_unregister (&lan83c185_driver);
diff --git a/drivers/net/sfc/Kconfig b/drivers/net/sfc/Kconfig
index 3be13b5..3e25fb3 100644
--- a/drivers/net/sfc/Kconfig
+++ b/drivers/net/sfc/Kconfig
@@ -12,3 +12,11 @@ config SFC
 
 	  To compile this driver as a module, choose M here.  The module
 	  will be called sfc.
+config SFC_MTD
+	bool "Solarflare Solarstorm SFC4000 flash MTD support"
+	depends on SFC && MTD
+	default y
+	help
+	  This exposes the on-board flash memory as an MTD device (e.g.
+          /dev/mtd1).  This makes it possible to upload new boot code
+          to the NIC.
diff --git a/drivers/net/sfc/Makefile b/drivers/net/sfc/Makefile
index c8f5704..e507daa 100644
--- a/drivers/net/sfc/Makefile
+++ b/drivers/net/sfc/Makefile
@@ -1,5 +1,6 @@
 sfc-y			+= efx.o falcon.o tx.o rx.o falcon_xmac.o \
 			   selftest.o ethtool.o xfp_phy.o \
 			   mdio_10g.o tenxpress.o boards.o sfe4001.o
+sfc-$(CONFIG_SFC_MTD)	+= mtd.o
 
 obj-$(CONFIG_SFC)	+= sfc.o
diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/boards.c
index 99e6023..edf0262 100644
--- a/drivers/net/sfc/boards.c
+++ b/drivers/net/sfc/boards.c
@@ -11,6 +11,7 @@
 #include "phy.h"
 #include "boards.h"
 #include "efx.h"
+#include "workarounds.h"
 
 /* Macros for unpacking the board revision */
 /* The revision info is in host byte order. */
@@ -52,9 +53,128 @@ static void board_blink(struct efx_nic *efx, bool blink)
 }
 
 /*****************************************************************************
+ * Support for LM87 sensor chip used on several boards
+ */
+#define LM87_REG_ALARMS1		0x41
+#define LM87_REG_ALARMS2		0x42
+#define LM87_IN_LIMITS(nr, _min, _max)			\
+	0x2B + (nr) * 2, _max, 0x2C + (nr) * 2, _min
+#define LM87_AIN_LIMITS(nr, _min, _max)			\
+	0x3B + (nr), _max, 0x1A + (nr), _min
+#define LM87_TEMP_INT_LIMITS(_min, _max)		\
+	0x39, _max, 0x3A, _min
+#define LM87_TEMP_EXT1_LIMITS(_min, _max)		\
+	0x37, _max, 0x38, _min
+
+#define LM87_ALARM_TEMP_INT		0x10
+#define LM87_ALARM_TEMP_EXT1		0x20
+
+#if defined(CONFIG_SENSORS_LM87) || defined(CONFIG_SENSORS_LM87_MODULE)
+
+static int efx_init_lm87(struct efx_nic *efx, struct i2c_board_info *info,
+			 const u8 *reg_values)
+{
+	struct i2c_client *client = i2c_new_device(&efx->i2c_adap, info);
+	int rc;
+
+	if (!client)
+		return -EIO;
+
+	while (*reg_values) {
+		u8 reg = *reg_values++;
+		u8 value = *reg_values++;
+		rc = i2c_smbus_write_byte_data(client, reg, value);
+		if (rc)
+			goto err;
+	}
+
+	efx->board_info.hwmon_client = client;
+	return 0;
+
+err:
+	i2c_unregister_device(client);
+	return rc;
+}
+
+static void efx_fini_lm87(struct efx_nic *efx)
+{
+	i2c_unregister_device(efx->board_info.hwmon_client);
+}
+
+static int efx_check_lm87(struct efx_nic *efx, unsigned mask)
+{
+	struct i2c_client *client = efx->board_info.hwmon_client;
+	s32 alarms1, alarms2;
+
+	/* If link is up then do not monitor temperature */
+	if (EFX_WORKAROUND_7884(efx) && efx->link_up)
+		return 0;
+
+	alarms1 = i2c_smbus_read_byte_data(client, LM87_REG_ALARMS1);
+	alarms2 = i2c_smbus_read_byte_data(client, LM87_REG_ALARMS2);
+	if (alarms1 < 0)
+		return alarms1;
+	if (alarms2 < 0)
+		return alarms2;
+	alarms1 &= mask;
+	alarms2 &= mask >> 8;
+	if (alarms1 || alarms2) {
+		EFX_ERR(efx,
+			"LM87 detected a hardware failure (status %02x:%02x)"
+			"%s%s\n",
+			alarms1, alarms2,
+			(alarms1 & LM87_ALARM_TEMP_INT) ? " INTERNAL" : "",
+			(alarms1 & LM87_ALARM_TEMP_EXT1) ? " EXTERNAL" : "");
+		return -ERANGE;
+	}
+
+	return 0;
+}
+
+#else /* !CONFIG_SENSORS_LM87 */
+
+static inline int
+efx_init_lm87(struct efx_nic *efx, struct i2c_board_info *info,
+	      const u8 *reg_values)
+{
+	return 0;
+}
+static inline void efx_fini_lm87(struct efx_nic *efx)
+{
+}
+static inline int efx_check_lm87(struct efx_nic *efx, unsigned mask)
+{
+	return 0;
+}
+
+#endif /* CONFIG_SENSORS_LM87 */
+
+/*****************************************************************************
  * Support for the SFE4002
  *
  */
+static u8 sfe4002_lm87_channel = 0x03; /* use AIN not FAN inputs */
+
+static const u8 sfe4002_lm87_regs[] = {
+	LM87_IN_LIMITS(0, 0x83, 0x91),		/* 2.5V:  1.8V +/- 5% */
+	LM87_IN_LIMITS(1, 0x51, 0x5a),		/* Vccp1: 1.2V +/- 5% */
+	LM87_IN_LIMITS(2, 0xb6, 0xca),		/* 3.3V:  3.3V +/- 5% */
+	LM87_IN_LIMITS(3, 0xb0, 0xc9),		/* 5V:    4.6-5.2V */
+	LM87_IN_LIMITS(4, 0xb0, 0xe0),		/* 12V:   11-14V */
+	LM87_IN_LIMITS(5, 0x44, 0x4b),		/* Vccp2: 1.0V +/- 5% */
+	LM87_AIN_LIMITS(0, 0xa0, 0xb2),		/* AIN1:  1.66V +/- 5% */
+	LM87_AIN_LIMITS(1, 0x91, 0xa1),		/* AIN2:  1.5V +/- 5% */
+	LM87_TEMP_INT_LIMITS(10, 60),		/* board */
+	LM87_TEMP_EXT1_LIMITS(10, 70),		/* Falcon */
+	0
+};
+
+static struct i2c_board_info sfe4002_hwmon_info = {
+	I2C_BOARD_INFO("lm87", 0x2e),
+	.platform_data	= &sfe4002_lm87_channel,
+	.irq		= -1,
+};
+
 /****************************************************************************/
 /* LED allocations. Note that on rev A0 boards the schematic and the reality
  * differ: red and green are swapped. Below is the fixed (A1) layout (there
@@ -84,11 +204,27 @@ static void sfe4002_fault_led(struct efx_nic *efx, bool state)
 			QUAKE_LED_OFF);
 }
 
+static int sfe4002_check_hw(struct efx_nic *efx)
+{
+	/* A0 board rev. 4002s report a temperature fault the whole time
+	 * (bad sensor) so we mask it out. */
+	unsigned alarm_mask =
+		(efx->board_info.major == 0 && efx->board_info.minor == 0) ?
+		~LM87_ALARM_TEMP_EXT1 : ~0;
+
+	return efx_check_lm87(efx, alarm_mask);
+}
+
 static int sfe4002_init(struct efx_nic *efx)
 {
+	int rc = efx_init_lm87(efx, &sfe4002_hwmon_info, sfe4002_lm87_regs);
+	if (rc)
+		return rc;
+	efx->board_info.monitor = sfe4002_check_hw;
 	efx->board_info.init_leds = sfe4002_init_leds;
 	efx->board_info.set_fault_led = sfe4002_fault_led;
 	efx->board_info.blink = board_blink;
+	efx->board_info.fini = efx_fini_lm87;
 	return 0;
 }
 
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 5b05789..ac7bdbf 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -77,11 +77,6 @@ static int napi_weight = 64;
  */
 unsigned int efx_monitor_interval = 1 * HZ;
 
-/* This controls whether or not the hardware monitor will trigger a
- * reset when it detects an error condition.
- */
-static unsigned int monitor_reset = true;
-
 /* This controls whether or not the driver will initialise devices
  * with invalid MAC addresses stored in the EEPROM or flash.  If true,
  * such devices will be initialised with a random locally-generated
@@ -1176,17 +1171,6 @@ static void efx_monitor(struct work_struct *data)
 		rc = falcon_check_xmac(efx);
 	mutex_unlock(&efx->mac_lock);
 
-	if (rc) {
-		if (monitor_reset) {
-			EFX_ERR(efx, "hardware monitor detected a fault: "
-				"triggering reset\n");
-			efx_schedule_reset(efx, RESET_TYPE_MONITOR);
-		} else {
-			EFX_ERR(efx, "hardware monitor detected a fault, "
-				"skipping reset\n");
-		}
-	}
-
 	queue_delayed_work(efx->workqueue, &efx->monitor_work,
 			   efx_monitor_interval);
 }
@@ -1358,12 +1342,11 @@ static void efx_watchdog(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
-	EFX_ERR(efx, "TX stuck with stop_count=%d port_enabled=%d: %s\n",
-		atomic_read(&efx->netif_stop_count), efx->port_enabled,
-		monitor_reset ? "resetting channels" : "skipping reset");
+	EFX_ERR(efx, "TX stuck with stop_count=%d port_enabled=%d:"
+		" resetting channels\n",
+		atomic_read(&efx->netif_stop_count), efx->port_enabled);
 
-	if (monitor_reset)
-		efx_schedule_reset(efx, RESET_TYPE_MONITOR);
+	efx_schedule_reset(efx, RESET_TYPE_TX_WATCHDOG);
 }
 
 
@@ -1459,6 +1442,7 @@ static int efx_netdev_event(struct notifier_block *this,
 		struct efx_nic *efx = netdev_priv(net_dev);
 
 		strcpy(efx->name, net_dev->name);
+		efx_mtd_rename(efx);
 	}
 
 	return NOTIFY_DONE;
@@ -1550,6 +1534,7 @@ void efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 
 	efx_stop_all(efx);
 	mutex_lock(&efx->mac_lock);
+	mutex_lock(&efx->spi_lock);
 
 	rc = falcon_xmac_get_settings(efx, ecmd);
 	if (rc)
@@ -1582,6 +1567,7 @@ int efx_reset_up(struct efx_nic *efx, struct ethtool_cmd *ecmd, bool ok)
 			EFX_ERR(efx, "could not restore PHY settings\n");
 	}
 
+	mutex_unlock(&efx->spi_lock);
 	mutex_unlock(&efx->mac_lock);
 
 	if (ok) {
@@ -1777,6 +1763,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	memset(efx, 0, sizeof(*efx));
 	spin_lock_init(&efx->biu_lock);
 	spin_lock_init(&efx->phy_lock);
+	mutex_init(&efx->spi_lock);
 	INIT_WORK(&efx->reset_work, efx_reset_work);
 	INIT_DELAYED_WORK(&efx->monitor_work, efx_monitor);
 	efx->pci_dev = pci_dev;
@@ -1911,6 +1898,8 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 	if (!efx)
 		return;
 
+	efx_mtd_remove(efx);
+
 	/* Mark the NIC as fini, then stop the interface */
 	rtnl_lock();
 	efx->state = STATE_FINI;
@@ -2077,6 +2066,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 
 	EFX_LOG(efx, "initialisation successful\n");
 
+	efx_mtd_probe(efx); /* allowed to fail */
 	return 0;
 
  fail5:
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index d02937b..dd0d45b 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -58,6 +58,16 @@ extern int efx_port_dummy_op_int(struct efx_nic *efx);
 extern void efx_port_dummy_op_void(struct efx_nic *efx);
 extern void efx_port_dummy_op_blink(struct efx_nic *efx, bool blink);
 
+/* MTD */
+#ifdef CONFIG_SFC_MTD
+extern int efx_mtd_probe(struct efx_nic *efx);
+extern void efx_mtd_rename(struct efx_nic *efx);
+extern void efx_mtd_remove(struct efx_nic *efx);
+#else
+static inline int efx_mtd_probe(struct efx_nic *efx) { return 0; }
+static inline void efx_mtd_rename(struct efx_nic *efx) {}
+static inline void efx_mtd_remove(struct efx_nic *efx) {}
+#endif
 
 extern unsigned int efx_monitor_interval;
 
diff --git a/drivers/net/sfc/enum.h b/drivers/net/sfc/enum.h
index cec15db..41e758e 100644
--- a/drivers/net/sfc/enum.h
+++ b/drivers/net/sfc/enum.h
@@ -72,7 +72,7 @@ extern const char *efx_loopback_mode_names[];
  * @RESET_TYPE_ALL: reset everything but PCI core blocks
  * @RESET_TYPE_WORLD: reset everything, save & restore PCI config
  * @RESET_TYPE_DISABLE: disable NIC
- * @RESET_TYPE_MONITOR: reset due to hardware monitor
+ * @RESET_TYPE_TX_WATCHDOG: reset due to TX watchdog
  * @RESET_TYPE_INT_ERROR: reset due to internal error
  * @RESET_TYPE_RX_RECOVERY: reset to recover from RX datapath errors
  * @RESET_TYPE_RX_DESC_FETCH: pcie error during rx descriptor fetch
@@ -86,7 +86,7 @@ enum reset_type {
 	RESET_TYPE_WORLD = 2,
 	RESET_TYPE_DISABLE = 3,
 	RESET_TYPE_MAX_METHOD,
-	RESET_TYPE_MONITOR,
+	RESET_TYPE_TX_WATCHDOG,
 	RESET_TYPE_INT_ERROR,
 	RESET_TYPE_RX_RECOVERY,
 	RESET_TYPE_RX_DESC_FETCH,
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index fa98af5..abd8fcd 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -172,10 +172,7 @@ static struct efx_ethtool_stat efx_ethtool_stats[] = {
 /* Number of ethtool statistics */
 #define EFX_ETHTOOL_NUM_STATS ARRAY_SIZE(efx_ethtool_stats)
 
-/* EEPROM range with gPXE configuration */
 #define EFX_ETHTOOL_EEPROM_MAGIC 0xEFAB
-#define EFX_ETHTOOL_EEPROM_MIN 0x100U
-#define EFX_ETHTOOL_EEPROM_MAX 0x400U
 
 /**************************************************************************
  *
@@ -545,8 +542,8 @@ static int efx_ethtool_get_eeprom_len(struct net_device *net_dev)
 
 	if (!spi)
 		return 0;
-	return min(spi->size, EFX_ETHTOOL_EEPROM_MAX) -
-		min(spi->size, EFX_ETHTOOL_EEPROM_MIN);
+	return min(spi->size, EFX_EEPROM_BOOTCONFIG_END) -
+		min(spi->size, EFX_EEPROM_BOOTCONFIG_START);
 }
 
 static int efx_ethtool_get_eeprom(struct net_device *net_dev,
@@ -557,8 +554,10 @@ static int efx_ethtool_get_eeprom(struct net_device *net_dev,
 	size_t len;
 	int rc;
 
-	rc = falcon_spi_read(spi, eeprom->offset + EFX_ETHTOOL_EEPROM_MIN,
+	mutex_lock(&efx->spi_lock);
+	rc = falcon_spi_read(spi, eeprom->offset + EFX_EEPROM_BOOTCONFIG_START,
 			     eeprom->len, &len, buf);
+	mutex_unlock(&efx->spi_lock);
 	eeprom->magic = EFX_ETHTOOL_EEPROM_MAGIC;
 	eeprom->len = len;
 	return rc;
@@ -575,8 +574,10 @@ static int efx_ethtool_set_eeprom(struct net_device *net_dev,
 	if (eeprom->magic != EFX_ETHTOOL_EEPROM_MAGIC)
 		return -EINVAL;
 
-	rc = falcon_spi_write(spi, eeprom->offset + EFX_ETHTOOL_EEPROM_MIN,
+	mutex_lock(&efx->spi_lock);
+	rc = falcon_spi_write(spi, eeprom->offset + EFX_EEPROM_BOOTCONFIG_START,
 			      eeprom->len, &len, buf);
+	mutex_unlock(&efx->spi_lock);
 	eeprom->len = len;
 	return rc;
 }
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 31ed1f4..71e0bed 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1628,9 +1628,9 @@ static int falcon_spi_wait(struct efx_nic *efx)
 	}
 }
 
-static int falcon_spi_cmd(const struct efx_spi_device *spi,
-			  unsigned int command, int address,
-			  const void *in, void *out, unsigned int len)
+int falcon_spi_cmd(const struct efx_spi_device *spi,
+		   unsigned int command, int address,
+		   const void *in, void *out, unsigned int len)
 {
 	struct efx_nic *efx = spi->efx;
 	bool addressed = (address >= 0);
@@ -1641,6 +1641,7 @@ static int falcon_spi_cmd(const struct efx_spi_device *spi,
 	/* Input validation */
 	if (len > FALCON_SPI_MAX_LEN)
 		return -EINVAL;
+	BUG_ON(!mutex_is_locked(&efx->spi_lock));
 
 	/* Check SPI not currently being accessed */
 	rc = falcon_spi_wait(efx);
@@ -1699,8 +1700,7 @@ efx_spi_munge_command(const struct efx_spi_device *spi,
 	return command | (((address >> 8) & spi->munge_address) << 3);
 }
 
-
-static int falcon_spi_fast_wait(const struct efx_spi_device *spi)
+int falcon_spi_fast_wait(const struct efx_spi_device *spi)
 {
 	u8 status;
 	int i, rc;
@@ -2253,13 +2253,15 @@ int falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 	__le16 *word, *limit;
 	u32 csum;
 
-	region = kmalloc(NVCONFIG_END, GFP_KERNEL);
+	region = kmalloc(FALCON_NVCONFIG_END, GFP_KERNEL);
 	if (!region)
 		return -ENOMEM;
 	nvconfig = region + NVCONFIG_OFFSET;
 
 	spi = efx->spi_flash ? efx->spi_flash : efx->spi_eeprom;
-	rc = falcon_spi_read(spi, 0, NVCONFIG_END, NULL, region);
+	mutex_lock(&efx->spi_lock);
+	rc = falcon_spi_read(spi, 0, FALCON_NVCONFIG_END, NULL, region);
+	mutex_unlock(&efx->spi_lock);
 	if (rc) {
 		EFX_ERR(efx, "Failed to read %s\n",
 			efx->spi_flash ? "flash" : "EEPROM");
@@ -2283,7 +2285,7 @@ int falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 		limit = (__le16 *) (nvconfig + 1);
 	} else {
 		word = region;
-		limit = region + NVCONFIG_END;
+		limit = region + FALCON_NVCONFIG_END;
 	}
 	for (csum = 0; word < limit; ++word)
 		csum += le16_to_cpu(*word);
@@ -2555,6 +2557,11 @@ static int falcon_spi_device_init(struct efx_nic *efx,
 			SPI_DEV_TYPE_FIELD(device_type, SPI_DEV_TYPE_ADDR_LEN);
 		spi_device->munge_address = (spi_device->size == 1 << 9 &&
 					     spi_device->addr_len == 1);
+		spi_device->erase_command =
+			SPI_DEV_TYPE_FIELD(device_type, SPI_DEV_TYPE_ERASE_CMD);
+		spi_device->erase_size =
+			1 << SPI_DEV_TYPE_FIELD(device_type,
+						SPI_DEV_TYPE_ERASE_SIZE);
 		spi_device->block_size =
 			1 << SPI_DEV_TYPE_FIELD(device_type,
 						SPI_DEV_TYPE_BLOCK_SIZE);
diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_hwdefs.h
index 5d584b0..040e70e 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -1150,7 +1150,6 @@ struct falcon_nvconfig_board_v3 {
 	(((type) >> EFX_LOW_BIT(field)) & EFX_MASK32(EFX_WIDTH(field)))
 
 #define NVCONFIG_OFFSET 0x300
-#define NVCONFIG_END 0x400
 
 #define NVCONFIG_BOARD_MAGIC_NUM 0xFA1C
 struct falcon_nvconfig {
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 003e48d..19e2521 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -260,6 +260,41 @@ void mdio_clause45_phy_reconfigure(struct efx_nic *efx)
 				    MDIO_MMDREG_CTRL1, ctrl2);
 }
 
+static void mdio_clause45_set_mmd_lpower(struct efx_nic *efx,
+					 int lpower, int mmd)
+{
+	int phy = efx->mii.phy_id;
+	int stat = mdio_clause45_read(efx, phy, mmd, MDIO_MMDREG_STAT1);
+	int ctrl1, ctrl2;
+
+	EFX_TRACE(efx, "Setting low power mode for MMD %d to %d\n",
+		  mmd, lpower);
+
+	if (stat & (1 << MDIO_MMDREG_STAT1_LPABLE_LBN)) {
+		ctrl1 = ctrl2 = mdio_clause45_read(efx, phy,
+						   mmd, MDIO_MMDREG_CTRL1);
+		if (lpower)
+			ctrl2 |= (1 << MDIO_MMDREG_CTRL1_LPOWER_LBN);
+		else
+			ctrl2 &= ~(1 << MDIO_MMDREG_CTRL1_LPOWER_LBN);
+		if (ctrl1 != ctrl2)
+			mdio_clause45_write(efx, phy, mmd,
+					    MDIO_MMDREG_CTRL1, ctrl2);
+	}
+}
+
+void mdio_clause45_set_mmds_lpower(struct efx_nic *efx,
+				   int low_power, unsigned int mmd_mask)
+{
+	int mmd = 0;
+	while (mmd_mask) {
+		if (mmd_mask & 1)
+			mdio_clause45_set_mmd_lpower(efx, low_power, mmd);
+		mmd_mask = (mmd_mask >> 1);
+		mmd++;
+	}
+}
+
 /**
  * mdio_clause45_get_settings - Read (some of) the PHY settings over MDIO.
  * @efx:		Efx NIC
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index 19c42ea..db9f358 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -54,6 +54,9 @@
 /* Loopback bit for WIS, PCS, PHYSX and DTEXS */
 #define MDIO_MMDREG_CTRL1_LBACK_LBN	(14)
 #define MDIO_MMDREG_CTRL1_LBACK_WIDTH	(1)
+/* Low power */
+#define MDIO_MMDREG_CTRL1_LPOWER_LBN	(11)
+#define MDIO_MMDREG_CTRL1_LPOWER_WIDTH	(1)
 
 /* Bits in MMDREG_STAT1 */
 #define MDIO_MMDREG_STAT1_FAULT_LBN	(7)
@@ -240,6 +243,10 @@ extern void mdio_clause45_transmit_disable(struct efx_nic *efx);
 /* Generic part of reconfigure: set/clear loopback bits */
 extern void mdio_clause45_phy_reconfigure(struct efx_nic *efx);
 
+/* Set the power state of the specified MMDs */
+extern void mdio_clause45_set_mmds_lpower(struct efx_nic *efx,
+					  int low_power, unsigned int mmd_mask);
+
 /* Read (some of) the PHY settings over MDIO */
 extern void mdio_clause45_get_settings(struct efx_nic *efx,
 				       struct ethtool_cmd *ecmd);
diff --git a/drivers/net/sfc/mtd.c b/drivers/net/sfc/mtd.c
new file mode 100644
index 0000000..a1e6c28
--- /dev/null
+++ b/drivers/net/sfc/mtd.c
@@ -0,0 +1,268 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/module.h>
+#include <linux/mtd/mtd.h>
+#include <linux/delay.h>
+
+#define EFX_DRIVER_NAME "sfc_mtd"
+#include "net_driver.h"
+#include "spi.h"
+
+#define EFX_SPI_VERIFY_BUF_LEN 16
+
+struct efx_mtd {
+	const struct efx_spi_device *spi;
+	struct mtd_info mtd;
+	char name[IFNAMSIZ + 20];
+};
+
+/* SPI utilities */
+
+static int efx_spi_slow_wait(struct efx_mtd *efx_mtd, bool uninterruptible)
+{
+	const struct efx_spi_device *spi = efx_mtd->spi;
+	struct efx_nic *efx = spi->efx;
+	u8 status;
+	int rc, i;
+
+	/* Wait up to 4s for flash/EEPROM to finish a slow operation. */
+	for (i = 0; i < 40; i++) {
+		__set_current_state(uninterruptible ?
+				    TASK_UNINTERRUPTIBLE : TASK_INTERRUPTIBLE);
+		schedule_timeout(HZ / 10);
+		rc = falcon_spi_cmd(spi, SPI_RDSR, -1, NULL,
+				    &status, sizeof(status));
+		if (rc)
+			return rc;
+		if (!(status & SPI_STATUS_NRDY))
+			return 0;
+		if (signal_pending(current))
+			return -EINTR;
+	}
+	EFX_ERR(efx, "timed out waiting for %s\n", efx_mtd->name);
+	return -ETIMEDOUT;
+}
+
+static int efx_spi_unlock(const struct efx_spi_device *spi)
+{
+	const u8 unlock_mask = (SPI_STATUS_BP2 | SPI_STATUS_BP1 |
+				SPI_STATUS_BP0);
+	u8 status;
+	int rc;
+
+	rc = falcon_spi_cmd(spi, SPI_RDSR, -1, NULL, &status, sizeof(status));
+	if (rc)
+		return rc;
+
+	if (!(status & unlock_mask))
+		return 0; /* already unlocked */
+
+	rc = falcon_spi_cmd(spi, SPI_WREN, -1, NULL, NULL, 0);
+	if (rc)
+		return rc;
+	rc = falcon_spi_cmd(spi, SPI_SST_EWSR, -1, NULL, NULL, 0);
+	if (rc)
+		return rc;
+
+	status &= ~unlock_mask;
+	rc = falcon_spi_cmd(spi, SPI_WRSR, -1, &status, NULL, sizeof(status));
+	if (rc)
+		return rc;
+	rc = falcon_spi_fast_wait(spi);
+	if (rc)
+		return rc;
+
+	return 0;
+}
+
+static int efx_spi_erase(struct efx_mtd *efx_mtd, loff_t start, size_t len)
+{
+	const struct efx_spi_device *spi = efx_mtd->spi;
+	unsigned pos, block_len;
+	u8 empty[EFX_SPI_VERIFY_BUF_LEN];
+	u8 buffer[EFX_SPI_VERIFY_BUF_LEN];
+	int rc;
+
+	if (len != spi->erase_size)
+		return -EINVAL;
+
+	if (spi->erase_command == 0)
+		return -EOPNOTSUPP;
+
+	rc = efx_spi_unlock(spi);
+	if (rc)
+		return rc;
+	rc = falcon_spi_cmd(spi, SPI_WREN, -1, NULL, NULL, 0);
+	if (rc)
+		return rc;
+	rc = falcon_spi_cmd(spi, spi->erase_command, start, NULL, NULL, 0);
+	if (rc)
+		return rc;
+	rc = efx_spi_slow_wait(efx_mtd, false);
+
+	/* Verify the entire region has been wiped */
+	memset(empty, 0xff, sizeof(empty));
+	for (pos = 0; pos < len; pos += block_len) {
+		block_len = min(len - pos, sizeof(buffer));
+		rc = falcon_spi_read(spi, start + pos, block_len, NULL, buffer);
+		if (rc)
+			return rc;
+		if (memcmp(empty, buffer, block_len))
+			return -EIO;
+
+		/* Avoid locking up the system */
+		cond_resched();
+		if (signal_pending(current))
+			return -EINTR;
+	}
+
+	return rc;
+}
+
+/* MTD interface */
+
+static int efx_mtd_read(struct mtd_info *mtd, loff_t start, size_t len,
+			size_t *retlen, u8 *buffer)
+{
+	struct efx_mtd *efx_mtd = mtd->priv;
+	const struct efx_spi_device *spi = efx_mtd->spi;
+	struct efx_nic *efx = spi->efx;
+	int rc;
+
+	rc = mutex_lock_interruptible(&efx->spi_lock);
+	if (rc)
+		return rc;
+	rc = falcon_spi_read(spi, FALCON_FLASH_BOOTCODE_START + start,
+			     len, retlen, buffer);
+	mutex_unlock(&efx->spi_lock);
+	return rc;
+}
+
+static int efx_mtd_erase(struct mtd_info *mtd, struct erase_info *erase)
+{
+	struct efx_mtd *efx_mtd = mtd->priv;
+	struct efx_nic *efx = efx_mtd->spi->efx;
+	int rc;
+
+	rc = mutex_lock_interruptible(&efx->spi_lock);
+	if (rc)
+		return rc;
+	rc = efx_spi_erase(efx_mtd, FALCON_FLASH_BOOTCODE_START + erase->addr,
+			   erase->len);
+	mutex_unlock(&efx->spi_lock);
+
+	if (rc == 0) {
+		erase->state = MTD_ERASE_DONE;
+	} else {
+		erase->state = MTD_ERASE_FAILED;
+		erase->fail_addr = 0xffffffff;
+	}
+	mtd_erase_callback(erase);
+	return rc;
+}
+
+static int efx_mtd_write(struct mtd_info *mtd, loff_t start,
+			 size_t len, size_t *retlen, const u8 *buffer)
+{
+	struct efx_mtd *efx_mtd = mtd->priv;
+	const struct efx_spi_device *spi = efx_mtd->spi;
+	struct efx_nic *efx = spi->efx;
+	int rc;
+
+	rc = mutex_lock_interruptible(&efx->spi_lock);
+	if (rc)
+		return rc;
+	rc = falcon_spi_write(spi, FALCON_FLASH_BOOTCODE_START + start,
+			      len, retlen, buffer);
+	mutex_unlock(&efx->spi_lock);
+	return rc;
+}
+
+static void efx_mtd_sync(struct mtd_info *mtd)
+{
+	struct efx_mtd *efx_mtd = mtd->priv;
+	struct efx_nic *efx = efx_mtd->spi->efx;
+	int rc;
+
+	mutex_lock(&efx->spi_lock);
+	rc = efx_spi_slow_wait(efx_mtd, true);
+	mutex_unlock(&efx->spi_lock);
+
+	if (rc)
+		EFX_ERR(efx, "%s sync failed (%d)\n", efx_mtd->name, rc);
+	return;
+}
+
+void efx_mtd_remove(struct efx_nic *efx)
+{
+	if (efx->spi_flash && efx->spi_flash->mtd) {
+		struct efx_mtd *efx_mtd = efx->spi_flash->mtd;
+		int rc;
+
+		for (;;) {
+			rc = del_mtd_device(&efx_mtd->mtd);
+			if (rc != -EBUSY)
+				break;
+			ssleep(1);
+		}
+		WARN_ON(rc);
+		kfree(efx_mtd);
+	}
+}
+
+void efx_mtd_rename(struct efx_nic *efx)
+{
+	if (efx->spi_flash && efx->spi_flash->mtd) {
+		struct efx_mtd *efx_mtd = efx->spi_flash->mtd;
+		snprintf(efx_mtd->name, sizeof(efx_mtd->name),
+			 "%s sfc_flash_bootrom", efx->name);
+	}
+}
+
+int efx_mtd_probe(struct efx_nic *efx)
+{
+	struct efx_spi_device *spi = efx->spi_flash;
+	struct efx_mtd *efx_mtd;
+
+	if (!spi || spi->size <= FALCON_FLASH_BOOTCODE_START)
+		return -ENODEV;
+
+	efx_mtd = kzalloc(sizeof(*efx_mtd), GFP_KERNEL);
+	if (!efx_mtd)
+		return -ENOMEM;
+
+	efx_mtd->spi = spi;
+	spi->mtd = efx_mtd;
+
+	efx_mtd->mtd.type = MTD_NORFLASH;
+	efx_mtd->mtd.flags = MTD_CAP_NORFLASH;
+	efx_mtd->mtd.size = spi->size - FALCON_FLASH_BOOTCODE_START;
+	efx_mtd->mtd.erasesize = spi->erase_size;
+	efx_mtd->mtd.writesize = 1;
+	efx_mtd_rename(efx);
+
+	efx_mtd->mtd.owner = THIS_MODULE;
+	efx_mtd->mtd.priv = efx_mtd;
+	efx_mtd->mtd.name = efx_mtd->name;
+	efx_mtd->mtd.erase = efx_mtd_erase;
+	efx_mtd->mtd.read = efx_mtd_read;
+	efx_mtd->mtd.write = efx_mtd_write;
+	efx_mtd->mtd.sync = efx_mtd_sync;
+
+	if (add_mtd_device(&efx_mtd->mtd)) {
+		kfree(efx_mtd);
+		spi->mtd = NULL;
+		/* add_mtd_device() returns 1 if the MTD table is full */
+		return -ENOMEM;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index cdb11fa..e596c9a 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -414,6 +414,7 @@ struct efx_blinker {
  * @init_leds: Sets up board LEDs
  * @set_fault_led: Turns the fault LED on or off
  * @blink: Starts/stops blinking
+ * @monitor: Board-specific health check function
  * @fini: Cleanup function
  * @blinker: used to blink LEDs in software
  * @hwmon_client: I2C client for hardware monitor
@@ -428,6 +429,7 @@ struct efx_board {
 	 * have a separate init callback that happens later than
 	 * board init. */
 	int (*init_leds)(struct efx_nic *efx);
+	int (*monitor) (struct efx_nic *nic);
 	void (*set_fault_led) (struct efx_nic *efx, bool state);
 	void (*blink) (struct efx_nic *efx, bool start);
 	void (*fini) (struct efx_nic *nic);
@@ -525,11 +527,15 @@ struct efx_phy_operations {
  * @enum efx_phy_mode - PHY operating mode flags
  * @PHY_MODE_NORMAL: on and should pass traffic
  * @PHY_MODE_TX_DISABLED: on with TX disabled
+ * @PHY_MODE_LOW_POWER: set to low power through MDIO
+ * @PHY_MODE_OFF: switched off through external control
  * @PHY_MODE_SPECIAL: on but will not pass traffic
  */
 enum efx_phy_mode {
 	PHY_MODE_NORMAL		= 0,
 	PHY_MODE_TX_DISABLED	= 1,
+	PHY_MODE_LOW_POWER	= 2,
+	PHY_MODE_OFF		= 4,
 	PHY_MODE_SPECIAL	= 8,
 };
 
@@ -655,6 +661,7 @@ union efx_multicast_hash {
  *	This field will be %NULL if no flash device is present.
  * @spi_eeprom: SPI EEPROM device
  *	This field will be %NULL if no EEPROM device is present.
+ * @spi_lock: SPI bus lock
  * @n_rx_nodesc_drop_cnt: RX no descriptor drop count
  * @nic_data: Hardware dependant state
  * @mac_lock: MAC access lock. Protects @port_enabled, @phy_mode,
@@ -731,6 +738,7 @@ struct efx_nic {
 
 	struct efx_spi_device *spi_flash;
 	struct efx_spi_device *spi_eeprom;
+	struct mutex spi_lock;
 
 	unsigned n_rx_nodesc_drop_cnt;
 
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index fe4e3fd..aa576c5 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -21,6 +21,7 @@
 #include "falcon_hwdefs.h"
 #include "falcon_io.h"
 #include "mac.h"
+#include "workarounds.h"
 
 /**************************************************************************
  *
@@ -65,48 +66,9 @@
 #define	P1_SPARE_LBN 4
 #define	P1_SPARE_WIDTH 4
 
-
-/**************************************************************************
- *
- * Temperature Sensor
- *
- **************************************************************************/
-#define	MAX6647	0x4e
-
-#define	RLTS	0x00
-#define	RLTE	0x01
-#define	RSL	0x02
-#define	RCL	0x03
-#define	RCRA	0x04
-#define	RLHN	0x05
-#define	RLLI	0x06
-#define	RRHI	0x07
-#define	RRLS	0x08
-#define	WCRW	0x0a
-#define	WLHO	0x0b
-#define	WRHA	0x0c
-#define	WRLN	0x0e
-#define	OSHT	0x0f
-#define	REET	0x10
-#define	RIET	0x11
-#define	RWOE	0x19
-#define	RWOI	0x20
-#define	HYS	0x21
-#define	QUEUE	0x22
-#define	MFID	0xfe
-#define	REVID	0xff
-
-/* Status bits */
-#define MAX6647_BUSY	(1 << 7)	/* ADC is converting */
-#define MAX6647_LHIGH	(1 << 6)	/* Local high temp. alarm */
-#define MAX6647_LLOW	(1 << 5)	/* Local low temp. alarm */
-#define MAX6647_RHIGH	(1 << 4)	/* Remote high temp. alarm */
-#define MAX6647_RLOW	(1 << 3)	/* Remote low temp. alarm */
-#define MAX6647_FAULT	(1 << 2)	/* DXN/DXP short/open circuit */
-#define MAX6647_EOT	(1 << 1)	/* Remote junction overtemp. */
-#define MAX6647_IOT	(1 << 0)	/* Local junction overtemp. */
-
-static const u8 xgphy_max_temperature = 90;
+/* Temperature Sensor */
+#define MAX664X_REG_RSL		0x02
+#define MAX664X_REG_WLHO	0x0B
 
 static void sfe4001_poweroff(struct efx_nic *efx)
 {
@@ -119,7 +81,7 @@ static void sfe4001_poweroff(struct efx_nic *efx)
 	i2c_smbus_write_byte_data(ioexp_client, P0_CONFIG, 0xff);
 
 	/* Clear any over-temperature alert */
-	i2c_smbus_read_byte_data(hwmon_client, RSL);
+	i2c_smbus_read_byte_data(hwmon_client, MAX664X_REG_RSL);
 }
 
 static int sfe4001_poweron(struct efx_nic *efx)
@@ -131,7 +93,7 @@ static int sfe4001_poweron(struct efx_nic *efx)
 	u8 out;
 
 	/* Clear any previous over-temperature alert */
-	rc = i2c_smbus_read_byte_data(hwmon_client, RSL);
+	rc = i2c_smbus_read_byte_data(hwmon_client, MAX664X_REG_RSL);
 	if (rc < 0)
 		return rc;
 
@@ -209,6 +171,34 @@ fail_on:
 	return rc;
 }
 
+static int sfe4001_check_hw(struct efx_nic *efx)
+{
+	s32 status;
+
+	/* If XAUI link is up then do not monitor */
+	if (EFX_WORKAROUND_7884(efx) && falcon_xaui_link_ok(efx))
+		return 0;
+
+	/* Check the powered status of the PHY. Lack of power implies that
+	 * the MAX6647 has shut down power to it, probably due to a temp.
+	 * alarm. Reading the power status rather than the MAX6647 status
+	 * directly because the later is read-to-clear and would thus
+	 * start to power up the PHY again when polled, causing us to blip
+	 * the power undesirably.
+	 * We know we can read from the IO expander because we did
+	 * it during power-on. Assume failure now is bad news. */
+	status = i2c_smbus_read_byte_data(efx->board_info.ioexp_client, P1_IN);
+	if (status >= 0 &&
+	    (status & ((1 << P1_AFE_PWD_LBN) | (1 << P1_DSP_PWD25_LBN))) != 0)
+		return 0;
+
+	/* Use board power control, not PHY power control */
+	sfe4001_poweroff(efx);
+	efx->phy_mode = PHY_MODE_OFF;
+
+	return (status < 0) ? -EIO : -ERANGE;
+}
+
 /* On SFE4001 rev A2 and later, we can control the FLASH_CFG_1 pin
  * using the 3V3X output of the IO-expander.  Allow the user to set
  * this when the device is stopped, and keep it stopped then.
@@ -261,35 +251,34 @@ static void sfe4001_fini(struct efx_nic *efx)
 	i2c_unregister_device(efx->board_info.hwmon_client);
 }
 
+static struct i2c_board_info sfe4001_hwmon_info = {
+	I2C_BOARD_INFO("max6647", 0x4e),
+	.irq		= -1,
+};
+
 /* This board uses an I2C expander to provider power to the PHY, which needs to
  * be turned on before the PHY can be used.
  * Context: Process context, rtnl lock held
  */
 int sfe4001_init(struct efx_nic *efx)
 {
-	struct i2c_client *hwmon_client;
 	int rc;
 
-	hwmon_client = i2c_new_dummy(&efx->i2c_adap, MAX6647);
-	if (!hwmon_client)
+#if defined(CONFIG_SENSORS_LM90) || defined(CONFIG_SENSORS_LM90_MODULE)
+	efx->board_info.hwmon_client =
+		i2c_new_device(&efx->i2c_adap, &sfe4001_hwmon_info);
+#else
+	efx->board_info.hwmon_client =
+		i2c_new_dummy(&efx->i2c_adap, sfe4001_hwmon_info.addr);
+#endif
+	if (!efx->board_info.hwmon_client)
 		return -EIO;
-	efx->board_info.hwmon_client = hwmon_client;
 
-	/* Set DSP over-temperature alert threshold */
-	EFX_INFO(efx, "DSP cut-out at %dC\n", xgphy_max_temperature);
-	rc = i2c_smbus_write_byte_data(hwmon_client, WLHO,
-				       xgphy_max_temperature);
+	/* Raise board/PHY high limit from 85 to 90 degrees Celsius */
+	rc = i2c_smbus_write_byte_data(efx->board_info.hwmon_client,
+				       MAX664X_REG_WLHO, 90);
 	if (rc)
-		goto fail_ioexp;
-
-	/* Read it back and verify */
-	rc = i2c_smbus_read_byte_data(hwmon_client, RLHN);
-	if (rc < 0)
-		goto fail_ioexp;
-	if (rc != xgphy_max_temperature) {
-		rc = -EFAULT;
-		goto fail_ioexp;
-	}
+		goto fail_hwmon;
 
 	efx->board_info.ioexp_client = i2c_new_dummy(&efx->i2c_adap, PCA9539);
 	if (!efx->board_info.ioexp_client) {
@@ -301,6 +290,7 @@ int sfe4001_init(struct efx_nic *efx)
 	 * blink code. */
 	efx->board_info.blink = tenxpress_phy_blink;
 
+	efx->board_info.monitor = sfe4001_check_hw;
 	efx->board_info.fini = sfe4001_fini;
 
 	rc = sfe4001_poweron(efx);
@@ -319,6 +309,6 @@ fail_on:
 fail_ioexp:
 	i2c_unregister_device(efx->board_info.ioexp_client);
 fail_hwmon:
-	i2c_unregister_device(hwmon_client);
+	i2c_unregister_device(efx->board_info.hwmon_client);
 	return rc;
 }
diff --git a/drivers/net/sfc/spi.h b/drivers/net/sfc/spi.h
index feef619..c4aca13 100644
--- a/drivers/net/sfc/spi.h
+++ b/drivers/net/sfc/spi.h
@@ -25,6 +25,7 @@
 #define SPI_WRDI 0x04		/* Reset write enable latch */
 #define SPI_RDSR 0x05		/* Read status register */
 #define SPI_WREN 0x06		/* Set write enable latch */
+#define SPI_SST_EWSR 0x50	/* SST: Enable write to status register */
 
 #define SPI_STATUS_WPEN 0x80	/* Write-protect pin enabled */
 #define SPI_STATUS_BP2 0x10	/* Block protection bit 2 */
@@ -36,6 +37,7 @@
 /**
  * struct efx_spi_device - an Efx SPI (Serial Peripheral Interface) device
  * @efx:		The Efx controller that owns this device
+ * @mtd:		MTD state
  * @device_id:		Controller's id for the device
  * @size:		Size (in bytes)
  * @addr_len:		Number of address bytes in read/write commands
@@ -44,23 +46,51 @@
  *	use bit 3 of the command byte as address bit A8, rather
  *	than having a two-byte address.  If this flag is set, then
  *	commands should be munged in this way.
+ * @erase_command:	Erase command (or 0 if sector erase not needed).
+ * @erase_size:		Erase sector size (in bytes)
+ *	Erase commands affect sectors with this size and alignment.
+ *	This must be a power of two.
  * @block_size:		Write block size (in bytes).
  *	Write commands are limited to blocks with this size and alignment.
- * @read:		Read function for the device
- * @write:		Write function for the device
  */
 struct efx_spi_device {
 	struct efx_nic *efx;
+#ifdef CONFIG_SFC_MTD
+	void *mtd;
+#endif
 	int device_id;
 	unsigned int size;
 	unsigned int addr_len;
 	unsigned int munge_address:1;
+	u8 erase_command;
+	unsigned int erase_size;
 	unsigned int block_size;
 };
 
+int falcon_spi_cmd(const struct efx_spi_device *spi, unsigned int command,
+		   int address, const void* in, void *out, unsigned int len);
+int falcon_spi_fast_wait(const struct efx_spi_device *spi);
 int falcon_spi_read(const struct efx_spi_device *spi, loff_t start,
 		    size_t len, size_t *retlen, u8 *buffer);
 int falcon_spi_write(const struct efx_spi_device *spi, loff_t start,
 		     size_t len, size_t *retlen, const u8 *buffer);
 
+/*
+ * SFC4000 flash is partitioned into:
+ *     0-0x400       chip and board config (see falcon_hwdefs.h)
+ *     0x400-0x8000  unused (or may contain VPD if EEPROM not present)
+ *     0x8000-end    boot code (mapped to PCI expansion ROM)
+ * SFC4000 small EEPROM (size < 0x400) is used for VPD only.
+ * SFC4000 large EEPROM (size >= 0x400) is partitioned into:
+ *     0-0x400       chip and board config
+ *     configurable  VPD
+ *     0x800-0x1800  boot config
+ * Aside from the chip and board config, all of these are optional and may
+ * be absent or truncated depending on the devices used.
+ */
+#define FALCON_NVCONFIG_END 0x400U
+#define FALCON_FLASH_BOOTCODE_START 0x8000U
+#define EFX_EEPROM_BOOTCONFIG_START 0x800U
+#define EFX_EEPROM_BOOTCONFIG_END 0x1800U
+
 #endif /* EFX_SPI_H */
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index d507c93..8d41c29 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -376,6 +376,7 @@ static int tenxpress_phy_check_hw(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data = efx->phy_data;
 	bool link_ok;
+	int rc = 0;
 
 	link_ok = tenxpress_link_ok(efx, true);
 
@@ -391,7 +392,22 @@ static int tenxpress_phy_check_hw(struct efx_nic *efx)
 		atomic_set(&phy_data->bad_crc_count, 0);
 	}
 
-	return 0;
+	rc = efx->board_info.monitor(efx);
+	if (rc) {
+		EFX_ERR(efx, "Board sensor %s; shutting down PHY\n",
+			(rc == -ERANGE) ? "reported fault" : "failed");
+		if (efx->phy_mode & PHY_MODE_OFF) {
+			/* Assume that board has shut PHY off */
+			phy_data->phy_mode = PHY_MODE_OFF;
+		} else {
+			efx->phy_mode |= PHY_MODE_LOW_POWER;
+			mdio_clause45_set_mmds_lpower(efx, true,
+						      efx->phy_op->mmds);
+			phy_data->phy_mode |= PHY_MODE_LOW_POWER;
+		}
+	}
+
+	return rc;
 }
 
 static void tenxpress_phy_fini(struct efx_nic *efx)
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index fa7b49d..ec50b90 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -22,6 +22,8 @@
 #define EFX_WORKAROUND_5147 EFX_WORKAROUND_ALWAYS
 /* RX PCIe double split performance issue */
 #define EFX_WORKAROUND_7575 EFX_WORKAROUND_ALWAYS
+/* Bit-bashed I2C reads cause performance drop */
+#define EFX_WORKAROUND_7884 EFX_WORKAROUND_ALWAYS
 /* TX pkt parser problem with <= 16 byte TXes */
 #define EFX_WORKAROUND_9141 EFX_WORKAROUND_ALWAYS
 /* Low rate CRC errors require XAUI reset */
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index 276151d..91f0246 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -128,6 +128,15 @@ static int xfp_phy_check_hw(struct efx_nic *efx)
 	if (link_up != efx->link_up)
 		falcon_xmac_sim_phy_event(efx);
 
+	rc = efx->board_info.monitor(efx);
+	if (rc) {
+		struct xfp_phy_data *phy_data = efx->phy_data;
+		EFX_ERR(efx, "XFP sensor alert; putting PHY into low power\n");
+		efx->phy_mode |= PHY_MODE_LOW_POWER;
+		mdio_clause45_set_mmds_lpower(efx, 1, XFP_REQUIRED_DEVS);
+		phy_data->phy_mode |= PHY_MODE_LOW_POWER;
+	}
+
 	return rc;
 }
 
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
new file mode 100644
index 0000000..fe51788
--- /dev/null
+++ b/drivers/net/smsc911x.c
@@ -0,0 +1,2091 @@
+/***************************************************************************
+ *
+ * Copyright (C) 2004-2008 SMSC
+ * Copyright (C) 2005-2008 ARM
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ ***************************************************************************
+ * Rewritten, heavily based on smsc911x simple driver by SMSC.
+ * Partly uses io macros from smc91x.c by Nicolas Pitre
+ *
+ * Supported devices:
+ *   LAN9115, LAN9116, LAN9117, LAN9118
+ *   LAN9215, LAN9216, LAN9217, LAN9218
+ *   LAN9210, LAN9211
+ *   LAN9220, LAN9221
+ *
+ */
+
+#include <linux/crc32.h>
+#include <linux/delay.h>
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/init.h>
+#include <linux/ioport.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/platform_device.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/timer.h>
+#include <linux/version.h>
+#include <linux/bug.h>
+#include <linux/bitops.h>
+#include <linux/irq.h>
+#include <linux/io.h>
+#include <linux/phy.h>
+#include <linux/smsc911x.h>
+#include "smsc911x.h"
+
+#define SMSC_CHIPNAME		"smsc911x"
+#define SMSC_MDIONAME		"smsc911x-mdio"
+#define SMSC_DRV_VERSION	"2008-10-21"
+
+MODULE_LICENSE("GPL");
+MODULE_VERSION(SMSC_DRV_VERSION);
+
+#if USE_DEBUG > 0
+static int debug = 16;
+#else
+static int debug = 3;
+#endif
+
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
+
+struct smsc911x_data {
+	void __iomem *ioaddr;
+
+	unsigned int idrev;
+
+	/* used to decide which workarounds apply */
+	unsigned int generation;
+
+	/* device configuration (copied from platform_data during probe) */
+	unsigned int irq_polarity;
+	unsigned int irq_type;
+	phy_interface_t phy_interface;
+
+	/* This needs to be acquired before calling any of below:
+	 * smsc911x_mac_read(), smsc911x_mac_write()
+	 */
+	spinlock_t mac_lock;
+
+#if (!SMSC_CAN_USE_32BIT)
+	/* spinlock to ensure 16-bit accesses are serialised */
+	spinlock_t dev_lock;
+#endif
+
+	struct phy_device *phy_dev;
+	struct mii_bus *mii_bus;
+	int phy_irq[PHY_MAX_ADDR];
+	unsigned int using_extphy;
+	int last_duplex;
+	int last_carrier;
+
+	u32 msg_enable;
+	unsigned int gpio_setting;
+	unsigned int gpio_orig_setting;
+	struct net_device *dev;
+	struct napi_struct napi;
+
+	unsigned int software_irq_signal;
+
+#ifdef USE_PHY_WORK_AROUND
+#define MIN_PACKET_SIZE (64)
+	char loopback_tx_pkt[MIN_PACKET_SIZE];
+	char loopback_rx_pkt[MIN_PACKET_SIZE];
+	unsigned int resetcount;
+#endif
+
+	/* Members for Multicast filter workaround */
+	unsigned int multicast_update_pending;
+	unsigned int set_bits_mask;
+	unsigned int clear_bits_mask;
+	unsigned int hashhi;
+	unsigned int hashlo;
+};
+
+#if SMSC_CAN_USE_32BIT
+
+static inline u32 smsc911x_reg_read(struct smsc911x_data *pdata, u32 reg)
+{
+	return readl(pdata->ioaddr + reg);
+}
+
+static inline void smsc911x_reg_write(struct smsc911x_data *pdata, u32 reg,
+				      u32 val)
+{
+	writel(val, pdata->ioaddr + reg);
+}
+
+/* Writes a packet to the TX_DATA_FIFO */
+static inline void
+smsc911x_tx_writefifo(struct smsc911x_data *pdata, unsigned int *buf,
+		      unsigned int wordcount)
+{
+	writesl(pdata->ioaddr + TX_DATA_FIFO, buf, wordcount);
+}
+
+/* Reads a packet out of the RX_DATA_FIFO */
+static inline void
+smsc911x_rx_readfifo(struct smsc911x_data *pdata, unsigned int *buf,
+		     unsigned int wordcount)
+{
+	readsl(pdata->ioaddr + RX_DATA_FIFO, buf, wordcount);
+}
+
+#else				/* SMSC_CAN_USE_32BIT */
+
+/* These 16-bit access functions are significantly slower, due to the locking
+ * necessary.  If your bus hardware can be configured to do this for you
+ * (in response to a single 32-bit operation from software), you should use
+ * the 32-bit access functions instead. */
+
+static inline u32 smsc911x_reg_read(struct smsc911x_data *pdata, u32 reg)
+{
+	unsigned long flags;
+	u32 data;
+
+	/* these two 16-bit reads must be performed consecutively, so must
+	 * not be interrupted by our own ISR (which would start another
+	 * read operation) */
+	spin_lock_irqsave(&pdata->dev_lock, flags);
+	data = ((readw(pdata->ioaddr + reg) & 0xFFFF) |
+		((readw(pdata->ioaddr + reg + 2) & 0xFFFF) << 16));
+	spin_unlock_irqrestore(&pdata->dev_lock, flags);
+
+	return data;
+}
+
+static inline void smsc911x_reg_write(struct smsc911x_data *pdata, u32 reg,
+				      u32 val)
+{
+	unsigned long flags;
+
+	/* these two 16-bit writes must be performed consecutively, so must
+	 * not be interrupted by our own ISR (which would start another
+	 * read operation) */
+	spin_lock_irqsave(&pdata->dev_lock, flags);
+	writew(val & 0xFFFF, pdata->ioaddr + reg);
+	writew((val >> 16) & 0xFFFF, pdata->ioaddr + reg + 2);
+	spin_unlock_irqrestore(&pdata->dev_lock, flags);
+}
+
+/* Writes a packet to the TX_DATA_FIFO */
+static inline void
+smsc911x_tx_writefifo(struct smsc911x_data *pdata, unsigned int *buf,
+		      unsigned int wordcount)
+{
+	while (wordcount--)
+		smsc911x_reg_write(pdata, TX_DATA_FIFO, *buf++);
+}
+
+/* Reads a packet out of the RX_DATA_FIFO */
+static inline void
+smsc911x_rx_readfifo(struct smsc911x_data *pdata, unsigned int *buf,
+		     unsigned int wordcount)
+{
+	while (wordcount--)
+		*buf++ = smsc911x_reg_read(pdata, RX_DATA_FIFO);
+}
+
+#endif				/* SMSC_CAN_USE_32BIT */
+
+/* waits for MAC not busy, with timeout.  Only called by smsc911x_mac_read
+ * and smsc911x_mac_write, so assumes mac_lock is held */
+static int smsc911x_mac_complete(struct smsc911x_data *pdata)
+{
+	int i;
+	u32 val;
+
+	SMSC_ASSERT_MAC_LOCK(pdata);
+
+	for (i = 0; i < 40; i++) {
+		val = smsc911x_reg_read(pdata, MAC_CSR_CMD);
+		if (!(val & MAC_CSR_CMD_CSR_BUSY_))
+			return 0;
+	}
+	SMSC_WARNING(HW, "Timed out waiting for MAC not BUSY. "
+		"MAC_CSR_CMD: 0x%08X", val);
+	return -EIO;
+}
+
+/* Fetches a MAC register value. Assumes mac_lock is acquired */
+static u32 smsc911x_mac_read(struct smsc911x_data *pdata, unsigned int offset)
+{
+	unsigned int temp;
+
+	SMSC_ASSERT_MAC_LOCK(pdata);
+
+	temp = smsc911x_reg_read(pdata, MAC_CSR_CMD);
+	if (unlikely(temp & MAC_CSR_CMD_CSR_BUSY_)) {
+		SMSC_WARNING(HW, "MAC busy at entry");
+		return 0xFFFFFFFF;
+	}
+
+	/* Send the MAC cmd */
+	smsc911x_reg_write(pdata, MAC_CSR_CMD, ((offset & 0xFF) |
+		MAC_CSR_CMD_CSR_BUSY_ | MAC_CSR_CMD_R_NOT_W_));
+
+	/* Workaround for hardware read-after-write restriction */
+	temp = smsc911x_reg_read(pdata, BYTE_TEST);
+
+	/* Wait for the read to complete */
+	if (likely(smsc911x_mac_complete(pdata) == 0))
+		return smsc911x_reg_read(pdata, MAC_CSR_DATA);
+
+	SMSC_WARNING(HW, "MAC busy after read");
+	return 0xFFFFFFFF;
+}
+
+/* Set a mac register, mac_lock must be acquired before calling */
+static void smsc911x_mac_write(struct smsc911x_data *pdata,
+			       unsigned int offset, u32 val)
+{
+	unsigned int temp;
+
+	SMSC_ASSERT_MAC_LOCK(pdata);
+
+	temp = smsc911x_reg_read(pdata, MAC_CSR_CMD);
+	if (unlikely(temp & MAC_CSR_CMD_CSR_BUSY_)) {
+		SMSC_WARNING(HW,
+			"smsc911x_mac_write failed, MAC busy at entry");
+		return;
+	}
+
+	/* Send data to write */
+	smsc911x_reg_write(pdata, MAC_CSR_DATA, val);
+
+	/* Write the actual data */
+	smsc911x_reg_write(pdata, MAC_CSR_CMD, ((offset & 0xFF) |
+		MAC_CSR_CMD_CSR_BUSY_));
+
+	/* Workaround for hardware read-after-write restriction */
+	temp = smsc911x_reg_read(pdata, BYTE_TEST);
+
+	/* Wait for the write to complete */
+	if (likely(smsc911x_mac_complete(pdata) == 0))
+		return;
+
+	SMSC_WARNING(HW,
+		"smsc911x_mac_write failed, MAC busy after write");
+}
+
+/* Get a phy register */
+static int smsc911x_mii_read(struct mii_bus *bus, int phyaddr, int regidx)
+{
+	struct smsc911x_data *pdata = (struct smsc911x_data *)bus->priv;
+	unsigned long flags;
+	unsigned int addr;
+	int i, reg;
+
+	spin_lock_irqsave(&pdata->mac_lock, flags);
+
+	/* Confirm MII not busy */
+	if (unlikely(smsc911x_mac_read(pdata, MII_ACC) & MII_ACC_MII_BUSY_)) {
+		SMSC_WARNING(HW,
+			"MII is busy in smsc911x_mii_read???");
+		reg = -EIO;
+		goto out;
+	}
+
+	/* Set the address, index & direction (read from PHY) */
+	addr = ((phyaddr & 0x1F) << 11) | ((regidx & 0x1F) << 6);
+	smsc911x_mac_write(pdata, MII_ACC, addr);
+
+	/* Wait for read to complete w/ timeout */
+	for (i = 0; i < 100; i++)
+		if (!(smsc911x_mac_read(pdata, MII_ACC) & MII_ACC_MII_BUSY_)) {
+			reg = smsc911x_mac_read(pdata, MII_DATA);
+			goto out;
+		}
+
+	SMSC_WARNING(HW, "Timed out waiting for MII write to finish");
+	reg = -EIO;
+
+out:
+	spin_unlock_irqrestore(&pdata->mac_lock, flags);
+	return reg;
+}
+
+/* Set a phy register */
+static int smsc911x_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
+			   u16 val)
+{
+	struct smsc911x_data *pdata = (struct smsc911x_data *)bus->priv;
+	unsigned long flags;
+	unsigned int addr;
+	int i, reg;
+
+	spin_lock_irqsave(&pdata->mac_lock, flags);
+
+	/* Confirm MII not busy */
+	if (unlikely(smsc911x_mac_read(pdata, MII_ACC) & MII_ACC_MII_BUSY_)) {
+		SMSC_WARNING(HW,
+			"MII is busy in smsc911x_mii_write???");
+		reg = -EIO;
+		goto out;
+	}
+
+	/* Put the data to write in the MAC */
+	smsc911x_mac_write(pdata, MII_DATA, val);
+
+	/* Set the address, index & direction (write to PHY) */
+	addr = ((phyaddr & 0x1F) << 11) | ((regidx & 0x1F) << 6) |
+		MII_ACC_MII_WRITE_;
+	smsc911x_mac_write(pdata, MII_ACC, addr);
+
+	/* Wait for write to complete w/ timeout */
+	for (i = 0; i < 100; i++)
+		if (!(smsc911x_mac_read(pdata, MII_ACC) & MII_ACC_MII_BUSY_)) {
+			reg = 0;
+			goto out;
+		}
+
+	SMSC_WARNING(HW, "Timed out waiting for MII write to finish");
+	reg = -EIO;
+
+out:
+	spin_unlock_irqrestore(&pdata->mac_lock, flags);
+	return reg;
+}
+
+/* Autodetects and initialises external phy for SMSC9115 and SMSC9117 flavors.
+ * If something goes wrong, returns -ENODEV to revert back to internal phy.
+ * Performed at initialisation only, so interrupts are enabled */
+static int smsc911x_phy_initialise_external(struct smsc911x_data *pdata)
+{
+	unsigned int hwcfg = smsc911x_reg_read(pdata, HW_CFG);
+
+	/* External phy is requested, supported, and detected */
+	if (hwcfg & HW_CFG_EXT_PHY_DET_) {
+
+		/* Switch to external phy. Assuming tx and rx are stopped
+		 * because smsc911x_phy_initialise is called before
+		 * smsc911x_rx_initialise and tx_initialise. */
+
+		/* Disable phy clocks to the MAC */
+		hwcfg &= (~HW_CFG_PHY_CLK_SEL_);
+		hwcfg |= HW_CFG_PHY_CLK_SEL_CLK_DIS_;
+		smsc911x_reg_write(pdata, HW_CFG, hwcfg);
+		udelay(10);	/* Enough time for clocks to stop */
+
+		/* Switch to external phy */
+		hwcfg |= HW_CFG_EXT_PHY_EN_;
+		smsc911x_reg_write(pdata, HW_CFG, hwcfg);
+
+		/* Enable phy clocks to the MAC */
+		hwcfg &= (~HW_CFG_PHY_CLK_SEL_);
+		hwcfg |= HW_CFG_PHY_CLK_SEL_EXT_PHY_;
+		smsc911x_reg_write(pdata, HW_CFG, hwcfg);
+		udelay(10);	/* Enough time for clocks to restart */
+
+		hwcfg |= HW_CFG_SMI_SEL_;
+		smsc911x_reg_write(pdata, HW_CFG, hwcfg);
+
+		SMSC_TRACE(HW, "Successfully switched to external PHY");
+		pdata->using_extphy = 1;
+	} else {
+		SMSC_WARNING(HW, "No external PHY detected, "
+			"Using internal PHY instead.");
+		/* Use internal phy */
+		return -ENODEV;
+	}
+	return 0;
+}
+
+/* Fetches a tx status out of the status fifo */
+static unsigned int smsc911x_tx_get_txstatus(struct smsc911x_data *pdata)
+{
+	unsigned int result =
+	    smsc911x_reg_read(pdata, TX_FIFO_INF) & TX_FIFO_INF_TSUSED_;
+
+	if (result != 0)
+		result = smsc911x_reg_read(pdata, TX_STATUS_FIFO);
+
+	return result;
+}
+
+/* Fetches the next rx status */
+static unsigned int smsc911x_rx_get_rxstatus(struct smsc911x_data *pdata)
+{
+	unsigned int result =
+	    smsc911x_reg_read(pdata, RX_FIFO_INF) & RX_FIFO_INF_RXSUSED_;
+
+	if (result != 0)
+		result = smsc911x_reg_read(pdata, RX_STATUS_FIFO);
+
+	return result;
+}
+
+#ifdef USE_PHY_WORK_AROUND
+static int smsc911x_phy_check_loopbackpkt(struct smsc911x_data *pdata)
+{
+	unsigned int tries;
+	u32 wrsz;
+	u32 rdsz;
+	ulong bufp;
+
+	for (tries = 0; tries < 10; tries++) {
+		unsigned int txcmd_a;
+		unsigned int txcmd_b;
+		unsigned int status;
+		unsigned int pktlength;
+		unsigned int i;
+
+		/* Zero-out rx packet memory */
+		memset(pdata->loopback_rx_pkt, 0, MIN_PACKET_SIZE);
+
+		/* Write tx packet to 118 */
+		txcmd_a = (u32)((ulong)pdata->loopback_tx_pkt & 0x03) << 16;
+		txcmd_a |= TX_CMD_A_FIRST_SEG_ | TX_CMD_A_LAST_SEG_;
+		txcmd_a |= MIN_PACKET_SIZE;
+
+		txcmd_b = MIN_PACKET_SIZE << 16 | MIN_PACKET_SIZE;
+
+		smsc911x_reg_write(pdata, TX_DATA_FIFO, txcmd_a);
+		smsc911x_reg_write(pdata, TX_DATA_FIFO, txcmd_b);
+
+		bufp = (ulong)pdata->loopback_tx_pkt & (~0x3);
+		wrsz = MIN_PACKET_SIZE + 3;
+		wrsz += (u32)((ulong)pdata->loopback_tx_pkt & 0x3);
+		wrsz >>= 2;
+
+		smsc911x_tx_writefifo(pdata, (unsigned int *)bufp, wrsz);
+
+		/* Wait till transmit is done */
+		i = 60;
+		do {
+			udelay(5);
+			status = smsc911x_tx_get_txstatus(pdata);
+		} while ((i--) && (!status));
+
+		if (!status) {
+			SMSC_WARNING(HW, "Failed to transmit "
+				"during loopback test");
+			continue;
+		}
+		if (status & TX_STS_ES_) {
+			SMSC_WARNING(HW, "Transmit encountered "
+				"errors during loopback test");
+			continue;
+		}
+
+		/* Wait till receive is done */
+		i = 60;
+		do {
+			udelay(5);
+			status = smsc911x_rx_get_rxstatus(pdata);
+		} while ((i--) && (!status));
+
+		if (!status) {
+			SMSC_WARNING(HW,
+				"Failed to receive during loopback test");
+			continue;
+		}
+		if (status & RX_STS_ES_) {
+			SMSC_WARNING(HW, "Receive encountered "
+				"errors during loopback test");
+			continue;
+		}
+
+		pktlength = ((status & 0x3FFF0000UL) >> 16);
+		bufp = (ulong)pdata->loopback_rx_pkt;
+		rdsz = pktlength + 3;
+		rdsz += (u32)((ulong)pdata->loopback_rx_pkt & 0x3);
+		rdsz >>= 2;
+
+		smsc911x_rx_readfifo(pdata, (unsigned int *)bufp, rdsz);
+
+		if (pktlength != (MIN_PACKET_SIZE + 4)) {
+			SMSC_WARNING(HW, "Unexpected packet size "
+				"during loop back test, size=%d, will retry",
+				pktlength);
+		} else {
+			unsigned int j;
+			int mismatch = 0;
+			for (j = 0; j < MIN_PACKET_SIZE; j++) {
+				if (pdata->loopback_tx_pkt[j]
+				    != pdata->loopback_rx_pkt[j]) {
+					mismatch = 1;
+					break;
+				}
+			}
+			if (!mismatch) {
+				SMSC_TRACE(HW, "Successfully verified "
+					   "loopback packet");
+				return 0;
+			} else {
+				SMSC_WARNING(HW, "Data mismatch "
+					"during loop back test, will retry");
+			}
+		}
+	}
+
+	return -EIO;
+}
+
+static int smsc911x_phy_reset(struct smsc911x_data *pdata)
+{
+	struct phy_device *phy_dev = pdata->phy_dev;
+	unsigned int temp;
+	unsigned int i = 100000;
+
+	BUG_ON(!phy_dev);
+	BUG_ON(!phy_dev->bus);
+
+	SMSC_TRACE(HW, "Performing PHY BCR Reset");
+	smsc911x_mii_write(phy_dev->bus, phy_dev->addr, MII_BMCR, BMCR_RESET);
+	do {
+		msleep(1);
+		temp = smsc911x_mii_read(phy_dev->bus, phy_dev->addr,
+			MII_BMCR);
+	} while ((i--) && (temp & BMCR_RESET));
+
+	if (temp & BMCR_RESET) {
+		SMSC_WARNING(HW, "PHY reset failed to complete.");
+		return -EIO;
+	}
+	/* Extra delay required because the phy may not be completed with
+	* its reset when BMCR_RESET is cleared. Specs say 256 uS is
+	* enough delay but using 1ms here to be safe */
+	msleep(1);
+
+	return 0;
+}
+
+static int smsc911x_phy_loopbacktest(struct net_device *dev)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	struct phy_device *phy_dev = pdata->phy_dev;
+	int result = -EIO;
+	unsigned int i, val;
+	unsigned long flags;
+
+	/* Initialise tx packet using broadcast destination address */
+	memset(pdata->loopback_tx_pkt, 0xff, ETH_ALEN);
+
+	/* Use incrementing source address */
+	for (i = 6; i < 12; i++)
+		pdata->loopback_tx_pkt[i] = (char)i;
+
+	/* Set length type field */
+	pdata->loopback_tx_pkt[12] = 0x00;
+	pdata->loopback_tx_pkt[13] = 0x00;
+
+	for (i = 14; i < MIN_PACKET_SIZE; i++)
+		pdata->loopback_tx_pkt[i] = (char)i;
+
+	val = smsc911x_reg_read(pdata, HW_CFG);
+	val &= HW_CFG_TX_FIF_SZ_;
+	val |= HW_CFG_SF_;
+	smsc911x_reg_write(pdata, HW_CFG, val);
+
+	smsc911x_reg_write(pdata, TX_CFG, TX_CFG_TX_ON_);
+	smsc911x_reg_write(pdata, RX_CFG,
+		(u32)((ulong)pdata->loopback_rx_pkt & 0x03) << 8);
+
+	for (i = 0; i < 10; i++) {
+		/* Set PHY to 10/FD, no ANEG, and loopback mode */
+		smsc911x_mii_write(phy_dev->bus, phy_dev->addr,	MII_BMCR,
+			BMCR_LOOPBACK | BMCR_FULLDPLX);
+
+		/* Enable MAC tx/rx, FD */
+		spin_lock_irqsave(&pdata->mac_lock, flags);
+		smsc911x_mac_write(pdata, MAC_CR, MAC_CR_FDPX_
+				   | MAC_CR_TXEN_ | MAC_CR_RXEN_);
+		spin_unlock_irqrestore(&pdata->mac_lock, flags);
+
+		if (smsc911x_phy_check_loopbackpkt(pdata) == 0) {
+			result = 0;
+			break;
+		}
+		pdata->resetcount++;
+
+		/* Disable MAC rx */
+		spin_lock_irqsave(&pdata->mac_lock, flags);
+		smsc911x_mac_write(pdata, MAC_CR, 0);
+		spin_unlock_irqrestore(&pdata->mac_lock, flags);
+
+		smsc911x_phy_reset(pdata);
+	}
+
+	/* Disable MAC */
+	spin_lock_irqsave(&pdata->mac_lock, flags);
+	smsc911x_mac_write(pdata, MAC_CR, 0);
+	spin_unlock_irqrestore(&pdata->mac_lock, flags);
+
+	/* Cancel PHY loopback mode */
+	smsc911x_mii_write(phy_dev->bus, phy_dev->addr, MII_BMCR, 0);
+
+	smsc911x_reg_write(pdata, TX_CFG, 0);
+	smsc911x_reg_write(pdata, RX_CFG, 0);
+
+	return result;
+}
+#endif				/* USE_PHY_WORK_AROUND */
+
+static u8 smsc95xx_resolve_flowctrl_fulldplx(u16 lcladv, u16 rmtadv)
+{
+	u8 cap = 0;
+
+	if (lcladv & ADVERTISE_PAUSE_CAP) {
+		if (lcladv & ADVERTISE_PAUSE_ASYM) {
+			if (rmtadv & LPA_PAUSE_CAP)
+				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
+			else if (rmtadv & LPA_PAUSE_ASYM)
+				cap = FLOW_CTRL_RX;
+		} else {
+			if (rmtadv & LPA_PAUSE_CAP)
+				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
+		}
+	} else if (lcladv & ADVERTISE_PAUSE_ASYM) {
+		if ((rmtadv & LPA_PAUSE_CAP) && (rmtadv & LPA_PAUSE_ASYM))
+			cap = FLOW_CTRL_TX;
+	}
+
+	return cap;
+}
+
+static void smsc911x_phy_update_flowcontrol(struct smsc911x_data *pdata)
+{
+	struct phy_device *phy_dev = pdata->phy_dev;
+	u32 afc = smsc911x_reg_read(pdata, AFC_CFG);
+	u32 flow;
+	unsigned long flags;
+
+	if (phy_dev->duplex == DUPLEX_FULL) {
+		u16 lcladv = phy_read(phy_dev, MII_ADVERTISE);
+		u16 rmtadv = phy_read(phy_dev, MII_LPA);
+		u8 cap = smsc95xx_resolve_flowctrl_fulldplx(lcladv, rmtadv);
+
+		if (cap & FLOW_CTRL_RX)
+			flow = 0xFFFF0002;
+		else
+			flow = 0;
+
+		if (cap & FLOW_CTRL_TX)
+			afc |= 0xF;
+		else
+			afc &= ~0xF;
+
+		SMSC_TRACE(HW, "rx pause %s, tx pause %s",
+			(cap & FLOW_CTRL_RX ? "enabled" : "disabled"),
+			(cap & FLOW_CTRL_TX ? "enabled" : "disabled"));
+	} else {
+		SMSC_TRACE(HW, "half duplex");
+		flow = 0;
+		afc |= 0xF;
+	}
+
+	spin_lock_irqsave(&pdata->mac_lock, flags);
+	smsc911x_mac_write(pdata, FLOW, flow);
+	spin_unlock_irqrestore(&pdata->mac_lock, flags);
+
+	smsc911x_reg_write(pdata, AFC_CFG, afc);
+}
+
+/* Update link mode if anything has changed.  Called periodically when the
+ * PHY is in polling mode, even if nothing has changed. */
+static void smsc911x_phy_adjust_link(struct net_device *dev)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	struct phy_device *phy_dev = pdata->phy_dev;
+	unsigned long flags;
+	int carrier;
+
+	if (phy_dev->duplex != pdata->last_duplex) {
+		unsigned int mac_cr;
+		SMSC_TRACE(HW, "duplex state has changed");
+
+		spin_lock_irqsave(&pdata->mac_lock, flags);
+		mac_cr = smsc911x_mac_read(pdata, MAC_CR);
+		if (phy_dev->duplex) {
+			SMSC_TRACE(HW,
+				"configuring for full duplex mode");
+			mac_cr |= MAC_CR_FDPX_;
+		} else {
+			SMSC_TRACE(HW,
+				"configuring for half duplex mode");
+			mac_cr &= ~MAC_CR_FDPX_;
+		}
+		smsc911x_mac_write(pdata, MAC_CR, mac_cr);
+		spin_unlock_irqrestore(&pdata->mac_lock, flags);
+
+		smsc911x_phy_update_flowcontrol(pdata);
+		pdata->last_duplex = phy_dev->duplex;
+	}
+
+	carrier = netif_carrier_ok(dev);
+	if (carrier != pdata->last_carrier) {
+		SMSC_TRACE(HW, "carrier state has changed");
+		if (carrier) {
+			SMSC_TRACE(HW, "configuring for carrier OK");
+			if ((pdata->gpio_orig_setting & GPIO_CFG_LED1_EN_) &&
+			    (!pdata->using_extphy)) {
+				/* Restore orginal GPIO configuration */
+				pdata->gpio_setting = pdata->gpio_orig_setting;
+				smsc911x_reg_write(pdata, GPIO_CFG,
+					pdata->gpio_setting);
+			}
+		} else {
+			SMSC_TRACE(HW, "configuring for no carrier");
+			/* Check global setting that LED1
+			 * usage is 10/100 indicator */
+			pdata->gpio_setting = smsc911x_reg_read(pdata,
+				GPIO_CFG);
+			if ((pdata->gpio_setting & GPIO_CFG_LED1_EN_)
+			    && (!pdata->using_extphy)) {
+				/* Force 10/100 LED off, after saving
+				 * orginal GPIO configuration */
+				pdata->gpio_orig_setting = pdata->gpio_setting;
+
+				pdata->gpio_setting &= ~GPIO_CFG_LED1_EN_;
+				pdata->gpio_setting |= (GPIO_CFG_GPIOBUF0_
+							| GPIO_CFG_GPIODIR0_
+							| GPIO_CFG_GPIOD0_);
+				smsc911x_reg_write(pdata, GPIO_CFG,
+					pdata->gpio_setting);
+			}
+		}
+		pdata->last_carrier = carrier;
+	}
+}
+
+static int smsc911x_mii_probe(struct net_device *dev)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	struct phy_device *phydev = NULL;
+	int phy_addr;
+
+	/* find the first phy */
+	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
+		if (pdata->mii_bus->phy_map[phy_addr]) {
+			phydev = pdata->mii_bus->phy_map[phy_addr];
+			SMSC_TRACE(PROBE, "PHY %d: addr %d, phy_id 0x%08X",
+				phy_addr, phydev->addr, phydev->phy_id);
+			break;
+		}
+	}
+
+	if (!phydev) {
+		pr_err("%s: no PHY found\n", dev->name);
+		return -ENODEV;
+	}
+
+	phydev = phy_connect(dev, phydev->dev.bus_id,
+		&smsc911x_phy_adjust_link, 0, pdata->phy_interface);
+
+	if (IS_ERR(phydev)) {
+		pr_err("%s: Could not attach to PHY\n", dev->name);
+		return PTR_ERR(phydev);
+	}
+
+	pr_info("%s: attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
+		dev->name, phydev->drv->name, phydev->dev.bus_id, phydev->irq);
+
+	/* mask with MAC supported features */
+	phydev->supported &= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
+			      SUPPORTED_Asym_Pause);
+	phydev->advertising = phydev->supported;
+
+	pdata->phy_dev = phydev;
+	pdata->last_duplex = -1;
+	pdata->last_carrier = -1;
+
+#ifdef USE_PHY_WORK_AROUND
+	if (smsc911x_phy_loopbacktest(dev) < 0) {
+		SMSC_WARNING(HW, "Failed Loop Back Test");
+		return -ENODEV;
+	}
+	SMSC_TRACE(HW, "Passed Loop Back Test");
+#endif				/* USE_PHY_WORK_AROUND */
+
+	SMSC_TRACE(HW, "phy initialised succesfully");
+	return 0;
+}
+
+static int __devinit smsc911x_mii_init(struct platform_device *pdev,
+				       struct net_device *dev)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	int err = -ENXIO, i;
+
+	pdata->mii_bus = mdiobus_alloc();
+	if (!pdata->mii_bus) {
+		err = -ENOMEM;
+		goto err_out_1;
+	}
+
+	pdata->mii_bus->name = SMSC_MDIONAME;
+	snprintf(pdata->mii_bus->id, MII_BUS_ID_SIZE, "%x", pdev->id);
+	pdata->mii_bus->priv = pdata;
+	pdata->mii_bus->read = smsc911x_mii_read;
+	pdata->mii_bus->write = smsc911x_mii_write;
+	pdata->mii_bus->irq = pdata->phy_irq;
+	for (i = 0; i < PHY_MAX_ADDR; ++i)
+		pdata->mii_bus->irq[i] = PHY_POLL;
+
+	pdata->mii_bus->parent = &pdev->dev;
+	dev_set_drvdata(&pdev->dev, &pdata->mii_bus);
+
+	pdata->using_extphy = 0;
+
+	switch (pdata->idrev & 0xFFFF0000) {
+	case 0x01170000:
+	case 0x01150000:
+	case 0x117A0000:
+	case 0x115A0000:
+		/* External PHY supported, try to autodetect */
+		if (smsc911x_phy_initialise_external(pdata) < 0) {
+			SMSC_TRACE(HW, "No external PHY detected, "
+				"using internal PHY");
+		}
+		break;
+	default:
+		SMSC_TRACE(HW, "External PHY is not supported, "
+			"using internal PHY");
+		break;
+	}
+
+	if (!pdata->using_extphy) {
+		/* Mask all PHYs except ID 1 (internal) */
+		pdata->mii_bus->phy_mask = ~(1 << 1);
+	}
+
+	if (mdiobus_register(pdata->mii_bus)) {
+		SMSC_WARNING(PROBE, "Error registering mii bus");
+		goto err_out_free_bus_2;
+	}
+
+	if (smsc911x_mii_probe(dev) < 0) {
+		SMSC_WARNING(PROBE, "Error registering mii bus");
+		goto err_out_unregister_bus_3;
+	}
+
+	return 0;
+
+err_out_unregister_bus_3:
+	mdiobus_unregister(pdata->mii_bus);
+err_out_free_bus_2:
+	mdiobus_free(pdata->mii_bus);
+err_out_1:
+	return err;
+}
+
+/* Gets the number of tx statuses in the fifo */
+static unsigned int smsc911x_tx_get_txstatcount(struct smsc911x_data *pdata)
+{
+	return (smsc911x_reg_read(pdata, TX_FIFO_INF)
+		& TX_FIFO_INF_TSUSED_) >> 16;
+}
+
+/* Reads tx statuses and increments counters where necessary */
+static void smsc911x_tx_update_txcounters(struct net_device *dev)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	unsigned int tx_stat;
+
+	while ((tx_stat = smsc911x_tx_get_txstatus(pdata)) != 0) {
+		if (unlikely(tx_stat & 0x80000000)) {
+			/* In this driver the packet tag is used as the packet
+			 * length. Since a packet length can never reach the
+			 * size of 0x8000, this bit is reserved. It is worth
+			 * noting that the "reserved bit" in the warning above
+			 * does not reference a hardware defined reserved bit
+			 * but rather a driver defined one.
+			 */
+			SMSC_WARNING(HW,
+				"Packet tag reserved bit is high");
+		} else {
+			if (unlikely(tx_stat & 0x00008000)) {
+				dev->stats.tx_errors++;
+			} else {
+				dev->stats.tx_packets++;
+				dev->stats.tx_bytes += (tx_stat >> 16);
+			}
+			if (unlikely(tx_stat & 0x00000100)) {
+				dev->stats.collisions += 16;
+				dev->stats.tx_aborted_errors += 1;
+			} else {
+				dev->stats.collisions +=
+				    ((tx_stat >> 3) & 0xF);
+			}
+			if (unlikely(tx_stat & 0x00000800))
+				dev->stats.tx_carrier_errors += 1;
+			if (unlikely(tx_stat & 0x00000200)) {
+				dev->stats.collisions++;
+				dev->stats.tx_aborted_errors++;
+			}
+		}
+	}
+}
+
+/* Increments the Rx error counters */
+static void
+smsc911x_rx_counterrors(struct net_device *dev, unsigned int rxstat)
+{
+	int crc_err = 0;
+
+	if (unlikely(rxstat & 0x00008000)) {
+		dev->stats.rx_errors++;
+		if (unlikely(rxstat & 0x00000002)) {
+			dev->stats.rx_crc_errors++;
+			crc_err = 1;
+		}
+	}
+	if (likely(!crc_err)) {
+		if (unlikely((rxstat & 0x00001020) == 0x00001020)) {
+			/* Frame type indicates length,
+			 * and length error is set */
+			dev->stats.rx_length_errors++;
+		}
+		if (rxstat & RX_STS_MCAST_)
+			dev->stats.multicast++;
+	}
+}
+
+/* Quickly dumps bad packets */
+static void
+smsc911x_rx_fastforward(struct smsc911x_data *pdata, unsigned int pktbytes)
+{
+	unsigned int pktwords = (pktbytes + NET_IP_ALIGN + 3) >> 2;
+
+	if (likely(pktwords >= 4)) {
+		unsigned int timeout = 500;
+		unsigned int val;
+		smsc911x_reg_write(pdata, RX_DP_CTRL, RX_DP_CTRL_RX_FFWD_);
+		do {
+			udelay(1);
+			val = smsc911x_reg_read(pdata, RX_DP_CTRL);
+		} while (timeout-- && (val & RX_DP_CTRL_RX_FFWD_));
+
+		if (unlikely(timeout == 0))
+			SMSC_WARNING(HW, "Timed out waiting for "
+				"RX FFWD to finish, RX_DP_CTRL: 0x%08X", val);
+	} else {
+		unsigned int temp;
+		while (pktwords--)
+			temp = smsc911x_reg_read(pdata, RX_DATA_FIFO);
+	}
+}
+
+/* NAPI poll function */
+static int smsc911x_poll(struct napi_struct *napi, int budget)
+{
+	struct smsc911x_data *pdata =
+		container_of(napi, struct smsc911x_data, napi);
+	struct net_device *dev = pdata->dev;
+	int npackets = 0;
+
+	while (likely(netif_running(dev)) && (npackets < budget)) {
+		unsigned int pktlength;
+		unsigned int pktwords;
+		struct sk_buff *skb;
+		unsigned int rxstat = smsc911x_rx_get_rxstatus(pdata);
+
+		if (!rxstat) {
+			unsigned int temp;
+			/* We processed all packets available.  Tell NAPI it can
+			 * stop polling then re-enable rx interrupts */
+			smsc911x_reg_write(pdata, INT_STS, INT_STS_RSFL_);
+			netif_rx_complete(dev, napi);
+			temp = smsc911x_reg_read(pdata, INT_EN);
+			temp |= INT_EN_RSFL_EN_;
+			smsc911x_reg_write(pdata, INT_EN, temp);
+			break;
+		}
+
+		/* Count packet for NAPI scheduling, even if it has an error.
+		 * Error packets still require cycles to discard */
+		npackets++;
+
+		pktlength = ((rxstat & 0x3FFF0000) >> 16);
+		pktwords = (pktlength + NET_IP_ALIGN + 3) >> 2;
+		smsc911x_rx_counterrors(dev, rxstat);
+
+		if (unlikely(rxstat & RX_STS_ES_)) {
+			SMSC_WARNING(RX_ERR,
+				"Discarding packet with error bit set");
+			/* Packet has an error, discard it and continue with
+			 * the next */
+			smsc911x_rx_fastforward(pdata, pktwords);
+			dev->stats.rx_dropped++;
+			continue;
+		}
+
+		skb = netdev_alloc_skb(dev, pktlength + NET_IP_ALIGN);
+		if (unlikely(!skb)) {
+			SMSC_WARNING(RX_ERR,
+				"Unable to allocate skb for rx packet");
+			/* Drop the packet and stop this polling iteration */
+			smsc911x_rx_fastforward(pdata, pktwords);
+			dev->stats.rx_dropped++;
+			break;
+		}
+
+		skb->data = skb->head;
+		skb_reset_tail_pointer(skb);
+
+		/* Align IP on 16B boundary */
+		skb_reserve(skb, NET_IP_ALIGN);
+		skb_put(skb, pktlength - 4);
+		smsc911x_rx_readfifo(pdata, (unsigned int *)skb->head,
+				     pktwords);
+		skb->protocol = eth_type_trans(skb, dev);
+		skb->ip_summed = CHECKSUM_NONE;
+		netif_receive_skb(skb);
+
+		/* Update counters */
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += (pktlength - 4);
+		dev->last_rx = jiffies;
+	}
+
+	/* Return total received packets */
+	return npackets;
+}
+
+/* Returns hash bit number for given MAC address
+ * Example:
+ * 01 00 5E 00 00 01 -> returns bit number 31 */
+static unsigned int smsc911x_hash(char addr[ETH_ALEN])
+{
+	return (ether_crc(ETH_ALEN, addr) >> 26) & 0x3f;
+}
+
+static void smsc911x_rx_multicast_update(struct smsc911x_data *pdata)
+{
+	/* Performs the multicast & mac_cr update.  This is called when
+	 * safe on the current hardware, and with the mac_lock held */
+	unsigned int mac_cr;
+
+	SMSC_ASSERT_MAC_LOCK(pdata);
+
+	mac_cr = smsc911x_mac_read(pdata, MAC_CR);
+	mac_cr |= pdata->set_bits_mask;
+	mac_cr &= ~(pdata->clear_bits_mask);
+	smsc911x_mac_write(pdata, MAC_CR, mac_cr);
+	smsc911x_mac_write(pdata, HASHH, pdata->hashhi);
+	smsc911x_mac_write(pdata, HASHL, pdata->hashlo);
+	SMSC_TRACE(HW, "maccr 0x%08X, HASHH 0x%08X, HASHL 0x%08X",
+		mac_cr, pdata->hashhi, pdata->hashlo);
+}
+
+static void smsc911x_rx_multicast_update_workaround(struct smsc911x_data *pdata)
+{
+	unsigned int mac_cr;
+
+	/* This function is only called for older LAN911x devices
+	 * (revA or revB), where MAC_CR, HASHH and HASHL should not
+	 * be modified during Rx - newer devices immediately update the
+	 * registers.
+	 *
+	 * This is called from interrupt context */
+
+	spin_lock(&pdata->mac_lock);
+
+	/* Check Rx has stopped */
+	if (smsc911x_mac_read(pdata, MAC_CR) & MAC_CR_RXEN_)
+		SMSC_WARNING(DRV, "Rx not stopped");
+
+	/* Perform the update - safe to do now Rx has stopped */
+	smsc911x_rx_multicast_update(pdata);
+
+	/* Re-enable Rx */
+	mac_cr = smsc911x_mac_read(pdata, MAC_CR);
+	mac_cr |= MAC_CR_RXEN_;
+	smsc911x_mac_write(pdata, MAC_CR, mac_cr);
+
+	pdata->multicast_update_pending = 0;
+
+	spin_unlock(&pdata->mac_lock);
+}
+
+static int smsc911x_soft_reset(struct smsc911x_data *pdata)
+{
+	unsigned int timeout;
+	unsigned int temp;
+
+	/* Reset the LAN911x */
+	smsc911x_reg_write(pdata, HW_CFG, HW_CFG_SRST_);
+	timeout = 10;
+	do {
+		udelay(10);
+		temp = smsc911x_reg_read(pdata, HW_CFG);
+	} while ((--timeout) && (temp & HW_CFG_SRST_));
+
+	if (unlikely(temp & HW_CFG_SRST_)) {
+		SMSC_WARNING(DRV, "Failed to complete reset");
+		return -EIO;
+	}
+	return 0;
+}
+
+/* Sets the device MAC address to dev_addr, called with mac_lock held */
+static void
+smsc911x_set_mac_address(struct smsc911x_data *pdata, u8 dev_addr[6])
+{
+	u32 mac_high16 = (dev_addr[5] << 8) | dev_addr[4];
+	u32 mac_low32 = (dev_addr[3] << 24) | (dev_addr[2] << 16) |
+	    (dev_addr[1] << 8) | dev_addr[0];
+
+	SMSC_ASSERT_MAC_LOCK(pdata);
+
+	smsc911x_mac_write(pdata, ADDRH, mac_high16);
+	smsc911x_mac_write(pdata, ADDRL, mac_low32);
+}
+
+static int smsc911x_open(struct net_device *dev)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	unsigned int timeout;
+	unsigned int temp;
+	unsigned int intcfg;
+
+	/* if the phy is not yet registered, retry later*/
+	if (!pdata->phy_dev) {
+		SMSC_WARNING(HW, "phy_dev is NULL");
+		return -EAGAIN;
+	}
+
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		SMSC_WARNING(HW, "dev_addr is not a valid MAC address");
+		return -EADDRNOTAVAIL;
+	}
+
+	/* Reset the LAN911x */
+	if (smsc911x_soft_reset(pdata)) {
+		SMSC_WARNING(HW, "soft reset failed");
+		return -EIO;
+	}
+
+	smsc911x_reg_write(pdata, HW_CFG, 0x00050000);
+	smsc911x_reg_write(pdata, AFC_CFG, 0x006E3740);
+
+	/* Make sure EEPROM has finished loading before setting GPIO_CFG */
+	timeout = 50;
+	while ((timeout--) &&
+	       (smsc911x_reg_read(pdata, E2P_CMD) & E2P_CMD_EPC_BUSY_)) {
+		udelay(10);
+	}
+
+	if (unlikely(timeout == 0))
+		SMSC_WARNING(IFUP,
+			"Timed out waiting for EEPROM busy bit to clear");
+
+	smsc911x_reg_write(pdata, GPIO_CFG, 0x70070000);
+
+	/* The soft reset above cleared the device's MAC address,
+	 * restore it from local copy (set in probe) */
+	spin_lock_irq(&pdata->mac_lock);
+	smsc911x_set_mac_address(pdata, dev->dev_addr);
+	spin_unlock_irq(&pdata->mac_lock);
+
+	/* Initialise irqs, but leave all sources disabled */
+	smsc911x_reg_write(pdata, INT_EN, 0);
+	smsc911x_reg_write(pdata, INT_STS, 0xFFFFFFFF);
+
+	/* Set interrupt deassertion to 100uS */
+	intcfg = ((10 << 24) | INT_CFG_IRQ_EN_);
+
+	if (pdata->irq_polarity) {
+		SMSC_TRACE(IFUP, "irq polarity: active high");
+		intcfg |= INT_CFG_IRQ_POL_;
+	} else {
+		SMSC_TRACE(IFUP, "irq polarity: active low");
+	}
+
+	if (pdata->irq_type) {
+		SMSC_TRACE(IFUP, "irq type: push-pull");
+		intcfg |= INT_CFG_IRQ_TYPE_;
+	} else {
+		SMSC_TRACE(IFUP, "irq type: open drain");
+	}
+
+	smsc911x_reg_write(pdata, INT_CFG, intcfg);
+
+	SMSC_TRACE(IFUP, "Testing irq handler using IRQ %d", dev->irq);
+	pdata->software_irq_signal = 0;
+	smp_wmb();
+
+	temp = smsc911x_reg_read(pdata, INT_EN);
+	temp |= INT_EN_SW_INT_EN_;
+	smsc911x_reg_write(pdata, INT_EN, temp);
+
+	timeout = 1000;
+	while (timeout--) {
+		if (pdata->software_irq_signal)
+			break;
+		msleep(1);
+	}
+
+	if (!pdata->software_irq_signal) {
+		dev_warn(&dev->dev, "ISR failed signaling test (IRQ %d)\n",
+			 dev->irq);
+		return -ENODEV;
+	}
+	SMSC_TRACE(IFUP, "IRQ handler passed test using IRQ %d", dev->irq);
+
+	dev_info(&dev->dev, "SMSC911x/921x identified at %#08lx, IRQ: %d\n",
+		 (unsigned long)pdata->ioaddr, dev->irq);
+
+	/* Bring the PHY up */
+	phy_start(pdata->phy_dev);
+
+	temp = smsc911x_reg_read(pdata, HW_CFG);
+	/* Preserve TX FIFO size and external PHY configuration */
+	temp &= (HW_CFG_TX_FIF_SZ_|0x00000FFF);
+	temp |= HW_CFG_SF_;
+	smsc911x_reg_write(pdata, HW_CFG, temp);
+
+	temp = smsc911x_reg_read(pdata, FIFO_INT);
+	temp |= FIFO_INT_TX_AVAIL_LEVEL_;
+	temp &= ~(FIFO_INT_RX_STS_LEVEL_);
+	smsc911x_reg_write(pdata, FIFO_INT, temp);
+
+	/* set RX Data offset to 2 bytes for alignment */
+	smsc911x_reg_write(pdata, RX_CFG, (2 << 8));
+
+	/* enable NAPI polling before enabling RX interrupts */
+	napi_enable(&pdata->napi);
+
+	temp = smsc911x_reg_read(pdata, INT_EN);
+	temp |= (INT_EN_TDFA_EN_ | INT_EN_RSFL_EN_);
+	smsc911x_reg_write(pdata, INT_EN, temp);
+
+	spin_lock_irq(&pdata->mac_lock);
+	temp = smsc911x_mac_read(pdata, MAC_CR);
+	temp |= (MAC_CR_TXEN_ | MAC_CR_RXEN_ | MAC_CR_HBDIS_);
+	smsc911x_mac_write(pdata, MAC_CR, temp);
+	spin_unlock_irq(&pdata->mac_lock);
+
+	smsc911x_reg_write(pdata, TX_CFG, TX_CFG_TX_ON_);
+
+	netif_start_queue(dev);
+	return 0;
+}
+
+/* Entry point for stopping the interface */
+static int smsc911x_stop(struct net_device *dev)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	unsigned int temp;
+
+	BUG_ON(!pdata->phy_dev);
+
+	/* Disable all device interrupts */
+	temp = smsc911x_reg_read(pdata, INT_CFG);
+	temp &= ~INT_CFG_IRQ_EN_;
+	smsc911x_reg_write(pdata, INT_CFG, temp);
+
+	/* Stop Tx and Rx polling */
+	netif_stop_queue(dev);
+	napi_disable(&pdata->napi);
+
+	/* At this point all Rx and Tx activity is stopped */
+	dev->stats.rx_dropped += smsc911x_reg_read(pdata, RX_DROP);
+	smsc911x_tx_update_txcounters(dev);
+
+	/* Bring the PHY down */
+	phy_stop(pdata->phy_dev);
+
+	SMSC_TRACE(IFDOWN, "Interface stopped");
+	return 0;
+}
+
+/* Entry point for transmitting a packet */
+static int smsc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	unsigned int freespace;
+	unsigned int tx_cmd_a;
+	unsigned int tx_cmd_b;
+	unsigned int temp;
+	u32 wrsz;
+	ulong bufp;
+
+	freespace = smsc911x_reg_read(pdata, TX_FIFO_INF) & TX_FIFO_INF_TDFREE_;
+
+	if (unlikely(freespace < TX_FIFO_LOW_THRESHOLD))
+		SMSC_WARNING(TX_ERR,
+			"Tx data fifo low, space available: %d", freespace);
+
+	/* Word alignment adjustment */
+	tx_cmd_a = (u32)((ulong)skb->data & 0x03) << 16;
+	tx_cmd_a |= TX_CMD_A_FIRST_SEG_ | TX_CMD_A_LAST_SEG_;
+	tx_cmd_a |= (unsigned int)skb->len;
+
+	tx_cmd_b = ((unsigned int)skb->len) << 16;
+	tx_cmd_b |= (unsigned int)skb->len;
+
+	smsc911x_reg_write(pdata, TX_DATA_FIFO, tx_cmd_a);
+	smsc911x_reg_write(pdata, TX_DATA_FIFO, tx_cmd_b);
+
+	bufp = (ulong)skb->data & (~0x3);
+	wrsz = (u32)skb->len + 3;
+	wrsz += (u32)((ulong)skb->data & 0x3);
+	wrsz >>= 2;
+
+	smsc911x_tx_writefifo(pdata, (unsigned int *)bufp, wrsz);
+	freespace -= (skb->len + 32);
+	dev_kfree_skb(skb);
+	dev->trans_start = jiffies;
+
+	if (unlikely(smsc911x_tx_get_txstatcount(pdata) >= 30))
+		smsc911x_tx_update_txcounters(dev);
+
+	if (freespace < TX_FIFO_LOW_THRESHOLD) {
+		netif_stop_queue(dev);
+		temp = smsc911x_reg_read(pdata, FIFO_INT);
+		temp &= 0x00FFFFFF;
+		temp |= 0x32000000;
+		smsc911x_reg_write(pdata, FIFO_INT, temp);
+	}
+
+	return NETDEV_TX_OK;
+}
+
+/* Entry point for getting status counters */
+static struct net_device_stats *smsc911x_get_stats(struct net_device *dev)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	smsc911x_tx_update_txcounters(dev);
+	dev->stats.rx_dropped += smsc911x_reg_read(pdata, RX_DROP);
+	return &dev->stats;
+}
+
+/* Entry point for setting addressing modes */
+static void smsc911x_set_multicast_list(struct net_device *dev)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	unsigned long flags;
+
+	if (dev->flags & IFF_PROMISC) {
+		/* Enabling promiscuous mode */
+		pdata->set_bits_mask = MAC_CR_PRMS_;
+		pdata->clear_bits_mask = (MAC_CR_MCPAS_ | MAC_CR_HPFILT_);
+		pdata->hashhi = 0;
+		pdata->hashlo = 0;
+	} else if (dev->flags & IFF_ALLMULTI) {
+		/* Enabling all multicast mode */
+		pdata->set_bits_mask = MAC_CR_MCPAS_;
+		pdata->clear_bits_mask = (MAC_CR_PRMS_ | MAC_CR_HPFILT_);
+		pdata->hashhi = 0;
+		pdata->hashlo = 0;
+	} else if (dev->mc_count > 0) {
+		/* Enabling specific multicast addresses */
+		unsigned int hash_high = 0;
+		unsigned int hash_low = 0;
+		unsigned int count = 0;
+		struct dev_mc_list *mc_list = dev->mc_list;
+
+		pdata->set_bits_mask = MAC_CR_HPFILT_;
+		pdata->clear_bits_mask = (MAC_CR_PRMS_ | MAC_CR_MCPAS_);
+
+		while (mc_list) {
+			count++;
+			if ((mc_list->dmi_addrlen) == ETH_ALEN) {
+				unsigned int bitnum =
+				    smsc911x_hash(mc_list->dmi_addr);
+				unsigned int mask = 0x01 << (bitnum & 0x1F);
+				if (bitnum & 0x20)
+					hash_high |= mask;
+				else
+					hash_low |= mask;
+			} else {
+				SMSC_WARNING(DRV, "dmi_addrlen != 6");
+			}
+			mc_list = mc_list->next;
+		}
+		if (count != (unsigned int)dev->mc_count)
+			SMSC_WARNING(DRV, "mc_count != dev->mc_count");
+
+		pdata->hashhi = hash_high;
+		pdata->hashlo = hash_low;
+	} else {
+		/* Enabling local MAC address only */
+		pdata->set_bits_mask = 0;
+		pdata->clear_bits_mask =
+		    (MAC_CR_PRMS_ | MAC_CR_MCPAS_ | MAC_CR_HPFILT_);
+		pdata->hashhi = 0;
+		pdata->hashlo = 0;
+	}
+
+	spin_lock_irqsave(&pdata->mac_lock, flags);
+
+	if (pdata->generation <= 1) {
+		/* Older hardware revision - cannot change these flags while
+		 * receiving data */
+		if (!pdata->multicast_update_pending) {
+			unsigned int temp;
+			SMSC_TRACE(HW, "scheduling mcast update");
+			pdata->multicast_update_pending = 1;
+
+			/* Request the hardware to stop, then perform the
+			 * update when we get an RX_STOP interrupt */
+			smsc911x_reg_write(pdata, INT_STS, INT_STS_RXSTOP_INT_);
+			temp = smsc911x_reg_read(pdata, INT_EN);
+			temp |= INT_EN_RXSTOP_INT_EN_;
+			smsc911x_reg_write(pdata, INT_EN, temp);
+
+			temp = smsc911x_mac_read(pdata, MAC_CR);
+			temp &= ~(MAC_CR_RXEN_);
+			smsc911x_mac_write(pdata, MAC_CR, temp);
+		} else {
+			/* There is another update pending, this should now
+			 * use the newer values */
+		}
+	} else {
+		/* Newer hardware revision - can write immediately */
+		smsc911x_rx_multicast_update(pdata);
+	}
+
+	spin_unlock_irqrestore(&pdata->mac_lock, flags);
+}
+
+static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	u32 intsts = smsc911x_reg_read(pdata, INT_STS);
+	u32 inten = smsc911x_reg_read(pdata, INT_EN);
+	int serviced = IRQ_NONE;
+	u32 temp;
+
+	if (unlikely(intsts & inten & INT_STS_SW_INT_)) {
+		temp = smsc911x_reg_read(pdata, INT_EN);
+		temp &= (~INT_EN_SW_INT_EN_);
+		smsc911x_reg_write(pdata, INT_EN, temp);
+		smsc911x_reg_write(pdata, INT_STS, INT_STS_SW_INT_);
+		pdata->software_irq_signal = 1;
+		smp_wmb();
+		serviced = IRQ_HANDLED;
+	}
+
+	if (unlikely(intsts & inten & INT_STS_RXSTOP_INT_)) {
+		/* Called when there is a multicast update scheduled and
+		 * it is now safe to complete the update */
+		SMSC_TRACE(INTR, "RX Stop interrupt");
+		temp = smsc911x_reg_read(pdata, INT_EN);
+		temp &= (~INT_EN_RXSTOP_INT_EN_);
+		smsc911x_reg_write(pdata, INT_EN, temp);
+		smsc911x_reg_write(pdata, INT_STS, INT_STS_RXSTOP_INT_);
+		smsc911x_rx_multicast_update_workaround(pdata);
+		serviced = IRQ_HANDLED;
+	}
+
+	if (intsts & inten & INT_STS_TDFA_) {
+		temp = smsc911x_reg_read(pdata, FIFO_INT);
+		temp |= FIFO_INT_TX_AVAIL_LEVEL_;
+		smsc911x_reg_write(pdata, FIFO_INT, temp);
+		smsc911x_reg_write(pdata, INT_STS, INT_STS_TDFA_);
+		netif_wake_queue(dev);
+		serviced = IRQ_HANDLED;
+	}
+
+	if (unlikely(intsts & inten & INT_STS_RXE_)) {
+		SMSC_TRACE(INTR, "RX Error interrupt");
+		smsc911x_reg_write(pdata, INT_STS, INT_STS_RXE_);
+		serviced = IRQ_HANDLED;
+	}
+
+	if (likely(intsts & inten & INT_STS_RSFL_)) {
+		if (likely(netif_rx_schedule_prep(dev, &pdata->napi))) {
+			/* Disable Rx interrupts */
+			temp = smsc911x_reg_read(pdata, INT_EN);
+			temp &= (~INT_EN_RSFL_EN_);
+			smsc911x_reg_write(pdata, INT_EN, temp);
+			/* Schedule a NAPI poll */
+			__netif_rx_schedule(dev, &pdata->napi);
+		} else {
+			SMSC_WARNING(RX_ERR,
+				"netif_rx_schedule_prep failed");
+		}
+		serviced = IRQ_HANDLED;
+	}
+
+	return serviced;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+void smsc911x_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	smsc911x_irqhandler(0, dev);
+	enable_irq(dev->irq);
+}
+#endif				/* CONFIG_NET_POLL_CONTROLLER */
+
+/* Standard ioctls for mii-tool */
+static int smsc911x_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+
+	if (!netif_running(dev) || !pdata->phy_dev)
+		return -EINVAL;
+
+	return phy_mii_ioctl(pdata->phy_dev, if_mii(ifr), cmd);
+}
+
+static int
+smsc911x_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+
+	cmd->maxtxpkt = 1;
+	cmd->maxrxpkt = 1;
+	return phy_ethtool_gset(pdata->phy_dev, cmd);
+}
+
+static int
+smsc911x_ethtool_setsettings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+
+	return phy_ethtool_sset(pdata->phy_dev, cmd);
+}
+
+static void smsc911x_ethtool_getdrvinfo(struct net_device *dev,
+					struct ethtool_drvinfo *info)
+{
+	strlcpy(info->driver, SMSC_CHIPNAME, sizeof(info->driver));
+	strlcpy(info->version, SMSC_DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, dev->dev.parent->bus_id,
+		sizeof(info->bus_info));
+}
+
+static int smsc911x_ethtool_nwayreset(struct net_device *dev)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+
+	return phy_start_aneg(pdata->phy_dev);
+}
+
+static u32 smsc911x_ethtool_getmsglevel(struct net_device *dev)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	return pdata->msg_enable;
+}
+
+static void smsc911x_ethtool_setmsglevel(struct net_device *dev, u32 level)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	pdata->msg_enable = level;
+}
+
+static int smsc911x_ethtool_getregslen(struct net_device *dev)
+{
+	return (((E2P_DATA - ID_REV) / 4 + 1) + (WUCSR - MAC_CR) + 1 + 32) *
+	    sizeof(u32);
+}
+
+static void
+smsc911x_ethtool_getregs(struct net_device *dev, struct ethtool_regs *regs,
+			 void *buf)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	struct phy_device *phy_dev = pdata->phy_dev;
+	unsigned long flags;
+	unsigned int i;
+	unsigned int j = 0;
+	u32 *data = buf;
+
+	regs->version = pdata->idrev;
+	for (i = ID_REV; i <= E2P_DATA; i += (sizeof(u32)))
+		data[j++] = smsc911x_reg_read(pdata, i);
+
+	for (i = MAC_CR; i <= WUCSR; i++) {
+		spin_lock_irqsave(&pdata->mac_lock, flags);
+		data[j++] = smsc911x_mac_read(pdata, i);
+		spin_unlock_irqrestore(&pdata->mac_lock, flags);
+	}
+
+	for (i = 0; i <= 31; i++)
+		data[j++] = smsc911x_mii_read(phy_dev->bus, phy_dev->addr, i);
+}
+
+static void smsc911x_eeprom_enable_access(struct smsc911x_data *pdata)
+{
+	unsigned int temp = smsc911x_reg_read(pdata, GPIO_CFG);
+	temp &= ~GPIO_CFG_EEPR_EN_;
+	smsc911x_reg_write(pdata, GPIO_CFG, temp);
+	msleep(1);
+}
+
+static int smsc911x_eeprom_send_cmd(struct smsc911x_data *pdata, u32 op)
+{
+	int timeout = 100;
+	u32 e2cmd;
+
+	SMSC_TRACE(DRV, "op 0x%08x", op);
+	if (smsc911x_reg_read(pdata, E2P_CMD) & E2P_CMD_EPC_BUSY_) {
+		SMSC_WARNING(DRV, "Busy at start");
+		return -EBUSY;
+	}
+
+	e2cmd = op | E2P_CMD_EPC_BUSY_;
+	smsc911x_reg_write(pdata, E2P_CMD, e2cmd);
+
+	do {
+		msleep(1);
+		e2cmd = smsc911x_reg_read(pdata, E2P_CMD);
+	} while ((e2cmd & E2P_CMD_EPC_BUSY_) && (timeout--));
+
+	if (!timeout) {
+		SMSC_TRACE(DRV, "TIMED OUT");
+		return -EAGAIN;
+	}
+
+	if (e2cmd & E2P_CMD_EPC_TIMEOUT_) {
+		SMSC_TRACE(DRV, "Error occured during eeprom operation");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int smsc911x_eeprom_read_location(struct smsc911x_data *pdata,
+					 u8 address, u8 *data)
+{
+	u32 op = E2P_CMD_EPC_CMD_READ_ | address;
+	int ret;
+
+	SMSC_TRACE(DRV, "address 0x%x", address);
+	ret = smsc911x_eeprom_send_cmd(pdata, op);
+
+	if (!ret)
+		data[address] = smsc911x_reg_read(pdata, E2P_DATA);
+
+	return ret;
+}
+
+static int smsc911x_eeprom_write_location(struct smsc911x_data *pdata,
+					  u8 address, u8 data)
+{
+	u32 op = E2P_CMD_EPC_CMD_ERASE_ | address;
+	int ret;
+
+	SMSC_TRACE(DRV, "address 0x%x, data 0x%x", address, data);
+	ret = smsc911x_eeprom_send_cmd(pdata, op);
+
+	if (!ret) {
+		op = E2P_CMD_EPC_CMD_WRITE_ | address;
+		smsc911x_reg_write(pdata, E2P_DATA, (u32)data);
+		ret = smsc911x_eeprom_send_cmd(pdata, op);
+	}
+
+	return ret;
+}
+
+static int smsc911x_ethtool_get_eeprom_len(struct net_device *dev)
+{
+	return SMSC911X_EEPROM_SIZE;
+}
+
+static int smsc911x_ethtool_get_eeprom(struct net_device *dev,
+				       struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	u8 eeprom_data[SMSC911X_EEPROM_SIZE];
+	int len;
+	int i;
+
+	smsc911x_eeprom_enable_access(pdata);
+
+	len = min(eeprom->len, SMSC911X_EEPROM_SIZE);
+	for (i = 0; i < len; i++) {
+		int ret = smsc911x_eeprom_read_location(pdata, i, eeprom_data);
+		if (ret < 0) {
+			eeprom->len = 0;
+			return ret;
+		}
+	}
+
+	memcpy(data, &eeprom_data[eeprom->offset], len);
+	eeprom->len = len;
+	return 0;
+}
+
+static int smsc911x_ethtool_set_eeprom(struct net_device *dev,
+				       struct ethtool_eeprom *eeprom, u8 *data)
+{
+	int ret;
+	struct smsc911x_data *pdata = netdev_priv(dev);
+
+	smsc911x_eeprom_enable_access(pdata);
+	smsc911x_eeprom_send_cmd(pdata, E2P_CMD_EPC_CMD_EWEN_);
+	ret = smsc911x_eeprom_write_location(pdata, eeprom->offset, *data);
+	smsc911x_eeprom_send_cmd(pdata, E2P_CMD_EPC_CMD_EWDS_);
+
+	/* Single byte write, according to man page */
+	eeprom->len = 1;
+
+	return ret;
+}
+
+static struct ethtool_ops smsc911x_ethtool_ops = {
+	.get_settings = smsc911x_ethtool_getsettings,
+	.set_settings = smsc911x_ethtool_setsettings,
+	.get_link = ethtool_op_get_link,
+	.get_drvinfo = smsc911x_ethtool_getdrvinfo,
+	.nway_reset = smsc911x_ethtool_nwayreset,
+	.get_msglevel = smsc911x_ethtool_getmsglevel,
+	.set_msglevel = smsc911x_ethtool_setmsglevel,
+	.get_regs_len = smsc911x_ethtool_getregslen,
+	.get_regs = smsc911x_ethtool_getregs,
+	.get_eeprom_len = smsc911x_ethtool_get_eeprom_len,
+	.get_eeprom = smsc911x_ethtool_get_eeprom,
+	.set_eeprom = smsc911x_ethtool_set_eeprom,
+};
+
+/* Initializing private device structures, only called from probe */
+static int __devinit smsc911x_init(struct net_device *dev)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	unsigned int byte_test;
+
+	SMSC_TRACE(PROBE, "Driver Parameters:");
+	SMSC_TRACE(PROBE, "LAN base: 0x%08lX",
+		(unsigned long)pdata->ioaddr);
+	SMSC_TRACE(PROBE, "IRQ: %d", dev->irq);
+	SMSC_TRACE(PROBE, "PHY will be autodetected.");
+
+#if (!SMSC_CAN_USE_32BIT)
+	spin_lock_init(&pdata->dev_lock);
+#endif
+
+	if (pdata->ioaddr == 0) {
+		SMSC_WARNING(PROBE, "pdata->ioaddr: 0x00000000");
+		return -ENODEV;
+	}
+
+	/* Check byte ordering */
+	byte_test = smsc911x_reg_read(pdata, BYTE_TEST);
+	SMSC_TRACE(PROBE, "BYTE_TEST: 0x%08X", byte_test);
+	if (byte_test == 0x43218765) {
+		SMSC_TRACE(PROBE, "BYTE_TEST looks swapped, "
+			"applying WORD_SWAP");
+		smsc911x_reg_write(pdata, WORD_SWAP, 0xffffffff);
+
+		/* 1 dummy read of BYTE_TEST is needed after a write to
+		 * WORD_SWAP before its contents are valid */
+		byte_test = smsc911x_reg_read(pdata, BYTE_TEST);
+
+		byte_test = smsc911x_reg_read(pdata, BYTE_TEST);
+	}
+
+	if (byte_test != 0x87654321) {
+		SMSC_WARNING(DRV, "BYTE_TEST: 0x%08X", byte_test);
+		if (((byte_test >> 16) & 0xFFFF) == (byte_test & 0xFFFF)) {
+			SMSC_WARNING(PROBE,
+				"top 16 bits equal to bottom 16 bits");
+			SMSC_TRACE(PROBE, "This may mean the chip is set "
+				"for 32 bit while the bus is reading 16 bit");
+		}
+		return -ENODEV;
+	}
+
+	/* Default generation to zero (all workarounds apply) */
+	pdata->generation = 0;
+
+	pdata->idrev = smsc911x_reg_read(pdata, ID_REV);
+	switch (pdata->idrev & 0xFFFF0000) {
+	case 0x01180000:
+	case 0x01170000:
+	case 0x01160000:
+	case 0x01150000:
+		/* LAN911[5678] family */
+		pdata->generation = pdata->idrev & 0x0000FFFF;
+		break;
+
+	case 0x118A0000:
+	case 0x117A0000:
+	case 0x116A0000:
+	case 0x115A0000:
+		/* LAN921[5678] family */
+		pdata->generation = 3;
+		break;
+
+	case 0x92100000:
+	case 0x92110000:
+	case 0x92200000:
+	case 0x92210000:
+		/* LAN9210/LAN9211/LAN9220/LAN9221 */
+		pdata->generation = 4;
+		break;
+
+	default:
+		SMSC_WARNING(PROBE, "LAN911x not identified, idrev: 0x%08X",
+			pdata->idrev);
+		return -ENODEV;
+	}
+
+	SMSC_TRACE(PROBE, "LAN911x identified, idrev: 0x%08X, generation: %d",
+		pdata->idrev, pdata->generation);
+
+	if (pdata->generation == 0)
+		SMSC_WARNING(PROBE,
+			"This driver is not intended for this chip revision");
+
+	/* Reset the LAN911x */
+	if (smsc911x_soft_reset(pdata))
+		return -ENODEV;
+
+	/* Disable all interrupt sources until we bring the device up */
+	smsc911x_reg_write(pdata, INT_EN, 0);
+
+	ether_setup(dev);
+	dev->open = smsc911x_open;
+	dev->stop = smsc911x_stop;
+	dev->hard_start_xmit = smsc911x_hard_start_xmit;
+	dev->get_stats = smsc911x_get_stats;
+	dev->set_multicast_list = smsc911x_set_multicast_list;
+	dev->flags |= IFF_MULTICAST;
+	dev->do_ioctl = smsc911x_do_ioctl;
+	netif_napi_add(dev, &pdata->napi, smsc911x_poll, SMSC_NAPI_WEIGHT);
+	dev->ethtool_ops = &smsc911x_ethtool_ops;
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = smsc911x_poll_controller;
+#endif				/* CONFIG_NET_POLL_CONTROLLER */
+
+	return 0;
+}
+
+static int __devexit smsc911x_drv_remove(struct platform_device *pdev)
+{
+	struct net_device *dev;
+	struct smsc911x_data *pdata;
+	struct resource *res;
+
+	dev = platform_get_drvdata(pdev);
+	BUG_ON(!dev);
+	pdata = netdev_priv(dev);
+	BUG_ON(!pdata);
+	BUG_ON(!pdata->ioaddr);
+	BUG_ON(!pdata->phy_dev);
+
+	SMSC_TRACE(IFDOWN, "Stopping driver.");
+
+	phy_disconnect(pdata->phy_dev);
+	pdata->phy_dev = NULL;
+	mdiobus_unregister(pdata->mii_bus);
+	mdiobus_free(pdata->mii_bus);
+
+	platform_set_drvdata(pdev, NULL);
+	unregister_netdev(dev);
+	free_irq(dev->irq, dev);
+	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
+					   "smsc911x-memory");
+	if (!res)
+		platform_get_resource(pdev, IORESOURCE_MEM, 0);
+
+	release_mem_region(res->start, res->end - res->start);
+
+	iounmap(pdata->ioaddr);
+
+	free_netdev(dev);
+
+	return 0;
+}
+
+static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
+{
+	struct net_device *dev;
+	struct smsc911x_data *pdata;
+	struct resource *res;
+	unsigned int intcfg = 0;
+	int res_size;
+	int retval;
+	DECLARE_MAC_BUF(mac);
+
+	pr_info("%s: Driver version %s.\n", SMSC_CHIPNAME, SMSC_DRV_VERSION);
+
+	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
+					   "smsc911x-memory");
+	if (!res)
+		res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		pr_warning("%s: Could not allocate resource.\n",
+			SMSC_CHIPNAME);
+		retval = -ENODEV;
+		goto out_0;
+	}
+	res_size = res->end - res->start;
+
+	if (!request_mem_region(res->start, res_size, SMSC_CHIPNAME)) {
+		retval = -EBUSY;
+		goto out_0;
+	}
+
+	dev = alloc_etherdev(sizeof(struct smsc911x_data));
+	if (!dev) {
+		pr_warning("%s: Could not allocate device.\n", SMSC_CHIPNAME);
+		retval = -ENOMEM;
+		goto out_release_io_1;
+	}
+
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
+	pdata = netdev_priv(dev);
+
+	dev->irq = platform_get_irq(pdev, 0);
+	pdata->ioaddr = ioremap_nocache(res->start, res_size);
+
+	/* copy config parameters across if present, otherwise pdata
+	 * defaults to zeros */
+	if (pdev->dev.platform_data) {
+		struct smsc911x_platform_config *config =
+			pdev->dev.platform_data;
+		pdata->irq_polarity = config->irq_polarity;
+		pdata->irq_type  = config->irq_type;
+		pdata->phy_interface = config->phy_interface;
+	}
+
+	pdata->dev = dev;
+	pdata->msg_enable = ((1 << debug) - 1);
+
+	if (pdata->ioaddr == NULL) {
+		SMSC_WARNING(PROBE,
+			"Error smsc911x base address invalid");
+		retval = -ENOMEM;
+		goto out_free_netdev_2;
+	}
+
+	retval = smsc911x_init(dev);
+	if (retval < 0)
+		goto out_unmap_io_3;
+
+	/* configure irq polarity and type before connecting isr */
+	if (pdata->irq_polarity == SMSC911X_IRQ_POLARITY_ACTIVE_HIGH)
+		intcfg |= INT_CFG_IRQ_POL_;
+
+	if (pdata->irq_type == SMSC911X_IRQ_TYPE_PUSH_PULL)
+		intcfg |= INT_CFG_IRQ_TYPE_;
+
+	smsc911x_reg_write(pdata, INT_CFG, intcfg);
+
+	/* Ensure interrupts are globally disabled before connecting ISR */
+	smsc911x_reg_write(pdata, INT_EN, 0);
+	smsc911x_reg_write(pdata, INT_STS, 0xFFFFFFFF);
+
+	retval = request_irq(dev->irq, smsc911x_irqhandler, IRQF_DISABLED,
+			     SMSC_CHIPNAME, dev);
+	if (retval) {
+		SMSC_WARNING(PROBE,
+			"Unable to claim requested irq: %d", dev->irq);
+		goto out_unmap_io_3;
+	}
+
+	platform_set_drvdata(pdev, dev);
+
+	retval = register_netdev(dev);
+	if (retval) {
+		SMSC_WARNING(PROBE,
+			"Error %i registering device", retval);
+		goto out_unset_drvdata_4;
+	} else {
+		SMSC_TRACE(PROBE, "Network interface: \"%s\"", dev->name);
+	}
+
+	spin_lock_init(&pdata->mac_lock);
+
+	retval = smsc911x_mii_init(pdev, dev);
+	if (retval) {
+		SMSC_WARNING(PROBE,
+			"Error %i initialising mii", retval);
+		goto out_unregister_netdev_5;
+	}
+
+	spin_lock_irq(&pdata->mac_lock);
+
+	/* Check if mac address has been specified when bringing interface up */
+	if (is_valid_ether_addr(dev->dev_addr)) {
+		smsc911x_set_mac_address(pdata, dev->dev_addr);
+		SMSC_TRACE(PROBE, "MAC Address is specified by configuration");
+	} else {
+		/* Try reading mac address from device. if EEPROM is present
+		 * it will already have been set */
+		u32 mac_high16 = smsc911x_mac_read(pdata, ADDRH);
+		u32 mac_low32 = smsc911x_mac_read(pdata, ADDRL);
+		dev->dev_addr[0] = (u8)(mac_low32);
+		dev->dev_addr[1] = (u8)(mac_low32 >> 8);
+		dev->dev_addr[2] = (u8)(mac_low32 >> 16);
+		dev->dev_addr[3] = (u8)(mac_low32 >> 24);
+		dev->dev_addr[4] = (u8)(mac_high16);
+		dev->dev_addr[5] = (u8)(mac_high16 >> 8);
+
+		if (is_valid_ether_addr(dev->dev_addr)) {
+			/* eeprom values are valid  so use them */
+			SMSC_TRACE(PROBE,
+				"Mac Address is read from LAN911x EEPROM");
+		} else {
+			/* eeprom values are invalid, generate random MAC */
+			random_ether_addr(dev->dev_addr);
+			smsc911x_set_mac_address(pdata, dev->dev_addr);
+			SMSC_TRACE(PROBE,
+				"MAC Address is set to random_ether_addr");
+		}
+	}
+
+	spin_unlock_irq(&pdata->mac_lock);
+
+	dev_info(&dev->dev, "MAC Address: %s\n",
+		 print_mac(mac, dev->dev_addr));
+
+	return 0;
+
+out_unregister_netdev_5:
+	unregister_netdev(dev);
+out_unset_drvdata_4:
+	platform_set_drvdata(pdev, NULL);
+	free_irq(dev->irq, dev);
+out_unmap_io_3:
+	iounmap(pdata->ioaddr);
+out_free_netdev_2:
+	free_netdev(dev);
+out_release_io_1:
+	release_mem_region(res->start, res->end - res->start);
+out_0:
+	return retval;
+}
+
+static struct platform_driver smsc911x_driver = {
+	.probe = smsc911x_drv_probe,
+	.remove = smsc911x_drv_remove,
+	.driver = {
+		.name = SMSC_CHIPNAME,
+	},
+};
+
+/* Entry point for loading the module */
+static int __init smsc911x_init_module(void)
+{
+	return platform_driver_register(&smsc911x_driver);
+}
+
+/* entry point for unloading the module */
+static void __exit smsc911x_cleanup_module(void)
+{
+	platform_driver_unregister(&smsc911x_driver);
+}
+
+module_init(smsc911x_init_module);
+module_exit(smsc911x_cleanup_module);
diff --git a/drivers/net/smsc911x.h b/drivers/net/smsc911x.h
new file mode 100644
index 0000000..feb36de
--- /dev/null
+++ b/drivers/net/smsc911x.h
@@ -0,0 +1,394 @@
+/***************************************************************************
+ *
+ * Copyright (C) 2004-2008 SMSC
+ * Copyright (C) 2005-2008 ARM
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ ***************************************************************************/
+#ifndef __SMSC911X_H__
+#define __SMSC911X_H__
+
+#define SMSC_CAN_USE_32BIT	1
+#define TX_FIFO_LOW_THRESHOLD	((u32)1600)
+#define SMSC911X_EEPROM_SIZE	((u32)7)
+#define USE_DEBUG		0
+
+/* This is the maximum number of packets to be received every
+ * NAPI poll */
+#define SMSC_NAPI_WEIGHT	16
+
+/* implements a PHY loopback test at initialisation time, to ensure a packet
+ * can be succesfully looped back */
+#define USE_PHY_WORK_AROUND
+
+#define DPRINTK(nlevel, klevel, fmt, args...) \
+	((void)((NETIF_MSG_##nlevel & pdata->msg_enable) && \
+	printk(KERN_##klevel "%s: %s: " fmt "\n", \
+	pdata->dev->name, __func__, ## args)))
+
+#if USE_DEBUG >= 1
+#define SMSC_WARNING(nlevel, fmt, args...) \
+	DPRINTK(nlevel, WARNING, fmt, ## args)
+#else
+#define SMSC_WARNING(nlevel, fmt, args...) \
+	({ do {} while (0); 0; })
+#endif
+
+#if USE_DEBUG >= 2
+#define SMSC_TRACE(nlevel, fmt, args...) \
+	DPRINTK(nlevel, INFO, fmt, ## args)
+#else
+#define SMSC_TRACE(nlevel, fmt, args...) \
+	({ do {} while (0); 0; })
+#endif
+
+#ifdef CONFIG_DEBUG_SPINLOCK
+#define SMSC_ASSERT_MAC_LOCK(pdata) \
+		WARN_ON(!spin_is_locked(&pdata->mac_lock))
+#else
+#define SMSC_ASSERT_MAC_LOCK(pdata) do {} while (0)
+#endif				/* CONFIG_DEBUG_SPINLOCK */
+
+#define FLOW_CTRL_TX		(1)
+#define FLOW_CTRL_RX		(2)
+
+/* SMSC911x registers and bitfields */
+#define RX_DATA_FIFO			0x00
+
+#define TX_DATA_FIFO			0x20
+#define TX_CMD_A_ON_COMP_		0x80000000
+#define TX_CMD_A_BUF_END_ALGN_		0x03000000
+#define TX_CMD_A_4_BYTE_ALGN_		0x00000000
+#define TX_CMD_A_16_BYTE_ALGN_		0x01000000
+#define TX_CMD_A_32_BYTE_ALGN_		0x02000000
+#define TX_CMD_A_DATA_OFFSET_		0x001F0000
+#define TX_CMD_A_FIRST_SEG_		0x00002000
+#define TX_CMD_A_LAST_SEG_		0x00001000
+#define TX_CMD_A_BUF_SIZE_		0x000007FF
+#define TX_CMD_B_PKT_TAG_		0xFFFF0000
+#define TX_CMD_B_ADD_CRC_DISABLE_	0x00002000
+#define TX_CMD_B_DISABLE_PADDING_	0x00001000
+#define TX_CMD_B_PKT_BYTE_LENGTH_	0x000007FF
+
+#define RX_STATUS_FIFO			0x40
+#define RX_STS_ES_			0x00008000
+#define RX_STS_MCAST_			0x00000400
+
+#define RX_STATUS_FIFO_PEEK		0x44
+
+#define TX_STATUS_FIFO			0x48
+#define TX_STS_ES_			0x00008000
+
+#define TX_STATUS_FIFO_PEEK		0x4C
+
+#define ID_REV				0x50
+#define ID_REV_CHIP_ID_			0xFFFF0000
+#define ID_REV_REV_ID_			0x0000FFFF
+
+#define INT_CFG				0x54
+#define INT_CFG_INT_DEAS_		0xFF000000
+#define INT_CFG_INT_DEAS_CLR_		0x00004000
+#define INT_CFG_INT_DEAS_STS_		0x00002000
+#define INT_CFG_IRQ_INT_		0x00001000
+#define INT_CFG_IRQ_EN_			0x00000100
+#define INT_CFG_IRQ_POL_		0x00000010
+#define INT_CFG_IRQ_TYPE_		0x00000001
+
+#define INT_STS				0x58
+#define INT_STS_SW_INT_			0x80000000
+#define INT_STS_TXSTOP_INT_		0x02000000
+#define INT_STS_RXSTOP_INT_		0x01000000
+#define INT_STS_RXDFH_INT_		0x00800000
+#define INT_STS_RXDF_INT_		0x00400000
+#define INT_STS_TX_IOC_			0x00200000
+#define INT_STS_RXD_INT_		0x00100000
+#define INT_STS_GPT_INT_		0x00080000
+#define INT_STS_PHY_INT_		0x00040000
+#define INT_STS_PME_INT_		0x00020000
+#define INT_STS_TXSO_			0x00010000
+#define INT_STS_RWT_			0x00008000
+#define INT_STS_RXE_			0x00004000
+#define INT_STS_TXE_			0x00002000
+#define INT_STS_TDFU_			0x00000800
+#define INT_STS_TDFO_			0x00000400
+#define INT_STS_TDFA_			0x00000200
+#define INT_STS_TSFF_			0x00000100
+#define INT_STS_TSFL_			0x00000080
+#define INT_STS_RXDF_			0x00000040
+#define INT_STS_RDFL_			0x00000020
+#define INT_STS_RSFF_			0x00000010
+#define INT_STS_RSFL_			0x00000008
+#define INT_STS_GPIO2_INT_		0x00000004
+#define INT_STS_GPIO1_INT_		0x00000002
+#define INT_STS_GPIO0_INT_		0x00000001
+
+#define INT_EN				0x5C
+#define INT_EN_SW_INT_EN_		0x80000000
+#define INT_EN_TXSTOP_INT_EN_		0x02000000
+#define INT_EN_RXSTOP_INT_EN_		0x01000000
+#define INT_EN_RXDFH_INT_EN_		0x00800000
+#define INT_EN_TIOC_INT_EN_		0x00200000
+#define INT_EN_RXD_INT_EN_		0x00100000
+#define INT_EN_GPT_INT_EN_		0x00080000
+#define INT_EN_PHY_INT_EN_		0x00040000
+#define INT_EN_PME_INT_EN_		0x00020000
+#define INT_EN_TXSO_EN_			0x00010000
+#define INT_EN_RWT_EN_			0x00008000
+#define INT_EN_RXE_EN_			0x00004000
+#define INT_EN_TXE_EN_			0x00002000
+#define INT_EN_TDFU_EN_			0x00000800
+#define INT_EN_TDFO_EN_			0x00000400
+#define INT_EN_TDFA_EN_			0x00000200
+#define INT_EN_TSFF_EN_			0x00000100
+#define INT_EN_TSFL_EN_			0x00000080
+#define INT_EN_RXDF_EN_			0x00000040
+#define INT_EN_RDFL_EN_			0x00000020
+#define INT_EN_RSFF_EN_			0x00000010
+#define INT_EN_RSFL_EN_			0x00000008
+#define INT_EN_GPIO2_INT_		0x00000004
+#define INT_EN_GPIO1_INT_		0x00000002
+#define INT_EN_GPIO0_INT_		0x00000001
+
+#define BYTE_TEST			0x64
+
+#define FIFO_INT			0x68
+#define FIFO_INT_TX_AVAIL_LEVEL_	0xFF000000
+#define FIFO_INT_TX_STS_LEVEL_		0x00FF0000
+#define FIFO_INT_RX_AVAIL_LEVEL_	0x0000FF00
+#define FIFO_INT_RX_STS_LEVEL_		0x000000FF
+
+#define RX_CFG				0x6C
+#define RX_CFG_RX_END_ALGN_		0xC0000000
+#define RX_CFG_RX_END_ALGN4_		0x00000000
+#define RX_CFG_RX_END_ALGN16_		0x40000000
+#define RX_CFG_RX_END_ALGN32_		0x80000000
+#define RX_CFG_RX_DMA_CNT_		0x0FFF0000
+#define RX_CFG_RX_DUMP_			0x00008000
+#define RX_CFG_RXDOFF_			0x00001F00
+
+#define TX_CFG				0x70
+#define TX_CFG_TXS_DUMP_		0x00008000
+#define TX_CFG_TXD_DUMP_		0x00004000
+#define TX_CFG_TXSAO_			0x00000004
+#define TX_CFG_TX_ON_			0x00000002
+#define TX_CFG_STOP_TX_			0x00000001
+
+#define HW_CFG				0x74
+#define HW_CFG_TTM_			0x00200000
+#define HW_CFG_SF_			0x00100000
+#define HW_CFG_TX_FIF_SZ_		0x000F0000
+#define HW_CFG_TR_			0x00003000
+#define HW_CFG_SRST_			0x00000001
+
+/* only available on 115/117 */
+#define HW_CFG_PHY_CLK_SEL_		0x00000060
+#define HW_CFG_PHY_CLK_SEL_INT_PHY_	0x00000000
+#define HW_CFG_PHY_CLK_SEL_EXT_PHY_	0x00000020
+#define HW_CFG_PHY_CLK_SEL_CLK_DIS_	0x00000040
+#define HW_CFG_SMI_SEL_		 	0x00000010
+#define HW_CFG_EXT_PHY_DET_		0x00000008
+#define HW_CFG_EXT_PHY_EN_		0x00000004
+#define HW_CFG_SRST_TO_			0x00000002
+
+/* only available  on 116/118 */
+#define HW_CFG_32_16_BIT_MODE_		0x00000004
+
+#define RX_DP_CTRL			0x78
+#define RX_DP_CTRL_RX_FFWD_		0x80000000
+
+#define RX_FIFO_INF			0x7C
+#define RX_FIFO_INF_RXSUSED_		0x00FF0000
+#define RX_FIFO_INF_RXDUSED_		0x0000FFFF
+
+#define TX_FIFO_INF			0x80
+#define TX_FIFO_INF_TSUSED_		0x00FF0000
+#define TX_FIFO_INF_TDFREE_		0x0000FFFF
+
+#define PMT_CTRL			0x84
+#define PMT_CTRL_PM_MODE_		0x00003000
+#define PMT_CTRL_PM_MODE_D0_		0x00000000
+#define PMT_CTRL_PM_MODE_D1_		0x00001000
+#define PMT_CTRL_PM_MODE_D2_		0x00002000
+#define PMT_CTRL_PM_MODE_D3_		0x00003000
+#define PMT_CTRL_PHY_RST_		0x00000400
+#define PMT_CTRL_WOL_EN_		0x00000200
+#define PMT_CTRL_ED_EN_			0x00000100
+#define PMT_CTRL_PME_TYPE_		0x00000040
+#define PMT_CTRL_WUPS_			0x00000030
+#define PMT_CTRL_WUPS_NOWAKE_		0x00000000
+#define PMT_CTRL_WUPS_ED_		0x00000010
+#define PMT_CTRL_WUPS_WOL_		0x00000020
+#define PMT_CTRL_WUPS_MULTI_		0x00000030
+#define PMT_CTRL_PME_IND_		0x00000008
+#define PMT_CTRL_PME_POL_		0x00000004
+#define PMT_CTRL_PME_EN_		0x00000002
+#define PMT_CTRL_READY_			0x00000001
+
+#define GPIO_CFG			0x88
+#define GPIO_CFG_LED3_EN_		0x40000000
+#define GPIO_CFG_LED2_EN_		0x20000000
+#define GPIO_CFG_LED1_EN_		0x10000000
+#define GPIO_CFG_GPIO2_INT_POL_		0x04000000
+#define GPIO_CFG_GPIO1_INT_POL_		0x02000000
+#define GPIO_CFG_GPIO0_INT_POL_		0x01000000
+#define GPIO_CFG_EEPR_EN_		0x00700000
+#define GPIO_CFG_GPIOBUF2_		0x00040000
+#define GPIO_CFG_GPIOBUF1_		0x00020000
+#define GPIO_CFG_GPIOBUF0_		0x00010000
+#define GPIO_CFG_GPIODIR2_		0x00000400
+#define GPIO_CFG_GPIODIR1_		0x00000200
+#define GPIO_CFG_GPIODIR0_		0x00000100
+#define GPIO_CFG_GPIOD4_		0x00000020
+#define GPIO_CFG_GPIOD3_		0x00000010
+#define GPIO_CFG_GPIOD2_		0x00000004
+#define GPIO_CFG_GPIOD1_		0x00000002
+#define GPIO_CFG_GPIOD0_		0x00000001
+
+#define GPT_CFG				0x8C
+#define GPT_CFG_TIMER_EN_		0x20000000
+#define GPT_CFG_GPT_LOAD_		0x0000FFFF
+
+#define GPT_CNT				0x90
+#define GPT_CNT_GPT_CNT_		0x0000FFFF
+
+#define WORD_SWAP			0x98
+
+#define FREE_RUN			0x9C
+
+#define RX_DROP				0xA0
+
+#define MAC_CSR_CMD			0xA4
+#define MAC_CSR_CMD_CSR_BUSY_		0x80000000
+#define MAC_CSR_CMD_R_NOT_W_		0x40000000
+#define MAC_CSR_CMD_CSR_ADDR_		0x000000FF
+
+#define MAC_CSR_DATA			0xA8
+
+#define AFC_CFG				0xAC
+#define AFC_CFG_AFC_HI_			0x00FF0000
+#define AFC_CFG_AFC_LO_			0x0000FF00
+#define AFC_CFG_BACK_DUR_		0x000000F0
+#define AFC_CFG_FCMULT_			0x00000008
+#define AFC_CFG_FCBRD_			0x00000004
+#define AFC_CFG_FCADD_			0x00000002
+#define AFC_CFG_FCANY_			0x00000001
+
+#define E2P_CMD				0xB0
+#define E2P_CMD_EPC_BUSY_		0x80000000
+#define E2P_CMD_EPC_CMD_		0x70000000
+#define E2P_CMD_EPC_CMD_READ_		0x00000000
+#define E2P_CMD_EPC_CMD_EWDS_		0x10000000
+#define E2P_CMD_EPC_CMD_EWEN_		0x20000000
+#define E2P_CMD_EPC_CMD_WRITE_		0x30000000
+#define E2P_CMD_EPC_CMD_WRAL_		0x40000000
+#define E2P_CMD_EPC_CMD_ERASE_		0x50000000
+#define E2P_CMD_EPC_CMD_ERAL_		0x60000000
+#define E2P_CMD_EPC_CMD_RELOAD_		0x70000000
+#define E2P_CMD_EPC_TIMEOUT_		0x00000200
+#define E2P_CMD_MAC_ADDR_LOADED_	0x00000100
+#define E2P_CMD_EPC_ADDR_		0x000000FF
+
+#define E2P_DATA			0xB4
+#define E2P_DATA_EEPROM_DATA_		0x000000FF
+#define LAN_REGISTER_EXTENT		0x00000100
+
+/*
+ * MAC Control and Status Register (Indirect Address)
+ * Offset (through the MAC_CSR CMD and DATA port)
+ */
+#define MAC_CR				0x01
+#define MAC_CR_RXALL_			0x80000000
+#define MAC_CR_HBDIS_			0x10000000
+#define MAC_CR_RCVOWN_			0x00800000
+#define MAC_CR_LOOPBK_			0x00200000
+#define MAC_CR_FDPX_			0x00100000
+#define MAC_CR_MCPAS_			0x00080000
+#define MAC_CR_PRMS_			0x00040000
+#define MAC_CR_INVFILT_			0x00020000
+#define MAC_CR_PASSBAD_			0x00010000
+#define MAC_CR_HFILT_			0x00008000
+#define MAC_CR_HPFILT_			0x00002000
+#define MAC_CR_LCOLL_			0x00001000
+#define MAC_CR_BCAST_			0x00000800
+#define MAC_CR_DISRTY_			0x00000400
+#define MAC_CR_PADSTR_			0x00000100
+#define MAC_CR_BOLMT_MASK_		0x000000C0
+#define MAC_CR_DFCHK_			0x00000020
+#define MAC_CR_TXEN_			0x00000008
+#define MAC_CR_RXEN_			0x00000004
+
+#define ADDRH				0x02
+
+#define ADDRL				0x03
+
+#define HASHH				0x04
+
+#define HASHL				0x05
+
+#define MII_ACC				0x06
+#define MII_ACC_PHY_ADDR_		0x0000F800
+#define MII_ACC_MIIRINDA_		0x000007C0
+#define MII_ACC_MII_WRITE_		0x00000002
+#define MII_ACC_MII_BUSY_		0x00000001
+
+#define MII_DATA			0x07
+
+#define FLOW				0x08
+#define FLOW_FCPT_			0xFFFF0000
+#define FLOW_FCPASS_			0x00000004
+#define FLOW_FCEN_			0x00000002
+#define FLOW_FCBSY_			0x00000001
+
+#define VLAN1				0x09
+
+#define VLAN2				0x0A
+
+#define WUFF				0x0B
+
+#define WUCSR				0x0C
+#define WUCSR_GUE_			0x00000200
+#define WUCSR_WUFR_			0x00000040
+#define WUCSR_MPR_			0x00000020
+#define WUCSR_WAKE_EN_			0x00000004
+#define WUCSR_MPEN_			0x00000002
+
+/*
+ * Phy definitions (vendor-specific)
+ */
+#define LAN9118_PHY_ID			0x00C0001C
+
+#define MII_INTSTS			0x1D
+
+#define MII_INTMSK			0x1E
+#define PHY_INTMSK_AN_RCV_		(1 << 1)
+#define PHY_INTMSK_PDFAULT_		(1 << 2)
+#define PHY_INTMSK_AN_ACK_		(1 << 3)
+#define PHY_INTMSK_LNKDOWN_		(1 << 4)
+#define PHY_INTMSK_RFAULT_		(1 << 5)
+#define PHY_INTMSK_AN_COMP_		(1 << 6)
+#define PHY_INTMSK_ENERGYON_		(1 << 7)
+#define PHY_INTMSK_DEFAULT_		(PHY_INTMSK_ENERGYON_ | \
+					 PHY_INTMSK_AN_COMP_ | \
+					 PHY_INTMSK_RFAULT_ | \
+					 PHY_INTMSK_LNKDOWN_)
+
+#define ADVERTISE_PAUSE_ALL		(ADVERTISE_PAUSE_CAP | \
+					 ADVERTISE_PAUSE_ASYM)
+
+#define LPA_PAUSE_ALL			(LPA_PAUSE_CAP | \
+					 LPA_PAUSE_ASYM)
+
+#endif				/* __SMSC911X_H__ */
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index aa31490..cbed34b 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -87,6 +87,8 @@ static int msg_level = -1;
 module_param (msg_level, int, 0);
 MODULE_PARM_DESC (msg_level, "Override default message level");
 
+static void waker(struct work_struct *work);
+
 /*-------------------------------------------------------------------------*/
 
 /* handles CDC Ethernet and many other network "bulk data" interfaces */
@@ -325,6 +327,7 @@ static void rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 	if (netif_running (dev->net)
 			&& netif_device_present (dev->net)
 			&& !test_bit (EVENT_RX_HALT, &dev->flags)) {
+		usb_mark_last_busy(dev->udev);
 		switch (retval = usb_submit_urb (urb, GFP_ATOMIC)) {
 		case -EPIPE:
 			usbnet_defer_kevent (dev, EVENT_RX_HALT);
@@ -496,6 +499,7 @@ static void intr_complete (struct urb *urb)
 		return;
 
 	memset(urb->transfer_buffer, 0, urb->transfer_buffer_length);
+	usb_mark_last_busy(dev->udev);
 	status = usb_submit_urb (urb, GFP_ATOMIC);
 	if (status != 0 && netif_msg_timer (dev))
 		deverr(dev, "intr resubmit --> %d", status);
@@ -588,6 +592,10 @@ static int usbnet_stop (struct net_device *net)
 	dev->flags = 0;
 	del_timer_sync (&dev->delay);
 	tasklet_kill (&dev->bh);
+
+	dev->used--;
+
+	dev->intf->needs_remote_wakeup = 0;
 	usb_autopm_put_interface(dev->intf);
 
 	return 0;
@@ -668,6 +676,11 @@ static int usbnet_open (struct net_device *net)
 
 	// delay posting reads until we're fully open
 	tasklet_schedule (&dev->bh);
+
+	dev->used++;
+
+	dev->intf->needs_remote_wakeup = 1;
+	usb_autopm_put_interface(dev->intf);
 	return retval;
 done:
 	usb_autopm_put_interface(dev->intf);
@@ -920,7 +933,7 @@ static void usbnet_tx_timeout (struct net_device *net)
 
 /*-------------------------------------------------------------------------*/
 
-static int usbnet_start_xmit (struct sk_buff *skb, struct net_device *net)
+static int __usbnet_start_xmit (struct sk_buff *skb, struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
 	int			length;
@@ -954,6 +967,7 @@ static int usbnet_start_xmit (struct sk_buff *skb, struct net_device *net)
 	entry->state = tx_start;
 	entry->length = length;
 
+	dev->tx_goingon = 1;
 	usb_fill_bulk_urb (urb, dev->udev, dev->out,
 			skb->data, skb->len, tx_complete, skb);
 
@@ -971,6 +985,7 @@ static int usbnet_start_xmit (struct sk_buff *skb, struct net_device *net)
 
 	spin_lock_irqsave (&dev->txq.lock, flags);
 
+	usb_mark_last_busy(dev->udev);
 	switch ((retval = usb_submit_urb (urb, GFP_ATOMIC))) {
 	case -EPIPE:
 		netif_stop_queue (net);
@@ -1004,6 +1019,28 @@ drop:
 	return retval;
 }
 
+static int usbnet_start_xmit(struct sk_buff *skb, struct net_device *net)
+{
+	struct usbnet		*dev = netdev_priv(net);
+	int			retval;
+	unsigned long		flags;
+
+	spin_lock_irqsave(&dev->txq.lock, flags);
+	if (dev->suspend_count) {
+		netif_stop_queue(net);
+		dev->tx_skb = skb;
+		if (!schedule_work (&dev->waker))
+			deverr(dev, "waker may have been dropped");
+		else
+			devdbg(dev, "waker scheduled");
+		spin_unlock_irqrestore(&dev->txq.lock, flags);
+		return NET_XMIT_SUCCESS;
+	}
+	spin_unlock_irqrestore(&dev->txq.lock, flags);
+
+	retval = __usbnet_start_xmit(skb, net);
+	return retval;
+}
 
 /*-------------------------------------------------------------------------*/
 
@@ -1023,6 +1060,8 @@ static void usbnet_bh (unsigned long param)
 			rx_process (dev, skb);
 			continue;
 		case tx_done:
+			dev->tx_goingon = 0;
+			/* fall through */
 		case rx_cleanup:
 			usb_free_urb (entry->urb);
 			dev_kfree_skb (skb);
@@ -1042,6 +1081,7 @@ static void usbnet_bh (unsigned long param)
 	} else if (netif_running (dev->net)
 			&& netif_device_present (dev->net)
 			&& !timer_pending (&dev->delay)
+			&& !dev->suspend_count
 			&& !test_bit (EVENT_RX_HALT, &dev->flags)) {
 		int	temp = dev->rxq.qlen;
 		int	qlen = RX_QLEN (dev);
@@ -1159,6 +1199,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	dev->bh.func = usbnet_bh;
 	dev->bh.data = (unsigned long) dev;
 	INIT_WORK (&dev->kevent, kevent);
+	INIT_WORK (&dev->waker, waker);
 	dev->delay.function = usbnet_bh;
 	dev->delay.data = (unsigned long) dev;
 	init_timer (&dev->delay);
@@ -1267,24 +1308,66 @@ EXPORT_SYMBOL_GPL(usbnet_probe);
  * resume only when the last interface is resumed
  */
 
+static void waker(struct work_struct *work)
+{
+	struct usbnet *dev = container_of(work, struct usbnet, waker);
+
+	if (!usb_autopm_get_interface(dev->intf)) {
+		usb_autopm_put_interface(dev->intf);
+	} else {
+		devdbg(dev, "autoresume failed");
+	}
+}
+
+static void stop_traffic(struct usbnet *dev)
+{
+	int temp;
+	DECLARE_WAIT_QUEUE_HEAD_ONSTACK (unlink_wakeup);
+	DECLARE_WAITQUEUE (wait, current);
+
+	/* ensure there are no more active urbs */
+	add_wait_queue (&unlink_wakeup, &wait);
+	dev->wait = &unlink_wakeup;
+	temp = unlink_urbs (dev, &dev->txq) + unlink_urbs (dev, &dev->rxq);
+
+	/* maybe wait for deletions to finish. */
+	while (!skb_queue_empty(&dev->rxq)
+			&& !skb_queue_empty(&dev->txq)
+			&& !skb_queue_empty(&dev->done)) {
+		msleep(UNLINK_TIMEOUT_MS);
+		if (netif_msg_ifdown (dev))
+			devdbg (dev, "waited for %d urb completions", temp);
+	}
+	dev->wait = NULL;
+	remove_wait_queue (&unlink_wakeup, &wait);
+
+	usb_kill_urb(dev->interrupt);
+}
+
 int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
 {
-	struct usbnet		*dev = usb_get_intfdata(intf);
+	struct usbnet *dev = usb_get_intfdata(intf);
 
-	if (!dev->suspend_count++) {
-		/*
-		 * accelerate emptying of the rx and queues, to avoid
-		 * having everything error out.
-		 */
-		netif_device_detach (dev->net);
-		(void) unlink_urbs (dev, &dev->rxq);
-		(void) unlink_urbs (dev, &dev->txq);
-		/*
-		 * reattach so runtime management can use and
-		 * wake the device
-		 */
-		netif_device_attach (dev->net);
+	devdbg(dev, "%s: begin", __FUNCTION__);
+
+	if (dev->suspend_count++)
+		return 0;
+
+	/* check for ongoing tx traffic */
+	if (dev->tx_goingon && dev->udev->auto_pm) {
+		dev->suspend_count--;
+		return -EBUSY;
 	}
+
+	stop_traffic(dev);
+
+	/* cancel work */
+	dev->flags = 0;
+	del_timer_sync(&dev->delay);
+	cancel_work_sync(&dev->kevent);
+
+	devdbg(dev, "%s: end", __FUNCTION__);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(usbnet_suspend);
@@ -1292,9 +1375,32 @@ EXPORT_SYMBOL_GPL(usbnet_suspend);
 int usbnet_resume (struct usb_interface *intf)
 {
 	struct usbnet		*dev = usb_get_intfdata(intf);
+	int                     status;
+
+	devdbg(dev, "%s: begin", __FUNCTION__);
+
+	if (--dev->suspend_count)
+		return 0;
+
+	status = init_status (dev, dev->intf);
+	if (dev->interrupt) {
+		status = usb_submit_urb (dev->interrupt, GFP_KERNEL);
+		if (status < 0) {
+			devdbg(dev, "failed restarting interrupt urb");
+		}
+	}
+
+	tasklet_schedule(&dev->bh);
+
+	/* transmit package that triggered resume */
+	if (dev->tx_skb) {
+		status = __usbnet_start_xmit(dev->tx_skb, dev->net);
+		dev->tx_skb = NULL;
+	}
+
+	netif_wake_queue(dev->net);
 
-	if (!--dev->suspend_count)
-		tasklet_schedule (&dev->bh);
+	devdbg(dev, "%s: end", __FUNCTION__);
 
 	return 0;
 }
diff --git a/include/linux/smsc911x.h b/include/linux/smsc911x.h
new file mode 100644
index 0000000..47c4ffd
--- /dev/null
+++ b/include/linux/smsc911x.h
@@ -0,0 +1,42 @@
+/***************************************************************************
+ *
+ * Copyright (C) 2004-2008 SMSC
+ * Copyright (C) 2005-2008 ARM
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ ***************************************************************************/
+#ifndef __LINUX_SMSC911X_H__
+#define __LINUX_SMSC911X_H__
+
+#include <linux/phy.h>
+
+/* platform_device configuration data, should be assigned to
+ * the platform_device's dev.platform_data */
+struct smsc911x_platform_config {
+	unsigned int irq_polarity;
+	unsigned int irq_type;
+	phy_interface_t phy_interface;
+};
+
+/* Constants for platform_device irq polarity configuration */
+#define SMSC911X_IRQ_POLARITY_ACTIVE_LOW	0
+#define SMSC911X_IRQ_POLARITY_ACTIVE_HIGH	1
+
+/* Constants for platform_device irq type configuration */
+#define SMSC911X_IRQ_TYPE_OPEN_DRAIN		0
+#define SMSC911X_IRQ_TYPE_PUSH_PULL		1
+
+#endif /* __LINUX_SMSC911X_H__ */
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index ba09fe8..ec3a85e 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -64,6 +64,12 @@ struct usbnet {
 #		define EVENT_RX_MEMORY	2
 #		define EVENT_STS_SPLIT	3
 #		define EVENT_LINK_RESET	4
+
+	/* autosuspend helpers */
+	struct work_struct	waker;
+	int                     used;
+	int                     tx_goingon;
+	struct sk_buff		*tx_skb; /* skb queued during suspend */
 };
 
 static inline struct usb_driver *driver_of(struct usb_interface *intf)
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 11dd013..ce532f2 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -108,6 +108,20 @@ extern void			ndisc_send_redirect(struct sk_buff *skb,
 
 extern int			ndisc_mc_map(struct in6_addr *addr, char *buf, struct net_device *dev, int dir);
 
+extern struct sk_buff		*ndisc_build_skb(struct net_device *dev,
+						 const struct in6_addr *daddr,
+						 const struct in6_addr *saddr,
+						 struct icmp6hdr *icmp6h,
+						 const struct in6_addr *target,
+						 int llinfo);
+
+extern void			ndisc_send_skb(struct sk_buff *skb,
+					       struct net_device *dev,
+					       struct neighbour *neigh,
+					       const struct in6_addr *daddr,
+					       const struct in6_addr *saddr,
+					       struct icmp6hdr *icmp6h);
+
 
 
 /*
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 2a6752d..fbf451c 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -437,38 +437,20 @@ static void pndisc_destructor(struct pneigh_entry *n)
 	ipv6_dev_mc_dec(dev, &maddr);
 }
 
-/*
- *	Send a Neighbour Advertisement
- */
-static void __ndisc_send(struct net_device *dev,
-			 struct neighbour *neigh,
-			 const struct in6_addr *daddr,
-			 const struct in6_addr *saddr,
-			 struct icmp6hdr *icmp6h, const struct in6_addr *target,
-			 int llinfo)
+struct sk_buff *ndisc_build_skb(struct net_device *dev,
+				const struct in6_addr *daddr,
+				const struct in6_addr *saddr,
+				struct icmp6hdr *icmp6h,
+				const struct in6_addr *target,
+				int llinfo)
 {
-	struct flowi fl;
-	struct dst_entry *dst;
 	struct net *net = dev_net(dev);
 	struct sock *sk = net->ipv6.ndisc_sk;
 	struct sk_buff *skb;
 	struct icmp6hdr *hdr;
-	struct inet6_dev *idev;
 	int len;
 	int err;
-	u8 *opt, type;
-
-	type = icmp6h->icmp6_type;
-
-	icmpv6_flow_init(sk, &fl, type, saddr, daddr, dev->ifindex);
-
-	dst = icmp6_dst_alloc(dev, neigh, daddr);
-	if (!dst)
-		return;
-
-	err = xfrm_lookup(&dst, &fl, NULL, 0);
-	if (err < 0)
-		return;
+	u8 *opt;
 
 	if (!dev->addr_len)
 		llinfo = 0;
@@ -485,8 +467,7 @@ static void __ndisc_send(struct net_device *dev,
 		ND_PRINTK0(KERN_ERR
 			   "ICMPv6 ND: %s() failed to allocate an skb.\n",
 			   __func__);
-		dst_release(dst);
-		return;
+		return NULL;
 	}
 
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
@@ -513,6 +494,42 @@ static void __ndisc_send(struct net_device *dev,
 					   csum_partial((__u8 *) hdr,
 							len, 0));
 
+	return skb;
+}
+
+EXPORT_SYMBOL(ndisc_build_skb);
+
+void ndisc_send_skb(struct sk_buff *skb,
+		    struct net_device *dev,
+		    struct neighbour *neigh,
+		    const struct in6_addr *daddr,
+		    const struct in6_addr *saddr,
+		    struct icmp6hdr *icmp6h)
+{
+	struct flowi fl;
+	struct dst_entry *dst;
+	struct net *net = dev_net(dev);
+	struct sock *sk = net->ipv6.ndisc_sk;
+	struct inet6_dev *idev;
+	int err;
+	u8 type;
+
+	type = icmp6h->icmp6_type;
+
+	icmpv6_flow_init(sk, &fl, type, saddr, daddr, dev->ifindex);
+
+	dst = icmp6_dst_alloc(dev, neigh, daddr);
+	if (!dst) {
+		kfree_skb(skb);
+		return;
+	}
+
+	err = xfrm_lookup(&dst, &fl, NULL, 0);
+	if (err < 0) {
+		kfree_skb(skb);
+		return;
+	}
+
 	skb->dst = dst;
 
 	idev = in6_dev_get(dst->dev);
@@ -529,6 +546,27 @@ static void __ndisc_send(struct net_device *dev,
 		in6_dev_put(idev);
 }
 
+EXPORT_SYMBOL(ndisc_send_skb);
+
+/*
+ *	Send a Neighbour Discover packet
+ */
+static void __ndisc_send(struct net_device *dev,
+			 struct neighbour *neigh,
+			 const struct in6_addr *daddr,
+			 const struct in6_addr *saddr,
+			 struct icmp6hdr *icmp6h, const struct in6_addr *target,
+			 int llinfo)
+{
+	struct sk_buff *skb;
+
+	skb = ndisc_build_skb(dev, daddr, saddr, icmp6h, target, llinfo);
+	if (!skb)
+		return;
+
+	ndisc_send_skb(skb, dev, neigh, daddr, saddr, icmp6h);
+}
+
 static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 			  const struct in6_addr *daddr,
 			  const struct in6_addr *solicited_addr,
