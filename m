From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: DSA: phy polling
Date: Tue, 22 Sep 2015 12:20:10 +0100
Message-ID: <20150922112009.GX21084@n2100.arm.linux.org.uk>
References: <20150914104254.GI21084@n2100.arm.linux.org.uk>
 <20150922021426.GE20288@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:38915 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbbIVLUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 07:20:36 -0400
Content-Disposition: inline
In-Reply-To: <20150922021426.GE20288@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 22, 2015 at 04:14:26AM +0200, Andrew Lunn wrote:
> On Mon, Sep 14, 2015 at 11:42:54AM +0100, Russell King - ARM Linux wrote:
> > Andrew,
> > 
> > I think you're the current maintainer of the Marvell DSA code, as being
> > the most recent author of changes to it. :)
> 
> Hi Russell
> 
> Sorry for the slow reply, i've been on vacation.
> 
> Humm, i suppose i might be the defacto Maintainer for Marvell parts,
> but i've no NDA with Marvell, so no access to the data sheets etc.

Like the rest of us :(

> > I've noticed in my testing that the Marvell DSA code seems to poll the
> > internal phy link status in mv88e6xxx_poll_link(), and set the network
> > device carrier status according to the results.
> 
> Peter Korsgaard comment might be correct, the switch needs to know
> what the PHY has negotiated. Hence the use of the PPU. There are also
> comments in the code that the PPU is needed for indirect access to the
> PHY.

I'm not changing the PPU at all - all I'm doing is to remove the extra
layer of software polling which partially duplicates what the phy layer
is already doing with its own polling.

The poll_link code is reading the port PCS control register and the
port status register, and using that to (a) control the netdev carrier
state, and (b) printing the link state.

Meanwhile, the PHY layer is polling the PHY that we created for the
port, decoding its registers, and controlling the same netdev carrier
state, parsing the standard MII register set to get the speed, duplex
and other parameters, and dsa_slave_adjust_link() is the printing the
new link state.  This then goes on to program the switch port via
mv88e6xxx_adjust_link() if necessary.

So, it's the PHY layer which is doing all the real work, the poll_link
code is just a duplication.

My current patch for this looks like this, and it's what I'm running
against the 88E6176 switch.  Link state is detected via the phy layer
and everything appears to work fine.

I think mv88e6060_poll_link() in drivers/net/dsa/mv88e6060.c can go the
same way too (it seems to be mostly the same as the code below, except
it doesn't support gigabit).  That would mean there's no users of the
.poll_link method in drivers/net/dsa - and that probably means the link
polling code in net/dsa can also be removed.

 drivers/net/dsa/mv88e6123_61_65.c |  1 -
 drivers/net/dsa/mv88e6131.c       |  1 -
 drivers/net/dsa/mv88e6171.c       |  1 -
 drivers/net/dsa/mv88e6352.c       |  1 -
 drivers/net/dsa/mv88e6xxx.c       | 67 ---------------------------------------
 drivers/net/dsa/mv88e6xxx.h       |  1 -
 6 files changed, 72 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index 3de2a6d73fdc..4bcfd683bbea 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -125,7 +125,6 @@ struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 	.set_addr		= mv88e6xxx_set_addr_indirect,
 	.phy_read		= mv88e6xxx_phy_read,
 	.phy_write		= mv88e6xxx_phy_write,
-	.poll_link		= mv88e6xxx_poll_link,
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 3e8386529965..c73121c8f155 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -178,7 +178,6 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.set_addr		= mv88e6xxx_set_addr_direct,
 	.phy_read		= mv88e6131_phy_read,
 	.phy_write		= mv88e6131_phy_write,
-	.poll_link		= mv88e6xxx_poll_link,
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index c2daaf087761..c95cfab56a4f 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -104,7 +104,6 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.set_addr		= mv88e6xxx_set_addr_indirect,
 	.phy_read		= mv88e6xxx_phy_read_indirect,
 	.phy_write		= mv88e6xxx_phy_write_indirect,
-	.poll_link		= mv88e6xxx_poll_link,
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 1f5129c105fb..37367060676f 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -324,7 +324,6 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.set_addr		= mv88e6xxx_set_addr_indirect,
 	.phy_read		= mv88e6xxx_phy_read_indirect,
 	.phy_write		= mv88e6xxx_phy_write_indirect,
-	.poll_link		= mv88e6xxx_poll_link,
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index f8baa897d1a0..c6683f65b125 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -388,73 +388,6 @@ int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
 }
 #endif
 
-void mv88e6xxx_poll_link(struct dsa_switch *ds)
-{
-	int i;
-
-	for (i = 0; i < DSA_MAX_PORTS; i++) {
-		struct net_device *dev;
-		int uninitialized_var(port_status);
-		int pcs_ctrl;
-		int link;
-		int speed;
-		int duplex;
-		int fc;
-
-		dev = ds->ports[i];
-		if (dev == NULL)
-			continue;
-
-		pcs_ctrl = mv88e6xxx_reg_read(ds, REG_PORT(i), PORT_PCS_CTRL);
-		if (pcs_ctrl < 0 || pcs_ctrl & PORT_PCS_CTRL_FORCE_LINK)
-			continue;
-
-		link = 0;
-		if (dev->flags & IFF_UP) {
-			port_status = mv88e6xxx_reg_read(ds, REG_PORT(i),
-							 PORT_STATUS);
-			if (port_status < 0)
-				continue;
-
-			link = !!(port_status & PORT_STATUS_LINK);
-		}
-
-		if (!link) {
-			if (netif_carrier_ok(dev)) {
-				netdev_info(dev, "link down\n");
-				netif_carrier_off(dev);
-			}
-			continue;
-		}
-
-		switch (port_status & PORT_STATUS_SPEED_MASK) {
-		case PORT_STATUS_SPEED_10:
-			speed = 10;
-			break;
-		case PORT_STATUS_SPEED_100:
-			speed = 100;
-			break;
-		case PORT_STATUS_SPEED_1000:
-			speed = 1000;
-			break;
-		default:
-			speed = -1;
-			break;
-		}
-		duplex = (port_status & PORT_STATUS_DUPLEX) ? 1 : 0;
-		fc = (port_status & PORT_STATUS_PAUSE_EN) ? 1 : 0;
-
-		if (!netif_carrier_ok(dev)) {
-			netdev_info(dev,
-				    "link up, %d Mb/s, %s duplex, flow control %sabled\n",
-				    speed,
-				    duplex ? "full" : "half",
-				    fc ? "en" : "dis");
-			netif_carrier_on(dev);
-		}
-	}
-}
-
 static bool mv88e6xxx_6065_family(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 9b6f3d9d5ae1..d94a4e134ee2 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -442,7 +442,6 @@ void mv88e6xxx_ppu_state_init(struct dsa_switch *ds);
 int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum);
 int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
 			    int regnum, u16 val);
-void mv88e6xxx_poll_link(struct dsa_switch *ds);
 void mv88e6xxx_get_strings(struct dsa_switch *ds, int port, uint8_t *data);
 void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds, int port,
 				 uint64_t *data);


-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
