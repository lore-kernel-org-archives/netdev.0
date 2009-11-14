From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Sat, 14 Nov 2009 01:24:07 -0500
Message-ID: <20091114062407.GT19478@kvack.org>
References: <20091113233504.GQ19478@kvack.org> <20091113153924.6130135f@nehalam> <20091113235210.GR19478@kvack.org> <20091113.185937.251557071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, opurdila@ixiacom.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:56539 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752467AbZKNGYC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Nov 2009 01:24:02 -0500
Content-Disposition: inline
In-Reply-To: <20091113.185937.251557071.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 06:59:37PM -0800, David Miller wrote:
> From: Benjamin LaHaise <bcrl@lhnet.ca>
> Date: Fri, 13 Nov 2009 18:52:10 -0500
> 
> > If you don't want the overhead from this kind of scaling, stick it under a 
> > config option, but please don't stop other people from pushing Linux into 
> > new uses which have these scaling requirements.
> 
> This 'scaling requirement' only exists in environments where people
> undersubsribe their networks, right?

Depends on how you look at things.  The case of lots of interfaces going 
up/down can occur during normal operations.  The incumbent telco in this 
area has occasional flaps that reset thousands of sessions.  The problem 
relates to how things flop over to a different path within their network, 
as they don't provide hot standby circuits for all the aggregated traffic 
coming in -- a link down results in a flap of all the L2TP sessions.  As 
for it being underprovisioned, that doesn't really apply.  The core LNS 
boxes are kept from having saturated links, as that results in poor user 
performance.  Plus they have substantially more CPU than embedded routers.

> I'm not saying we won't put scaling into these areas, I'm just trying
> to make a point to show that this "need" only exists because people
> have purposefully created these situations where they feel the need to
> massively control their users usage in order to generate revenue.

I've finally got some of the userspace bits necessary for parallel network 
device creation wired up.  Will reducing the granularity of rtnl_lock() for 
devices which can handle it be okay?  That will get a factor of 4 to 8 
improvement from current single socket hardware.

The other way I'm working around the scaling issues is to use network 
namespaces.  Babylon (the L2TP/PPPoE stack I'm working on) can now split 
interface creation across some number of network namespaces.  This keeps 
the number of interfaces in a given net instance down to 5-10,000.  That 
really helps avoid some of the scaling issues, as we're pretty good in 
that range.

The worst part of all the overhead during setup and teardown is that very 
little traffic can pass while this is occurring, effectively making it an 
outage, hence the desire to minimise outage situations.

		-ben
