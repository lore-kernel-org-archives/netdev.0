From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [ovs-dev] [PATCH net 0/2] vxlan: Set a large MTU on ovs-created
 vxlan devices
Date: Sun, 10 Jan 2016 11:49:49 +0100
Message-ID: <20160110104949.GE1190@pox.localdomain>
References: <8660z6qohn.fsf@weave.works>
 <CAEh+42iWSZOyikNydU2Bs8meqYfrKfUJLDGFJ8HzQ06k64LP0g@mail.gmail.com>
 <568DADEE.1050206@stressinduktion.org>
 <CAEh+42h_dH5-AYBN+L=+LMfNLXhSfs-AwWh_aZ_oLfZ1NV48Zg@mail.gmail.com>
 <20160107114935.GJ32456@pox.localdomain>
 <CAEh+42hA69_e1HRGzsfzc2yGNgr6d8Bg4+pD8EQPdou5LzUegA@mail.gmail.com>
 <20160107172137.GA24672@pox.localdomain>
 <568EA55A.7070305@stressinduktion.org>
 <20160107184042.GB24672@pox.localdomain>
 <56902A3D.4090508@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@kernel.org>, David Wragg <david@weave.works>,
	David Miller <davem@davemloft.net>, dev@openvswitch.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37069 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754885AbcAJKtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 05:49:52 -0500
Received: by mail-wm0-f52.google.com with SMTP id f206so229295312wmf.0
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 02:49:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56902A3D.4090508@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/16 at 10:29pm, Hannes Frederic Sowa wrote:
> On 07.01.2016 19:40, Thomas Graf wrote:
> >I think you are worried about an ICMP error from a hop which does not
> >decrement TTL. I think that's a good point and I think we should only
> >send an ICMP error if the TTL is decremented in the action list of
> >the flow for which we have seen a MTU based drop (or TTL=0).
> 
> Also agreed, ovs must act in routing mode but at the same time must have an
> IP address on the path. I think this is actually the problem.
> 
> Currently we have no way to feedback an error in current configurations with
> ovs sitting in another namespace for e.g. docker containers:
> 
> We traverse a net namespace so we drop skb->sk, we don't hold any socket
> reference to enqueue an PtB error to the original socket.
> 
> We mostly use netif_rx_internal queues the socket on the backlog, so we
> can't signal an error over the callstack either.
> 
> And ovs does not necessarily have an ip address as the first hop of the
> namespace or the virtual machine, so it cannot know a valid ip address with
> which to reply, no?

[your last statement moved up here:]
> If we are doing L3 forwarding into a tunnel, this is absolutely correct and
> can be easily done.

OK, I can see where you are going with this. I was assuming pure
virtual networks due to the contexts of these patches.

So an ICMP is always UDP encapsulated or directly delivered to a veth or
tap which runs in its own netns or is a VM of which the IP stack
operates exclusively in the context of the virtual network. The stack of
the OVS host never gets to see the actual ICMPs and rp_filter never gets
into play.

In such a context, the virtual router IPs are typically programmed
into the flow table because they are only valid in the virtual network
context, assigning them to the OVS bridge would be wrong as it
represents the underlay context.

The virtual router address is known in the flow context of the virtual
network though and can be given to the icmp_send variant.

Can you elaborate a bit on your container scenario, is it ovs running
in host netns with veth pairs bridging into container netns?

Shouldn't that be solved with the above as the ICMPs sent back in
return by the local OVS are perfectly valid in the IP stack context of
the container netns?
