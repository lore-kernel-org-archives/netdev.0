From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH][XFRM] Replace rwlock on xfrm_policy_afinfo with rcu
Date: Wed, 08 Aug 2012 08:25:47 +0200
Message-ID: <1344407147.28967.212.camel@edumazet-glaptop>
References: <1344316904-2544-1-git-send-email-Priyanka.Jain@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Priyanka Jain <Priyanka.Jain@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:42372 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575Ab2HHGZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 02:25:51 -0400
Received: by weyx8 with SMTP id x8so249883wey.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 23:25:50 -0700 (PDT)
In-Reply-To: <1344316904-2544-1-git-send-email-Priyanka.Jain@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-07 at 10:51 +0530, Priyanka Jain wrote:
> xfrm_policy_afinfo is read mosly data structure.
> Write on xfrm_policy_afinfo is done only at the
> time of configuration.
> So rwlocks can be safely replaced with RCU.
> 
> RCUs usage optimizes the performance.


>  static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family)
> @@ -2530,16 +2535,16 @@ static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family)
>  	struct xfrm_policy_afinfo *afinfo;
>  	if (unlikely(family >= NPROTO))
>  		return NULL;
> -	read_lock(&xfrm_policy_afinfo_lock);
> -	afinfo = xfrm_policy_afinfo[family];
> +	rcu_read_lock();
> +	afinfo = rcu_dereference(xfrm_policy_afinfo[family]);
>  	if (unlikely(!afinfo))
> -		read_unlock(&xfrm_policy_afinfo_lock);
> +		rcu_read_unlock();

This makes no sense to me : We cant safely return afinfo here. 

Note the current code is buggy as well, this is worrying.

As soon as we exit from xfrm_policy_get_afinfo(), pointer might be
invalid.

Really, RCU conversion should be the right moment to spot those bugs and
first fix them (for stable trees)
