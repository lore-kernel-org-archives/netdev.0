From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Thu, 6 Mar 2008 18:56:29 +0100
Message-ID: <20080306175629.GA2876@ami.dom.local>
References: <20080224222035.M62480@visp.net.lb> <20080225095646.GA4321@ff.dom.local> <20080225104652.M2446@visp.net.lb> <20080225113930.GA4733@ff.dom.local> <20080305103935.M76165@visp.net.lb> <20080306134015.GA4571@ff.dom.local> <1204811995.4440.30.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:53283 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753963AbYCFRwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 12:52:24 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2496629fga.17
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2008 09:52:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1204811995.4440.30.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2008 at 08:59:55AM -0500, jamal wrote:
> On Thu, 2008-06-03 at 13:40 +0000, Jarek Poplawski wrote:
> 
> > I'm not sure this lockdep report is because of this, but there is
> > really a problem with lock order while using sch_ingress with
> > act_mirred: dev->queue_lock is taken after dev->ingress_lock, so
> > reversely to e.g. qdisc_lock_tree(). This shouldn't be a problem
> > when one of the devices is ifb yet.
> 
> Are there more details? Ingress of which netdevice is redirecting to
> egress of which netdevice?
> Sorry, I dont understand much about the internals of lockdep so i dont
> know what you are teaching it in the patch below...

Every netdevice after register_netdevice() has its queue_lock and
ingress_lock initialized with the same static lock_class_keys, so unless
changed later, these locks are treated by lockdep as 2 global locks. So,
taking such locks with different order should be reported. This really
happens in act_mirred, and I don't know yet, why this wasn't reported
earlier.

Of course, if there are two different devices this could be safe, but
not always (e.g. thread1 has dev_eth0->ingress_lock and wants
dev_eth1->queue_lock, thread2 has dev_eth1->ingress_lock, wants
dev_eth0->qdisc_lock, and thread3 has dev_eth0->qdisc_lock and wants
dev_eth0->ingress_lock). With ifb this shouldn't be the case, but
anyway we have to tell lockdep that ifb uses a different pair of locks.

My patch teaches lockdep about queue_lock, but after rethinking it
seems it's not enough, and I'll have to update this patch with
ingress_lock too.

Denys, I'll have to read your script yet, so you can wait with this
patching (unless you've started already - anyway this patch shouldn't
be harmful).

Thanks,
Jarek P.
