From: Andy Fleming <afleming@freescale.com>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Fri, 18 Mar 2005 17:14:19 -0600
Message-ID: <1925682251c3a74c9c349e15cb44d48a@freescale.com>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>	<1110334456.32556.21.camel@gaston>	<20050308194229.41c23707.davem@davemloft.net>	<1110340214.32524.32.camel@gaston> <57a429f8eb807987d88b06129861d507@freescale.com> <4230D1AC.5070506@katalix.com> <ba5d844255b5ba76b2685f9397faf689@freescale.com> <423734FB.40101@katalix.com>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
        linuxppc-embedded@ozlabs.org,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <423734FB.40101@katalix.com>
To: James Chapman <jchapman@katalix.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Mar 15, 2005, at 13:18, James Chapman wrote:

> Hi Andy,
>
> I finally found some time to review your phy abstraction code.
>
> I haven't reviewed the low level MII functions; I focused mostly on
> its API to the net driver and whether it has the necessary hooks to
> handle the various hardware that I know.
>
> General comment: nice, clean code. No serious style or Linux kernel
> core API issues that I can see.

Thank you

>
> Specific comments follow.
>
> - It isn't obvious what has to be done in net drivers to hook up this
>   code. Consider writing a Documentation/networking/phy.txt to
>   describe typical net driver code changes needed.

Oh, definitely, that's on my plate.

>
> - If a net driver is modified to use your new code, should it use any
>   functions from mii.c at all? I guess I'm unclear about the
>   relationship with mii.c.

Well, I didn't want to interfere with mii.c, since so many drivers use 
it already.  This code is designed to be separate to not break 
anything, but also to serve as a superset of the mii.c functionality.

So I think the PHY code should add the functionality provided by these 
functions:
   int mii_ethtool_sset(struct mii_if_info *mii, struct ethtool_cmd 
*ecmd)
   int mii_ethtool_gset(struct mii_if_info *mii, struct ethtool_cmd 
*ecmd)
   int generic_mii_ioctl(struct mii_if_info *mii_if,
                       struct mii_ioctl_data *mii_data, int cmd,
                       unsigned int *duplex_chg_out)

While these functions are already handled by the existing PHY code:
   unsigned int mii_check_media (struct mii_if_info *mii,
                               unsigned int ok_to_print,
                               unsigned int init_media) // determines 
duplex/speed
   int mii_link_ok (struct mii_if_info *mii) // returns link status
   int mii_nway_restart (struct mii_if_info *mii) // does this do 
anything?
   void mii_check_link (struct mii_if_info *mii) // reads link, and 
updates carrier


>
> - netif_carrier_on()/off() calls are done by mii.c on link state
>   changes. Consider doing the same inside your phy code.

That's reasonable.

>
> - Some hardware does not use a separate irq for phy but instead
>   indicates phy events via the ethernet chip's irq.
>
>   There are registered phy_driver callbacks to handle things like
>   read/clear/ack interrupt status. But if my ethernet device's phy
>   interrupt is effectively one or more bits in the ethernet chip's
>   status register (where there is no separate phy interrupt), how
>   would this hook into your phy code? For example, in the interrupt
>   handler of mv643xx_eth, we check status bits that indicate link
>   state change from the same register that indicates rx/tx packet
>   events.
>
>   Also, NAPI drivers will disable irqs and poll for tx/rx while there
>   is work to do. If they have a combined tx/rx/phy interrupt then does
>   this pose other issues for hooking up the new phy code?
>
> - What determines whether the phy driver uses interrupts or polling?

For handling such interrupts, there are two options I can see:
1) Let the PHY code share the interrupt, and it will handle it, then 
the enet driver can clear it.
2) Have the enet code handle the interrupt.  This is more difficult, in 
that it is absolutely verboten to access the PHYs from interrupt time.  
The reason I did this is to allow for PHY read/write mechanisms which 
block until an interrupt signals the operation is complete.
3) Set the PHY to poll.  This is simple, just set phydev->irq to -1 
before you call phy_start().  I will make sure to document this.

>
> - The callback registered in phy_connect() is called when phy link
>   changes are detected. It is passed a struct device*. How about
>   letting the net driver register its struct net_device* which would
>   be passed back in the callback? It is likely that the callback will
>   need access to net driver data anyway. Some net drivers will need to
>   reconfigure their ethernet chip for duplex/speed setting changes,
>   for example. Passing in the struct net_device* also lets the phy
>   code call netif_xxx() functions such as netif_carrier_on()/off()
>   mentioned earlier as well as the netif_msg_xxx message control
>   macros.

Ok.  The reason I didn't do this (actually, I did, and then changed it) 
was to allow drivers which weren't net devices to use the code.  I 
didn't have a particular use in mind.  If no one thinks that would be 
useful (I'm not sure I do), then I will change it back.

>
> - The callback function is only called by the phy timer poll as
>   far as I can tell. Shouldn't it also be called in the phy interrupt
>   handler when link state changes?

The phy interrupt is a bit awkward.  For the reasons mentioned above, I 
can't call phy read/write functions from interrupt context.  The lock 
on phydev->state has the same issue.  So the interrupt handler just 
disables the interrupt (because otherwise the PHY keeps generating it), 
and schedules a task to clear the interrupt, and tell the state machine 
there's a change.  That task just sets phydev->state to CHANGELINK.  
When interrupts are being used, this is the only way state gets 
updated.  When interrupts are off, this state gets hit every other 
interval (2 seconds, total).

>
> - Have all phy printk messages controlled by the netif_msg_ macros.

Ok

>
> - Many drivers use mii.c to implement ethtool functions. I don't see
>   equivalents in your new code.

See above...way above.


>
> - Does include/linux/phy.h represent a public API for use by net
>   drivers or is it also the internal API used by various C files in
>   your phy code?  It seems to contain some data/defs that are
>   private to the implementation. Separate some members of struct
>   phy_device into public and private parts and move the private bits
>   into separate files away from include/linux?

Hmm... So the fields I see in phy_device which are internal are:

int link_timeout;
struct work_struct phy_queue;
struct timer_list phy_timer;

I'm not convinced it's worth creating a new file, and adding a new 
level of indirection for these three fields.  However, I do see a 
couple function prototypes which probably could move into the C files, 
since they are internal functions:

void phy_change(void *data);
void phy_timer(unsigned long data);

The rest of the functions and fields are public.  Especially in the 
early stages of its existence, when I would hate to lock someone out of 
using the code in a certain way before it's clear what the best ways to 
use it are.

>
> - phy_sanitize_settings() / phy_force_reduction()
>
>   I don't understand why this is done. Are you trying to handle
>   link negotiation in software for phy chips that can't autoneg?

This code is there for the case where someone manually sets their 
controller to a certain speed/duplex setting which doesn't work.  The 
sanitize function makes sure that the next highest setting supported by 
the PHY is chosen, and the force function is used to choose a new 
setting if the selected setting did not achieve a link.

I added this functionality to enable recoverability (eg - when I change 
the setting on an NFS-rooted system, and choose one that doesn't work 
with the network I am on.  This way, the network will eventually come 
up again)

>
> Other minor notes:-
>
> - Rename register_mdiobus() --> mdiobus_register()?

Ok

>
> - I personally try to avoid listing parameter names in function header
>   comment blocks; they seldom contain useful info and they're a
>   maintenance overhead. If it would be useful for docbook-generated
>   documentation then ok, but your comment blocks don't follow that
>   format anyway.

Yeah.  I think I got stuck in the mode, early on, when I was writing 
some functions for which their parameters weren't intuitively obvious.  
For consistency, I ended up with a lot of functions with:

phydev: The phy device

Which is really just a waste of space.  I will attempt to prune out the 
ones I feel are obvious without the comment.

>
> I hope this was useful.

It was, indeed.  I will post an updated patch early next week.

Andy
