From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFR] gianfar ethernet driver
Date: Wed, 07 Jul 2004 01:27:40 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40EB89CC.2040100@pobox.com>
References: <C681B01E-CEA9-11D8-931F-000393DBC2E8@freescale.com> <89563A5C-CFAE-11D8-BA44-000393C30512@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <kumar.gala@freescale.com>, netdev@oss.sgi.com,
        dwmw2@infradead.org, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <89563A5C-CFAE-11D8-BA44-000393C30512@freescale.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andy Fleming wrote:
>>> 7) ethtool_ops should not be kmalloc'd.
>>> +       dev_ethtool_ops =
>>> +               (struct ethtool_ops *)kmalloc(sizeof(struct 
>>> ethtool_ops),
>>> +                                             GFP_KERNEL);
> 
> 
> Is there a particular reason?  The reason I did it this way is because 
> the driver supports a 10/100 controller which does not have the RMON 
> statistics, and therefore should not read from that register space.  So 
> I needed to use different functions to fill in the statistics lists.

Just switch out one static pointer for another, once you know the 
hardware you're dealing with.  You _must_ have that knowledge anyway, 
before calling register_netdev(), otherwise you're got a race in 
initialization versus interface-up.


>>> 8) I recommend enabling _both_ hardware interrupt coalescing and NAPI,
>>> at the same time.  Several other Linux net drivers need to be changed to
>>> do this, as well
> 
> 
> Ok... but this is possible with the driver as it is.  Interrupt 
> Coalescing is runtime configurable, and NAPI is a compile-time option.  
> NAPI can sometimes hurt performance, and so we'd like to have the 
> ability to disable it for some deployments.  I guess I'm not sure what 
> change this suggestion was meant to cause.

Default hardware mitigation to on in all cases, and preferably NAPI as well.

If you see cases that hurt performance, that wants investigating.


>>> 14) surely gfar_set_mac_address() needs some sort of synchronization?
> 
> 
> I'm not sure why.  It only gets called during gfar_open(), and 
> startup_gfar() gets called after it.

Incorrect.  Set-mac-address can be called when the interface is up and 
active, such as by the bonding driver.


>>> 15) gfar_change_mtu() synchronization appears absent?
> 
> 
> I'm not exactly sure what kind of synchronization is expected here.  
> stop_gfar() and startup_gfar() do modify the appropriate hardware values.

Same conditions (and response) as set-mac-address.  These can be called 
while you're actively DMAing packets.


>>> 23) gfar_set_multi() does not appear to take into account huge
>>> multi-cast lists.  Drivers usually handle large dev->mc_count by falling
>>> back to ALLMULTI behavior.
> 
> 
> Actually, it does.  The bits which are set represent hash table values. 
>  Essentially, the MAC addr is converted to an 8-bit CRC.  This value 
> then serves as an index to the 256-bit hash table.  If the list is 
> large, then certain bits may be written twice, but if all the bits are 
> set, then the behavior is the same as in the ALLMULTI behavior -- every 
> multicast packet arrives.  It would be a mistake, IMHO, to cut it off 
> after N entries, as several of those entries could overlap in the 
> bitmap.  Clearly, the less bits which are set, the more effective the 
> hardware filter, so checking each address will, I think, always be a 
> performance win or tie (on the filtering side) over ALLMULTI

ok


>>> 24) setting IFF_MULTICAST is suspicious at best, possibly wrong:
>>> +       dev->mtu = 1500;
>>> +       dev->set_multicast_list = gfar_set_multi;
>>> +       dev->flags |= IFF_MULTICAST;
>>> +
> 
> 
> I'll believe you, but is there a reason for this?  I guess it's already 
> set, by default, so easy fix.

follow the other drivers, and behave predictably :)


>>> 28) I see you support register dump (good!), now please send the
>>> register-pretty-print patch to the ethtool package :)
> 
> 
> Heh.  Well, I haven't written that, yet.  There's actually a slight 
> problem, in that the 85xx registers are 32-bit, and refuse to be 
> accessed as bytes.  I'll be sure to look at that in the near...ish future.

Nothing wrong with accessing registers as 32-bit quantities.  That 
attribute is common to a lot of NICs.


>>> 31) infinite loops, particularly on 1-bits, are discouraged:
>>> +       /* Wait for the transaction to finish */
>>> +       while (gfar_read(&regbase->miimind) & (MIIMIND_NOTVALID |
>>> MIIMIND_BUSY))
>>> +               cpu_relax();
> 
> 
> What is the suggested method for waiting for the bus to be free?  Should 
> I timeout after some time, and bring the driver down?

it's really up to you, as it depends on the implementation platforms.

The most simple is to include a counter that counts down to zero, and 
starts some absurdly large number like 100000.


>>> 33) merge-stopper:  mii_parse_sr().  never wait for autonegotiation to
>>> complete.  it is an asynchronous operation that could exceed 30 seconds.
> 
> 
> Hmm...
> 
>>> 34) merge-stopper:  dm9161_wait().  same thing as #33.
> 
> 
> This may be a problem.  That function is there to work around an issue 
> in the PHY, wherein if you try to configure it before it has come up all 
> the way, it refuses to bring the link up.  We've sworn at this code many 
> times, but there has, as of yet, not been a good suggestion as to how we 
> can ensure that the 9161 is  ready before we configure it.

I interpret that as a driver bug :)

As common sense, regardless of phy bugs, you should not be trying to 
configure the MAC _or_ the phy in the middle of autonegotiation. 
Presumeably you are using a combination of netif_stop_queue(), 
netif_carrier_off(), and netif_device_detach() to achieve this.


>>> 35) liberally borrow code and ideas from Ben H's sungem_phy.c.
>>> Eventually we want to move to a generic phy module.
> 
> 
> Heh.  ironically, I stole liberally from the ibm_emac driver, which now 
> looks exactly like the sungem_phy code for phy handling.  A generic phy 
> module would be a good thing, and I'm even interested in helping with 
> code and/or suggestions.  If nothing else, I'll jump on the new generic 
> phy module bandwagon!

Cool.  This item #35 is more of a long term "think about it" type of 
request.  Please do not hesitate to think of ways that you could share 
code with sungem_phy.c, and/or make them both use the same API, and 
submit patches along those lines :)

It's not enough to just write a driver, help change Linux for the better :)


>  From Jamal:
> 
>>
>> 1) The check (in gfar_start_xmit()):
>>
>> Should happen much sooner - i.e before the skb is touched.
> 
> 
> I'm not sure I agree here.  What I am doing is detecting the full state 
> before an skb needs to be rejected.  I am testing the NEXT descriptor to 
> see if it is ready (if not, dirty_tx will be pointing to it).  This way, 
> I always handle any skb that is passed to gfar_start_xmit()

See my comments to jamal as well:  if you guarantee that you always have 
room on the DMA ring for an additional skb, that check should never be 
needed.

Some extremely cautious/paranoid programmers will add a check, with a 
printk noting it's a BUG (i.e. impossible) condition, such as

	if (unlikely(... no more descriptors ...)) {
		printk(KERN_ERR "%s: BUG: no room for TX\n", dev->name);
		netif_stop_queue();
		spin_unlock_irqrestore();
		return 1;
	}

	... queue TX to hardware ...

	if (no more descriptors)
		netif_stop_queue()

	spin_unlock_irqrestore()


>> 2) Also its pretty scary if you are doing:
>> txbdp->status |= TXBD_INTERRUPT for every packet.
>> Look at other drivers, they try to do this every few packets;
>> or enable tx mitigation to slow the rate  of those interupts.
> 
> 
> I don't believe this is as dire as you think.  This bit only indicates 
> that, if the conditions are right, an interrupt will be generated once 
> that descriptor is processed, and its data sent.  Conditions which 
> mitigate that are:
> 1) coalescing is on, and the timer and counter have not triggered the 
> interrupt yet
> 2) NAPI is enabled, and so interrupts are disabled after the first 
> packet arrives
> 3) NAPI is disabled, but the driver is currently handling a previous 
> interrupt, so the interrupts are disabled for now.

Even at 10/100 speeds, you really don't want to be generating one 
interrupt per Tx...

	Jeff
