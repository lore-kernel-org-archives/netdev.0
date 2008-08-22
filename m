From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4 2.6.28] cxgb3 - manage a private ip address for
 iSCSI
Date: Fri, 22 Aug 2008 12:08:51 -0700
Message-ID: <20080822120851.c45a90f2.akpm@linux-foundation.org>
References: <200808221838.m7MIcW6a004400@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, davem@davemloft.net, michaelc@cs.wisc.edu,
	swise@opengridcomputing.com, rdreier@cisco.com, daisyc@us.ibm.com,
	wenxiong@us.ibm.com, bhua@us.ibm.com, divy@chelsio.com,
	dm@chelsio.com, leedom@chelsio.com, kxie@chelsio.com
To: Karen Xie <kxie@chelsio.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756179AbYHVTKS@vger.kernel.org>
In-Reply-To: <200808221838.m7MIcW6a004400@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Aug 2008 11:38:32 -0700
Karen Xie <kxie@chelsio.com> wrote:

> [PATCH 1/4 2.6.28] cxgb3 - manage a private ip address for iSCSI
> 
> From: Karen Xie <kxie@chelsio.com>
> 
> Create a per port sysfs entry to pass an IP address to the NIC driver, and a control call for the iSCSI driver to grab it.
> The IP address is required in both drivers to manage ARP requests and connection set up.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/adapter.h        |    1 +
>  drivers/net/cxgb3/cxgb3_ctl_defs.h |    7 ++++
>  drivers/net/cxgb3/cxgb3_main.c     |   65 ++++++++++++++++++++++++++++++++++++
>  drivers/net/cxgb3/cxgb3_offload.c  |    6 +++
>  4 files changed, 79 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
> index 2711404..0e4fe95 100644
> --- a/drivers/net/cxgb3/adapter.h
> +++ b/drivers/net/cxgb3/adapter.h
> @@ -64,6 +64,7 @@ struct port_info {
>  	struct link_config link_config;
>  	struct net_device_stats netstats;
>  	int activity;
> +	__be32 iscsi_ipaddr;
>  };
>  
>  enum {				/* adapter flags */
> diff --git a/drivers/net/cxgb3/cxgb3_ctl_defs.h b/drivers/net/cxgb3/cxgb3_ctl_defs.h
> index 6ad9240..e171aa8 100644
> --- a/drivers/net/cxgb3/cxgb3_ctl_defs.h
> +++ b/drivers/net/cxgb3/cxgb3_ctl_defs.h
> @@ -57,6 +57,7 @@ enum {
>  	RDMA_GET_MIB		= 19,
>  
>  	GET_RX_PAGE_INFO	= 50,
> +	GET_ISCSI_IPADDR	= 51,
>  };
>  
>  /*
> @@ -86,6 +87,12 @@ struct iff_mac {
>  	u16 vlan_tag;
>  };
>  
> +/* Structure used to request a port's iSCSI IP address */
> +struct iscsi_ipaddr {
> +	struct net_device *dev;		/* the net_device */
> +	__be32 ipaddr;			/* the return iSCSI IP address */
> +};
> +
>  struct pci_dev;
>  
>  /*
> diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
> index 5447f3e..1c8952c 100644
> --- a/drivers/net/cxgb3/cxgb3_main.c
> +++ b/drivers/net/cxgb3/cxgb3_main.c
> @@ -687,6 +687,66 @@ static struct attribute *offload_attrs[] = {
>  
>  static struct attribute_group offload_attr_group = {.attrs = offload_attrs };
>  
> +static ssize_t iscsi_ipaddr_attr_show(struct device *d,
> +				      char *buf)

could fit in a single 80-col line.

> +{
> +	struct port_info *pi = netdev_priv(to_net_dev(d));
> +	__be32 a = ntohl(pi->iscsi_ipaddr);
> +
> +	return sprintf(buf, "%d.%d.%d.%d\n",
> +		       (a >> 24) & 0xff,
> +		       (a >> 16) & 0xff,
> +		       (a >>  8) & 0xff,
> +		       (a >>  0) & 0xff);

Use NIPQUAD and NIPQUAD_FMT here?

> +}
> +
> +static ssize_t iscsi_ipaddr_attr_store(struct device *d,
> +				       const char *buf, size_t len)
> +{
> +	struct port_info *pi = netdev_priv(to_net_dev(d));
> +	__be32 a = 0;

There's not really any need to use __be32 in kernel code.  Plain old
be23 is fine.

> +	unsigned long octet;
> +	const char *parse = buf;
> +	char *endp;
> +	int i;
> +
> +	for (i = 1; i <= 4; i++) {
> +		octet = simple_strtoul(parse, &endp, 10);
> +		if (endp == buf || octet > 255 ||
> +		    (i < 4 && *endp != '.') ||
> +		    (i == 4 && *endp != '\0' && *endp != '\n'))
> +			return -EINVAL;
> +		a = (a << 8) | octet;
> +		parse = endp+1;
> +	}
> +	pi->iscsi_ipaddr = htonl(a);
> +	return endp-buf;
> +}

This appears to be taking a dotted quad ipv4 address in ascii form,
turning it into a u32 while performing checking?

Surely we have a library function somewhere in networking which does
this?  If not, I'd suggest writing one. 

> +#define ISCSI_IPADDR_ATTR(name) \
> +static ssize_t show_##name(struct device *d, struct device_attribute *attr, \
> +			   char *buf) \
> +{ \
> +	return iscsi_ipaddr_attr_show(d, buf); \
> +} \
> +static ssize_t store_##name(struct device *d, struct device_attribute *attr, \
> +                            const char *buf, size_t len) \
> +{ \
> +	return iscsi_ipaddr_attr_store(d, buf, len); \
> +} \
> +static DEVICE_ATTR(name, S_IRUGO | S_IWUSR, show_##name, store_##name)
> +
> +ISCSI_IPADDR_ATTR(iscsi_ipaddr);
> +
> +static struct attribute *iscsi_offload_attrs[] = {
> +	&dev_attr_iscsi_ipaddr.attr,
> +	NULL
> +};
> +
> +static struct attribute_group iscsi_offload_attr_group = {
> +        .attrs = iscsi_offload_attrs
> +};
> +
>  /*
>   * Sends an sk_buff to an offload queue driver
>   * after dealing with any active network taps.
> @@ -1078,6 +1138,7 @@ static int cxgb_open(struct net_device *dev)
>  		if (err)
>  			printk(KERN_WARNING
>  			       "Could not initialize offload capabilities\n");
> +		sysfs_create_group(&dev->dev.kobj, &iscsi_offload_attr_group);
>  	}
>  
>  	link_start(dev);
> @@ -1100,6 +1161,9 @@ static int cxgb_close(struct net_device *dev)
>  	netif_carrier_off(dev);
>  	t3_mac_disable(&pi->mac, MAC_DIRECTION_TX | MAC_DIRECTION_RX);
>  
> +        if (is_offload(adapter) && !ofld_disable)
> +		sysfs_remove_group(&dev->dev.kobj, &iscsi_offload_attr_group);
> +
>  	spin_lock(&adapter->work_lock);	/* sync with update task */
>  	clear_bit(pi->port_id, &adapter->open_device_map);
>  	spin_unlock(&adapter->work_lock);
> @@ -2681,6 +2745,7 @@ static int __devinit init_one(struct pci_dev *pdev,
>  		pi->first_qset = i;
>  		pi->activity = 0;
>  		pi->port_id = i;
> +		pi->iscsi_ipaddr = 0;
>  		netif_carrier_off(netdev);
>  		netdev->irq = pdev->irq;
>  		netdev->mem_start = mmio_start;
> diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
> index c5b3de1..d5687dc 100644
> --- a/drivers/net/cxgb3/cxgb3_offload.c
> +++ b/drivers/net/cxgb3/cxgb3_offload.c
> @@ -407,6 +407,12 @@ static int cxgb_offload_ctl(struct t3cdev *tdev, unsigned int req, void *data)
>  		rx_page_info->page_size = tp->rx_pg_size;
>  		rx_page_info->num = tp->rx_num_pgs;
>  		break;
> +	case GET_ISCSI_IPADDR: {
> +		struct iscsi_ipaddr *p = data;
> +		struct port_info *pi = netdev_priv(p->dev);
> +		p->ipaddr = pi->iscsi_ipaddr;
> +		break;
> +	}
>  	default:
>  		return -EOPNOTSUPP;
>  	}

I'm wondering about ipv6.  Will it never ever be supported?

Even if not, it would perhaps be clearer if this was called
GET_ISCSI_IPV4ADDR?
