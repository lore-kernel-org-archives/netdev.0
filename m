From: Adrian Bunk <bunk@stusta.de>
Subject: drivers/net/netxen/: usage of uninitialized variables
Date: Wed, 13 Dec 2006 14:07:21 +0100
Message-ID: <20061213130721.GG3851@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964924AbWLMNHQ@vger.kernel.org>
To: amitkale@netxen.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Coverity checker spotted the following places where variables are 
being used uninitialized:


drivers/net/netxen/netxen_nic_ethtool.c:

<--  snip  -->

...
static u32 netxen_nic_get_link(struct net_device *dev)
{
        struct netxen_port *port = netdev_priv(dev);
        struct netxen_adapter *adapter = port->adapter;
        __le32 status;

        /* read which mode */
        if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
                if (adapter->phy_read
                    && adapter->phy_read(adapter, port->portnum,
                                         NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
                                         &status) != 0)
                        return -EIO;
                else
                        return (netxen_get_phy_link(status));
...

<--  snip  -->

"status" is not initiazlized if !adapter->phy_read.


drivers/net/netxen/netxen_nic_ethtool.c:

<--  snip  -->

...
static int
netxen_nic_set_settings(struct net_device *dev, struct ethtool_cmd 
*ecmd)
{
        struct netxen_port *port = netdev_priv(dev);
        struct netxen_adapter *adapter = port->adapter;
        __le32 status;

        /* read which mode */
        if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
                /* autonegotiation */
                if (adapter->phy_write
                    && adapter->phy_write(adapter, port->portnum,
                                          NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
                                          (__le32) ecmd->autoneg) != 0)
                        return -EIO;
                else
                        port->link_autoneg = ecmd->autoneg;

                if (adapter->phy_read
                    && adapter->phy_read(adapter, port->portnum,
                                         NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
                                         &status) != 0)
                        return -EIO;

                /* speed */
                switch (ecmd->speed) {
                case SPEED_10:
                        netxen_set_phy_speed(status, 0);
                        break;
                case SPEED_100:
                        netxen_set_phy_speed(status, 1);
                        break;
                case SPEED_1000:
                        netxen_set_phy_speed(status, 2);
                        break;
                }
...

<--  snip  -->

"status" is not initiazlized if !adapter->phy_read.


drivers/net/netxen/netxen_nic_isr.c:

<--  snip  -->

void netxen_handle_port_int(struct netxen_adapter *adapter, u32 portno,
                            u32 enable)
{
        __le32 int_src;
        struct netxen_port *port;

        /*  This should clear the interrupt source */
        if (adapter->phy_read)
                adapter->phy_read(adapter, portno,
                                  NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS,
                                  &int_src);
        if (int_src == 0) {
                DPRINTK(INFO, "No phy interrupts for port #%d\n", portno);
                return;
        }
...

<--  snip  -->

"int_src" is not initiazlized if !adapter->phy_read.


cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
