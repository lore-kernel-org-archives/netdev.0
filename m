From: Ming Liu <ming.liu@windriver.com>
Subject: Re: [PATCH] crypto: aesni-intel - avoid IPsec re-ordering
Date: Wed, 12 Nov 2014 18:41:30 +0800
Message-ID: <5463395A.5040200@windriver.com>
References: <1415771371-30774-1-git-send-email-ming.liu@windriver.com> <20141112084138.GL6390@secunet.com> <20141112085148.GA26268@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<davem@davemloft.net>, <ying.xue@windriver.com>,
	<linux-crypto@vger.kernel.org>, <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20141112085148.GA26268@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/12/2014 04:51 PM, Herbert Xu wrote:
> On Wed, Nov 12, 2014 at 09:41:38AM +0100, Steffen Klassert wrote:
>> Can't we just use cryptd unconditionally to fix this reordering problem?
> I think the idea is that most of the time cryptd isn't required
> so we want to stick with direct processing to lower latency.
>
> I think the simplest fix would be to punt to cryptd as long as
> there are cryptd requests queued.
I've tried that method when I started to think about the fix, but it 
will cause 2 other issues per test while resolving the reordering one, 
as follows:
1 The work queue can not handle so many packets when the traffic is very 
high(over 200M/S), and it would drop most of them when the queue length 
is beyond CRYPTD_MAX_CPU_QLEN.
2 Soft lockups are observed, per my analysis, the cause is: in some 
extreme cases, all packets would be sent to the cryptd once there are 
requests already in it, this will let the net poll functions return 
pretty fast, and lead too many hw interrupts triggered in a certain period.

//Ming Liu
>
> Cheers,
