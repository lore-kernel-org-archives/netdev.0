From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/4] atl1: Main C file for Attansic L1 driver
Date: Mon, 20 Nov 2006 00:57:44 +0100
Message-ID: <200611200057.45274.arnd@arndb.de>
References: <20061119203050.GD29736@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, shemminger@osdl.org, romieu@fr.zoreil.com,
	csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:5373 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S933790AbWKSX54 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 18:57:56 -0500
To: Jay Cliburn <jacliburn@bellsouth.net>
In-Reply-To: <20061119203050.GD29736@osprey.hogchain.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 19 November 2006 21:30, Jay Cliburn wrote:
> This patch contains the main C file for the Attansic L1 gigabit ethernet
> adapter driver.

Just a few style comments:

> +	/* PCI config space info */
> +	hw->vendor_id = pdev->vendor;
> +	hw->device_id = pdev->device;
> +	hw->subsystem_vendor_id = pdev->subsystem_vendor;
> +	hw->subsystem_id = pdev->subsystem_device;

Do you actually need the copies of these fields? I guess you can
always access the data from pdev.

> +	size = sizeof(struct at_buffer) * (tpd_ring->count + rfd_ring->count);
> +	tpd_ring->buffer_info = kmalloc(size, GFP_KERNEL);
> +	if (unlikely(!tpd_ring->buffer_info)) {
> +		printk(KERN_WARNING "%s: kmalloc failed , size = D%d\n", 
> +			at_driver_name, size);
> +		return -ENOMEM;
> +	}
> +	rfd_ring->buffer_info =
> +	    (struct at_buffer *)(tpd_ring->buffer_info + tpd_ring->count);
> +
> +	memset(tpd_ring->buffer_info, 0, size);

Use kzalloc or kcalloc here.

> +	ring_header->desc =
> +	    pci_alloc_consistent(pdev, ring_header->size, &ring_header->dma);
> +	if (unlikely(!ring_header->desc)) {
> +		kfree(tpd_ring->buffer_info);
> +		printk(KERN_WARNING 
> +			"%s: pci_alloc_consistent failed, size = D%d\n", 
> +			at_driver_name, size);
> +		return -ENOMEM;
> +	}

Your cleanup path gets simpler if you use goto, and only one
instance of kfree at the end, instead of multiple return statements
in this function.


> +	while (!buffer_info->alloced && !next_info->alloced) {
> +		if (NULL != buffer_info->skb) {
> +			buffer_info->alloced = 1;
> +			goto next;
> +		}

Instead of 'if (NULL != buffer_info->skb)', you should write
'if (buffer_info->skb)', like you do elsewhere.

> +	      next:
> +		rfd_next_to_use = next_next;
> +		if (unlikely(++next_next == rfd_ring->count))
> +			next_next = 0;

Labels go to the start of a line.

> +#ifdef NETIF_F_HW_VLAN_TX
> +		if (adapter->vlgrp && (rrd->pkt_flg & PACKET_FLAG_VLAN_INS)) {
> +			u16 vlan_tag = (rrd->vlan_tag >> 4) |
> +			    		((rrd->vlan_tag & 7) << 13) | 
> +					((rrd->vlan_tag & 8) << 9);
> +			vlan_hwaccel_rx(skb, adapter->vlgrp, vlan_tag);
> +		} else
> +#endif

No need for the #ifdef when submitting the driver for inclusion.
In this kernel version, NETIF_F_HW_VLAN_TX is always defined.

> +static int at_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
> +{
> +	struct at_adapter *adapter = netdev_priv(netdev);
> +/*	struct mii_ioctl_data *data = (struct mii_ioctl_data *)&ifr->ifr_data;*/
> +	struct mii_ioctl_data *data = if_mii(ifr);
> +	unsigned long flags;
> +
> +	switch (cmd) {
> +	case SIOCGMIIPHY:
> +		data->phy_id = 0;
> +		break;
> +	case SIOCGMIIREG:
> +		if (!capable(CAP_NET_ADMIN))
> +			return -EPERM;
> +		spin_lock_irqsave(&adapter->stats_lock, flags);
> +		if (at_read_phy_reg
> +		    (&adapter->hw, data->reg_num & 0x1F, &data->val_out)) {
> +			spin_unlock_irqrestore(&adapter->stats_lock, flags);
> +			return -EIO;
> +		}
> +		spin_unlock_irqrestore(&adapter->stats_lock, flags);
> +		break;
> +	case SIOCSMIIREG:
> +		if (!capable(CAP_NET_ADMIN))
> +			return -EPERM;
> +		if (data->reg_num & ~(0x1F))
> +			return -EFAULT;
> +		spin_lock_irqsave(&adapter->stats_lock, flags);
> +		printk(KERN_DEBUG "%s: at_mii_ioctl write %x %x\n", 
> +			at_driver_name, data->reg_num,
> +			  data->val_in);
> +		if (at_write_phy_reg(&adapter->hw, data->reg_num, data->val_in)) {
> +			spin_unlock_irqrestore(&adapter->stats_lock, flags);
> +			return -EIO;
> +		}
> +		spin_unlock_irqrestore(&adapter->stats_lock, flags);
> +		break;
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +	return AT_SUCCESS;
> +}
> +#endif				/* SIOCGMIIPHY */

Any reason why you can't use generic_mii_ioctl?

> +      err_init_hw:
> +      err_reset:
> +      err_register:
> +      err_sw_init:
> +      err_eeprom:
> +	iounmap(adapter->hw.hw_addr);
> +      err_ioremap:
> +	free_netdev(netdev);
> +      err_alloc_etherdev:
> +	pci_release_regions(pdev);
> +	return err;

It's more common to have a single label with multiple gotos instead
of multiple labels that all go to one statement.
