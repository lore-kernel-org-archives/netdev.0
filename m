From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: tc related lockdep warning.
Date: Wed, 27 Sep 2006 10:54:27 +0200
Message-ID: <20060927085427.GA1619@ff.dom.local>
References: <20060925124352.GA1592@ff.dom.local> <1159188473.5301.68.camel@jzny2> <4517D9A6.70307@trash.net> <45195219.7050105@trash.net> <20060926212034.GA3134@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:15261 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1750864AbWI0IuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 04:50:10 -0400
To: Dave Jones <davej@redhat.com>
Content-Disposition: inline
In-Reply-To: <20060926212034.GA3134@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 26, 2006 at 05:20:34PM -0400, Dave Jones wrote:
> On Tue, Sep 26, 2006 at 06:15:21PM +0200, Patrick McHardy wrote:
>  > Patrick McHardy wrote:
>  > > jamal wrote:
>  > > 
>  > >>Yes, that looks plausible. Can you try making those changes and see if
>  > >>the warning is gone?
>  > > 
>  > >
>  > > I think this points to a bigger brokeness caused by the move of
>  > > dev->qdisc to RCU. It means destruction of filters and actions doesn't
>  > > necessarily happens in user-context and thus not protected by the rtnl
>  > > anymore.
>  > 
>  > I looked into this and we indeed still have lots of problems from that
>  > broken RCU patch. Basically all locking (qdiscs, classifiers, actions,
>  > estimators) assumes that updates are only done in process context and
>  > thus read_lock doesn't need bottem half protection. Quite a few things
>  > also assume that updates only happen under the RTNL and don't need
>  > any further protection if not used during packet processing.
>  > 
>  > Instead of "fixing" all this I suggest something like this (untested)
>  > patch instead. Since only the dev->qdisc pointer is protected by RCU,
>  > but enqueue and the qdisc tree are still protected by dev->qdisc_lock,
>  > we can perform destruction of the tree immediately and only do the
>  > final free in the rcu callback, as long as we make sure not to enqueue
>  > anything to a half-way destroyed qdisc.
> 
> With this patch, I get no lockdep warnings, but the machine locks up completely.
> I hooked up a serial console, and found this..
...

Sorry for my not humble and simplistic opinion, but I'd dare
to remind you are changing "stable" version and even without
this lockups this patch would look very "serious". Why don't
try to restore not-rcu version of qdisc_destroy which looks
not lot to do.

Jarek P.
