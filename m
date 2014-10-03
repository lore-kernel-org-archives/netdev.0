From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: HW bridging support using notifiers?
Date: Fri, 3 Oct 2014 10:22:15 -0400
Message-ID: <20141003142215.GR17057@kvack.org>
References: <542E0089.5050005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	stephen@networkplumber.org, andy@greyhouse.net, tgraf@suug.ch,
	nbd@openwrt.org, john.r.fastabend@intel.com, edumazet@google.com,
	vyasevic@redhat.com, buytenh@wantstofly.org,
	sfeldma@cumulusnetworks.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:40866 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752152AbaJCOWR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 10:22:17 -0400
Content-Disposition: inline
In-Reply-To: <542E0089.5050005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian et al,

On Thu, Oct 02, 2014 at 06:48:57PM -0700, Florian Fainelli wrote:
> Hi all,
> 
> I am taking a look at adding HW bridging support to DSA, in way that's
> usable outside of DSA.

I've been working on support for the RTL8366S switch, and our work is 
directly overlapping here.  I actually have something that is working at 
configuring port and tag based vlans on the RTL8366S.  I'll try to clean 
up the code to post something for discussion over the next couple of days.

> Lennert's approach in 2008 [1] looks conceptually good to me,as he
> noted, it uses a bunch of new ndo's which is not only limiting to one
> ndo implementer per struct net_device, but also is mostly consuming the
> information from the bridge layer, while the ndo is an action

I think having ndo implementer methods for hardware switch offloads makes 
more sense.  Such a scheme is needed in order to implement the stacking of 
devices that is required in order to transparently handle configuration of 
vlans on switch ports where the 8021q device has to pass on the vlan tag 
to the switch device.  The ndo methods do perform an action of causing the 
switch to be configured to match the bridge config.  Additionally, they 
can be used to veto changes that cannot be offloaded to hardware -- this 
(configurable) behaviour is desired by some users of these APIs who wish 
to be made aware when a particuarly configuration is not supported by the 
underlying hardware.

> So here's what I am up to now:
> 
> - use the NETDEV_JOIN notifier to discover when a bridge port is added
> - use the NETDEV_LEAVE notifier, still need to verify this does not
> break netconsole as indicated in net/bridge/br_if.c
> - use the NETDEV_CHANGEINFODATA notifier to notify about STP state changes

To me, notifiers are the wrong model for join and leave.  Implementing 
stacking on top of notifiers is somewhat more complicated.  Here are the 
ndo methods I've implemented so far which are sufficient for basic config 
of the RTL8366S.  They're fairly similar to those in [1].

+	int			(*ndo_join_bridge)(struct net_bridge *bridge,
+						   struct net_device *dev,
+						   int *switch_nr,
+						   int *switch_port_nr,
+						   int vlan);
+	int			(*ndo_leave_bridge)(struct net_bridge *bridge,
+						    struct net_device *dev,
+						    int switch_nr,
+						    int switch_port_nr,
+						    int vlan);
+	int			(*ndo_flood_xmit)(struct switch_info *dev,
+						  struct sk_buff *skb,
+						  u64 port_mask);

There are a couple of important points here.  In the case of joining and 
leaving a bridge, the bridge needs to be provided with information it can 
use to identify switch ports.  This is needed in order to offload the 
flooding of packets to multiple ports, as otherwise the Linux bridge code 
doesn't have any way to figure out which packets can be merged into a 
single transmit via the ndo_flood_xmit() method.

> Now, this raises a bunch of questions:
> 
> - we would need a getter to return the stp state of a given network
> device when called with NETDEV_CHANGEINFODATA, is that acceptable? This
> would be the first function exported by the bridge layer to expose
> internal data

I have yet to dig into STP, so I'll refrain from commenting on these parts 
for now.

> NB: this also raises the question of the race condition and locking
> within br_set_stp_state() and when the network devices notifier callback
> runs
U
> - or do we need a new network device notifier accepting an opaque
> pointer which could provide us with the data we what, something like
> this: call_netdevices_notifier_data(NETDEV_CHANGEINFODATA, dev, info),
> where info would be a structure/union telling what's this data about
> 
> Let me know what you think, thanks!
> 
> [1]: http://patchwork.ozlabs.org/patch/16578/

Thanks for the pointer to this.  Cheers!

		-ben

> --
> Florian
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
"Thought is the essence of where you are now."
