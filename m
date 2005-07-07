From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Thu, 07 Jul 2005 14:17:18 -0700 (PDT)
Message-ID: <20050707.141718.85410359.davem@davemloft.net>
References: <42CB2698.2080904@cosmosbay.com>
	<42CB2B84.50702@cosmosbay.com>
	<20050706124206.GW16076@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch
In-Reply-To: <20050706124206.GW16076@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 6 Jul 2005 14:42:06 +0200

> The inital issue you brought up which you backed up with numbers
> is probably the cause of multiple wrong branch predictions due
> to the fact that I wrote skb = dequeue(); if (skb) which was
> assumed to be likely by the compiler. In your patch you fixed
> this with !skb_queue_empty() which fixed this wrong prediction
> and also acts as a little optimization due to skb_queue_empty()
> being really simple to implement for the compiler.

As an aside, this reminds me that as part of my quest to make
sk_buff smaller, I intend to walk across the tree and change
all tests of the form:

	if (!skb_queue_len(list))

into:

	if (skb_queue_empty(list))

It would be really nice, after the above transformation and some
others, to get rid of sk_buff_head->qlen.  Why?  Because that
also allows us to remove the skb->list member as well, as it's
the only reason for existing is so that the SKB queue removal
routines can decrement the queue length.

That's kind of silly, and most SKB lists in the kernel do not care
about the queue length at all.  Rather, they care about empty and
non-empty.  The cases that do care (mostly packet schedulers) can
keep track of the queue length themselves in their private data
structures.  When they remove packets, they _know_ which queue to
decrement the queue length of.
