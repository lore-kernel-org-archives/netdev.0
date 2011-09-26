From: "Christian Benvenuti (benve)" <benve@cisco.com>
Subject: RE: [net-next-2.6 PATCH 0/3 RFC] macvlan: MAC Address filtering support for passthru mode
Date: Mon, 26 Sep 2011 18:06:22 -0500
Message-ID: <184D23435BECB444AB6B9D4630C8EC83028F8AC6@XMB-RCD-303.cisco.com>
References: <CA93894D.33EF8%roprabhu@cisco.com> <CA974FD6.343A2%roprabhu@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Sridhar Samudrala" <sri@us.ibm.com>, <netdev@vger.kernel.org>,
	<dragos.tatulea@gmail.com>, <arnd@arndb.de>,
	"David Wang (dwang2)" <dwang2@cisco.com>, <kaber@trash.net>,
	<davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<mchan@broadcom.com>, <kvm@vger.kernel.org>
To: "Roopa Prabhu (roprabhu)" <roprabhu@cisco.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-5.cisco.com ([173.37.86.76]:9245 "EHLO
	rcdn-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884Ab1IZXGZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 19:06:25 -0400
Content-class: urn:content-classes:message
In-Reply-To: <CA974FD6.343A2%roprabhu@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Roopa Prabhu (roprabhu)
> Sent: Thursday, September 15, 2011 6:47 AM
> To: Michael S. Tsirkin
> Cc: Sridhar Samudrala; netdev@vger.kernel.org;
> dragos.tatulea@gmail.com; arnd@arndb.de; David Wang (dwang2);
Christian
> Benvenuti (benve); kaber@trash.net; davem@davemloft.net;
> eric.dumazet@gmail.com; mchan@broadcom.com; kvm@vger.kernel.org
> Subject: Re: [net-next-2.6 PATCH 0/3 RFC] macvlan: MAC Address
> filtering support for passthru mode
> 
> 
> 
> The netlink patch is still in the works. I will post the patches after
> I
> clean it up a bit and also accommodate or find answers to most
> questions
> discussed for non-passthru case. Thought I will post the netlink
> interface
> here to see if anyone has any early comments. I have a
> rtnl_link_ops->set_rx_filter defined.
> 
> [IFLA_RX_FILTER] = {
>     [IFLA_ADDRESS_FILTER] = {
>         [IFLA_ADDRESS_FILTER_FLAGS]
>         [IFLA_ADDRESS_LIST] = {
>             [IFLA_ADDRESS_LIST_ENTRY]
>         }
>     }
>     [IFLA_VLAN_FILTER] = {
>         [IFLA_VLAN_LIST] = {
>             [IFLA_VLAN]
>         }
>     }
> }
> 
> Some open questions:
>     - The VLAN filter above shows a VLAN list. It could also be a
> bitmap or
> the interface could provide both a bitmap and VLAN list for more
> flexibility
> . Like the below
> 
> [IFLA_RX_FILTER] = {
>     [IFLA_ADDRESS_FILTER] = {
>         [IFLA_ADDRESS_FILTER_FLAGS]
>         [IFLA_ADDRESS_LIST] = {
>             [IFLA_ADDRESS_LIST_ENTRY]
>         }
>     }
>     [IFLA_VLAN_FILTER] = {
>         [IFLA_VLAN_BITMAP]
>         [IFLA_VLAN_LIST] = {
>             [IFLA_VLAN]
>         }
>     }
> }

The simplest interface probably is to stick to a bitmap (knowing that in
the worst
case it will take 256 bytes, but we can compress it ...), because
sending
a vlan list may end up requiring much more than that (on interfaces
configured as trunks).
This regardless of whether the most common use case is that of a server
configured
with just few vlans or that of a switch configured with few trunks.

Another option would be a list of ranges, but that one would not work
well
in those cases where trunks are configured, for example, to carry big
numbers
of odd or even vlan IDs or other groups of vlans IDs that cannot be
grouped
into ranges. Probably an acceptable compromise, if we care about the
size
of this attribute, would be:
- to use a list of IDs for less than 256 vlans (or a list of ranges)
- to use a bitmap for more than 256 vlan.

I would recommend the two attributes (IFLA_VLAN_BITMAP and
IFLA_VLAN_LIST)
to be mutually exclusive to reduce the complexity of the merging and
error/misconfig detection code.

>     - Do you see any advantage in keeping Unicast and multicast
address
> list
> separate ? Something like the below :
>     [IFLA_RX_FILTER] = {
>         [IFLA_ADDRESS_FILTER_FLAGS]
>         [IFLA_UC_ADDRESS_FILTER] = {
>             [IFLA_ADDRESS_LIST] = {
>                 [IFLA_ADDRESS_LIST_ENTRY]
>             }
>         }
>         [IFLA_MC_ADDRESS_FILTER] = {
>             [IFLA_ADDRESS_LIST] = {
>                 [IFLA_ADDRESS_LIST_ENTRY]
>             }
>         }
>         [IFLA_VLAN_FILTER] = {
>             [IFLA_VLAN_LIST] = {
>                 [IFLA_VLAN]
>             }
>         }
>     }

I personally like the idea of grouping UC and MC addresses into two
distinct
attributes/groups.
The receiver (the kernel) would have to check them anyway (I suppose),
but
I like the idea of having the kernel being able to detect the case
where, for
example, the user configures a MC address thinking he is actually
configuring
a UC address.

Most probably the iproute2 commands used to configure/add/del UC and MC
address
will be assigned two different keywords.
BTW, once this code will be in, it will be possible for "ip link show"
to show
all UC/MC MAC addresses; right now "ip link" only shows dev->dev_addr.
This output is useful for debugging.

The output from "ip maddr" only shows the MC list and anyway I think the
best
place for the list of MAC addresses is "ip link show".

Would "ip link show" also show the list of vlans?
Probably, best would be to add new flags (to ask for the extended
output) or
simply add the extra output (uc/mc/vlan lists) under the already
existent "-s" flag ?

>     - Is there any need to keep address and vlan filters separate. And
> have
> two rtnl_link_ops, set_rx_address_filter, set_rx_vlan_filter ?. I
don't
> see
> one .
> 
>     [IFLA_RX_ADDRESS_FILTER] = {
>         [IFLA_ADDRESS_FILTER_FLAGS]
>         [IFLA_ADDRESS_LIST] = {
>             [IFLA_ADDRESS_LIST_ENTRY]
>         }
>     }
>     [IFLA_RX_VLAN_FILTER] = {
>         [IFLA_VLAN_LIST] = {
>             [IFLA_VLAN]
>         }
>     }

I think both approaches are good.
Anyway, given that you can have/configure nested vlans, having
IFLA_RX_VLAN_FILTER
inside IFLA_RX_FILTER would be syntactically correct too.

/Chris

 
> Thanks,
> Roopa
> 
> 
> 
> On 9/12/11 10:02 AM, "Roopa Prabhu" <roprabhu@cisco.com> wrote:
> 
> >
> >
> >
> > On 9/11/11 12:03 PM, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> >
> >> On Sun, Sep 11, 2011 at 06:18:01AM -0700, Roopa Prabhu wrote:
> >>>
> >>>
> >>>
> >>> On 9/11/11 2:44 AM, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> >>>
> >>>>
> >>>> Yes, but what I mean is, if the size of the single filter table
> >>>> is limited, we need to decide how many addresses is
> >>>> each guest allowed. If we let one guest ask for
> >>>> as many as it wants, it can lock others out.
> >>>
> >>> Yes true. In these cases ie when the number of unicast addresses
> being
> >>> registered is more than it can handle, The VF driver will put the
> VF  in
> >>> promiscuous mode (Or at least its supposed to do. I think all
> drivers do
> >>> that).
> >>>
> >>>
> >>> Thanks,
> >>> Roopa
> >>
> >> Right, so that works at least but likely performs worse
> >> than a hardware filter. So we better allocate it in
> >> some fair way, as a minimum. Maybe a way for
> >> the admin to control that allocation is useful.
> >
> > Yes I think we will have to do something like that. There is a
> maximum that hw
> > can support. Might need to consider that too. But there is no
> interface to get
> > that today. I think the virtualization case gets a little trickier.
> Virtio-net
> > allows upto 64 unicast addresses. But the lowerdev may allow only
> upto say 10
> > unicast addresses (I think intel supports 10 unicast addresses on
the
> VF). Am
> > not sure if there is a good way to notify the guest of blocked
> addresses.
> > Maybe putting the lower dev in promiscuous mode could be a policy
> decision too
> > in this case.
> >
> > One other thing, I had indicated that I will look up details on
> opening my
> > patch for non-passthru to enable hw filtering (without adding
> filtering
> > support in macvlan right away. Ie phase1). Turns out in current code
> in
> > macvlan_handle_frame, for non-passthru case, it does not fwd unicast
> pkts
> > destined to macs other than the ones in macvlan hash. So a filter or
> hash
> > lookup there for additional unicast addresses needs to be definitely
> added for
> > non-passthru.
> >
> > Thanks,
> > Roopa
> >
> >
> >
