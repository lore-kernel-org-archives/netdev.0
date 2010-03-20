From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] xfrm: implement basic garbage collection for bundles
Date: Sat, 20 Mar 2010 09:26:33 -0400
Message-ID: <20100320132633.GB30349@hmsreliant.think-freely.org>
References: <1269087341-7009-1-git-send-email-timo.teras@iki.fi>
 <20100320123247.GB1930@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38281 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808Ab0CTN0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 09:26:44 -0400
Content-Disposition: inline
In-Reply-To: <20100320123247.GB1930@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 20, 2010 at 08:32:48PM +0800, Herbert Xu wrote:
> On Sat, Mar 20, 2010 at 02:15:41PM +0200, Timo Teras wrote:
> > The dst core calls garbage collection only from dst_alloc when
> > the dst entry threshold is exceeded. Xfrm core currently checks
> > bundles only on NETDEV_DOWN event.
> > 
> > Previously this has not been a big problem since xfrm gc threshold
> > was small, and they were generated all the time due to another bug.
> > 
> > Since after a33bc5c15154c835aae26f16e6a3a7d9ad4acb45
> > ("xfrm: select sane defaults for xfrm[4|6] gc_thresh") we can have
> > large gc threshold sizes (>200000 on machines with normal amount
> > of memory) the garbage collection does not get triggered under
> > normal circumstances. This can result in enormous amount of stale
> > bundles. Further more, each of these stale bundles keep a reference
> > to ipv4/ipv6 rtable entries which are already gargage collected and
> > put to dst core "destroy free'd dst's" list. Now this list can grow
> > to be very large, and the dst core periodic job can bring even a fast
> > machine to it's knees.
> 
> So why do we need this larger threshold in the first place? Neil?
My initial reasoning is here:
http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commit;h=a33bc5c15154c835aae26f16e6a3a7d9ad4acb45
I'd had a bug  claiming that ipsec didn't scale to thousands of SA's, and the
reason turned out to be that xfrm code capped their entry threshold at 1024
entries:
https://bugzilla.redhat.com/show_bug.cgi?id=253053

I exported the gc thresholds via sysctls, and then used the above commit to
select sane values, reasoning that we should be able to support as many tunnels
as routes when possible.

If its too high, I have no qualm with lowering it, given that those that need it
can bump it up higher via the sysctl.

Regards
Neil

> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 
> 
