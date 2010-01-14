From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: netfilter: nf_conntrack: add support for "conntrack zones"
Date: Thu, 14 Jan 2010 10:05:49 -0500
Message-ID: <1263481549.23480.24.camel@bigi>
References: <4B4F24AC.70105@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Ben Greear <greearb@candelatech.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f194.google.com ([209.85.221.194]:46565 "EHLO
	mail-qy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756974Ab0ANPFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 10:05:52 -0500
In-Reply-To: <4B4F24AC.70105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ive had an equivalent discussion with B Greear (CCed) at one point on
something similar, curious if you solve things differently - couldnt
tell from the patch if you address it.
Comments inline:

On Thu, 2010-01-14 at 15:05 +0100, Patrick McHardy wrote:
> The attached largish patch adds support for "conntrack zones",
> which are virtual conntrack tables that can be used to seperate
> connections from different zones, allowing to handle multiple
> connections with equal identities in conntrack and NAT.
>
> A zone is simply a numerical identifier associated with a network
> device that is incorporated into the various hashes and used to
> distinguish entries in addition to the connection tuples. Additionally
> it is used to seperate conntrack defragmentation queues. An iptables
> target for the raw table could be used alternatively to the network
> device for assigning conntrack entries to zones.
>
>
> This is mainly useful when connecting multiple private networks using
> the same addresses (which unfortunately happens occasionally) 

Agreed that this would be a main driver of such a feature.
Which means that you need zones (or whatever noun other people use) to
work on not just netfilter, but also routing, ipsec etc.
As a digression: this is trivial to solve with network namespaces. 

> to pass
> the packets through a set of veth devices and SNAT each network to a
> unique address, after which they can pass through the "main" zone and
> be handled like regular non-clashing packets and/or have NAT applied a
> second time based f.i. on the outgoing interface.
> 

The fundamental question i have is:
how you deal with overlapping addresses?
i.e zone1 uses 10.0.0.1 and zone2 uses 10.0.0.1 but they are for
different NAT users/endpoints.

> Something like this, with multiple tunl and veth devices, each pair
> using a unique zone:
> 
>   <tunl0 / zone 1>
>      |
>   PREROUTING
>      |
>   FORWARD
>      |
>   POSTROUTING: SNAT to unique network
>      |
>   <veth1 / zone 1>
>   <veth0 / zone 0>
>      |
>   PREROUTING
>      |
>   FORWARD
>      |
>   POSTROUTING: SNAT to eth0 address
>      |
>   <eth0>
> 
> As probably everyone has noticed, this is quite similar to what you
> can do using network namespaces. The main reason for not using
> network namespaces is that its an all-or-nothing approach, you can't
> virtualize just connection tracking. 

Unless there is a clever approach for overlapping IP addresses (my
question above), i dont see a way around essentially virtualizing the
whole stack which clone(CLONE_NEWNET) provides..

> Beside the difficulties in
> managing different namespaces from f.i. an IKE or PPP daemon running
> in the initial namespace, 

This is a valid concern against the namespace approach. Existing tools
of course could be taught to know about namespaces - and one could
argue that if you can resolve the overlap IP address issue, then you
_have to_ modify user space anyways.

> network namespaces have a quite large
> overhead, especially when used with a large conntrack table.

Elaboration needed.
You said the size in 64 bit increases to 152B per conntrack i think?
Do you have a hand-wave figure we can use as a metric to elaborate this
point? What would a typical user of this feature have in number of
"zones" and how many contracks per zone? Actually we could also look
at extremes (huge number vs low numbers)...

You may also wanna look as a metric at code complexity/maintainability
of this scheme vs namespace (which adds zero changes to the kernel).
I am pretty sure you will soon be "zoning" on other pieces of the net
stack ;->

> I'm not too fond of this partial feature duplication myself, but I
> couldn't think of a better way to do this without the downsides of
> using namespaces. Having partially shared network namespaces would
> be great, but it doesn't seem to fit in the design very well.
> I'm open for any better suggestion :)

My opinions above.

BTW, why not use skb->mark instead of creating a new semantic construct?

cheers,
jamal

