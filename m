From: Martin Willi <martin@strongswan.org>
Subject: Re: [PATCH] xfrm: Accept ESP packets regardless of UDP   encapsulation mode
Date: Thu, 18 Dec 2008 13:36:56 +0100
Message-ID: <1229603816.10402.178.camel@martin>
References: <E1LDGgX-0007JE-T9@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.km23152-01.keymachine.de ([87.118.114.125]:52395 "EHLO
	km23152-01.keymachine.de" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753786AbYLRMhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 07:37:25 -0500
Received: from localhost (km23152-01.keymachine.de [127.0.0.1])
	by km23152-01.keymachine.de (Postfix) with SMTP id 82FAE30A8010
	for <netdev@vger.kernel.org>; Thu, 18 Dec 2008 13:37:02 +0100 (CET)
In-Reply-To: <E1LDGgX-0007JE-T9@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> IKE or IKEv2 is supposed to negotiate UDP encapsulation
> explicitly.  So either we did negotiate to use UDP encapsulation,
> and Strongswan ignored it (it's buggy), or we didn't and the peer
> still chose to use it (the peer is buggy).

This is just not true. UDP encapsulation is never negotiated explicitly
in IKEv2. It is enabled if the peer thinks it is might help, for example
if it detects a NAT situation. There is no way to say "use UDP
encapsulation".

> More importantly, you've failed to demonstrate why you need this
> in the first place.  None of the URLs you've quoted tells us that
> the kernel needs to handle an SA switching between with encap and
> without encap without the key manager telling it to do so.

The local key manager does not know whether the peer enables UDP
encapsulation, it can't. Most likely it will in NAT situations, but it
might do so even if there is no NAT detected. And this is not a bug, it
is allowed to do so by the protocol.

> In either case it's a serious bug in the key manager.  I don't see
> why we should work around such brokenness in the kernel.

>From the key manager perspective, I can enable or disable UDP
encapsulation, fine. I decide locally what I'll use for outgoing
packets. But how should I know what the peer uses? I can't, it isn't
negotiated. It is, by the standard, perfectly valid to send UDP
encapsulated packets if the peer wants to do so. And there is no need to
communicate this to the key manager, there is actually no such mechanism
in IKEv2. Therefore I need the kernel to accept packet, encapsulated or
not.

> For a start, you've introduced a bug in the ESP code as it may try
> access a non-existant UDP header and then interpret that as an
> address change which will generate bogus events to your daemon.

I agree, I've missed that (because "my" daemon uses Netlink and the
km_new_mapping event was not implemented until recently).

But this is no valid reason to drop that approach in general, it is a
side effect introduced by my specific patch. This can be fixed.

Martin


