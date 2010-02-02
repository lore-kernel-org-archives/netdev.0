From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH net-next-2.6 09/13] net-caif: add CAIF netdevice
Date: Tue, 2 Feb 2010 13:37:19 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E079032A2145@eseldmw101.eemea.ericsson.se>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com> <1264028130-14364-10-git-send-email-sjur.brandeland@stericsson.com> <4B580A39.3000805@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<marcel@holtmann.org>, <stefano.babic@babic.homelinux.org>,
	<randy.dunlap@oracle.com>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.ericsson.se ([193.180.251.57]:61127 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751968Ab0BBMhX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 07:37:23 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4B580A39.3000805@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick.
Sorry for late response.

Patrick McHardy wrote:
> sjur.brandeland@stericsson.com wrote:
>> +static void ipcaif_net_init(struct net_device *dev) { +	struct
>> chnl_net *priv; +	dev->netdev_ops = &netdev_ops;
>> +	dev->destructor = free_netdev;
> 
> These (especially ->destructor) should be set in the setup function.

The ipcaif_net_init is actually the setup function, but it is badly named.
I'll rename it to ipcaif_net_setup, sorry for the confusion.

> 
>> +	dev->flags |= IFF_NOARP;
>> +	dev->flags |= IFF_POINTOPOINT;
>> +	dev->needed_headroom = CAIF_NEEDED_HEADROOM;
>> +	dev->needed_tailroom = CAIF_NEEDED_TAILROOM;
>> +	dev->mtu = SIZE_MTU;
>> +	dev->tx_queue_len = CAIF_NET_DEFAULT_QUEUE_LEN;
> 
> These too I guess, its uncommon to reinitialize mtu and tx_queue_len
> when setting a device down and up again. 
> 
>> +
>> +	priv = (struct chnl_net *)netdev_priv(dev);
>> +	priv->chnl.receive = chnl_recv_cb;
>> +	priv->chnl.ctrlcmd = chnl_flowctrl_cb;
>> +	priv->netdev = dev;
>> +	priv->config.type = CAIF_CHTY_DATAGRAM;
>> +	priv->config.phy_pref = CFPHYPREF_HIGH_BW;
>> +	priv->config.priority = CAIF_PRIO_LOW;
>> +	priv->config.u.dgm.connection_id = -1; /* Insert illegal value */
>> +	priv->flowenabled = false; +
>> +	ASSERT_RTNL();
>> +	init_waitqueue_head(&priv->netmgmt_wq);
>> +	list_add(&priv->list_field, &chnl_net_list); }
> 
>> +static int chnl_net_hard_start_xmit(struct sk_buff *skb, struct
>> +net_device *dev)
> 
> static netdev_tx_t
> 
>> +{
>> +	struct chnl_net *priv;
>> +	struct cfpkt *pkt = NULL;
>> +	int len;
>> +	int result = -1;
>> +
>> +	/* Get our private data. */
>> +	priv = (struct chnl_net *)netdev_priv(dev);
>> +	if (!priv)
>> +		return -ENOSPC;
> 
> This is an impossible condition, netdev_priv() will never return NULL.
> The cast is also unnecessary.

Thanks, I'll fix this.

>> +
>> +
>> +	if (skb->len > priv->netdev->mtu) {
>> +		pr_warning("CAIF: %s(): Size of skb exceeded MTU\n", __func__);
>> +		return -ENOSPC; +	}
>> +
>> +	if (!priv->flowenabled) {
>> +		pr_debug("CAIF: %s(): dropping packets flow off\n", __func__);
>> +		return NETDEV_TX_BUSY; +	}
>> +
>> +	if (priv->config.type == CAIF_CHTY_DATAGRAM_LOOP) { +		struct
>> iphdr *hdr; +		__be32 swap;
>> +		/* Retrieve IP header. */
>> +		hdr = ip_hdr(skb);
>> +		/* Change source and destination address. */
>> +		swap = hdr->saddr;
>> +		hdr->saddr = hdr->daddr;
>> +		hdr->daddr = swap;
> 
> swap()?


The modem provides a loopback function for the CAIF link type (CAIF_CHTY_DATAGRAM_LOOP).
This is useful for testing the physical link between modem and host.
In this scenario we need to swap src and destination ip address.
I'll move this to a separate function in next patch set.

> 
> 
>> +
>> +static int ipcaif_newlink(struct net *src_net, struct net_device
>> *dev, +			  struct nlattr *tb[], struct nlattr *data[]) { +	int err;
>> +	struct chnl_net *caifdev;
>> +	ASSERT_RTNL();
>> +	caifdev = netdev_priv(dev);
>> +	caif_netlink_parms(data, &caifdev->config);
>> +	err = register_netdevice(dev);
>> +	if (err) {
>> +		pr_warning("CAIF: %s(): device rtml registration failed\n", +			 
>> __func__); +		goto out;
>> +	}
>> +	dev_hold(dev);
> 
> What is this reference used for? You don't have a dellink function,
> so this looks like a leak. 

I don't think it leaks because I do dev_put in chnl_net_uninit,
but you're right - I don't really need this. I'll remove the 
dev_hold and dev_put completely in next patch-set.


>> +static struct rtnl_link_ops ipcaif_link_ops __read_mostly = {
>> +	.kind		= "caif", +	.priv_size	= (size_t)sizeof(struct chnl_net),
> 
> Unnecessary cast.

OK, Thanks.

> 
>> +	.setup		= ipcaif_net_init,
>> +	.maxtype	= IFLA_CAIF_MAX,
>> +	.policy		= ipcaif_policy,
>> +	.newlink	= ipcaif_newlink,
>> +	.changelink	= ipcaif_changelink,
>> +	.get_size	= ipcaif_get_size,
>> +	.fill_info	= ipcaif_fill_info,
>> +
>> +};
>> +
>> +int chnl_net_ioctl(unsigned int cmd, unsigned long arg, bool
>> +from_user_land) { +	struct chnl_net *priv;
>> +	int result = -1;
>> +	struct chnl_net *dev;
>> +	struct net_device *netdevptr;
>> +	int ret;
>> +	struct ifreq ifreq;
>> +	struct ifcaif_param param;
>> +	rtnl_lock();
>> +	if (from_user_land) {
>> +		if (copy_from_user(&ifreq, (const void *)arg, sizeof(ifreq)))
>> +			return -EFAULT; +	} else
>> +		memcpy(&ifreq, (void *)arg, sizeof(ifreq));
> 
> Why do you need both an ioctl and a netlink interface?

Well, I would like to keep support for both netlink and ioctl.
Internally we are using a netlink interface, and oFono is using ioctl to create interfaces.

>> +static int __init chnl_init_module(void) {
>> +	int err = -1;
>> +	caif_register_ioctl(chnl_net_ioctl);
>> +	err = rtnl_link_register(&ipcaif_link_ops);
>> +	if (err < 0) {
>> +		rtnl_link_unregister(&ipcaif_link_ops);
> 
> You don't need to unregister on error. The ioctl should be
> unregistered I guess. 

Very well spotted, thanks. This could leave wild pointers. 


>> +static void __exit chnl_exit_module(void) {
>> +	struct chnl_net *dev = NULL;
>> +	struct list_head *list_node;
>> +	struct list_head *_tmp;
>> +	rtnl_lock();
>> +	list_for_each_safe(list_node, _tmp, &chnl_net_list) {
>> +		dev = list_entry(list_node, struct chnl_net, list_field);
>> +		delete_device(dev); +	}
>> +	rtnl_unlock();
>> +	rtnl_link_unregister(&ipcaif_link_ops);
>> +	caif_register_ioctl(NULL);
> 
> This is racy, rtnl_link_unregister() will clean up all CAIF devices,
> but the ioctl handler might register new ones after that. I'd suggest
> to drop the ioctl interface completely.  

You're right thank you, I'll fix this.

BR/Sjur
