From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Distributed storage.
Date: Fri, 3 Aug 2007 14:57:47 +0400
Message-ID: <20070803105747.GE10089@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708021408.24876.phillips@phunq.net> <20070803102629.GB10089@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Daniel Phillips <phillips@phunq.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:60884 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760283AbXHCK6I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 06:58:08 -0400
Content-Disposition: inline
In-Reply-To: <20070803102629.GB10089@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 03, 2007 at 02:26:29PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > Memory deadlock is a concern of course.  From a cursory glance through, 
> > it looks like this code is pretty vm-friendly and you have thought 
> > quite a lot about it, however I respectfully invite peterz 
> > (obsessive/compulsive memory deadlock hunter) to help give it a good 
> > going over with me.

Another major issue is network allocations.

Your initial work and subsequent releases made by Peter were originally
opposed on my side, but now I think the right way is to use both
positive moments from your approach and specialized allocator -
essentially what I proposed (in the blog only though) is to bind a
independent reserve for any socket - such a reserve can be stolen from
socket buffer itself (each socket has a limited socket buffer where
packets are allocated from, it accounts both data and control (skb)
lengths), so when main allocation via common path fails, it would be
possible to get data from own reserve. This allows sending sockets to
make a progress in case of deadlock.

For receiving situation is worse, since system does not know in advance
to which socket given packet will belong to, so it must allocate from
global pool (and thus there must be independent global reserve), and
then exchange part of the socket's reserve to the global one (or just
copy packet to the new one, allocated from socket's reseve is it was
setup, or drop it otherwise). Global independent reserve is what I
proposed when stopped to advertise network allocator, but it seems that
it was not taken into account, and reserve was always allocated only
when system has serious memory pressure in Peter's patches without any
meaning for per-socket reservation.

It allows to separate sockets and effectively make them fair - system
administrator or programmer can limit socket's buffer a bit and request
a reserve for special communication channels, which will have guaranteed
ability to have both sending and receiving progress, no matter how many
of them were setup. And it does not require any changes behind network
side.

-- 
	Evgeniy Polyakov
