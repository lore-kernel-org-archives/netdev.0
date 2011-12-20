From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Tue, 20 Dec 2011 08:53:09 +0200
Message-ID: <4EF030D5.6040603@iki.fi>
References: <20111214.125010.82857701285437834.davem@davemloft.net> <20111215134957.GI6348@secunet.com> <20111216122147.GJ6348@secunet.com> <20111219.161053.148816799233666803.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:58527 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751520Ab1LTGxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 01:53:18 -0500
Received: by lahd3 with SMTP id d3so71216lah.19
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 22:53:16 -0800 (PST)
In-Reply-To: <20111219.161053.148816799233666803.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2011 11:10 PM, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Fri, 16 Dec 2011 13:21:47 +0100
> 
>> Subject: [PATCH] route: Initialize with the fib_metrics in the non default case
>>
>> We initialize the routing metrics with the cached values in
>> rt_init_metrics(). So if we have the metrics cached on the
>> inetpeer, we ignore the user configured fib_metrics. So
>> initialize the routing metrics with the fib_metrics if they
>> are different from dst_default_metrics.
>>
>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> The current behavior is intentional.
> 
> Learned metrics should be used on all routes for which a inetpeer
> peer exists and the destination matches.
> 
> There is no sane way to allow overrides.
> 
> I'm pretty sure all of Timo's bugs will be fixed when you add the
> generation count for PMTU stuff.

I tried to look at the code to see how the fib MTU is handled, but I
don't think just generation count for PMTU would solve it.

My problem is that after inetpeer is created, the fib mtu is never
looked again at. The code that updates it, is in rt_init_metrics():
                if (inet_metrics_new(peer))
                        memcpy(peer->metrics, fi->fib_metrics,
                               sizeof(u32) * RTAX_MAX);

Since the inetpeer there never gets recycled (peer lookup does not look
at generation count), the metrics are initialised from the fib exactly
once: when the inetpeer is initially created.

Now, if I have running system, there's traffic to specific inetpeer, and
later I add a system wide override route with mtu to that destination,
the updated mtu is never honoured. Because it comes from fib, and not
via the pmtu mechanism.

Or maybe I missed the place where that updated would happen?

It seems that the inetpeer.c comment that " The (inetpeer) nodes
contains long-living information about the peer which doesn't depend on
routes." does not hold true any more. Since mtu is (or at least used to
be) a route dependant value.

Perhaps we could then at least check the fib MTU and update inetpeer if
it's lower than what inetpeer used to be. This means of course that if
there's various routes to same destination (e.g. due to policy routing)
with different MTUs, only the smallest one would get used system wide.
But at least the route specific MTU would work then.

This is basically a problem for me, as I have userland code adding
dynamically per-destination mtu routes to workaround black hole ISP routers.

- Timo
