From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Wed, 26 May 2010 00:06:35 -0700
Message-ID: <AANLkTinHGMtfw4Oydfgx0w7QLb-HyYSKdI-4smD-BEkq@mail.gmail.com>
References: <alpine.DEB.1.00.1005252157150.27170@pokey.mtv.corp.google.com>
	<20100525220858.1071f238@nehalam>
	<20100525.225236.226781050.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:25652 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196Ab0EZHGk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 03:06:40 -0400
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o4Q76btO027420
	for <netdev@vger.kernel.org>; Wed, 26 May 2010 00:06:38 -0700
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by kpbe11.cbf.corp.google.com with ESMTP id o4Q76aWf006048
	for <netdev@vger.kernel.org>; Wed, 26 May 2010 00:06:36 -0700
Received: by pxi10 with SMTP id 10so3671204pxi.35
        for <netdev@vger.kernel.org>; Wed, 26 May 2010 00:06:36 -0700 (PDT)
In-Reply-To: <20100525.225236.226781050.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 25, 2010 at 10:52 PM, David Miller <davem@davemloft.net> wr=
ote:
>
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 25 May 2010 22:08:58 -0700
>
> > The IETF TCP maintainers already think Linux TCP allows unsafe
> > operation, this will just allow more possible misuse and prove
> > their argument. =A0Until/unless this behavior was approved by
> > a wider set of research, I don't think it should be accepted at
> > this time.
>
> Yes, and two other points I'd like to add.
>
> 1) Stop pretending a network path characteristic can be made into
> =A0 an application level one, else I'll stop reading your patches.
>
> =A0 You can try to use smoke and mirrors to make your justification b=
y
> =A0 saying that an application can circumvent things right now by
> =A0 openning up multiple connections. =A0But guess what? =A0If that a=
ct
> =A0 overflows a network queue, we'll pull the CWND back on all of tho=
se
> =A0 connections while their CWNDs are still small and therefore way
> =A0 before things get out of hand.
>
It's really not that simple.=A0 In the application with multiple
connections, congestion may only affect some number of connections, so
more of the aggregate window may be preserved.=A0 This is an unfairness
issue between 1 and N connection scenarios which is a real problem.

>
> =A0 Whereas if you set the initial window high, the CWND is wildly ou=
t
> =A0 of control before we are even started.
>
> =A0 And even after your patch the "abuse" ability is still there. =A0=
So
> =A0 since your patch doesn't prevent the "abuse", you really don't ca=
re
> =A0 about CWND abuse. =A0Instead, you simply want to pimp your featur=
e.
>
> 2) The very last application I'd want to use something like this is a
> =A0 damn web browser.
>

Right, this should be fixed in the server not at the browsers.
Unfortunately, web browsers seem to have lost any self control in
limiting the number of simultaneous connections that can be opened (we
managed to get IE8 to open over 100 of them).=A0 So the cat's way out o=
f
the bag.=A0 Server's can rein this problem in by only allowing fewer
connections, but at the cost of losing latency is not much incentive!

> =A0 Maybe a program, which is extremely sophisticated, like a databas=
e
> =A0 or caching manager, that runs privileged and somehow has complete
> =A0 and constantly updated knowledge of the network topology from end
> =A0 to end. =A0And iff, and only iff, we only would let privileged
> =A0 applications make the setting.
>
> Right now we only allow to do this via a route setting, exactly becau=
se:
>
> 1) It is a network path characteristic, full stop.
>
Thanks to NAT, the concept of a network path or even host specific
path is a weakened concept.=A0 On the Internet this may be a path
characteristic per client, which unfortunately has no visibility in
the kernel other than per connection state.=A0 When a single IP address
may have thousands of hosts behind it, caching TCP parameters for that
IP address is implicitly doing a huge aggregation-- probably dicey...

>
> 2) Only humans can really know what the exact end to end path
> =A0 characteristics are on a per-route basis, and given that whether =
it
> =A0 is safe to increase the initial CWND as a result.

In all but the most trivial networks, I do not believes humans are
capable of making an intelligent decision about this.=A0 Don't get me
wrong, it's great that it can be set in the route, but there's nothing
at all that prevents naive abuse (2009 study showed that 15%
connections of connections on the Internet violate icw standards
anyway).=A0 We have proposed in iETF to raise the initial congestion
window, but dynamic mechanisms that algorithmically determine safe
values are still of interest and may be safer which is what this patch
would allow.

Thanks for your comments!
