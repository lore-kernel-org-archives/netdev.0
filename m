From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] crypto: aesni-intel - avoid IPsec re-ordering
Date: Thu, 20 Nov 2014 08:26:51 +0100
Message-ID: <20141120072650.GT6390@secunet.com>
References: <1415771371-30774-1-git-send-email-ming.liu@windriver.com>
 <20141112084138.GL6390@secunet.com>
 <20141115031549.GA19208@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ming Liu <ming.liu@windriver.com>, <davem@davemloft.net>,
	<ying.xue@windriver.com>, <linux-crypto@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141115031549.GA19208@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 15, 2014 at 11:15:50AM +0800, Herbert Xu wrote:
> On Wed, Nov 12, 2014 at 09:41:38AM +0100, Steffen Klassert wrote:
> >
> > Everything below the local_bh_enable() should not run in atomic context
> > as the subsequent functions may set the CRYPTO_TFM_REQ_MAY_SLEEP flag.
> 
> Actually I'm thinking of doing exactly that (disabling softirq in
> cryptd) to fix the reordering problem.
> 
> Most threads do not use the FPU/SIMD so cryptd is only ever needed
> when we have a user-space app that touches the FPU/SIMD which then
> gets an interrupt to perform crypto in softirq.  So forcing cryptd
> on everyone just because some apps touch the FPU/SIMD is a non-
> starter.
> 
> The most straightforward solution is to always defer to cryptd once
> it gets started.  This is bad because if a rarely used app that
> touches FPU/SIMD runs then we'll end up stuck in cryptd long after
> the app goes away.
> 
> So what I'm thinking of is to have the softirq path forcibly regain
> control from cryptd where possible.  This is tricky because cryptd
> might be in the middle of processing a request.  So that's why I'd
> like to disable softirqs while we're processing a request.
> 

What about to use a fallback algorithm that does not need to touch
FPU/SIMD in such cases? We would not need cryptd at all and it would
keep the requests in the right order because we don't defer them.
