From: James Chapman <jchapman@katalix.com>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Tue, 15 Mar 2005 19:18:19 +0000
Message-ID: <423734FB.40101@katalix.com>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>	<1110334456.32556.21.camel@gaston>	<20050308194229.41c23707.davem@davemloft.net>	<1110340214.32524.32.camel@gaston> <57a429f8eb807987d88b06129861d507@freescale.com> <4230D1AC.5070506@katalix.com> <ba5d844255b5ba76b2685f9397faf689@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
        linuxppc-embedded@ozlabs.org,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <ba5d844255b5ba76b2685f9397faf689@freescale.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Andy,

I finally found some time to review your phy abstraction code.

I haven't reviewed the low level MII functions; I focused mostly on
its API to the net driver and whether it has the necessary hooks to
handle the various hardware that I know.

General comment: nice, clean code. No serious style or Linux kernel
core API issues that I can see.

Specific comments follow.

- It isn't obvious what has to be done in net drivers to hook up this
   code. Consider writing a Documentation/networking/phy.txt to
   describe typical net driver code changes needed.

- If a net driver is modified to use your new code, should it use any
   functions from mii.c at all? I guess I'm unclear about the
   relationship with mii.c.

- netif_carrier_on()/off() calls are done by mii.c on link state
   changes. Consider doing the same inside your phy code.

- Some hardware does not use a separate irq for phy but instead
   indicates phy events via the ethernet chip's irq.

   There are registered phy_driver callbacks to handle things like
   read/clear/ack interrupt status. But if my ethernet device's phy
   interrupt is effectively one or more bits in the ethernet chip's
   status register (where there is no separate phy interrupt), how
   would this hook into your phy code? For example, in the interrupt
   handler of mv643xx_eth, we check status bits that indicate link
   state change from the same register that indicates rx/tx packet
   events.

   Also, NAPI drivers will disable irqs and poll for tx/rx while there
   is work to do. If they have a combined tx/rx/phy interrupt then does
   this pose other issues for hooking up the new phy code?

- What determines whether the phy driver uses interrupts or polling?

- The callback registered in phy_connect() is called when phy link
   changes are detected. It is passed a struct device*. How about
   letting the net driver register its struct net_device* which would
   be passed back in the callback? It is likely that the callback will
   need access to net driver data anyway. Some net drivers will need to
   reconfigure their ethernet chip for duplex/speed setting changes,
   for example. Passing in the struct net_device* also lets the phy
   code call netif_xxx() functions such as netif_carrier_on()/off()
   mentioned earlier as well as the netif_msg_xxx message control
   macros.

- The callback function is only called by the phy timer poll as
   far as I can tell. Shouldn't it also be called in the phy interrupt
   handler when link state changes?

- Have all phy printk messages controlled by the netif_msg_ macros.

- Many drivers use mii.c to implement ethtool functions. I don't see
   equivalents in your new code.

- Does include/linux/phy.h represent a public API for use by net
   drivers or is it also the internal API used by various C files in
   your phy code?  It seems to contain some data/defs that are
   private to the implementation. Separate some members of struct
   phy_device into public and private parts and move the private bits
   into separate files away from include/linux?

- phy_sanitize_settings() / phy_force_reduction()

   I don't understand why this is done. Are you trying to handle
   link negotiation in software for phy chips that can't autoneg?

Other minor notes:-

- Rename register_mdiobus() --> mdiobus_register()?

- I personally try to avoid listing parameter names in function header
   comment blocks; they seldom contain useful info and they're a
   maintenance overhead. If it would be useful for docbook-generated
   documentation then ok, but your comment blocks don't follow that
   format anyway.

I hope this was useful.

/james

Andy Fleming wrote:

> 
> On Mar 10, 2005, at 17:01, James Chapman wrote:
> 
>> Hi Andy,
>>
>> Can you elaborate on why this phy abstraction is needed?
>>
>> In your original post, you mentioned that you were going to post a
>> patch to show how your code would be hooked up in an existing net
>> driver. Did I miss it? It would help in understanding the pros and cons
>> of using genphy over using plain old mii.c.
> 
> 
> Hi James,
> 
> I haven't posted it yet, since it's a large patch (it deletes a lot of 
> code from my driver), but I can give a basic overview of how my driver 
> hooks into this code:
> 
> 1) The driver connects to the PHY when opened, calling phy_connect, and 
> then clears some bits to declare functionality it doesn't support (my 
> driver, for instance, does not support gigabit in half-duplex mode).
> 
> 2) The driver implements a function which reads the speed/duplex 
> settings, and modifies the controller registers as appropriate (also 
> bringing the carrier up and down depending on link state).  My driver 
> needs to note whether it's gigabit or not (for GMII vs MII mode), and 
> the duplex (to set the MAC full or half).
> 
> Both of those steps are very straightforward.  The PHY layer will invoke 
> the callback whenever the link state changes, so the controller will 
> always be up-to-date.
> 
> 3) The third step is the part that can make things a little messier.  My 
> driver implements a second driver for the MDIO bus, which is connected 
> through its registers.  This bus needs to be registered, and the driver 
> also needs to register.  Then some code needs to be written to deal with 
> initialization, and takedown.  I can send out that patch anytime, if 
> there's demand.
> 
>>
>> btw, I recently posted a patch to add GigE support to mii.c which is
>> in Jeff's netdev-2.6 queue. Some register definitions were added in
>> mii.h that will collide with yours.
> 
> 
> Yeah, I ran in to some of those.  I can't remember whether they're in 
> the patch or not, I suspect not.  I will have to submit a new patch to 
> cover those (I just changed my code to use your definitions).
> 
> Andy
