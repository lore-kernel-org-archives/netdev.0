From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sun, 04 Apr 2010 13:50:16 +0300
Message-ID: <4BB86EE8.5090203@iki.fi>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi> <1270126340-30181-2-git-send-email-timo.teras@iki.fi> <20100404104230.GA10368@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:50307 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753364Ab0DDKuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 06:50:21 -0400
Received: by ewy20 with SMTP id 20so866520ewy.1
        for <netdev@vger.kernel.org>; Sun, 04 Apr 2010 03:50:18 -0700 (PDT)
In-Reply-To: <20100404104230.GA10368@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Apr 01, 2010 at 03:52:17PM +0300, Timo Teras wrote:
>> -extern void *flow_cache_lookup(struct net *net, struct flowi *key, u16 family,
>> -			       u8 dir, flow_resolve_t resolver);
>> +struct flow_cache_entry_ops {
>> +	struct flow_cache_entry_ops ** (*get)(struct flow_cache_entry_ops **);
>> +	int (*check)(struct flow_cache_entry_ops **);
>> +	void (*delete)(struct flow_cache_entry_ops **);
>> +};
>> +
>> +typedef struct flow_cache_entry_ops **(*flow_resolve_t)(
>> +		struct net *net, struct flowi *key, u16 family,
>> +		u8 dir, struct flow_cache_entry_ops **old_ops, void *ctx);
> 
> OK this bit really bugs me.
> 
> When I first looked at it, my reaction was why on earth are we
> returning an ops pointer? Only after some digging around do I see
> the fact that this ops pointer is in fact embedded in xfrm_policy.
> 
> How about embedding flow_cache_entry in xfrm_policy instead? Returning
> flow_cache_entry * would make a lot more sense than a nested pointer
> to flow_cache_entry_ops.

Because flow_cache_entry is per-cpu, and multiple entries (due to
different flows matching same policies, or same flow having multiple
per-cpu entries) can point to same policy. If we cached "dummy" objects
for even policies, then this would be better approach.

This would make actually sense, since it'd be useful to cache all
policies involved in check path (main + sub policy refs). In which
case we might want to make the ops 'per flow cache instance' instead
of 'per cache entry'.
