From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4 3/5] fib_trie: dump doesnt use RCU
Date: Wed, 23 Jan 2008 23:26:51 -0800 (PST)
Message-ID: <20080123.232651.71974261.davem@davemloft.net>
References: <47983304.3030309@trash.net>
	<20080123.224337.80401207.davem@davemloft.net>
	<4798348B.4080300@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60177
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752185AbYAXH0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 02:26:41 -0500
In-Reply-To: <4798348B.4080300@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 24 Jan 2008 07:47:39 +0100

> David Miller wrote:
> > From: Patrick McHardy <kaber@trash.net>
> > Date: Thu, 24 Jan 2008 07:41:08 +0100
> >
> >> David Miller wrote:
> >>     
> >>> and nothing in that code path retakes the RTNL semaphore.
> >>>       
> >> Actually we're always holding the rtnl during dumps, nlk->cb_mutex points
> >> to rtnl_mutex in case of rtnetlink. It used to be held only during the first
> >> ->dump invocation and not on continuations, but I changed this a few 
> >> versions ago.
> >>     
> >
> > My bad.  Thanks for the correction Patrick.
> >
> > But continuations can occur on subsequent recvmsg() calls,
> > does it return to userspace with the mutex held?  If so
> > I'm pretty sure that's not allowed.
> 
> No, the mutex is dropped between different ->dump invocations.

Ok, great.

This does mean, however, that the RTNL semaphore is dropped between
->dump() invocations on the same nlk->cb[] instance.

And that has implications for the shortcut Stephen is taking.

Stephen's patch assumes that during a (top-level) dump the table
cannot change.  And by the above, we can only conclude that it can in
fact change between ->dump() calls for the same top-level dump run.

So the removal of the -EBUSY code block in his patch isn't valid.
