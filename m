From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2] MPLS: Add limited GSO support
Date: Wed, 3 Apr 2013 17:44:17 -0700
Message-ID: <CAEP_g=9cnm39i7rBk=Pi_1e6dFDLMa6oVFuO3PufEhODCVBqnw@mail.gmail.com>
References: <1364980315-13649-1-git-send-email-horms@verge.net.au>
 <CAEP_g=_Y0hN2DvyO4JitMrpQvN=TmTO5Pk28DpvF6Ya09AeTcg@mail.gmail.com> <20130404002809.GF29678@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:42584 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932071Ab3DDAol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 20:44:41 -0400
Received: by mail-ob0-f200.google.com with SMTP id uz6so11218454obc.3
        for <netdev@vger.kernel.org>; Wed, 03 Apr 2013 17:44:37 -0700 (PDT)
In-Reply-To: <20130404002809.GF29678@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 3, 2013 at 5:28 PM, Simon Horman <horms@verge.net.au> wrote:
> On Wed, Apr 03, 2013 at 04:51:38PM -0700, Jesse Gross wrote:
>> On Wed, Apr 3, 2013 at 2:11 AM, Simon Horman <horms@verge.net.au> wrote:
>> > In the case where a non-MPLS packet is recieved and an MPLS stack is
>> > added it may well be the case that the original skb is GSO but the
>> > NIC used for transmit does not support GSO of MPLS packets.
>> >
>> > The aim of this code is to provide GSO in software for MPLS packets
>> > whose skbs are GSO.
>> >
>> > When an implementation adds an MPLS stack to a non-MPLS packet it should do
>> > the following to skb metadata:
>> >
>> > * Set skb_mac_header(skb)->protocol to the new MPLS ethertype.
>> >   That is, either ETH_P_MPLS_UC or ETH_P_MPLS_MC.
>> >
>> > * Leave skb->protocol as the old non-MPLS ethertype.
>> >
>> > * Set skb->encapsulation = 1.
>> >
>> >   This may not strictly be necessary as I believe that checking
>> >   skb_mac_header(skb)->protocol and skb->protocol should be necessary and
>> >   sufficient.
>> >
>> >   However, it does seem to fit nicely with the current implementation of
>> >   dev_hard_start_xmit() where the more expensive check of
>> >   skb_mac_header(skb)->protocol may be guarded by an existing check of
>> >   skb->encapsulation.
>> >
>> > One aspect of this patch that I am unsure about is the modification I have
>> > made to skb_segment(). This seems to be necessary as checskum accelearation
>> > may no longer be possible as the packet has changed to be MPLS from some
>> > other packet type which may have been supported by the hardware in use.
>> >
>> > I will post a patch, "[PATCH v3.24] datapath: Add basic MPLS support to
>> > kernel" which adds MPLS support to the kernel datapath of Open vSwtich.
>> > That patch sets the above requirements in
>> > datapath/actions.c:set_ethertype() and was used to exercise the MPLS GSO
>> > code. The datapath patch is against the Open vSwtich tree but it is
>> > intended that it be added to the Open vSwtich code present in the mainline
>> > Linux kernel at some point.
>> >
>> > Suggested by Jesse Gross. Based heavily on "v4 GRE: Add TCP segmentation
>> > offload for GRE" by Pravin B Shelar.
>> >
>> > Cc: Jesse Gross <jesse@nicira.com>
>> > Cc: Pravin B Shelar <pshelar@nicira.com>
>> > Signed-off-by: Simon Horman <horms@verge.net.au>
>>
>> MPLS is very similar to both the Ethernet header and vlans in that GSO
>> only requires replication without any modification.  That means that
>> if we look at the mac_len as containing all three then we can just
>> copy it without any special knowledge.  I don't know that we carefully
>> maintain mac_len in all places but you are already doing that in your
>> MPLS patches.
>
> At least for the cases that I am aware of I think that mac_len is
> predictable. But I'm a little unsure of what you are getting at here.

If you have the MAC len then you don't need any new MPLS code here at
all; just replicate the whole thing onto each packet.
