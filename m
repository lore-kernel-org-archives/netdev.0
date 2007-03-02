From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch 26/26] Xen-paravirt_ops: Add the Xen virtual network
	device driver.
Date: Thu, 1 Mar 2007 16:42:14 -0800
Message-ID: <20070301164214.4a40bc59@freekitty>
References: <20070301232443.195603797@goop.org>
	<20070301232529.648076372@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, Jeff Garzik <jeff@garzik.org>,
   Ian Pratt <ian.pratt@xensource.com>, netdev@vger.kernel.org,
   linux-kernel@vger.kernel.org, Chris Wright <chrisw@sous-sol.org>,
   Andi Kleen <ak@muc.de>, Zachary@smtp.osdl.org,
   virtualization@lists.osdl.org, Andrew Morton <akpm@linux-foundation.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <virtualization-bounces@lists.osdl.org>
In-Reply-To: <20070301232529.648076372@goop.org>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.osdl.org>
List-Help: <mailto:virtualization-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.osdl.org?subject=subscribe>
Sender: virtualization-bounces@lists.osdl.org
Errors-To: virtualization-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

On Thu, 01 Mar 2007 15:25:09 -0800
Jeremy Fitzhardinge <jeremy@goop.org> wrote:

> The network device frontend driver allows the kernel to access network
> devices exported exported by a virtual machine containing a physical
> network device driver.
> =

> Signed-off-by: Ian Pratt <ian.pratt@xensource.com>
> Signed-off-by: Christian Limpach <Christian.Limpach@cl.cam.ac.uk>
> Signed-off-by: Chris Wright <chrisw@sous-sol.org>
> Signed-off-by: Jeremy Fitzhardinge <jeremy@xensource.com>
> Cc: netdev@vger.kernel.org
> Cc: Jeff Garzik <jeff@garzik.org>
> =

> ---
>  drivers/net/Kconfig        |   12 =

>  drivers/net/Makefile       |    2 =

>  drivers/net/xen-netfront.c | 2066 ++++++++++++++++++++++++++++++++++++++=
++++++
>  include/xen/events.h       |    2 =

>  4 files changed, 2082 insertions(+)
> =

> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2525,6 +2525,18 @@ source "drivers/atm/Kconfig"
>  =

>  source "drivers/s390/net/Kconfig"
>  =

> +config XEN_NETDEV_FRONTEND
> +	tristate "Xen network device frontend driver"
> +	depends on XEN
> +	default y
> +	help
> +	  The network device frontend driver allows the kernel to
> +	  access network devices exported exported by a virtual
> +	  machine containing a physical network device driver. The
> +	  frontend driver is intended for unprivileged guest domains;
> +	  if you are compiling a kernel for a Xen guest, you almost
> +	  certainly want to enable this.
> +
>  config ISERIES_VETH
>  	tristate "iSeries Virtual Ethernet driver support"
>  	depends on PPC_ISERIES

Might make more sense earlier in list (near other virtual devices).
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> +/*
> + * Mutually-exclusive module options to select receive data path:
> + *  rx_copy : Packets are copied by network backend into local memory
> + *  rx_flip : Page containing packet data is transferred to our ownership
> + * For fully-virtualised guests there is no option - copying must be use=
d.
> + * For paravirtualised guests, flipping is the default.
> + */
> +#ifdef CONFIG_XEN


Hey I thought this driver depended on CONFIG_XEN already?

> +static int MODPARM_rx_copy =3D 0;
> +module_param_named(rx_copy, MODPARM_rx_copy, bool, 0);
> +MODULE_PARM_DESC(rx_copy, "Copy packets from network card (rather than f=
lip)");
> +static int MODPARM_rx_flip =3D 0;
> +module_param_named(rx_flip, MODPARM_rx_flip, bool, 0);
> +MODULE_PARM_DESC(rx_flip, "Flip packets from network card (rather than c=
opy)");
> +#else
> +static const int MODPARM_rx_copy =3D 1;
> +static const int MODPARM_rx_flip =3D 0;
> +#endif


No MIXED case variable names please.


Why have two mutually exclusive values instead of just one value
with three states: 0 =3D normal, 1 =3D copy, 2 =3D flip?


> +#define DPRINTK(fmt, args...)				\
> +	pr_debug("netfront (%s:%d) " fmt,		\
> +		 __FUNCTION__, __LINE__, ##args)
> +#define IPRINTK(fmt, args...)				\
> +	printk(KERN_INFO "netfront: " fmt, ##args)
> +#define WPRINTK(fmt, args...)				\
> +	printk(KERN_WARNING "netfront: " fmt, ##args)


Could you use dev_dbg, dev_info, dev_warn instead of these macros?

> +
> +/** Send a packet on a net device to encourage switches to learn the
> + * MAC. We send a fake ARP request.
> + *
> + * @param dev device
> + * @return 0 on success, error code otherwise
> + */
Why the sudden urge to use docbook format on one internal function.


> +static int send_fake_arp(struct net_device *dev)
> +{
> +	struct sk_buff *skb;
> +	u32             src_ip, dst_ip;
> +
> +	dst_ip =3D INADDR_BROADCAST;
> +	src_ip =3D inet_select_addr(dev, dst_ip, RT_SCOPE_LINK);
> +
> +	/* No IP? Then nothing to do. */
> +	if (src_ip =3D=3D 0)
> +		return 0;
> +
> +	skb =3D arp_create(ARPOP_REPLY, ETH_P_ARP,
> +			 dst_ip, dev, src_ip,
> +			 /*dst_hw*/ NULL, /*src_hw*/ NULL,
> +			 /*target_hw*/ dev->dev_addr);
> +	if (skb =3D=3D NULL)
> +		return -ENOMEM;
> +
> +	return dev_queue_xmit(skb);
> +}

This should probably be done in generic (non driver code).
It creates lots of dependencies here.

> +/*
> + * We use this notifier to send out a fake ARP reply to reset switches a=
nd
> + * router ARP caches when an IP interface is brought up on a VIF.
> + */
> +static int
> +inetdev_notify(struct notifier_block *this, unsigned long event, void *p=
tr)
> +{
> +	struct in_ifaddr  *ifa =3D (struct in_ifaddr *)ptr;
> +	struct net_device *dev =3D ifa->ifa_dev->dev;
> +
> +	/* UP event and is it one of our devices? */
> +	if (event =3D=3D NETDEV_UP && dev->open =3D=3D network_open)
> +		(void)send_fake_arp(dev);
> +
> +	return NOTIFY_DONE;
> +}

Shouldn't just be a global kernel option for gratuitous ARP.
Doesn't seem to be unique to this driver.
With sysctl to enable it.

-- =

Stephen Hemminger <shemminger@linux-foundation.org>
