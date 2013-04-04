From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2] MPLS: Add limited GSO support
Date: Thu, 4 Apr 2013 10:20:47 -0700
Message-ID: <CAEP_g=-9sup3ny7Y8HKW85LrtM=xZfEme7UeKvGZ11uHUFqPcA@mail.gmail.com>
References: <1364980315-13649-1-git-send-email-horms@verge.net.au>
 <CAEP_g=_Y0hN2DvyO4JitMrpQvN=TmTO5Pk28DpvF6Ya09AeTcg@mail.gmail.com>
 <20130404002809.GF29678@verge.net.au> <CAEP_g=9cnm39i7rBk=Pi_1e6dFDLMa6oVFuO3PufEhODCVBqnw@mail.gmail.com>
 <20130404005539.GA17694@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:38339 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1763921Ab3DDRVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 13:21:09 -0400
Received: by mail-ie0-f197.google.com with SMTP id a11so15455778iee.0
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 10:21:09 -0700 (PDT)
In-Reply-To: <20130404005539.GA17694@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 3, 2013 at 5:55 PM, Simon Horman <horms@verge.net.au> wrote:
> On Wed, Apr 03, 2013 at 05:44:17PM -0700, Jesse Gross wrote:
>> On Wed, Apr 3, 2013 at 5:28 PM, Simon Horman <horms@verge.net.au> wrote:
>> > On Wed, Apr 03, 2013 at 04:51:38PM -0700, Jesse Gross wrote:
>> >> On Wed, Apr 3, 2013 at 2:11 AM, Simon Horman <horms@verge.net.au> wrote:
>> >> > In the case where a non-MPLS packet is recieved and an MPLS stack is
>> >> > added it may well be the case that the original skb is GSO but the
>> >> > NIC used for transmit does not support GSO of MPLS packets.
>> >> >
>> >> > The aim of this code is to provide GSO in software for MPLS packets
>> >> > whose skbs are GSO.
>> >> >
>> >> > When an implementation adds an MPLS stack to a non-MPLS packet it should do
>> >> > the following to skb metadata:
>> >> >
>> >> > * Set skb_mac_header(skb)->protocol to the new MPLS ethertype.
>> >> >   That is, either ETH_P_MPLS_UC or ETH_P_MPLS_MC.
>> >> >
>> >> > * Leave skb->protocol as the old non-MPLS ethertype.
>> >> >
>> >> > * Set skb->encapsulation = 1.
>> >> >
>> >> >   This may not strictly be necessary as I believe that checking
>> >> >   skb_mac_header(skb)->protocol and skb->protocol should be necessary and
>> >> >   sufficient.
>> >> >
>> >> >   However, it does seem to fit nicely with the current implementation of
>> >> >   dev_hard_start_xmit() where the more expensive check of
>> >> >   skb_mac_header(skb)->protocol may be guarded by an existing check of
>> >> >   skb->encapsulation.
>> >> >
>> >> > One aspect of this patch that I am unsure about is the modification I have
>> >> > made to skb_segment(). This seems to be necessary as checskum accelearation
>> >> > may no longer be possible as the packet has changed to be MPLS from some
>> >> > other packet type which may have been supported by the hardware in use.
>> >> >
>> >> > I will post a patch, "[PATCH v3.24] datapath: Add basic MPLS support to
>> >> > kernel" which adds MPLS support to the kernel datapath of Open vSwtich.
>> >> > That patch sets the above requirements in
>> >> > datapath/actions.c:set_ethertype() and was used to exercise the MPLS GSO
>> >> > code. The datapath patch is against the Open vSwtich tree but it is
>> >> > intended that it be added to the Open vSwtich code present in the mainline
>> >> > Linux kernel at some point.
>> >> >
>> >> > Suggested by Jesse Gross. Based heavily on "v4 GRE: Add TCP segmentation
>> >> > offload for GRE" by Pravin B Shelar.
>> >> >
>> >> > Cc: Jesse Gross <jesse@nicira.com>
>> >> > Cc: Pravin B Shelar <pshelar@nicira.com>
>> >> > Signed-off-by: Simon Horman <horms@verge.net.au>
>> >>
>> >> MPLS is very similar to both the Ethernet header and vlans in that GSO
>> >> only requires replication without any modification.  That means that
>> >> if we look at the mac_len as containing all three then we can just
>> >> copy it without any special knowledge.  I don't know that we carefully
>> >> maintain mac_len in all places but you are already doing that in your
>> >> MPLS patches.
>> >
>> > At least for the cases that I am aware of I think that mac_len is
>> > predictable. But I'm a little unsure of what you are getting at here.
>>
>> If you have the MAC len then you don't need any new MPLS code here at
>> all; just replicate the whole thing onto each packet.
>
> The MAC len is set to cover everything up to the top of the MPLS stack.
> So it seems that something needs to be done to account for the length
> of the MPLS stack.
>
> Are you suggesting that if Open vSwtich set up the MAC len to extend
> to the end of the MPLS stack then mpls_gro_segment() would not be necessary?

Something along those lines.  I think this is very similar to the
skb->protocol discussion (and likely influenced by the outcome of
that).  MPLS is a little weird with respect to the existing layer
pointers but if we can find a good definition then I think that the
GSO code should be pretty minimal.
