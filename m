From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] switchdev: enforce no pvid flag in vlan ranges
Date: Wed, 14 Oct 2015 20:07:41 -0400
Message-ID: <20151015000741.GA1297@ketchup.lan>
References: <1444651299-2813-1-git-send-email-razor@blackwall.org>
 <20151012173625.GA17983@ketchup.lan>
 <20151013083111.GA1432@colbert.mtl.com>
 <20151013143225.GA9636@ketchup.mtl.sfl>
 <20151014061446.GA29908@colbert.mtl.com>
 <20151014152515.GA6681@ketchup.mtl.sfl>
 <CAE4R7bDFMgWnvS03OU+SE3QAeC-TSVYZ7=oLV9q-v6DbYmm_Tg@mail.gmail.com>
 <20151014174152.GB9216@colbert.mtl.com>
 <20151014185100.GA5576@ketchup.mtl.sfl>
 <561ED270.60003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ido Schimmel <idosch@mellanox.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Netdev <netdev@vger.kernel.org>,
	=?utf-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Elad Raz <eladr@mellanox.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:35149 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbbJOAHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 20:07:50 -0400
Content-Disposition: inline
In-Reply-To: <561ED270.60003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Oct. Wednesday 14 (42) 03:08 PM, Florian Fainelli wrote:
> On 14/10/15 11:51, Vivien Didelot wrote:
> > On Oct. Wednesday 14 (42) 08:42 PM, Ido Schimmel wrote:
> >> Wed, Oct 14, 2015 at 08:14:24PM IDT, sfeldma@gmail.com wrote:
> >>> On Wed, Oct 14, 2015 at 8:25 AM, Vivien Didelot
> >>> <vivien.didelot@savoirfairelinux.com> wrote:
> >>>> On Oct. Wednesday 14 (42) 09:14 AM, Ido Schimmel wrote:
> >>>>> Tue, Oct 13, 2015 at 05:32:26PM IDT, vivien.didelot@savoirfairelinux.com wrote:
> >>>>>> On Oct. Tuesday 13 (42) 11:31 AM, Ido Schimmel wrote:
> >>>>>>> Mon, Oct 12, 2015 at 08:36:25PM IDT, vivien.didelot@savoirfairelinux.com wrote:
> >>>>>>>> Hi guys,
> >>>>>>>>
> >>>>>>>> On Oct. Monday 12 (42) 02:01 PM, Nikolay Aleksandrov wrote:
> >>>>>>>>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> >>>>>>>>>
> >>>>>>>>> We shouldn't allow BRIDGE_VLAN_INFO_PVID flag in VLAN ranges.
> >>>>>>>>>
> >>>>>>>>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> >>>>>>>>> ---
> >>>>>>>>>  net/switchdev/switchdev.c | 3 +++
> >>>>>>>>>  1 file changed, 3 insertions(+)
> >>>>>>>>>
> >>>>>>>>> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> >>>>>>>>> index 6e4a4f9ad927..256c596de896 100644
> >>>>>>>>> --- a/net/switchdev/switchdev.c
> >>>>>>>>> +++ b/net/switchdev/switchdev.c
> >>>>>>>>> @@ -720,6 +720,9 @@ static int switchdev_port_br_afspec(struct net_device *dev,
> >>>>>>>>>                         if (vlan.vid_begin)
> >>>>>>>>>                                 return -EINVAL;
> >>>>>>>>>                         vlan.vid_begin = vinfo->vid;
> >>>>>>>>> +                       /* don't allow range of pvids */
> >>>>>>>>> +                       if (vlan.flags & BRIDGE_VLAN_INFO_PVID)
> >>>>>>>>> +                               return -EINVAL;
> >>>>>>>>>                 } else if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END) {
> >>>>>>>>>                         if (!vlan.vid_begin)
> >>>>>>>>>                                 return -EINVAL;
> >>>>>>>>> --
> >>>>>>>>> 2.4.3
> >>>>>>>>>
> >>>>>>>>
> >>>>>>>> Yes the patch looks good, but it is a minor check though. I hope the
> >>>>>>>> subject of this thread is making sense.
> >>>>>>>>
> >>>>>>>> VLAN ranges seem to have been included for an UX purpose (so commands
> >>>>>>>> look like Cisco IOS). We don't want to change any existing interface, so
> >>>>>>>> we pushed that down to drivers, with the only valid reason that, maybe
> >>>>>>>> one day, an hardware can be capable of programming a range on a per-port
> >>>>>>>> basis.
> >>>>>>> Hi,
> >>>>>>>
> >>>>>>> That's actually what we are doing in mlxsw. We can do up to 256 entries in
> >>>>>>> one go. We've yet to submit this part.
> >>>>>>
> >>>>>> Perfect Ido, thanks for pointing this out! I'm OK with the range then.
> >>>>>>
> >>>>>> So there is now a very last question in my head for this, which is more
> >>>>>> a matter of kernel design. Should the user be aware of such underlying
> >>>>>> support? In other words, would it make sense to do this in a driver:
> >>>>>>
> >>>>>>    foo_port_vlan_add(struct net_device *dev,
> >>>>>>                      struct switchdev_obj_port_vlan *vlan)
> >>>>>>    {
> >>>>>>        if (vlan->vid_begin != vlan->vid_end)
> >>>>>>            return -ENOTSUPP; /* or something more relevant for user */
> >>>>>>
> >>>>>>        return foo_port_single_vlan_add(dev, vlan->vid_begin);
> >>>>>>    }
> >>>>>>
> >>>>>> So drivers keep being simple, and we can easily propagate the fact that
> >>>>>> one-or-all VLAN is not supportable, vs. the VLAN feature itself is not
> >>>>>> implemented and must be done in software.
> >>>>> I think that if you want to keep it simple, then Scott's advice from the
> >>>>> previous thread is the most appropriate one. I believe the hardware you
> >>>>> are using is simply not meant to support multiple 802.1Q bridges.
> >>>>
> >>>> You mean allowing only one Linux bridge over an hardware switch?
> >>>>
> >>>> It would for sure simplify how, as developers and users, we represent a
> >>>> physical switch. But I am not sure how to achieve that and I don't have
> >>>> strong opinions on this TBH.
> >>>
> >>> Hi Vivien, I think it's possible to keep switch ports on just one
> >>> bridge if we do a little bit of work on the NETDEV_CHANGEUPPER
> >>> notifier.  This will give you the driver-level control you want.  Do
> >>> you have time to investigate?  The idea is:
> >>>
> >>> 1) In your driver's handler for NETDEV_CHANGEUPPER, if switch port is
> >>> being added to a second bridge,then return NOTIFY_BAD.  Your driver
> >>> needs to track the bridge count.
> >>>
> >>> 2) In __netdev_upper_dev_link(), check the return code from the
> >>> call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, ...) call, and if
> >>> NOTIFY_BAD, abort the linking operation (goto rollback_xxx).
> >>>
> >> Hi,
> >>
> >> We are doing something similar in mlxsw (not upstream yet). Jiri
> >> introduced PRE_CHANGEUPPER, which is called from the function you
> >> mentioned, but before the linking operation (so that you don't need to
> >> rollback).
> >>
> >> If the notification is about a linking operation and the master is a
> >> bridge different than the current one, then NOTIFY_BAD is returned.
> > 
> > Great, I'll wait for this then.
> > 
> > Scott, this is another good reason why we definitely need a simple
> > struct device per switch chip. In addition to the port net_device
> > registration, the netdev notifier is another exact same piece of code
> > that both Rocker and DSA implement.
> > 
> >> Vivien, regarding your WAN interface question, this is something we
> >> currently don't do. We don't even flood traffic from bridged ports
> >> to CPU (although we can), as it can saturate the bus. Only control
> >> traffic is supposed to go there.
> > 
> > I kinda answered it myself: a Linux bridge needs to remain a user
> > abstraction of a logical group of net_device. In other words, we must
> > allow physical distinct ports under the same bridge.
> > 
> > Below is an example of a custom router with 2 chained switch chips sw0
> > and sw1, and what usage I believe we expect:
> > 
> >     [ Linux soft bridge "br0" which can accelerate VLAN, STP, etc.    ]
> >                                                        (CPU)    (WAN)
> >     [ sw0p0 sw0p1 sw0p2 ] [ sw1p0 sw1p1 sw1p2 sw1p3 ] [ eth0 ] [ eth1 ]
> >                      `--DSA--'                   `-------'
> 
> Your use case is something that is fairly common with PON/GPON devices,
> but AFAIR they typically implement this by having two sets of bridges,
> one which spans the WAN interface and a bunch of other ports, and
> another bridge which is LAN only (few ports + Wi-Fi typically). Usually
> this is under the same physical switch though, so this is all about
> partitioning physical ports and physical interfaces under logical groups.
> 
> By definition the WAN and LAN domains are separate logical and broadcast
> domains, with separate admission control rules, STP etc. I do not think
> your "br0" example should span the WAN interface in this case. Also,
> with eth0 being the conduit interface, it cannot be allowed to be a
> bridge member, that's something I ended up fixing in the bridge layer,
> otherwise untagging does not work, but that is nitpicking.
> 
> It still makes sense though allow the creation of a "br0" device which
> spans the entire set of ports and interfaces (except eth0), but not name
> eth1 "WAN", just treat it as an extension in that case.
> 
> Sorry if that seems like f'ing flies, but having concise example should
> help make progress on these design issues ;)

You are right, my drawing wasn't that correct. What you just described
is more accurate.

Thanks,
-v
