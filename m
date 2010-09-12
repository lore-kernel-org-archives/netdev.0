From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Sun, 12 Sep 2010 15:08:54 -0700 (PDT)
Message-ID: <20100912.150854.193715637.davem@davemloft.net>
References: <20100912.085833.226777368.davem@davemloft.net>
	<20100912.091353.71112923.davem@davemloft.net>
	<20100912205722.GB2585@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jarkao2@gmail.cthom
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39644
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753857Ab0ILWIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Sep 2010 18:08:36 -0400
In-Reply-To: <20100912205722.GB2585@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 12 Sep 2010 22:57:22 +0200

> On Sun, Sep 12, 2010 at 09:13:53AM -0700, David Miller wrote:
>> 
>> BTW, Jarek, as to your idea to store a tail pointer in the shinfo, how
>> will you sync that tail pointer in all of the shinfo instances
>> referencing the frag list?
>> 
>> It simply can't work, we have to copy.
> 
> The question is if we need to sync at all? This is shared data at the
> moment, so I can't imagine how the list (especialy doubly linked)
> could be changed without locking? And even if it's possible, I doubt
> copying e.g. like in your current patch can help when an skb is added
> at the tail later.

That's the fundamental issue.

If you look, everywhere we curently do that trick of "use the
skb->prev pointer to remmeber the frag_list tail" the code knows
it has exclusive access to both the skb metadata and the
underlying data.

But for modifications of the frag list during the SKBs lifetime
that's another issue, entirely.  All of these functions trimming
the head or tail of the SKB data which can modify the frag
list elements, they can be called from all kinds of contexts.
Look for Alexey Kuznetsov's comments in skbuff.c that read
"mincing fragments" and similar.

The real win with my work is complete unification of all list
handling, and making our packet handling code much more "hackable"
by non-networking kernel hackers.

Really we have the last major core datastructures that do not
use standard lists, and I'm going to convert it so we can
be sane like the rest of the kernel. :-)
