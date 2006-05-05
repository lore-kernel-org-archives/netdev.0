From: Andi Kleen <ak@suse.de>
Subject: Re: [x86_64, NET] smp_rmb() in dst_destroy() seems very expensive, ditto in kfree_skb()
Date: Fri, 5 May 2006 19:05:30 +0200
Message-ID: <200605051905.31130.ak@suse.de>
References: <E1FbSM8-0002lx-00@gondolin.me.apana.org.au> <20060504.162546.88959729.davem@davemloft.net> <445B11A3.1020407@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:3469 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1751664AbWEER3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 13:29:38 -0400
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <445B11A3.1020407@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 05 May 2006 10:49, Eric Dumazet wrote:
> On a dual opteron box, I noticed high oprofile numbers in net/core/dst.c 
> , function dst_destroy(struct dst_entry * dst)
> 
> It appears the smb_rmb() done at the begining of  dst_destroy() is the 
> killer  (this is a lfence machine instruction, that apparently is doing 
> a *lot* of things... may be IO related...) that is responsible for 80% 
> of the cpu time used by the whole function.
> 
> I dont understand very much all variety of available barriers, and why 
> this smb_rmb() is used in dst_destroy().
> I missed the corresponding wmb that should be done somewhere in the dst 
> code.
> 
> Do we have an alternative to smp_rmb() in the dst_destroy()/ kfree_skb() 
> context ?

Eliminating it probably wouldn't help very much - it just flushes the 
loads already in flight. If it didn't do that the next smp_rmb() would.
I'm surprised there are that many though. Normally kernel code is spagetti
enough that the CPU cannot speculate too many loads ahead.

But are you 100% sure the cost is not in the lock decl ? That would make
more sense. Perhaps profile for cache misses too and double check?

-Andi
