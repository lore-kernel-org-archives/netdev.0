From: David Miller <davem@davemloft.net>
Subject: Re: slow tcp connect when using IPsec
Date: Fri, 25 Mar 2011 01:27:49 -0700 (PDT)
Message-ID: <20110325.012749.235670347.davem@davemloft.net>
References: <20110325064116.GE1290@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57624
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933056Ab1CYI1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 04:27:10 -0400
In-Reply-To: <20110325064116.GE1290@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 25 Mar 2011 07:41:16 +0100

> commit 5e2b61f78411be25f0b84f97d5b5d312f184dfd1
> Author: David S. Miller <davem@davemloft.net>
> Date:   Fri Mar 4 21:47:09 2011 -0800
> 
>     ipv4: Remove flowi from struct rtable.
> 
> Some time and a lot of trace_printks later I found that we set up
> the flow informations without source _and_ destination address in
> ip_route_newports(). That is because we take the address informations
> from the the rt_key_src and rt_key_dst fields of the rtable here
> and they appear to be empty. If I restore the behaviour before the bisected
> commit by taking the address informations from rt_src and rt_dst the issue
> is gone.

Indeed, it is wrong to use the key values, since they can be
wildcards.  Thanks for tracking this down.

> So now I know why it did not behave as expected, but unfortunately I
> still don't know why it magically started to work after 20
> seconds...

After some time, TCP will mark routing path as having trouble, then it
will relookup the route.  At this point source and dest will no longer
be wildcarded in the socket, and thus neither will be the resulting
route keys in the relooked-up route.

Look for the dst_negative_advice() paths to see where this happens.
