From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/10] [NET]: Avoid unnecessary cloning for ingress	filtering
Date: Mon, 15 Oct 2007 16:28:44 +0200
Message-ID: <4713791C.10903@trash.net>
References: <20071014042604.GA11431@gondor.apana.org.au>	 <E1Igv4p-00030c-00@gondolin.me.apana.org.au>	 <1192358991.4892.23.camel@localhost> <1192456665.4336.57.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46839 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752303AbXJOO2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 10:28:50 -0400
In-Reply-To: <1192456665.4336.57.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> Also, iirc this started as a netfilter optimization thing starting with
> tail-calls - can someone (Patrick?) clue me how it helps in that
> optimization aspect? 


Most NF_HOOK invocations look like this:

return NF_HOOK(....);

NF_HOOK does (did):

({int __ret; \
if ((__ret=nf_hook_thresh(pf, hook, &(skb), indev, outdev, okfn, \
			  thresh, 1)) == 1) \
         __ret = (okfn)(skb); \
__ret;})

So the (okfn) invocation would allow a tail-call optimization, but gcc
doesn't do them in case the address of a local variable or parameter
is passed to an external function previously (&skb). With Herbert
patches we avoid this and gcc can generate optimized tail calls.
This in turn allows to remove the inline from the okfns without any
additional function call overhead, which avoids having two copies
of the same function in the CONFIG_NETFILTER=y case (one inlined,
one out-of-line so the address can be passed to nf_hook_slow()).
Removing just 4 inlines in net/ipv4 saved 3376 bytes of text with
CONFIG_NETFILTER=y on x86_64.

Besides that it generates better code in all netfilter code since
we don't have to constantly dereference **pskb. As a simple example
the xt_MARK target_v1() function shrinks by an entire 17 byte (or 16%)
because of this change :)


