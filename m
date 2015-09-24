From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net 0/2] lwtunnel: make it really work, for IPv4
Date: Thu, 24 Sep 2015 00:54:00 -0500
Message-ID: <87lhbws6pz.fsf@x220.int.ebiederm.org>
References: <cover.1442936392.git.jbenc@redhat.com>
	<87zj0d92ba.fsf@x220.int.ebiederm.org>
	<20150923080957.GB29680@pox.localdomain>
	<87lhbx72j2.fsf@x220.int.ebiederm.org>
	<20150923162927.6d437a1f@griffin>
	<8761313ud5.fsf@x220.int.ebiederm.org>
	<20150923225456.74c5cd1d@griffin>
	<878u7w6dxh.fsf@x220.int.ebiederm.org>
	<20150923230808.GA12825@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47815 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbbIXGBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 02:01:40 -0400
In-Reply-To: <20150923230808.GA12825@pox.localdomain> (Thomas Graf's message
	of "Thu, 24 Sep 2015 01:08:08 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf <tgraf@suug.ch> writes:

> On 09/23/15 at 04:09pm, Eric W. Biederman wrote:
>
> [...]
>
>> *Blink* You were targeting net.git with a feature enhancement????
>> I will just ignore that.
>
> The point of this series is to not expose the src and dst port Netlink
> bits to user space in a released kernel because the ABI is not set in
> stone yet. Hence targeting net.
>
> If patch 1 is regarded unacceptable we should at least pull in patch 2
> to not expose these bits until this has been worked out to leave the
> option proposed here on the table.

My only interest in this is to help figure out how to make IPv6 ndisc
work over light weight tunnels.

>> What I was observing is that in general the only tunneled packets that
>> need an ingress metadata dst for a tunneled medium ethernet like medium
>> are arp and ndisc packets.  In other cases if you aren't doing something
>> exceptional like openvswitch the normal routing should be sufficient.
>> 
>> Which means a ndo_reply_dst method could remove the need in many cases
>> for an ingress metadata dst to need to be allocated.
>
> The tunnel RX metadata collected is used to associate packets matching
> a particular tunnel id with the appropriate virtual networks by forwarding
> them to a separate netns, separate VRF device or a separate bridge.
>
> More sophisticated hypervisors may run multiple tunnel endpoints on
> the same host using different host addresses and differentiate packets
> based on the underlay destination IP as well.

Fair enough.  And in at least some of those situations the dst metadata
will be needed on every packet.  I think the extra allocation per packet
for the metadata dst is unfortunate but I won't say it is wrong.

>> Regardless a netdevice operation that digs into the packet and figures
>> out what is necessary for a reply seems like the clean way to make this
>> work for both arp and neighbour discovery.
>
> I'm not disagreeing entirely although I disagree that you can do the
> NDO without looking at the original metadata dst. Even a full fib
> lookup based on the requested IP in the ARP header is somewhat error
> prone. I fully agree though that once we support additional types
> besides IP tunneling then such an NDO might in fact make sense.

We can't use the metadata dst for IPv6 neighbour discovery.  Neighbour
discovery processing comes after ip6_route_input.  That is what makes
such a network device operation interesting today.

We don't need the information in the metadata dst because the
information that was in the metadata dst is still in the packet we just
need to reparse the packet.

Given that the input network device is per tunnel type, the network
device method will already know the format of the tunnel packet and so
should not have any trouble parsing it.

As an assist we can preserve 90% of the information in ip_tunnel_key by
repurposing inner_transport_header, inner_network_header and
inner_mac_header (which are only valid on output packets today) as
outer_transport_header, outer_network_header and outer_mac_header for
input packets.

That makes tun_id the only field of struct ip_tunnel_key that we have to
work to find.



Creating outer_transport_header, outer_network_header and
outer_mac_header should open up a lot of optmization opportunities
for input tunnel processing.  I expect with just a little bit of care
we should be able to replace the input metadata dst with a handful
of fields stored in skb->cb.  Which in turn means no memory allocations
are necessary, and that the work can be done unconditionally.

Eric
