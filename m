From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Wed, 6 Jul 2005 14:42:06 +0200
Message-ID: <20050706124206.GW16076@postel.suug.ch>
References: <20050705173411.GK16076@postel.suug.ch> <20050705.142210.14973612.davem@davemloft.net> <20050705213355.GM16076@postel.suug.ch> <20050705.143548.28788459.davem@davemloft.net> <42CB14B2.5090601@cosmosbay.com> <20050705234104.GR16076@postel.suug.ch> <42CB2698.2080904@cosmosbay.com> <42CB2B84.50702@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <42CB2B84.50702@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Eric Dumazet <42CB2B84.50702@cosmosbay.com> 2005-07-06 02:53

A short recap after some coffee and sleep:

The inital issue you brought up which you backed up with numbers
is probably the cause of multiple wrong branch predictions due
to the fact that I wrote skb = dequeue(); if (skb) which was
assumed to be likely by the compiler. In your patch you fixed
this with !skb_queue_empty() which fixed this wrong prediction
and also acts as a little optimization due to skb_queue_empty()
being really simple to implement for the compiler. The patch
I posted should result in almost the same result, despite of
the additional wrong branch prediction for the loop it always
has one wrong prediction which is when we hit a non-empty queue.
In your unrolled version you could optimize it even more by
taking advantage that prio=2 is the most likely non-empty queue
so you could change the check to likely and save a wrong branch
prediction for the common case at the cost of a branch misprediction
if all queues are empty.

The patch I posted results in something like this:

pfifo_fast_dequeue:
	pushl	%ebx
	xorl	%ecx, %ecx
	movl	8(%esp), %ebx
	leal	128(%ebx), %edx
.L129:
	movl	(%edx), %eax
	cmpl	%edx, %eax
	jne	.L132		; if (!skb_queue_empty())
	incl	%ecx
	addl	$20, %edx
	cmpl	$2, %ecx
	jle	.L129		; end of loop
	xorl	%eax, %eax	; all queues empty
.L117:
	popl	%ebx
	ret

I regard the miss here as acceptable for the increased flexibility
we get. It can be optimized with a loop unrolling but my opinion
is to try and avoid it if possible.

Now your second thought is quite interesting, although it heavly
depends on the fact that prio=2 is the most often used band. It
will be interesting to see some numbers.

> static struct sk_buff *
> pfifo_fast_dequeue(struct Qdisc* qdisc)
> {
>         struct sk_buff_head *list = qdisc_priv(qdisc);
>         struct sk_buff_head *best = NULL;
> 
> 	list += 2;
>         if (!skb_queue_empty(list))
>                 best = list;
>         list--;
>         if (!skb_queue_empty(list))
>                 best = list;
>         list--;
>         if (!skb_queue_empty(list))
>                 best = list;

Here is what I mean, a likely() should be even better.

>         if (best) {
>                 qdisc->q.qlen--;
>                 return __skb_dequeue(best);
>                 }
>         return NULL;
> }
