From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] ipv6: suppress sparse warnings in IP6_ECN_set_ce()
Date: Fri, 12 Aug 2016 07:43:38 +0200
Message-ID: <1470980618.12075.29.camel@sipsolutions.net>
References: <1470909883-5463-1-git-send-email-johannes@sipsolutions.net>
	 <1470950793.12189.7.camel@edumazet-glaptop3.roam.corp.google.com>
	 (sfid-20160811_232641_577451_4C1D2106)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:58017 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751091AbcHLFob (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2016 01:44:31 -0400
In-Reply-To: <1470950793.12189.7.camel@edumazet-glaptop3.roam.corp.google.com> (sfid-20160811_232641_577451_4C1D2106)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-11 at 23:26 +0200, Eric Dumazet wrote:
> On Thu, 2016-08-11 at 12:04 +0200, Johannes Berg wrote:
> > 
> > From: Johannes Berg <johannes.berg@intel.com>
> > 
> > Use the correct type for these manipulations, which is __wsum,
> > instead of using __be32. This doesn't really change anything
> > since __wsum really *is* __be32, but removes the address space
> > warnings from sparse.
> > 
> > Cc: Eric Dumazet <edumazet@google.com>
> > Fixes: 34ae6a1aa054 ("ipv6: update skb->csum when CE mark is
> > propagated")
> > Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> > ---
> >  include/net/inet_ecn.h | 8 ++++----
> >  1 file changed, 4 insertions(+), 4 deletions(-)
> > 
> > diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
> > index 0dc0a51da38f..89aa4e73fc37 100644
> > --- a/include/net/inet_ecn.h
> > +++ b/include/net/inet_ecn.h
> > @@ -119,14 +119,14 @@ struct ipv6hdr;
> >   */
> >  static inline int IP6_ECN_set_ce(struct sk_buff *skb, struct
> > ipv6hdr *iph)
> >  {
> > -	__be32 from, to;
> > +	__wsum from, to;
> >  
> >  	if (INET_ECN_is_not_ect(ipv6_get_dsfield(iph)))
> >  		return 0;
> >  
> > -	from = *(__be32 *)iph;
> > -	to = from | htonl(INET_ECN_CE << 20);
> > -	*(__be32 *)iph = to;
> > +	from = *(__wsum *)iph;
> 
> Well, 4 first bytes of iph are not a __wsum technically speaking :(
> 
> > 
> > +	to = from | (__force __wsum)htonl(INET_ECN_CE << 20);
> 
> Hmm... this is a bit convoluted.
> Doing a OR operation on a __wsum seems strange to me.

Yeah, I was a bit torn.

> > +	*(__wsum *)iph = to;
> >  	if (skb->ip_summed == CHECKSUM_COMPLETE)
> >  		skb->csum = csum_add(csum_sub(skb->csum, from),
> > to);
> >  	return 1;
> 
> 
> 
> What about something like that ?
> 
> No big deal, but this looks a bit cleaner to me.
> 
> Thanks.
> 
> diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
> index
> 0dc0a51da38faacab2ea275681f5f70e09a6c79e..dce2d586d9cecb9e9de381aa092
> 6f3e3d3ec9568 100644
> --- a/include/net/inet_ecn.h
> +++ b/include/net/inet_ecn.h
> @@ -128,7 +128,8 @@ static inline int IP6_ECN_set_ce(struct sk_buff
> *skb, struct ipv6hdr *iph)
>  	to = from | htonl(INET_ECN_CE << 20);
>  	*(__be32 *)iph = to;
>  	if (skb->ip_summed == CHECKSUM_COMPLETE)
> -		skb->csum = csum_add(csum_sub(skb->csum, from), to);
> +		skb->csum = csum_add(csum_sub(skb->csum, (__force
> __wsum)from),
> +				     (__force __wsum)to);
> 

I had exactly this originally, but then thought maybe using the right
type would be nicer. I'll send out this one again as v2, since you
prefer that.

johannes
