From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Fix race between sk_filter reassign and sk_clone()
Date: Wed, 17 Oct 2007 21:23:02 -0700 (PDT)
Message-ID: <20071017.212302.68039057.davem@davemloft.net>
References: <4715D9D2.8070102@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43000
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751015AbXJREXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 00:23:10 -0400
In-Reply-To: <4715D9D2.8070102@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 17 Oct 2007 13:45:54 +0400

> The race can result in that some sock will get an sk_filter
> pointer set to kfree-d memory. Look
> 
> CPU1:                            CPU2:
> sk_clone():                      sk_attach_filter():
>   new_sk = sk_alloc(...);
>   sock_copy(new_sk, sk); 
>   /* copies the filter ptr */
>   ...
>   filter = new_sk->sk_filter;
>   if (filter)
>                                      old_fp = sk->sk_filter;
>                                      ...
>                                      sk_filter_release(old_fp);
>                                        if (atomic_dec_and_test(&old_fp->refcnt))
>      atomic_inc(&filter->refcnt);
>                                           /* true */
>                                           call_rcu(&fp->rcu, kfree);
> 
> that's it - after a quiescent state pass the new_sk will have 
> a pointer on kfree-d filter.
> 
> The same problem exists for detaching filter (SO_DETACH_FILTER).
> 
> The proposed fix consists of 3 preparation patches and the fix itself.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Looks good, applied.

Thanks for fixing this bug Pavel!
