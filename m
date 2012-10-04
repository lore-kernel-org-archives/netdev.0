From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: kernel 3.2.27 on arm: WARNING: at mm/page_alloc.c:2109
 __alloc_pages_nodemask+0x1d4/0x68c()
Date: Thu, 04 Oct 2012 18:02:01 +0200
Message-ID: <1349366521.2532.12.camel@sakura.staff.proxad.net>
References: <20120829002548.GA7063@aldebaran.gro-tsen.net>
	 <alpine.LSU.2.00.1208311900330.1936@eggly.anvils>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: David Madore <david+ml@madore.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:59722 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757061Ab2JDQKP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2012 12:10:15 -0400
In-Reply-To: <alpine.LSU.2.00.1208311900330.1936@eggly.anvils>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2012-08-31 at 19:21 -0700, Hugh Dickins wrote:

Hi,

> Francois is right that a GFP_ATOMIC allocation from pskb_expand_head()
> is failing, which can easily happen, and cause your "failed to reallocate
> TX buffer" errors; but it's well worth looking up what's actually on
> lines 2108 and 2109 of mm/page_alloc.c in 3.2.27:
> 
> 	if (order >= MAX_ORDER) {
> 		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
> 
> That was probably not a sane allocation request, it has gone out of range:
> maybe the skb header is even corrupted.  If you're lucky, it might be
> something that netdev will recognize as already fixed.

I have the same problem on the exact same hardware and found the cause:

Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Tue Apr 10 20:08:39 2012 +0000

    net: allow pskb_expand_head() to get maximum tailroom
    
    [ Upstream commit 87151b8689d890dfb495081f7be9b9e257f7a2df ]
    

It turns out this change has a bad side effect on drivers that uses
skb_recycle(), in that case mv643xx_eth.c

Since skb_recycle() resets skb->data using (skb->head + NET_SKB_PAD), a
recycled skb going multiple times through a path that needs to expand
skb head will get bigger and bigger each time, and you eventually end up
with an allocation failure.

An idea to fix this would be to pass needed skb size to skb_resize() and
set skb->data to MIN(NET_SKB_PAD, (skb->end - skb->head - skb_size) / 2)

skb recycling gives a small speed boost, but does not get a lot of test
coverage since only 3 drivers uses it

-- 
Maxime
