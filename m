From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: bk16 changes to cbq
Date: Wed, 7 Jul 2004 19:59:58 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707155958.GA9797@ms2.inr.ac.ru>
References: <1088861810.1039.298.camel@jzny.localdomain> <20040705202727.GA21226@ms2.inr.ac.ru> <20040706221317.2f0585d1.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040706221317.2f0585d1.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> e1000 would hang the delay scheduler sometimes
> 
> Let me look for the exact email from Stephen.  Here it is:
> 
> http://mailman.ds9a.nl/pipermail/lartc/2004q2/012736.html

Well, that test was really meaningless. So, Stephen's patch is right.

The problem is that Stephen's argument just does not look right
and forces to suspect some worse bug somewhere. If netif_queue_stopped(),
it will be awaken, so no loss of wakeups can happen. If a device
sets stopped flag and forgets to wake up after that, it is really
badly broken and this should be repaired, it inevitably will result
in stalls.


> Jamal read this, and that is what prompted him to say that if
> the delay scheduler was made classful instead of "pretending"
> to be, the bug mentioned in Stephen's email would not occur.

It is not related issue. sch_delay allocates private fifo qdisc,
which is quite pointless (it is not accessible for tuning anyway)
and complicates things a lot. F.e. if it copied tbf structure,
it would not have to use ->requeue.

And if it is planned to be tunable and replacable with something else,
it should be classful.


> I do not understand things fully.  I think it would help if, for example,
> each of the qdisc and classification operations had some comments
> describing the exact semantics of each ops->method.   For example,
> what does requeue do and what is it indicating with each of the
> possible return values.  What is expected of it?  What kind of state
> is it allowed to leave the queue in?

Ideally, ->requeue() should return queue to the state before ->dequeue(),
undoing all the state. When it fails (which is possible only due to
some fault sort of failed memory allocation. In the case of sch_delay,
which uses requeue of fifo it is absolutely impossible), it drops
skb and returns NET_XMIT_DROP or NET_XMIT_CN.

Stephen's statement:

> Also, if requeuing the packet fails, it is probably because the queue became full
> by a racing enqueue.

is not true. Everything between dequeue() and requeue() happens under
dev->queue_lock, so there is no place for races there.
Simple qdiscs never fail. cbq cannot fail too, the place where it returns
NET_XMIT_CN is rather for safety when some user drops lock somewhere
between dequeue and requeue, which is not allowed actually.


>  So the right thing to do is to go back and try again

In theory he is right. sch_delay just have no choice. If it just returns,
when ->requeue() failed by some unknown reason, sch_delay would stall.

But, again, sch_delay uses fifo, which never fails in any case.
So, it does not matter. :-)

Alexey
