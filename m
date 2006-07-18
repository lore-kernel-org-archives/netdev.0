From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Wed, 19 Jul 2006 03:01:21 +0400
Message-ID: <20060718230121.GA31474@ms2.inr.ac.ru>
References: <20060718081625.GA13830@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:56534 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932411AbWGRXBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 19:01:32 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060718081625.GA13830@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

Can I ask couple of questions? Just as a person who looked at VJ's
slides once and was confused. And startled, when found that it is not
considered as another joke of genuis. :-)


About locks:

> 	  is completely lockless (there is one irq lock when skb 
> is queued/dequeued into netchannels queue in hard/soft irq, 

Equivalent of socket spinlock.


> one mutex for netchannel's bucket 

Equivalent of socket user lock.


> and some locks on qdisk/NIC driver layer,

The same as in traditional code, right?


>From all that I see, this "completely lockless code" has not less locks
than traditional approach, even when doing no protocol processing.
Where am I wrong? Frankly speaking, when talking about locks,
I do not see anything, which could be saved, only TCP hash table
lookup can be RCUized, but this optimization obviously has nothing to do
with netchannels.

The only improvement in this area suggested in VJ's slides 
is a lock-free producer-consumer ring. It is missing in your patch
and I could guess it is not big loss, it is unlikely
to improve something significantly until the lock is heavily contended,
which never happens without massive network-level parallelism
for a single bucket.


The next question is about locality:

To find netchannel bucket in netif_receive_skb() you have to access
all the headers of packet. Right? Then you wait for processing in user
context, and this information is washed out of cache or even scheduled
on another CPU.

In traditional approach you also fetch all the headers on softirq,
but you do all the required work with them immediately and do not access them
when the rest of processing is done in process context. I do not see
how netchannels (without hardware classification) can improve something
here. At the first sight it makes locality worse.

Honestly, I do not see how this approach could improve performance
even a little. And it looks like your benchmarks confirm that all
the win is not due to architectural changes, but just because
some required bits of code are castrated.


VJ slides describe a totally different scheme, where softirq part is omitted
completely, protocol processing is moved to user space as whole.
It is an amazing toy. But I see nothing, which could promote its status
to practical. Exokernels used to do this thing for ages, and all the
performance gains are compensated by overcomplicated classification
engine, which has to remain in kernel and essentially to do the same
work which routing/firewalling/socket hash tables do.


> advance that having two separate TCP stacks (one of which can contain 
> some bugs (I mean atcp.c)) is not that good idea, so I understand 
> possible negative feedback on that issue, but it is much better than
> silence.

You are absolutely right here. Moreover, I can guess that absense
of feedback is a direct consequence of this thing. I would advise to
get rid of it and never mention it again. :-) If you took VJ suggestion
seriously and moved TCP engine to user space, it could remain unnoticed.
But if TCP stays in kernel (and it obviously has to), you want to work
with normal stack, you can improve, optimize and rewrite it infinitely,
but do not start with a toy. It proves nothing and compromises
the whole approach.

Alexey
