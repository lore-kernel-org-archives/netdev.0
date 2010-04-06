From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 2/4] xfrm: cache bundles instead of policies for outgoing
 flows
Date: Tue, 06 Apr 2010 15:55:13 +0300
Message-ID: <4BBB2F31.7090806@iki.fi>
References: <1270450824-2928-1-git-send-email-timo.teras@iki.fi> <1270450824-2928-3-git-send-email-timo.teras@iki.fi> <20100406124014.GA24412@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:41711 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755053Ab0DFMzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 08:55:20 -0400
Received: by ewy20 with SMTP id 20so452890ewy.1
        for <netdev@vger.kernel.org>; Tue, 06 Apr 2010 05:55:17 -0700 (PDT)
In-Reply-To: <20100406124014.GA24412@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Apr 05, 2010 at 10:00:22AM +0300, Timo Teras wrote:
>> @@ -623,33 +618,11 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
>> +	hlist_for_each_entry_continue(policy, entry, bydst)
>> +		atomic_inc(&policy->genid);
> 
> Do we still need this since we're invalidating the whole flow
> cache?
> 
> The current code is necessary since otherwise the bundles won't
> get freed.  But with your new code, this is essentially doing
> nothing, no?

You are right. I completely missed the flushing there. It was
just systematic conversion of deleting the bundles to incrementing
the genid.

Which also makes me think of another issue. The resolver does
not get notice if the genid was outdated. So it might end up
the old policies from bundle after xfrm_policy_insert(). I think
we should explicitly call ops->delete() in flow_cache_lookup if
the flow genid was outdated. (I remember actually doing this,
but also removing it when I was hunting my the one hlist related
corruption bug.)
