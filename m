From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 6/9] Resending NetXen 1G/10G NIC driver patch
Date: Thu, 25 May 2006 09:47:49 -0700
Message-ID: <20060525094749.4948a27f@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.33.0605250355260.5844-100000@unmsrvr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sanjeev@netxen.com, unmproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:9112 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030274AbWEYQr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 12:47:59 -0400
To: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
In-Reply-To: <Pine.LNX.4.33.0605250355260.5844-100000@unmsrvr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Why is this necessary. Additional private API seems like leftover
debug code.

> +int
> +netxen_nic_do_ioctl(struct netxen_adapter *adapter, void *u_data,
> +		    struct netxen_port *port)
> +{
> +	struct netxen_nic_ioctl_data data;
> +	struct netxen_nic_ioctl_data *up_data;
> +	int retval = 0;
> +	struct netxen_statistics netxen_stats;
> +
> +	up_data = (void *)u_data;
> +
> +	DPRINTK(INFO, "doing ioctl for %p\n", adapter);
> +	if (copy_from_user(&data, up_data, sizeof(data))) {
> +		/* evil user tried to crash the kernel */
> +		DPRINTK(ERR, "bad copy from userland: %d\n", (int)sizeof(data));
> +		retval = -EFAULT;
> +		goto error_out;
> +	}
> +
> +	/* Shouldn't access beyond legal limits of  "char u[64];" member */
> +	if (!data.ptr && (data.size > sizeof(data.u))) {
> +		/* evil user tried to crash the kernel */
> +		DPRINTK(ERR, "bad size: %d\n", data.size);
> +		retval = -EFAULT;
> +		goto error_out;
> +	}
> +
> +	switch (data.cmd) {
> +	case netxen_nic_cmd_pci_read:
> +		if ((retval = netxen_nic_hw_read_wx(adapter, data.off,
> +						    &(data.u), data.size)))
> +			goto error_out;
> +		if (copy_to_user((void *)&(up_data->u), &(data.u), data.size)) {
> +			DPRINTK(ERR, "bad copy to userland: %d\n",
> +				(int)sizeof(data));
> +			retval = -EFAULT;
> +			goto error_out;
> +		}
> +		data.rv = 0;
> +		break;
> +

Can't you access the same registers area with ethtool.


> +	case netxen_nic_cmd_pci_write:
> +		data.rv = netxen_nic_hw_write_wx(adapter, data.off, &(data.u),
> +						 data.size);
> +		break;
> +
> +	case netxen_nic_cmd_pci_mem_read:
> +		DPRINTK(INFO, "doing %s for %p\n",
> +			"netxen_nic_cmd_pci_mm_rd", adapter);
> +		netxen_nic_pci_mem_read(adapter, data.off, &(data.u),
> +					data.size);
> +		if (copy_to_user((void *)&(up_data->u), &(data.u), data.size)) {
> +			DPRINTK(ERR, "bad copy to userland: %d\n",
> +				(int)sizeof(data));
> +			retval = -EFAULT;
> +			goto error_out;
> +		}
> +		data.rv = 0;
> +		DPRINTK(INFO, "read %lx\n", (unsigned long)data.u);
> +		break;

PCI memory is accessible directly through sysfs for diagnostic tools.


> +	case netxen_nic_cmd_pci_mem_write:
> +		netxen_nic_pci_mem_write(adapter, data.off, &(data.u),
> +					 data.size);
> +		data.rv = 0;	/* write always succeeds */
> +		break;
> +
> +	case netxen_nic_cmd_pci_config_read:
> +		switch (data.size) {
> +		case 1:
> +			data.rv = pci_read_config_byte(adapter->ahw.pdev,
> +						       data.off,
> +						       (char *)&(data.u));
> +			break;
> +		case 2:
> +			data.rv = pci_read_config_word(adapter->ahw.pdev,
> +						       data.off,
> +						       (short *)&(data.u));
> +			break;
> +		case 4:
> +			data.rv = pci_read_config_dword(adapter->ahw.pdev,
> +							data.off,
> +							(u32 *) & (data.u));
> +			break;
> +		}
> +		if (copy_to_user((void *)&(up_data->u), &(data.u), data.size)) {
> +			DPRINTK(ERR, "bad copy to userland: %d\n",
> +				(int)sizeof(data));
> +			retval = -EFAULT;
> +			goto error_out;
> +		}
> +		break;
> +
> +	case netxen_nic_cmd_pci_config_write:
> +		switch (data.size) {
> +		case 1:
> +			data.rv = pci_write_config_byte(adapter->ahw.pdev,
> +							data.off,
> +							*(char *)&(data.u));
> +			break;
> +		case 2:
> +			data.rv = pci_write_config_word(adapter->ahw.pdev,
> +							data.off,
> +							*(short *)&(data.u));
> +			break;
> +		case 4:
> +			data.rv = pci_write_config_dword(adapter->ahw.pdev,
> +							 data.off,
> +							 *(u32 *) & (data.u));
> +			break;
> +		}
> +		break;
> +
> +	case netxen_nic_cmd_get_stats:
> +		data.rv =
> +		    netxen_nic_fill_statistics(adapter, port, &netxen_stats);
> +		if (copy_to_user
> +		    ((void *)(up_data->ptr), (void *)&netxen_stats,
> +		     sizeof(struct netxen_statistics))) {
> +			DPRINTK(ERR, "bad copy to userland: %d\n",
> +				(int)sizeof(netxen_stats));
> +			retval = -EFAULT;
> +			goto error_out;
> +		}
> +		up_data->rv = data.rv;
> +		break;
> +
> +	case netxen_nic_cmd_clear_stats:
> +		data.rv = netxen_nic_clear_statistics(adapter, port);
> +		up_data->rv = data.rv;
> +		break;
> +
> +	case netxen_nic_cmd_get_version:
> +		if (copy_to_user
> +		    ((void *)&(up_data->u), NETXEN_NIC_LINUX_VERSIONID,
> +		     sizeof(NETXEN_NIC_LINUX_VERSIONID))) {
> +			DPRINTK(ERR, "bad copy to userland: %d\n",
> +				(int)sizeof(data));
> +			retval = -EFAULT;
> +			goto error_out;
> +		}
> +		break;
> +
> +	default:
> +		DPRINTK(INFO, "bad command %d for %p\n", data.cmd, adapter);
> +		retval = -EOPNOTSUPP;
> +		goto error_out;
> +	}
> +	put_user(data.rv, &(up_data->rv));
> +	DPRINTK(INFO, "done ioctl for %p well.\n", adapter);
> +
> +      error_out:
> +	return retval;
> +}
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
