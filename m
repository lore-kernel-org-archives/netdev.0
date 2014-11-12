From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] crypto: aesni-intel - avoid IPsec re-ordering
Date: Wed, 12 Nov 2014 12:43:16 +0100
Message-ID: <20141112114316.GN6390@secunet.com>
References: <1415771371-30774-1-git-send-email-ming.liu@windriver.com>
 <20141112084138.GL6390@secunet.com>
 <20141112085148.GA26268@gondor.apana.org.au>
 <5463395A.5040200@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<ying.xue@windriver.com>, <linux-crypto@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Ming Liu <ming.liu@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35923 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753098AbaKLLn2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2014 06:43:28 -0500
Content-Disposition: inline
In-Reply-To: <5463395A.5040200@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 12, 2014 at 06:41:30PM +0800, Ming Liu wrote:
> On 11/12/2014 04:51 PM, Herbert Xu wrote:
> >On Wed, Nov 12, 2014 at 09:41:38AM +0100, Steffen Klassert wrote:
> >>Can't we just use cryptd unconditionally to fix this reordering problem?
> >I think the idea is that most of the time cryptd isn't required
> >so we want to stick with direct processing to lower latency.
> >
> >I think the simplest fix would be to punt to cryptd as long as
> >there are cryptd requests queued.
> I've tried that method when I started to think about the fix, but it
> will cause 2 other issues per test while resolving the reordering
> one, as follows:
> 1 The work queue can not handle so many packets when the traffic is
> very high(over 200M/S), and it would drop most of them when the
> queue length is beyond CRYPTD_MAX_CPU_QLEN.

That's why I've proposed to adjust CRYPTD_MAX_CPU_QLEN in my other mail.
But anyway, it still does not fix the reorder problem completely.
We still have a problem if subsequent algorithms run asynchronously
or if we get interrupted while we are processing the last request
from the queue.

I think we have only two options, either processing all calls
directly or use cryptd unconditionally. Mixing direct and
asynchronous calls will lead to problems.

If we don't want to use cryptd unconditionally, we could use
direct calls for all requests. If the fpu is not usable, we
maybe could fallback to an algorithm that does not need the
fpu, such as aes-generic.
