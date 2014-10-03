From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: HW bridging support using notifiers?
Date: Fri, 3 Oct 2014 15:42:45 -0400
Message-ID: <20141003194245.GB17057@kvack.org>
References: <542E0089.5050005@gmail.com> <20141003142215.GR17057@kvack.org> <542EF3C4.3050201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	stephen@networkplumber.org, andy@greyhouse.net, tgraf@suug.ch,
	nbd@openwrt.org, john.r.fastabend@intel.com, edumazet@google.com,
	vyasevic@redhat.com, buytenh@wantstofly.org,
	sfeldma@cumulusnetworks.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:45307 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753233AbaJCTmq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 15:42:46 -0400
Content-Disposition: inline
In-Reply-To: <542EF3C4.3050201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 03, 2014 at 12:06:44PM -0700, Florian Fainelli wrote:
> Hi Benjamin,
> 
> On 10/03/2014 07:22 AM, Benjamin LaHaise wrote:
> > Hi Florian et al,
> > 
> > On Thu, Oct 02, 2014 at 06:48:57PM -0700, Florian Fainelli wrote:
> >> Hi all,
> >>
> >> I am taking a look at adding HW bridging support to DSA, in way that's
> >> usable outside of DSA.
> > 
> > I've been working on support for the RTL8366S switch, and our work is 
> > directly overlapping here.  I actually have something that is working at 
> > configuring port and tag based vlans on the RTL8366S.  I'll try to clean 
> > up the code to post something for discussion over the next couple of days.
> 
> Cool, please do!
> 
> > 
> >> Lennert's approach in 2008 [1] looks conceptually good to me,as he
> >> noted, it uses a bunch of new ndo's which is not only limiting to one
> >> ndo implementer per struct net_device, but also is mostly consuming the
> >> information from the bridge layer, while the ndo is an action
> > 
> > I think having ndo implementer methods for hardware switch offloads makes 
> > more sense.  Such a scheme is needed in order to implement the stacking of 
> > devices that is required in order to transparently handle configuration of 
> > vlans on switch ports where the 8021q device has to pass on the vlan tag 
> > to the switch device.  The ndo methods do perform an action of causing the 
> > switch to be configured to match the bridge config.  Additionally, they 
> > can be used to veto changes that cannot be offloaded to hardware -- this 
> > (configurable) behaviour is desired by some users of these APIs who wish 
> > to be made aware when a particuarly configuration is not supported by the 
> > underlying hardware.
> 
> Humm, that's a fair point, so not only would we want new NDOs, but we'd
> also need to specify the return values (invalid, no space etc...).
> 
> As far as bridging alone is concerned (not including VLANs for now), I
> don't think there are restrictions in terms of what the hardware can do,
> since we mostly tell it to "group" N-ports together.
> 
> For VLANs, there should be a way for the switch driver to tell whether
> that's supported or not.

What the hardware can support varies widely.  For example, the RTL8366S 
happens to support a total of 8 FDBs in hardware, which, given how the Linux 
bridge works, implies a total of at most 8 VLANs.  However, it can use more 
VLANs if they share overlapping FDBs (which Linux doesn't support).  There 
are also features like VLAN remapping, q-in-q support...  We're going to 
have to do a fair amount of work to learn about all these quirks of hardware 
features that need to be identified and reported.

> > 
> >> So here's what I am up to now:
> >>
> >> - use the NETDEV_JOIN notifier to discover when a bridge port is added
> >> - use the NETDEV_LEAVE notifier, still need to verify this does not
> >> break netconsole as indicated in net/bridge/br_if.c
> >> - use the NETDEV_CHANGEINFODATA notifier to notify about STP state changes
> > 
> > To me, notifiers are the wrong model for join and leave.  Implementing 
> > stacking on top of notifiers is somewhat more complicated.  Here are the 
> > ndo methods I've implemented so far which are sufficient for basic config 
> > of the RTL8366S.  They're fairly similar to those in [1].
> > 
> > +	int			(*ndo_join_bridge)(struct net_bridge *bridge,
> > +						   struct net_device *dev,
> > +						   int *switch_nr,
> > +						   int *switch_port_nr,
> > +						   int vlan);
> > +	int			(*ndo_leave_bridge)(struct net_bridge *bridge,
> > +						    struct net_device *dev,
> > +						    int switch_nr,
> > +						    int switch_port_nr,
> > +						    int vlan);
> > +	int			(*ndo_flood_xmit)(struct switch_info *dev,
> > +						  struct sk_buff *skb,
> > +						  u64 port_mask);
> 
> I don't think the switch_port_nr belongs here, this is something that
> should be resolved within the implementer of these ndo's, whether that
> is DSA, or Jiri's switchdev, since the net_device argument should be
> linked to both the switch port number, and the switch number.

The switch_port_nr is absolutely required for flood offloading.  (more below)

> > 
> > There are a couple of important points here.  In the case of joining and 
> > leaving a bridge, the bridge needs to be provided with information it can 
> > use to identify switch ports.  This is needed in order to offload the 
> > flooding of packets to multiple ports, as otherwise the Linux bridge code 
> > doesn't have any way to figure out which packets can be merged into a 
> > single transmit via the ndo_flood_xmit() method.
> 
> I am not exactly sure yet how ndo_flood_xmit() fits in the picture here,
> but it might be optional based on how the switch has been configured I
> presume?

ndo_flood_xmit() is a method that sends a single packet to a bitmask of 
the ports attached to the switch.  This is quite useful for saving bandwidth 
on the CPU port of a switch when sending out broadcast packets, and, more 
importantly, multicast packets.  The bits in that bitmask correspond to 
the switch_port_nr reported ny ndo_join_bridge(), and I modified the Linux 
bridge code to group ports attached to the same switch together and use the 
switch_nr to identify that ports are on the same switch and collapse flooding 
to multiple ports into a single call of ndo_flood_xmit().  The RTL8366S has 
support for this feature (that's why I implemented it), and I'm pretty sure 
other switches do as well -- at the very least I know one of the Marvell 
switches I was exposed to in the past that had this capability, but I don't 
recall the precise details of the interface since I wasn't directly involved 
in the coding for that driver.

I'm sure there are other hardware features we'll have to come up with a 
model for.  Cheers,

		-ben
-- 
"Thought is the essence of where you are now."
