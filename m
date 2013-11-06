From: Mathias Krause <mathias.krause@secunet.com>
Subject: Re: [PATCH net-next 3/3] net: allow to leave the buffer fragmented
 in skb_cow_data()
Date: Wed, 06 Nov 2013 13:42:03 +0100
Message-ID: <527A391B.4050907@secunet.com>
References: <cover.1381923854.git.mathias.krause@secunet.com> <14f30e8f5f8405c1ca73b6d3a554441c1736142d.1381923854.git.mathias.krause@secunet.com> <20131106093028.GA18435@gondor.apana.org.au> <527A109E.5040000@secunet.com> <20131106095217.GA18851@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55629 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756521Ab3KFMmI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Nov 2013 07:42:08 -0500
In-Reply-To: <20131106095217.GA18851@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06.11.2013 10:52, Herbert Xu wrote:
> On Wed, Nov 06, 2013 at 10:49:18AM +0100, Mathias Krause wrote:
>> On 06.11.2013 10:30, Herbert Xu wrote:
>>
>>> Hang on, you haven't explained why it is OK to write to pages.
>> Why wouldn't it if the skb isn't cloned?
> 
> Because if it's owned by an entity outside our stack (e.g., virt
> host or app) then the skb itself won't be cloned.

Ok.

>>> What if said page is owned by the virt host or some app?
>> How would one detect such a case. I could image not by testing
>> skb_shinfo(skb)->nr_frags as it is right now?
> 
> You can't.  That's why we always copy.

Well, skb_cow_data() will only copy, i.e. call __pskb_pull_tail(), in
case the skb is either cloned or fragmented. As you already said it
won't be cloned in your case. Does it contain fragments, i.e. is
skb_shinfo(skb)->nr_frags != 0? If not, we won't copy with the current
code either.

We *will* copy, though, if we're expected to expand the tailroom. That
won't change in my patch as we'll linearize the skb in that case -- even
if there would enough room in the skb. That's needed to not hit the
SKB_LINEAR_ASSERT(skb) in skb_put().

> If you want to do this
> properly then we'll need to add at least a bit to indicate whether
> the page originated from within the network stack and we have
> full ownership.

Can you please explain why this would be needed? I still don't get the
reasoning behind "pages are considered not writable at the moment even
if they are anonymous".

skb_cow_data() is only used in those places:

- net/caif/cfpkt_skbuff.c
- net/ipv4/ah4.c
- net/ipv4/esp4.c
- net/ipv6/ah6.c
- net/ipv6/esp6.c
- net/rxrpc/rxkad.c

Can you explain how this change would be a problem for them?


Thanks,
Mathias
