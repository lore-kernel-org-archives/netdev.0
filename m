From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linkwatch bustage in git-net
Date: Tue, 8 May 2007 23:11:43 -0700
Message-ID: <20070508231143.fcae61c7.akpm@linux-foundation.org>
References: <20070508222033.4e57a580.akpm@linux-foundation.org>
	<20070509053154.GA850@gondor.apana.org.au>
	<20070509054558.GA1184@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:33156 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933700AbXEIGMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 02:12:20 -0400
In-Reply-To: <20070509054558.GA1184@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 May 2007 15:45:58 +1000 Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, May 09, 2007 at 03:31:55PM +1000, Herbert Xu wrote:
> > 
> > Hmm, I don't see it here (probably because we use different NICs).
> > But does this help?
> 
> Thinking about it again I don't think it will help you because if your
> carrier started out as off then it would've been considered an urgent
> event anyway.
> 
> So what NIC are you using? And where abouts in the boot process is it
> hanging? For exmaple, is it hanging when obtaining a DHCP address?
> 
> In any case, this patch can't hurt.  So here's one with a changelog:
> 
> [NET] link_watch: Eliminate potential delay on wrap-around

hm, that fixed it.  Do we know why? ;)



btw, looking at the code:

	clear_bit(LW_RUNNING, &linkwatch_flags);

	spin_lock_irq(&lweventlist_lock);
	next = lweventlist;
	lweventlist = NULL;
	spin_unlock_irq(&lweventlist_lock);

	while (next) {
		struct net_device *dev = next;

		next = dev->link_watch_next;

lweventlist_lock protects lweventlist and every netdev's ->link_watch_next.
 But this code is walking that singly-linked list outside the lock and
after clearing LW_RUNNING.  What stops this singly-linked list from getting
altered by another thread of control while this code is traversing it?

