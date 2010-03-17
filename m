From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Wed, 17 Mar 2010 16:16:21 +0200
Message-ID: <4BA0E435.6090801@iki.fi>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100317130704.GA2601@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f209.google.com ([209.85.219.209]:50461 "EHLO
	mail-ew0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064Ab0CQOWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 10:22:17 -0400
Received: by ewy1 with SMTP id 1so449776ewy.38
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 07:22:15 -0700 (PDT)
In-Reply-To: <20100317130704.GA2601@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Mar 15, 2010 at 02:20:10PM +0200, Timo Teras wrote:
>> Instead of doing O(n) xfrm_find_bundle() call per-packet, cache
>> the previous lookup results in flow cache. The flow cache is
>> updated to be per-netns and more generic.
> 
> This only works well if the traffic doesn't switch bundles much.
> But if that were the case then the number of bundles is likely
> to be small anyway.

The problem is if I have multipoint gre1 and policy that says
"encrypt all gre in transport mode".

Thus for each public address, I get one bundle. But the
xfrm_lookup() is called for each packet because ipgre_tunnel_xmit()
calls ip_route_output_key() on per-packet basis.

For my use-case it makes a huge difference.

> IOW I think if we're doing this then we should go the whole
> distance and directly cache bundles instead of policies in the
> flow cache.

Then we cannot maintain policy use time. But if it's not a
requirement, we could drop the policy from cache.

Also. With this and your recent flowi patch, I'm seeing pmtu
issues. Seems like xfrm_bundle_ok uses the original dst which
resulted in the creation of the bundle. Somehow that dst
does not get updated with pmtu... but the new dst used in
next xfrm_lookup for same target does have proper mtu.
I'm debugging right now why this is happening. Any ideas?

- Timo
