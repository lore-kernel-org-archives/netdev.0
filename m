From: David Miller <davem@davemloft.net>
Subject: Re: Oops in filter add
Date: Mon, 19 Mar 2007 19:22:06 -0700 (PDT)
Message-ID: <20070319.192206.21926062.davem@davemloft.net>
References: <45FEEE35.6090606@reflexsecurity.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, tgraf@suug.ch
To: chris@reflexsecurity.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58881
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965756AbXCTCWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 22:22:07 -0400
In-Reply-To: <45FEEE35.6090606@reflexsecurity.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Madden <chris@reflexsecurity.com>
Date: Mon, 19 Mar 2007 16:10:29 -0400

> I did some digging, and it appears the filter add isn't mutexed right.  
> Inside net/core/dev.c, ing_filter, I see:
> 
>         spin_lock(&dev->ingress_lock);
>         if ((q = dev->qdisc_ingress) != NULL)
>             result = q->enqueue(skb, q);
>         spin_unlock(&dev->ingress_lock);
> 
> And unless I'm missing something, this is the only place this lock is
> used ( other than initialization ).  In net/sched/cls_api.c, I see we do
> qdisc_lock_tree/qdisc_unlock_tree (which locks dev->queue_lock).  As
> near as I can tell, this is our problem ( our mutexes don't prohibit
> manipulation while packets are flowing ).

I think this should use dev->queue_lock.

It looks like the idea might have been to allow more parallelized
running of ingress filters, but this is done wrong and leads to
the crashes you are seeing.

Can you just replace the above with dev->queue_lock and see if
that makes your problem go away?  THanks.
