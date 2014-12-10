From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 1/6] net: Split netdev_alloc_frag into __alloc_page_frag
 and add __napi_alloc_frag
Date: Wed, 10 Dec 2014 09:06:56 -0800
Message-ID: <54887DB0.7040903@gmail.com>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>	 <20141210034042.2114.29360.stgit@ahduyck-vm-fedora20> <1418227328.27198.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com, davem@davemloft.net,
	brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:62334 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757433AbaLJRG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 12:06:58 -0500
Received: by mail-pd0-f173.google.com with SMTP id ft15so3128164pdb.18
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 09:06:58 -0800 (PST)
In-Reply-To: <1418227328.27198.25.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2014 08:02 AM, Eric Dumazet wrote:
> On Tue, 2014-12-09 at 19:40 -0800, Alexander Duyck wrote:
>
>> I also took the opportunity to refactor the core bits that were placed in
>> __alloc_page_frag.  First I updated the allocation to do either a 32K
>> allocation or an order 0 page.  This is based on the changes in commmit
>> d9b2938aa where it was found that latencies could be reduced in case of
>> failures. 
>
> GFP_KERNEL and GFP_ATOMIC allocation constraints are quite different.
>
> I have no idea how expensive it is to attempt order-3, order-2, order-1
> allocations with GFP_ATOMIC.

The most likely case is the successful first allocation so I didn't see
much point in trying to optimize for the failure cases.  I personally
prefer to see a fast failure rather than one that is dragged out over
several failed allocation attempts.  In addition I can get away with
several optimization tricks that I cannot with the loop.

> I did an interesting experiment on mlx4 driver, allocating the pages
> needed to store the fragments, using a small layer before the
> alloc_page() that is normally used :
>
> - Attempt order-9 allocations, and use split_page() to give the
> individual pages.
>
> Boost in performance is 10% on TCP bulk receive, because of less TLB
> misses.
>
> With huge amount of memory these days, alloc_page() tend to give pages
> spread all over memory, with poor TLB locality.
>
> With this strategy, a 1024 RX ring is backed by 2 huge pages only.

That is an interesting idea.  I wonder if there would be a similar
benefit for small packets.  If nothing else I might try a few
experiments with ixgbe to see if I can take advantage of something similar.

- Alex
