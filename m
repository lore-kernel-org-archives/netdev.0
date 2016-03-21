From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 0/9] RFC6864 compliant GRO and GSO partial offload
Date: Mon, 21 Mar 2016 14:50:14 -0400 (EDT)
Message-ID: <20160321.145014.2053938894183716531.davem@davemloft.net>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, netdev@vger.kernel.org,
	alexander.duyck@gmail.com, tom@herbertland.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50772 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756517AbcCUT3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 15:29:46 -0400
In-Reply-To: <20160318230945.14955.63211.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Fri, 18 Mar 2016 16:24:38 -0700

> This patch series addresses two things.
> 
> First it enables what I am calling RFC6864 compliant GRO.  Basically what
> I am doing is allowing one of two patterns for incoming frames.  Either the
> IP ID will increment, or if the DF bit is set it can either increment or
> stay the same value.  This allows us to perform GRO if the IP ID is forced
> to stay at a static value as may occur if we are replicating an IP header
> instead of actually having it offloaded.
> 
> The last 3 patches introduce what I am calling GSO partial.  The best way
> to describe it is that it is a GSO offload in which the portion pointed to
> by csum_start must be handled by the hardware, and the region before that
> can be optionally handled.  So for example with i40e the only pieces it was
> missing from the full offload was the checksum so this is computed in
> software and the hardware will update inner and outer IP headers.  In the
> example for ixgbe the hardware will only update the outer IP header.  The
> outer UDP or GRE header and inner IP header are unmodified.

Conceptually I am completely fine with these changes.

> The one concern here is that if the outer IP header does not have
> the DF bit set and does not update the IP ID field we run the risk
> of causing all sorts of problems if the packet is fragmented in
> flight.

I think we absolutely cannot let such a packet be output from our
stack.
