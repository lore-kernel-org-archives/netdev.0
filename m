From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH] inet: fix enforcing of fragment queue hash list depth
Date: Mon, 15 Apr 2013 17:26:37 +0200
Message-ID: <20130415152637.GA29378@order.stressinduktion.org>
References: <20130415142454.14020.18322.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44399 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754871Ab3DOP0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 11:26:39 -0400
Content-Disposition: inline
In-Reply-To: <20130415142454.14020.18322.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesper!

On Mon, Apr 15, 2013 at 04:25:10PM +0200, Jesper Dangaard Brouer wrote:
> I have found an issues with commit:
> 
>  commit 5a3da1fe9561828d0ca7eca664b16ec2b9bf0055
>  Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
>  Date:   Fri Mar 15 11:32:30 2013 +0000
> 
>     inet: limit length of fragment queue hash table bucket lists
> 
> There is a connection between the fixed 128 hash depth limit and the
> frag mem limit/thresh settings, which limits how high the thresh can
> be set.
> 
> The 128 elems hash depth limit, results in bad behaviour if mem limit
> thresh holds are increased, via /proc/sys/net ::
> 
>  /proc/sys/net/ipv4/ipfrag_high_thresh
>  /proc/sys/net/ipv4/ipfrag_low_thresh
> 
> If we increase the thresh, to something allowing 128 elements in each
> bucket, which is not that high given the hash array size of 64
> (64*128=8192), e.g.
>   big MTU frags (2944(truesize)+208(ipq))*8192(max elems)=25755648
>   small frags   ( 896(truesize)+208(ipq))*8192(max elems)=9043968

I thought it was pretty high already. While creating this patch I also
had a patch which did calculate the chain limit while updating the sysctl
high_thresh knob (perhaps this could be of use):

http://patchwork.ozlabs.org/patch/227136/

Perhaps we should reconsider the formula I choose to calculate this limit.
But because we would actually have 128 iterations in the hash bucket I
am more in favor of resizing (or even come up with a way to dynamically
resize) the hash table. On a smaller sized machine I can actually create
severe latency because of the list iteration even with the 128 list length
limit in place.

> The problem with commit 5a3da1fe (inet: limit length of fragment queue
> hash table bucket lists) is that, once we hit the limit, the we *keep*
> the existing frag queues, not allowing new frag queues to be created.
> Thus, an attacker can effectivly block handling of fragments for 60
> sec (as each frag queue have a timeout of 60 sec).
> 
> Even without increasing the limit, as Hannes showed, an attacker on
> IPv6 can "attack" a specific hash bucket, and via that change, can
> block/drop new fragments also (trying to) utilize this bucket.
> 
> Summary:
>  With the default mem limit/thresh settings, this is not general
> problem, but adjusting the thresh limits result in some-what
> unexpected behavior.
> 
> Proposed solution:
>  IMHO instead of keeping existing frag queues, we should kill one of
> the frag queues in the hash instead.

I thought that if we actually reach this limit the machine would be in
some kind DoS situation and there won't be a good solution to identify
harmless fragments from non-harmless fragments. So I settled with the
simple drop and did not try to come up with a load balancing or rehashing
method.

My first try to solve this problem actually was converting the hash chains
from hlists to lists (so doubling the size of the hash table by two) to be
able to drop the last element per bucket.

> Implementation complications:
>  Killing of frag queues while only holding the hash bucket lock, and
> not the frag queue lock, complicates the implementation, as we race
> and can end up (trying to) remove the hash element twice (resulting in
> an oops).

I will have to play with this patch a bit. Perhaps I have some more insights
after that. :)

Thanks for looking into it,

  Hannes
