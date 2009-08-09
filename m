From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] macvlan: add tap device backend
Date: Sun, 9 Aug 2009 11:02:16 +0300
Message-ID: <20090809080215.GA17200@redhat.com>
References: <1249595428-21594-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@voltaire.com>,
	"Fischer, Anna" <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Edge Virtual Bridging <evb@yahoogroups.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752475AbZHIIEA@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1249595428-21594-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 06, 2009 at 09:50:28PM +0000, Arnd Bergmann wrote:
> This driver
> -----------
> While the other approaches should work as well, doing it using a tap
> interface should give additional benefits:
> 
> * We can keep using the optimizations for jumbo frames that we have put
> into the tun/tap driver.
> 
> * No need for root permissions that packet sockets need, just use 'ip
> link add link type macvtap' to create a new device and give it the right
> permissions using udev (using one tap per macvlan netdev).
> 
> * support for multiqueue network adapters by opening the tap device
> multiple times, using one file descriptor per guest CPU/network
> queue/interrupt (if the adapter supports multiple queues on a single
> MAC address).
> 
> * support for zero-copy receive/transmit using async I/O on the tap device
> (if the adapter supports per MAC rx queues).
> 
> * The same framework in macvlan can be used to add a third backend
> into a future kernel based virtio-net implementation.

Could you split the patches up, to make this last easier?
patch 1 - export framework
patch 2 - code using it


> This version of the driver does not support any of those features,
> but they all appear possible to add ;).
> The driver is currently called 'macvtap', but I'd be more than happy
> to change that if anyone could suggest a better name. The code is
> still in an early stage and I wish I had found more time to polish
> it, but at this time, I'd first like to know if people agree with the
> basic concept at all.
> 
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Stephen Hemminger <shemminger@linux-foundation.org>
> Cc: David S. Miller" <davem@davemloft.net>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Or Gerlitz <ogerlitz@voltaire.com>
> Cc: "Fischer, Anna" <anna.fischer@hp.com>
> Cc: netdev@vger.kernel.org
> Cc: bridge@lists.linux-foundation.org
> Cc: linux-kernel@vger.kernel.org
> Cc: Edge Virtual Bridging <evb@yahoogroups.com>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> ---
> 
> The evb mailing list eats Cc headers, please make sure to keep everybody
> in your Cc list when replying there.
> ---
>  drivers/net/Kconfig   |   12 ++
>  drivers/net/Makefile  |    1 +
>  drivers/net/macvlan.c |   39 +++-----
>  drivers/net/macvlan.h |   37 +++++++
>  drivers/net/macvtap.c |  276 +++++++++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 341 insertions(+), 24 deletions(-)
>  create mode 100644 drivers/net/macvlan.h
>  create mode 100644 drivers/net/macvtap.c
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 5f6509a..0b9ac6a 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -90,6 +90,18 @@ config MACVLAN
>  	  To compile this driver as a module, choose M here: the module
>  	  will be called macvlan.
>  
> +config MACVTAP
> +	tristate "MAC-VLAN based tap driver (EXPERIMENTAL)"
> +	depends on MACVLAN
> +	help
> +	  This adds a specialized tap character device driver that is based
> +	  on the MAC-VLAN network interface, called macvtap. A macvtap device
> +	  can be added in the same way as a macvlan device, using 'type
> +	  macvlan', and then be accessed through the tap user space interface.
> +	
> +	  To compile this driver as a module, choose M here: the module
> +	  will be called macvtap.
> +
>  config EQUALIZER
>  	tristate "EQL (serial line load balancing) support"
>  	---help---
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index ead8cab..8a2d2d7 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -162,6 +162,7 @@ obj-$(CONFIG_XEN_NETDEV_FRONTEND) += xen-netfront.o
>  obj-$(CONFIG_DUMMY) += dummy.o
>  obj-$(CONFIG_IFB) += ifb.o
>  obj-$(CONFIG_MACVLAN) += macvlan.o
> +obj-$(CONFIG_MACVTAP) += macvtap.o
>  obj-$(CONFIG_DE600) += de600.o
>  obj-$(CONFIG_DE620) += de620.o
>  obj-$(CONFIG_LANCE) += lance.o
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 99eed9f..9f7dc6a 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -30,22 +30,7 @@
>  #include <linux/if_macvlan.h>
>  #include <net/rtnetlink.h>
>  
> -#define MACVLAN_HASH_SIZE	(1 << BITS_PER_BYTE)
> -
> -struct macvlan_port {
> -	struct net_device	*dev;
> -	struct hlist_head	vlan_hash[MACVLAN_HASH_SIZE];
> -	struct list_head	vlans;
> -};
> -
> -struct macvlan_dev {
> -	struct net_device	*dev;
> -	struct list_head	list;
> -	struct hlist_node	hlist;
> -	struct macvlan_port	*port;
> -	struct net_device	*lowerdev;
> -};
> -
> +#include "macvlan.h"
>  
>  static struct macvlan_dev *macvlan_hash_lookup(const struct macvlan_port *port,
>  					       const unsigned char *addr)
> @@ -135,7 +120,7 @@ static void macvlan_broadcast(struct sk_buff *skb,
>  			else
>  				nskb->pkt_type = PACKET_MULTICAST;
>  
> -			netif_rx(nskb);
> +			vlan->receive(nskb);
>  		}
>  	}
>  }
> @@ -180,11 +165,11 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
>  	skb->dev = dev;
>  	skb->pkt_type = PACKET_HOST;
>  
> -	netif_rx(skb);
> +	vlan->receive(skb);
>  	return NULL;
>  }
>  
> -static int macvlan_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +int macvlan_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	const struct macvlan_dev *vlan = netdev_priv(dev);
>  	unsigned int len = skb->len;
> @@ -202,6 +187,7 @@ static int macvlan_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	}
>  	return NETDEV_TX_OK;
>  }
> +EXPORT_SYMBOL_GPL(macvlan_start_xmit);
>  
>  static int macvlan_hard_header(struct sk_buff *skb, struct net_device *dev,
>  			       unsigned short type, const void *daddr,
> @@ -412,7 +398,7 @@ static const struct net_device_ops macvlan_netdev_ops = {
>  	.ndo_validate_addr	= eth_validate_addr,
>  };
>  
> -static void macvlan_setup(struct net_device *dev)
> +void macvlan_setup(struct net_device *dev)
>  {
>  	ether_setup(dev);
>  
> @@ -423,6 +409,7 @@ static void macvlan_setup(struct net_device *dev)
>  	dev->ethtool_ops	= &macvlan_ethtool_ops;
>  	dev->tx_queue_len	= 0;
>  }
> +EXPORT_SYMBOL_GPL(macvlan_setup);
>  
>  static int macvlan_port_create(struct net_device *dev)
>  {
> @@ -472,7 +459,7 @@ static void macvlan_transfer_operstate(struct net_device *dev)
>  	}
>  }
>  
> -static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
> +int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
>  {
>  	if (tb[IFLA_ADDRESS]) {
>  		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
> @@ -482,9 +469,10 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
>  	}
>  	return 0;
>  }
> +EXPORT_SYMBOL_GPL(macvlan_validate);
>  
> -static int macvlan_newlink(struct net_device *dev,
> -			   struct nlattr *tb[], struct nlattr *data[])
> +int macvlan_newlink(struct net_device *dev,
> +		    struct nlattr *tb[], struct nlattr *data[])
>  {
>  	struct macvlan_dev *vlan = netdev_priv(dev);
>  	struct macvlan_port *port;
> @@ -524,6 +512,7 @@ static int macvlan_newlink(struct net_device *dev,
>  	vlan->lowerdev = lowerdev;
>  	vlan->dev      = dev;
>  	vlan->port     = port;
> +	vlan->receive  = netif_rx;
>  
>  	err = register_netdevice(dev);
>  	if (err < 0)
> @@ -533,8 +522,9 @@ static int macvlan_newlink(struct net_device *dev,
>  	macvlan_transfer_operstate(dev);
>  	return 0;
>  }
> +EXPORT_SYMBOL_GPL(macvlan_newlink);
>  
> -static void macvlan_dellink(struct net_device *dev)
> +void macvlan_dellink(struct net_device *dev)
>  {
>  	struct macvlan_dev *vlan = netdev_priv(dev);
>  	struct macvlan_port *port = vlan->port;
> @@ -545,6 +535,7 @@ static void macvlan_dellink(struct net_device *dev)
>  	if (list_empty(&port->vlans))
>  		macvlan_port_destroy(port->dev);
>  }
> +EXPORT_SYMBOL_GPL(macvlan_dellink);
>  
>  static struct rtnl_link_ops macvlan_link_ops __read_mostly = {
>  	.kind		= "macvlan",
> diff --git a/drivers/net/macvlan.h b/drivers/net/macvlan.h
> new file mode 100644
> index 0000000..3f3c6c3
> --- /dev/null
> +++ b/drivers/net/macvlan.h
> @@ -0,0 +1,37 @@
> +#ifndef _MACVLAN_H
> +#define _MACVLAN_H
> +
> +#include <linux/netdevice.h>
> +#include <linux/netlink.h>
> +#include <linux/list.h>
> +
> +#define MACVLAN_HASH_SIZE	(1 << BITS_PER_BYTE)
> +
> +struct macvlan_port {
> +	struct net_device	*dev;
> +	struct hlist_head	vlan_hash[MACVLAN_HASH_SIZE];
> +	struct list_head	vlans;
> +};
> +
> +struct macvlan_dev {
> +	struct net_device	*dev;
> +	struct list_head	list;
> +	struct hlist_node	hlist;
> +	struct macvlan_port	*port;
> +	struct net_device	*lowerdev;
> +
> +	int (*receive)(struct sk_buff *skb);
> +};
> +
> +extern int macvlan_start_xmit(struct sk_buff *skb, struct net_device *dev);
> +
> +extern void macvlan_setup(struct net_device *dev);
> +
> +extern int macvlan_validate(struct nlattr *tb[], struct nlattr *data[]);
> +
> +extern int macvlan_newlink(struct net_device *dev,
> +		struct nlattr *tb[], struct nlattr *data[]);
> +
> +extern void macvlan_dellink(struct net_device *dev);
> +
> +#endif /* _MACVLAN_H */
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> new file mode 100644
> index 0000000..d99bfc0
> --- /dev/null
> +++ b/drivers/net/macvtap.c
> @@ -0,0 +1,276 @@
> +#include <linux/etherdevice.h>
> +#include <linux/nsproxy.h>
> +#include <linux/module.h>
> +#include <linux/skbuff.h>
> +#include <linux/cache.h>
> +#include <linux/sched.h>
> +#include <linux/types.h>
> +#include <linux/init.h>
> +#include <linux/wait.h>
> +#include <linux/cdev.h>
> +#include <linux/fs.h>
> +
> +#include <net/net_namespace.h>
> +#include <net/rtnetlink.h>
> +
> +#include "macvlan.h"
> +
> +struct macvtap_dev {
> +	struct macvlan_dev m;
> +	struct cdev cdev;
> +	struct sk_buff_head readq;
> +	wait_queue_head_t wait;
> +};
> +
> +/*
> + * Minor number matches netdev->ifindex, so need a large value
> + */
> +static int macvtap_major;
> +#define MACVTAP_NUM_DEVS 65536
> +
> +static int macvtap_receive(struct sk_buff *skb)
> +{
> +	struct macvtap_dev *vtap = netdev_priv(skb->dev);
> +
> +	skb_queue_tail(&vtap->readq, skb);
> +	wake_up(&vtap->wait);
> +	return 0;
> +}
> +
> +static int macvtap_open(struct inode *inode, struct file *file)
> +{
> +	struct net *net = current->nsproxy->net_ns;
> +	int ifindex = iminor(inode);
> +	struct net_device *dev = dev_get_by_index(net, ifindex);
> +	int err;
> +
> +	err = -ENODEV;
> +	if (!dev)
> +		goto out1;
> +
> +	file->private_data = netdev_priv(dev);
> +	err = 0;
> +out1:
> +	return err;
> +}
> +
> +static int macvtap_release(struct inode *inode, struct file *file)
> +{
> +	struct macvtap_dev *vtap = file->private_data;
> +
> +	if (!vtap)
> +		return 0;
> +
> +	dev_put(vtap->m.dev);
> +	return 0;
> +}
> +
> +/* Get packet from user space buffer */
> +static ssize_t macvtap_get_user(struct macvtap_dev *vtap,
> +			       const struct iovec *iv, size_t count,
> +			       int noblock)
> +{
> +	struct sk_buff *skb;
> +	size_t len = count;
> +
> +	if (unlikely(len < ETH_HLEN))
> +		return -EINVAL;
> +
> +	skb = alloc_skb(NET_IP_ALIGN + len, GFP_KERNEL);
> +
> +	if (!skb) {
> +		vtap->m.dev->stats.rx_dropped++;
> +		return -ENOMEM;
> +	}
> +
> +	skb_reserve(skb, NET_IP_ALIGN);
> +	skb_put(skb, count);
> +
> +	if (skb_copy_datagram_from_iovec(skb, 0, iv, 0, len)) {
> +		vtap->m.dev->stats.rx_dropped++;
> +		kfree_skb(skb);
> +		return -EFAULT;
> +	}
> +
> +	skb_set_network_header(skb, ETH_HLEN);
> +	skb->dev = vtap->m.lowerdev;
> +
> +	macvlan_start_xmit(skb, vtap->m.dev);
> +
> +	return count;
> +}

With tap, we discovered that not limiting the number of outstanding
skbs hurts UDP performance. And the solution was to limit
the number of outstanding packets - with hacks to work around
the fact that userspace .



> +
> +static ssize_t macvtap_aio_write(struct kiocb *iocb, const struct iovec *iv,
> +			      unsigned long count, loff_t pos)
> +{
> +	struct file *file = iocb->ki_filp;
> +	ssize_t result;
> +	struct macvtap_dev *vtap = file->private_data;
> +
> +	result = macvtap_get_user(vtap, iv, iov_length(iv, count),
> +			      file->f_flags & O_NONBLOCK);
> +
> +	return result;
> +}
> +
> +/* Put packet to the user space buffer */
> +static ssize_t macvtap_put_user(struct macvtap_dev *vtap,
> +				       struct sk_buff *skb,
> +				       struct iovec *iv, int len)
> +{
> +	int ret;
> +
> +	skb_push(skb, ETH_HLEN);
> +	len = min_t(int, skb->len, len);
> +
> +	ret = skb_copy_datagram_iovec(skb, 0, iv, len);
> +
> +	vtap->m.dev->stats.rx_packets++;
> +	vtap->m.dev->stats.rx_bytes += len;

where does atomicity guarantee for these counters come from?

> +
> +	return ret ? ret : len;
> +}
> +
> +static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
> +			    unsigned long count, loff_t pos)
> +{
> +	struct file *file = iocb->ki_filp;
> +	struct macvtap_dev *vtap = file->private_data;
> +	DECLARE_WAITQUEUE(wait, current);
> +	struct sk_buff *skb;
> +	ssize_t len, ret = 0;
> +
> +	if (!vtap)
> +		return -EBADFD;
> +
> +	len = iov_length(iv, count);
> +	if (len < 0) {
> +		ret = -EINVAL;
> +		goto out;
> +	}
> +
> +	add_wait_queue(&vtap->wait, &wait);
> +	while (len) {
> +		current->state = TASK_INTERRUPTIBLE;
> +
> +		/* Read frames from the queue */
> +		if (!(skb=skb_dequeue(&vtap->readq))) {
> +			if (file->f_flags & O_NONBLOCK) {
> +				ret = -EAGAIN;
> +				break;
> +			}
> +			if (signal_pending(current)) {
> +				ret = -ERESTARTSYS;
> +				break;
> +			}
> +			/* Nothing to read, let's sleep */
> +			schedule();
> +			continue;
> +		}
> +		ret = macvtap_put_user(vtap, skb, (struct iovec *) iv, len);

Don't cast away the constness. Instead, fix macvtap_put_user
to used skb_copy_datagram_const_iovec which does not modify the iovec.

> +		kfree_skb(skb);
> +		break;
> +	}
> +
> +	current->state = TASK_RUNNING;
> +	remove_wait_queue(&vtap->wait, &wait);
> +
> +out:
> +	return ret;
> +}
> +
> +struct file_operations macvtap_fops = {
> +	.owner = THIS_MODULE,
> +	.open = macvtap_open,
> +	.release = macvtap_release,
> +	.aio_read = macvtap_aio_read,
> +	.aio_write = macvtap_aio_write,
> +	.llseek = no_llseek,
> +};
> +
> +static int macvtap_newlink(struct net_device *dev,
> +	struct nlattr *tb[], struct nlattr *data[])
> +{
> +	struct macvtap_dev *vtap = netdev_priv(dev);
> +	int err;
> +
> +	err = macvlan_newlink(dev, tb, data);
> +	if (err)
> +		goto out1;
> +
> +	cdev_init(&vtap->cdev, &macvtap_fops);
> +	vtap->cdev.owner = THIS_MODULE;
> +	err = cdev_add(&vtap->cdev, MKDEV(MAJOR(macvtap_major), dev->ifindex), 1);
> +
> +	if (err)
> +		goto out2;
> +
> +	/*
> +	 * TODO: add class dev so device node gets created automatically
> +	 * by udev.
> +	 */
> +	pr_debug("%s:%d: added cdev %d:%d for dev %s\n",
> +		__func__, __LINE__, MAJOR(macvtap_major),
> +		dev->ifindex, dev->name);
> +
> +	skb_queue_head_init(&vtap->readq);
> +	init_waitqueue_head(&vtap->wait);
> +	vtap->m.receive = macvtap_receive;
> +
> +	return 0;
> +
> +out2:
> +	macvlan_dellink(dev);
> +out1:
> +	return err;
> +}
> +
> +static void macvtap_dellink(struct net_device *dev)
> +{
> +	struct macvtap_dev *vtap = netdev_priv(dev);
> +	cdev_del(&vtap->cdev);
> +	/* TODO: kill open file descriptors */
> +	macvlan_dellink(dev);
> +}
> +
> +static struct rtnl_link_ops macvtap_link_ops __read_mostly = {
> +	.kind = "macvtap",
> +	.priv_size = sizeof(struct macvtap_dev),
> +	.setup = macvlan_setup,
> +	.validate = macvlan_validate,
> +	.newlink = macvtap_newlink,
> +	.dellink = macvtap_dellink,
> +};
> +
> +static int macvtap_init(void)
> +{
> +	int err;
> +
> +	err = alloc_chrdev_region(&macvtap_major, 0,
> +				MACVTAP_NUM_DEVS, "macvtap");
> +	if (err)
> +		goto out1;
> +
> +	err = rtnl_link_register(&macvtap_link_ops);
> +	if (err)
> +		goto out2;
> +
> +	return 0;
> +
> +out2:
> +	unregister_chrdev_region(macvtap_major, MACVTAP_NUM_DEVS);
> +out1:
> +	return err;
> +}
> +module_init(macvtap_init);
> +
> +static void macvtap_exit(void)
> +{
> +	rtnl_link_unregister(&macvtap_link_ops);
> +	unregister_chrdev_region(macvtap_major, MACVTAP_NUM_DEVS);
> +}
> +module_exit(macvtap_exit);
> +
> +MODULE_ALIAS_RTNL_LINK("macvtap");
> +MODULE_AUTHOR("Arnd Bergmann <arnd@arndb.de>");
> +MODULE_LICENSE("GPL");
> -- 
> 1.6.0.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
