From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 01/20] net: slight optimization of addr compare for
 some modules
Date: Tue, 24 Dec 2013 06:22:24 -0800
Message-ID: <1387894944.2259.31.camel@joe-AO722>
References: <52B96F9B.4020806@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52B96F9B.4020806@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-12-24 at 19:27 +0800, Ding Tianhong wrote:
> Use possibly more efficient ether_addr_equal_unaligned
> and ether_addr_equal to instead of memcmp.

A negative of adding so many different drivers in a single
patch is that you miss sending patches to the named maintainers.

Most of these below have separate individual maintainers.
(a suggested patch below this too)

>  drivers/net/bonding/bond_3ad.c                        |  2 +-
>  drivers/net/ethernet/3com/3c509.c                     |  3 +--
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c        | 10 ++++------
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c     |  2 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c      |  2 +-
>  drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c    |  2 +-
>  drivers/net/ethernet/chelsio/cxgb3/l2t.c              |  2 +-
>  drivers/net/ethernet/cisco/enic/enic_pp.c             |  2 +-
>  drivers/net/ethernet/emulex/benet/be_main.c           |  2 +-
>  drivers/net/ethernet/intel/igbvf/netdev.c             |  2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c        |  3 +--
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |  4 ++--
>  drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |  2 +-
>  drivers/net/ethernet/micrel/ksz884x.c                 |  9 ++++-----
>  drivers/net/ethernet/neterion/vxge/vxge-main.c        |  2 +-
>  drivers/net/ethernet/packetengines/yellowfin.c        |  8 ++------
>  drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c    |  2 +-
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c        |  4 ++--
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c        |  4 ++--
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      |  4 ++--
>  drivers/net/ethernet/renesas/sh_eth.c                 |  2 +-
>  drivers/net/ethernet/seeq/sgiseeq.c                   |  2 +-
>  drivers/net/ethernet/sun/sunvnet.c                    |  2 +-
>  drivers/net/ethernet/ti/cpsw_ale.c                    |  2 +-
>  drivers/net/fddi/skfp/fplustm.c                       |  3 ++-
>  drivers/net/plip/plip.c                               |  2 +-
>  net/caif/cfrfml.c                                     |  2 +-
>  27 files changed, 39 insertions(+), 47 deletions(-)

Also for bonding, my preference would be to rename
the macro and use ether_addr_equal as it seems that
all references are u16 aligned.

I also removed some superfluous parentheses.
---
 drivers/net/bonding/bond_3ad.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 187b1b7..ae56983 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -91,7 +91,8 @@
 //endalloun
 
 // compare MAC addresses
-#define MAC_ADDRESS_COMPARE(A, B) memcmp(A, B, ETH_ALEN)
+#define MAC_ADDRESS_EQUAL(A, B)					\
+	ether_addr_equal((const u8 *)A, (const u8 *)B)
 
 static struct mac_addr null_mac_addr = { { 0, 0, 0, 0, 0, 0 } };
 static u16 ad_ticks_per_sec;
@@ -419,7 +420,7 @@ static void __choose_matched(struct lacpdu *lacpdu, struct port *port)
 	// check if all parameters are alike
 	if (((ntohs(lacpdu->partner_port) == port->actor_port_number) &&
 	     (ntohs(lacpdu->partner_port_priority) == port->actor_port_priority) &&
-	     !MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_system)) &&
+	     MAC_ADDRESS_EQUAL(&lacpdu->partner_system, &port->actor_system) &&
 	     (ntohs(lacpdu->partner_system_priority) == port->actor_system_priority) &&
 	     (ntohs(lacpdu->partner_key) == port->actor_oper_port_key) &&
 	     ((lacpdu->partner_state & AD_STATE_AGGREGATION) == (port->actor_oper_port_state & AD_STATE_AGGREGATION))) ||
@@ -509,7 +510,7 @@ static void __update_selected(struct lacpdu *lacpdu, struct port *port)
 		// check if any parameter is different
 		if (ntohs(lacpdu->actor_port) != partner->port_number ||
 		    ntohs(lacpdu->actor_port_priority) != partner->port_priority ||
-		    MAC_ADDRESS_COMPARE(&lacpdu->actor_system, &partner->system) ||
+		    !MAC_ADDRESS_EQUAL(&lacpdu->actor_system, &partner->system) ||
 		    ntohs(lacpdu->actor_system_priority) != partner->system_priority ||
 		    ntohs(lacpdu->actor_key) != partner->key ||
 		    (lacpdu->actor_state & AD_STATE_AGGREGATION) != (partner->port_state & AD_STATE_AGGREGATION)) {
@@ -540,7 +541,7 @@ static void __update_default_selected(struct port *port)
 		// check if any parameter is different
 		if (admin->port_number != oper->port_number ||
 		    admin->port_priority != oper->port_priority ||
-		    MAC_ADDRESS_COMPARE(&admin->system, &oper->system) ||
+		    !MAC_ADDRESS_EQUAL(&admin->system, &oper->system) ||
 		    admin->system_priority != oper->system_priority ||
 		    admin->key != oper->key ||
 		    (admin->port_state & AD_STATE_AGGREGATION)
@@ -570,7 +571,7 @@ static void __update_ntt(struct lacpdu *lacpdu, struct port *port)
 		// check if any parameter is different
 		if ((ntohs(lacpdu->partner_port) != port->actor_port_number) ||
 		    (ntohs(lacpdu->partner_port_priority) != port->actor_port_priority) ||
-		    MAC_ADDRESS_COMPARE(&(lacpdu->partner_system), &(port->actor_system)) ||
+		    !MAC_ADDRESS_EQUAL(&lacpdu->partner_system, &port->actor_system) ||
 		    (ntohs(lacpdu->partner_system_priority) != port->actor_system_priority) ||
 		    (ntohs(lacpdu->partner_key) != port->actor_oper_port_key) ||
 		    ((lacpdu->partner_state & AD_STATE_LACP_ACTIVITY) != (port->actor_oper_port_state & AD_STATE_LACP_ACTIVITY)) ||
@@ -1072,7 +1073,7 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			break;
 		case AD_RX_CURRENT:
 			// detect loopback situation
-			if (!MAC_ADDRESS_COMPARE(&(lacpdu->actor_system), &(port->actor_system))) {
+			if (MAC_ADDRESS_EQUAL(&lacpdu->actor_system, &port->actor_system)) {
 				// INFO_RECEIVED_LOOPBACK_FRAMES
 				pr_err("%s: An illegal loopback occurred on adapter (%s).\n"
 				       "Check the configuration to verify that all adapters are connected to 802.3ad compliant switch ports\n",
@@ -1278,11 +1279,11 @@ static void ad_port_selection_logic(struct port *port)
 		}
 		// check if current aggregator suits us
 		if (((aggregator->actor_oper_aggregator_key == port->actor_oper_port_key) && // if all parameters match AND
-		     !MAC_ADDRESS_COMPARE(&(aggregator->partner_system), &(port->partner_oper.system)) &&
+		     MAC_ADDRESS_EQUAL(&aggregator->partner_system, &port->partner_oper.system) &&
 		     (aggregator->partner_system_priority == port->partner_oper.system_priority) &&
 		     (aggregator->partner_oper_aggregator_key == port->partner_oper.key)
 		    ) &&
-		    ((MAC_ADDRESS_COMPARE(&(port->partner_oper.system), &(null_mac_addr)) && // partner answers
+		    ((!MAC_ADDRESS_EQUAL(&port->partner_oper.system, &null_mac_addr) && // partner answers
 		      !aggregator->is_individual)  // but is not individual OR
 		    )
 		   ) {
@@ -1696,7 +1697,7 @@ static void ad_enable_collecting_distributing(struct port *port)
  */
 static void ad_disable_collecting_distributing(struct port *port)
 {
-	if (port->aggregator && MAC_ADDRESS_COMPARE(&(port->aggregator->partner_system), &(null_mac_addr))) {
+	if (port->aggregator && !MAC_ADDRESS_EQUAL(&port->aggregator->partner_system, &null_mac_addr)) {
 		pr_debug("Disabling port %d(LAG %d)\n",
 			 port->actor_port_number,
 			 port->aggregator->aggregator_identifier);
@@ -1818,8 +1819,8 @@ static u16 aggregator_identifier;
 void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution)
 {
 	// check that the bond is not initialized yet
-	if (MAC_ADDRESS_COMPARE(&(BOND_AD_INFO(bond).system.sys_mac_addr),
-				bond->dev->dev_addr)) {
+	if (!MAC_ADDRESS_EQUAL(&BOND_AD_INFO(bond).system.sys_mac_addr,
+			       bond->dev->dev_addr)) {
 
 		aggregator_identifier = 0;
 
