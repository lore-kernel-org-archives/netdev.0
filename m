From: Shmulik Hen <hshmulik@intel.com>
Subject: [patch] (8/8) Add 802.3ad support to bonding
Date: Thu, 20 Mar 2003 17:18:23 +0200 (IST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0303201659160.10351-100000@jrslxjul4.npdj.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: Bonding Developement list <bonding-devel@lists.sourceforge.net>,
   Bonding Announce list <bonding-announce@lists.sourceforge.net>,
   Linux Net Mailing list <linux-net@vger.kernel.org>,
   Linux Kernel Mailing list <linux-kernel@vger.kernel.org>,
   Oss SGI Netdev list <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch adds the actual code that does the IEEE 802.3ad dynamic link=20
aggregation stuff. This mode offers the following advantages:
automatic configuration, rapid configuration and reconfiguration, and=20
deterministic behavior. It forms aggregation groups that include only=20
members with full duplex and the same speed, and all adapters in the=20
active aggregator simultaneously receive and transmit data.

This patch is against bonding 2.4.20-20030317.

diff -Nuarp linux-2.4.20-bonding-20030317/Documentation/networking/bondin=
g.txt linux-2.4.20-bonding-20030317-devel/Documentation/networking/bondin=
g.txt
--- linux-2.4.20-bonding-20030317/Documentation/networking/bonding.txt	20=
03-03-18 17:24:24.000000000 +0200
+++ linux-2.4.20-bonding-20030317-devel/Documentation/networking/bonding.=
txt	2003-03-18 17:24:25.000000000 +0200
@@ -237,6 +237,11 @@ text or numeric option):
 		Broadcast policy: transmits everything on all slave
 		interfaces. This mode provides fault tolerance.
=20
+    802.3ad or 4
+        IEEE 802.3ad Dynamic link aggregation. Creates aggregation
+        groups that share the same speed and duplex settings.
+        Transmits and receives on all slaves in the active aggregator.
+
 miimon
 =20
         Specifies the frequency in milli-seconds that MII link monitorin=
g will=20
@@ -412,7 +417,7 @@ Switch Configuration
=20
 While the switch does not need to be configured when the active-backup
 policy is used (mode=3D1), it does need to be configured for the round-r=
obin,=20
-XOR, and broadcast policies (mode=3D0, mode=3D2, and mode=3D3).=20
+XOR, broadcast, and 802.3ad policies (mode=3D0, mode=3D2, mode=3D3, and =
mode=3D4).
=20
=20
 Verifying Bond Configuration
@@ -445,7 +450,7 @@ parameters of mode=3D0 and miimon=3D1000 is=20
 The network configuration can be verified using the ifconfig command. In
 the example below, the bond0 interface is the master (MASTER) while eth0=
 and=20
 eth1 are slaves (SLAVE). Notice all slaves of bond0 have the same MAC ad=
dress=20
-(HWaddr) as bond0.
+(HWaddr) as bond0 (except for 802.3ad mode).
=20
 [root]# /sbin/ifconfig
 bond0     Link encap:Ethernet  HWaddr 00:C0:F0:1F:37:B4 =20
@@ -538,6 +543,13 @@ Frequently Asked Questions
 	  units.
 	* Linux bonding, of course !
 =09
+	In 802.3ad mode, it works with with systems that support IEEE 802.3ad
+	Dynamic Link Aggregation:
+
+	* Extreme networks Summit 7i (look for link-aggregation).
+	* Cisco 6500 series (look for lacp).
+	* Foundry Big Iron 4000
+
 	In active-backup mode, it should work with any Layer-II switche.
=20
=20
@@ -591,6 +603,9 @@ Frequently Asked Questions
=20
 	Broadcast policy transmits everything on all slave interfaces.
=20
+	802.3ad, based on XOR but distributes traffic among all interfaces
+	in the active aggregator.
+
=20
 High Availability
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
diff -Nuarp linux-2.4.20-bonding-20030317/drivers/net/bonding/bond_3ad.c =
linux-2.4.20-bonding-20030317-devel/drivers/net/bonding/bond_3ad.c
--- linux-2.4.20-bonding-20030317/drivers/net/bonding/bond_3ad.c	1970-01-=
01 02:00:00.000000000 +0200
+++ linux-2.4.20-bonding-20030317-devel/drivers/net/bonding/bond_3ad.c	20=
03-03-18 17:24:25.000000000 +0200
@@ -0,0 +1,2454 @@
+/***********************************************************************=
*****
+   Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
+
+   This program is free software; you can redistribute it and/or modify =
it
+   under the terms of the GNU General Public License as published by the=
 Free
+   Software Foundation; either version 2 of the License, or (at your opt=
ion)
+   any later version.
+
+   This program is distributed in the hope that it will be useful, but W=
ITHOUT
+   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License=
 for
+   more details.
+
+   You should have received a copy of the GNU General Public License alo=
ng with
+   this program; if not, write to the Free Software Foundation, Inc., 59
+   Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+
+   The full GNU General Public License is included in this distribution =
in the
+   file called LICENSE.
+************************************************************************=
*****/
+
+#include <linux/skbuff.h>
+#include <linux/if_ether.h>
+#include <linux/netdevice.h>
+#include <linux/spinlock.h>
+#include <linux/ethtool.h>
+#include <linux/if_bonding.h>
+#include "bonding.h"
+#include "bond_3ad.h"
+
+// General definitions
+#define AD_SHORT_TIMEOUT           1
+#define AD_LONG_TIMEOUT            0
+#define AD_STANDBY                 0x2
+#define AD_MAX_TX_IN_SECOND        3
+#define AD_COLLECTOR_MAX_DELAY     0
+
+// Timer definitions(43.4.4 in the 802.3ad standard)
+#define AD_FAST_PERIODIC_TIME      1
+#define AD_SLOW_PERIODIC_TIME      30
+#define AD_SHORT_TIMEOUT_TIME      (3*AD_FAST_PERIODIC_TIME)
+#define AD_LONG_TIMEOUT_TIME       (3*AD_SLOW_PERIODIC_TIME)
+#define AD_CHURN_DETECTION_TIME    60
+#define AD_AGGREGATE_WAIT_TIME     2
+
+// Port state definitions(43.4.2.2 in the 802.3ad standard)
+#define AD_STATE_LACP_ACTIVITY   0x1
+#define AD_STATE_LACP_TIMEOUT    0x2
+#define AD_STATE_AGGREGATION     0x4
+#define AD_STATE_SYNCHRONIZATION 0x8
+#define AD_STATE_COLLECTING      0x10
+#define AD_STATE_DISTRIBUTING    0x20
+#define AD_STATE_DEFAULTED       0x40
+#define AD_STATE_EXPIRED         0x80
+
+// Port Variables definitions used by the State Machines(43.4.7 in the 8=
02.3ad standard)
+#define AD_PORT_BEGIN           0x1
+#define AD_PORT_LACP_ENABLED    0x2
+#define AD_PORT_ACTOR_CHURN     0x4
+#define AD_PORT_PARTNER_CHURN   0x8
+#define AD_PORT_READY           0x10
+#define AD_PORT_READY_N         0x20
+#define AD_PORT_MATCHED         0x40
+#define AD_PORT_STANDBY         0x80
+#define AD_PORT_SELECTED        0x100
+#define AD_PORT_MOVED           0x200
+
+// Port Key definitions
+// key is determined according to the link speed, duplex and
+// user key(which is yet not supported)
+//              --------------------------------------------------------=
----
+// Port key :   | User key                       |      Speed       |Dup=
lex|
+//              --------------------------------------------------------=
----
+//              16                               6               1 0
+#define  AD_DUPLEX_KEY_BITS    0x1
+#define  AD_SPEED_KEY_BITS     0x3E
+#define  AD_USER_KEY_BITS      0xFFC0
+
+//dalloun
+#define     AD_LINK_SPEED_BITMASK_1MBPS       0x1
+#define     AD_LINK_SPEED_BITMASK_10MBPS      0x2
+#define     AD_LINK_SPEED_BITMASK_100MBPS     0x4
+#define     AD_LINK_SPEED_BITMASK_1000MBPS    0x8
+//endalloun
+
+// compare MAC addresses
+#define MAC_ADDRESS_COMPARE(A, B) memcmp(A, B, ETH_ALEN)
+
+static struct mac_addr null_mac_addr =3D {{0, 0, 0, 0, 0, 0}};
+static u16 ad_ticks_per_sec;
+
+// =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D 3AD api to bondin=
g and kernel code =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+static u16 __get_link_speed(struct port *port);
+static u8 __get_duplex(struct port *port);
+static inline void __initialize_port_locks(struct port *port);
+static inline void __deinitialize_port_locks(struct port *port);
+//conversions
+static void __ntohs_lacpdu(struct lacpdu *lacpdu);
+static u16 __ad_timer_to_ticks(u16 timer_type, u16 Par);
+
+
+// =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D ad code helper fu=
nctions =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+//needed by ad_rx_machine(...)
+static void __record_pdu(struct lacpdu *lacpdu, struct port *port);
+static void __record_default(struct port *port);
+static void __update_selected(struct lacpdu *lacpdu, struct port *port);
+static void __update_default_selected(struct port *port);
+static void __choose_matched(struct lacpdu *lacpdu, struct port *port);
+static void __update_ntt(struct lacpdu *lacpdu, struct port *port);
+
+//needed for ad_mux_machine(..)
+static void __attach_bond_to_agg(struct port *port);
+static void __detach_bond_from_agg(struct port *port);
+static int __agg_ports_are_ready(struct aggregator *aggregator);
+static void __set_agg_ports_ready(struct aggregator *aggregator, int val=
);
+
+//needed for ad_agg_selection_logic(...)
+static u32 __get_agg_bandwidth(struct aggregator *aggregator);
+static struct aggregator *__get_active_agg(struct aggregator *aggregator=
);
+
+
+// =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D main 802.3ad prot=
ocol functions =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+static int ad_lacpdu_send(struct port *port);
+static int ad_marker_send(struct port *port, struct marker *marker);
+static void ad_mux_machine(struct port *port);
+static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port);
+static void ad_tx_machine(struct port *port);
+static void ad_periodic_machine(struct port *port);
+static void ad_port_selection_logic(struct port *port);
+static void ad_agg_selection_logic(struct aggregator *aggregator);
+static void ad_clear_agg(struct aggregator *aggregator);
+static void ad_initialize_agg(struct aggregator *aggregator);
+static void ad_initialize_port(struct port *port);
+static void ad_initialize_lacpdu(struct lacpdu *Lacpdu);
+static void ad_enable_collecting_distributing(struct port *port);
+static void ad_disable_collecting_distributing(struct port *port);
+static void ad_marker_info_received(struct marker *marker_info, struct p=
ort *port);
+static void ad_marker_response_received(struct marker *marker, struct po=
rt *port);
+
+
+////////////////////////////////////////////////////////////////////////=
/////////
+// =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D api to bonding an=
d kernel code =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+////////////////////////////////////////////////////////////////////////=
/////////
+
+/**
+ * __get_bond_by_port - get the port's bonding struct
+ * @port: the port we're looking at
+ *
+ * Return @port's bonding struct, or %NULL if it can't be found.
+ */
+static inline struct bonding *__get_bond_by_port(struct port *port)
+{
+	if (port->slave =3D=3D NULL) {
+		return NULL;
+	}
+
+	return bond_get_bond_by_slave(port->slave);
+}
+
+/**
+ * __get_first_port - get the first port in the bond
+ * @bond: the bond we're looking at
+ *
+ * Return the port of the first slave in @bond, or %NULL if it can't be =
found.
+ */
+static inline struct port *__get_first_port(struct bonding *bond)
+{
+	struct slave *slave =3D bond->next;
+
+	if (slave =3D=3D (struct slave *)bond) {
+		return NULL;
+	}
+
+	return &(SLAVE_AD_INFO(slave).port);
+}
+
+/**
+ * __get_next_port - get the next port in the bond
+ * @port: the port we're looking at
+ *
+ * Return the port of the slave that is next in line of @port's slave in=
 the
+ * bond, or %NULL if it can't be found.
+ */
+static inline struct port *__get_next_port(struct port *port)
+{
+	struct bonding *bond =3D __get_bond_by_port(port);
+	struct slave *slave =3D port->slave;
+
+	// If there's no bond for this port, or this is the last slave
+	if ((bond =3D=3D NULL) || (slave->next =3D=3D bond->next)) {
+		return NULL;
+	}
+
+	return &(SLAVE_AD_INFO(slave->next).port);
+}
+
+/**
+ * __get_first_agg - get the first aggregator in the bond
+ * @bond: the bond we're looking at
+ *
+ * Return the aggregator of the first slave in @bond, or %NULL if it can=
't be
+ * found.
+ */
+static inline struct aggregator *__get_first_agg(struct port *port)
+{
+	struct bonding *bond =3D __get_bond_by_port(port);
+
+	// If there's no bond for this port, or this is the last slave
+	if ((bond =3D=3D NULL) || (bond->next =3D=3D (struct slave *)bond)) {
+		return NULL;
+	}
+
+	return &(SLAVE_AD_INFO(bond->next).aggregator);
+}
+
+/**
+ * __get_next_agg - get the next aggregator in the bond
+ * @aggregator: the aggregator we're looking at
+ *
+ * Return the aggregator of the slave that is next in line of @aggregato=
r's
+ * slave in the bond, or %NULL if it can't be found.
+ */
+static inline struct aggregator *__get_next_agg(struct aggregator *aggre=
gator)
+{
+	struct slave *slave =3D aggregator->slave;
+	struct bonding *bond =3D bond_get_bond_by_slave(slave);
+
+	// If there's no bond for this aggregator, or this is the last slave
+	if ((bond =3D=3D NULL) || (slave->next =3D=3D bond->next)) {
+		return NULL;
+	}
+
+	return &(SLAVE_AD_INFO(slave->next).aggregator);
+}
+
+/**
+ * __disable_port - disable the port's slave
+ * @port: the port we're looking at
+ *
+ */
+static inline void __disable_port(struct port *port)
+{
+	bond_set_slave_inactive_flags(port->slave);
+}
+
+/**
+ * __enable_port - enable the port's slave, if it's up
+ * @port: the port we're looking at
+ *
+ */
+static inline void __enable_port(struct port *port)
+{
+	struct slave *slave =3D port->slave;
+
+	if ((slave->link =3D=3D BOND_LINK_UP) && IS_UP(slave->dev)) {
+		bond_set_slave_active_flags(slave);
+	}
+}
+
+/**
+ * __port_is_enabled - check if the port's slave is in active state
+ * @port: the port we're looking at
+ *
+ */
+static inline int __port_is_enabled(struct port *port)
+{
+	return(port->slave->state =3D=3D BOND_STATE_ACTIVE);
+}
+
+/**
+ * __get_agg_selection_mode - get the aggregator selection mode
+ * @port: the port we're looking at
+ *
+ * Get the aggregator selection mode. Can be %BANDWIDTH or %COUNT.
+ */
+static inline u32 __get_agg_selection_mode(struct port *port)
+{
+	struct bonding *bond =3D __get_bond_by_port(port);
+
+	if (bond =3D=3D NULL) {
+		return AD_BANDWIDTH;
+	}
+
+	return BOND_AD_INFO(bond).agg_select_mode;
+}
+
+/**
+ * __check_agg_selection_timer - check if the selection timer has expire=
d
+ * @port: the port we're looking at
+ *
+ */
+static inline int __check_agg_selection_timer(struct port *port)
+{
+	struct bonding *bond =3D __get_bond_by_port(port);
+
+	if (bond =3D=3D NULL) {
+		return 0;
+	}
+
+	return BOND_AD_INFO(bond).agg_select_timer ? 1 : 0;
+}
+
+/**
+ * __get_rx_machine_lock - lock the port's RX machine
+ * @port: the port we're looking at
+ *
+ */
+static inline void __get_rx_machine_lock(struct port *port)
+{
+	spin_lock(&(SLAVE_AD_INFO(port->slave).rx_machine_lock));
+}
+
+/**
+ * __release_rx_machine_lock - unlock the port's RX machine
+ * @port: the port we're looking at
+ *
+ */
+static inline void __release_rx_machine_lock(struct port *port)
+{
+	spin_unlock(&(SLAVE_AD_INFO(port->slave).rx_machine_lock));
+}
+
+/**
+ * __get_link_speed - get a port's speed
+ * @port: the port we're looking at
+ *
+ * Return @port's speed in 802.3ad bitmask format. i.e. one of:
+ *     0,
+ *     %AD_LINK_SPEED_BITMASK_10MBPS,
+ *     %AD_LINK_SPEED_BITMASK_100MBPS,
+ *     %AD_LINK_SPEED_BITMASK_1000MBPS
+ */
+static u16 __get_link_speed(struct port *port)
+{
+	struct slave *slave =3D port->slave;
+	u16 speed;
+
+	/* this if covers only a special case: when the configuration starts wi=
th
+	 * link down, it sets the speed to 0.
+	 * This is done in spite of the fact that the e100 driver reports 0 to =
be
+	 * compatible with MVT in the future.*/
+	if (slave->link !=3D BOND_LINK_UP) {
+		speed=3D0;
+	} else {
+		switch (slave->speed) {
+		case SPEED_10:
+			speed =3D AD_LINK_SPEED_BITMASK_10MBPS;
+			break;
+
+		case SPEED_100:
+			speed =3D AD_LINK_SPEED_BITMASK_100MBPS;
+			break;
+
+		case SPEED_1000:
+			speed =3D AD_LINK_SPEED_BITMASK_1000MBPS;
+			break;
+
+		default:
+			speed =3D 0; // unknown speed value from ethtool. shouldn't happen
+			break;
+		}
+	}
+
+	BOND_PRINT_DBG(("Port %d Received link speed %d update from adapter", p=
ort->actor_port_number, speed));
+	return speed;
+}
+
+/**
+ * __get_duplex - get a port's duplex
+ * @port: the port we're looking at
+ *
+ * Return @port's duplex in 802.3ad bitmask format. i.e.:
+ *     0x01 if in full duplex
+ *     0x00 otherwise
+ */
+static u8 __get_duplex(struct port *port)
+{
+	struct slave *slave =3D port->slave;
+
+	u8 retval;
+
+	//  handling a special case: when the configuration starts with
+	// link down, it sets the duplex to 0.
+	if (slave->link !=3D BOND_LINK_UP) {
+		retval=3D0x0;
+	} else {
+		switch (slave->duplex) {
+		case DUPLEX_FULL:
+			retval=3D0x1;
+			BOND_PRINT_DBG(("Port %d Received status full duplex update from adap=
ter", port->actor_port_number));
+			break;
+		case DUPLEX_HALF:
+		default:
+			retval=3D0x0;
+			BOND_PRINT_DBG(("Port %d Received status NOT full duplex update from =
adapter", port->actor_port_number));
+			break;
+		}
+	}
+	return retval;
+}
+
+/**
+ * __initialize_port_locks - initialize a port's RX machine spinlock
+ * @port: the port we're looking at
+ *
+ */
+static inline void __initialize_port_locks(struct port *port)
+{
+	// make sure it isn't called twice
+	spin_lock_init(&(SLAVE_AD_INFO(port->slave).rx_machine_lock));
+}
+
+/**
+ * __deinitialize_port_locks - deinitialize a port's RX machine spinlock
+ * @port: the port we're looking at
+ *
+ */
+static inline void __deinitialize_port_locks(struct port *port)
+{
+}
+
+//conversions
+/**
+ * __ntohs_lacpdu - convert the contents of a LACPDU to host byte order
+ * @lacpdu: the speicifed lacpdu
+ *
+ * For each multi-byte field in the lacpdu, convert its content
+ */
+static void __ntohs_lacpdu(struct lacpdu *lacpdu)
+{
+	if (lacpdu) {
+		lacpdu->actor_system_priority =3D   ntohs(lacpdu->actor_system_priorit=
y);
+		lacpdu->actor_key =3D               ntohs(lacpdu->actor_key);
+		lacpdu->actor_port_priority =3D     ntohs(lacpdu->actor_port_priority)=
;
+		lacpdu->actor_port =3D              ntohs(lacpdu->actor_port);
+		lacpdu->partner_system_priority =3D ntohs(lacpdu->partner_system_prior=
ity);
+		lacpdu->partner_key =3D             ntohs(lacpdu->partner_key);
+		lacpdu->partner_port_priority =3D   ntohs(lacpdu->partner_port_priorit=
y);
+		lacpdu->partner_port =3D            ntohs(lacpdu->partner_port);
+		lacpdu->collector_max_delay =3D     ntohs(lacpdu->collector_max_delay)=
;
+	}
+}
+
+/**
+ * __ad_timer_to_ticks - convert a given timer type to AD module ticks
+ * @timer_type:	which timer to operate
+ * @par: timer parameter. see below
+ *
+ * If @timer_type is %current_while_timer, @par indicates long/short tim=
er.
+ * If @timer_type is %periodic_timer, @par is one of %FAST_PERIODIC_TIME=
,
+ *						    %SLOW_PERIODIC_TIME.
+ */
+static u16 __ad_timer_to_ticks(u16 timer_type, u16 par)
+{
+	u16 retval=3D0;	 //to silence the compiler
+
+	switch (timer_type) {
+	case AD_CURRENT_WHILE_TIMER:   // for rx machine usage
+		if (par) {	      // for short or long timeout
+			retval =3D (AD_SHORT_TIMEOUT_TIME*ad_ticks_per_sec); // short timeout
+		} else {
+			retval =3D (AD_LONG_TIMEOUT_TIME*ad_ticks_per_sec); // long timeout
+		}
+		break;
+	case AD_ACTOR_CHURN_TIMER:	    // for local churn machine
+		retval =3D (AD_CHURN_DETECTION_TIME*ad_ticks_per_sec);
+		break;
+	case AD_PERIODIC_TIMER:	    // for periodic machine
+		retval =3D (par*ad_ticks_per_sec); // long timeout
+		break;
+	case AD_PARTNER_CHURN_TIMER:   // for remote churn machine
+		retval =3D (AD_CHURN_DETECTION_TIME*ad_ticks_per_sec);
+		break;
+	case AD_WAIT_WHILE_TIMER:	    // for selection machine
+		retval =3D (AD_AGGREGATE_WAIT_TIME*ad_ticks_per_sec);
+		break;
+	}
+	return retval;
+}
+
+
+////////////////////////////////////////////////////////////////////////=
/////////
+// =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D ad_rx_machine hel=
per functions =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+////////////////////////////////////////////////////////////////////////=
/////////
+
+/**
+ * __record_pdu - record parameters from a received lacpdu
+ * @lacpdu: the lacpdu we've received
+ * @port: the port we're looking at
+ *
+ * Record the parameter values for the Actor carried in a received lacpd=
u as
+ * the current partner operational parameter values and sets
+ * actor_oper_port_state.defaulted to FALSE.
+ */
+static void __record_pdu(struct lacpdu *lacpdu, struct port *port)
+{
+	// validate lacpdu and port
+	if (lacpdu && port) {
+		// record the new parameter values for the partner operational
+		port->partner_oper_port_number =3D lacpdu->actor_port;
+		port->partner_oper_port_priority =3D lacpdu->actor_port_priority;
+		port->partner_oper_system =3D lacpdu->actor_system;
+		port->partner_oper_system_priority =3D lacpdu->actor_system_priority;
+		port->partner_oper_key =3D lacpdu->actor_key;
+		// zero partener's lase states
+		port->partner_oper_port_state =3D 0;
+		port->partner_oper_port_state |=3D (lacpdu->actor_state & AD_STATE_LAC=
P_ACTIVITY);
+		port->partner_oper_port_state |=3D (lacpdu->actor_state & AD_STATE_LAC=
P_TIMEOUT);
+		port->partner_oper_port_state |=3D (lacpdu->actor_state & AD_STATE_AGG=
REGATION);
+		port->partner_oper_port_state |=3D (lacpdu->actor_state & AD_STATE_SYN=
CHRONIZATION);
+		port->partner_oper_port_state |=3D (lacpdu->actor_state & AD_STATE_COL=
LECTING);
+		port->partner_oper_port_state |=3D (lacpdu->actor_state & AD_STATE_DIS=
TRIBUTING);
+		port->partner_oper_port_state |=3D (lacpdu->actor_state & AD_STATE_DEF=
AULTED);
+		port->partner_oper_port_state |=3D (lacpdu->actor_state & AD_STATE_EXP=
IRED);
+
+		// set actor_oper_port_state.defaulted to FALSE
+		port->actor_oper_port_state &=3D ~AD_STATE_DEFAULTED;
+
+		// set the partner sync. to on if the partner is sync. and the port is=
 matched
+		if ((port->sm_vars & AD_PORT_MATCHED) && (lacpdu->actor_state & AD_STA=
TE_SYNCHRONIZATION)) {
+			port->partner_oper_port_state |=3D AD_STATE_SYNCHRONIZATION;
+		} else {
+			port->partner_oper_port_state &=3D ~AD_STATE_SYNCHRONIZATION;
+		}
+	}
+}
+
+/**
+ * __record_default - record default parameters
+ * @port: the port we're looking at
+ *
+ * This function records the default parameter values for the partner ca=
rried
+ * in the Partner Admin parameters as the current partner operational pa=
rameter
+ * values and sets actor_oper_port_state.defaulted to TRUE.
+ */
+static void __record_default(struct port *port)
+{
+	// validate the port
+	if (port) {
+		// record the partner admin parameters
+		port->partner_oper_port_number =3D port->partner_admin_port_number;
+		port->partner_oper_port_priority =3D port->partner_admin_port_priority=
;
+		port->partner_oper_system =3D port->partner_admin_system;
+		port->partner_oper_system_priority =3D port->partner_admin_system_prio=
rity;
+		port->partner_oper_key =3D port->partner_admin_key;
+		port->partner_oper_port_state =3D port->partner_admin_port_state;
+
+		// set actor_oper_port_state.defaulted to true
+		port->actor_oper_port_state |=3D AD_STATE_DEFAULTED;
+	}
+}
+
+/**
+ * __update_selected - update a port's Selected variable from a received=
 lacpdu
+ * @lacpdu: the lacpdu we've received
+ * @port: the port we're looking at
+ *
+ * Update the value of the selected variable, using parameter values fro=
m a
+ * newly received lacpdu. The parameter values for the Actor carried in =
the
+ * received PDU are compared with the corresponding operational paramete=
r
+ * values for the ports partner. If one or more of the comparisons shows=
 that
+ * the value(s) received in the PDU differ from the current operational =
values,
+ * then selected is set to FALSE and actor_oper_port_state.synchronizati=
on is
+ * set to out_of_sync. Otherwise, selected remains unchanged.
+ */
+static void __update_selected(struct lacpdu *lacpdu, struct port *port)
+{
+	// validate lacpdu and port
+	if (lacpdu && port) {
+		// check if any parameter is different
+		if ((lacpdu->actor_port !=3D port->partner_oper_port_number) ||
+		    (lacpdu->actor_port_priority !=3D port->partner_oper_port_priority=
) ||
+		    MAC_ADDRESS_COMPARE(&(lacpdu->actor_system), &(port->partner_oper_=
system)) ||
+		    (lacpdu->actor_system_priority !=3D port->partner_oper_system_prio=
rity) ||
+		    (lacpdu->actor_key !=3D port->partner_oper_key) ||
+		    ((lacpdu->actor_state & AD_STATE_AGGREGATION) !=3D (port->partner_=
oper_port_state & AD_STATE_AGGREGATION))
+		   ) {
+			// update the state machine Selected variable
+			port->sm_vars &=3D ~AD_PORT_SELECTED;
+		}
+	}
+}
+
+/**
+ * __update_default_selected - update a port's Selected variable from Pa=
rtner
+ * @port: the port we're looking at
+ *
+ * This function updates the value of the selected variable, using the p=
artner
+ * administrative parameter values. The administrative values are compar=
ed with
+ * the corresponding operational parameter values for the partner. If on=
e or
+ * more of the comparisons shows that the administrative value(s) differ=
 from
+ * the current operational values, then Selected is set to FALSE and
+ * actor_oper_port_state.synchronization is set to OUT_OF_SYNC. Otherwis=
e,
+ * Selected remains unchanged.
+ */
+static void __update_default_selected(struct port *port)
+{
+	// validate the port
+	if (port) {
+		// check if any parameter is different
+		if ((port->partner_admin_port_number !=3D port->partner_oper_port_numb=
er) ||
+		    (port->partner_admin_port_priority !=3D port->partner_oper_port_pr=
iority) ||
+		    MAC_ADDRESS_COMPARE(&(port->partner_admin_system), &(port->partner=
_oper_system)) ||
+		    (port->partner_admin_system_priority !=3D port->partner_oper_syste=
m_priority) ||
+		    (port->partner_admin_key !=3D port->partner_oper_key) ||
+		    ((port->partner_admin_port_state & AD_STATE_AGGREGATION) !=3D (por=
t->partner_oper_port_state & AD_STATE_AGGREGATION))
+		   ) {
+			// update the state machine Selected variable
+			port->sm_vars &=3D ~AD_PORT_SELECTED;
+		}
+	}
+}
+
+/**
+ * __choose_matched - update a port's matched variable from a received l=
acpdu
+ * @lacpdu: the lacpdu we've received
+ * @port: the port we're looking at
+ *
+ * Update the value of the matched variable, using parameter values from=
 a
+ * newly received lacpdu. Parameter values for the partner carried in th=
e
+ * received PDU are compared with the corresponding operational paramete=
r
+ * values for the actor. Matched is set to TRUE if all of these paramete=
rs
+ * match and the PDU parameter partner_state.aggregation has the same va=
lue as
+ * actor_oper_port_state.aggregation and lacp will actively maintain the=
 link
+ * in the aggregation. Matched is also set to TRUE if the value of
+ * actor_state.aggregation in the received PDU is set to FALSE, i.e., in=
dicates
+ * an individual link and lacp will actively maintain the link. Otherwis=
e,
+ * matched is set to FALSE. LACP is considered to be actively maintainin=
g the
+ * link if either the PDU's actor_state.lacp_activity variable is TRUE o=
r both
+ * the actor's actor_oper_port_state.lacp_activity and the PDU's
+ * partner_state.lacp_activity variables are TRUE.
+ */
+static void __choose_matched(struct lacpdu *lacpdu, struct port *port)
+{
+	// validate lacpdu and port
+	if (lacpdu && port) {
+		// check if all parameters are alike
+		if (((lacpdu->partner_port =3D=3D port->actor_port_number) &&
+		     (lacpdu->partner_port_priority =3D=3D port->actor_port_priority) =
&&
+		     !MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_sys=
tem)) &&
+		     (lacpdu->partner_system_priority =3D=3D port->actor_system_priori=
ty) &&
+		     (lacpdu->partner_key =3D=3D port->actor_oper_port_key) &&
+		     ((lacpdu->partner_state & AD_STATE_AGGREGATION) =3D=3D (port->act=
or_oper_port_state & AD_STATE_AGGREGATION))) ||
+		    // or this is individual link(aggregation =3D=3D FALSE)
+		    ((lacpdu->actor_state & AD_STATE_AGGREGATION) =3D=3D 0)
+		   ) {
+			// update the state machine Matched variable
+			port->sm_vars |=3D AD_PORT_MATCHED;
+		} else {
+			port->sm_vars &=3D ~AD_PORT_MATCHED;
+		}
+	}
+}
+
+/**
+ * __update_ntt - update a port's ntt variable from a received lacpdu
+ * @lacpdu: the lacpdu we've received
+ * @port: the port we're looking at
+ *
+ * Updates the value of the ntt variable, using parameter values from a =
newly
+ * received lacpdu. The parameter values for the partner carried in the
+ * received PDU are compared with the corresponding operational paramete=
r
+ * values for the Actor. If one or more of the comparisons shows that th=
e
+ * value(s) received in the PDU differ from the current operational valu=
es,
+ * then ntt is set to TRUE. Otherwise, ntt remains unchanged.
+ */
+static void __update_ntt(struct lacpdu *lacpdu, struct port *port)
+{
+	// validate lacpdu and port
+	if (lacpdu && port) {
+		// check if any parameter is different
+		if ((lacpdu->partner_port !=3D port->actor_port_number) ||
+		    (lacpdu->partner_port_priority !=3D port->actor_port_priority) ||
+		    MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_syste=
m)) ||
+		    (lacpdu->partner_system_priority !=3D port->actor_system_priority)=
 ||
+		    (lacpdu->partner_key !=3D port->actor_oper_port_key) ||
+		    ((lacpdu->partner_state & AD_STATE_LACP_ACTIVITY) !=3D (port->acto=
r_oper_port_state & AD_STATE_LACP_ACTIVITY)) ||
+		    ((lacpdu->partner_state & AD_STATE_LACP_TIMEOUT) !=3D (port->actor=
_oper_port_state & AD_STATE_LACP_TIMEOUT)) ||
+		    ((lacpdu->partner_state & AD_STATE_SYNCHRONIZATION) !=3D (port->ac=
tor_oper_port_state & AD_STATE_SYNCHRONIZATION)) ||
+		    ((lacpdu->partner_state & AD_STATE_AGGREGATION) !=3D (port->actor_=
oper_port_state & AD_STATE_AGGREGATION))
+		   ) {
+			// set ntt to be TRUE
+			port->ntt =3D 1;
+		}
+	}
+}
+
+/**
+ * __attach_bond_to_agg
+ * @port: the port we're looking at
+ *
+ * Handle the attaching of the port's control parser/multiplexer and the
+ * aggregator. This function does nothing since the parser/multiplexer o=
f the
+ * receive and the parser/multiplexer of the aggregator are already comb=
ined.
+ */
+static void __attach_bond_to_agg(struct port *port)
+{
+	port=3DNULL; // just to satisfy the compiler
+	// This function does nothing since the parser/multiplexer of the recei=
ve
+	// and the parser/multiplexer of the aggregator are already combined
+}
+
+/**
+ * __detach_bond_to_agg
+ * @port: the port we're looking at
+ *
+ * Handle the detaching of the port's control parser/multiplexer from th=
e
+ * aggregator. This function does nothing since the parser/multiplexer o=
f the
+ * receive and the parser/multiplexer of the aggregator are already comb=
ined.
+ */
+static void __detach_bond_from_agg(struct port *port)
+{
+	port=3DNULL; // just to satisfy the compiler
+	// This function does nothing sience the parser/multiplexer of the rece=
ive
+	// and the parser/multiplexer of the aggregator are already combined
+}
+
+/**
+ * __agg_ports_are_ready - check if all ports in an aggregator are ready
+ * @aggregator: the aggregator we're looking at
+ *
+ */
+static int __agg_ports_are_ready(struct aggregator *aggregator)
+{
+	struct port *port;
+	int retval =3D 1;
+
+	if (aggregator) {
+		// scan all ports in this aggregator to verfy if they are all ready
+		for (port=3Daggregator->lag_ports; port; port=3Dport->next_port_in_agg=
regator) {
+			if (!(port->sm_vars & AD_PORT_READY_N)) {
+				retval =3D 0;
+				break;
+			}
+		}
+	}
+
+	return retval;
+}
+
+/**
+ * __set_agg_ports_ready - set value of Ready bit in all ports of an agg=
regator
+ * @aggregator: the aggregator we're looking at
+ * @val: Should the ports' ready bit be set on or off
+ *
+ */
+static void __set_agg_ports_ready(struct aggregator *aggregator, int val=
)
+{
+	struct port *port;
+
+	for (port=3Daggregator->lag_ports; port; port=3Dport->next_port_in_aggr=
egator) {
+		if (val) {
+			port->sm_vars |=3D AD_PORT_READY;
+		} else {
+			port->sm_vars &=3D ~AD_PORT_READY;
+		}
+	}
+}
+
+/**
+ * __get_agg_bandwidth - get the total bandwidth of an aggregator
+ * @aggregator: the aggregator we're looking at
+ *
+ */
+static u32 __get_agg_bandwidth(struct aggregator *aggregator)
+{
+	u32 bandwidth=3D0;
+	u32 basic_speed;
+
+	if (aggregator->num_of_ports) {
+		basic_speed =3D __get_link_speed(aggregator->lag_ports);
+		switch (basic_speed) {
+		case AD_LINK_SPEED_BITMASK_1MBPS:
+			bandwidth =3D aggregator->num_of_ports;
+			break;
+		case AD_LINK_SPEED_BITMASK_10MBPS:
+			bandwidth =3D aggregator->num_of_ports * 10;
+			break;
+		case AD_LINK_SPEED_BITMASK_100MBPS:
+			bandwidth =3D aggregator->num_of_ports * 100;
+			break;
+		case AD_LINK_SPEED_BITMASK_1000MBPS:
+			bandwidth =3D aggregator->num_of_ports * 1000;
+			break;
+		default:
+			bandwidth=3D0; // to silent the compilor ....
+		}
+	}
+	return bandwidth;
+}
+
+/**
+ * __get_active_agg - get the current active aggregator
+ * @aggregator: the aggregator we're looking at
+ *
+ */
+static struct aggregator *__get_active_agg(struct aggregator *aggregator=
)
+{
+	struct aggregator *retval =3D NULL;
+
+	for (; aggregator; aggregator =3D __get_next_agg(aggregator)) {
+		if (aggregator->is_active) {
+			retval =3D aggregator;
+			break;
+		}
+	}
+
+	return retval;
+}
+
+////////////////////////////////////////////////////////////////////////=
//////////////
+// =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D main 802.3ad prot=
ocol code =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+////////////////////////////////////////////////////////////////////////=
//////////////
+
+/**
+ * ad_lacpdu_send - send out a lacpdu packet on a given port
+ * @port: the port we're looking at
+ *
+ * Returns:   0 on success
+ *          < 0 on error
+ */
+static int ad_lacpdu_send(struct port *port)
+{
+	struct slave *slave =3D port->slave;
+	struct sk_buff *skb;
+	struct lacpdu_header *lacpdu_header;
+	int length =3D sizeof(struct lacpdu_header);
+	struct mac_addr lacpdu_multicast_address =3D AD_MULTICAST_LACPDU_ADDR;
+
+	skb =3D dev_alloc_skb(length);
+	if (!skb) {
+		return -ENOMEM;
+	}
+
+	skb->dev =3D slave->dev;
+	skb->mac.raw =3D skb->data;
+	skb->nh.raw =3D skb->data + ETH_HLEN;
+	skb->protocol =3D PKT_TYPE_LACPDU;
+
+	lacpdu_header =3D (struct lacpdu_header *)skb_put(skb, length);
+
+	lacpdu_header->ad_header.destination_address =3D lacpdu_multicast_addre=
ss;
+	/* Note: source addres is set to be the member's PERMANENT address, bec=
ause we use it
+	   to identify loopback lacpdus in receive. */
+	lacpdu_header->ad_header.source_address =3D *((struct mac_addr *)(slave=
->perm_hwaddr));
+	lacpdu_header->ad_header.length_type =3D PKT_TYPE_LACPDU;
+
+	lacpdu_header->lacpdu =3D port->lacpdu; // struct copy
+
+	dev_queue_xmit(skb);
+
+	return 0;
+}
+
+/**
+ * ad_marker_send - send marker information/response on a given port
+ * @port: the port we're looking at
+ * @marker: marker data to send
+ *
+ * Returns:   0 on success
+ *          < 0 on error
+ */
+static int ad_marker_send(struct port *port, struct marker *marker)
+{
+	struct slave *slave =3D port->slave;
+	struct sk_buff *skb;
+	struct marker_header *marker_header;
+	int length =3D sizeof(struct marker_header);
+	struct mac_addr lacpdu_multicast_address =3D AD_MULTICAST_LACPDU_ADDR;
+
+	skb =3D dev_alloc_skb(length + 16);
+	if (!skb) {
+		return -ENOMEM;
+	}
+
+	skb_reserve(skb, 16);
+
+	skb->dev =3D slave->dev;
+	skb->mac.raw =3D skb->data;
+	skb->nh.raw =3D skb->data + ETH_HLEN;
+	skb->protocol =3D PKT_TYPE_LACPDU;
+
+	marker_header =3D (struct marker_header *)skb_put(skb, length);
+
+	marker_header->ad_header.destination_address =3D lacpdu_multicast_addre=
ss;
+	/* Note: source addres is set to be the member's PERMANENT address, bec=
ause we use it
+	   to identify loopback MARKERs in receive. */
+	marker_header->ad_header.source_address =3D *((struct mac_addr *)(slave=
->perm_hwaddr));
+	marker_header->ad_header.length_type =3D PKT_TYPE_LACPDU;
+
+	marker_header->marker =3D *marker; // struct copy
+
+	dev_queue_xmit(skb);
+
+	return 0;
+}
+
+/**
+ * ad_mux_machine - handle a port's mux state machine
+ * @port: the port we're looking at
+ *
+ */
+static void ad_mux_machine(struct port *port)
+{
+	mux_states_t last_state;
+
+	// keep current State Machine state to compare later if it was changed
+	last_state =3D port->sm_mux_state;
+
+	if (port->sm_vars & AD_PORT_BEGIN) {
+		port->sm_mux_state =3D AD_MUX_DETACHED;		 // next state
+	} else {
+		switch (port->sm_mux_state) {
+		case AD_MUX_DETACHED:
+			if ((port->sm_vars & AD_PORT_SELECTED) || (port->sm_vars & AD_PORT_ST=
ANDBY)) { // if SELECTED or STANDBY
+				port->sm_mux_state =3D AD_MUX_WAITING; // next state
+			}
+			break;
+		case AD_MUX_WAITING:
+			// if SELECTED =3D=3D FALSE return to DETACH state
+			if (!(port->sm_vars & AD_PORT_SELECTED)) { // if UNSELECTED
+				port->sm_vars &=3D ~AD_PORT_READY_N;
+				// in order to withhold the Selection Logic to check all ports READY=
_N value
+				// every callback cycle to update ready variable, we check READY_N a=
nd update READY here
+				__set_agg_ports_ready(port->aggregator, __agg_ports_are_ready(port->=
aggregator));
+				port->sm_mux_state =3D AD_MUX_DETACHED;	 // next state
+				break;
+			}
+
+			// check if the wait_while_timer expired
+			if (port->sm_mux_timer_counter && !(--port->sm_mux_timer_counter)) {
+				port->sm_vars |=3D AD_PORT_READY_N;
+			}
+
+			// in order to withhold the selection logic to check all ports READY_=
N value
+			// every callback cycle to update ready variable, we check READY_N an=
d update READY here
+			__set_agg_ports_ready(port->aggregator, __agg_ports_are_ready(port->a=
ggregator));
+
+			// if the wait_while_timer expired, and the port is in READY state, m=
ove to ATTACHED state
+			if ((port->sm_vars & AD_PORT_READY) && !port->sm_mux_timer_counter) {
+				port->sm_mux_state =3D AD_MUX_ATTACHED;	 // next state
+			}
+			break;
+		case AD_MUX_ATTACHED:
+			// check also if agg_select_timer expired(so the edable port will tak=
e place only after this timer)
+			if ((port->sm_vars & AD_PORT_SELECTED) && (port->partner_oper_port_st=
ate & AD_STATE_SYNCHRONIZATION) && !__check_agg_selection_timer(port)) {
+				port->sm_mux_state =3D AD_MUX_COLLECTING_DISTRIBUTING;// next state
+			} else if (!(port->sm_vars & AD_PORT_SELECTED) || (port->sm_vars & AD=
_PORT_STANDBY)) {	  // if UNSELECTED or STANDBY
+				port->sm_vars &=3D ~AD_PORT_READY_N;
+				// in order to withhold the selection logic to check all ports READY=
_N value
+				// every callback cycle to update ready variable, we check READY_N a=
nd update READY here
+				__set_agg_ports_ready(port->aggregator, __agg_ports_are_ready(port->=
aggregator));
+				port->sm_mux_state =3D AD_MUX_DETACHED;// next state
+			}
+			break;
+		case AD_MUX_COLLECTING_DISTRIBUTING:
+			if (!(port->sm_vars & AD_PORT_SELECTED) || (port->sm_vars & AD_PORT_S=
TANDBY) ||
+			    !(port->partner_oper_port_state & AD_STATE_SYNCHRONIZATION)
+			   ) {
+				port->sm_mux_state =3D AD_MUX_ATTACHED;// next state
+
+			} else {
+				// if port state hasn't changed make
+				// sure that a collecting distributing
+				// port in an active aggregator is enabled
+				if (port->aggregator &&
+				    port->aggregator->is_active &&
+				    !__port_is_enabled(port)) {
+
+					__enable_port(port);
+				}
+			}
+			break;
+		default:    //to silence the compiler
+			break;
+		}
+	}
+
+	// check if the state machine was changed
+	if (port->sm_mux_state !=3D last_state) {
+		BOND_PRINT_DBG(("Mux Machine: Port=3D%d, Last State=3D%d, Curr State=3D=
%d", port->actor_port_number, last_state, port->sm_mux_state));
+		switch (port->sm_mux_state) {
+		case AD_MUX_DETACHED:
+			__detach_bond_from_agg(port);
+			port->actor_oper_port_state &=3D ~AD_STATE_SYNCHRONIZATION;
+			ad_disable_collecting_distributing(port);
+			port->actor_oper_port_state &=3D ~AD_STATE_COLLECTING;
+			port->actor_oper_port_state &=3D ~AD_STATE_DISTRIBUTING;
+			port->ntt =3D 1;
+			break;
+		case AD_MUX_WAITING:
+			port->sm_mux_timer_counter =3D __ad_timer_to_ticks(AD_WAIT_WHILE_TIME=
R, 0);
+			break;
+		case AD_MUX_ATTACHED:
+			__attach_bond_to_agg(port);
+			port->actor_oper_port_state |=3D AD_STATE_SYNCHRONIZATION;
+			port->actor_oper_port_state &=3D ~AD_STATE_COLLECTING;
+			port->actor_oper_port_state &=3D ~AD_STATE_DISTRIBUTING;
+			ad_disable_collecting_distributing(port);
+			port->ntt =3D 1;
+			break;
+		case AD_MUX_COLLECTING_DISTRIBUTING:
+			port->actor_oper_port_state |=3D AD_STATE_COLLECTING;
+			port->actor_oper_port_state |=3D AD_STATE_DISTRIBUTING;
+			ad_enable_collecting_distributing(port);
+			port->ntt =3D 1;
+			break;
+		default:    //to silence the compiler
+			break;
+		}
+	}
+}
+
+/**
+ * ad_rx_machine - handle a port's rx State Machine
+ * @lacpdu: the lacpdu we've received
+ * @port: the port we're looking at
+ *
+ * If lacpdu arrived, stop previous timer (if exists) and set the next s=
tate as
+ * CURRENT. If timer expired set the state machine in the proper state.
+ * In other cases, this function checks if we need to switch to other st=
ate.
+ */
+static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
+{
+	rx_states_t last_state;
+
+	// Lock to prevent 2 instances of this function to run simultaneously(r=
x interrupt and periodic machine callback)
+	__get_rx_machine_lock(port);
+
+	// keep current State Machine state to compare later if it was changed
+	last_state =3D port->sm_rx_state;
+
+	// check if state machine should change state
+	// first, check if port was reinitialized
+	if (port->sm_vars & AD_PORT_BEGIN) {
+		port->sm_rx_state =3D AD_RX_INITIALIZE;		    // next state
+	}
+	// check if port is not enabled
+	else if (!(port->sm_vars & AD_PORT_BEGIN) && !port->is_enabled && !(por=
t->sm_vars & AD_PORT_MOVED)) {
+		port->sm_rx_state =3D AD_RX_PORT_DISABLED;	    // next state
+	}
+	// check if new lacpdu arrived
+	else if (lacpdu && ((port->sm_rx_state =3D=3D AD_RX_EXPIRED) || (port->=
sm_rx_state =3D=3D AD_RX_DEFAULTED) || (port->sm_rx_state =3D=3D AD_RX_CU=
RRENT))) {
+		port->sm_rx_timer_counter =3D 0; // zero timer
+		port->sm_rx_state =3D AD_RX_CURRENT;
+	} else {
+		// if timer is on, and if it is expired
+		if (port->sm_rx_timer_counter && !(--port->sm_rx_timer_counter)) {
+			switch (port->sm_rx_state) {
+			case AD_RX_EXPIRED:
+				port->sm_rx_state =3D AD_RX_DEFAULTED;		// next state
+				break;
+			case AD_RX_CURRENT:
+				port->sm_rx_state =3D AD_RX_EXPIRED;	    // next state
+				break;
+			default:    //to silence the compiler
+				break;
+			}
+		} else {
+			// if no lacpdu arrived and no timer is on
+			switch (port->sm_rx_state) {
+			case AD_RX_PORT_DISABLED:
+				if (port->sm_vars & AD_PORT_MOVED) {
+					port->sm_rx_state =3D AD_RX_INITIALIZE;	    // next state
+				} else if (port->is_enabled && (port->sm_vars & AD_PORT_LACP_ENABLED=
)) {
+					port->sm_rx_state =3D AD_RX_EXPIRED;	// next state
+				} else if (port->is_enabled && ((port->sm_vars & AD_PORT_LACP_ENABLE=
D) =3D=3D 0)) {
+					port->sm_rx_state =3D AD_RX_LACP_DISABLED;    // next state
+				}
+				break;
+			default:    //to silence the compiler
+				break;
+
+			}
+		}
+	}
+
+	// check if the State machine was changed or new lacpdu arrived
+	if ((port->sm_rx_state !=3D last_state) || (lacpdu)) {
+		BOND_PRINT_DBG(("Rx Machine: Port=3D%d, Last State=3D%d, Curr State=3D=
%d", port->actor_port_number, last_state, port->sm_rx_state));
+		switch (port->sm_rx_state) {
+		case AD_RX_INITIALIZE:
+			if (!(port->actor_oper_port_key & AD_DUPLEX_KEY_BITS)) {
+				port->sm_vars &=3D ~AD_PORT_LACP_ENABLED;
+			} else {
+				port->sm_vars |=3D AD_PORT_LACP_ENABLED;
+			}
+			port->sm_vars &=3D ~AD_PORT_SELECTED;
+			__record_default(port);
+			port->actor_oper_port_state &=3D ~AD_STATE_EXPIRED;
+			port->sm_vars &=3D ~AD_PORT_MOVED;
+			port->sm_rx_state =3D AD_RX_PORT_DISABLED;	// next state
+
+			/*- Fall Through -*/
+
+		case AD_RX_PORT_DISABLED:
+			port->sm_vars &=3D ~AD_PORT_MATCHED;
+			break;
+		case AD_RX_LACP_DISABLED:
+			port->sm_vars &=3D ~AD_PORT_SELECTED;
+			__record_default(port);
+			port->partner_oper_port_state &=3D ~AD_STATE_AGGREGATION;
+			port->sm_vars |=3D AD_PORT_MATCHED;
+			port->actor_oper_port_state &=3D ~AD_STATE_EXPIRED;
+			break;
+		case AD_RX_EXPIRED:
+			//Reset of the Synchronization flag. (Standard 43.4.12)
+			//This reset cause to disable this port in the COLLECTING_DISTRIBUTIN=
G state of the
+			//mux machine in case of EXPIRED even if LINK_DOWN didn't arrive for =
the port.
+			port->partner_oper_port_state &=3D ~AD_STATE_SYNCHRONIZATION;
+			port->sm_vars &=3D ~AD_PORT_MATCHED;
+			port->partner_oper_port_state |=3D AD_SHORT_TIMEOUT;
+			port->sm_rx_timer_counter =3D __ad_timer_to_ticks(AD_CURRENT_WHILE_TI=
MER, (u16)(AD_SHORT_TIMEOUT));
+			port->actor_oper_port_state |=3D AD_STATE_EXPIRED;
+			break;
+		case AD_RX_DEFAULTED:
+			__update_default_selected(port);
+			__record_default(port);
+			port->sm_vars |=3D AD_PORT_MATCHED;
+			port->actor_oper_port_state &=3D ~AD_STATE_EXPIRED;
+			break;
+		case AD_RX_CURRENT:
+			// detect loopback situation
+			if (!MAC_ADDRESS_COMPARE(&(lacpdu->actor_system), &(port->actor_syste=
m))) {
+				// INFO_RECEIVED_LOOPBACK_FRAMES
+				printk(KERN_ERR "bonding: An illegal loopback occurred on adapter (%=
s)\n",
+						port->slave->dev->name);
+				printk(KERN_ERR "Check the configuration to verify that all Adapters=
 "
+						"are connected to 802.3ad compliant switch ports\n");
+				__release_rx_machine_lock(port);
+				return;
+			}
+			__update_selected(lacpdu, port);
+			__update_ntt(lacpdu, port);
+			__record_pdu(lacpdu, port);
+			__choose_matched(lacpdu, port);
+			port->sm_rx_timer_counter =3D __ad_timer_to_ticks(AD_CURRENT_WHILE_TI=
MER, (u16)(port->actor_oper_port_state & AD_STATE_LACP_TIMEOUT));
+			port->actor_oper_port_state &=3D ~AD_STATE_EXPIRED;
+			// verify that if the aggregator is enabled, the port is enabled too.
+			//(because if the link goes down for a short time, the 802.3ad will n=
ot
+			// catch it, and the port will continue to be disabled)
+			if (port->aggregator && port->aggregator->is_active && !__port_is_ena=
bled(port)) {
+				__enable_port(port);
+			}
+			break;
+		default:    //to silence the compiler
+			break;
+		}
+	}
+	__release_rx_machine_lock(port);
+}
+
+/**
+ * ad_tx_machine - handle a port's tx state machine
+ * @port: the port we're looking at
+ *
+ */
+static void ad_tx_machine(struct port *port)
+{
+	struct lacpdu *lacpdu =3D &port->lacpdu;
+
+	// check if tx timer expired, to verify that we do not send more than 3=
 packets per second
+	if (port->sm_tx_timer_counter && !(--port->sm_tx_timer_counter)) {
+		// check if there is something to send
+		if (port->ntt && (port->sm_vars & AD_PORT_LACP_ENABLED)) {
+			//update current actual Actor parameters
+			//lacpdu->subtype                   initialized
+			//lacpdu->version_number            initialized
+			//lacpdu->tlv_type_actor_info       initialized
+			//lacpdu->actor_information_length  initialized
+			lacpdu->actor_system_priority =3D port->actor_system_priority;
+			lacpdu->actor_system =3D port->actor_system;
+			lacpdu->actor_key =3D port->actor_oper_port_key;
+			lacpdu->actor_port_priority =3D port->actor_port_priority;
+			lacpdu->actor_port =3D port->actor_port_number;
+			lacpdu->actor_state =3D port->actor_oper_port_state;
+			//lacpdu->reserved_3_1              initialized
+			//lacpdu->tlv_type_partner_info     initialized
+			//lacpdu->partner_information_length initialized
+			lacpdu->partner_system_priority =3D port->partner_oper_system_priorit=
y;
+			lacpdu->partner_system =3D port->partner_oper_system;
+			lacpdu->partner_key =3D port->partner_oper_key;
+			lacpdu->partner_port_priority =3D port->partner_oper_port_priority;
+			lacpdu->partner_port =3D port->partner_oper_port_number;
+			lacpdu->partner_state =3D port->partner_oper_port_state;
+			//lacpdu->reserved_3_2              initialized
+			//lacpdu->tlv_type_collector_info   initialized
+			//lacpdu->collector_information_length initialized
+			//collector_max_delay                initialized
+			//reserved_12[12]                   initialized
+			//tlv_type_terminator               initialized
+			//terminator_length                 initialized
+			//reserved_50[50]                   initialized
+
+			// We need to convert all non u8 parameters to Big Endian for transmi=
t
+			__ntohs_lacpdu(lacpdu);
+			// send the lacpdu
+			if (ad_lacpdu_send(port) >=3D 0) {
+				BOND_PRINT_DBG(("Sent LACPDU on port %d", port->actor_port_number));
+				// mark ntt as false, so it will not be sent again until demanded
+				port->ntt =3D 0;
+			}
+		}
+		// restart tx timer(to verify that we will not exceed AD_MAX_TX_IN_SEC=
OND
+		port->sm_tx_timer_counter=3Dad_ticks_per_sec/AD_MAX_TX_IN_SECOND;
+	}
+}
+
+/**
+ * ad_periodic_machine - handle a port's periodic state machine
+ * @port: the port we're looking at
+ *
+ * Turn ntt flag on priodically to perform periodic transmission of lacp=
du's.
+ */
+static void ad_periodic_machine(struct port *port)
+{
+	periodic_states_t last_state;
+
+	// keep current state machine state to compare later if it was changed
+	last_state =3D port->sm_periodic_state;
+
+	// check if port was reinitialized
+	if (((port->sm_vars & AD_PORT_BEGIN) || !(port->sm_vars & AD_PORT_LACP_=
ENABLED) || !port->is_enabled) ||
+	    (!(port->actor_oper_port_state & AD_STATE_LACP_ACTIVITY) && !(port-=
>partner_oper_port_state & AD_STATE_LACP_ACTIVITY))
+	   ) {
+		port->sm_periodic_state =3D AD_NO_PERIODIC;	     // next state
+	}
+	// check if state machine should change state
+	else if (port->sm_periodic_timer_counter) {
+		// check if periodic state machine expired
+		if (!(--port->sm_periodic_timer_counter)) {
+			// if expired then do tx
+			port->sm_periodic_state =3D AD_PERIODIC_TX;    // next state
+		} else {
+			// If not expired, check if there is some new timeout parameter from =
the partner state
+			switch (port->sm_periodic_state) {
+			case AD_FAST_PERIODIC:
+				if (!(port->partner_oper_port_state & AD_STATE_LACP_TIMEOUT)) {
+					port->sm_periodic_state =3D AD_SLOW_PERIODIC;  // next state
+				}
+				break;
+			case AD_SLOW_PERIODIC:
+				if ((port->partner_oper_port_state & AD_STATE_LACP_TIMEOUT)) {
+					// stop current timer
+					port->sm_periodic_timer_counter =3D 0;
+					port->sm_periodic_state =3D AD_PERIODIC_TX;	 // next state
+				}
+				break;
+			default:    //to silence the compiler
+				break;
+			}
+		}
+	} else {
+		switch (port->sm_periodic_state) {
+		case AD_NO_PERIODIC:
+			port->sm_periodic_state =3D AD_FAST_PERIODIC;	 // next state
+			break;
+		case AD_PERIODIC_TX:
+			if (!(port->partner_oper_port_state & AD_STATE_LACP_TIMEOUT)) {
+				port->sm_periodic_state =3D AD_SLOW_PERIODIC;  // next state
+			} else {
+				port->sm_periodic_state =3D AD_FAST_PERIODIC;  // next state
+			}
+			break;
+		default:    //to silence the compiler
+			break;
+		}
+	}
+
+	// check if the state machine was changed
+	if (port->sm_periodic_state !=3D last_state) {
+		BOND_PRINT_DBG(("Periodic Machine: Port=3D%d, Last State=3D%d, Curr St=
ate=3D%d", port->actor_port_number, last_state, port->sm_periodic_state))=
;
+		switch (port->sm_periodic_state) {
+		case AD_NO_PERIODIC:
+			port->sm_periodic_timer_counter =3D 0;	   // zero timer
+			break;
+		case AD_FAST_PERIODIC:
+			port->sm_periodic_timer_counter =3D __ad_timer_to_ticks(AD_PERIODIC_T=
IMER, (u16)(AD_FAST_PERIODIC_TIME))-1; // decrement 1 tick we lost in the=
 PERIODIC_TX cycle
+			break;
+		case AD_SLOW_PERIODIC:
+			port->sm_periodic_timer_counter =3D __ad_timer_to_ticks(AD_PERIODIC_T=
IMER, (u16)(AD_SLOW_PERIODIC_TIME))-1; // decrement 1 tick we lost in the=
 PERIODIC_TX cycle
+			break;
+		case AD_PERIODIC_TX:
+			port->ntt =3D 1;
+			break;
+		default:    //to silence the compiler
+			break;
+		}
+	}
+}
+
+/**
+ * ad_port_selection_logic - select aggregation groups
+ * @port: the port we're looking at
+ *
+ * Select aggregation groups, and assign each port for it's aggregetor. =
The
+ * selection logic is called in the inititalization (after all the hands=
hkes),
+ * and after every lacpdu receive (if selected is off).
+ */
+static void ad_port_selection_logic(struct port *port)
+{
+	struct aggregator *aggregator, *free_aggregator =3D NULL, *temp_aggrega=
tor;
+	struct port *last_port =3D NULL, *curr_port;
+	int found =3D 0;
+
+	// if the port is already Selected, do nothing
+	if (port->sm_vars & AD_PORT_SELECTED) {
+		return;
+	}
+
+	// if the port is connected to other aggregator, detach it
+	if (port->aggregator) {
+		// detach the port from its former aggregator
+		temp_aggregator=3Dport->aggregator;
+		for (curr_port=3Dtemp_aggregator->lag_ports; curr_port; last_port=3Dcu=
rr_port, curr_port=3Dcurr_port->next_port_in_aggregator) {
+			if (curr_port =3D=3D port) {
+				temp_aggregator->num_of_ports--;
+				if (!last_port) {// if it is the first port attached to the aggregat=
or
+					temp_aggregator->lag_ports=3Dport->next_port_in_aggregator;
+				} else {// not the first port attached to the aggregator
+					last_port->next_port_in_aggregator=3Dport->next_port_in_aggregator;
+				}
+
+				// clear the port's relations to this aggregator
+				port->aggregator =3D NULL;
+				port->next_port_in_aggregator=3DNULL;
+				port->actor_port_aggregator_identifier=3D0;
+
+				BOND_PRINT_DBG(("Port %d left LAG %d", port->actor_port_number, temp=
_aggregator->aggregator_identifier));
+				// if the aggregator is empty, clear its parameters, and set it read=
y to be attached
+				if (!temp_aggregator->lag_ports) {
+					ad_clear_agg(temp_aggregator);
+				}
+				break;
+			}
+		}
+		if (!curr_port) { // meaning: the port was related to an aggregator bu=
t was not on the aggregator port list
+			printk(KERN_WARNING "bonding: Warning: Port %d (on %s) was "
+			       "related to aggregator %d but was not on its port list\n",
+			       port->actor_port_number, port->slave->dev->name,
+			       port->aggregator->aggregator_identifier);
+		}
+	}
+	// search on all aggregators for a suitable aggregator for this port
+	for (aggregator =3D __get_first_agg(port); aggregator;
+	     aggregator =3D __get_next_agg(aggregator)) {
+
+		// keep a free aggregator for later use(if needed)
+		if (!aggregator->lag_ports) {
+			if (!free_aggregator) {
+				free_aggregator=3Daggregator;
+			}
+			continue;
+		}
+		// check if current aggregator suits us
+		if (((aggregator->actor_oper_aggregator_key =3D=3D port->actor_oper_po=
rt_key) && // if all parameters match AND
+		     !MAC_ADDRESS_COMPARE(&(aggregator->partner_system), &(port->partn=
er_oper_system)) &&
+		     (aggregator->partner_system_priority =3D=3D port->partner_oper_sy=
stem_priority) &&
+		     (aggregator->partner_oper_aggregator_key =3D=3D port->partner_ope=
r_key)
+		    ) &&
+		    ((MAC_ADDRESS_COMPARE(&(port->partner_oper_system), &(null_mac_add=
r)) && // partner answers
+		      !aggregator->is_individual)  // but is not individual OR
+		    )
+		   ) {
+			// attach to the founded aggregator
+			port->aggregator =3D aggregator;
+			port->actor_port_aggregator_identifier=3Dport->aggregator->aggregator=
_identifier;
+			port->next_port_in_aggregator=3Daggregator->lag_ports;
+			port->aggregator->num_of_ports++;
+			aggregator->lag_ports=3Dport;
+			BOND_PRINT_DBG(("Port %d joined LAG %d(existing LAG)", port->actor_po=
rt_number, port->aggregator->aggregator_identifier));
+
+			// mark this port as selected
+			port->sm_vars |=3D AD_PORT_SELECTED;
+			found =3D 1;
+			break;
+		}
+	}
+
+	// the port couldn't find an aggregator - attach it to a new aggregator
+	if (!found) {
+		if (free_aggregator) {
+			// assign port a new aggregator
+			port->aggregator =3D free_aggregator;
+			port->actor_port_aggregator_identifier=3Dport->aggregator->aggregator=
_identifier;
+
+			// update the new aggregator's parameters
+			// if port was responsed from the end-user
+			if (port->actor_oper_port_key & AD_DUPLEX_KEY_BITS) {// if port is fu=
ll duplex
+				port->aggregator->is_individual =3D 0;
+			} else {
+				port->aggregator->is_individual =3D 1;
+			}
+
+			port->aggregator->actor_admin_aggregator_key =3D port->actor_admin_po=
rt_key;
+			port->aggregator->actor_oper_aggregator_key =3D port->actor_oper_port=
_key;
+			port->aggregator->partner_system=3Dport->partner_oper_system;
+			port->aggregator->partner_system_priority =3D port->partner_oper_syst=
em_priority;
+			port->aggregator->partner_oper_aggregator_key =3D port->partner_oper_=
key;
+			port->aggregator->receive_state =3D 1;
+			port->aggregator->transmit_state =3D 1;
+			port->aggregator->lag_ports =3D port;
+			port->aggregator->num_of_ports++;
+
+			// mark this port as selected
+			port->sm_vars |=3D AD_PORT_SELECTED;
+
+			BOND_PRINT_DBG(("Port %d joined LAG %d(new LAG)", port->actor_port_nu=
mber, port->aggregator->aggregator_identifier));
+		} else {
+			printk(KERN_ERR "bonding: Port %d (on %s) did not find a suitable agg=
regator\n",
+			       port->actor_port_number, port->slave->dev->name);
+		}
+	}
+	// if all aggregator's ports are READY_N =3D=3D TRUE, set ready=3DTRUE =
in all aggregator's ports
+	// else set ready=3DFALSE in all aggregator's ports
+	__set_agg_ports_ready(port->aggregator, __agg_ports_are_ready(port->agg=
regator));
+
+	if (!__check_agg_selection_timer(port) && (aggregator =3D __get_first_a=
gg(port))) {
+		ad_agg_selection_logic(aggregator);
+	}
+}
+
+/**
+ * ad_agg_selection_logic - select an aggregation group for a team
+ * @aggregator: the aggregator we're looking at
+ *
+ * It is assumed that only one aggregator may be selected for a team.
+ * The logic of this function is to select (at first time) the aggregato=
r with
+ * the most ports attached to it, and to reselect the active aggregator =
only if
+ * the previous aggregator has no more ports related to it.
+ *
+ * FIXME: this function MUST be called with the first agg in the bond, o=
r
+ * __get_active_agg() won't work correctly. This function should be bett=
er
+ * called with the bond itself, and retrieve the first agg from it.
+ */
+static void ad_agg_selection_logic(struct aggregator *aggregator)
+{
+	struct aggregator *best_aggregator =3D NULL, *active_aggregator =3D NUL=
L;
+	struct aggregator *last_active_aggregator =3D NULL, *origin_aggregator;
+	struct port *port;
+	u16 num_of_aggs=3D0;
+
+	origin_aggregator =3D aggregator;
+
+	//get current active aggregator
+	last_active_aggregator =3D __get_active_agg(aggregator);
+
+	// search for the aggregator with the most ports attached to it.
+	do {
+		// count how many candidate lag's we have
+		if (aggregator->lag_ports) {
+			num_of_aggs++;
+		}
+		if (aggregator->is_active && !aggregator->is_individual &&   // if cur=
rent aggregator is the active aggregator
+		    MAC_ADDRESS_COMPARE(&(aggregator->partner_system), &(null_mac_addr=
))) {   // and partner answers to 802.3ad PDUs
+			if (aggregator->num_of_ports) {	// if any ports attached to the curre=
nt aggregator
+				best_aggregator=3DNULL;	 // disregard the best aggregator that was c=
hosen by now
+				break;		 // stop the selection of other aggregator if there are any =
ports attached to this active aggregator
+			} else { // no ports attached to this active aggregator
+				aggregator->is_active =3D 0; // mark this aggregator as not active a=
nymore
+			}
+		}
+		if (aggregator->num_of_ports) {	// if any ports attached
+			if (best_aggregator) {	// if there is a candidte aggregator
+				//The reasons for choosing new best aggregator:
+				// 1. if current agg is NOT individual and the best agg chosen so fa=
r is individual OR
+				// current and best aggs are both individual or both not individual,=
 AND
+				// 2a.  current agg partner reply but best agg partner do not reply =
OR
+				// 2b.  current agg partner reply OR current agg partner do not repl=
y AND best agg partner also do not reply AND
+				//      current has more ports/bandwidth, or same amount of ports bu=
t current has faster ports, THEN
+				//      current agg become best agg so far
+
+				//if current agg is NOT individual and the best agg chosen so far is=
 individual change best_aggregator
+				if (!aggregator->is_individual && best_aggregator->is_individual) {
+					best_aggregator=3Daggregator;
+				}
+				// current and best aggs are both individual or both not individual
+				else if ((aggregator->is_individual && best_aggregator->is_individua=
l) ||
+					 (!aggregator->is_individual && !best_aggregator->is_individual)) {
+					//  current and best aggs are both individual or both not individua=
l AND
+					//  current agg partner reply but best agg partner do not reply
+					if ((MAC_ADDRESS_COMPARE(&(aggregator->partner_system), &(null_mac_=
addr)) &&
+					     !MAC_ADDRESS_COMPARE(&(best_aggregator->partner_system), &(nul=
l_mac_addr)))) {
+						best_aggregator=3Daggregator;
+					}
+					//  current agg partner reply OR current agg partner do not reply A=
ND best agg partner also do not reply
+					else if (! (!MAC_ADDRESS_COMPARE(&(aggregator->partner_system), &(n=
ull_mac_addr)) &&
+						    MAC_ADDRESS_COMPARE(&(best_aggregator->partner_system), &(null=
_mac_addr)))) {
+						if ((__get_agg_selection_mode(aggregator->lag_ports) =3D=3D AD_BAN=
DWIDTH)&&
+						    (__get_agg_bandwidth(aggregator) > __get_agg_bandwidth(best_ag=
gregator))) {
+							best_aggregator=3Daggregator;
+						} else if (__get_agg_selection_mode(aggregator->lag_ports) =3D=3D =
AD_COUNT) {
+							if (((aggregator->num_of_ports > best_aggregator->num_of_ports) &=
&
+							     (aggregator->actor_oper_aggregator_key & AD_SPEED_KEY_BITS))=
||
+							    ((aggregator->num_of_ports =3D=3D best_aggregator->num_of_por=
ts) &&
+							     ((u16)(aggregator->actor_oper_aggregator_key & AD_SPEED_KEY_=
BITS) >
+							      (u16)(best_aggregator->actor_oper_aggregator_key & AD_SPEED=
_KEY_BITS)))) {
+								best_aggregator=3Daggregator;
+							}
+						}
+					}
+				}
+			} else {
+				best_aggregator=3Daggregator;
+			}
+		}
+		aggregator->is_active =3D 0; // mark all aggregators as not active any=
more
+	} while ((aggregator =3D __get_next_agg(aggregator)));
+
+	// if we have new aggregator selected, don't replace the old aggregator=
 if it has an answering partner,
+	// or if both old aggregator and new aggregator don't have answering pa=
rtner
+	if (best_aggregator) {
+		if (last_active_aggregator && last_active_aggregator->lag_ports && las=
t_active_aggregator->lag_ports->is_enabled &&
+		    (MAC_ADDRESS_COMPARE(&(last_active_aggregator->partner_system), &(=
null_mac_addr)) ||   // partner answers OR
+		     (!MAC_ADDRESS_COMPARE(&(last_active_aggregator->partner_system), =
&(null_mac_addr)) &&	// both old and new
+		      !MAC_ADDRESS_COMPARE(&(best_aggregator->partner_system), &(null_=
mac_addr))))     // partner do not answer
+		   ) {
+			// if new aggregator has link, and old aggregator does not, replace o=
ld aggregator.(do nothing)
+			// -> don't replace otherwise.
+			if (!(!last_active_aggregator->actor_oper_aggregator_key && best_aggr=
egator->actor_oper_aggregator_key)) {
+				best_aggregator=3DNULL;
+				last_active_aggregator->is_active =3D 1; // don't replace good old a=
ggregator
+
+			}
+		}
+	}
+
+	// if there is new best aggregator, activate it
+	if (best_aggregator) {
+		for (aggregator =3D __get_first_agg(best_aggregator->lag_ports);
+		    aggregator;
+		    aggregator =3D __get_next_agg(aggregator)) {
+
+			BOND_PRINT_DBG(("Agg=3D%d; Ports=3D%d; a key=3D%d; p key=3D%d; Indiv=3D=
%d; Active=3D%d",
+					aggregator->aggregator_identifier, aggregator->num_of_ports,
+					aggregator->actor_oper_aggregator_key, aggregator->partner_oper_agg=
regator_key,
+					aggregator->is_individual, aggregator->is_active));
+		}
+
+		// check if any partner replys
+		if (best_aggregator->is_individual) {
+			printk(KERN_WARNING "bonding: Warning: No 802.3ad response from the l=
ink partner "
+					"for any adapters in the bond\n");
+		}
+
+		// check if there are more than one aggregator
+		if (num_of_aggs > 1) {
+			BOND_PRINT_DBG(("Warning: More than one Link Aggregation Group was "
+					"found in the bond. Only one group will function in the bond"));
+		}
+
+		best_aggregator->is_active =3D 1;
+		BOND_PRINT_DBG(("LAG %d choosed as the active LAG", best_aggregator->a=
ggregator_identifier));
+		BOND_PRINT_DBG(("Agg=3D%d; Ports=3D%d; a key=3D%d; p key=3D%d; Indiv=3D=
%d; Active=3D%d",
+				best_aggregator->aggregator_identifier, best_aggregator->num_of_port=
s,
+				best_aggregator->actor_oper_aggregator_key, best_aggregator->partner=
_oper_aggregator_key,
+				best_aggregator->is_individual, best_aggregator->is_active));
+
+		// disable the ports that were related to the former active_aggregator
+		if (last_active_aggregator) {
+			for (port=3Dlast_active_aggregator->lag_ports; port; port=3Dport->nex=
t_port_in_aggregator) {
+				__disable_port(port);
+			}
+		}
+	}
+
+	// if the selected aggregator is of join individuals(partner_system is =
NULL), enable their ports
+	active_aggregator =3D __get_active_agg(origin_aggregator);
+
+	if (active_aggregator) {
+		if (!MAC_ADDRESS_COMPARE(&(active_aggregator->partner_system), &(null_=
mac_addr))) {
+			for (port=3Dactive_aggregator->lag_ports; port; port=3Dport->next_por=
t_in_aggregator) {
+				__enable_port(port);
+			}
+		}
+	}
+}
+
+/**
+ * ad_clear_agg - clear a given aggregator's parameters
+ * @aggregator: the aggregator we're looking at
+ *
+ */
+static void ad_clear_agg(struct aggregator *aggregator)
+{
+	if (aggregator) {
+		aggregator->is_individual =3D 0;
+		aggregator->actor_admin_aggregator_key =3D 0;
+		aggregator->actor_oper_aggregator_key =3D 0;
+		aggregator->partner_system =3D null_mac_addr;
+		aggregator->partner_system_priority =3D 0;
+		aggregator->partner_oper_aggregator_key =3D 0;
+		aggregator->receive_state =3D 0;
+		aggregator->transmit_state =3D 0;
+		aggregator->lag_ports =3D NULL;
+		aggregator->is_active =3D 0;
+		aggregator->num_of_ports =3D 0;
+		BOND_PRINT_DBG(("LAG %d was cleared", aggregator->aggregator_identifie=
r));
+	}
+}
+
+/**
+ * ad_initialize_agg - initialize a given aggregator's parameters
+ * @aggregator: the aggregator we're looking at
+ *
+ */
+static void ad_initialize_agg(struct aggregator *aggregator)
+{
+	if (aggregator) {
+		ad_clear_agg(aggregator);
+
+		aggregator->aggregator_mac_address =3D null_mac_addr;
+		aggregator->aggregator_identifier =3D 0;
+		aggregator->slave =3D NULL;
+	}
+}
+
+/**
+ * ad_initialize_port - initialize a given port's parameters
+ * @aggregator: the aggregator we're looking at
+ *
+ */
+static void ad_initialize_port(struct port *port)
+{
+	if (port) {
+		port->actor_port_number =3D 1;
+		port->actor_port_priority =3D 0xff;
+		port->actor_system =3D null_mac_addr;
+		port->actor_system_priority =3D 0xffff;
+		port->actor_port_aggregator_identifier =3D 0;
+		port->ntt =3D 0;
+		port->actor_admin_port_key =3D 1;
+		port->actor_oper_port_key  =3D 1;
+		port->actor_admin_port_state =3D AD_STATE_AGGREGATION | AD_STATE_LACP_=
ACTIVITY;
+		port->actor_oper_port_state  =3D AD_STATE_AGGREGATION | AD_STATE_LACP_=
ACTIVITY;
+		port->partner_admin_system =3D null_mac_addr;
+		port->partner_oper_system  =3D null_mac_addr;
+		port->partner_admin_system_priority =3D 0xffff;
+		port->partner_oper_system_priority  =3D 0xffff;
+		port->partner_admin_key =3D 1;
+		port->partner_oper_key  =3D 1;
+		port->partner_admin_port_number =3D 1;
+		port->partner_oper_port_number  =3D 1;
+		port->partner_admin_port_priority =3D 0xff;
+		port->partner_oper_port_priority  =3D 0xff;
+		port->partner_admin_port_state =3D 1;
+		port->partner_oper_port_state  =3D 1;
+		port->is_enabled =3D 1;
+		// ****** private parameters ******
+		port->sm_vars =3D 0x3;
+		port->sm_rx_state =3D 0;
+		port->sm_rx_timer_counter =3D 0;
+		port->sm_periodic_state =3D 0;
+		port->sm_periodic_timer_counter =3D 0;
+		port->sm_mux_state =3D 0;
+		port->sm_mux_timer_counter =3D 0;
+		port->sm_tx_state =3D 0;
+		port->sm_tx_timer_counter =3D 0;
+		port->slave =3D NULL;
+		port->aggregator =3D NULL;
+		port->next_port_in_aggregator =3D NULL;
+		port->transaction_id =3D 0;
+
+		ad_initialize_lacpdu(&(port->lacpdu));
+	}
+}
+
+/**
+ * ad_enable_collecting_distributing - enable a port's transmit/receive
+ * @port: the port we're looking at
+ *
+ * Enable @port if it's in an active aggregator
+ */
+static void ad_enable_collecting_distributing(struct port *port)
+{
+	if (port->aggregator->is_active) {
+		BOND_PRINT_DBG(("Enabling port %d(LAG %d)", port->actor_port_number, p=
ort->aggregator->aggregator_identifier));
+		__enable_port(port);
+	}
+}
+
+/**
+ * ad_disable_collecting_distributing - disable a port's transmit/receiv=
e
+ * @port: the port we're looking at
+ *
+ */
+static void ad_disable_collecting_distributing(struct port *port)
+{
+	if (port->aggregator && MAC_ADDRESS_COMPARE(&(port->aggregator->partner=
_system), &(null_mac_addr))) {
+		BOND_PRINT_DBG(("Disabling port %d(LAG %d)", port->actor_port_number, =
port->aggregator->aggregator_identifier));
+		__disable_port(port);
+	}
+}
+
+#if 0
+/**
+ * ad_marker_info_send - send a marker information frame
+ * @port: the port we're looking at
+ *
+ * This function does nothing since we decided not to implement send and=
 handle
+ * response for marker PDU's, in this stage, but only to respond to mark=
er
+ * information.
+ */
+static void ad_marker_info_send(struct port *port)
+{
+	struct marker marker;
+	u16 index;
+
+	// fill the marker PDU with the appropriate values
+	marker.subtype =3D 0x02;
+	marker.version_number =3D 0x01;
+	marker.tlv_type =3D AD_MARKER_INFORMATION_SUBTYPE;
+	marker.marker_length =3D 0x16;
+	// convert requester_port to Big Endian
+	marker.requester_port =3D (((port->actor_port_number & 0xFF) << 8) |((u=
16)(port->actor_port_number & 0xFF00) >> 8));
+	marker.requester_system =3D port->actor_system;
+	// convert requester_port(u32) to Big Endian
+	marker.requester_transaction_id =3D (((++port->transaction_id & 0xFF) <=
< 24) |((port->transaction_id & 0xFF00) << 8) |((port->transaction_id & 0=
xFF0000) >> 8) |((port->transaction_id & 0xFF000000) >> 24));
+	marker.pad =3D 0;
+	marker.tlv_type_terminator =3D 0x00;
+	marker.terminator_length =3D 0x00;
+	for (index=3D0; index<90; index++) {
+		marker.reserved_90[index]=3D0;
+	}
+
+	// send the marker information
+	if (ad_marker_send(port, &marker) >=3D 0) {
+		BOND_PRINT_DBG(("Sent Marker Information on port %d", port->actor_port=
_number));
+	}
+}
+#endif
+
+/**
+ * ad_marker_info_received - handle receive of a Marker information fram=
e
+ * @marker_info: Marker info received
+ * @port: the port we're looking at
+ *
+ */
+static void ad_marker_info_received(struct marker *marker_info,struct po=
rt *port)
+{
+	struct marker marker;
+
+	// copy the received marker data to the response marker
+	//marker =3D *marker_info;
+	memcpy(&marker, marker_info, sizeof(struct marker));
+	// change the marker subtype to marker response
+	marker.tlv_type=3DAD_MARKER_RESPONSE_SUBTYPE;
+	// send the marker response
+
+	if (ad_marker_send(port, &marker) >=3D 0) {
+		BOND_PRINT_DBG(("Sent Marker Response on port %d", port->actor_port_nu=
mber));
+	}
+}
+
+/**
+ * ad_marker_response_received - handle receive of a marker response fra=
me
+ * @marker: marker PDU received
+ * @port: the port we're looking at
+ *
+ * This function does nothing since we decided not to implement send and=
 handle
+ * response for marker PDU's, in this stage, but only to respond to mark=
er
+ * information.
+ */
+static void ad_marker_response_received(struct marker *marker, struct po=
rt *port)
+{
+	marker=3DNULL; // just to satisfy the compiler
+	port=3DNULL;  // just to satisfy the compiler
+	// DO NOTHING, SINCE WE DECIDED NOT TO IMPLEMENT THIS FEATURE FOR NOW
+}
+
+/**
+ * ad_initialize_lacpdu - initialize a given lacpdu structure
+ * @lacpdu: lacpdu structure to initialize
+ *
+ */
+static void ad_initialize_lacpdu(struct lacpdu *lacpdu)
+{
+	u16 index;
+
+	// initialize lacpdu data
+	lacpdu->subtype =3D 0x01;
+	lacpdu->version_number =3D 0x01;
+	lacpdu->tlv_type_actor_info =3D 0x01;
+	lacpdu->actor_information_length =3D 0x14;
+	// lacpdu->actor_system_priority    updated on send
+	// lacpdu->actor_system             updated on send
+	// lacpdu->actor_key                updated on send
+	// lacpdu->actor_port_priority      updated on send
+	// lacpdu->actor_port               updated on send
+	// lacpdu->actor_state              updated on send
+	lacpdu->tlv_type_partner_info =3D 0x02;
+	lacpdu->partner_information_length =3D 0x14;
+	for (index=3D0; index<=3D2; index++) {
+		lacpdu->reserved_3_1[index]=3D0;
+	}
+	// lacpdu->partner_system_priority  updated on send
+	// lacpdu->partner_system           updated on send
+	// lacpdu->partner_key              updated on send
+	// lacpdu->partner_port_priority    updated on send
+	// lacpdu->partner_port             updated on send
+	// lacpdu->partner_state            updated on send
+	for (index=3D0; index<=3D2; index++) {
+		lacpdu->reserved_3_2[index]=3D0;
+	}
+	lacpdu->tlv_type_collector_info =3D 0x03;
+	lacpdu->collector_information_length=3D 0x10;
+	lacpdu->collector_max_delay =3D AD_COLLECTOR_MAX_DELAY;
+	for (index=3D0; index<=3D11; index++) {
+		lacpdu->reserved_12[index]=3D0;
+	}
+	lacpdu->tlv_type_terminator =3D 0x00;
+	lacpdu->terminator_length =3D 0;
+	for (index=3D0; index<=3D49; index++) {
+		lacpdu->reserved_50[index]=3D0;
+	}
+}
+
+////////////////////////////////////////////////////////////////////////=
//////////////
+// =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D AD exported funct=
ions to the main bonding code =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
+////////////////////////////////////////////////////////////////////////=
//////////////
+
+// Check aggregators status in team every T seconds
+#define AD_AGGREGATOR_SELECTION_TIMER  8
+
+static u16 aggregator_identifier;
+
+/**
+ * bond_3ad_initialize - initialize a bond's 802.3ad parameters and stru=
ctures
+ * @bond: bonding struct to work on
+ * @tick_resolution: tick duration (millisecond resolution)
+ *
+ * Can be called only after the mac address of the bond is set.
+ */
+void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution)
+{                        =20
+	// check that the bond is not initialized yet
+	if (MAC_ADDRESS_COMPARE(&(BOND_AD_INFO(bond).system.sys_mac_addr), &(bo=
nd->device->dev_addr))) {
+
+		aggregator_identifier =3D 0;
+
+		BOND_AD_INFO(bond).system.sys_priority =3D 0xFFFF;
+		BOND_AD_INFO(bond).system.sys_mac_addr =3D *((struct mac_addr *)bond->=
device->dev_addr);
+
+		// initialize how many times this module is called in one second(shoul=
d be about every 100ms)
+		ad_ticks_per_sec =3D tick_resolution;
+
+		// initialize the aggregator selection timer(to activate an aggregatio=
n selection after initialize)
+		BOND_AD_INFO(bond).agg_select_timer =3D (AD_AGGREGATOR_SELECTION_TIMER=
 * ad_ticks_per_sec);
+		BOND_AD_INFO(bond).agg_select_mode =3D AD_BANDWIDTH;
+	}
+}
+
+/**
+ * bond_3ad_bind_slave - initialize a slave's port
+ * @slave: slave struct to work on
+ *
+ * Returns:   0 on success
+ *          < 0 on error
+ */
+int bond_3ad_bind_slave(struct slave *slave)
+{
+	struct bonding *bond =3D bond_get_bond_by_slave(slave);
+	struct port *port;
+	struct aggregator *aggregator;
+
+	if (bond =3D=3D NULL) {
+		printk(KERN_CRIT "The slave %s is not attached to its bond\n", slave->=
dev->name);
+		return -1;
+	}
+
+	//check that the slave has not been intialized yet.
+	if (SLAVE_AD_INFO(slave).port.slave !=3D slave) {
+
+		// port initialization
+		port =3D &(SLAVE_AD_INFO(slave).port);
+
+		ad_initialize_port(port);
+
+		port->slave =3D slave;
+		port->actor_port_number =3D SLAVE_AD_INFO(slave).id;
+		// key is determined according to the link speed, duplex and user key(=
which is yet not supported)
+		//              ------------------------------------------------------=
------
+		// Port key :   | User key                       |      Speed       |D=
uplex|
+		//              ------------------------------------------------------=
------
+		//              16                               6               1 0
+		port->actor_admin_port_key =3D 0;	// initialize this parameter
+		port->actor_admin_port_key |=3D __get_duplex(port);
+		port->actor_admin_port_key |=3D (__get_link_speed(port) << 1);
+		port->actor_oper_port_key =3D port->actor_admin_port_key;
+		// if the port is not full duplex, then the port should be not lacp En=
abled
+		if (!(port->actor_oper_port_key & AD_DUPLEX_KEY_BITS)) {
+			port->sm_vars &=3D ~AD_PORT_LACP_ENABLED;
+		}
+		// actor system is the bond's system
+		port->actor_system =3D BOND_AD_INFO(bond).system.sys_mac_addr;
+		// tx timer(to verify that no more than MAX_TX_IN_SECOND lacpdu's are =
sent in one second)
+		port->sm_tx_timer_counter =3D ad_ticks_per_sec/AD_MAX_TX_IN_SECOND;
+		port->aggregator =3D NULL;
+		port->next_port_in_aggregator =3D NULL;
+
+		__disable_port(port);
+		__initialize_port_locks(port);
+
+
+		// aggregator initialization
+		aggregator =3D &(SLAVE_AD_INFO(slave).aggregator);
+
+		ad_initialize_agg(aggregator);
+
+		aggregator->aggregator_mac_address =3D *((struct mac_addr *)bond->devi=
ce->dev_addr);
+		aggregator->aggregator_identifier =3D (++aggregator_identifier);
+		aggregator->slave =3D slave;
+		aggregator->is_active =3D 0;
+		aggregator->num_of_ports =3D 0;
+	}
+
+	return 0;
+}
+
+/**
+ * bond_3ad_unbind_slave - deinitialize a slave's port
+ * @slave: slave struct to work on
+ *
+ * Search for the aggregator that is related to this port, remove the
+ * aggregator and assign another aggregator for other port related to it
+ * (if any), and remove the port.
+ */
+void bond_3ad_unbind_slave(struct slave *slave)
+{
+	struct port *port, *prev_port, *temp_port;
+	struct aggregator *aggregator, *new_aggregator, *temp_aggregator;
+	int select_new_active_agg =3D 0;
+=09
+	// find the aggregator related to this slave
+	aggregator =3D &(SLAVE_AD_INFO(slave).aggregator);
+
+	// find the port related to this slave
+	port =3D &(SLAVE_AD_INFO(slave).port);
+
+	// if slave is null, the whole port is not initialized
+	if (!port->slave) {
+		printk(KERN_WARNING "bonding: Trying to unbind an uninitialized port o=
n %s\n", slave->dev->name);
+		return;
+	}
+
+	bond_3ad_link_status_changed(slave, 0);
+
+	// disable the port
+	ad_disable_collecting_distributing(port);
+
+	// deinitialize port's locks if necessary(os-specific)
+	__deinitialize_port_locks(port);
+
+	BOND_PRINT_DBG(("Unbinding Link Aggregation Group %d", aggregator->aggr=
egator_identifier));
+	// check if this aggregator is occupied
+	if (aggregator->lag_ports) {
+		// check if there are other ports related to this aggregator except
+		// the port related to this slave(thats ensure us that there is a
+		// reason to search for new aggregator, and that we will find one
+		if ((aggregator->lag_ports !=3D port) || (aggregator->lag_ports->next_=
port_in_aggregator)) {
+			// find new aggregator for the related port(s)
+			new_aggregator =3D __get_first_agg(port);
+			for (; new_aggregator; new_aggregator =3D __get_next_agg(new_aggregat=
or)) {
+				// if the new aggregator is empty, or it connected to to our port on=
ly
+				if (!new_aggregator->lag_ports || ((new_aggregator->lag_ports =3D=3D=
 port) && !new_aggregator->lag_ports->next_port_in_aggregator)) {
+					break;
+				}
+			}
+			// if new aggregator found, copy the aggregator's parameters
+			// and connect the related lag_ports to the new aggregator
+			if ((new_aggregator) && ((!new_aggregator->lag_ports) || ((new_aggreg=
ator->lag_ports =3D=3D port) && !new_aggregator->lag_ports->next_port_in_=
aggregator))) {
+				BOND_PRINT_DBG(("Some port(s) related to LAG %d - replaceing with LA=
G %d", aggregator->aggregator_identifier, new_aggregator->aggregator_iden=
tifier));
+
+				if ((new_aggregator->lag_ports =3D=3D port) && new_aggregator->is_ac=
tive) {
+					printk(KERN_INFO "bonding: Removing an active aggregator\n");
+					// select new active aggregator
+					 select_new_active_agg =3D 1;
+				}
+
+				new_aggregator->is_individual =3D aggregator->is_individual;
+				new_aggregator->actor_admin_aggregator_key =3D aggregator->actor_adm=
in_aggregator_key;
+				new_aggregator->actor_oper_aggregator_key =3D aggregator->actor_oper=
_aggregator_key;
+				new_aggregator->partner_system =3D aggregator->partner_system;
+				new_aggregator->partner_system_priority =3D aggregator->partner_syst=
em_priority;
+				new_aggregator->partner_oper_aggregator_key =3D aggregator->partner_=
oper_aggregator_key;
+				new_aggregator->receive_state =3D aggregator->receive_state;
+				new_aggregator->transmit_state =3D aggregator->transmit_state;
+				new_aggregator->lag_ports =3D aggregator->lag_ports;
+				new_aggregator->is_active =3D aggregator->is_active;
+				new_aggregator->num_of_ports =3D aggregator->num_of_ports;
+
+				// update the information that is written on the ports about the agg=
regator
+				for (temp_port=3Daggregator->lag_ports; temp_port; temp_port=3Dtemp_=
port->next_port_in_aggregator) {
+					temp_port->aggregator=3Dnew_aggregator;
+					temp_port->actor_port_aggregator_identifier =3D new_aggregator->agg=
regator_identifier;
+				}
+
+				// clear the aggregator
+				ad_clear_agg(aggregator);
+			=09
+				if (select_new_active_agg) {
+					ad_agg_selection_logic(__get_first_agg(port));
+				}
+			} else {
+				printk(KERN_WARNING "bonding: Warning: unbinding aggregator, "
+				       "and could not find a new aggregator for its ports\n");
+			}
+		} else { // in case that the only port related to this aggregator is t=
he one we want to remove
+			select_new_active_agg =3D aggregator->is_active;
+			// clear the aggregator
+			ad_clear_agg(aggregator);
+			if (select_new_active_agg) {
+				printk(KERN_INFO "Removing an active aggregator\n");
+				// select new active aggregator
+				ad_agg_selection_logic(__get_first_agg(port));
+			}
+		}
+	}
+
+	BOND_PRINT_DBG(("Unbinding port %d", port->actor_port_number));
+	// find the aggregator that this port is connected to
+	temp_aggregator =3D __get_first_agg(port);
+	for (; temp_aggregator; temp_aggregator =3D __get_next_agg(temp_aggrega=
tor)) {
+		prev_port =3D NULL;
+		// search the port in the aggregator's related ports
+		for (temp_port=3Dtemp_aggregator->lag_ports; temp_port; prev_port=3Dte=
mp_port, temp_port=3Dtemp_port->next_port_in_aggregator) {
+			if (temp_port =3D=3D port) { // the aggregator found - detach the por=
t from this aggregator
+				if (prev_port) {
+					prev_port->next_port_in_aggregator =3D temp_port->next_port_in_aggr=
egator;
+				} else {
+					temp_aggregator->lag_ports =3D temp_port->next_port_in_aggregator;
+				}
+				temp_aggregator->num_of_ports--;
+				if (temp_aggregator->num_of_ports=3D=3D0) {
+					select_new_active_agg =3D temp_aggregator->is_active;
+					// clear the aggregator
+					ad_clear_agg(temp_aggregator);
+					if (select_new_active_agg) {
+						printk(KERN_INFO "Removing an active aggregator\n");
+						// select new active aggregator
+						ad_agg_selection_logic(__get_first_agg(port));
+					}
+				}
+				break;
+			}
+		}
+	}
+	port->slave=3DNULL;=09
+}
+
+/**
+ * bond_3ad_state_machine_handler - handle state machines timeout
+ * @bond: bonding struct to work on
+ *
+ * The state machine handling concept in this module is to check every t=
ick
+ * which state machine should operate any function. The execution order =
is
+ * round robin, so when we have an interaction between state machines, t=
he
+ * reply of one to each other might be delayed until next tick.
+ *
+ * This function also complete the initialization when the agg_select_ti=
mer
+ * times out, and it selects an aggregator for the ports that are yet no=
t
+ * related to any aggregator, and selects the active aggregator for a bo=
nd.
+ */
+void bond_3ad_state_machine_handler(struct bonding *bond)
+{
+	struct port *port;
+	struct aggregator *aggregator;
+	unsigned long flags;
+
+	read_lock_irqsave(&bond->lock, flags);
+
+	//check if there are any slaves
+	if (bond->next =3D=3D (struct slave *)bond) {
+		goto end;
+	}
+
+	if ((bond->device->flags & IFF_UP) !=3D IFF_UP) {
+		goto end;
+	}
+
+	// check if agg_select_timer timer after initialize is timed out
+	if (BOND_AD_INFO(bond).agg_select_timer && !(--BOND_AD_INFO(bond).agg_s=
elect_timer)) {
+		// select the active aggregator for the bond
+		if ((port =3D __get_first_port(bond))) {
+			if (!port->slave) {
+				printk(KERN_WARNING "bonding: Warning: bond's first port is uninitia=
lized\n");
+				goto end;
+			}
+
+			aggregator =3D __get_first_agg(port);
+			ad_agg_selection_logic(aggregator);
+		}
+	}
+
+	// for each port run the state machines
+	for (port =3D __get_first_port(bond); port; port =3D __get_next_port(po=
rt)) {
+		if (!port->slave) {
+			printk(KERN_WARNING "bonding: Warning: Found an uninitialized port\n"=
);
+			goto end;
+		}
+
+		ad_rx_machine(NULL, port);
+		ad_periodic_machine(port);
+		ad_port_selection_logic(port);
+		ad_mux_machine(port);
+		ad_tx_machine(port);
+
+		// turn off the BEGIN bit, since we already handled it
+		if (port->sm_vars & AD_PORT_BEGIN) {
+			port->sm_vars &=3D ~AD_PORT_BEGIN;
+		}
+	}
+
+end:
+	read_unlock_irqrestore(&bond->lock, flags);
+
+
+	if ((bond->device->flags & IFF_UP) =3D=3D IFF_UP) {
+		/* re-arm the timer */
+		mod_timer(&(BOND_AD_INFO(bond).ad_timer), jiffies + (AD_TIMER_INTERVAL=
 * HZ / 1000));
+	}
+}
+
+/**
+ * bond_3ad_rx_indication - handle a received frame
+ * @lacpdu: received lacpdu
+ * @slave: slave struct to work on
+ * @length: length of the data received
+ *
+ * It is assumed that frames that were sent on this NIC don't returned a=
s new
+ * received frames (loopback). Since only the payload is given to this
+ * function, it check for loopback.
+ */
+void bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, =
u16 length)
+{
+	struct port *port;
+
+	if (length >=3D sizeof(struct lacpdu)) {
+
+		port =3D &(SLAVE_AD_INFO(slave).port);
+
+		if (!port->slave) {
+			printk(KERN_WARNING "bonding: Warning: port of slave %s is uninitiali=
zed\n", slave->dev->name);
+			return;
+		}
+
+		switch (lacpdu->subtype) {
+		case AD_TYPE_LACPDU:
+			__ntohs_lacpdu(lacpdu);
+			BOND_PRINT_DBG(("Received LACPDU on port %d", port->actor_port_number=
));
+			ad_rx_machine(lacpdu, port);
+			break;
+
+		case AD_TYPE_MARKER:
+			// No need to convert fields to Little Endian since we don't use the =
marker's fields.
+
+			switch (((struct marker *)lacpdu)->tlv_type) {
+			case AD_MARKER_INFORMATION_SUBTYPE:
+				BOND_PRINT_DBG(("Received Marker Information on port %d", port->acto=
r_port_number));
+				ad_marker_info_received((struct marker *)lacpdu, port);
+				break;
+
+			case AD_MARKER_RESPONSE_SUBTYPE:
+				BOND_PRINT_DBG(("Received Marker Response on port %d", port->actor_p=
ort_number));
+				ad_marker_response_received((struct marker *)lacpdu, port);
+				break;
+
+			default:
+				BOND_PRINT_DBG(("Received an unknown Marker subtype on slot %d", por=
t->actor_port_number));
+			}
+		}
+	}
+}
+
+/**
+ * bond_3ad_adapter_speed_changed - handle a slave's speed change indica=
tion
+ * @slave: slave struct to work on
+ *
+ * Handle reselection of aggregator (if needed) for this port.
+ */
+void bond_3ad_adapter_speed_changed(struct slave *slave)
+{
+	struct port *port;
+
+	port =3D &(SLAVE_AD_INFO(slave).port);
+
+	// if slave is null, the whole port is not initialized
+	if (!port->slave) {
+		printk(KERN_WARNING "bonding: Warning: speed changed for uninitialized=
 port on %s\n",
+		       slave->dev->name);
+		return;
+	}
+
+	port->actor_admin_port_key &=3D ~AD_SPEED_KEY_BITS;
+	port->actor_oper_port_key=3Dport->actor_admin_port_key |=3D (__get_link=
_speed(port) << 1);
+	BOND_PRINT_DBG(("Port %d changed speed", port->actor_port_number));
+	// there is no need to reselect a new aggregator, just signal the
+	// state machines to reinitialize
+	port->sm_vars |=3D AD_PORT_BEGIN;
+}
+
+/**
+ * bond_3ad_adapter_duplex_changed - handle a slave's duplex change indi=
cation
+ * @slave: slave struct to work on
+ *
+ * Handle reselection of aggregator (if needed) for this port.
+ */
+void bond_3ad_adapter_duplex_changed(struct slave *slave)
+{
+	struct port *port;
+
+	port=3D&(SLAVE_AD_INFO(slave).port);
+
+	// if slave is null, the whole port is not initialized
+	if (!port->slave) {
+		printk(KERN_WARNING "bonding: Warning: duplex changed for uninitialize=
d port on %s\n",
+		       slave->dev->name);
+		return;
+	}
+
+	port->actor_admin_port_key &=3D ~AD_DUPLEX_KEY_BITS;
+	port->actor_oper_port_key=3Dport->actor_admin_port_key |=3D __get_duple=
x(port);
+	BOND_PRINT_DBG(("Port %d changed duplex", port->actor_port_number));
+	// there is no need to reselect a new aggregator, just signal the
+	// state machines to reinitialize
+	port->sm_vars |=3D AD_PORT_BEGIN;
+}
+
+/**
+ * bond_3ad_link_status_changed - handle a slave's link status change in=
dication
+ * @slave: slave struct to work on
+ * @status: whether the link is now up or down
+ *
+ * Handle reselection of aggregator (if needed) for this port.
+ */
+void bond_3ad_link_status_changed(struct slave *slave, int status)
+{
+	struct port *port;
+
+	port =3D &(SLAVE_AD_INFO(slave).port);
+
+	// if slave is null, the whole port is not initialized
+	if (!port->slave) {
+		printk(KERN_WARNING "bonding: Warning: link status changed for uniniti=
alized port on %s\n",
+		       slave->dev->name);
+		return;
+	}
+
+	// on link down we are zeroing duplex and speed since some of the adapt=
ors(ce1000.lan) report full duplex/speed instead of N/A(duplex) / 0(speed=
)
+	// on link up we are forcing recheck on the duplex and speed since some=
 of he adaptors(ce1000.lan) report
+	if (status) { // is up
+		port->is_enabled =3D 1;
+		port->actor_admin_port_key &=3D ~AD_DUPLEX_KEY_BITS;
+		port->actor_oper_port_key=3Dport->actor_admin_port_key |=3D __get_dupl=
ex(port);
+		port->actor_admin_port_key &=3D ~AD_SPEED_KEY_BITS;
+		port->actor_oper_port_key=3Dport->actor_admin_port_key |=3D (__get_lin=
k_speed(port) << 1);
+	} else {
+		port->is_enabled =3D 0;
+		port->actor_admin_port_key &=3D ~AD_DUPLEX_KEY_BITS;
+		port->actor_oper_port_key=3D (port->actor_admin_port_key &=3D ~AD_SPEE=
D_KEY_BITS);
+	}
+	BOND_PRINT_DBG(("Port %d changed link status to %s", port->actor_port_n=
umber, (status?"UP":"DOWN")));
+	// there is no need to reselect a new aggregator, just signal the
+	// state machines to reinitialize
+	port->sm_vars |=3D AD_PORT_BEGIN;
+}
+
+/**
+ * bond_3ad_get_active_agg_info - get information of the active aggregat=
or
+ * @bond: bonding struct to work on
+ * @ad_info: ad_info struct to fill with the bond's info
+ *
+ * Returns:   0 on success
+ *          < 0 on error
+ */
+int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *a=
d_info)
+{
+	struct aggregator *aggregator =3D NULL;
+	struct port *port;
+
+	for (port =3D __get_first_port(bond); port; port =3D __get_next_port(po=
rt)) {
+		if (port->aggregator && port->aggregator->is_active) {
+			aggregator =3D port->aggregator;
+			break;
+		}
+	}
+
+	if (aggregator) {
+		ad_info->aggregator_id =3D aggregator->aggregator_identifier;
+		ad_info->ports =3D aggregator->num_of_ports;
+		ad_info->actor_key =3D aggregator->actor_oper_aggregator_key;
+		ad_info->partner_key =3D aggregator->partner_oper_aggregator_key;
+		memcpy(ad_info->partner_system, aggregator->partner_system.mac_addr_va=
lue, ETH_ALEN);
+		return 0;
+	}
+
+	return -1;
+}
+
+int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
+{
+	slave_t *slave, *start_at;
+	struct bonding *bond =3D (struct bonding *) dev->priv;
+	unsigned long flags;
+	struct ethhdr *data =3D (struct ethhdr *)skb->data;
+	int slave_agg_no;
+	int slaves_in_agg;
+	int agg_id;
+	struct ad_info ad_info;
+
+	if (!IS_UP(dev)) { /* bond down */
+		dev_kfree_skb(skb);
+		return 0;
+	}
+
+	if (bond =3D=3D NULL) {
+		printk(KERN_CRIT "bonding: Error: bond is NULL on device %s\n", dev->n=
ame);
+		dev_kfree_skb(skb);
+		return 0;
+	}
+
+	read_lock_irqsave(&bond->lock, flags);
+	slave =3D bond->prev;
+
+	/* check if bond is empty */
+	if ((slave =3D=3D (struct slave *) bond) || (bond->slave_cnt =3D=3D 0))=
 {
+		printk(KERN_DEBUG "ERROR: bond is empty\n");
+		dev_kfree_skb(skb);
+		read_unlock_irqrestore(&bond->lock, flags);
+		return 0;
+	}
+
+	if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
+		printk(KERN_DEBUG "ERROR: bond_3ad_get_active_agg_info failed\n");
+		dev_kfree_skb(skb);
+		read_unlock_irqrestore(&bond->lock, flags);
+		return 0;
+	}
+
+	slaves_in_agg =3D ad_info.ports;
+	agg_id =3D ad_info.aggregator_id;
+
+	if (slaves_in_agg =3D=3D 0) {
+		/*the aggregator is empty*/
+		printk(KERN_DEBUG "ERROR: active aggregator is empty\n");
+		dev_kfree_skb(skb);
+		read_unlock_irqrestore(&bond->lock, flags);
+		return 0;
+	}
+
+	/* we're at the root, get the first slave */
+	if ((slave =3D=3D NULL) || (slave->dev =3D=3D NULL)) {
+		/* no suitable interface, frame not sent */
+		dev_kfree_skb(skb);
+		read_unlock_irqrestore(&bond->lock, flags);
+		return 0;
+	}
+
+	slave_agg_no =3D (data->h_dest[5]^slave->dev->dev_addr[5]) % slaves_in_=
agg;
+	while (slave !=3D (slave_t *)bond) {
+		struct aggregator *agg =3D SLAVE_AD_INFO(slave).port.aggregator;
+
+		if (agg && (agg->aggregator_identifier =3D=3D agg_id)) {
+			slave_agg_no--;
+			if (slave_agg_no < 0) {
+				break;
+			}
+		}
+
+		slave =3D slave->prev;
+		if (slave =3D=3D NULL) {
+			printk(KERN_ERR "bonding: Error: slave is NULL\n");
+			dev_kfree_skb(skb);
+			read_unlock_irqrestore(&bond->lock, flags);
+			return 0;
+		}
+	}
+
+	if (slave =3D=3D (slave_t *)bond) {
+		printk(KERN_ERR "bonding: Error: Couldn't find a slave to tx on for ag=
gregator ID %d\n", agg_id);
+		dev_kfree_skb(skb);
+		read_unlock_irqrestore(&bond->lock, flags);
+		return 0;
+	}
+
+	start_at =3D slave;
+
+	do {
+		int slave_agg_id =3D 0;
+		struct aggregator *agg;
+
+		if (slave =3D=3D NULL) {
+			printk(KERN_ERR "bonding: Error: slave is NULL\n");
+			dev_kfree_skb(skb);
+			read_unlock_irqrestore(&bond->lock, flags);
+			return 0;
+		}
+
+		agg =3D SLAVE_AD_INFO(slave).port.aggregator;
+
+		if (agg) {
+			slave_agg_id =3D agg->aggregator_identifier;
+		}
+
+		if (SLAVE_IS_OK(slave) &&=20
+		    agg && (slave_agg_id =3D=3D agg_id)) {
+			skb->dev =3D slave->dev;		=09
+			skb->priority =3D 1;
+			dev_queue_xmit(skb);
+			read_unlock_irqrestore(&bond->lock, flags);
+			return 0;
+		}
+	} while ((slave =3D slave->next) !=3D start_at);
+
+	/* no suitable interface, frame not sent */
+	dev_kfree_skb(skb);
+	read_unlock_irqrestore(&bond->lock, flags);
+	return 0;
+}
+
+int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct net_device *dev, st=
ruct packet_type* ptype)
+{
+	struct bonding *bond =3D (struct bonding *)dev->priv;
+	struct slave *slave =3D NULL;
+	unsigned long flags;
+	int ret =3D NET_RX_DROP;
+
+	if (!(dev->flags & IFF_MASTER)) {
+		goto out;
+	}
+
+	read_lock_irqsave(&bond->lock, flags);
+#ifdef BOND_POINT_TO_POINT_PROT
+	slave =3D bond_get_slave_by_dev((struct bonding *) dev->priv, skb->real=
_dev);
+#else
+#warning "skb->real_dev not defined. apply bond-p2p patch for the module=
 to work !!!"
+#endif //BOND_POINT_TO_POINT_PROT
+
+	if (slave =3D=3D NULL) {
+		goto out_unlock;
+	}
+
+	bond_3ad_rx_indication((struct lacpdu *) skb->data, slave, skb->len);
+
+	ret =3D NET_RX_SUCCESS;
+
+out_unlock:
+	read_unlock_irqrestore(&bond->lock, flags);
+out:
+	dev_kfree_skb(skb);
+
+	return ret;
+}
+
diff -Nuarp linux-2.4.20-bonding-20030317/drivers/net/bonding/bond_3ad.h =
linux-2.4.20-bonding-20030317-devel/drivers/net/bonding/bond_3ad.h
--- linux-2.4.20-bonding-20030317/drivers/net/bonding/bond_3ad.h	1970-01-=
01 02:00:00.000000000 +0200
+++ linux-2.4.20-bonding-20030317-devel/drivers/net/bonding/bond_3ad.h	20=
03-03-18 17:24:25.000000000 +0200
@@ -0,0 +1,281 @@
+/***********************************************************************=
*****
+   Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
+
+   This program is free software; you can redistribute it and/or modify =
it
+   under the terms of the GNU General Public License as published by the=
 Free
+   Software Foundation; either version 2 of the License, or (at your opt=
ion)
+   any later version.
+
+   This program is distributed in the hope that it will be useful, but W=
ITHOUT
+   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License=
 for
+   more details.
+
+   You should have received a copy of the GNU General Public License alo=
ng with
+   this program; if not, write to the Free Software Foundation, Inc., 59
+   Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+
+   The full GNU General Public License is included in this distribution =
in the
+   file called LICENSE.
+************************************************************************=
*****/
+
+#ifndef __BOND_3AD_H__
+#define __BOND_3AD_H__
+
+#include <asm/byteorder.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+
+// General definitions
+#define BOND_ETH_P_LACPDU       0x8809
+#define PKT_TYPE_LACPDU         __constant_htons(BOND_ETH_P_LACPDU)
+#define AD_TIMER_INTERVAL       100 /*msec*/
+
+#define MULTICAST_LACPDU_ADDR    {0x01, 0x80, 0xC2, 0x00, 0x00, 0x02}
+#define AD_MULTICAST_LACPDU_ADDR    {MULTICAST_LACPDU_ADDR}
+
+typedef struct mac_addr {
+	u8 mac_addr_value[ETH_ALEN];
+} mac_addr_t;
+
+typedef enum {
+	AD_BANDWIDTH =3D 0,
+	AD_COUNT
+} agg_selection_t;
+
+// rx machine states(43.4.11 in the 802.3ad standard)
+typedef enum {
+	AD_RX_DUMMY,
+	AD_RX_INITIALIZE,     // rx Machine
+	AD_RX_PORT_DISABLED,  // rx Machine
+	AD_RX_LACP_DISABLED,  // rx Machine
+	AD_RX_EXPIRED,	      // rx Machine
+	AD_RX_DEFAULTED,      // rx Machine
+	AD_RX_CURRENT	      // rx Machine
+} rx_states_t;
+
+// periodic machine states(43.4.12 in the 802.3ad standard)
+typedef enum {
+	AD_PERIODIC_DUMMY,
+	AD_NO_PERIODIC,	       // periodic machine
+	AD_FAST_PERIODIC,      // periodic machine
+	AD_SLOW_PERIODIC,      // periodic machine
+	AD_PERIODIC_TX	   // periodic machine
+} periodic_states_t;
+
+// mux machine states(43.4.13 in the 802.3ad standard)
+typedef enum {
+	AD_MUX_DUMMY,
+	AD_MUX_DETACHED,       // mux machine
+	AD_MUX_WAITING,	       // mux machine
+	AD_MUX_ATTACHED,       // mux machine
+	AD_MUX_COLLECTING_DISTRIBUTING // mux machine
+} mux_states_t;
+
+// tx machine states(43.4.15 in the 802.3ad standard)
+typedef enum {
+	AD_TX_DUMMY,
+	AD_TRANSMIT	   // tx Machine
+} tx_states_t;
+
+// rx indication types
+typedef enum {
+	AD_TYPE_LACPDU =3D 1,    // type lacpdu
+	AD_TYPE_MARKER	   // type marker
+} pdu_type_t;
+
+// rx marker indication types
+typedef enum {
+	AD_MARKER_INFORMATION_SUBTYPE =3D 1, // marker imformation subtype
+	AD_MARKER_RESPONSE_SUBTYPE     // marker response subtype
+} marker_subtype_t;
+
+// timers types(43.4.9 in the 802.3ad standard)
+typedef enum {
+	AD_CURRENT_WHILE_TIMER,
+	AD_ACTOR_CHURN_TIMER,
+	AD_PERIODIC_TIMER,
+	AD_PARTNER_CHURN_TIMER,
+	AD_WAIT_WHILE_TIMER
+} ad_timers_t;
+
+#pragma pack(1)
+
+typedef struct ad_header {
+	struct mac_addr destination_address;
+	struct mac_addr source_address;
+	u16 length_type;
+} ad_header_t;
+
+// Link Aggregation Control Protocol(LACP) data unit structure(43.4.2.2 =
in the 802.3ad standard)
+typedef struct lacpdu {
+	u8 subtype;		     // =3D LACP(=3D 0x01)
+	u8 version_number;
+	u8 tlv_type_actor_info;	      // =3D actor information(type/length/valu=
e)
+	u8 actor_information_length; // =3D 20
+	u16 actor_system_priority;
+	struct mac_addr actor_system;
+	u16 actor_key;
+	u16 actor_port_priority;
+	u16 actor_port;
+	u8 actor_state;
+	u8 reserved_3_1[3];	     // =3D 0
+	u8 tlv_type_partner_info;     // =3D partner information
+	u8 partner_information_length;	 // =3D 20
+	u16 partner_system_priority;
+	struct mac_addr partner_system;
+	u16 partner_key;
+	u16 partner_port_priority;
+	u16 partner_port;
+	u8 partner_state;
+	u8 reserved_3_2[3];	     // =3D 0
+	u8 tlv_type_collector_info;	  // =3D collector information
+	u8 collector_information_length; // =3D 16
+	u16 collector_max_delay;
+	u8 reserved_12[12];
+	u8 tlv_type_terminator;	     // =3D terminator
+	u8 terminator_length;	     // =3D 0
+	u8 reserved_50[50];	     // =3D 0
+} lacpdu_t;
+
+typedef struct lacpdu_header {
+	struct ad_header ad_header;
+	struct lacpdu lacpdu;
+} lacpdu_header_t;
+
+// Marker Protocol Data Unit(PDU) structure(43.5.3.2 in the 802.3ad stan=
dard)
+typedef struct marker {
+	u8 subtype;		 //  =3D 0x02  (marker PDU)
+	u8 version_number;	 //  =3D 0x01
+	u8 tlv_type;		 //  =3D 0x01  (marker information)
+	//  =3D 0x02  (marker response information)
+	u8 marker_length;	 //  =3D 0x16
+	u16 requester_port;	 //   The number assigned to the port by the reques=
ter
+	struct mac_addr requester_system;      //   The requester=92s system id
+	u32 requester_transaction_id;	//   The transaction id allocated by the =
requester,
+	u16 pad;		 //  =3D 0
+	u8 tlv_type_terminator;	     //  =3D 0x00
+	u8 terminator_length;	     //  =3D 0x00
+	u8 reserved_90[90];	     //  =3D 0
+} marker_t;
+
+typedef struct marker_header {
+	struct ad_header ad_header;
+	struct marker marker;
+} marker_header_t;
+
+#pragma pack()
+
+struct slave;
+struct bonding;
+struct ad_info;
+struct port;
+
+#ifdef __ia64__
+#pragma pack(8)
+#endif
+
+// aggregator structure(43.4.5 in the 802.3ad standard)
+typedef struct aggregator {
+	struct mac_addr aggregator_mac_address;
+	u16 aggregator_identifier;
+	u16 is_individual;		 // BOOLEAN
+	u16 actor_admin_aggregator_key;
+	u16 actor_oper_aggregator_key;
+	struct mac_addr partner_system;
+	u16 partner_system_priority;
+	u16 partner_oper_aggregator_key;
+	u16 receive_state;		// BOOLEAN
+	u16 transmit_state;		// BOOLEAN
+	struct port *lag_ports;
+	// ****** PRIVATE PARAMETERS ******
+	struct slave *slave;	    // pointer to the bond slave that this aggrega=
tor belongs to
+	u16 is_active;	    // BOOLEAN. Indicates if this aggregator is active
+	u16 num_of_ports;
+} aggregator_t;
+
+// port structure(43.4.6 in the 802.3ad standard)
+typedef struct port {
+	u16 actor_port_number;
+	u16 actor_port_priority;
+	struct mac_addr actor_system;	       // This parameter is added here al=
though it is not specified in the standard, just for simplification
+	u16 actor_system_priority;	 // This parameter is added here although it=
 is not specified in the standard, just for simplification
+	u16 actor_port_aggregator_identifier;
+	u16 ntt;			 // BOOLEAN
+	u16 actor_admin_port_key;
+	u16 actor_oper_port_key;
+	u8 actor_admin_port_state;
+	u8 actor_oper_port_state;
+	struct mac_addr partner_admin_system;
+	struct mac_addr partner_oper_system;
+	u16 partner_admin_system_priority;
+	u16 partner_oper_system_priority;
+	u16 partner_admin_key;
+	u16 partner_oper_key;
+	u16 partner_admin_port_number;
+	u16 partner_oper_port_number;
+	u16 partner_admin_port_priority;
+	u16 partner_oper_port_priority;
+	u8 partner_admin_port_state;
+	u8 partner_oper_port_state;
+	u16 is_enabled;	      // BOOLEAN
+	// ****** PRIVATE PARAMETERS ******
+	u16 sm_vars;	      // all state machines variables for this port
+	rx_states_t sm_rx_state;	// state machine rx state
+	u16 sm_rx_timer_counter;    // state machine rx timer counter
+	periodic_states_t sm_periodic_state;// state machine periodic state
+	u16 sm_periodic_timer_counter;	// state machine periodic timer counter
+	mux_states_t sm_mux_state;	// state machine mux state
+	u16 sm_mux_timer_counter;   // state machine mux timer counter
+	tx_states_t sm_tx_state;	// state machine tx state
+	u16 sm_tx_timer_counter;    // state machine tx timer counter(allways o=
n - enter to transmit state 3 time per second)
+	struct slave *slave;	    // pointer to the bond slave that this port be=
longs to
+	struct aggregator *aggregator;	   // pointer to an aggregator that this=
 port related to
+	struct port *next_port_in_aggregator; // Next port on the linked list o=
f the parent aggregator
+	u32 transaction_id;	    // continuous number for identification of Mark=
er PDU's;
+	struct lacpdu lacpdu;	       // the lacpdu that will be sent for this p=
ort
+} port_t;
+
+// system structure
+typedef struct ad_system {
+	u16 sys_priority;
+	struct mac_addr sys_mac_addr;
+} ad_system_t;
+
+#ifdef __ia64__
+#pragma pack()
+#endif
+
+// =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D AD Exported struc=
tures to the main bonding code =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
+#define BOND_AD_INFO(bond)   ((bond)->ad_info)
+#define SLAVE_AD_INFO(slave) ((slave)->ad_info)
+
+struct ad_bond_info {
+	ad_system_t system;	    // 802.3ad system structure
+	u32 agg_select_timer;	    // Timer to select aggregator after all adapt=
er's hand shakes
+	u32 agg_select_mode;	    // Mode of selection of active aggregator(band=
width/count)
+	struct timer_list ad_timer;
+	struct packet_type ad_pkt_type;
+};
+
+struct ad_slave_info {
+	struct aggregator aggregator;	    // 802.3ad aggregator structure
+	struct port port;		    // 802.3ad port structure
+	spinlock_t rx_machine_lock; // To avoid race condition between callback=
 and receive interrupt
+	u16 id;
+};
+
+// =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D AD Exported funct=
ions to the main bonding code =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
+void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution);
+int  bond_3ad_bind_slave(struct slave *slave);
+void bond_3ad_unbind_slave(struct slave *slave);
+void bond_3ad_state_machine_handler(struct bonding *bond);
+void bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, =
u16 length);
+void bond_3ad_adapter_speed_changed(struct slave *slave);
+void bond_3ad_adapter_duplex_changed(struct slave *slave);
+void bond_3ad_link_status_changed(struct slave *slave, int status);
+int  bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *=
ad_info);
+int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev);
+int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct net_device *dev, st=
ruct packet_type* ptype);
+#endif //__BOND_3AD_H__
+
diff -Nuarp linux-2.4.20-bonding-20030317/drivers/net/bonding/bonding.h l=
inux-2.4.20-bonding-20030317-devel/drivers/net/bonding/bonding.h
--- linux-2.4.20-bonding-20030317/drivers/net/bonding/bonding.h	2003-03-1=
8 17:24:24.000000000 +0200
+++ linux-2.4.20-bonding-20030317-devel/drivers/net/bonding/bonding.h	200=
3-03-18 17:24:25.000000000 +0200
@@ -10,6 +10,11 @@
  *	This software may be used and distributed according to the terms
  *	of the GNU Public License, incorporated herein by reference.
  *=20
+ *
+ * 2003/03/18 - Amir Noam <amir.noam at intel dot com>,
+ *		Tsippy Mendelson <tsippy.mendelson at intel dot com> and
+ *		Shmulik Hen <shmulik.hen at intel dot com>
+ *	- Added support for IEEE 802.3ad Dynamic link aggregatoin mode.
  */
 =20
 #ifndef _LINUX_BONDING_H
@@ -17,6 +22,36 @@
=20
 #include <linux/timer.h>
 #include <linux/proc_fs.h>
+#include "bond_3ad.h"
+
+#ifdef BONDING_DEBUG
+
+// use this like so: BOND_PRINT_DBG(("foo =3D %d, bar =3D %d", foo, bar)=
);
+#define BOND_PRINT_DBG(X)                                     \
+do {                                                          \
+	printk(KERN_DEBUG "%s (%d)", __FUNCTION__, __LINE__); \
+	printk X;                                             \
+	printk("\n");                                         \
+} while(0)
+
+#else
+#define BOND_PRINT_DBG(X)
+#endif /* BONDING_DEBUG */
+
+#define IS_UP(dev)  ((((dev)->flags & (IFF_UP)) =3D=3D (IFF_UP)) && \
+		     (netif_running(dev) && netif_carrier_ok(dev)))
+
+/* Checks whether the dev is ready for transmit. We do not check netif_r=
unning */
+/* since a device can be stopped by the driver for short periods of time=
 for */
+/* maintainance. dev_queue_xmit() handles this by queing the packet unti=
l the */
+/* the dev is running again. Keeping packets ordering requires sticking =
the the*/
+/* same dev as much as possible */
+#define SLAVE_IS_OK(slave) \
+		     ((((slave)->dev->flags & (IFF_UP)) =3D=3D (IFF_UP)) && \
+		     netif_carrier_ok((slave)->dev) && \
+		     ((slave)->link =3D=3D BOND_LINK_UP) && \
+		     ((slave)->state =3D=3D BOND_STATE_ACTIVE))
+
=20
 typedef struct slave {
 	struct slave *next;
@@ -31,6 +66,7 @@ typedef struct slave {
 	u16    speed;
 	u8     duplex;
 	u8     perm_hwaddr[ETH_ALEN];
+	struct ad_slave_info ad_info; // HUGE struct. maybe alloc dynamically
 } slave_t;
=20
 /*
@@ -62,7 +98,53 @@ typedef struct bonding {
 	struct net_device *device;
 	struct dev_mc_list *mc_list;
 	unsigned short flags;
+	struct ad_bond_info ad_info;
 } bonding_t;
=20
+void bond_set_slave_active_flags(slave_t *slave);
+void bond_set_slave_inactive_flags(slave_t *slave);
+
+//this function can be used for iterating the slave list (which is circu=
lar)
+//must be locked with bond RW lock
+extern inline struct slave*
+bond_get_next_slave(struct bonding *bond, struct slave *slave)
+{
+	//If we have reached the last slave - return NULL
+	if (slave->next =3D=3D bond->next) {
+		return NULL;
+	}
+	return slave->next;
+}
+
+//must be locked with bond RW lock
+//returns NULL if the net_device does not belong to any of the bond's sl=
aves
+extern inline struct slave*
+bond_get_slave_by_dev(struct bonding *bond, struct net_device *slave_dev=
)
+{
+	struct slave *our_slave =3D bond->next;
+
+	//check if the list of slaves is empty
+	if (our_slave =3D=3D (slave_t *)bond) {
+		return NULL;
+	}
+
+	for (; our_slave; our_slave =3D bond_get_next_slave(bond, our_slave)) {
+		if (our_slave->dev =3D=3D slave_dev) {
+			break;
+		}
+	}
+	return our_slave;
+}
+
+extern inline struct bonding*
+bond_get_bond_by_slave(struct slave *slave)
+{
+	if (!slave || !slave->dev->master) {
+		return NULL;
+	}
+
+	return (struct bonding *)(slave->dev->master->priv);
+}
+
 #endif /* _LINUX_BONDING_H */
=20
diff -Nuarp linux-2.4.20-bonding-20030317/drivers/net/bonding/bond_main.c=
 linux-2.4.20-bonding-20030317-devel/drivers/net/bonding/bond_main.c
--- linux-2.4.20-bonding-20030317/drivers/net/bonding/bond_main.c	2003-03=
-18 17:24:24.000000000 +0200
+++ linux-2.4.20-bonding-20030317-devel/drivers/net/bonding/bond_main.c	2=
003-03-18 17:24:25.000000000 +0200
@@ -319,6 +319,11 @@
  *	  properly.
  *	- Block possibility of enslaving before the master is up. This
  *	  prevents putting the system in an unstable state.
+ *
+ * 2003/03/18 - Amir Noam <amir.noam at intel dot com>,
+ *		Tsippy Mendelson <tsippy.mendelson at intel dot com> and
+ *		Shmulik Hen <shmulik.hen at intel dot com>
+ *	- Added support for IEEE 802.3ad Dynamic link aggregatoin mode.
  */
=20
 #include <linux/config.h>
@@ -359,6 +364,7 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include "bonding.h"
+#include "bond_3ad.h"
=20
 #define DRV_VERSION		"2.4.20-20030317"
 #define DRV_RELDATE		"March 17, 2003"
@@ -409,6 +415,7 @@ static struct bond_parm_tbl bond_mode_tb
 {	"active-backup",	BOND_MODE_ACTIVEBACKUP},
 {	"balance-xor",		BOND_MODE_XOR},
 {	"broadcast",		BOND_MODE_BROADCAST},
+{	"802.3ad",		BOND_MODE_8023AD},
 {	NULL,			-1},
 };
=20
@@ -464,8 +471,6 @@ static void bond_set_promiscuity(bonding
 static void bond_set_allmulti(bonding_t *bond, int inc);
 static struct dev_mc_list* bond_mc_list_find_dmi(struct dev_mc_list *dmi=
, struct dev_mc_list *mc_list);
 static void bond_mc_update(bonding_t *bond, slave_t *new, slave_t *old);
-static void bond_set_slave_inactive_flags(slave_t *slave);
-static void bond_set_slave_active_flags(slave_t *slave);
 static int bond_enslave(struct net_device *master, struct net_device *sl=
ave);
 static int bond_release(struct net_device *master, struct net_device *sl=
ave);
 static int bond_release_all(struct net_device *master);
@@ -483,9 +488,6 @@ static int bond_get_info(char *buf, char
=20
 /* several macros */
=20
-#define IS_UP(dev)	((((dev)->flags & (IFF_UP)) =3D=3D (IFF_UP)) && \
-			(netif_running(dev) && netif_carrier_ok(dev)))
- =20
 static void arp_send_all(slave_t *slave)
 {=09
 	int i;=20
@@ -510,6 +512,8 @@ bond_mode_name(void)
 		return "load balancing (xor)";
 	case BOND_MODE_BROADCAST :
 		return "fault-tolerance (broadcast)";
+	case BOND_MODE_8023AD:
+		return "IEEE 802.3ad Dynamic link aggregation";
 	default :
 		return "unknown";
 	}
@@ -530,13 +534,13 @@ multicast_mode_name(void)
 	}
 }
=20
-static void bond_set_slave_inactive_flags(slave_t *slave)
+void bond_set_slave_inactive_flags(slave_t *slave)
 {
 	slave->state =3D BOND_STATE_BACKUP;
 	slave->dev->flags |=3D IFF_NOARP;
 }
=20
-static void bond_set_slave_active_flags(slave_t *slave)
+void bond_set_slave_active_flags(slave_t *slave)
 {
 	slave->state =3D BOND_STATE_ACTIVE;
 	slave->dev->flags &=3D ~IFF_NOARP;
@@ -815,8 +819,29 @@ static u16 bond_check_mii_link(bonding_t
 	return (has_active_interface ? BMSR_LSTATUS : 0);
 }
=20
+//register to receive lacpdus on a bond
+static void bond_register_lacpdu(struct bonding *bond)
+{
+	struct packet_type* pk_type =3D &(BOND_AD_INFO(bond).ad_pkt_type);
+
+	//initialize packet type
+	pk_type->type =3D PKT_TYPE_LACPDU;
+	pk_type->dev =3D bond->device;
+	pk_type->func =3D bond_3ad_lacpdu_recv;
+	pk_type->data =3D (void*)1;  // understand shared skbs
+
+	dev_add_pack(pk_type);
+}
+
+//register to receive lacpdus on a bond
+static void bond_unregister_lacpdu(struct bonding *bond)
+{
+	dev_remove_pack(&(BOND_AD_INFO(bond).ad_pkt_type));
+}
+
 static int bond_open(struct net_device *dev)
 {
+	struct bonding *bond =3D (struct bonding *)(dev->priv);
 	struct timer_list *timer =3D &((struct bonding *)(dev->priv))->mii_time=
r;
 	struct timer_list *arp_timer =3D &((struct bonding *)(dev->priv))->arp_=
timer;
 	MOD_INC_USE_COUNT;
@@ -840,6 +865,19 @@ static int bond_open(struct net_device *
 		}
 		add_timer(arp_timer);
 	}
+
+	if (bond_mode =3D=3D BOND_MODE_8023AD) {
+		struct timer_list *ad_timer =3D &(BOND_AD_INFO(bond).ad_timer);
+		init_timer(ad_timer);
+		ad_timer->expires  =3D jiffies + (AD_TIMER_INTERVAL * HZ / 1000);
+		ad_timer->data     =3D (unsigned long)bond;
+		ad_timer->function =3D (void *)&bond_3ad_state_machine_handler;
+		add_timer(ad_timer);
+
+		//register to receive LACPDUs
+		bond_register_lacpdu(bond);
+	}
+
 	return 0;
 }
=20
@@ -861,8 +899,18 @@ static int bond_close(struct net_device=20
 		}
 	}
=20
-	/* Release the bonded slaves */
-	bond_release_all(master);
+	if (bond_mode =3D=3D BOND_MODE_8023AD) {
+		del_timer_sync(&(BOND_AD_INFO(bond).ad_timer));
+
+		//Unregister the receive of LACPDUs
+		bond_unregister_lacpdu(bond);
+	}
+
+	if (bond->next !=3D (struct slave *) bond) {
+		/* Release the bonded slaves */
+		bond_release_all(master);
+	}
+=09
 	bond_mc_list_destroy (bond);
=20
 	write_unlock_irqrestore(&bond->lock, flags);
@@ -880,6 +928,13 @@ static void bond_mc_list_flush(struct ne
 =20
 	for (dmi =3D flush->mc_list; dmi !=3D NULL; dmi =3D dmi->next)=20
 		dev_mc_delete(dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
+
+	if (bond_mode =3D=3D BOND_MODE_8023AD) {
+		/*del lacpdu mc addr to mc list*/
+		u8 lacpdu_multicast[ETH_ALEN] =3D MULTICAST_LACPDU_ADDR;
+
+		dev_mc_delete(dev, lacpdu_multicast, ETH_ALEN, 0);
+	}
 }
=20
 /*
@@ -1240,6 +1295,13 @@ static int bond_enslave(struct net_devic
 			dev_mc_add (slave_dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
 	}
=20
+	if (bond_mode =3D=3D BOND_MODE_8023AD) {
+		/*add lacpdu mc addr to mc list*/
+		u8 lacpdu_multicast[ETH_ALEN] =3D MULTICAST_LACPDU_ADDR;
+
+		dev_mc_add(slave_dev, lacpdu_multicast, ETH_ALEN, 0);
+	}
+
 	write_lock_irqsave(&bond->lock, flags);
 =09
 	bond_attach_slave(bond, new_slave);
@@ -1299,6 +1361,11 @@ static int bond_enslave(struct net_devic
 		       "bond_enslave(): failed to get speed/duplex from %s, "
 		       "speed forced to 100Mbps, duplex forced to Full.\n",
 		       new_slave->dev->name);
+		if (bond_mode =3D=3D BOND_MODE_8023AD) {
+			printk(KERN_WARNING
+			       "Operation of 802.3ad mode requires ETHTOOL support "
+			       "in base driver for proper aggregator selection.\n");
+		}
 	}
 =09
 	/* if we're in active-backup mode, we need one and only one active
@@ -1337,6 +1404,23 @@ static int bond_enslave(struct net_devic
 		if (primary !=3D NULL)
 		  if( strcmp(primary, new_slave->dev->name) =3D=3D 0)=20
 			bond->primary_slave =3D new_slave;
+	} else if (bond_mode =3D=3D BOND_MODE_8023AD) {
+		/* in 802.3ad mode, the internal mechanism
+		   will activate the slaves in the selected
+		   aggregator */
+		bond_set_slave_inactive_flags(new_slave);
+		//if this is the first slave
+		if (new_slave =3D=3D bond->next) {
+			SLAVE_AD_INFO(new_slave).id =3D 1;
+			/*Initialize AD with the number of times that the AD timer is called =
in 1 second*/
+			/*can be called only after the mac address of the bond is set*/
+			bond_3ad_initialize(bond, 1000/AD_TIMER_INTERVAL);
+		} else {
+			SLAVE_AD_INFO(new_slave).id =3D
+			SLAVE_AD_INFO(new_slave->prev).id + 1;
+		}
+
+		bond_3ad_bind_slave(new_slave);
 	} else {
 #ifdef BONDING_DEBUG
 		printk(KERN_CRIT "This slave is always active in trunk mode\n");
@@ -1601,6 +1685,12 @@ static int bond_release(struct net_devic
 	old_current =3D bond->current_slave;
 	while ((our_slave =3D our_slave->prev) !=3D (slave_t *)bond) {
 		if (our_slave->dev =3D=3D slave) {
+			/* Inform AD package of unbinding of slave. */
+			if (bond_mode =3D=3D BOND_MODE_8023AD) {
+				bond_3ad_unbind_slave(our_slave);
+			}
+
+			/* release the slave from its bond */
 			bond_detach_slave(bond, our_slave);
=20
 			printk (KERN_INFO "%s: releasing %s interface %s",
@@ -1705,6 +1795,12 @@ static int bond_release_all(struct net_d
 	bond->primary_slave =3D NULL;
=20
 	while ((our_slave =3D bond->prev) !=3D (slave_t *)bond) {
+		/* Inform AD package of unbinding of slave
+		   before slave is detached from the list. */
+		if (bond_mode =3D=3D BOND_MODE_8023AD) {
+			bond_3ad_unbind_slave(our_slave);
+		}
+	=09
 		slave_dev =3D our_slave->dev;
 		bond_detach_slave(bond, our_slave);
=20
@@ -1784,6 +1880,8 @@ static void bond_mii_monitor(struct net_
 		int mindelay =3D updelay + 1;
 		struct net_device *dev =3D slave->dev;
 		int link_state;
+		u16 old_speed =3D slave->speed;
+		u8 old_duplex =3D slave->duplex;
 	=09
 		link_state =3D bond_check_dev_link(dev, 0);
=20
@@ -1832,7 +1930,7 @@ static void bond_mii_monitor(struct net_
 					slave->link =3D BOND_LINK_DOWN;
 					/* in active/backup mode, we must
 					   completely disable this interface */
-					if (bond_mode =3D=3D BOND_MODE_ACTIVEBACKUP) {
+					if ((bond_mode =3D=3D BOND_MODE_ACTIVEBACKUP) || (bond_mode =3D=3D =
BOND_MODE_8023AD)) {
 						bond_set_slave_inactive_flags(slave);
 					}
 					printk(KERN_INFO
@@ -1841,6 +1939,11 @@ static void bond_mii_monitor(struct net_
 						master->name,
 						dev->name);
=20
+					//notify ad that the link status has changed
+					if (bond_mode =3D=3D BOND_MODE_8023AD) {
+						bond_3ad_link_status_changed(slave, 0);
+					}
+
 					read_lock(&bond->ptrlock);
 					if (slave =3D=3D bond->current_slave) {
 						read_unlock(&bond->ptrlock);
@@ -1911,8 +2014,12 @@ static void bond_mii_monitor(struct net_
 					/* now the link has been up for long time enough */
 					slave->link =3D BOND_LINK_UP;
 					slave->jiffies =3D jiffies;
-
-					if (bond_mode !=3D BOND_MODE_ACTIVEBACKUP) {
+				=09
+					if (bond_mode =3D=3D BOND_MODE_8023AD) {
+						/* prevent it from being the active one */
+						slave->state =3D BOND_STATE_BACKUP;
+					}
+					else if (bond_mode !=3D BOND_MODE_ACTIVEBACKUP) {
 						/* make it immediately active */
 						slave->state =3D BOND_STATE_ACTIVE;
 					} else if (slave !=3D bond->primary_slave) {
@@ -1926,7 +2033,12 @@ static void bond_mii_monitor(struct net_
 						master->name,
 						dev->name);
 =09
-					if ( (bond->primary_slave !=3D NULL)	=20
+					//notify ad that the link status has changed
+					if (bond_mode =3D=3D BOND_MODE_8023AD) {
+						bond_3ad_link_status_changed(slave, 1);
+					}
+				=09
+					if ( (bond->primary_slave !=3D NULL)=09
 					  && (slave =3D=3D bond->primary_slave) )
 						change_active_interface(bond);=20
 				}
@@ -1950,7 +2062,16 @@ static void bond_mii_monitor(struct net_
 		} /* end of switch */
 	=09
 		bond_update_speed_duplex(slave);
-	=09
+
+		if (bond_mode =3D=3D BOND_MODE_8023AD) {
+			if (old_speed !=3D slave->speed) {
+				bond_3ad_adapter_speed_changed(slave);
+			}
+			if (old_duplex !=3D slave->duplex) {
+				bond_3ad_adapter_duplex_changed(slave);
+			}
+		}
+
 	} /* end of while */
=20
 	/*=20
@@ -1978,12 +2099,17 @@ static void bond_mii_monitor(struct net_
 				bestslave->delay =3D 0;
 				bestslave->link  =3D BOND_LINK_UP;
 				bestslave->jiffies =3D jiffies;
+
+				//notify ad that the link status has changed
+				if (bond_mode =3D=3D BOND_MODE_8023AD) {
+					bond_3ad_link_status_changed(bestslave, 1);
+				}
 			}
=20
 			if (bond_mode =3D=3D BOND_MODE_ACTIVEBACKUP) {
 				bond_set_slave_active_flags(bestslave);
 				bond_mc_update(bond, bestslave, NULL);
-			} else {
+			} else if (bond_mode !=3D BOND_MODE_8023AD) {
 				bestslave->state =3D BOND_STATE_ACTIVE;
 			}
 			write_lock(&bond->ptrlock);
@@ -2956,6 +3082,31 @@ static int bond_get_info(char *buf, char
 			       multicast_mode_name());
=20
 		read_lock_irqsave(&bond->lock, flags);
+
+		if (bond_mode =3D=3D BOND_MODE_8023AD) {
+			struct ad_info ad_info;
+
+			len +=3D sprintf(buf + len, "\n802.3ad info\n");
+
+			if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
+				len +=3D sprintf(buf + len, "bond %s has no active aggregator\n", bo=
nd->device->name);
+			} else {
+				len +=3D sprintf(buf + len, "Active Aggregator Info:\n");
+
+				len +=3D sprintf(buf + len, "\tAggregator ID: %d\n", ad_info.aggrega=
tor_id);
+				len +=3D sprintf(buf + len, "\tNumber of ports: %d\n", ad_info.ports=
);
+				len +=3D sprintf(buf + len, "\tActor Key: %d\n", ad_info.actor_key);
+				len +=3D sprintf(buf + len, "\tPartner Key: %d\n", ad_info.partner_k=
ey);
+				len +=3D sprintf(buf + len, "\tPartner Mac Address: %02x:%02x:%02x:%=
02x:%02x:%02x\n",
+					       ad_info.partner_system[0],
+					       ad_info.partner_system[1],
+					       ad_info.partner_system[2],
+					       ad_info.partner_system[3],
+					       ad_info.partner_system[4],
+					       ad_info.partner_system[5]);
+			}
+		}
+
 		for (slave =3D bond->prev; slave !=3D (slave_t *)bond;=20
 		     slave =3D slave->prev) {
 			len +=3D sprintf(buf + len, "\nSlave Interface: %s\n", slave->dev->na=
me);
@@ -2976,6 +3127,17 @@ static int bond_get_info(char *buf, char
 				       slave->perm_hwaddr[3],
 				       slave->perm_hwaddr[4],
 				       slave->perm_hwaddr[5]);
+
+			if (bond_mode =3D=3D BOND_MODE_8023AD) {
+				struct aggregator *agg =3D SLAVE_AD_INFO(slave).port.aggregator;
+
+				if (agg) {
+					len +=3D sprintf(buf + len, "Aggregator ID: %d\n",
+						       agg->aggregator_identifier);
+				} else {
+					len +=3D sprintf(buf + len, "Aggregator ID: N/A\n");
+				}
+			}
 		}
 		read_unlock_irqrestore(&bond->lock, flags);
=20
@@ -3093,6 +3255,9 @@ static int __init bond_init(struct net_d
 	case BOND_MODE_BROADCAST:
 		dev->hard_start_xmit =3D bond_xmit_broadcast;
 		break;
+	case BOND_MODE_8023AD:
+		dev->hard_start_xmit =3D bond_3ad_xmit_xor;
+		break;
 	default:
 		printk(KERN_ERR "Unknown bonding mode %d\n", bond_mode);
 		kfree(bond->stats);
@@ -3280,6 +3445,35 @@ static int __init bonding_init(void)
 		downdelay =3D 0;
 	}
=20
+	/* reset values for 802.3ad */
+	if (bond_mode =3D=3D BOND_MODE_8023AD) {
+		if (arp_interval !=3D 0) {
+			printk(KERN_WARNING "bonding_init(): ARP monitoring"
+			       "can't be used simultaneously with 802.3ad, "
+			       "disabling ARP monitoring\n"
+			       );
+			arp_interval =3D 0;
+		}
+	=09
+		if (miimon =3D=3D 0) {
+			printk(KERN_ERR
+			       "bonding_init(): miimon must be specified, "
+			       "otherwise bonding will not detect link failure, "
+			       "speed and duplex which are essential "
+			       "for 802.3ad operation"
+			       "Forcing miimon to 100msec\n");
+			miimon =3D 100;
+		}
+	=09
+		if (multicast_mode !=3D BOND_MULTICAST_ALL) {
+			printk(KERN_ERR
+			       "bonding_init(): Multicast mode must "
+			       "be set to ALL for 802.3ad, "
+			       "Forcing Multicast mode to ALL\n");
+			multicast_mode =3D BOND_MULTICAST_ALL;
+		}
+	}
+=09
 	if (miimon =3D=3D 0) {
 		if ((updelay !=3D 0) || (downdelay !=3D 0)) {
 			/* just warn the user the up/down delay will have
diff -Nuarp linux-2.4.20-bonding-20030317/drivers/net/bonding/Makefile li=
nux-2.4.20-bonding-20030317-devel/drivers/net/bonding/Makefile
--- linux-2.4.20-bonding-20030317/drivers/net/bonding/Makefile	2003-03-18=
 17:24:24.000000000 +0200
+++ linux-2.4.20-bonding-20030317-devel/drivers/net/bonding/Makefile	2003=
-03-18 17:24:25.000000000 +0200
@@ -4,7 +4,8 @@
=20
 O_TARGET :=3D bonding.o
=20
-obj-y	 :=3D bond_main.o
+obj-y	 :=3D bond_main.o \
+            bond_3ad.o
=20
 obj-m	 :=3D $(O_TARGET)
=20
diff -Nuarp linux-2.4.20-bonding-20030317/include/linux/if_bonding.h linu=
x-2.4.20-bonding-20030317-devel/include/linux/if_bonding.h
--- linux-2.4.20-bonding-20030317/include/linux/if_bonding.h	2003-03-18 1=
7:24:24.000000000 +0200
+++ linux-2.4.20-bonding-20030317-devel/include/linux/if_bonding.h	2003-0=
3-18 17:24:25.000000000 +0200
@@ -23,6 +23,11 @@
  * 2003/03/18 - Tsippy Mendelson <tsippy.mendelson at intel dot com> and
  *		Amir Noam <amir.noam at intel dot com>
  *	- Moved driver's private data types to bonding.h
+ *
+ * 2003/03/18 - Amir Noam <amir.noam at intel dot com>,
+ *		Tsippy Mendelson <tsippy.mendelson at intel dot com> and
+ *		Shmulik Hen <shmulik.hen at intel dot com>
+ *	- Added support for IEEE 802.3ad Dynamic link aggregatoin mode.
  */
=20
 #ifndef _LINUX_IF_BONDING_H
@@ -49,6 +54,7 @@
 #define BOND_MODE_ACTIVEBACKUP	1
 #define BOND_MODE_XOR		2
 #define BOND_MODE_BROADCAST	3
+#define BOND_MODE_8023AD        4
=20
 /* each slave's link has 4 states */
 #define BOND_LINK_UP    0           /* link is up and running */
@@ -81,6 +87,14 @@ typedef struct ifslave
 	__u32  link_failure_count;
 } ifslave;
=20
+struct ad_info {
+	__u16 aggregator_id;
+	__u16 ports;
+	__u16 actor_key;
+	__u16 partner_key;
+	__u8 partner_system[ETH_ALEN];
+};
+
 #endif /* _LINUX_IF_BONDING_H */
=20
 /*

--=20
| Shmulik Hen                                    |
| Israel Design Center (Jerusalem)               |
| LAN Access Division                            |
| Intel Communications Group, Intel corp.        |
|                                                |
| Anti-Spam: shmulik dot hen at intel dot com    |
