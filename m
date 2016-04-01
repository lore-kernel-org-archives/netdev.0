From: Ben Greear <greearb@candelatech.com>
Subject: Re: Question on rhashtable in worst-case scenario.
Date: Fri, 1 Apr 2016 11:17:26 -0700
Message-ID: <56FEBB36.4020606@candelatech.com>
References: <56F9941A.3080501@candelatech.com>
 <56FAAA6D.3070806@candelatech.com> <1459329252.2055.1.camel@sipsolutions.net>
 <20160330.123821.328761526754742195.davem@davemloft.net>
 <56FC0445.6010200@candelatech.com> <1459410405.4576.8.camel@sipsolutions.net>
 <20160331075015.GA27716@gondor.apana.org.au>
 <1459438199.4576.26.camel@sipsolutions.net>
 <20160401004627.GA9367@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	tgraf@suug.ch
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:44102 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124AbcDASR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 14:17:28 -0400
In-Reply-To: <20160401004627.GA9367@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/31/2016 05:46 PM, Herbert Xu wrote:
> On Thu, Mar 31, 2016 at 05:29:59PM +0200, Johannes Berg wrote:
>>
>> Does removing this completely disable the "-EEXIST" error? I can't say
>> I fully understand the elasticity stuff in __rhashtable_insert_fast().
>
> What EEXIST error are you talking about? The only one that can be
> returned on insertion is if you're explicitly checking for dups
> which clearly can't be the case for you.
>
> If you're talking about the EEXIST error due to a rehash then it is
> completely hidden from you by rhashtable_insert_rehash.
>
> If you actually meant EBUSY then yes this should prevent it from
> occurring, unless your chain-length exceeds 2^32.

EEXIST was on removal, and was a symptom of the failure to insert, not
really a problem itself.

I reverted my revert (ie, back to rhashtable), added Johanne's patch
to check insertion (and added my on pr_err there).

I also added this:

diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 38ef0be..c25b945 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -66,6 +66,7 @@

  static const struct rhashtable_params sta_rht_params = {
         .nelem_hint = 3, /* start small */
+       .insecure_elasticity = true, /* Disable chain-length checks. */
         .automatic_shrinking = true,
         .head_offset = offsetof(struct sta_info, hash_node),
         .key_offset = offsetof(struct sta_info, addr),


Now, my test case seems to pass, though I did have one strange issue
before I put in the pr_err.  I'm not sure if it was a hashtable issue
or something else..but I have lots of something-else going on in this system,
so I'd say that likely the patch above fixes rhashtable for my use case.

I will of course let you know if I run into more issues that appear
to be hashtable related!

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
