From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: order-0 vs order-N driver allocation. Was: [PATCH v10 07/12]
 net/mlx4_en: add page recycle to prepare rx ring for tx support
Date: Fri, 05 Aug 2016 09:15:33 +0200
Message-ID: <1470381333.13693.48.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
	 <1468955817-10604-8-git-send-email-bblanco@plumgrid.com>
	 <1469432120.8514.5.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160803174107.GA38399@ast-mbp.thefacebook.com>
	 <20160804181913.26ee17b9@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	linux-mm <linux-mm@kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35940 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757779AbcHEHPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2016 03:15:38 -0400
Received: by mail-wm0-f43.google.com with SMTP id q128so19914599wma.1
        for <netdev@vger.kernel.org>; Fri, 05 Aug 2016 00:15:38 -0700 (PDT)
In-Reply-To: <20160804181913.26ee17b9@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-04 at 18:19 +0200, Jesper Dangaard Brouer wrote:

> I actually agree, that we should switch to order-0 allocations.
> 
> *BUT* this will cause performance regressions on platforms with
> expensive DMA operations (as they no longer amortize the cost of
> mapping a larger page).


We much prefer reliable behavior, even it it is ~1 % slower than the
super-optimized thing that opens highways for attackers.

Anyway, in most cases pages are re-used, so we only call
dma_sync_single_range_for_cpu(), and there is no way to avoid this.

Using order-0 pages [1] is actually faster, since when we use high-order
pages (multiple frames per 'page') we can not reuse the pages.

[1] I had a local patch to allocate these pages using a very simple
allocator allocating max order (order-10) pages and splitting them into
order-0 ages, in order to lower TLB footprint. But I could not measure a
gain doing so on x86, at least on my lab machines.
