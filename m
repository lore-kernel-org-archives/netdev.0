From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NIU support for skb->rxhash
Date: Fri, 23 Apr 2010 01:14:56 -0700 (PDT)
Message-ID: <20100423.011456.48472321.davem@davemloft.net>
References: <20100422.042157.99869295.davem@davemloft.net>
	<1271936598.7895.5304.camel@edumazet-laptop>
	<20100422.141922.39169749.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48527
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750876Ab0DWIOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 04:14:51 -0400
In-Reply-To: <20100422.141922.39169749.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 22 Apr 2010 14:19:22 -0700 (PDT)

> Also I have some ideas about what we can do if we have
> just the rxhash.  It seems we can avoid the type_trans
> overhead on the interrupting cpu.
> 
> Things like eth_type_trans() become a netdev operation rather than
> something drivers statically call by hand. ->ndo_type_trans or
> similar.
> 
> SKB has a state bit saying whether ->ndo_type_trans has been invoked
> yet on RX.
> 
> Drivers pass raw SKBs up into the stack.
> 
> We defer the ->ndo_type_trans as far as possible, for RPS when we have
> ->rxhash we can defer this all the way to the destination RPS cpu.
> 
> If we lack ->rxhash, the source cpu will need to invoke
> ->ndo_type_trans before it can begin parsing the packet.

I looked into implementing this and it doesn't work.  The
problem is GRO want's to look into the packet very early
and we want to batch GRO a set of packets into a big packet
before shooting them over to a remote cpu.

This reminds me that we can start using ->rxhash as a quick
mismatch check in the GRO flow matcher.
