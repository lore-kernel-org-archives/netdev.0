From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: suspicious rcu_dereference_check in sctp_v6_get_dst
Date: Sat, 05 Dec 2015 17:56:28 -0800
Message-ID: <1449366988.25029.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151206002517.GB14181@codemonkey.org.uk>
	 <1449364386.25029.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151206013708.GA19228@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33911 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817AbbLFB4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 20:56:30 -0500
Received: by pfbg73 with SMTP id g73so46795493pfb.1
        for <netdev@vger.kernel.org>; Sat, 05 Dec 2015 17:56:29 -0800 (PST)
In-Reply-To: <20151206013708.GA19228@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-12-05 at 20:37 -0500, Dave Jones wrote:
> On Sat, Dec 05, 2015 at 05:13:06PM -0800, Eric Dumazet wrote:
>  
>  > > diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
>  > > index acb45b8c2a9d..7081183f4d9f 100644
>  > > --- a/net/sctp/ipv6.c
>  > > +++ b/net/sctp/ipv6.c
>  > > @@ -328,7 +328,9 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
>  > >  	if (baddr) {
>  > >  		fl6->saddr = baddr->v6.sin6_addr;
>  > >  		fl6->fl6_sport = baddr->v6.sin6_port;
>  > > +		rcu_read_lock();
>  > >  		final_p = fl6_update_dst(fl6, rcu_dereference(np->opt), &final);
>  > > +		rcu_read_unlock();
>  > >  		dst = ip6_dst_lookup_flow(sk, fl6, final_p);
>  > >  	}
>  > >  
>  > 
>  > Hmm, better use :
>  > 
>  > diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
>  > index acb45b8c2a9d..d28c0b4c9128 100644
>  > --- a/net/sctp/ipv6.c
>  > +++ b/net/sctp/ipv6.c
>  > @@ -323,14 +323,13 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
>  >  			}
>  >  		}
>  >  	}
>  > -	rcu_read_unlock();
>  > -
>  >  	if (baddr) {
>  >  		fl6->saddr = baddr->v6.sin6_addr;
>  >  		fl6->fl6_sport = baddr->v6.sin6_port;
>  >  		final_p = fl6_update_dst(fl6, rcu_dereference(np->opt), &final);
>  >  		dst = ip6_dst_lookup_flow(sk, fl6, final_p);
>  >  	}
>  > +	rcu_read_unlock();
>  >  
>  >  out:
>  >  	if (!IS_ERR_OR_NULL(dst)) {
> 
> I looked at that option first, but decided to mirror the other use of fl6_update_dst.
> 
> It looks like your solution would work too, so I'm not against it, but..
> For my own understanding, why is this better? Just to cut down on the
> number of repeated lock/unlocks in the same function?  Or is there some
> semantic I'm missing in the earlier lock/unlock section that's somehow
> related to the np->opt ?

This was my intent when cooking commit c836a8ba93869d6a0

I have no idea how I missed to move the rcu_read_lock()

Yes, there is no need to have too many rcu_read_lock()/unlock() all
around the places. Extending the existing section is good enough.
