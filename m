From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: [PATCH]: r8169: Message level support
Date: Sun, 27 Feb 2005 22:43:01 +0000
Message-ID: <42224CF5.5090601@phekda.gotadsl.co.uk>
References: <4220ADA6.2040506@phekda.gotadsl.co.uk> <20050226203518.GA14688@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050226203518.GA14688@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Thanks for reviewing the patch, Francois and Jeff. I'll send an updated 
version sometime in the next week.

Francois Romieu wrote:
> Jeff, can you send a ack/nack if you disagree with the remarks below ?
> 
> Richard Dawe <rich@phekda.gotadsl.co.uk> :
> [...]
> 
>>There seems to be a mixture of drivers using a bitfield and a level. 
>>Which is the currently preferred mechanism?
> 
> 
> They do not offer exactly the same range. I prefer to keep both as the
> module option is not that expensive.

OK.

[snip]
> 1 - I am not fond of shouting macro. Everything starts turnings caps.
>     Any reason to not use "dprintk" ?

(dprintk vs. DPRINTK)

I prefer macros to be uppercase, to make it obvious that they're macros. 
  But this isn't a strong preference.

I'll make it lowercase.

> 2 - Imho the driver should not poke its nose into the guts of netif_msg_xxx().
>     It defeats its whole purpose. Any objection to not use it explicitely ?

No objection at all.

In my first patch I did exactly that. But then I used the e100 driver as 
a model, which sticks its nose into the guts.

I'll use the netif_msg_xxx() macros.

> 3 - If PFX is included, we'll have a mix of printk and dprintk. My personal
>     taste would be to not include it in the definition of the macro.

I'll go with Jeff here, which is that "PFX should only be used in probe 
paths".

[snip]
> It's up to you but I'd rather see:
> #define RTL8169_DEF_MSG_ENABLE \
> 	(NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK)

I'll use that.

> [...]
> @@ -433,10 +443,10 @@ static void rtl8169_hw_start(struct net_
>  static int rtl8169_close(struct net_device *dev);
>  static void rtl8169_set_rx_mode(struct net_device *dev);
>  static void rtl8169_tx_timeout(struct net_device *dev);
> -static struct net_device_stats *rtl8169_get_stats(struct net_device *netdev);
> +static struct net_device_stats *rtl8169_get_stats(struct net_device *dev);
>  static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
>  				void __iomem *);
> -static int rtl8169_change_mtu(struct net_device *netdev, int new_mtu);
> +static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
>  static void rtl8169_down(struct net_device *dev);
>  
>  #ifdef CONFIG_R8169_NAPI
> 
> Separate patch please.

OK, will do.

[snip]
> -static void rtl8169_link_option(int idx, u8 *autoneg, u16 *speed, u8 *duplex)
> +static void rtl8169_link_option(struct net_device *dev, int idx, u8 *autoneg, u16 *speed, u8 *duplex)
>  {
> +	struct rtl8169_private *tp = netdev_priv(dev);
>  	struct {
>  		u16 speed;
>  		u8 duplex;
> 
> Why not give a struct rtl8169_private * as argument to this function ?

Er, no idea why I didn't. I'll do that. ;)

> [...]
> 
>>@@ -871,6 +881,18 @@ static void rtl8169_get_regs(struct net_
>>         spin_unlock_irqrestore(&tp->lock, flags);
>> }
>> 
>>+static u32 r8169_get_msglevel(struct net_device *dev)
>>+{
>>+	struct rtl8169_private *tp = netdev_priv(dev);
>>+	return tp->msg_enable;
>>+}
> 
> 
> 
> Variable declaration and code are always separated by an empty
> line in the current driver. Please keep it this way.

Will do.

>> 
>> 	for (p = mac_print; p->msg; p++) {
>> 		if (tp->mac_version == p->version) {
>>-			dprintk("mac_version == %s (%04d)\n", p->msg,
>>-				  p->version);
>>+			if (netif_msg_hw(tp))
>>+				printk(KERN_DEBUG
>>+				       "mac_version == %s (%04d)\n",
> 
> 
> No need to add a line: you are allowed to use the whole 80 cols range.

I think I did that for consistency with another printk that was split 
across lines.

I'll fix the case above as you'd like.

[snip]
>>@@ -1169,7 +1200,8 @@ rtl8169_init_board(struct pci_dev *pdev,
>> 	/* dev zeroed in alloc_etherdev */
>> 	dev = alloc_etherdev(sizeof (*tp));
>> 	if (dev == NULL) {
>>-		printk(KERN_ERR PFX "unable to alloc new ethernet\n");
>>+		if (debug & NETIF_MSG_PROBE)
>>+			printk(KERN_ERR PFX "unable to alloc new ethernet\n");
>> 		goto err_out;
>> 	}
>> 
> 
> 
> Can you do something like:
> 
> struct {
> 	u32 msg_enable;
> } debug;
> 
> This way it will be possible to issue netif_msg_probe(&debug).

Yes, good idea!

>>@@ -1177,10 +1209,15 @@ rtl8169_init_board(struct pci_dev *pdev,
>> 	SET_NETDEV_DEV(dev, &pdev->dev);
>> 	tp = netdev_priv(dev);
>> 
>>+	tp->msg_enable = debug;
>>+
>> 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
>> 	rc = pci_enable_device(pdev);
>> 	if (rc) {
>>-		printk(KERN_ERR PFX "%s: enable failure\n", pdev->slot_name);
>>+		if (netif_msg_probe(tp))
>>+			printk(KERN_ERR PFX
>>+			       "%s: enable failure\n",
>>+			       pdev->slot_name);
> 
> 
> Use dprintk ?

Original dprintk or the DPRINTK used in my patch? If you mean DPRINTK, 
then it wouldn't work, because DPRINTK includes dev->name. At this point 
in the code, dev->name is not defined.

Perhaps I could modifying DPRINTK (*) to use dev->name if defined, 
otherwise fall back on PFX.

(*) I'm not ignoring the future renaming of DPRINTK to dprintk. I'm just 
trying to avoid confusion when talking about this patch.

Thanks, bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek
