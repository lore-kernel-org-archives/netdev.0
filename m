From: Tom Herbert <therbert@google.com>
Subject: Re: Get rxhash fixes and RFS support in tun
Date: Thu, 21 Nov 2013 08:28:18 -0800
Message-ID: <CA+mtBx_KuiC2KWXKuV-+KBrJ7GhMK0L5kAH8sO7CA3sQqGp+Cg@mail.gmail.com>
References: <CA+mtBx91hSmYKrbUsPrtnXRjYR8QDGZ+GAAnMixauUqw9LFkiQ@mail.gmail.com>
	<20131120.212321.700376819925646003.davem@davemloft.net>
	<CA+mtBx8g9uYOc0euQiEDi8qfx_ZggsE_Wn8N5R+peE1_N4WKEg@mail.gmail.com>
	<20131120.215025.590189385589840672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jerry Chu <hkchu@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:49076 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753813Ab3KUQ2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 11:28:19 -0500
Received: by mail-ie0-f170.google.com with SMTP id qd12so7364143ieb.15
        for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 08:28:19 -0800 (PST)
In-Reply-To: <20131120.215025.590189385589840672.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 20, 2013 at 6:50 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Wed, 20 Nov 2013 18:42:48 -0800
>
>> We need the rxhash to be the value seen at the point of RPS (to do RFS
>> correctly), which I think probably means we don't ever want to change
>> it after the first calculation! (clearing at tunnel decap wouldn't be
>> correct either)  For ESP or AH, I believe it's appropriate to use SPI
>> as a substitute for ports.
>
> But that means that all connections going over the same IPSEC path
> hash to the same value.
>
> I really think that xfrm_input() should zap the rxhash near the
> existing nf_reset() call.
>
> The same argument goes for tunnels, that is why ip_tunnel_core.c does
> what it does with the rxhash clearing right now.
>
I suspect this is not the right thing to do any more.  Since we're
doing deep inspection now in flow_dissector, we should already have
the discovered the hash on the inner header if it's a standard encap.
In order to do RFS for tunneled packets at the NIC interface we don't
want recompute to a different L4 hash (which would be common case if
NIC did deep inspection on tunneled packets and we clear hash at
decap).

> In both the IPSEC tunnel (not transport) and normal IP/GRE tunnel
> cases, it's a completely new SKB receive, done via netif_rx(), after
> decapsulation.
>
> That leaves only IPSEC transport mode as the only case where RFS isn't
> (re-)performed but we can build infrastructure to make that happen.
