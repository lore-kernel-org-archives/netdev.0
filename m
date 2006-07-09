From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sun, 09 Jul 2006 08:52:16 -0400
Message-ID: <1152449536.5124.31.camel@jzny2>
References: <20060630.133348.68039806.davem@davemloft.net>
	 <1151700884.5270.278.camel@jzny2> <20060630211043.GO14627@postel.suug.ch>
	 <1151703097.5270.307.camel@jzny2> <20060630234512.GR14627@postel.suug.ch>
	 <1151722785.5093.51.camel@jzny2> <20060701112833.GS14627@postel.suug.ch>
	 <1151760901.5093.141.camel@jzny2> <20060708105451.GG14627@postel.suug.ch>
	 <1152368076.5272.39.camel@jzny2>  <20060708234602.GH14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:43440 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1030485AbWGIMwV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 08:52:21 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FzYlr-0006sI-MP
	for netdev@vger.kernel.org; Sun, 09 Jul 2006 08:52:23 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060708234602.GH14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-09-07 at 01:46 +0200, Thomas Graf wrote:
> * Jamal Hadi Salim <hadi@cyberus.ca> 2006-07-08 10:14
[..]
> > There is no easy way to detect such a deadlock. I think it reduces to
> > the same case as eth0->eth0, i.e:
> 
> It's very simple. Just use the same method and add a flag if a mirred
> is currently in use as Herbert did to qdisc_run().
> 

But that would make it more complex in the sense it would require a lot
more code.

Another simpler approach is to check for recursion right in 
dev_queue_xmit() - but i did not dare to do that because i could not
justify it for any other code other than loops created by the action
code. i.e something along the lines of:

if (q->enqueue) {
		if (!spin_trylock(&dev->queue_lock)) {
			printk("yikes recursed device %s\n",dev->name);
                        goto tx_recursion_detected;
                }
.
.
.
recursion_detected:
        rc = -ENETDOWN;
        local_bh_enable();

out_kfree_skb:
        kfree_skb(skb);
        return rc;
out:
        local_bh_enable();
        return rc;
}

[BTW, notice how i used code to describe my view above ;->]
Again, I was hoping that Herbert's stuff may change this view (and
therefore give it more legitimacy) - but if the above can be accepted
then we can forget touching mirred.
The above change if acceptable will catch all sorts of scenarios:
A->A, A->B->A, A->B->C->B etc

> > I have a dated  patch to mirred (may not apply cleanly) that i believe
> > will fix this specific one. Try to see if it also fixes this case you
> > have.
> 
> This is complete nonsense, fixing a case out of a generic
> problem is useless.
> 

No Thomas - this is a valid check. As valid as mirred checking if device
is up first. I dont like it, like i said, because it adds one more check
in the first path. I was contemplating at some point even not doing the 

> > Its the second pathological case tx deadlock essentially and mirred
> > could help - it is not the mirred lock really if the attached patch
> > fixes it, but i could be wrong.
> 
> __LINK_STATE_QDISC_RUNNING will prevent an eventual tx deadlock,
> it will not prevent the mirred deadlock.
> 

By "mirred deadlock" i think you mean the deadlock that happens in
dev_queue_xmit()? 

> I think everything has been said about this, since I'm still not
> getting the intend of many parts I'm not able to fix these, sorry.
> 

What is still not clear above?

cheers,
jamal

