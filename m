From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCHv2] sctp: Fix port hash table size computation
Date: Fri, 19 Feb 2016 09:07:03 -0500
Message-ID: <20160219140703.GA20372@hmsreliant.think-freely.org>
References: <20160218.153921.2010668846576353053.davem@davemloft.net>
 <1455829857-15797-1-git-send-email-nhorman@tuxdriver.com>
 <1455877730.648.21.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Dmitry Vyukov <dvyukov@google.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47611 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1948804AbcBSOHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 09:07:16 -0500
Content-Disposition: inline
In-Reply-To: <1455877730.648.21.camel@edumazet-ThinkPad-T530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2016 at 11:28:50AM +0100, Eric Dumazet wrote:
> On jeu., 2016-02-18 at 16:10 -0500, Neil Horman wrote:
> > Dmitry Vyukov noted recently that the sctp_port_hashtable had an error in
> > its size computation, observing that the current method never guaranteed
> > that the hashsize (measured in number of entries) would be a power of two,
> > which the input hash function for that table requires.  The root cause of
> > the problem is that two values need to be computed (one, the allocation
> > order of the storage requries, as passed to __get_free_pages, and two the
> > number of entries for the hash table).  Both need to be ^2, but for
> > different reasons, and the existing code is simply computing one order
> > value, and using it as the basis for both, which is wrong (i.e. it assumes
> > that ((1<<order)*PAGE_SIZE)/sizeof(bucket) is still ^2 when its not).
> 
> Looks complicated for a stable submission.
> 
> What about reusing existing trick instead ?
> 
> 
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index ab0d538..3e4e11b 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -1434,6 +1434,10 @@ static __init int sctp_init(void)
>  	do {
>  		sctp_port_hashsize = (1UL << order) * PAGE_SIZE /
>  					sizeof(struct sctp_bind_hashbucket);
> +
> +		while (sctp_port_hashsize & (sctp_port_hashsize - 1))
> +			sctp_port_hashsize--;
> +
>  	if ((sctp_port_hashsize > (64 * 1024)) && order > 0)
>  		continue;
>  	sctp_port_hashtable = (struct sctp_bind_hashbucket *)
> 
> 
> 

I had actually thought about that, but to be frank I felt like the logic to
compute the hashsize was complex the way it was presented currently, and that my
rewite made it more clear, breaking it down into a few easy steps:

1) compute a goal size order
2) compute the target order for the largest table we want to support
3) select the minimum of (1) and (2)
4) allocated the largest table we can up to the size in (3)
5) compute how many buckets the table we allocated in (4) supports


I'm happy to use your suggestion above if the consensus is that its more clear,
but it took me a bit to figure out what exactly the existing code was trying to
do (especially given the dual use of the order variable), so I thought some
additional clarity was called for.

Neil
