From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4 net-next] net: allow skb->head to be a page fragment
Date: Sat, 28 Apr 2012 08:30:45 +0200
Message-ID: <1335594645.2900.17.camel@edumazet-glaptop>
References: <1335522818.2775.227.camel@edumazet-glaptop>
	 <4F9B3980.1080605@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:40499 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640Ab2D1Gas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 02:30:48 -0400
Received: by wejx9 with SMTP id x9so842880wej.19
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 23:30:47 -0700 (PDT)
In-Reply-To: <4F9B3980.1080605@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-27 at 17:27 -0700, Alexander Duyck wrote:

> This doesn't seem right to me.  You are only counting the piece of the
> page that got filled with data and the piece that will get overwritten
> with the shared info.  What about the rest of the page?  It looks like
> in the tg3 patch you have the driver using a half page.  Based on this
> function I suspect the resultant truesize would be something like 64 +
> 256 + 320 for an ack.  Shouldn't your truesize in that case be 2048 + 256?

Hi Alex

Not sure what you mean, since there is no such change in this patch.

driver must pass the truesize of the fragment, not the used one to
build_skb(). This is what I did in tg3 patch.

Therefore, all packets will have truesize = 2048 + 256.

The tg3 patch could be generalized to take care of special MTU, and be
able to use 1024 or 4096 as well for the frag size.

Lets discuss of the existing truesize problem.

There is one problem with fragments : We track the used length of them,
not their truesize.

So for example, GRO is not able to track resulting truesize.

We could split the "__u32 size;" to :

__u32 size:24;
__u32 truesizelog:8;

this_frag_truesize = max(1U << frag->truesizelog, frag->size);


  
