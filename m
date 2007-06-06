From: Tim Mann <mann@vmware.com>
Subject: bnx2 driver reports WoL not supported when it actually works
Date: Wed, 6 Jun 2007 16:43:50 -0700
Message-ID: <20070606164350.7b650d5e@mann-lx.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mann@vmware.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:34844 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966017AbXFFXnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 19:43:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Michael.  We have some IBM blades with a BCM5708-based dual-port
NIC that the bnx2 driver reports as not supporting wake-on-LAN.
(Ethtool says "Supports Wake-on: d".)  However, IBM says that WoL is
supported by these NICs, and in fact when I tried putting the blade
into soft-off and sending a magic packet to it, it did wake up!  I
tried both ports, and they both worked.

Some more details:  The driver identifies the NIC as follows:

Broadcom NetXtreme II BCM5708 1000Base-SX (B2) PCI-X 64-bit 133MHz found at mem da000000, IRQ 153, node addr  00145 ed6f8ea

Here's the full ethtool output:

        Supported ports: [ FIBRE ]
        Supported link modes:   1000baseT/Full 
        Supports auto-negotiation: Yes
        Advertised link modes:  1000baseT/Full 
        Advertised auto-negotiation: Yes
        Speed: 1000Mb/s
        Duplex: Full
        Port: FIBRE
        PHYAD: 2
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: d
        Wake-on: d
Cannot get message level: Function not implemented
        Link detected: yes

I added a printk to get the full contents of the chip_id register; it's
0x57081021.  So the driver is deciding that the NIC doesn't support WoL
because the SERDES bit is set in the CHIP_BOND_ID.  (It's not the later
CHIP_ID test since this NIC is a 5708_B2.)

	/* Disable WOL support if we are running on a SERDES chip. */
	if (CHIP_BOND_ID(bp) & CHIP_BOND_ID_SERDES_BIT) {
		bp->phy_flags |= PHY_SERDES_FLAG;
		bp->flags |= NO_WOL_FLAG;
		if (CHIP_NUM(bp) == CHIP_NUM_5708) {
			bp->phy_addr = 2;
			reg = REG_RD_IND(bp, bp->shmem_base +
					 BNX2_SHARED_HW_CFG_CONFIG);
			if (reg & BNX2_SHARED_HW_CFG_PHY_2_5G)
				bp->phy_flags |= PHY_2_5G_CAPABLE_FLAG;
		}
	}

	if ((CHIP_ID(bp) == CHIP_ID_5708_A0) ||
	    (CHIP_ID(bp) == CHIP_ID_5708_B0) ||
	    (CHIP_ID(bp) == CHIP_ID_5708_B1))
		bp->flags |= NO_WOL_FLAG;

It would be easy to "fix" this by commenting out the line that sets the
NO_WOL_FLAG if the SERDES bit is set, but I assume the line is there
for a reason -- I imagine there are *some* NICs that don't support WoL
if the SERDES bit is set (?).

Can you find out what the right fix is?  (Or do we need to ask IBM?)
It's important to me because my software is conservative and does not
put a machine to sleep if ethtool says that the machine doesn't have a
NIC that supports WoL.

Thanks,
-- 
Tim Mann  work: mann@vmware.com  home: tim@tim-mann.org
          http://www.vmware.com  http://tim-mann.org
