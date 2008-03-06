From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Thu, 6 Mar 2008 22:40:00 +0100
Message-ID: <20080306214000.GC2876@ami.dom.local>
References: <20080224222035.M62480@visp.net.lb> <20080225095646.GA4321@ff.dom.local> <20080225104652.M2446@visp.net.lb> <20080225113930.GA4733@ff.dom.local> <20080305103935.M76165@visp.net.lb> <20080306134015.GA4571@ff.dom.local> <1204811995.4440.30.camel@localhost> <20080306175629.GA2876@ami.dom.local> <1204836523.4457.103.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:11812 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547AbYCFVe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 16:34:27 -0500
Received: by ug-out-1314.google.com with SMTP id z38so4011505ugc.16
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2008 13:34:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1204836523.4457.103.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2008 at 03:48:42PM -0500, jamal wrote:
> On Thu, 2008-06-03 at 18:56 +0100, Jarek Poplawski wrote:
> 
> > Every netdevice after register_netdevice() has its queue_lock and
> > ingress_lock initialized with the same static lock_class_keys, so unless
> > changed later, these locks are treated by lockdep as 2 global locks.
> >  So, taking such locks with different order should be reported. 
> 
> ok.
> 
> > This really
> > happens in act_mirred, and I don't know yet, why this wasn't reported
> > earlier.
> 
> Look closely at those traces again ;-> there are *three* different
> netdevices involved, one (loopback) seems to be _totaly_ unrelated.
> Tracing of those locks just seems confused - perhaps the pernet stuff is
> confusing loopback?

But currently lockdep doesn't know dev->queue_lock could mean eth or lo.
It sees one class of devices using one lock. We can let it know (e.g.
dev->_xmit_lock is different according to dev->type), but it wasn't
necessary. I hope it will suffice here if lockdep knows more about ifb,
but similar problem could theoretically happen with other devs.

> > Of course, if there are two different devices this could be safe, but
> > not always (e.g. thread1 has dev_eth0->ingress_lock and wants
> > dev_eth1->queue_lock, thread2 has dev_eth1->ingress_lock, wants
> > dev_eth0->qdisc_lock, and thread3 has dev_eth0->qdisc_lock and wants

Sorry, should be:
 dev_eth0->queue_lock, and thread3 has dev_eth0->queue_lock and wants

> > dev_eth0->ingress_lock). With ifb this shouldn't be the case, but
> > anyway we have to tell lockdep that ifb uses a different pair of locks.
> 
> thread3 can not happen because we dont allow it (the other 2 are not
> contentious).

Could you explain why? It's a qdisc_lock_tree case and probably not only
this.

> There are cases where redirecting will cause you problems (example if
> you redirected to yourself and cause an infinite redirect) which are
> listed in iproute2/doc. Denys script is fine afaics.

Yes, but it seems such redirection between two eths like above mentioned
is legal?

Jarek P.
