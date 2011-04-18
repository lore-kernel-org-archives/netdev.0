From: Jim Dykman <dykmanj@linux.vnet.ibm.com>
Subject: Re: [PATCH 24/27] HFI: hf network driver
Date: Sun, 17 Apr 2011 23:21:35 -0400
Message-ID: <4DABAE3F.4090903@linux.vnet.ibm.com>
References: <1299100213-8770-1-git-send-email-dykmanj@linux.vnet.ibm.com> <1299100213-8770-24-git-send-email-dykmanj@linux.vnet.ibm.com> <1299105612.4277.34.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	"William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	"Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	"Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	"Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:35273 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885Ab1DRDVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 23:21:41 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3I3Ac20028624
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 21:10:38 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p3I3Leor117374
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 21:21:40 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3I3Ldoo016717
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 21:21:40 -0600
In-Reply-To: <1299105612.4277.34.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/2011 5:40 PM, Ben Hutchings wrote:
> On Wed, 2011-03-02 at 16:10 -0500, dykmanj@linux.vnet.ibm.com wrote:
>> From: Jim Dykman <dykmanj@linux.vnet.ibm.com>
>>
>> It is a separate binary because it is not strictly necessary to use the HFI.
>> This patch includes module load/unload and the window open/setup with the
>> hfi device driver.
> [...]
>> diff --git a/drivers/net/hfi/ip/Kconfig b/drivers/net/hfi/ip/Kconfig
>> new file mode 100644
>> index 0000000..1a2c21d
>> --- /dev/null
>> +++ b/drivers/net/hfi/ip/Kconfig
>> @@ -0,0 +1,9 @@
>> +config HFI_IP
>> +	tristate "IP-over-HFI"
>> +	depends on NETDEVICES && INET && HFI
>> +	---help---
>> +	Support for the IP over HFI. It transports IP
>> +	packets over HFI.
>> +
>> +	To compile the driver as a module, choose M here. The module
>> +	will be called hf.
> 
> You actually call it hf_if!  But why it is not called hfi_ip?
> 
That IS a good name. Ok, we'll call it hfi_ip.

>> diff --git a/drivers/net/hfi/ip/Makefile b/drivers/net/hfi/ip/Makefile
>> new file mode 100644
>> index 0000000..59eff9b
>> --- /dev/null
>> +++ b/drivers/net/hfi/ip/Makefile
>> @@ -0,0 +1,6 @@
>> +#
>> +# Makefile for the HF IP interface for IBM eServer System p
>> +#
>> +obj-$(CONFIG_HFI_IP) += hf_if.o
>> +
>> +hf_if-objs :=	hf_if_main.o
>> diff --git a/drivers/net/hfi/ip/hf_if_main.c b/drivers/net/hfi/ip/hf_if_main.c
>> new file mode 100644
>> index 0000000..329baa1
>> --- /dev/null
>> +++ b/drivers/net/hfi/ip/hf_if_main.c
> [...]
>> +static int hf_inet_event(struct notifier_block *this,
>> +			 unsigned long event,
>> +			 void *ifa)
>> +{
>> +	struct in_device	*in_dev;
>> +	struct net_device	*netdev;
>> +
>> +	in_dev = ((struct in_ifaddr *)ifa)->ifa_dev;
>> +
>> +	netdev = in_dev->dev;
>> +
>> +	if (!net_eq(dev_net(netdev), &init_net))
>> +		return NOTIFY_DONE;
>> +
>> +	if (event == NETDEV_UP) {
>> +		struct hf_if	*net_if;
>> +
>> +		net_if = &(((struct hf_net *)(netdev_priv(netdev)))->hfif);
> 
> Try running:
> 
> # ifconfig lo down
> # ifconfig lo up
> 
> and watch the explosion.
> 
> You need to check that this is actually one of your devices.  I've done
> this by comparing netdev->netdev_ops pointer.
> 
Check added to v2.

> [...]
>> +static int hf_alloc_tx_resource(struct hf_if *net_if)
>> +{
> [...]
>> +	if (net_if->tx_fifo.addr == 0) {
>> +		printk(KERN_ERR "%s: hf_alloc_tx_resource: "
>> +			"tx_fifo fail, size=0x%x\n",
>> +			net_if->name, net_if->tx_fifo.size);
> [...]
> 
> The netdev_err() and netif_err() (etc.) macros are the standard way to
> format messages relating to a net device.
> 
Fixed in v2

> [...]
>> +static int hf_set_mac_addr(struct net_device *netdev, void *p)
>> +{
>> +	struct hf_net		*net = netdev_priv(netdev);
>> +	struct hf_if		*net_if = &(net->hfif);
>> +
>> +	/* Mac address format: 02:ClusterID:ISR:ISR:HFI_WIN:WIN */
>> +
>> +	/* Locally administered MAC address */
>> +	netdev->dev_addr[0] = 0x2; /* bit6=1, bit7=0 */
>> +
>> +	netdev->dev_addr[1] = 0x0; /* cluster id */
>> +
>> +	*(u16 *)(&(netdev->dev_addr[2])) = (u16)(net_if->isr_id);
>> +
>> +	*(u16 *)(&(netdev->dev_addr[4])) = (u16)
>> +	(((net_if->ai) << HF_MAC_HFI_SHIFT) | (net_if->client.window));
> 
> These two assignments should perhaps include an explicit cpu_to_be16().
> 
The HFIs live in a chip on the motherboard of one specific Power7 server.
Power arch is big-endian. I'm going to leave this asis.

> [...]
>> +static int hf_net_close(struct net_device *netdev)
>> +{
>> +	struct hf_net		*net = netdev_priv(netdev);
>> +	struct hf_if		*net_if = &(net->hfif);
>> +	struct hfidd_acs	*p_acs = HF_ACS(net_if);
>> +
>> +	if (net_if->state == HF_NET_CLOSE)
>> +		return 0;
> 
> I'm a bit puzzled by this.  Do you not trust the networking core to keep
> track of your device state?
> 
Removed in v2.
>> +	spin_lock(&(net_if->lock));
>> +	if (net_if->state == HF_NET_OPEN) {
>> +		hf_close_ip_window(net_if, p_acs);
>> +
>> +		hf_free_resource(net_if);
>> +	}
>> +
>> +	hf_register_hfi_ready_callback(netdev, p_acs,
>> +			HFIDD_REQ_EVENT_UNREGISTER);
>> +
>> +	net_if->state = HF_NET_CLOSE;
>> +	spin_unlock(&(net_if->lock));
>> +
>> +	return 0;
>> +}
>> +
>> +struct net_device_stats *hf_get_stats(struct net_device *netdev)
>> +{
>> +	struct hf_net	*net = netdev_priv(netdev);
>> +	struct hf_if	*net_if = &(net->hfif);
>> +
>> +	return &(net_if->net_stats);
>> +}
> 
> Please use the stats contained in struct net_device instead.
> 
Ok
>> +static int hf_change_mtu(struct net_device *netdev, int new_mtu)
>> +{
>> +	if ((new_mtu <= 0) || (new_mtu > HF_NET_MTU))
>> +		return -ERANGE;
> 
> Since this interface apparently only passes ARP and IPv4, the minimum
> MTU should be the minimum for IPv4, which is 68.  (The spec says 576 but
> the Linux IPv4 implementation uses this value.)
> 
Ok
> [...]
>> +static void hf_if_setup(struct net_device *netdev)
>> +{
>> +	netdev->type		= ARPHRD_HFI;
>> +	netdev->mtu		= HF_NET_MTU;
>> +	netdev->tx_queue_len	= 1000;
>> +	netdev->flags		= IFF_BROADCAST;
>> +	netdev->hard_header_len	= HF_HLEN;
>> +	netdev->addr_len	= HF_ALEN;
>> +	netdev->needed_headroom	= 0;
>> +
>> +	netdev->header_ops	= &hf_header_ops;
>> +	netdev->netdev_ops	= &hf_netdev_ops;
>> +
>> +	netdev->features       |= NETIF_F_SG;
> 
> You can't provide NETIF_F_SG without checksum offload.
> 
Removed in v2.
>> +	memcpy(netdev->broadcast, hfi_bcast_addr, HF_ALEN);
>> +}
>> +
>> +static struct hf_net *hf_init_netdev(int idx, int ai)
>> +{
>> +	struct net_device	*netdev;
>> +	struct hf_net		*net;
>> +	int			ii;
>> +	int			rc;
>> +	char			ifname[HF_MAX_NAME_LEN];
>> +
>> +	ii = (idx * MAX_HFIS) + ai;
>> +	sprintf(ifname, "hf%d", ii);
>> +	netdev = alloc_netdev(sizeof(struct hf_net), ifname, hf_if_setup);
>> +	if (!netdev) {
>> +		printk(KERN_ERR "hf_init_netdev: "
>> +				"alloc_netdev for hfi%d:hf%d fail\n", ai, idx);
>> +		return (struct hf_net *) -ENODEV;
> 
> Use ERR_PTR() instead of writing this sort of cast yourself.
> 
Ok.
> [...]
>> +static int __init hf_init_module(void)
>> +{
>> +	u32		idx, ai;
>> +	struct hf_net	*net;
>> +
>> +	memset(&hf_ginfo, 0, sizeof(struct hf_global_info));
>> +
>> +	for (idx = 0; idx < MAX_HF_PER_HFI; idx++) {
>> +		for (ai = 0; ai < MAX_HFIS; ai++) {
>> +			net = hf_init_netdev(idx, ai);
>> +			if (IS_ERR(net)) {
>> +				printk(KERN_ERR "hf_init_module: hf_init_netdev"
>> +						" for idx %d ai %d failed rc"
>> +						" 0x%016llx\n",
>> +						idx, ai, (u64)(PTR_ERR(net)));
> 
> Whyever are you formatting the error like this?  Use %ld and remove the
> (u64) cast.
> 
> 
Fixed in v2.
>> +
>> +				goto err_out;
>> +			}
>> +
>> +			hf_ginfo.net[idx][ai] = net;
>> +		}
>> +	}
>> +
>> +	register_inetaddr_notifier(&hf_inet_notifier);
>> +
>> +	printk(KERN_INFO "hf module loaded\n");
>> +	return 0;
>> +
>> +err_out:
>> +	for (idx = 0; idx < MAX_HF_PER_HFI; idx++) {
>> +		for (ai = 0; ai < MAX_HFIS; ai++) {
>> +			net = hf_ginfo.net[idx][ai];
>> +			if (net != NULL) {
>> +				hf_del_netdev(net);
>> +				hf_ginfo.net[idx][ai] = NULL;
>> +			}
>> +		}
>> +	}
>> +
>> +	return -EINVAL;
> 
> Use the error code you were given:
> 
> 	return PTR_ERR(net);
> 
Also fixed in v2.
>> +}
>> +
>> +static void __exit hf_cleanup_module(void)
>> +{
>> +	u32		idx, ai;
>> +	struct hf_net	*net;
>> +
>> +	unregister_inetaddr_notifier(&hf_inet_notifier);
>> +	for (idx = 0; idx < MAX_HF_PER_HFI; idx++) {
>> +		for (ai = 0; ai < MAX_HFIS; ai++) {
>> +			net = hf_ginfo.net[idx][ai];
>> +			if (net != NULL) {
>> +				hf_del_netdev(net);
>> +				hf_ginfo.net[idx][ai] = NULL;
>> +			}
>> +		}
>> +	}
>> +
>> +	return;
> 
> Redundant statement is redundant.
> 
These are all removed in v2.

>> +}
> [...]
>> --- /dev/null
>> +++ b/include/linux/hfi/hf_if.h
> [...]
>> +struct hfi_ip_extended_hdr {            /* 16B */
>> +	u32		immediate_len:7;/* In bytes */
>> +	u32		num_desc:3;     /* number of descriptors */
>> +					/* Logical Port ID: */
>> +	u32		lpid_valid:1;   /* set by sending HFI */
>> +	u32		lpid:4;         /* set by sending HFI */
>> +	/* Ethernet Service Header is 113 bits, which is 14 bytes + 1 bit */
>> +	u32		ethernet_svc_hdr_hi:1;    /* Not used by HFI */
>> +	char            ethernet_svc_hdr[12];     /* Not used by HFI */
>> +	__sum16         bcast_csum;
>> +} __packed;
> 
> It looks like you're relying on gcc to treat a set of bitfields with
> type u32 and only 16 bits assigned as having a size of 2 in a packed
> structure.  This might be true now, but I wouldn't want to rely on that
> being true for later versions.  Why not define the set of bitfields with
> type u16?
> 
They're not 16 bits long either, so I'm changing these to unsigned int

> Also the above appears to assume big-endian byte and bit order.
> 
Again, Power arch is big endian and HFI is Power-only.

> [...]
>> +#define HF_ALEN				6
>> +struct hf_hwhdr {
>> +	u8				h_dest[HF_ALEN];
>> +	u8				h_source[HF_ALEN];
>> +	__be16				h_proto;
>> +};
>> +
>> +#define HF_HLEN				sizeof(struct hf_hwhdr)
> [...]
> 
> This looks familiar!  Maybe you should just use the existing struct
> ethhdr?
> 
Ok
> Ben.
> 

Jim

