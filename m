From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
Date: Mon, 25 Aug 2014 15:31:46 -0700 (PDT)
Message-ID: <20140825.153146.2165451041039058085.davem@davemloft.net>
References: <20140823.132811.751469424156827125.davem@davemloft.net>
	<20140823.213839.1953243016141233125.davem@davemloft.net>
	<CAHA+R7O_RSyKVNqcHXePbahvU+ayf77w61jos=G38M93okVWKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	hannes@stressinduktion.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755332AbaHYWbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 18:31:48 -0400
In-Reply-To: <CAHA+R7O_RSyKVNqcHXePbahvU+ayf77w61jos=G38M93okVWKw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Mon, 25 Aug 2014 15:21:00 -0700

> When I tried to unify the list management of SKB's, I was surprised to see
> there are still some places relying on skb->next and skb->prev to be
> the head of the skb struct, since nowadays we have list API's, they still
> play some magic on these pointers (sctp and tipc IIRC). This is why I
> gave up, maybe it's time to revise this again.

I think SCTP should be OK, and yes I do remember that protocol being one of
the last subsystems making such SKB list pointer assumptions.

It was using list_*() operations on sk_buff objects or something like that.

> Talking about skb->next, fortunately we do gso segmentation after
> going out of qdisc queues, otherwise it's scary to play with these
> pointers at same time. I think all queues of SKB's are either using
> just ->next or both ->prev and ->next.

It occurs to me that perhaps the thing to do is to pass sk_buff ** to
dev_hard_start_xmit().

If it really is important to free the original GSO skb after the
segmented parts, we can run that as part of the destructor of the
final segment.
