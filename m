From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Simplifying the 802.15.4 stack
Date: Tue, 11 Mar 2014 16:30:12 +0400
Message-ID: <CALT56yOBjfb5_dG=FdVCPbWmPzUdPP7DbdTXL9ges3c-fRYx-A@mail.gmail.com>
References: <20140307133924.21165955@zoidberg>
	<41ad409189cf3c414ca246c204f69f33.squirrel@webmail.itwm.fhg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-zigbee-devel <linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <41ad409189cf3c414ca246c204f69f33.squirrel-2RFepEojUI2EPUtC0b/4VBvVK+yQ3ZXh@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Helo,

On Sat, Mar 8, 2014 at 8:58 PM, Phoebe Buckheister
<phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org> wrote:
> On Fri, March 7, 2014 11:16 pm, Dmitry Eremin-Solenikov wrote:
>> On Fri, Mar 7, 2014 at 4:16 PM, Phoebe Buckheister
>> <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org> wrote:

[skipped]

>>> 3) the mac802154_priv slave list
>>>
>>> This is one of the biggest problems I think the current stack has. For
>>> HardMAC, every netdevice corresponds to one specific WPAN (made up of
>>> PAN ID, channel, and page) and it is pretty much guaranteed that
>>> multiple HardMAC netdevs will always function as intended, even if they
>>> are backed by the same piece of hardware.
>>>
>>> SoftMAC, on the other hand, takes a single PHY chip and adds an
>>> *arbitrary* number of specific WPANs on top of that PHY. No real
>>> hardware can support an arbitrary number of specific WPANs, and no chip
>>> I have yet come across can even support more than one. As far as I've
>>> been told and was able to reconstruct from documentation and standards
>>> documents, this was implemented to allow for ZigBee frequency agility,
>>> but that was never implemented. What we have, though, is a means for
>>> unprivileged users that can run socket(), write() and ip(8) to
>>> effectively DoS a node that uses this feature.
>>
>> This was done to support different kinds of devices accessing the radio.
>> Compare to 802.11 stack, which has phy & device conception.
>> It really helps to separate between the radio-related parts and functional
>> (MAC) things.
>>
>> 1) 802.15.4. At the moment of writing there was no difference between
>>     plain device and coordinator. (It was expected that the need to
>>     differentiate between device and coordinator may arise in the future.
>>     Compare to 802.11 AP and Mesh devices.)
>>
>> 2) Monitor. A device returning a frame with _all_headers to userspace.
>>     W/o any processing. Again, compare to 802.11 stack - they added
>>     monitor devices.
>
> Differentiating between different roles of a device with different types
> of interfaces is a sensible idea. I'm not actually opposed to that, quite
> the contrary - I am mainly interested in a working and semantically
> correct system.
>
> As far as 802.15.4 is concerned, I do want to be able to support all kinds
> of devices that make sense. It is not sensible though to add a monitor
> device on a PHY that is already running a WPAN if that PHY does not
> support concurrent monitors, so that should not be allowed for 802.15.4
> just as it is not allowed for 802.11. For why I think it is not sensible
> to allow multiple 802.15.4 slave devices on one PHY, see below.

If you wish to disallow multiple 802.15.4 devices on a single phy, just do it.

However before removing the rest of the phy/device API, please, Please,
PLEASE, go and consult the 802.11 separation in Linux kernel. This largest
part of slave support code was modeled after 802.11 stack. This is not about
the roles of the device - it is about the multiple roles being
attached to the device.
For example monitor mode would be hard to support on plain 802.15.4 - one
can expect that mac802.15.4 will change the skb. Especially after
adding security/encryption. Monitor (wireshark/whatever) must receive
skbs before all the rest of the handlers. It is not directly possible with
other architectures.

>> Left over or not implemented:
>>
>> 3) SMAC - Freescale's 'Simple MAC'. Broadcast frames, two-byte header
>>     to identify SMAC, no addressing. Used mostly for their demonstrations
>>     and for hobbyist simple devices. It is present in linux-wpan kernel
>> and
>>     I think it's worth adding it to mainline

If I have time, I'll update the code and send it to review & merge. This would
be a good example of supporting other protocols on top of 802.15.4 PHY in
parallel to the  802.15.4 MAC.

[skipped regarding miwi]

> Those are interesting protocols to support with the current PHY
> infrastructure, yes. MiWi might benefit greatly from sharing code with
> mac802154, so there is reason to keep that code reasonably generic if
> anyone ever wanted to implement WiMi, the same holds for VLC.
>
> All of those protocols may very well share the PHY and parts of the code
> with regular 802.15.4, but 802.15.4 and these protocols are all in some
> way incompatible with each other. For what I can tell, SMAC uses the first
> two bytes of a frame as data, where 802.15.4 expects a frame control word,
> so those cannot work together on the same PHY without interfering with
> each other. MiWi, as an extended subset of 802.15.4, probably also cannot
> coexist with 802.15.4 or SMAC on the same PHY. Two protocols can only
> reliably coexist if they were explicitly designed to do that, but I
> couldn't confirm that what you listed was designed to.

This is up to the protocol and application to decide, whether it can parse
packets or it can ignore them. Compare this to having IPv4, IPv6, IPX
and SMB (NetBEUI or whatever that was called) packets on top of
a wire. It is up to the protocol to decide, whether it can parse the
packet and whether the packet looks good enough to be passed
to upper layers.

> So yes, it is sensible to allow different protocols on top of the PHY, but
> not two different protocols at once, and also not two different instances
> of the same protocol that interfere with each other - which, for the
> transceivers that have drivers in the kernel now, are any two instances at
> all. The transceivers we support are designed by their manufacturers to be
> as cheap as possible while still allowing a full implementation of an
> 802.15.4 stack, which notable does not include a requirement for one
> device to be accessible in different specific WPANs at once.

And this is to the driver to decide. I don't remember, which got to the kernel.
My original code allowed the upper layers and protocol to agree on what
is allowed and what is not. It is the driver, who knows what is currently
enabled (address filtering, auto-ack, promisc, etc). Mac802.15.4 should
not impose additional restrictions on top of that.


> If the stated goal of mac802154 is to support anything that uses a
> 802.15.4 PHY, or a similar PHY, then maybe the stack should renamed to
> reflect that. Or it could be split into mac80215x and ieee802154, smac,
> miwi ... A basic stack for just the PHY functions and one stack for each
> protocol, where those stack could of course share code where appropriate.
> Since nothing has made a move for mainline since the 802.15.4 PHY
> infrastructure was added, I do believe that this complexity is not
> warranted at the moment. That might change when those protocols wish to go
> mainline, but right now the implementation in the kernel is an 802.15.4
> stack, and the assumption that it is a pure 802.15.4 stack is also present
> in the PHY drivers. In my opinion, we should stick to what we know -
> 802.15.4 - until the need to diversify arises.

PHY does/should not depend on having only 802.15.4. Monitoring and SMAC
worked w/o any issues. In fact this was the original cause for reduced and full
MLME ops, not that RFD/FFD crap, that is currently written in the comment
in ieee802154_netdev.h file.

> As explained above, I am not opposed to the separation into PHY devices
> and netdevs. The current mode of seperation is at odds with what can be
> implemented in reality without breaking at least one assumption of the
> netdev model though, so I think we should rethink at least the mode of
> separation - the separation itself is a sensible thing.

I'm open to any real suggestions. But please check the 80211 kernel code
first.

[skipped]

>>> 4) our *drivers* are expected to *sleep*
>>>
>>> This is just wrong. Our RX/TX path invokes the scheduler at least once
>>> for every packet on the assumption that drivers might sleep, which may
>>> entail arbitrary delays even after the Qdiscs of the system have run.
>>> Especially when somebody wanted to use latency sensitive Qdiscs, this
>>> is a disaster, but also for general system throughput once you have a
>>> certain number of packets going through your node.
>>
>> I'm not sure about RX path (I just don't remember details at this point).
>> There are netif_rx and netif_rx_ni functions.
>>
>> For TX path things are really simple. ndo_start_xmit can not sleep.
>> at86, serial - all require sleeping in the tx path. For at86:
>> Change the state, wait for the change to finish, program the buffer,
>> toggle the gpio. Lot's of waiting and sleeping there.
>>
>> It would be possible to move the schedule&company to the driver
>> itself. I don't remember if we tried that or not. However we felt that
>> it would be simpler to handle all scheduling inside mac80154 core.
>>
>> You can shift schedule_work & company to the final drivers,
>> You won't get rid of them completely.
>
> Lots of waiting is required, yes, but sleeping is not necessary for this
> waiting to happen. For at86: a TX operation writes a frame to the device
> frame buffer, changes state, checks that the state change has succeeded
> and reports and error if not, and finally waits for the TRX_END interrupt
> to signal completion of the Transmission and to change the device state
> back to receive mode. Writing to the device can be done asynchronously
> with the SPI infrastructure the kernel has, sequencing of these operations
> operations up until the wait for completion can be one via the completion
> callbacks the SPI core offers. When TRX_END has fired, or when an error
> has happened, we can inform mac802154 via a callback of our own about the
> outcome of the operation. If mac802154 has not indicated that it wants to
> send another frame right away, we can then change the device state to RX
> asynchronously while mac802154 processes the packet we just gave to it. No
> sleeping is actually required for these operations to work, but it
> admittedly does make programming a little easier, at the cost of increased
> latencies and decreased throughput.

First, just to make sure that you understand it. 'a TX operation writes a frame
to the device frame buffer, changes state, checks that the state
change has succeeded'.
This part already includes sleeping a lot. One can change the drivers
code to do all the job on asynchronous callbacks or in the special
driver-local worker. But you still face the issue. Again, send the patches
on how to improve the situation.


-- 
With best wishes
Dmitry

------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
