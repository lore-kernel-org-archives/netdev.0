From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net 0/2] lwtunnel: make it really work, for IPv4
Date: Thu, 24 Sep 2015 10:19:43 +0200
Message-ID: <20150924101943.26f3daf2@griffin>
References: <cover.1442936392.git.jbenc@redhat.com>
	<87zj0d92ba.fsf@x220.int.ebiederm.org>
	<20150923080957.GB29680@pox.localdomain>
	<87lhbx72j2.fsf@x220.int.ebiederm.org>
	<20150923162927.6d437a1f@griffin>
	<8761313ud5.fsf@x220.int.ebiederm.org>
	<20150923225456.74c5cd1d@griffin>
	<878u7w6dxh.fsf@x220.int.ebiederm.org>
	<20150923230808.GA12825@pox.localdomain>
	<87lhbws6pz.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751991AbbIXITs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 04:19:48 -0400
In-Reply-To: <87lhbws6pz.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Sep 2015 00:54:00 -0500, Eric W. Biederman wrote:
> My only interest in this is to help figure out how to make IPv6 ndisc
> work over light weight tunnels.

Thanks for that. However, as much as some of the things you wrote in
this mail make sense (see below), I don't see how they help with this
particular problem. You seem to be concerned mostly with ingress and
the existence of metadata_dst, while the problem with IPv6 is there's
currently no place to attach egress tunnel info to.

> We can't use the metadata dst for IPv6 neighbour discovery.  Neighbour
> discovery processing comes after ip6_route_input.  That is what makes
> such a network device operation interesting today.
> 
> We don't need the information in the metadata dst because the
> information that was in the metadata dst is still in the packet we just
> need to reparse the packet.

That's an interesting point. For ARP and ndisc, we can certainly do
that. For ovs and similar use cases, I'm not sure. We can certainly
make it work this way but we'd need a ndo for reparsing the header.
Compared to the current situation where we just carry the parsed data,
reparsing seems to be more expensive. I'd expect this would show in
performance numbers.

> Given that the input network device is per tunnel type, the network
> device method will already know the format of the tunnel packet and so
> should not have any trouble parsing it.

Yes.

> As an assist we can preserve 90% of the information in ip_tunnel_key by
> repurposing inner_transport_header, inner_network_header and
> inner_mac_header (which are only valid on output packets today) as
> outer_transport_header, outer_network_header and outer_mac_header for
> input packets.
>
> That makes tun_id the only field of struct ip_tunnel_key that we have to
> work to find.

You will need to know the format of the tunnel header to get tun_id.
Because we want the users generic, it means a ndo to parse the headers.

> Creating outer_transport_header, outer_network_header and
> outer_mac_header should open up a lot of optmization opportunities
> for input tunnel processing.  I expect with just a little bit of care
> we should be able to replace the input metadata dst with a handful
> of fields stored in skb->cb.  Which in turn means no memory allocations
> are necessary, and that the work can be done unconditionally.

Which would mean no GRO. Which is probably no problem. Seems it may
indeed be an optimization. Doesn't have much to do with this set,
though, we'd still have the exact same problems as now and the exact
same ways to fix them.

 Jiri

-- 
Jiri Benc
