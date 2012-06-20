From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Update netdev_alloc_frag to work more efficiently
 with TCP and GRO
Date: Wed, 20 Jun 2012 10:17:03 +0200
Message-ID: <1340180223.4604.828.camel@edumazet-glaptop>
References: <20120620004306.17814.58369.stgit@gitlad.jf.intel.com>
	 <1340170590.4604.784.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44723 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755013Ab2FTIRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 04:17:08 -0400
Received: by bkcji2 with SMTP id ji2so5901658bkc.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 01:17:06 -0700 (PDT)
In-Reply-To: <1340170590.4604.784.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 07:36 +0200, Eric Dumazet wrote:

> I tested this idea one month ago and got not convincing results, because
> the branch was taken half of the time.
> 
> The cases where page can be reused is probably specific to ixgbe because
> it uses a different allocator for the frags themselves.
> netdev_alloc_frag() is only used to allocate the skb head.
> 
> For typical nics, we allocate frags to populate the RX ring _way_ before
> packet is received by the NIC.
> 
> Then, I played with using order-2 pages instead of order-0 ones if
> PAGE_SIZE < 8192.
> 
> No clear win either, but you might try this too.

By the way, big cost in netdev_alloc_frag() is the irq masking/restore
We probably could have a version for softirq users...

Another idea would also use a pool of pages, instead of a single one,
if we want to play with the "clear the offset if page count is one"
idea.

Strange, I did again benchs with order-2 allocations and got good
results this time, but with latest net-next, maybe things have changed
since last time I did this.

(netdev_alloc_frag(), get_page_from_freelist() and put_page() less
prevalent in perf results)
