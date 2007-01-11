From: David Miller <davem@davemloft.net>
Subject: Re: BUG: soft lockup detected on CPU#0! (2.6.18.2 plus hacks)
Date: Thu, 11 Jan 2007 01:27:55 -0800 (PST)
Message-ID: <20070111.012755.15271378.davem@davemloft.net>
References: <20070111082958.GB1672@ff.dom.local>
	<20070111083526.GC1672@ff.dom.local>
	<20070111083934.GA2578@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, greearb@candelatech.com,
	herbert@gondor.apana.org.au, dlstevens@us.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50502
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965345AbXAKJ14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jan 2007 04:27:56 -0500
To: jarkao2@o2.pl
In-Reply-To: <20070111083934.GA2578@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@o2.pl>
Date: Thu, 11 Jan 2007 09:39:34 +0100

> Sure, but is this even legal to be preempted during
> reading or modifying rcu list or be blocked while 
> holding rcu protected pointer? Doesn't this disturb
> rcu cycle and make possible memory release problems?

It's fine in this case.

Since the list cannot be changed by anyone else, and the hash linked
list (as seen by readers) is modified atomically by a single store, it
all works out.

Readers only look at foo->next in the hash traversal.  Since the
preceeding element cannot change outside of the current writer,
the ->next pointer to update is protected.

Readers therefore will either see the hash list with the entry or
without.

We then use call_rcu() to make sure any reading threads that happened
to get a glimpse of the hash entry before the hlist_del_rcu()
completed will go away and drop their references before we free that
entry.

I really don't see any problem here. :-)

