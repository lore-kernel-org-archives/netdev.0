From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sat, 03 Apr 2010 23:19:04 +0300
Message-ID: <4BB7A2B8.4040405@iki.fi>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi> <1270126340-30181-2-git-send-email-timo.teras@iki.fi> <20100403033857.GA2205@gondor.apana.org.au> <20100403083609.GA3654@gondor.apana.org.au> <4BB74790.7070109@iki.fi> <20100403141709.GA5165@gondor.apana.org.au> <4BB74FF8.2020303@iki.fi> <20100403155353.GA5618@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:55441 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755900Ab0DCUTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Apr 2010 16:19:09 -0400
Received: by ewy20 with SMTP id 20so805473ewy.1
        for <netdev@vger.kernel.org>; Sat, 03 Apr 2010 13:19:08 -0700 (PDT)
In-Reply-To: <20100403155353.GA5618@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sat, Apr 03, 2010 at 05:26:00PM +0300, Timo Ter=E4s wrote:
>> Why would this block? The device down hook calls flow cache
>> flush. On flush all bundles with non-up devices get pruned
>> immediately (via stale_bundle check).
>=20
> Perhaps I missed something in your patch, but the flush that
> we currently perform is limited to the bundles from hashed policies.
> So if a policy has just recently been removed, then its bundles
> won't be flushed.

If a policy is removed, policy->genid is incremented invalidating
the bundles. Those bundles get freed when:
 - specific flow gets hit
 - cache is flushed due to GC call, or interface going down
 - flow cache randomization

If someone is then removing a net driver, we still execute
flush on the 'device down' hook, and all stale bundles
get flushed.

But yes, this means that xfrm_policy struct can now be held
allocated up to ten extra minutes. But it's only memory that
it's holding, not any extra refs. And it's still reclaimable
by the GC.

If this feels troublesome, we could add asynchronous flush
request that would be called on policy removal. Or even stick
to the synchronous one.
