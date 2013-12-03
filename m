From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not
 ipsec pkt
Date: Tue, 03 Dec 2013 10:01:07 +0100
Message-ID: <529D9DD3.7000908@6wind.com>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com> <1383725153-26298-1-git-send-email-christophe.gouault@6wind.com> <20131121121246.GD31491@secunet.com> <528F6B32.5050103@6wind.com> <20131203075513.GQ31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Saurabh Mohan <saurabh.mohan@vyatta.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:36295 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998Ab3LCJBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 04:01:15 -0500
Received: by mail-ee0-f54.google.com with SMTP id e51so1245933eek.41
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 01:01:14 -0800 (PST)
In-Reply-To: <20131203075513.GQ31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen,

On 12/03/2013 08:55 AM, Steffen Klassert wrote:
> On Fri, Nov 22, 2013 at 03:33:22PM +0100, Christophe Gouault wrote:
>>
>> I had in mind to later support cross netns in vti interfaces like for
>> ipip tunnels (different netns for the decapsulated and encapsulated
>> packets). With the deferred inbound policy check, the SA and SP will not
>> be in the same netns, this will cause problems for the inbound policy check.
>>
>
> Well, I think the current vti implementation has two problems.
> The first is that the receive hook is at the wrong place. I've
> objected this already when vti was originally implemented, but
> my objections remained unheared.
> The receive hook is in the middle of the decapsulation process,
> some of the header pointers point still into the IPsec packet
> others point already into the decapsulated packet. This makes it
> very unflexible and proper namespace and interfamily support can't
> be done as it is.
>
> I think vti should register it's own receive hooks for the IPsec
> protocols, then we have the control over the decryption and
> decapsulation process.
>
> The second problem is that we missuse the gre keys to mark
> the packets. Currently, we can use only the o_key to mark
> packets because the i_key is used to do the tunnel lookup.
> But if we want to do the policy check for the decapsulated
> packet we need two keys, one to mark transmitted and one to
> mark received packets. This is because vti typically uses
> wildcard selectors, so on forwarding the output policy maches
> in both directions. This generates a loop where the IPsec
> gateways bouncing the packet back and forth until the ttl
> is exceeded.
>
> I'm currently testing a patchset that implements an IPsec
> protocol multiplexer, so that vti can register it's own
> receive path hooks. Further it makes the i_key usable
> for vti and changes the vti4 code to do the following:
> vti uses the IPsec protocol multiplexer to register it's
> own receive side hooks for ESP and AH.
>
> Vti then does the following on receive side:
>
> 1. Do an input policy check for the IPsec packet we received.
>     This is required because this packet could be already
>     processed by IPsec (tunnel in tunnel or a block policy
>     is present), so an inbound policy check is needed.
>
> 2. Clean the skb to not leak informations on namespace
>     transitions.
>
> 3. Mark the packet with the i_key. The policy and the state
>     must match this key now. Policy and state belong to the vti
>     namespace and policy enforcement is done at the further layers.
>
> 4. Call the generic xfrm layer to do decryption and decapsulation.
>
> 5. Wait for a callback from the xfrm layer to properly update
>     the device statistics.
>
> On transmit side:
>
> 1. Mark the packet with the o_key. The policy and the state
>     must match this key now.
>
> 2. Do a xfrm_lookup on the original packet with the mark applied.
>
> 3. Check if we got an IPsec route.
>
> 4. Clean the skb to not leak informations on namespace
>     transitions.
>
> 5. Attach the dst_enty we got from the xfrm_lookup to the skb.

I am just wondering when exactly the netns transition IPsec and route
lookups are performed (as far as I understand, we first need to perform
the SP+SA lookup in inner netns, then change namespaces to outer netns, 
then perform a route lookup).

But I guess the patchset will answer this question.

> 6. Call dst_output to do the IPsec processing.
>
> 7. Do the device statistics.
>
> I hope to get a RFC version of this patchset ready by the
> end of the week.

This patchset sounds really promising. I am eagerly waiting for it.

Best Regards,
Christophe
