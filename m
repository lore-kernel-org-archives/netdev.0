From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
Date: Sat, 23 Aug 2014 21:38:39 -0700 (PDT)
Message-ID: <20140823.213839.1953243016141233125.davem@davemloft.net>
References: <20140823.132811.751469424156827125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, jhs@mojatatu.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39076 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbaHXEik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 00:38:40 -0400
In-Reply-To: <20140823.132811.751469424156827125.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sat, 23 Aug 2014 13:28:11 -0700 (PDT)

> This just adds the infrastructure, it does not actually add any
> instances of actually doing multiple ndo_start_xmit calls per
> ndo_xmit_flush invocation.

So today I was looking more into this aspect.

Like Tom Herbert has mentioned we have all the infrastructure (sort
of) already to handle a list of SKBs going down into
dev_hard_start_xmit() via the GSO handling.

But that code is funny, because it keeps the original GSO head SKB
around as a placeholder to maintain the list of segmented SKBs.

So the list walker basically walks starting at skb->next.  That's
awkward for what we want to do, which is pass in an arbitrary list of
SKBs.

All it really wants that head SKB for is essentially list management,
which seems like overkill to me.

Anyways, this got me thinking that we should have something that
provides the segment list management and stop keeping that head GSO
SKB around.

Then we can make that "gso:" label list walker generic enough that we
could pass down arbitrary lists of SKBs from the qdisc_restart() path.

This list management seems to be the only reason why we keep the GSO
head SKB around after dev_gso_segment(), we should be able to free it
up early without any problems right?

I'm also thinking about whether we should hang the generic SKB list
management off of the txq or the qdisc.  Right now the gso_skb thing
is in the qdisc.

Thoughts?
