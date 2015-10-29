From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 29 Oct 2015 04:16:11 +0000
Message-ID: <20151029041611.GF22011@ZenIV.linux.org.uk>
References: <1445991236.7476.59.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151028123543.GB22011@ZenIV.linux.org.uk>
 <1446038672.7476.65.camel@edumazet-glaptop2.roam.corp.google.com>
 <1446043677.7476.68.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151028211347.GC22011@ZenIV.linux.org.uk>
 <1446068668.7476.89.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151028223330.GD22011@ZenIV.linux.org.uk>
 <1446073709.7476.93.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151029001532.GE22011@ZenIV.linux.org.uk>
 <1446089381.7476.114.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	dhowells@redhat.com, linux-fsdevel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60621 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbbJ2EQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 00:16:16 -0400
Content-Disposition: inline
In-Reply-To: <1446089381.7476.114.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 28, 2015 at 08:29:41PM -0700, Eric Dumazet wrote:

> But this is an optimization : If you do not use the initial dup2(), the
> fd array can be automatically expanded if needed (all slots are in use)

Whee...

> No locking change. files->file_lock is still taken.
> 
> We only want to minimize time to find an empty slot.

Then I'd say that my variant is going to win.  It *will* lead to
cacheline pingpong in more cases than yours, but I'm quite sure that
it will be a win as far as the total amount of cachelines accessed.

> The trick is to not start bitmap search at files->next_fd, but a random
> point. This is a win if we assume there are enough holes.
> 
> low = start;
> if (low < files->next_fd)
>     low = files->next_fd;
> 
> res = -1;
> if (flags & O_FD_FASTALLOC) {
> 	random_point = pick_random_between(low, fdt->max_fds);
> 
> 	res = find_next_zero_bit(fdt->open_fds, fdt->max_fds,
> 				random_point);
> 	/* No empty slot found, try the other range */
> 	if (res >= fdt->max_fds) {
> 		res = find_next_zero_bit(fdt->open_fds,
> 				low, random_point);
> 		if (res >= random_point)
> 			res = -1;
> 	}
> }

Have you tried to experiment with that in userland?  I mean, emulate that
thing in normal userland code, count the cacheline accesses and drive it
with the use patterns collected from actual applications.

I can sit down and play with math expectations, but I suspect that it's
easier to experiment.  It's nothing but an intuition (I hadn't seriously
done probability theory in quite a while, and my mathematical tastes run
more to geometry and topology anyway), but... I would expect it to degrade
badly when the bitmap is reasonably dense.

Note, BTW, that vmalloc'ed memory gets populated as you read it, and it's
not cheap - it's done via #PF triggered in kernel mode, with handler
noticing that the faulting address is in vmalloc range and doing the
right thing.  IOW, if your bitmap is very sparse, the price of page faults
needs to be taken into account.

AFAICS, the only benefit of that thing is keeping dirtied cachelines far
from each other.  Which might be a win overall, but I'm not convinced that
the rest won't offset the effect of that...
