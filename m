From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC net-next] ipv6: avoid high order memory allocations for /proc/net/ipv6_route
Date: Thu, 22 Aug 2013 05:16:02 +0200
Message-ID: <20130822031602.GA19269@order.stressinduktion.org>
References: <20130821175024.GA14419@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38628 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670Ab3HVDQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 23:16:05 -0400
Content-Disposition: inline
In-Reply-To: <20130821175024.GA14419@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 21, 2013 at 07:50:24PM +0200, Hannes Frederic Sowa wrote:
> I created this patch in a hurry while trying to get the rt6i_flags of
> the routing entries on a system with lots of routes (I later cleaned it
> up a bit).
> 
> The current approach for dumping routes over netlink is to redump a tree
> as soon as the serialnumber on the nodes changes. Is this behavior more
> preferable as to just ignore the routes for that moment? I am in favour
> of not restarting the dump on /proc/net/ipv6_route.

Ok, I hit the same panics as Patrick once did
while some more stress testing this change
(http://permalink.gmane.org/gmane.linux.network/151391).

As I read this up, this was also the reason the serial checks where
introduced. It also tries to skip visited notes, so please void my
question above.

The reason is a disconnected fib6_node in FWS_U state trying to walk
up. I'll investigate if we can fix this up in the walker post-cleanup on
fib6_repair_tree/fib6_del_route (then we could also remove the serial
number checks on inet6_dump_fib) or I will make the appropriate serial
changes to this patch, too.

> +int ipv6_route_open(struct inode *inode, struct file *file)
> +{
> +	return seq_open_net(inode, file, &ipv6_route_seq_ops,
> +			    sizeof(struct fib6_walker_t));
> +}
> +

sizeof(struct ipv6_route_iter) here, of course. :(

Greetings,

  Hannes
