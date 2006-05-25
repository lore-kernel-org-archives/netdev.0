From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2/9] Resending NetXen 1G/10G NIC driver patch
Date: Thu, 25 May 2006 09:42:21 -0700
Message-ID: <20060525094221.18c79b3a@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.33.0605250349110.5844-100000@unmsrvr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sanjeev@netxen.com, unmproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:58772 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030264AbWEYQme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 12:42:34 -0400
To: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
In-Reply-To: <Pine.LNX.4.33.0605250349110.5844-100000@unmsrvr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 May 2006 03:51:03 -0700 (PDT)
"Linsys Contractor Amit S. Kale" <amitkale@unminc.com> wrote:

> diff -Naru linux-2.6.16.18.orig/drivers/net/netxen/netxen_nic.h linux-2.6.16.18/drivers/net/netxen/netxen_nic.h
> --- linux-2.6.16.18.orig/drivers/net/netxen/netxen_nic.h	1969-12-31 16:00:00.000000000 -0800
> +++ linux-2.6.16.18/drivers/net/netxen/netxen_nic.h	2006-05-25 02:43:22.000000000 -0700
> @@ -0,0 +1,950 @@
>
> +#define IP_ALIGNMENT_BYTES		2 /* make ip aligned on 16 bytes addr */

Please use NET_IP_ALIGN, it does the right architecture dependent
offset.

...
> +#define NETXEN_PCI_ID(X) { PCI_DEVICE(PCI_VENDOR_ID_NX, (X)) }

Nested macro's on macro's, just use PCI_DEVICE()

> +
> +#define PFX "netxen: "
> +
> +/* Note: Make sure to not call this before adapter->port is valid */
> +#if !defined(NETXEN_DEBUG)
> +#define DPRINTK(klevel, fmt, args...)	do { \
> +	} while (0)
> +#else
> +#define DPRINTK(klevel, fmt, args...)	do { \
> +	printk(KERN_##klevel PFX "%s: %s: " fmt, __FUNCTION__,\
> +		(adapter != NULL && adapter->port != NULL && \
> +		adapter->port[0] != NULL && \
> +		adapter->port[0]->netdev != NULL) ? \
> +		adapter->port[0]->netdev->name : NULL, \
> +		## args); } while(0)
> +#endif
> +

Ugh. Macro with magic variable.  if you need to keep this, pass adapter.


> +struct netdev_list {
> +	struct netdev_list *next;
> +	struct net_device *netdev;
> +};

Why not use regular list.h or simple linked list.  Even better
figure out how to not need need "list of devices at all"

> +struct netxen_port_hw {
> +	unsigned char mac_addr[MAX_ADDR_LEN];
> +	int mtu;
> +	struct pci_dev *pdev;
> +	struct netxen_port *port;
> +};

Isn't mtu redundant with dev->mtu and mac_addr redundant
with dev->dev_addr


> +/* Following structure is for specific port information    */
> +
> +#define	NETXEN_PORT_UP			0
> +#define	NETXEN_PORT_DOWN		1
> +#define	NETXEN_PORT_INITIALIAZED	2
> +#define	NETXEN_PORT_SUSPEND		3

Don't mirror port state with netdevice state because you risk
getting the two out of sync. Isn't this redundant with
netif_running()

