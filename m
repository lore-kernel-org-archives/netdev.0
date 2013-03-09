From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash table
Date: Sat, 9 Mar 2013 16:19:23 +0100
Message-ID: <20130309151923.GH28531@order.stressinduktion.org>
References: <20130307214211.GP7941@order.stressinduktion.org> <20130308055718.GA28531@order.stressinduktion.org> <20130308130433.GB28531@order.stressinduktion.org> <1362754386.15793.226.camel@edumazet-glaptop> <20130308150831.GD28531@order.stressinduktion.org> <1362756219.15793.240.camel@edumazet-glaptop> <20130308155404.GE28531@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53425 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932441Ab3CIPT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 10:19:26 -0500
Content-Disposition: inline
In-Reply-To: <20130308155404.GE28531@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 08, 2013 at 04:54:04PM +0100, Hannes Frederic Sowa wrote:
> On Fri, Mar 08, 2013 at 07:23:39AM -0800, Eric Dumazet wrote:
> > On Fri, 2013-03-08 at 16:08 +0100, Hannes Frederic Sowa wrote:
> > > On Fri, Mar 08, 2013 at 06:53:06AM -0800, Eric Dumazet wrote:
> > > > No matter how you hash, a hacker can easily fill your defrag unit with
> > > > not complete datagrams, so what's the point ?
> > > 
> > > I want to harden reassembly logic against all fragments being put in
> > > the same hash bucket because of malicious traffic and thus creating
> > > long list traversals in the fragment queue hash table.
> > 
> > Note that the long traversal was a real issue with TCP (thats why I
> > introduced ipv6_addr_jhash()), as a single ehash slot could contains
> > thousand of sockets.
> > 
> > But with fragments, we should just limit the depth of any particular
> > slot, and drop above a particular threshold.
> > 
> > reassembly is a best effort mechanism, better make sure it doesnt use
> > all our cpu cycles.
> 
> Hm, I have to think about it, especially because it is used in the netfilter
> code. There could be some fairness issues if packets get dropped in netfilter
> if reassembly could not be performed. I'll check this.

There should be no fairness issues in the forwarding path because
legitimate traffic should send a reasonable random 32bit fragmentation
id which is a direct input to jhash.

I thought about the list length limit this morning and I believe we have
to dynamically compute it (maybe on sysctl change), because I bet people
want to have their fragmentation cache utilized if they higher the memory
thresholds (maybe dns resolvers with dnssec employed). The missing value
is the average skb->truesize so I'll have to assume one. Any pointers
on this? We could also export the limit to userspace and have the users
deal with it. But I am not in favour of this solution.

Should we do reclamation in the hash buckets (I would have to switch
from hlist to list) or just drop incoming fragments (this should be
fairly easy). Currently we discard fragments in lru fashion, so I think
reclamation would be the way to go, too.

Thanks,

  Hannes
