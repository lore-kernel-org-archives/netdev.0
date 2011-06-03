From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next] bonding: make 802.3ad use update lacp_rate
Date: Fri, 3 Jun 2011 17:00:59 +0200
Message-ID: <20110603150059.GB2765@psychotron.brq.redhat.com>
References: <1307111733-4746-1-git-send-email-panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"open list:BONDING DRIVER" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1307111733-4746-1-git-send-email-panweiping3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, Jun 03, 2011 at 04:35:33PM CEST, panweiping3@gmail.com wrote:
>There is a bug that when you modify lacp_rate via sysfs,
>802.3ad won't use the new value of lacp_rate to transmit packets.
>That is because port->actor_oper_port_state isn't changed.
>
>And I want to use AD_STATE_LACP_TIMEOUT,
>so I move related macros from bond_3ad.c into bond_3ad.h.
>
>Signed-off-by: Weiping Pan <panweiping3@gmail.com>
>---
> drivers/net/bonding/bond_3ad.c   |   48 --------------------------------------
> drivers/net/bonding/bond_3ad.h   |   48 ++++++++++++++++++++++++++++++++++++++
> drivers/net/bonding/bond_sysfs.c |   15 +++++++++++-
> 3 files changed, 62 insertions(+), 49 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index c7537abc..9083258 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -34,54 +34,6 @@
> #include "bonding.h"
> #include "bond_3ad.h"
> 
>-// General definitions
>-#define AD_SHORT_TIMEOUT           1
>-#define AD_LONG_TIMEOUT            0
>-#define AD_STANDBY                 0x2
>-#define AD_MAX_TX_IN_SECOND        3
>-#define AD_COLLECTOR_MAX_DELAY     0
>-
>-// Timer definitions(43.4.4 in the 802.3ad standard)
>-#define AD_FAST_PERIODIC_TIME      1
>-#define AD_SLOW_PERIODIC_TIME      30
>-#define AD_SHORT_TIMEOUT_TIME      (3*AD_FAST_PERIODIC_TIME)
>-#define AD_LONG_TIMEOUT_TIME       (3*AD_SLOW_PERIODIC_TIME)
>-#define AD_CHURN_DETECTION_TIME    60
>-#define AD_AGGREGATE_WAIT_TIME     2
>-
>-// Port state definitions(43.4.2.2 in the 802.3ad standard)
>-#define AD_STATE_LACP_ACTIVITY   0x1
>-#define AD_STATE_LACP_TIMEOUT    0x2
>-#define AD_STATE_AGGREGATION     0x4
>-#define AD_STATE_SYNCHRONIZATION 0x8
>-#define AD_STATE_COLLECTING      0x10
>-#define AD_STATE_DISTRIBUTING    0x20
>-#define AD_STATE_DEFAULTED       0x40
>-#define AD_STATE_EXPIRED         0x80
>-
>-// Port Variables definitions used by the State Machines(43.4.7 in the 802.3ad standard)
>-#define AD_PORT_BEGIN           0x1
>-#define AD_PORT_LACP_ENABLED    0x2
>-#define AD_PORT_ACTOR_CHURN     0x4
>-#define AD_PORT_PARTNER_CHURN   0x8
>-#define AD_PORT_READY           0x10
>-#define AD_PORT_READY_N         0x20
>-#define AD_PORT_MATCHED         0x40
>-#define AD_PORT_STANDBY         0x80
>-#define AD_PORT_SELECTED        0x100
>-#define AD_PORT_MOVED           0x200
>-
>-// Port Key definitions
>-// key is determined according to the link speed, duplex and
>-// user key(which is yet not supported)
>-//              ------------------------------------------------------------
>-// Port key :   | User key                       |      Speed       |Duplex|
>-//              ------------------------------------------------------------
>-//              16                               6               1 0
>-#define  AD_DUPLEX_KEY_BITS    0x1
>-#define  AD_SPEED_KEY_BITS     0x3E
>-#define  AD_USER_KEY_BITS      0xFFC0
>-
> //dalloun
> #define     AD_LINK_SPEED_BITMASK_1MBPS       0x1
> #define     AD_LINK_SPEED_BITMASK_10MBPS      0x2
>diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
>index 0ee3f16..6ce1f6b 100644
>--- a/drivers/net/bonding/bond_3ad.h
>+++ b/drivers/net/bonding/bond_3ad.h
>@@ -37,6 +37,54 @@
> #define AD_LACP_SLOW 0
> #define AD_LACP_FAST 1
> 
>+#define AD_SHORT_TIMEOUT           1
>+#define AD_LONG_TIMEOUT            0
>+#define AD_STANDBY                 0x2
>+#define AD_MAX_TX_IN_SECOND        3
>+#define AD_COLLECTOR_MAX_DELAY     0
>+
>+// Timer definitions(43.4.4 in the 802.3ad standard)
>+#define AD_FAST_PERIODIC_TIME      1
>+#define AD_SLOW_PERIODIC_TIME      30
>+#define AD_SHORT_TIMEOUT_TIME      (3*AD_FAST_PERIODIC_TIME)
>+#define AD_LONG_TIMEOUT_TIME       (3*AD_SLOW_PERIODIC_TIME)
>+#define AD_CHURN_DETECTION_TIME    60
>+#define AD_AGGREGATE_WAIT_TIME     2
>+
>+// Port state definitions(43.4.2.2 in the 802.3ad standard)
>+#define AD_STATE_LACP_ACTIVITY   0x1
>+#define AD_STATE_LACP_TIMEOUT    0x2
>+#define AD_STATE_AGGREGATION     0x4
>+#define AD_STATE_SYNCHRONIZATION 0x8
>+#define AD_STATE_COLLECTING      0x10
>+#define AD_STATE_DISTRIBUTING    0x20
>+#define AD_STATE_DEFAULTED       0x40
>+#define AD_STATE_EXPIRED         0x80
>+
>+// Port Variables definitions used by the State Machines(43.4.7 in the 802.3ad standard)
>+#define AD_PORT_BEGIN           0x1
>+#define AD_PORT_LACP_ENABLED    0x2
>+#define AD_PORT_ACTOR_CHURN     0x4
>+#define AD_PORT_PARTNER_CHURN   0x8
>+#define AD_PORT_READY           0x10
>+#define AD_PORT_READY_N         0x20
>+#define AD_PORT_MATCHED         0x40
>+#define AD_PORT_STANDBY         0x80
>+#define AD_PORT_SELECTED        0x100
>+#define AD_PORT_MOVED           0x200
>+
>+// Port Key definitions
>+// key is determined according to the link speed, duplex and
>+// user key(which is yet not supported)
>+//              ------------------------------------------------------------
>+// Port key :   | User key                       |      Speed       |Duplex|
>+//              ------------------------------------------------------------
>+//              16                               6               1 0
>+#define  AD_DUPLEX_KEY_BITS    0x1
>+#define  AD_SPEED_KEY_BITS     0x3E
>+#define  AD_USER_KEY_BITS      0xFFC0
>+
>+
> typedef struct mac_addr {
> 	u8 mac_addr_value[ETH_ALEN];
> } __packed mac_addr_t;
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index 88fcb25..2cad514 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -783,8 +783,13 @@ static ssize_t bonding_store_lacp(struct device *d,
> 				  struct device_attribute *attr,
> 				  const char *buf, size_t count)
> {
>-	int new_value, ret = count;
>+	int new_value, i, ret = count;
> 	struct bonding *bond = to_bond(d);
>+	struct slave *slave;
>+	struct port *port = NULL;
>+		
>+	if (!rtnl_trylock())
>+		return restart_syscall();
> 
> 	if (bond->dev->flags & IFF_UP) {
> 		pr_err("%s: Unable to update LACP rate because interface is up.\n",
>@@ -804,6 +809,13 @@ static ssize_t bonding_store_lacp(struct device *d,
> 
> 	if ((new_value == 1) || (new_value == 0)) {
> 		bond->params.lacp_fast = new_value;
>+		bond_for_each_slave(bond, slave, i) {

you should hold read_lock(&bond->lock) when you iterate over slaves

>+			port = &(slave->ad_info.port);
>+			if (new_value)
>+				port->actor_oper_port_state |= AD_STATE_LACP_TIMEOUT;
>+			else
>+				port->actor_oper_port_state &= ~AD_STATE_LACP_TIMEOUT;
>+		}
> 		pr_info("%s: Setting LACP rate to %s (%d).\n",
> 			bond->dev->name, bond_lacp_tbl[new_value].modename,
> 			new_value);
>@@ -813,6 +825,7 @@ static ssize_t bonding_store_lacp(struct device *d,
> 		ret = -EINVAL;
> 	}
> out:
>+	rtnl_unlock();
> 	return ret;
> }
> static DEVICE_ATTR(lacp_rate, S_IRUGO | S_IWUSR,
>-- 
>1.7.4.4
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
