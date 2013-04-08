From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK packet
Date: Mon, 08 Apr 2013 13:40:40 -0400
Message-ID: <1558855.HGIqa4tJdt@sifl>
References: <20130408154519.18177.57709.stgit@localhost> <3541094.5siDbVn1lC@sifl> <1365442586.3887.26.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37252 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935109Ab3DHRkp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Apr 2013 13:40:45 -0400
In-Reply-To: <1365442586.3887.26.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, April 08, 2013 10:36:26 AM Eric Dumazet wrote:
> On Mon, 2013-04-08 at 13:22 -0400, Paul Moore wrote:
> > On Monday, April 08, 2013 12:14:34 PM David Miller wrote:
> > > From: Paul Moore <pmoore@redhat.com>
> > > Date: Mon, 08 Apr 2013 11:45:19 -0400
> > > 
> > > > Commit 90ba9b1986b5ac4b2d184575847147ea7c4280a2 converted
> > > > tcp_make_synack() to use alloc_skb() directly instead of calling
> > > > sock_wmalloc(), the goal being the elimination of two atomic
> > > > operations.  Unfortunately, in doing so the change broke certain
> > > > SELinux/NetLabel configurations by no longer correctly assigning
> > > > the sock to the outgoing packet.
> > > > 
> > > > This patch fixes this regression by doing the skb->sk assignment
> > > > directly inside tcp_make_synack().
> > > > 
> > > > Reported-by: Miroslav Vadkerti <mvadkert@redhat.com>
> > > > Signed-off-by: Paul Moore <pmoore@redhat.com>
> > > 
> > > Setting skb->sk without the destructor results in an SKB that can live
> > > potentially forever with a stale reference to a destroyed socket.
> > > 
> > > You cannot fix the problem in this way.
> > 
> > Okay, no worries, I'll work on v2.  For some reason I missed the
> > destructor assignment in skb_set_owner_w(); I guess I was spending so much
> > time hunting around looking for the missing skb->sk assignment that once I
> > found it I declared victory ... a bit too soon.
> > 
> > Looking at the code again, I think the right solution is to call
> > skb_set_owner_w() instead of doing the assignment directly but that is
> > starting to bring us back to sock_wmalloc(force == 1) which gets back to
> > Eric's comments ... (below) ...
> > 
> > On Monday, April 08, 2013 09:19:23 AM Eric Dumazet wrote:
> > > Keeping a pointer on a socket without taking a refcount is not going to
> > > work.
> > > 
> > > We are trying to make the stack scale, so you need to add a selinux call
> > > to take a ref count only if needed.
> > > 
> > > That is : If selinux is not used, we don't need to slow down the stack.
> > 
> > Contrary to popular belief, my goal is to not destroy the scalability
> > and/or performance of our network stack, I just want to make sure we have
> > a quality network stack that is not only fast and scalable, but also
> > preserves the security functionality that makes Linux attractive to a
> > number of users.  To that end, we could put a #ifdef in the middle of
> > tcp_make_synack(), but that seems very ugly to me and I think sets a bad
> > precedence for the network stack and kernel as a whole.
> > 
> > So a question for Dave, et al. - would you prefer that I fix this by:
> > 
> > 1. Restore the original sock_wmalloc() call?
> > 2. Keep things as-is with skb_alloc() but add skb_set_owner_w()?
> > 3. Add a #ifdef depending on SELinux (probably the LSM in general to be
> > safe) and use sock_wmalloc() if enabled, skb_alloc() if not?
> 
> Didnt we had the same issue with RST packets ?
> 
> Please take a look at commit 3a7c384ffd57ef5fbd95f48edaa2ca4eb3d9f2ee

Sort of a similar problem, but not really the same.  Also, arguably, there is 
no real associated sock/socket for a RST so orphaning the packet makes sense.  
In the case of a SYNACK we can, and should, associate the packet with a 
sock/socket.

-- 
paul moore
security and virtualization @ redhat
