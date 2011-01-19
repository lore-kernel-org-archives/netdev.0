From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] xen network backend driver
Date: Wed, 19 Jan 2011 16:40:16 +0000
Message-ID: <1295455216.11126.39.camel@bwh-desktop>
References: <1295449318.14981.3484.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:49110 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039Ab1ASQkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 11:40:19 -0500
In-Reply-To: <1295449318.14981.3484.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-01-19 at 15:01 +0000, Ian Campbell wrote:
[...]
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index cbf0635..5b088f5 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2970,6 +2970,13 @@ config XEN_NETDEV_FRONTEND
>  	  if you are compiling a kernel for a Xen guest, you almost
>  	  certainly want to enable this.
>  
> +config XEN_NETDEV_BACKEND
> +	tristate "Xen backend network device"
> +	depends on XEN_BACKEND
> +	help
> +	  Implement the network backend driver, which passes packets
> +	  from the guest domain's frontend drivers to the network.

This is not an accurate description.  The backend driver doesn't pass
packets to 'the network' (I assume that means physical network); that's
done by a bridge or by routing.

[...]
> diff --git a/drivers/net/xen-netback/Makefile b/drivers/net/xen-netback/Makefile
> new file mode 100644
> index 0000000..e346e81
> --- /dev/null
> +++ b/drivers/net/xen-netback/Makefile
> @@ -0,0 +1,3 @@
> +obj-$(CONFIG_XEN_NETDEV_BACKEND) := xen-netback.o
> +
> +xen-netback-y := netback.o xenbus.o interface.o
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> new file mode 100644
> index 0000000..2d55ed6
> --- /dev/null
> +++ b/drivers/net/xen-netback/common.h
> @@ -0,0 +1,250 @@
> +/******************************************************************************
> + * arch/xen/drivers/netif/backend/common.h

Doesn't match the actual filename, but then why include the filename at
all?

[...]
> +#ifndef __NETIF__BACKEND__COMMON_H__
> +#define __NETIF__BACKEND__COMMON_H__

Also doesn't match the filename.

> +
> +#define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
> +
> +#include <linux/version.h>

Don't include <linux/version.h> in an in-tree driver.

[...]
> +void netif_disconnect(struct xen_netif *netif);
> +
> +void netif_set_features(struct xen_netif *netif);
> +struct xen_netif *netif_alloc(struct device *parent, domid_t domid,
> +			      unsigned int handle);
[...]

The 'netif_' prefix belongs to the networking core; you should use some
other prefix for these.

[...]
> --- /dev/null
> +++ b/drivers/net/xen-netback/interface.c
[...]
> +/*
> + * Module parameter 'queue_length':
> + *
> + * Enables queuing in the network stack when a client has run out of receive
> + * descriptors.
> + */
> +static unsigned long netbk_queue_length = 32;
> +module_param_named(queue_length, netbk_queue_length, ulong, 0644);

This can be controlled through sysfs later, so it doesn't need to be a
module parameter.

[...]
> +static int netbk_set_tx_csum(struct net_device *dev, u32 data)
> +{
> +	struct xen_netif *netif = netdev_priv(dev);
> +	if (data) {
> +		if (!netif->csum)
> +			return -ENOSYS;

Should be -EOPNOTSUPP.  Same in netbk_set_sg(), netbk_set_tso().

[...]
> +struct xen_netif *netif_alloc(struct device *parent, domid_t domid,
> +			      unsigned int handle)
> +{
[...]
> +	/*
> +	 * Initialise a dummy MAC address. We choose the numerically
> +	 * largest non-broadcast address to prevent the address getting
> +	 * stolen by an Ethernet bridge for STP purposes.
> +	 * (FE:FF:FF:FF:FF:FF)
> +	 */
> +	memset(dev->dev_addr, 0xFF, ETH_ALEN);
> +	dev->dev_addr[0] &= ~0x01;

I'm a bit dubious about this.

[...]
> --- /dev/null
> +++ b/drivers/net/xen-netback/netback.c
[...]
> +static void net_tx_action(unsigned long data);
> +
> +static void net_rx_action(unsigned long data);

The 'net_' prefix belongs to the networking core.

[...]
> +static int netif_get_page_ext(struct page *pg,
> +			      unsigned int *_group, unsigned int *_idx)

The '_' prefix is usually meant to distinguish lower-level functions or
to avoid naming conflicts in macros.  I don't see any justification for
using it here.

[...]
> +static int MODPARM_netback_kthread;
> +module_param_named(netback_kthread, MODPARM_netback_kthread, bool, 0);
> +MODULE_PARM_DESC(netback_kthread, "Use kernel thread to replace tasklet");
> +
> +/*
> + * Netback bottom half handler.
> + * dir indicates the data direction.
> + * rx: 1, tx: 0.
> + */
> +static inline void xen_netbk_bh_handler(struct xen_netbk *netbk, int dir)
> +{
> +	if (MODPARM_netback_kthread)
> +		wake_up(&netbk->kthread.netbk_action_wq);
> +	else if (dir)
> +		tasklet_schedule(&netbk->tasklet.net_rx_tasklet);
> +	else
> +		tasklet_schedule(&netbk->tasklet.net_tx_tasklet);
> +}

Ugh, please just use NAPI.

[...]
> +static struct sk_buff *netbk_copy_skb(struct sk_buff *skb)
> +{

This should be implemented in net/core/skbuff.c as a variant of
skb_copy() and pskb_copy(), sharing as much code as possible.

[...]
> +static int skb_checksum_setup(struct sk_buff *skb)

The 'skb_' prefix belongs to the networking core.

> +{
> +	struct iphdr *iph;
> +	unsigned char *th;
> +	int err = -EPROTO;
> +
> +	if (skb->protocol != htons(ETH_P_IP))
> +		goto out;
> +
> +	iph = (void *)skb->data;
> +	th = skb->data + 4 * iph->ihl;
> +	if (th >= skb_tail_pointer(skb))
> +		goto out;
> +
> +	skb->csum_start = th - skb->head;
> +	switch (iph->protocol) {
> +	case IPPROTO_TCP:
> +		skb->csum_offset = offsetof(struct tcphdr, check);
> +		break;
> +	case IPPROTO_UDP:
> +		skb->csum_offset = offsetof(struct udphdr, check);
> +		break;
> +	default:
> +		if (net_ratelimit())
> +			printk(KERN_ERR "Attempting to checksum a non-"
> +			       "TCP/UDP packet, dropping a protocol"
> +			       " %d packet", iph->protocol);

This is missing a newline, and missing any indicator of what generated
it.  Use pr_err() to cover the latter.

[...]
> +#ifdef NETBE_DEBUG_INTERRUPT
> +static irqreturn_t netif_be_dbg(int irq, void *dev_id, struct pt_regs *regs)

This wouldn't compile on anything after 2.6.18!  Clearly no-one defines
NETBE_DEBUG_INTERRUPT, and you can remove this code entirely.

[...]
> +module_init(netback_init);
[...]

No module_fini?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

