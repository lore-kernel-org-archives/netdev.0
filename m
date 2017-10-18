From: Andrew Lunn <andrew@lunn.ch>
Subject: [net-next] dsa: slave: support phy devices on external MII bus
Date: Wed, 18 Oct 2017 18:21:38 +0200
Message-ID: <20171018162138.GA15371@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>
To: mnhu@prevas.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:50040 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751712AbdJRQVk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 12:21:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Martin

Sorry for starting a new thread. I deleted the patchset from my mailbox.

Florian said:

> The logic goes like this:
> 
> - try to connect to the PHY via phy-handle
> - if we have a PHY we are connecting via phy-handle but we need to
>   divert MDIO reads/writes connect using its address on the diverted
>   bus
> - connect using a fixed PHY
> - finally try using the DSA slave MII bus which would connect to the switch internal PHYs

This is not quite correct. Looking at the code:

        phy_dn = of_parse_phandle(port_dn, "phy-handle", 0);
 ...

        if (phy_dn) {
                int phy_id = of_mdio_parse_addr(&slave_dev->dev, phy_dn);

                /* If this PHY address is part of phys_mii_mask, which means
                 * that we need to divert reads and writes to/from it, then we
                 * want to bind this device using the slave MII bus created by
                 * DSA to make that happen.
                 */
                if (!phy_is_fixed && phy_id >= 0 &&
                    (ds->phys_mii_mask & (1 << phy_id))) {
                        ret = dsa_slave_phy_connect(p, slave_dev, phy_id);
                        if (ret) {
                                netdev_err(slave_dev, "failed to connect to phy%d: %d\n", phy_id, ret);
                                of_node_put(phy_dn);
                                return ret;
                        }
                } else {
                        p->phy = of_phy_connect(slave_dev, phy_dn,

The first point really is:

- try to connect to the PHY via phy-handle, if the phy_id is not
valid, or if the phy_id does not map to a phy that the switch says
does not exist.

In your case, all these points are true, so it uses
dsa_slave_phy_connect().  But we actually want it to use
of_phy_connect(), which will use the correct bus.

For some Marvell chips, you cannot actually go on ds->phys_mii_mask.
These devices can have in built PHYs and SERDES interfaces which can
be assigned to ports. These SERDES interfaces could have external PHYs
connected to them, and be on the external MDIO bus. So
ds->phys_mii_mask indicates there is a PHY, but the phy-handle points
to a different phy.

So i think this code block needs to change. If we have a phy-handle,
use it.  i.e. what Florian _thinks_ it should be doing. If not, then
use dsa_slave_phy_connect().

    Andrew
