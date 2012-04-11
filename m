From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 05/10] net: move destructor_arg to the front of sk_buff.
Date: Wed, 11 Apr 2012 10:20:28 +0200
Message-ID: <1334132428.5300.2685.camel@edumazet-glaptop>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
	 <1334067984-7706-5-git-send-email-ian.campbell@citrix.com>
	 <4F847CF9.3090701@intel.com> <1334083265.5300.288.camel@edumazet-glaptop>
	 <4F8486E7.5050604@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58980 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753458Ab2DKIUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 04:20:34 -0400
Received: by bkcik5 with SMTP id ik5so433127bkc.19
        for <netdev@vger.kernel.org>; Wed, 11 Apr 2012 01:20:32 -0700 (PDT)
In-Reply-To: <4F8486E7.5050604@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 12:15 -0700, Alexander Duyck wrote:

> 
> Actually now that I think about it my concerns go much further than the
> memset.  I'm convinced that this is going to cause a pretty significant
> performance regression on multiple drivers, especially on non x86_64
> architecture.  What we have right now on most platforms is a
> skb_shared_info structure in which everything up to and including frag 0
> is all in one cache line.  This gives us pretty good performance for igb
> and ixgbe since that is our common case when jumbo frames are not
> enabled is to split the head and place the data in a page.

I dont understand this split thing for MTU=1500 frames.

Even using half a page per fragment, each skb :

needs 2 allocations for sk_buff and skb->head, plus one page alloc /
reference.

skb->truesize = ksize(skb->head) + sizeof(*skb) + PAGE_SIZE/2 = 512 +
256 + 2048 = 2816 bytes


With non split you have :

2 allocations for sk_buff and skb->head.

skb->truesize = ksize(skb->head) + sizeof(*skb) = 2048 + 256 = 2304
bytes

less overhead and less calls to page allocator...

This only can benefit if GRO is on, since aggregation can use fragments
and a single sk_buff, instead of a frag_list
