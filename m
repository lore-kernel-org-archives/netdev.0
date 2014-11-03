From: David Miller <davem@davemloft.net>
Subject: Re: [0/3] net: Kill skb_copy_datagram_const_iovec
Date: Mon, 03 Nov 2014 15:05:53 -0500 (EST)
Message-ID: <20141103.150553.633529234958324183.davem@davemloft.net>
References: <20141103002207.GA26588@gondor.apana.org.au>
	<20141103004503.GX7996@ZenIV.linux.org.uk>
	<20141103053751.GA27845@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141103053751.GA27845@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 3 Nov 2014 13:37:51 +0800

> On Mon, Nov 03, 2014 at 12:45:03AM +0000, Al Viro wrote:
>>
>> Note, BTW, that there's a damn good reason to convert the socket side of
>> things to iov_iter - as it is, ->splice_write() there is basically done with
>> page-by-page mapping and doing kernel_sendmsg(); being able to deal with
>> "map and copy" stuff *inside* ->sendmsg() would not only reduce the overhead,
>> it would allow to get rid of ->sendpage() completely.  Basically, let
>> ->sendmsg() instances check the iov_iter type and play zerocopy games if
>> it's an "array of kernel pages" kind.  Compare ->sendpage() and ->sendmsg()
>> instances for the protocols that have nontrivial ->sendpage(); you'll see
>> that there's a lot of duplication.  Merging them looks very feasible, with
>> divergence happening only very deep in the call chain.
> 
> Honestly I don't really care which way we end up going as long as
> we pick one solution and stick with it.  Right now we have an
> abomination in the form of skb_copy_datagram_const_iovec which is
> the worst of both worlds, plus it duplicates tons of code.
> 
> So here's a few patches to kill this crap.

To pick one direction and go with it, I totally agree with.

But a patch set like this as an interim solution, I am not so happy
with.

If the method says const, we have a contract with the caller to not
modify the iovec.  That caller can assume that we have not done so.

So this patch set violated that contract and can result in real bugs
either now or in the future.

I'll see if I can make some progress converting the networking over
to iov_iter.  It can't be that difficult... albeit perhaps a little
time consuming.
