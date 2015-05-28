From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: RE: [Intel-wired-lan] [PATCH v5] ixgbe: Add module parameter to
 disable VLAN filter
Date: Thu, 28 May 2015 06:42:48 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05EBB7DE@BPXM14GP.gisp.nec.co.jp>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05EB460C@BPXM14GP.gisp.nec.co.jp>
 <555F5644.8040401@redhat.com>
 <7F861DC0615E0C47A872E6F3C5FCDDBD05EB9F5A@BPXM14GP.gisp.nec.co.jp>
 <55652130.6090708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sy.jong.choi@intel.com" <sy.jong.choi@intel.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([210.143.35.52]:40967 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbbE1GoB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 02:44:01 -0400
In-Reply-To: <55652130.6090708@gmail.com>
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: Re: [Intel-wired-lan] [PATCH v5] ixgbe: Add module parameter to disable VLAN filter
> 
> On 05/26/2015 06:11 PM, Hiroshi Shimamoto wrote:
> >> On 05/21/2015 06:10 AM, Hiroshi Shimamoto wrote:
> >>> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> >>>
> >>> Introduce module parameter "disable_hw_vlan_filter" to disable HW VLAN
> >>> filter on ixgbe module load.
> >>>
> >>>   From the hardware limitation, there are only 64 VLAN entries for HW VLAN
> >>> filter, and it leads to limit the number of VLANs up to 64 among PF and
> >>> VFs. For SDN/NFV case, we need to handle unlimited VLAN packets on VF.
> >>> In such case, every VLAN packet can be transmitted to each VF.
> >>>
> >>> When we try to make VLAN devices on VF, the 65th VLAN registration fails
> >>> and never be able to receive a packet with that VLAN tag.
> >>> If we do the below command on VM, ethX.65 to ethX.100 cannot be created.
> >>>     # for i in `seq 1 100`; do \
> >>>       ip link add link ethX name ethX.$i type vlan id $i; done
> >>>
> >>> There is a capability to disable HW VLAN filter and that makes all VLAN
> >>> tagged packets can be transmitted to every VFs. After VLAN filter stage,
> >>> unicast packets are transmitted to VF which has the MAC address same as
> >>> the transmitting packet.
> >>>
> >>> With this patch and "disable_hw_vlan_filter=1", we can use unlimited
> >>> number of VLANs on VF.
> >>>
> >>> Disabling HW VLAN filter breaks some NIC features such as DCB and FCoE.
> >>> DCB and FCoE are disabled when HW VLAN filter is disabled by this module
> >>> parameter.
> >>> Because of that reason, the administrator has to know that before turning
> >>> off HW VLAN filter.
> >> You might also want to note that it makes the system susceptible to
> >> broadcast/multicast storms since it eliminates any/all VLAN isolation.
> >> So a broadcast or multicast packet on one VLAN is received on ALL
> >> interfaces regardless of their VLAN configuration. In addition the
> >> current VF driver is likely to just receive the packet as untagged, see
> >> ixgbevf_process_skb_fields().  As a result one or two VFs can bring the
> >> entire system to a crawl by saturating the PCIe bus via
> >> broadcast/multicast traffic since there is nothing to prevent them from
> >> talking to each other over VLANs that are no longer there.
> > that's right.
> >
> > On the other hand, an untagged packet is not isolated,
> > doesn't it same broadcast/multicast storm on untagged network?
> 
> Yes, that is one of the reasons for VLANs.  It provides isolation so
> that if you have two entities on the same network you won't have entity
> A able to talk to entity B.  The problem is with VLAN promiscuous
> enabled if entity B is a VF it will see the traffic but has no way to
> know that it was VLAN tagged and a part of entity A's VLAN.

Sorry, I guess I failed to make a question to clarify.
Occupying PCIe bus with broadcast/multicast packets causes performance
degradation. VLAN filter can isolate traffic and reduce PCIe bus usage,
but untagged broadcast/multicast traffic is still problem, I think.
What is difference between tagged packet and untagged packet?

> 
> >
> >> For the sake of backwards compatibility I would say that a feature like
> >> this should be mutually exclusive with SR-IOV as well since it will
> >> cause erratic behavior.  The VF will receive requests from all VLANs
> >> thinking the traffic is untagged, and then send replies back to VLAN 0
> >> even though that isn't where the message originated.
> > Sorry, I couldn't catch the above part.
> > Could you explain a bit more?
> >
> > thanks,
> > Hiroshi
> >
> >> Until the VF issue
> >> is fixed this type of feature is a no-go.
> >
> 
> The current behavior for a VF is that if it receives a VLAN that it
> didn't request it assumes it is operating in port VLAN mode.  The
> problem is with your patch the VF will be receiving all traffic but have
> no idea which VLAN it came from.  As a result it could be replying to
> multicast or broadcast requests on one VLAN with the wrong VLAN ID.
> 
> The VLAN behavior of the VF drivers will need to be fixed before
> something like that could be supported with ANY of the VFs.  As such you
> will probably need to fix the VF driver in order to allow any of them to
> come online when VLAN filtering is disabled, as the driver will need to
> report the VLAN tag ID up to the stack.

Thanks, that explains cleaner, I think I got the issue.
I have to check the exact behavior on my box to understand correctly, will do.

thanks,
Hiroshi
