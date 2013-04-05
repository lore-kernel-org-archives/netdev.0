From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [RFC PATCH ipsec] xfrm: use the right dev to fill xdst
Date: Fri, 5 Apr 2013 15:59:59 +0300
Message-ID: <CAEnQRZDUjaL56AggThN50sYJpA8diQdQ85D4xCqpwtv8PbR7mg@mail.gmail.com>
References: <1365088362-4318-1-git-send-email-nicolas.dichtel@6wind.com>
	<20130405094629.GV21448@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:56364 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161627Ab3DENAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 09:00:01 -0400
Received: by mail-wg0-f50.google.com with SMTP id k13so3829203wgh.29
        for <netdev@vger.kernel.org>; Fri, 05 Apr 2013 06:00:00 -0700 (PDT)
In-Reply-To: <20130405094629.GV21448@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 5, 2013 at 12:46 PM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Thu, Apr 04, 2013 at 05:12:42PM +0200, Nicolas Dichtel wrote:
>> Commit bc8e4b954e46 (xfrm6: ensure to use the same dev when building a bundle)
>> broke IPsec for IPv4 over IPv6 tunnels (because dev points to an IPv4 only
>> interface, hence in6_dev_get(dev) returns NULL.
>
> Can you give some informations on how to reproduce this? I'm running
> interfamily tunnels on our testing environment and it seems to
> work fine.

I can hit this in our setup while using some internal custom simulated
interfaces.

Anyhow, this should be reproducible with a classic IPv6 IPsec over
IPv4 test.  Please make sure
that the IPv4 interface doesn't have an IPv6 address set up.

Quoting from commit bc8e4b954e46 (xfrm6: ensure to use the same dev
when building a bundle):

-       xdst->u.rt6.rt6i_idev = in6_dev_get(rt->u.dst.dev);
+       xdst->u.rt6.rt6i_idev = in6_dev_get(dev);

dev points to IPv4 endpoint and if it doesn't have an IPv6 address
associated then
in6_dev_get(dev) will return NULL.

>
>>
>> After looking again into commit 25ee3286dcbc ([IPSEC]: Merge common code into
>> xfrm_bundle_create), it seems that previously we were using dev from the route,
>> for both IPv4 and IPv6.
>
> I think this was the right way. We need to attach the dev from the
> corresponding route to the xdst.
>
>>
>> In fact, xfrm_fill_dst() is called during a loop on chained dst, but dev points
>> always to the same device.
>
> The way we do it now can be problematic for tunnel in tunnel scenarios too.
> We assign the dev from the first tunnel route to all the bundle entries,
> this looks really wrong.
>
> I think your patch is correct, but I want understand the breaking
> scenario first.

thanks,
Daniel.
