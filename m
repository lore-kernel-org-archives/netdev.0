From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 26/26] Xen-paravirt_ops: Add the Xen virtual network device
 driver.
Date: Thu, 01 Mar 2007 16:56:42 -0800
Message-ID: <45E7764A.7000100@goop.org>
References: <20070301232443.195603797@goop.org>	<20070301232529.648076372@goop.org> <20070301164214.4a40bc59@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@muc.de>, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	xen-devel@lists.xensource.com, Chris Wright <chrisw@sous-sol.org>,
	Zachary Amsden <zach@vmware.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Ian Pratt <ian.pratt@xensource.com>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:60769 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751334AbXCBA4q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 19:56:46 -0500
In-Reply-To: <20070301164214.4a40bc59@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Thu, 01 Mar 2007 15:25:09 -0800
> Jeremy Fitzhardinge <jeremy@goop.org> wrote:
>
>   
>> The network device frontend driver allows the kernel to access network
>> devices exported exported by a virtual machine containing a physical
>> network device driver.
>>
>> Signed-off-by: Ian Pratt <ian.pratt@xensource.com>
>> Signed-off-by: Christian Limpach <Christian.Limpach@cl.cam.ac.uk>
>> Signed-off-by: Chris Wright <chrisw@sous-sol.org>
>> Signed-off-by: Jeremy Fitzhardinge <jeremy@xensource.com>
>> Cc: netdev@vger.kernel.org
>> Cc: Jeff Garzik <jeff@garzik.org>
>>
>> ---
>>  drivers/net/Kconfig        |   12 
>>  drivers/net/Makefile       |    2 
>>  drivers/net/xen-netfront.c | 2066 ++++++++++++++++++++++++++++++++++++++++++++
>>  include/xen/events.h       |    2 
>>  4 files changed, 2082 insertions(+)
>>
>> ===================================================================
>> --- a/drivers/net/Kconfig
>> +++ b/drivers/net/Kconfig
>> @@ -2525,6 +2525,18 @@ source "drivers/atm/Kconfig"
>>  
>>  source "drivers/s390/net/Kconfig"
>>  
>> +config XEN_NETDEV_FRONTEND
>> +	tristate "Xen network device frontend driver"
>> +	depends on XEN
>> +	default y
>> +	help
>> +	  The network device frontend driver allows the kernel to
>> +	  access network devices exported exported by a virtual
>> +	  machine containing a physical network device driver. The
>> +	  frontend driver is intended for unprivileged guest domains;
>> +	  if you are compiling a kernel for a Xen guest, you almost
>> +	  certainly want to enable this.
>> +
>>  config ISERIES_VETH
>>  	tristate "iSeries Virtual Ethernet driver support"
>>  	depends on PPC_ISERIES
>>     
>
> Might make more sense earlier in list (near other virtual devices).
>   

OK.

>
> Hey I thought this driver depended on CONFIG_XEN already?
>   

You're right.

>> +static int MODPARM_rx_copy = 0;
>> +module_param_named(rx_copy, MODPARM_rx_copy, bool, 0);
>> +MODULE_PARM_DESC(rx_copy, "Copy packets from network card (rather than flip)");
>> +static int MODPARM_rx_flip = 0;
>> +module_param_named(rx_flip, MODPARM_rx_flip, bool, 0);
>> +MODULE_PARM_DESC(rx_flip, "Flip packets from network card (rather than copy)");
>> +#else
>> +static const int MODPARM_rx_copy = 1;
>> +static const int MODPARM_rx_flip = 0;
>> +#endif
>>     
>
>
> No MIXED case variable names please.
>   

OK.

> Why have two mutually exclusive values instead of just one value
> with three states: 0 = normal, 1 = copy, 2 = flip?
>   

That does seem odd.  I'll fix it up.

>> +#define DPRINTK(fmt, args...)				\
>> +	pr_debug("netfront (%s:%d) " fmt,		\
>> +		 __FUNCTION__, __LINE__, ##args)
>> +#define IPRINTK(fmt, args...)				\
>> +	printk(KERN_INFO "netfront: " fmt, ##args)
>> +#define WPRINTK(fmt, args...)				\
>> +	printk(KERN_WARNING "netfront: " fmt, ##args)
>>     
>
>
> Could you use dev_dbg, dev_info, dev_warn instead of these macros?
>   

Yes.  I'd done that conversion elsewhere, but overlooked it here.

>> +
>> +/** Send a packet on a net device to encourage switches to learn the
>> + * MAC. We send a fake ARP request.
>> + *
>> + * @param dev device
>> + * @return 0 on success, error code otherwise
>> + */
>>     
> Why the sudden urge to use docbook format on one internal function.
>   

It probably got copied from somewhere.  I'll clean it up.

>> +static int send_fake_arp(struct net_device *dev)
>> +{
>> +	struct sk_buff *skb;
>> +	u32             src_ip, dst_ip;
>> +
>> +	dst_ip = INADDR_BROADCAST;
>> +	src_ip = inet_select_addr(dev, dst_ip, RT_SCOPE_LINK);
>> +
>> +	/* No IP? Then nothing to do. */
>> +	if (src_ip == 0)
>> +		return 0;
>> +
>> +	skb = arp_create(ARPOP_REPLY, ETH_P_ARP,
>> +			 dst_ip, dev, src_ip,
>> +			 /*dst_hw*/ NULL, /*src_hw*/ NULL,
>> +			 /*target_hw*/ dev->dev_addr);
>> +	if (skb == NULL)
>> +		return -ENOMEM;
>> +
>> +	return dev_queue_xmit(skb);
>> +}
>>     
>
> This should probably be done in generic (non driver code).
> It creates lots of dependencies here.
> [...]
> Shouldn't just be a global kernel option for gratuitous ARP.
> Doesn't seem to be unique to this driver.
> With sysctl to enable it.
>   

I agree it would be nice to not have to do this in the driver.  The
specific requirement here is to make it send a packet after resume
(which includes arriving after a migration) so that a switch can quickly
work that the machine is there.  Is there a generic mechanism for doing
this?

    J

