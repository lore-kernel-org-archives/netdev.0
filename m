From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Thu, 04 May 2006 16:22:23 -0700 (PDT)
Message-ID: <20060504.162223.44735502.davem@davemloft.net>
References: <200604271331.37073.kelly@au.ibm.com>
	<20060426.232501.119306252.davem@davemloft.net>
	<200605041259.23204.kelly@au.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49815
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750818AbWEDXWa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 19:22:30 -0400
To: kelly@au1.ibm.com
In-Reply-To: <200605041259.23204.kelly@au.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kelly Daly <kelly@au1.ibm.com>
Date: Thu, 4 May 2006 12:59:23 +1000

> We DID write an infrastructure to resolve this issue, although it is more 
> complex than the dynamic descriptor scheme for userspace.  And we want to 
> keep this simple - right?

Yes.

I wonder if it is possible to manage the buffer pool just like a SLAB
cache to deal with the variable lifetimes.  The system has a natural
"working set" size of networking buffers at a given point in time and
even the default net channel can grow to accomodate that with some
kind of limit.

This is kind of what I was alluding to in the past, in that we now
have globals limits on system TCP socket memory when really what we
want to do is have a set of global generic system packet memory
limits.

These two things can tie in together.

Note that this means we need a callback in the SKB to free the memory
up.  For direct net channels to a socket, you don't need any callbacks
of course because as you mentioned you know the buffer lifetimes.

People want such a callback anyways in order to experiment with SKB
recycling in drivers.

Note that some kind of "shrink" callback would need to be implemented.
It would only be needed for the default channel.  We need to seriously
avoid needing something like this over the socket net channels because
that is serious complexity.

Finally... if we go the global packet memory route, we will need hard
and soft limits.  There is a danger in such a scheme of not being able
to get critical control packets out (ACKs, etc.).  Also, there are all
kinds of classification and drop algorithms (see RED) which could be
used to handle overload situations gracefully.

So, are you still sure you want to do away with the descriptors for
the default channel?  Is the scheme I have outlined above doable or
is there some critical barrier or some complexity issue which makes
it undesirable?
