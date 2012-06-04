From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Mon, 04 Jun 2012 16:01:41 +0200
Message-ID: <1338818501.2760.1821.camel@edumazet-glaptop>
References: <20120517121800.GA18052@1wt.eu> <20120517150157.GA19274@1wt.eu>
	 <1337269380.3403.10.camel@edumazet-glaptop> <20120517155621.GK14498@1wt.eu>
	 <1337272404.3403.18.camel@edumazet-glaptop> <20120517164016.GL14498@1wt.eu>
	 <1337273387.3403.24.camel@edumazet-glaptop>
	 <1337276056.3403.37.camel@edumazet-glaptop>
	 <20120604123738.GA28992@redhat.com>
	 <1338815213.2760.1806.camel@edumazet-glaptop>
	 <20120604134138.GA29814@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:55183 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716Ab2FDOBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 10:01:48 -0400
Received: by eeit10 with SMTP id t10so1542138eei.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 07:01:46 -0700 (PDT)
In-Reply-To: <20120604134138.GA29814@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-04 at 16:41 +0300, Michael S. Tsirkin wrote:

> This is generally what virtio does, take a look:
> page_to_skb fills the first fragment and receive_mergeable fills the
> rest (other modes are for legacy hardware).
> 
> The way hypervisor now works is this (we call it mergeable buffers):
> 
> - pages are passed to hardware
> - hypervisor puts virtio specific stuff in first 12 bytes
>   on first page
> - following this, the rest of the first page and all following
>   pages have data
> 
> The driver gets the 1st page, allocates the skb, copies out the 12 byte
> header and copies the first 128 bytes of data into skb.
> The rest if any is populated by the pages.
> 
> So I guess I'm asking for advice, would it make sense to switch to build_skb
> and how best to handle the data copying above? Maybe it would help
> if we changed the hypervisor to write the 12 bytes separately?
>   

Thanks for these details.

Not sure 12 bytes of headroom would be enough (instead of the
NET_SKB_PAD reserved in netdev_alloc_skb_ip_align(), but what could be
done indeed is to use the first page as the skb->head, so using
build_skb() indeed, removing one fragment, one (small) copy and one
{put|get}_page() pair.
