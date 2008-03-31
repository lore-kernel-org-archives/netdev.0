From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of
	netif_rx()
Date: Mon, 31 Mar 2008 12:12:37 +0200
Message-ID: <20080331101237.GA12324@elte.hu>
References: <47BDC848.50607@cosmosbay.com> <20080226.182120.183405235.davem@davemloft.net> <47C92F49.4070100@cosmosbay.com> <20080323.032949.194309002.davem@davemloft.net> <47E6A5FD.6060407@cosmosbay.com> <20080331094823.GA11651@elte.hu> <47F0B66C.6080404@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757201AbYCaKNH@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47F0B66C.6080404@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Eric Dumazet <dada1@cosmosbay.com> wrote:

> Problem is to check available space :
>
> It depends on stack growing UP or DOWN, and depends on caller running 
> on process stack, or softirq stack, or even hardirq stack.

ok - i wish such threads were on lkml so that everyone not just the 
netdev kabal can read it. It's quite ugly, but if we want to check stack 
free space i'd suggest for you to put a stack_can_recurse() call into 
arch/x86/kernel/process.c and offer a default __weak implementation in 
kernel/fork.c that always returns 0.

the rule on x86 should be something like this: on 4K stacks and 64-bit 
[which have irqstacks] free stack space can go as low as 25%. On 8K 
stacks [which doesnt have irqstacks but nests irqs] it should not go 
below 50% before falling back to the explicitly queued packet branch.

this way other pieces of kernel code code can choose between on-stack 
fast recursion and explicit iterators. Although i'm not sure i like the 
whole concept to begin with ...

	Ingo
