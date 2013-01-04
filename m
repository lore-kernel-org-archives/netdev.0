From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Date: Fri, 04 Jan 2013 09:15:03 -0800
Message-ID: <1357319703.1678.1737.camel@edumazet-glaptop>
References: <20121228014503.GA5017@dcvr.yhbt.net>
	 <20130102200848.GA4500@dcvr.yhbt.net>  <20130104160148.GB3885@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Wong <normalperson@yhbt.net>, linux-mm@kvack.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rik van Riel <riel@redhat.com>,
	Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Mel Gorman <mgorman@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:33945 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754994Ab3ADRPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 12:15:11 -0500
In-Reply-To: <20130104160148.GB3885@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-04 at 16:01 +0000, Mel Gorman wrote:

> Implying that it's stuck in compaction somewhere. It could be the case
> that compaction alters timing enough to trigger another bug. You say it
> tests differently depending on whether TCP or unix sockets are used
> which might indicate multiple problems. However, lets try and see if
> compaction is the primary problem or not.

One difference between TCP or unix socket is that :

Unix sockets try hard to limit the order of allocations.

For a 16KB (+ skb overhead) send(), we will probably use one order-2
page and one order-0 page as a frag (data_len being not 0) :

vi +1484 net/unix/af_unix.c

       if (len > SKB_MAX_ALLOC)
                data_len = min_t(size_t,
                                 len - SKB_MAX_ALLOC,
                                 MAX_SKB_FRAGS * PAGE_SIZE);

        skb = sock_alloc_send_pskb(sk, len - data_len, data_len,
                                   msg->msg_flags & MSG_DONTWAIT, &err);

While TCP could use order-3 pages if available

Eric, you could try to change SKB_FRAG_PAGE_ORDER in net/core/sock.c to
lower values (16384, 8192, 4096) and check if the hang can disappear or
not.

Alternatively (no kernel patching needed), you could try to hang AF_UNIX
using buffers of 90KB, to force order-3 allocations as well (one 32KB
allocation plus 16 * 4KB frags)

Thanks
