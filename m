From: "Phoebe Buckheister" <phoebe.buckheister@itwm.fraunhofer.de>
Subject: Re: Simplifying the 802.15.4 stack
Date: Sat, 8 Mar 2014 17:58:16 +0100
Message-ID: <41ad409189cf3c414ca246c204f69f33.squirrel@webmail.itwm.fhg.de>
References: <20140307133924.21165955@zoidberg>
Reply-To: phoebe.buckheister@itwm.fraunhofer.de
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-zigbee-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
To: "Phoebe Buckheister" <phoebe.buckheister@itwm.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:51048 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbaCHQ65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 11:58:57 -0500
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s28GwrIC026218
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Sat, 8 Mar 2014 17:58:53 +0100
In-Reply-To: <20140307133924.21165955@zoidberg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a reply to Dmitrys mail, which went only to linux-zigbee-devel.
The full text of Dmitrys mail is included for interested netdev readers
that are not on linux-zigbee-devel.

On Fri, March 7, 2014 11:16 pm, Dmitry Eremin-Solenikov wrote:
> Hello,
>
> On Fri, Mar 7, 2014 at 4:16 PM, Phoebe Buckheister
> <phoebe.buckheister@itwm.fraunhofer.de> wrote:
>> Hi,
>>
>> the 802.15.4/6LoWPAN stack on Linux is pretty usable as it is now, much
>> due to the recent 6lowpan fixes by Alex. We can drive different radio
>> chips on different frequencies, IPv6 works well and we interoperate
>> just fine with RFC compliant stacks like the one implemented in Contiki.
>>
>> There are, however, also a number of sore points, which I want to
>> outline in this message and for which I want to propose possible
>> solutions. These sore points range anywhere from minor annoyances to
>> what I view as major integrity problems. I'll list what comes to my
>> mind here, in no particular order. If you have any idea how to fix
>> something, if you have something to add to the list or merely want to
>> tell me where and why I am mistaken, please do so.
>>
>> 1) header handling in the stack
>>
>> We currently have three points in the stack that parse or create
>> 802.15.4 headers, where two of those are already duplicated code - in
>> the same source file no less. Header handling for mac802154 is
>> cumbersome, and for upper layers entirely impossible without
>> duplicating more code at the moment. I have a patch that attempts to
>> rectify this by adding structs for the 802.15.4 header and its
>> components, but that was shot down by davem due to some endianness
>> issues. I am reworking the patch to fix all of this and will resend it
>> soon, but it doesn't end with that.
>
> Strange. I don't remember issues with headers code, but that was looong
> time ago. I was puzzled by header-related code in 6lowpan. For the headers
> there is a simple requirement: dev_hard_header() should work for both
> SoftMAC and HardMAC drivers. That means that before calling
> dev_hard_header() the frame does not contain header at all.

The header handling in mac802154 is actually fine, save for a little code
duplication, as long as no frame with link-layer security are received.
Once that happens, the security header is simply not parsed and the frame
is not dropped as required, but the security header and the actual frame
payload are handed to upper layers as though they were the payload of an
unsecured frame.

6lowpan has an entirely different problem. Currently, 6lowpan assumes that
the ieee802154_mac_cb struct in an skb->cb will be valid when lowpan
receives the skb, but that's just not so. Instead, lowpan would have to
parse the MAC header again to get the addresses it needs for further
processing. To do that without duplicating the mac802154 header parsing
code, we need to move header handling around and make it available to all
interested users, not only mac802154.

>
>> 2) endianness in the stack
>
> The stack was tested on PowerPC boxes, but that was some time ago
> (at least before 6lowpan work). If you need an access to PowerPC box
> to run tests, I can think about arranging that.
>
>> We really never use network byte order on purpose, and inside of the
>> stack we should really change that. Ideally we'd also change it in the
>> userspace API if we ever got the chance to do that, because
>> AF_IEEE802154 is the *only* protocol i know that uses all byte orders
>> in it's sockaddr struct *except* network byte order.
>
> This can be hard and davem would probably disallow it :(
>
> Sockaddr for 802.15.4 should have used native byteorder, if I'm not
> mistaken.
>
>> 3) the mac802154_priv slave list
>>
>> This is one of the biggest problems I think the current stack has. For
>> HardMAC, every netdevice corresponds to one specific WPAN (made up of
>> PAN ID, channel, and page) and it is pretty much guaranteed that
>> multiple HardMAC netdevs will always function as intended, even if they
>> are backed by the same piece of hardware.
>>
>> SoftMAC, on the other hand, takes a single PHY chip and adds an
>> *arbitrary* number of specific WPANs on top of that PHY. No real
>> hardware can support an arbitrary number of specific WPANs, and no chip
>> I have yet come across can even support more than one. As far as I've
>> been told and was able to reconstruct from documentation and standards
>> documents, this was implemented to allow for ZigBee frequency agility,
>> but that was never implemented. What we have, though, is a means for
>> unprivileged users that can run socket(), write() and ip(8) to
>> effectively DoS a node that uses this feature.
>
> This was done to support different kinds of devices accessing the radio.
> Compare to 802.11 stack, which has phy & device conception.
> It really helps to separate between the radio-related parts and functional
> (MAC) things.
>
> 1) 802.15.4. At the moment of writing there was no difference between
>     plain device and coordinator. (It was expected that the need to
>     differentiate between device and coordinator may arise in the future.
>     Compare to 802.11 AP and Mesh devices.)
>
> 2) Monitor. A device returning a frame with _all_headers to userspace.
>     W/o any processing. Again, compare to 802.11 stack - they added
>     monitor devices.

Differentiating between different roles of a device with different types
of interfaces is a sensible idea. I'm not actually opposed to that, quite
the contrary - I am mainly interested in a working and semantically
correct system.

As far as 802.15.4 is concerned, I do want to be able to support all kinds
of devices that make sense. It is not sensible though to add a monitor
device on a PHY that is already running a WPAN if that PHY does not
support concurrent monitors, so that should not be allowed for 802.15.4
just as it is not allowed for 802.11. For why I think it is not sensible
to allow multiple 802.15.4 slave devices on one PHY, see below.

>
> Left over or not implemented:
>
> 3) SMAC - Freescale's 'Simple MAC'. Broadcast frames, two-byte header
>     to identify SMAC, no addressing. Used mostly for their demonstrations
>     and for hobbyist simple devices. It is present in linux-wpan kernel
> and
>     I think it's worth adding it to mainline
>
> 4) MiWi. Microchip's 802.15.4 variant. While it shares lot's of commons
>     with main 802.15.4 standard, it has some simplifications in the
>     areas of address negotiation and association/removal. Not implemented,
>     but it might be worth looking into it - it is a 'baby 802.15.4',
> so implementing
>     it would also help main 802.15.4 stack.
>
> 5) MiWi P2P - Another fancy from Microchip. Don't remember the details.
>
> 6) _anything_ else. This band and these radio modems are used for lots
>     pf hobbyist devices. Moreover, the notion of 'WPAN device is a device
>     supporting transmission of frames <= 127 bytes with 2-byte CRC16
>     at the end of the frame' should allow implementing other fancy devices
>     through this stack. In Siemens we were contacted by a French company
>     that developed powerline devices. They are not 802.15.4 devices,
>     because standard defines no powerline phy (yet). Those guys were
>     interested in transmitting 802.15.4 frames on top of these devices.
>     Or a custom frames. Another example: 802.15.7 Visible Light
>     Communications look very similar to 802.15.4. Very but not equal.
>     So it is possible to support 'VLC' drivers on top of 'WPAN phy'.
>     The driver would share lot's of code with 802.15.4. And still
>     allow to support VLC peculiarities.

Those are interesting protocols to support with the current PHY
infrastructure, yes. MiWi might benefit greatly from sharing code with
mac802154, so there is reason to keep that code reasonably generic if
anyone ever wanted to implement WiMi, the same holds for VLC.

All of those protocols may very well share the PHY and parts of the code
with regular 802.15.4, but 802.15.4 and these protocols are all in some
way incompatible with each other. For what I can tell, SMAC uses the first
two bytes of a frame as data, where 802.15.4 expects a frame control word,
so those cannot work together on the same PHY without interfering with
each other. MiWi, as an extended subset of 802.15.4, probably also cannot
coexist with 802.15.4 or SMAC on the same PHY. Two protocols can only
reliably coexist if they were explicitly designed to do that, but I
couldn't confirm that what you listed was designed to.

So yes, it is sensible to allow different protocols on top of the PHY, but
not two different protocols at once, and also not two different instances
of the same protocol that interfere with each other - which, for the
transceivers that have drivers in the kernel now, are any two instances at
all. The transceivers we support are designed by their manufacturers to be
as cheap as possible while still allowing a full implementation of an
802.15.4 stack, which notable does not include a requirement for one
device to be accessible in different specific WPANs at once.

>
>
> Note. I did not say a word about ZigBee or 6lowpan. Those are next-level
> protocols. They are not to be implemented as wpan phy slaves. Instead
> they use low level protocols (802.15.4 in this case) and operate them
> through protocol-related interface (netlink + data), be it a userspace
> implementation or a kernel-space one.
>
>
> I think I have said enough to convince you (and other developers) that
> slaves
> are important part of the stack and phy <-> dev separation should be
> supported. Just stop living in 802.15.4-only world. This parts of universe
> centers around 802.15.4,  but is not limited to it.

If the stated goal of mac802154 is to support anything that uses a
802.15.4 PHY, or a similar PHY, then maybe the stack should renamed to
reflect that. Or it could be split into mac80215x and ieee802154, smac,
miwi ... A basic stack for just the PHY functions and one stack for each
protocol, where those stack could of course share code where appropriate.
Since nothing has made a move for mainline since the 802.15.4 PHY
infrastructure was added, I do believe that this complexity is not
warranted at the moment. That might change when those protocols wish to go
mainline, but right now the implementation in the kernel is an 802.15.4
stack, and the assumption that it is a pure 802.15.4 stack is also present
in the PHY drivers. In my opinion, we should stick to what we know -
802.15.4 - until the need to diversify arises.

As explained above, I am not opposed to the separation into PHY devices
and netdevs. The current mode of seperation is at odds with what can be
implemented in reality without breaking at least one assumption of the
netdev model though, so I think we should rethink at least the mode of
separation - the separation itself is a sensible thing.

>
> Regarding multiple 802.15.4 devices per single phy, switching channels,
> etc.
> At the time we did this, stack contained (and it still contains) areas
> requiring more attention. To make multidev configurations work safely
> one just needs to add several checks in the code and several error codes
> around.
>
> In fact (yes, I'm not joking) the ability to add several devices and to
> switch channels from each of the device was considered as a feature,
> not as a bug. If you did this, you certainly knew what you are doing.
> And why. So if the driver fails, it's your problem (note: fails, not
> crashes).
> On the other hand, it allows running several interesting experiments
> and to deploy interesting configurations.

I don't think it's quite as easy as that. Making multidev work safely in
all configurations requires a lot of compatibility checking between the
devices configured on the PHY, and indications from the PHY driver about
what the chip can safely support. For the drivers we have now and chips I
have seen so far, this indication would always be "one specific WPAN",
plus maybe a monitor of the network, reducing the possible slaves to one
specific WPAN instance and one monitor device.

I can also think of different ways to switch specific WPANs by only
sending a packet down a device that do not require different device
instances. One would be to export a netlink controller for a device, such
that one could open a netlink socket, bind it to the wpan device, and from
then on be able to change channel/page/PAN-ID/other parameters of only
that wpan device via this socket. Other options include (possibly
privileged) ancillary data messages for socket sendmsg() calls that would
have the same effect. With these options, you can still know what you are
doing and not have the driver or a netdev fail on you in a manner that
might be hard to debug. I cannot comment on the experiments and
interesting configurations you mentioned, but I feel that most or all of
these are specialized enough to not care whether the switching mechanism
is via a simple packet, via a netlink command, or via a packet with
ancillary data.

>
>> I thus propose to remove this feature entirely and instead have a 1:1
>> correspondence between PHYs and netdevs. If a driver can support
>> multiple specific WPANs per chip, it can register multiple PHYs. If
>> anybody actually needs to reconfigure the device to a different
>> specific WPAN, we already have an interface for that: the netlink API.
>> The netlink API also has the benefit that it does not impose arbitrary
>> delays before the switch, as switching by sending a packet does when
>> reordering/shaping Qdiscs are configured on the WPAN.
>
> It's your community-based choice now. However I'd suggest to leave
> that in place. See 802.11 stack - there are much more similarities
> that one would have expected.
>
> [skipped]
>
>> 4) our *drivers* are expected to *sleep*
>>
>> This is just wrong. Our RX/TX path invokes the scheduler at least once
>> for every packet on the assumption that drivers might sleep, which may
>> entail arbitrary delays even after the Qdiscs of the system have run.
>> Especially when somebody wanted to use latency sensitive Qdiscs, this
>> is a disaster, but also for general system throughput once you have a
>> certain number of packets going through your node.
>
> I'm not sure about RX path (I just don't remember details at this point).
> There are netif_rx and netif_rx_ni functions.
>
> For TX path things are really simple. ndo_start_xmit can not sleep.
> at86, serial - all require sleeping in the tx path. For at86:
> Change the state, wait for the change to finish, program the buffer,
> toggle the gpio. Lot's of waiting and sleeping there.
>
> It would be possible to move the schedule&company to the driver
> itself. I don't remember if we tried that or not. However we felt that
> it would be simpler to handle all scheduling inside mac80154 core.
>
> You can shift schedule_work & company to the final drivers,
> You won't get rid of them completely.

Lots of waiting is required, yes, but sleeping is not necessary for this
waiting to happen. For at86: a TX operation writes a frame to the device
frame buffer, changes state, checks that the state change has succeeded
and reports and error if not, and finally waits for the TRX_END interrupt
to signal completion of the Transmission and to change the device state
back to receive mode. Writing to the device can be done asynchronously
with the SPI infrastructure the kernel has, sequencing of these operations
operations up until the wait for completion can be one via the completion
callbacks the SPI core offers. When TRX_END has fired, or when an error
has happened, we can inform mac802154 via a callback of our own about the
outcome of the operation. If mac802154 has not indicated that it wants to
send another frame right away, we can then change the device state to RX
asynchronously while mac802154 processes the packet we just gave to it. No
sleeping is actually required for these operations to work, but it
admittedly does make programming a little easier, at the cost of increased
latencies and decreased throughput.

>
> --
> With best wishes
> Dmitry
>
