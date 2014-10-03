From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: HW bridging support using notifiers?
Date: Fri, 03 Oct 2014 12:06:44 -0700
Message-ID: <542EF3C4.3050201@gmail.com>
References: <542E0089.5050005@gmail.com> <20141003142215.GR17057@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	stephen@networkplumber.org, andy@greyhouse.net, tgraf@suug.ch,
	nbd@openwrt.org, john.r.fastabend@intel.com, edumazet@google.com,
	vyasevic@redhat.com, buytenh@wantstofly.org,
	sfeldma@cumulusnetworks.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33680 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754327AbaJCTGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 15:06:48 -0400
Received: by mail-pa0-f48.google.com with SMTP id eu11so1966650pac.21
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 12:06:48 -0700 (PDT)
In-Reply-To: <20141003142215.GR17057@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Benjamin,

On 10/03/2014 07:22 AM, Benjamin LaHaise wrote:
> Hi Florian et al,
> 
> On Thu, Oct 02, 2014 at 06:48:57PM -0700, Florian Fainelli wrote:
>> Hi all,
>>
>> I am taking a look at adding HW bridging support to DSA, in way that's
>> usable outside of DSA.
> 
> I've been working on support for the RTL8366S switch, and our work is 
> directly overlapping here.  I actually have something that is working at 
> configuring port and tag based vlans on the RTL8366S.  I'll try to clean 
> up the code to post something for discussion over the next couple of days.

Cool, please do!

> 
>> Lennert's approach in 2008 [1] looks conceptually good to me,as he
>> noted, it uses a bunch of new ndo's which is not only limiting to one
>> ndo implementer per struct net_device, but also is mostly consuming the
>> information from the bridge layer, while the ndo is an action
> 
> I think having ndo implementer methods for hardware switch offloads makes 
> more sense.  Such a scheme is needed in order to implement the stacking of 
> devices that is required in order to transparently handle configuration of 
> vlans on switch ports where the 8021q device has to pass on the vlan tag 
> to the switch device.  The ndo methods do perform an action of causing the 
> switch to be configured to match the bridge config.  Additionally, they 
> can be used to veto changes that cannot be offloaded to hardware -- this 
> (configurable) behaviour is desired by some users of these APIs who wish 
> to be made aware when a particuarly configuration is not supported by the 
> underlying hardware.

Humm, that's a fair point, so not only would we want new NDOs, but we'd
also need to specify the return values (invalid, no space etc...).

As far as bridging alone is concerned (not including VLANs for now), I
don't think there are restrictions in terms of what the hardware can do,
since we mostly tell it to "group" N-ports together.

For VLANs, there should be a way for the switch driver to tell whether
that's supported or not.

> 
>> So here's what I am up to now:
>>
>> - use the NETDEV_JOIN notifier to discover when a bridge port is added
>> - use the NETDEV_LEAVE notifier, still need to verify this does not
>> break netconsole as indicated in net/bridge/br_if.c
>> - use the NETDEV_CHANGEINFODATA notifier to notify about STP state changes
> 
> To me, notifiers are the wrong model for join and leave.  Implementing 
> stacking on top of notifiers is somewhat more complicated.  Here are the 
> ndo methods I've implemented so far which are sufficient for basic config 
> of the RTL8366S.  They're fairly similar to those in [1].
> 
> +	int			(*ndo_join_bridge)(struct net_bridge *bridge,
> +						   struct net_device *dev,
> +						   int *switch_nr,
> +						   int *switch_port_nr,
> +						   int vlan);
> +	int			(*ndo_leave_bridge)(struct net_bridge *bridge,
> +						    struct net_device *dev,
> +						    int switch_nr,
> +						    int switch_port_nr,
> +						    int vlan);
> +	int			(*ndo_flood_xmit)(struct switch_info *dev,
> +						  struct sk_buff *skb,
> +						  u64 port_mask);

I don't think the switch_port_nr belongs here, this is something that
should be resolved within the implementer of these ndo's, whether that
is DSA, or Jiri's switchdev, since the net_device argument should be
linked to both the switch port number, and the switch number.

> 
> There are a couple of important points here.  In the case of joining and 
> leaving a bridge, the bridge needs to be provided with information it can 
> use to identify switch ports.  This is needed in order to offload the 
> flooding of packets to multiple ports, as otherwise the Linux bridge code 
> doesn't have any way to figure out which packets can be merged into a 
> single transmit via the ndo_flood_xmit() method.

I am not exactly sure yet how ndo_flood_xmit() fits in the picture here,
but it might be optional based on how the switch has been configured I
presume?

> 
>> Now, this raises a bunch of questions:
>>
>> - we would need a getter to return the stp state of a given network
>> device when called with NETDEV_CHANGEINFODATA, is that acceptable? This
>> would be the first function exported by the bridge layer to expose
>> internal data
> 
> I have yet to dig into STP, so I'll refrain from commenting on these parts 
> for now.

The idea is to use the Linux STP result and apply the results to the
bridge port/switch ports members directly, since switches (at least
those from Marvell and Broadcom) have that semantic built into their
hardware logic.

> 
>> NB: this also raises the question of the race condition and locking
>> within br_set_stp_state() and when the network devices notifier callback
>> runs
> U
>> - or do we need a new network device notifier accepting an opaque
>> pointer which could provide us with the data we what, something like
>> this: call_netdevices_notifier_data(NETDEV_CHANGEINFODATA, dev, info),
>> where info would be a structure/union telling what's this data about
>>
>> Let me know what you think, thanks!
>>
>> [1]: http://patchwork.ozlabs.org/patch/16578/
> 
> Thanks for the pointer to this.  Cheers!
> 
> 		-ben
> 
>> --
>> Florian
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
