From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/7] xfrm: remove policy lock when accessing policy->walk.dead
Date: Tue, 30 Mar 2010 07:55:07 +0300
Message-ID: <4BB1842B.9010704@iki.fi>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-2-git-send-email-timo.teras@iki.fi> <20100329144339.GA26214@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:54540 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753996Ab0C3EzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 00:55:11 -0400
Received: by ewy20 with SMTP id 20so1033042ewy.1
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 21:55:10 -0700 (PDT)
In-Reply-To: <20100329144339.GA26214@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Mar 29, 2010 at 05:12:38PM +0300, Timo Teras wrote:
>> @@ -1132,7 +1119,7 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
>>  		__xfrm_policy_link(pol, XFRM_POLICY_MAX+dir);
>>  	}
>>  	if (old_pol)
>> -		__xfrm_policy_unlink(old_pol, XFRM_POLICY_MAX+dir);
>> +		old_pol = __xfrm_policy_unlink(old_pol, XFRM_POLICY_MAX+dir);
>>  	write_unlock_bh(&xfrm_policy_lock);
>>  
>>  	if (old_pol) {
> 
> So when can this actually fail?

Considering that the socket reference is received from the sk->sk_policy,
and the hash bucket we use is "XFRM_POLICY_MAX+dir", it's non-obvious if
it can fail or not.

It would look like the timer can kill a policy and unlink it, but it
would still be found from sk_policy.

It probably doesn't really make sense to insert per-socket policy that
expires. But in case someone does something like that, I'd think we
need the above just to be sure.

Considering this, xfrm_sk_policy_lookup() should probably check the
dead flag, and cleanup sk_policy if it was killed by a timer.
