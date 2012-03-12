From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Allocate unique metrics for icmp6 packets to
 prevent tainting dst metrics
Date: Mon, 12 Mar 2012 12:48:59 -0700 (PDT)
Message-ID: <20120312.124859.1068600282113438294.davem@davemloft.net>
References: <4F5E133E.4040308@network-box.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nick.jones@network-box.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50566 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756343Ab2CLTtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 15:49:17 -0400
In-Reply-To: <4F5E133E.4040308@network-box.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Jones <nick.jones@network-box.com>
Date: Mon, 12 Mar 2012 23:16:14 +0800

> The generation of an icmp6 packet, targeted to a specific desination
> address, will cause the shared metrics of the ip6_dst and inetpeer
> of that address to be tainted with the hoplimit value 255.
> All packets, icmp6 or otherwise, will have this hoplimit value, and
> if the destination is a router, not even advertisements specifying a
> new hoplimit value will have any effect due to the way
> ip6_dst_hoplimit works.
> 
> By allocating a unique metrics array for the icmp6 packet, the shared
> metrics will not be tainted.
> 
> Signed-off-by: Nick Jones <nick.jones@network-box.com>

You can't just change the allocation side.

You now have to make sure the free'ing side knows that these special
routes use kmalloc()'d metrics.  On ipv6 this is implemented in
ip6_dst_destroy().  Unless DST_HOST will be clear on all of these
icmp6 routes, the metrics will be leaked because ip6_dst_destroy()
will not invoke dst_destroy_metrics_generic() which would do the
kfree().
