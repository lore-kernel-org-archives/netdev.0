From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netpoll: Don't call driver methods from interrupt context.
Date: Tue, 04 Mar 2014 02:29:57 -0800
Message-ID: <87ppm2fe8q.fsf@xmission.com>
References: <874n3fow2i.fsf@xmission.com>
	<CAM_iQpUo7LDcXqKxpZwKjx_KX6R2hVcyHx3GJnYxEg+9Nez0Rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Matt Mackall <mpm@selenic.com>,
	Satyam Sharma <satyam.sharma@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35202 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756788AbaCDKaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 05:30:09 -0500
In-Reply-To: <CAM_iQpUo7LDcXqKxpZwKjx_KX6R2hVcyHx3GJnYxEg+9Nez0Rg@mail.gmail.com>
	(Cong Wang's message of "Mon, 3 Mar 2014 20:23:03 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> writes:

> On Mon, Mar 3, 2014 at 12:40 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>  net/core/netpoll.c |    6 +++---
>>  1 files changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
>> index a664f7829a6d..a1877621bf31 100644
>> --- a/net/core/netpoll.c
>> +++ b/net/core/netpoll.c
>> @@ -330,7 +330,7 @@ repeat:
>>                 skb = skb_dequeue(&skb_pool);
>>
>>         if (!skb) {
>> -               if (++count < 10) {
>> +               if (++count < 10 && !in_irq()) {
>>                         netpoll_poll_dev(np->dev);
>
> This looks like a workaround.

It is not a workaround.  It is a neutering of the netpoll code (when
run in irq context) to just allocate memory for the message we are going
to send and queueing that message for delivery in a safer context.

> Here ou are trying to avoid calling netpoll_poll_dev()
> in IRQ context, but it has a side effect for netpoll_send_udp()
> which could possibly return early after find_skb().

It isn't a side effect, it is an unfortuante fact of life that sometimes
you can not allocate memory in irq context.

> Also, netpoll_poll_dev() does more than just calling driver
> poll method, I am not sure if it is safe to skip it either.

netpoll_poll_dev is absolutely safe to skip at this location because
it is not called at this location 99% of the time.

Also note my patch is about much much more than not calling
the driver's napi poll method from interrupt context.  It is about
not calling any driver method from interrupt context.  This includes
ndo_poll_controller, and ndo_start_xmit.

The only work netpoll_poll_dev does that does not call into driver
methods is zap_completion_queues and find_skb has already called
zap_completion_queues.  Which means even a more fine grained aproach
could not find code in netpoll_poll_dev that is desirable to call in
interrupt context.

I expect you were referring to netpoll_neigh_reply and there are issues
with that code.

Semantically netpoll_neigh_reply is a path into the driver methods for
sending packets and as such is not appropriate to call from interrupt
context.

Practically speaking netpoll_neigh_reply is dead code because there
is not a single netpoll user in the kernel that sets rx_skb_hook.

Functionally netpoll_neigh_reply scares me to read.  It has the
potential to infinitely recurse and unless I am missing some deep magic
it leaks every packet that makes it on to the neigh_tx queue.

The code path that can has the potential to infinitely recurse is:
find_skb
   netpoll_poll_dev
      service_neigh_queue
         netpoll_neigh_reply
             find_skb
                ...

It is my personal recommendation that all support for receiving packets
in netpoll be removed.  It has been a decade and we still have yet to
see a user of that code merged into the tree, and the code is extremely
fishy if not totally horrifically broken.

> netpoll code needs to rewrite.

I don't have a clue what you mean there.  My guess is you are saying
netpoll need a rewrite.  After having read through the netpoll code I
would argue that my two line change is the rewrite the netpoll code
needs.  (Well other than dead code removal).

What is desired to do in interrupt context is to allocate a buffer, put
our data in it, and queue that buffer to be handled later.  That is
exactly what happens with my changes when the code is run in interrupt
context.

Better than that I have tested my changes, and the code works.

In this instance I got lucky that everything netpoll needed to do to
handle being called from interrupt context was already present in the
code and I just needed to tell the netpoll code to use those other paths
in interrupt context.

Eric
