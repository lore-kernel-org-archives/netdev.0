From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Wed, 19 Jul 2006 09:38:41 +0400
Message-ID: <20060719053841.GA24744@2ka.mipt.ru>
References: <20060718081625.GA13830@2ka.mipt.ru> <20060718230121.GA31474@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:12268 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932506AbWGSFix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 01:38:53 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20060718230121.GA31474@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 19, 2006 at 03:01:21AM +0400, Alexey Kuznetsov (kuznet@ms2.inr.ac.ru) wrote:
> Hello!

Hello, Alexey.

> Can I ask couple of questions? Just as a person who looked at VJ's
> slides once and was confused. And startled, when found that it is not
> considered as another joke of genuis. :-)
> 
> 
> About locks:
> 
> > 	  is completely lockless (there is one irq lock when skb 
> > is queued/dequeued into netchannels queue in hard/soft irq, 
> 
> Equivalent of socket spinlock.

There is no socket spinlock anymore.
Above lock is skb_queue lock which is held inside
skb_dequeue/skb_queue_tail calls.
 
> > one mutex for netchannel's bucket 
> 
> Equivalent of socket user lock.

No, it is an equivalent for hash lock in socket table.

> > and some locks on qdisk/NIC driver layer,
> 
> The same as in traditional code, right?

I use dst_output(), so it is possible to have as many locks inside
low-level NIC driver as you want.

> From all that I see, this "completely lockless code" has not less locks
> than traditional approach, even when doing no protocol processing.
> Where am I wrong? Frankly speaking, when talking about locks,
> I do not see anything, which could be saved, only TCP hash table
> lookup can be RCUized, but this optimization obviously has nothing to do
> with netchannels.

It looks like you should looks at it again :)
Just an example - tcp_established() can be called with bh disabled under
the socket lock. In netchannels there is no need for that.

> The only improvement in this area suggested in VJ's slides 
> is a lock-free producer-consumer ring. It is missing in your patch
> and I could guess it is not big loss, it is unlikely
> to improve something significantly until the lock is heavily contended,
> which never happens without massive network-level parallelism
> for a single bucket.

That's because I decided to use skbs, but not special structures and
thus I use the same queue as socket code (and have the only one lock
inside skb_queue_tail()/skb_dequeue()). I will describe below why I do
not changed it to more hardware-friendly stuff.

> The next question is about locality:
> 
> To find netchannel bucket in netif_receive_skb() you have to access
> all the headers of packet. Right? Then you wait for processing in user
> context, and this information is washed out of cache or even scheduled
> on another CPU.
> 
> In traditional approach you also fetch all the headers on softirq,
> but you do all the required work with them immediately and do not access them
> when the rest of processing is done in process context. I do not see
> how netchannels (without hardware classification) can improve something
> here. At the first sight it makes locality worse.

In that case one copies the whole data into userspace, so access for 20
bytes of headers completely does not matter.

> Honestly, I do not see how this approach could improve performance
> even a little. And it looks like your benchmarks confirm that all
> the win is not due to architectural changes, but just because
> some required bits of code are castrated.

Hmm, for 80 bytes sized packets win was about 2.5 times. Could you
please show me lines inside existing code, which should be commented, so
I got 50Mbyte/sec for that?

> VJ slides describe a totally different scheme, where softirq part is omitted
> completely, protocol processing is moved to user space as whole.
> It is an amazing toy. But I see nothing, which could promote its status
> to practical. Exokernels used to do this thing for ages, and all the
> performance gains are compensated by overcomplicated classification
> engine, which has to remain in kernel and essentially to do the same
> work which routing/firewalling/socket hash tables do.

There are several ideas presented in his slides.
For my personal opinion most of performance win is obtained from
userspace processing and memcpy instead of copy_to_user() (but my
previous work showed that it is not the case for a lot of situations),
so I created first approach, tested second and now move into fully
zero-copy design. How skbs or other structures are delivered into the
queue/array does not matter in my design - I can replace it in a moment,
but I do not want to mess with drivers, since it is huge break, which
must be done after high-level stuff proven to work good.

> > advance that having two separate TCP stacks (one of which can contain 
> > some bugs (I mean atcp.c)) is not that good idea, so I understand 
> > possible negative feedback on that issue, but it is much better than
> > silence.
> 
> You are absolutely right here. Moreover, I can guess that absense
> of feedback is a direct consequence of this thing. I would advise to
> get rid of it and never mention it again. :-) If you took VJ suggestion
> seriously and moved TCP engine to user space, it could remain unnoticed.
> But if TCP stays in kernel (and it obviously has to), you want to work
> with normal stack, you can improve, optimize and rewrite it infinitely,
> but do not start with a toy. It proves nothing and compromises
> the whole approach.

Well, you probably did not read my previous e-mails about netchannels.
I showed there, that using existing stack it is imposible to get big
performance win (although I tested my patches with 1gb only), since
there are some nitpicks on sending side (now I think it is congestion
control, but I'm not 100% sure).

The only thing my TCP stack implementation proves, that it is possible
to have higher transfer rate with existing NICs over TCP that with
existing socket code, no more, no less.

> Alexey

-- 
	Evgeniy Polyakov
