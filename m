From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: Fix tcp_v6_send_response checksum
Date: Wed, 21 Apr 2010 14:28:41 -0700 (PDT)
Message-ID: <20100421.142841.191672280.davem@davemloft.net>
References: <20100421.004922.193694715.davem@davemloft.net>
	<20100421.015823.266647388.davem@davemloft.net>
	<20100421130920.GA31300@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cratiu@ixiacom.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48717
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755232Ab0DUV2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 17:28:37 -0400
In-Reply-To: <20100421130920.GA31300@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 21 Apr 2010 21:09:20 +0800

> On Wed, Apr 21, 2010 at 01:58:23AM -0700, David Miller wrote:
>> 
>> If we're going to use CHECKSUM_PARTIAL for these things (which we are
>> since commit 2e8e18ef52e7dd1af0a3bd1f7d990a1d0b249586 "tcp: Set
>> CHECKSUM_UNNECESSARY in tcp_init_nondata_skb"), we can't be setting
>> buff->csum as we always have been here in tcp_v6_send_response.  We
>> need to leave it at zero.
>> 
>> Kill that line and checksums are good again.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> That line is needed for the CHECKSUM_NONE case.  In fact, if we're
> in the CHECKSUM_PARTIAL case, then that buff->csum calculation
> should be a noop because it immediately gets overwritten when we
> subsequently set csum_start/csum_offset.

Ok, but the checksums were broken.  Can you see why?

I think we changed semantics here when we did this:

-	t1->check = csum_ipv6_magic(&fl.fl6_src, &fl.fl6_dst,
-				    tot_len, IPPROTO_TCP,
-				    buff->csum);
+	__tcp_v6_send_check(buff, &fl.fl6_src, &fl.fl6_dst);

which changes what ->csum needs to be.  It used to need to be computed
over the header as well as any data afterwards, but now it has to
cover only data.  Because now it evaluates to:

		th->check = tcp_v6_check(skb->len, saddr, daddr,
					 csum_partial(th, th->doff << 2,
						      skb->csum));

See?  We were computing the checksum over the TCP header twice now :-)
That's why my patch fixed things for dataless packets, whose
->csum would evaluate to zero.

So to make things work fully as-is, we would need to compute ->csum
over the post-header data only.

But an even easier change is to just be consistent with the rest
of the TCP packet generation code and use CHECKSUM_PARTIAL here.
And that's how I'll fix this.

What confused me here last night is the fact that CHECKSUM_NONE
is zero and the implicit zero initialization of new SKBs givs us
that :-)

Anyways, thanks for pointing this out!
