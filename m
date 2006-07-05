From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.17 1/9] NetXen: Makefile and ethtool interface
Date: Wed, 05 Jul 2006 11:34:51 -0400
Message-ID: <44ABDC1B.4020504@garzik.org>
References: <Pine.LNX.4.64.0607050602310.27969@dut46> <Pine.LNX.4.64.0607050616110.27969@dut46>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sanjeev@netxen.com, unmproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:62093 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964903AbWGEPey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2006 11:34:54 -0400
To: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
In-Reply-To: <Pine.LNX.4.64.0607050616110.27969@dut46>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linsys Contractor Amit S. Kale wrote:
> +static int
> +netxen_nic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
> +{
> +    struct netxen_port *port = netdev_priv(dev);
> +    struct netxen_adapter *adapter = port->adapter;
> +    struct netxen_niu_phy_status status;
> +
> +    /* read which mode */
> +    if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
> +        /* autonegotiation */
> +        if (netxen_nic_phy_write(port->adapter, port->portnum,
> +                     NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
> +                     (netxen_crbword_t) ecmd->autoneg) != 0)
> +            return -EIO;
> +        else
> +            port->link_autoneg = ecmd->autoneg;
> +
> +        if (netxen_nic_phy_read(port->adapter, port->portnum,
> +                    NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
> +                    (netxen_crbword_t *) & status) != 0)
> +            return -EIO;
> +
> +        /* speed */
> +        switch (ecmd->speed) {
> +        case SPEED_10:
> +            status.speed = 0;
> +            break;
> +        case SPEED_100:
> +            status.speed = 1;
> +            break;
> +        case SPEED_1000:
> +            status.speed = 2;
> +            break;
> +        }
> +        /* set duplex mode */
> +        if (ecmd->duplex == DUPLEX_HALF)
> +            status.duplex = 0;
> +        if (ecmd->duplex == DUPLEX_FULL)
> +            status.duplex = 1;
> +
> +        if (netxen_nic_phy_write(port->adapter, port->portnum,
> +                     NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
> +                     *((int *)&status)) != 0)
> +            return -EIO;
> +        else {
> +            port->link_speed = ecmd->speed;
> +            port->link_duplex = ecmd->duplex;
> +        }
> +    }
> +    if (netif_running(dev)) {
> +        dev->stop(dev);
> +        dev->open(dev);
> +    }
> +    return 0;
> +}
> +

> +/* Restart Link Process */
> +static int netxen_nic_nway_reset(struct net_device *dev)
> +{
> +    if (netif_running(dev)) {
> +        dev->stop(dev);    /* verify */
> +        dev->open(dev);
> +    }
> +    return 0;
> +}

Direct calls to dev->stop() and dev->open() are likely buggy, because 
the locking/context differs between the above quoted calls and the calls 
from inside the net stack.


> +struct ethtool_ops netxen_nic_ethtool_ops = {
> +    .get_settings = netxen_nic_get_settings,
> +    .set_settings = netxen_nic_set_settings,
> +    .get_drvinfo = netxen_nic_get_drvinfo,
> +    .get_regs_len = netxen_nic_get_regs_len,
> +    .get_regs = netxen_nic_get_regs,
> +    .get_wol = netxen_nic_get_wol,
> +    .nway_reset = netxen_nic_nway_reset,
> +    .get_link = netxen_nic_get_link,
> +    .get_eeprom_len = netxen_nic_get_eeprom_len,
> +    .get_eeprom = netxen_nic_get_eeprom,
> +    .get_ringparam = netxen_nic_get_ringparam,
> +    .get_pauseparam = netxen_nic_get_pauseparam,
> +    .set_pauseparam = netxen_nic_set_pauseparam,
> +    .get_tx_csum = ethtool_op_get_tx_csum,
> +    .set_tx_csum = ethtool_op_set_tx_csum,
> +    .get_sg = ethtool_op_get_sg,
> +    .set_sg = ethtool_op_set_sg,
> +#ifdef NETIF_F_TSO
> +    .get_tso = ethtool_op_get_tso,
> +    .set_tso = ethtool_op_set_tso,
> +#endif

kill this #ifdef

	Jeff


