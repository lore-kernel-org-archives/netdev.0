From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sun, 9 Jul 2006 15:33:27 +0200
Message-ID: <20060709133327.GK14627@postel.suug.ch>
References: <20060630211043.GO14627@postel.suug.ch> <1151703097.5270.307.camel@jzny2> <20060630234512.GR14627@postel.suug.ch> <1151722785.5093.51.camel@jzny2> <20060701112833.GS14627@postel.suug.ch> <1151760901.5093.141.camel@jzny2> <20060708105451.GG14627@postel.suug.ch> <1152368076.5272.39.camel@jzny2> <20060708234602.GH14627@postel.suug.ch> <1152449536.5124.31.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:47328 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1030490AbWGINdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2006 09:33:07 -0400
To: Jamal Hadi Salim <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1152449536.5124.31.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Jamal Hadi Salim <hadi@cyberus.ca> 2006-07-09 08:52
> On Sun, 2006-09-07 at 01:46 +0200, Thomas Graf wrote:
> > * Jamal Hadi Salim <hadi@cyberus.ca> 2006-07-08 10:14
> [..]
> > > There is no easy way to detect such a deadlock. I think it reduces to
> > > the same case as eth0->eth0, i.e:
> > 
> > It's very simple. Just use the same method and add a flag if a mirred
> > is currently in use as Herbert did to qdisc_run().
> > 
> 
> But that would make it more complex in the sense it would require a lot
> more code.
> 
> Another simpler approach is to check for recursion right in 

It's very interesting that you change from "there is no easy way"
to "another simpler approach..." in just one posting :-)

> dev_queue_xmit() - but i did not dare to do that because i could not
> justify it for any other code other than loops created by the action
> code. i.e something along the lines of:
> 
> if (q->enqueue) {
> 		if (!spin_trylock(&dev->queue_lock)) {
> 			printk("yikes recursed device %s\n",dev->name);
>                         goto tx_recursion_detected;
>                 }

That's not gonna work, dev->queue_lock may be held legimitately
by someone else than an underlying dev_queue_xmit() call.

> [BTW, notice how i used code to describe my view above ;->]

I'm very proud of you.

> Again, I was hoping that Herbert's stuff may change this view (and
> therefore give it more legitimacy) - but if the above can be accepted
> then we can forget touching mirred.

You need this:

if (test_and_set_bit(__LINK_STATE_ENQUEUEING, &dev->state))
	goto tx_recursion_detected;

spin_lock(queue_lock);
enqueue(...)
qdisc_run()
spin_unlock(queue_lock);

clear_bit(__LINK_TATE_ENQUEUEING, &dev->state);

Unfortunately we'd still need __LINK_STATE_QDISC_RUNNING due
to net_tx_action().

> No Thomas - this is a valid check. As valid as mirred checking if device
> is up first. I dont like it, like i said, because it adds one more check
> in the first path. I was contemplating at some point even not doing the 

I'm not going to argue about this.

> By "mirred deadlock" i think you mean the deadlock that happens in
> dev_queue_xmit()? 

I meant the deadlock within mirred but the deadlock on queue_lock
is happening first anyway.

> What is still not clear above?

Frankly, I have no idea which deadlocks are intentional, what ideas
you have about ingress->egress, etc because it is not documented.
The list is very long. I'm not going to waste time trying to work
out a patch that will then not suit the ideas in your mind and on
your notes. You're maintaing this code, no?
