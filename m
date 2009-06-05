From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Fri, 5 Jun 2009 15:17:26 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0906051444360.29918@gentwo.org>
References: <alpine.DEB.1.10.0906021044430.15692@gentwo.org> <20090603.224104.222901210.davem@davemloft.net> <alpine.DEB.1.10.0906041150590.3204@gentwo.org> <20090604.153057.178458221.davem@davemloft.net> <alpine.DEB.1.10.0906050959380.23895@gentwo.org>
 <adaeitywrfj.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yosefe@Voltaire.COM
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:37400 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752815AbZFETRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 15:17:37 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B458182C8BE
	for <netdev@vger.kernel.org>; Fri,  5 Jun 2009 15:32:39 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id x7FKXMZq4dYd for <netdev@vger.kernel.org>;
	Fri,  5 Jun 2009 15:32:39 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4D40082C7CB
	for <netdev@vger.kernel.org>; Fri,  5 Jun 2009 15:32:30 -0400 (EDT)
In-Reply-To: <adaeitywrfj.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 5 Jun 2009, Roland Dreier wrote:

>  > ARP is tied to managing small chunks of information about the network
>  > infrastructure. Buffering the first few and throwing the rest away is
>  > appropriate there for what the ARP protocol intends to do.
>
> Yes, but what the IP stack is doing is queueing a few packets while ARP
> is pending and dropping all other packets until the destination ethernet
> address is resolved.

Usually the ARP resolution is already established so its not that big an
issue. In order for ARP resolution to matter we have to send to a
IP address that is not in the current ARP cache.
We ran a test here sending UDP unicast and indeed we get udp packet loss.

However, *no* initial packets made it at all to the destination. We
had an effective outage for 3 milliseconds of packets being
discarded before anything is received. However, once it starts packets
flow continually without a problem.

This is actually better than IPoIB there is nothing before
the initial traffic that arrives. In the IPoIB case 3 packets arrive
suggesting to the other side that the link is okay.

In the MC case a IGMP join must also be performed which likely takes much
longer and the switches will hold off traffic for awhile. We have a
mininum here of 8 milliseconds of those outages. Then the first 3 packet
arrive.

>  > UDP multicasting can be used for streaming information. And right now the
>  > IPoIB layer is dropping thousands of packets whenever there was a pause of
>  > a few minutes or when a new multicast group is used and there is some
>  > delay that the network need to reestablish the multicast route.
>
> Yes -- and the required IB multicast resolution seems like it is an L2
> thing precisely analogous to ARP.  So I think the original IPoIB code
> actually was doing the right thing.

Then why dont the 1G NICs do the same?

Why are apps no longer working right when we move them from 1G to
IPoIB?
