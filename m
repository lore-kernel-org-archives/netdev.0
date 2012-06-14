From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] ipv4: Kill ip_rt_frag_needed().
Date: Wed, 13 Jun 2012 22:59:41 -0700 (PDT)
Message-ID: <20120613.225941.2175393318277942399.davem@davemloft.net>
References: <20120613.032228.1574539964049471628.davem@davemloft.net>
	<20120614053529.GP27795@secunet.com>
	<20120613.224203.297717896085583687.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37562 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006Ab2FNF7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 01:59:42 -0400
In-Reply-To: <20120613.224203.297717896085583687.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 13 Jun 2012 22:42:03 -0700 (PDT)

> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Thu, 14 Jun 2012 07:35:29 +0200
> 
>> With your patch applied, we stop setting the DF bit after we
>> received a 'need to frag' ICMP message, but we don't fragment. We
>> send the packets out unfragmented. Before we removed
>> ip_rt_frag_needed(), we did the fragmentation according to the pmtu
>> informations we got from the icmp message. Now the router with the
>> low mtu has to do the fragmentation.
> 
> Ok, then if we want to do the fragmentation locally then we have to
> consider my initial patch which updates the PMTU in raw_err().
> 
> Did you test that?  I mean specifically, this patch:
> 
> http://marc.info/?l=linux-netdev&m=133945597319917&w=2
> 
> If it works for you, I will try to extend it to the other datagram
> cases.

Actually, thinking some more, we could extend my inet->pmtudisc patch
to achieve a similar effect.

Essentially we'd have a socket local PMTU value for datagram sockets.

Would you be OK with that approach?

I like the inet->pmtudisc way of solving this problem, because it:

1) Requires no special code to "remember" the flow used for the last
   socket sendmsg() call.

2) In the events of a malicious attempt to poison the routing cache
   PMTU information, only one socket will be harmed, rather than
   the whole system.

I tried to look for inspiration in other systems, but all of them lack
source based routing and other things we support, so they just use
a purely destination address based cache for PMTU information.

Other systems also don't have to deal with SO_BINDTODEVICE which
influences the route.

So we absolutely have to make our PMTU operations with the full
context used to emit the packet.
