From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH]: r8169: Message level support
Date: Sat, 26 Feb 2005 21:35:18 +0100
Message-ID: <20050226203518.GA14688@electric-eye.fr.zoreil.com>
References: <4220ADA6.2040506@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
Content-Disposition: inline
In-Reply-To: <4220ADA6.2040506@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff, can you send a ack/nack if you disagree with the remarks below ?

Richard Dawe <rich@phekda.gotadsl.co.uk> :
[...]
> There seems to be a mixture of drivers using a bitfield and a level. 
> Which is the currently preferred mechanism?

They do not offer exactly the same range. I prefer to keep both as the
module option is not that expensive.

[...]
> --- linux-2.6.11-rc5/drivers/net/r8169.c.orig	2005-02-24 16:40:30.000000000 +0000
> +++ linux-2.6.11-rc5/drivers/net/r8169.c	2005-02-26 16:49:16.000000000 +0000
> @@ -79,12 +79,14 @@ VERSION 2.2LK	<2005/01/25>
>  	        printk( "Assertion failed! %s,%s,%s,line=%d\n",	\
>          	#expr,__FILE__,__FUNCTION__,__LINE__);		\
>          }
> -#define dprintk(fmt, args...)	do { printk(PFX fmt, ## args); } while (0)
>  #else
>  #define assert(expr) do {} while (0)
> -#define dprintk(fmt, args...)	do {} while (0)
>  #endif /* RTL8169_DEBUG */
>  
> +#define DPRINTK(nlevel, klevel, fmt, args...) \
> +	(void)((NETIF_MSG_##nlevel & tp->msg_enable) && \
> +	printk(KERN_##klevel PFX "%s: " fmt, dev->name, ## args))
> +

1 - I am not fond of shouting macro. Everything starts turnings caps.
    Any reason to not use "dprintk" ?
2 - Imho the driver should not poke its nose into the guts of netif_msg_xxx().
    It defeats its whole purpose. Any objection to not use it explicitely ?
3 - If PFX is included, we'll have a mix of printk and dprintk. My personal
    taste would be to not include it in the definition of the macro.

>  #define TX_BUFFS_AVAIL(tp) \
>  	(tp->dirty_tx + NUM_TX_DESC - tp->cur_tx - 1)
>  
> @@ -132,6 +134,10 @@ static int multicast_filter_limit = 32;
>  #define RTL8169_TX_TIMEOUT	(6*HZ)
>  #define RTL8169_PHY_TIMEOUT	(10*HZ)
>  
> +#define RTL8169_DEF_MSG_ENABLE (NETIF_MSG_DRV		| \
> +				NETIF_MSG_PROBE		| \
> +				NETIF_MSG_LINK)


It's up to you but I'd rather see:
#define RTL8169_DEF_MSG_ENABLE \
	(NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK)

[...]
@@ -433,10 +443,10 @@ static void rtl8169_hw_start(struct net_
 static int rtl8169_close(struct net_device *dev);
 static void rtl8169_set_rx_mode(struct net_device *dev);
 static void rtl8169_tx_timeout(struct net_device *dev);
-static struct net_device_stats *rtl8169_get_stats(struct net_device *netdev);
+static struct net_device_stats *rtl8169_get_stats(struct net_device *dev);
 static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
 				void __iomem *);
-static int rtl8169_change_mtu(struct net_device *netdev, int new_mtu);
+static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
 static void rtl8169_down(struct net_device *dev);
 
 #ifdef CONFIG_R8169_NAPI

Separate patch please.

@@ -543,14 +553,15 @@ static void rtl8169_check_link_status(st
 	spin_lock_irqsave(&tp->lock, flags);
 	if (tp->link_ok(ioaddr)) {
 		netif_carrier_on(dev);
-		printk(KERN_INFO PFX "%s: link up\n", dev->name);
+		DPRINTK(LINK, INFO, "link up\n");
 	} else
 		netif_carrier_off(dev);
 	spin_unlock_irqrestore(&tp->lock, flags);
 }
 
-static void rtl8169_link_option(int idx, u8 *autoneg, u16 *speed, u8 *duplex)
+static void rtl8169_link_option(struct net_device *dev, int idx, u8 *autoneg, u16 *speed, u8 *duplex)
 {
+	struct rtl8169_private *tp = netdev_priv(dev);
 	struct {
 		u16 speed;
 		u8 duplex;

Why not give a struct rtl8169_private * as argument to this function ?

[...]
> @@ -871,6 +881,18 @@ static void rtl8169_get_regs(struct net_
>          spin_unlock_irqrestore(&tp->lock, flags);
>  }
>  
> +static u32 r8169_get_msglevel(struct net_device *dev)
> +{
> +	struct rtl8169_private *tp = netdev_priv(dev);
> +	return tp->msg_enable;
> +}


Variable declaration and code are always separated by an empty
line in the current driver. Please keep it this way.

>  
>  	for (p = mac_print; p->msg; p++) {
>  		if (tp->mac_version == p->version) {
> -			dprintk("mac_version == %s (%04d)\n", p->msg,
> -				  p->version);
> +			if (netif_msg_hw(tp))
> +				printk(KERN_DEBUG
> +				       "mac_version == %s (%04d)\n",

No need to add a line: you are allowed to use the whole 80 cols range.

[...]
> @@ -1091,7 +1122,7 @@ static void rtl8169_phy_timer(unsigned l
>  	if (tp->link_ok(ioaddr))
>  		goto out_unlock;
>  
> -	printk(KERN_WARNING PFX "%s: PHY reset until link up\n", dev->name);
> +	DPRINTK(LINK, WARNING, "PHY reset until link up\n");
>  
>  	tp->phy_reset_enable(ioaddr);
>  
> @@ -1169,7 +1200,8 @@ rtl8169_init_board(struct pci_dev *pdev,
>  	/* dev zeroed in alloc_etherdev */
>  	dev = alloc_etherdev(sizeof (*tp));
>  	if (dev == NULL) {
> -		printk(KERN_ERR PFX "unable to alloc new ethernet\n");
> +		if (debug & NETIF_MSG_PROBE)
> +			printk(KERN_ERR PFX "unable to alloc new ethernet\n");
>  		goto err_out;
>  	}
>  

Can you do something like:

struct {
	u32 msg_enable;
} debug;

This way it will be possible to issue netif_msg_probe(&debug).

> @@ -1177,10 +1209,15 @@ rtl8169_init_board(struct pci_dev *pdev,
>  	SET_NETDEV_DEV(dev, &pdev->dev);
>  	tp = netdev_priv(dev);
>  
> +	tp->msg_enable = debug;
> +
>  	/* enable device (incl. PCI PM wakeup and hotplug setup) */
>  	rc = pci_enable_device(pdev);
>  	if (rc) {
> -		printk(KERN_ERR PFX "%s: enable failure\n", pdev->slot_name);
> +		if (netif_msg_probe(tp))
> +			printk(KERN_ERR PFX
> +			       "%s: enable failure\n",
> +			       pdev->slot_name);

Use dprintk ?

--
Ueimor
