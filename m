From: Pradeep Dalvi <pradeep@linsyssoft.com>
Subject: Re: [PATCH 6/9] Resending NetXen 1G/10G NIC driver patch
Date: Fri, 26 May 2006 14:20:53 +0000
Message-ID: <1148653253.3453.109.camel@arya.linsyssoft.com>
References: <Pine.LNX.4.33.0605250355260.5844-100000@unmsrvr>
	 <20060525094749.4948a27f@dxpl.pdx.osdl.net>
Reply-To: pradeep@linsyssoft.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Sanjeev Jorapur <sanjeev@netxen.com>,
	UNM Project Staff <unmproj@linsyssoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:35691 "EHLO
	svr68.ehostpros.com") by vger.kernel.org with ESMTP
	id S1750831AbWEZOhS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 10:37:18 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060525094749.4948a27f@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -u linux-2.6.16.18/drivers/net/netxen/netxen_nic_init.c
linux-2.6.16.18/drivers/net/netxen/netxen_nic_init.c
--- linux-2.6.16.18/drivers/net/netxen/netxen_nic_init.c
2006-05-25 02:43:22.000000000 -0700
+++ linux-2.6.16.18/drivers/net/netxen/netxen_nic_init.c
2006-05-26 04:05:34.000000000 -0700
@@ -200,8 +200,8 @@
 }

 /*
- * netxen_decode_crb_addr(0 - utility to translate from internal
Phantom
- * CRB address to external PCI CRB address.
+ * netxen_decode_crb_addr(0 - utility to translate from internal
Phantom CRB address
+ * to external PCI CRB address.
  */
 unsigned long netxen_decode_crb_addr(unsigned long addr)
 {
@@ -869,7 +869,6 @@
                for (p = 0; p < adapter->ahw.max_ports; p++) {
                        nport = adapter->port[p];
                        if (netif_queue_stopped(nport->netdev)
-                           && (nport->state == NETXEN_PORT_UP)
                            && (nport->flags & NETXEN_NETDEV_STATUS)) {
                                netif_wake_queue(nport->netdev);
                                nport->flags &= ~NETXEN_NETDEV_STATUS;
@@ -920,7 +919,7 @@
                }
                count++;        /* now there should be no failure */
                pdesc = &rcv_desc->desc_head[producer];
-               skb_reserve(skb, IP_ALIGNMENT_BYTES);
+               skb_reserve(skb, NET_IP_ALIGN);
                /*
                 * This will be setup when we receive the
                 * buffer after it has been filled

On Thu, 2006-05-25 at 09:47 -0700, Stephen Hemminger wrote:
> Why is this necessary. Additional private API seems like leftover
> debug code.
> 
> > +int
> > +netxen_nic_do_ioctl(struct netxen_adapter *adapter, void *u_data,
> > +		    struct netxen_port *port)
> > +{
> > +	struct netxen_nic_ioctl_data data;
> > +	struct netxen_nic_ioctl_data *up_data;
> > +	int retval = 0;
> > +	struct netxen_statistics netxen_stats;
> > +
> > +	up_data = (void *)u_data;
> > +
> > +	DPRINTK(INFO, "doing ioctl for %p\n", adapter);
> > +	if (copy_from_user(&data, up_data, sizeof(data))) {
> > +		/* evil user tried to crash the kernel */
> > +		DPRINTK(ERR, "bad copy from userland: %d\n", (int)sizeof(data));
> > +		retval = -EFAULT;
> > +		goto error_out;
> > +	}
> > +
> > +	/* Shouldn't access beyond legal limits of  "char u[64];" member */
> > +	if (!data.ptr && (data.size > sizeof(data.u))) {
> > +		/* evil user tried to crash the kernel */
> > +		DPRINTK(ERR, "bad size: %d\n", data.size);
> > +		retval = -EFAULT;
> > +		goto error_out;
> > +	}
> > +
> > +	switch (data.cmd) {
> > +	case netxen_nic_cmd_pci_read:
> > +		if ((retval = netxen_nic_hw_read_wx(adapter, data.off,
> > +						    &(data.u), data.size)))
> > +			goto error_out;
> > +		if (copy_to_user((void *)&(up_data->u), &(data.u), data.size)) {
> > +			DPRINTK(ERR, "bad copy to userland: %d\n",
> > +				(int)sizeof(data));
> > +			retval = -EFAULT;
> > +			goto error_out;
> > +		}
> > +		data.rv = 0;
> > +		break;
> > +
> 
> Can't you access the same registers area with ethtool.
> 
> 
> > +	case netxen_nic_cmd_pci_write:
> > +		data.rv = netxen_nic_hw_write_wx(adapter, data.off, &(data.u),
> > +						 data.size);
> > +		break;
> > +
> > +	case netxen_nic_cmd_pci_mem_read:
> > +		DPRINTK(INFO, "doing %s for %p\n",
> > +			"netxen_nic_cmd_pci_mm_rd", adapter);
> > +		netxen_nic_pci_mem_read(adapter, data.off, &(data.u),
> > +					data.size);
> > +		if (copy_to_user((void *)&(up_data->u), &(data.u), data.size)) {
> > +			DPRINTK(ERR, "bad copy to userland: %d\n",
> > +				(int)sizeof(data));
> > +			retval = -EFAULT;
> > +			goto error_out;
> > +		}
> > +		data.rv = 0;
> > +		DPRINTK(INFO, "read %lx\n", (unsigned long)data.u);
> > +		break;
> 
> PCI memory is accessible directly through sysfs for diagnostic tools.
> 
> 
> > +	case netxen_nic_cmd_pci_mem_write:
> > +		netxen_nic_pci_mem_write(adapter, data.off, &(data.u),
> > +					 data.size);
> > +		data.rv = 0;	/* write always succeeds */
> > +		break;
> > +
> > +	case netxen_nic_cmd_pci_config_read:
> > +		switch (data.size) {
> > +		case 1:
> > +			data.rv = pci_read_config_byte(adapter->ahw.pdev,
> > +						       data.off,
> > +						       (char *)&(data.u));
> > +			break;
> > +		case 2:
> > +			data.rv = pci_read_config_word(adapter->ahw.pdev,
> > +						       data.off,
> > +						       (short *)&(data.u));
> > +			break;
> > +		case 4:
> > +			data.rv = pci_read_config_dword(adapter->ahw.pdev,
> > +							data.off,
> > +							(u32 *) & (data.u));
> > +			break;
> > +		}
> > +		if (copy_to_user((void *)&(up_data->u), &(data.u), data.size)) {
> > +			DPRINTK(ERR, "bad copy to userland: %d\n",
> > +				(int)sizeof(data));
> > +			retval = -EFAULT;
> > +			goto error_out;
> > +		}
> > +		break;
> > +
> > +	case netxen_nic_cmd_pci_config_write:
> > +		switch (data.size) {
> > +		case 1:
> > +			data.rv = pci_write_config_byte(adapter->ahw.pdev,
> > +							data.off,
> > +							*(char *)&(data.u));
> > +			break;
> > +		case 2:
> > +			data.rv = pci_write_config_word(adapter->ahw.pdev,
> > +							data.off,
> > +							*(short *)&(data.u));
> > +			break;
> > +		case 4:
> > +			data.rv = pci_write_config_dword(adapter->ahw.pdev,
> > +							 data.off,
> > +							 *(u32 *) & (data.u));
> > +			break;
> > +		}
> > +		break;
> > +
> > +	case netxen_nic_cmd_get_stats:
> > +		data.rv =
> > +		    netxen_nic_fill_statistics(adapter, port, &netxen_stats);
> > +		if (copy_to_user
> > +		    ((void *)(up_data->ptr), (void *)&netxen_stats,
> > +		     sizeof(struct netxen_statistics))) {
> > +			DPRINTK(ERR, "bad copy to userland: %d\n",
> > +				(int)sizeof(netxen_stats));
> > +			retval = -EFAULT;
> > +			goto error_out;
> > +		}
> > +		up_data->rv = data.rv;
> > +		break;
> > +
> > +	case netxen_nic_cmd_clear_stats:
> > +		data.rv = netxen_nic_clear_statistics(adapter, port);
> > +		up_data->rv = data.rv;
> > +		break;
> > +
> > +	case netxen_nic_cmd_get_version:
> > +		if (copy_to_user
> > +		    ((void *)&(up_data->u), NETXEN_NIC_LINUX_VERSIONID,
> > +		     sizeof(NETXEN_NIC_LINUX_VERSIONID))) {
> > +			DPRINTK(ERR, "bad copy to userland: %d\n",
> > +				(int)sizeof(data));
> > +			retval = -EFAULT;
> > +			goto error_out;
> > +		}
> > +		break;
> > +
> > +	default:
> > +		DPRINTK(INFO, "bad command %d for %p\n", data.cmd, adapter);
> > +		retval = -EOPNOTSUPP;
> > +		goto error_out;
> > +	}
> > +	put_user(data.rv, &(up_data->rv));
> > +	DPRINTK(INFO, "done ioctl for %p well.\n", adapter);
> > +
> > +      error_out:
> > +	return retval;
> > +}
> > 
> > -
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
-- 
pradeep

