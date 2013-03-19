From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH net] inet: limit length of fragment queue hash table
 bucket lists
Date: Tue, 19 Mar 2013 15:20:40 +0100
Message-ID: <1363702840.3232.104.camel@localhost>
References: <20130315213230.GB24041@order.stressinduktion.org>
	 <20130319.100324.927922515830950770.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59692 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755351Ab3CSOUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 10:20:46 -0400
In-Reply-To: <20130319.100324.927922515830950770.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-19 at 10:03 -0400, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Fri, 15 Mar 2013 22:32:30 +0100
> 
> > This patch introduces a constant limit of the fragment queue hash
> > table bucket list lengths. Currently the limit 128 is choosen somewhat
> > arbitrary and just ensures that we can fill up the fragment cache with
> > empty packets up to the default ip_frag_high_thresh limits. It should
> > just protect from list iteration eating considerable amounts of cpu.
> > 
> > If we reach the maximum length in one hash bucket a warning is printed.
> > This is implemented on the caller side of inet_frag_find to distinguish
> > between the different users of inet_fragment.c.
> > 
> > I dropped the out of memory warning in the ipv4 fragment lookup path,
> > because we already get a warning by the slab allocator.
> > 
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> This looks mostly fine to me, Eric could you give it a quick review?
> 
> Although one comment from me:
> 
> > +/* averaged:
> > + * max_depth = default ipfrag_high_thresh / INETFRAGS_HASHSZ /
> > + *	       rounded up (SKB_TRUELEN(0) + sizeof(struct ipq or
> > + *	       struct frag_queue))
> > + */
> > +#define INETFRAGS_MAXDEPTH		128
> 
> If we deem this to be the ideal formula, maybe we can maintain it
> accurately and very cheaply at run time.  We'd do this by adding a
> handler for the ipfrag_high_thresh sysctl, and use that to recalculate
> the maxdepth any time ipfrag_high_thresh is changed by the user.

I think it's overkill to implement this now.  I just want this patch in
as a safeguard.

The idea I discussed with Eric, will remove the need for this patch.
The idea is to drop the LRU lists, increase the hash size a bit, and do
cleanup/eviction directly on the frag hash tables.  And e.g. only allow
5 frag queue elements in each hash bucket... but more work and testing
is needed before I have something ready.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
