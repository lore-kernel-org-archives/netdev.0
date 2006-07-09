From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sun, 09 Jul 2006 10:03:16 -0400
Message-ID: <1152453796.5124.70.camel@jzny2>
References: <20060630211043.GO14627@postel.suug.ch>
	 <1151703097.5270.307.camel@jzny2> <20060630234512.GR14627@postel.suug.ch>
	 <1151722785.5093.51.camel@jzny2> <20060701112833.GS14627@postel.suug.ch>
	 <1151760901.5093.141.camel@jzny2> <20060708105451.GG14627@postel.suug.ch>
	 <1152368076.5272.39.camel@jzny2> <20060708234602.GH14627@postel.suug.ch>
	 <1152449536.5124.31.camel@jzny2>  <20060709133327.GK14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:7818 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1161007AbWGIODT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 10:03:19 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FzZsY-0002kY-Ji
	for netdev@vger.kernel.org; Sun, 09 Jul 2006 10:03:22 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060709133327.GK14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-09-07 at 15:33 +0200, Thomas Graf wrote:
> * Jamal Hadi Salim <hadi@cyberus.ca> 2006-07-09 08:52
[..]
> > Another simpler approach is to check for recursion right in 
> 
> It's very interesting that you change from "there is no easy way"
> to "another simpler approach..." in just one posting :-)
> 

I said there was no easy way of detecting - which is different from
preventing. Both approaches i showed were things i used (as far back as
last year) but did not find palatable to submit.
Hopefully we dont go into a tangent on this.

> > if (q->enqueue) {
> > 		if (!spin_trylock(&dev->queue_lock)) {
> > 			printk("yikes recursed device %s\n",dev->name);
> >                         goto tx_recursion_detected;
> >                 }
> 
> That's not gonna work, dev->queue_lock may be held legimitately
> by someone else than an underlying dev_queue_xmit() call.
> 

If there is a legitimate reason then it wont work. I cant think of one
though.

> > [BTW, notice how i used code to describe my view above ;->]
> 
> I'm very proud of you.
> 

Thank you thank you

> > Again, I was hoping that Herbert's stuff may change this view (and
> > therefore give it more legitimacy) - but if the above can be accepted
> > then we can forget touching mirred.
> 
> You need this:
> 
> if (test_and_set_bit(__LINK_STATE_ENQUEUEING, &dev->state))
> 	goto tx_recursion_detected;
> 
> spin_lock(queue_lock);
> enqueue(...)
> qdisc_run()
> spin_unlock(queue_lock);
> 
> clear_bit(__LINK_TATE_ENQUEUEING, &dev->state);
> 
> Unfortunately we'd still need __LINK_STATE_QDISC_RUNNING due
> to net_tx_action().
> 

This is also another approach that would work. If you think its simpler
go ahead and shoot a patch.

> > By "mirred deadlock" i think you mean the deadlock that happens in
> > dev_queue_xmit()? 
> 
> I meant the deadlock within mirred but the deadlock on queue_lock
> is happening first anyway.
> 

if you can stop things at the queue you wont have to worry about mirred.

> > What is still not clear above?
> 
> Frankly, I have no idea which deadlocks are intentional, what ideas
> you have about ingress->egress, etc because it is not documented.
> The list is very long. 

Ask one question at a time and i will answer. Some of the things we
discussed have no place to be commented-on in the code. But i think what
is obvious is:

A->*->A is a no-no.
And in some cases it is fine to let the user just fsck themselves
because then they will understand it is a bad idea [1] when shit
happens. OTOH, if there was a KISS way of doing it (as in the ifb case,
why not).

> I'm not going to waste time trying to work
> out a patch that will then not suit the ideas in your mind and on
> your notes. You're maintaing this code, no?

Yes, of course otherwise i wouldnt bother to comment on any patches.

cheers,
jamal

[1] there was a long discussion a few years back when i was still in
lkml on someone trying to redirect (i think) /dev/null -> /dev/mem
(dont hold me accountable if those are not the right devices, just
absorb the moral of this instead). The consensus was it would be very
difficult to do without making a lot of changes and if someone wishes to
do that they deserved what they are getting.

