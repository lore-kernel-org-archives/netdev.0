From: David Miller <davem@davemloft.net>
Subject: Re: Multicast packet loss
Date: Fri, 13 Mar 2009 14:51:52 -0700 (PDT)
Message-ID: <20090313.145152.121603300.davem@davemloft.net>
References: <49B3F655.6030308@cosmosbay.com>
	<20090308.194922.267426196.davem@davemloft.net>
	<49B4B909.7050002@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kchang@athenacr.com, netdev@vger.kernel.org,
	cl@linux-foundation.org, bmb@athenacr.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34950
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754458AbZCMVwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 17:52:06 -0400
In-Reply-To: <49B4B909.7050002@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 09 Mar 2009 07:36:57 +0100

> I chose cmpxchg() because I needed some form of exclusion here.
> I first added a spinlock inside "struct softirq_del" then I realize
> I could use cmpxchg() instead and keep the structure small. As the
> synchronization is only needed at queueing time, we could pass
> the address of a spinlock XXX to sofirq_del() call.

I don't understand why you need the mutual exclusion in the
first place.  The function pointer always has the same value.
And this locking isn't protecting the list insertion either,
as that isn't even necessary.

It just looks like plain overhead to me.

> Also, when an event was queued for later invocation, I also needed to keep
> a reference on "struct socket" to make sure it doesnt disappear before
> the invocation. Not all sockets are RCU guarded (we added RCU only for 
> some protocols (TCP, UDP ...). So I found keeping a read_lock
> on callback was the easyest thing to do. I now realize we might
> overflow preempt_count, so special care is needed.

You're using this in UDP so... make the rule that you can't use
this with a non-RCU-quiescent protocol.

> About your first point, maybe we should make sofirq_del() (poor name
> I confess) only have one argument (pointer to struct softirq_del),
> and initialize the function pointer at socket init time. That would
> insure "struct softirq_del" is associated to one callback
> only. cmpxchg() test would have to be done on "next" field then (or
> use the spinlock XXX)

Why?  You run this from softirq safe context, nothing can run other
softirqs on this cpu and corrupt the list, therefore.
