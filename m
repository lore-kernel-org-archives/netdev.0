From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Mon, 4 Jun 2012 21:16:37 +0300
Message-ID: <20120604181636.GG32205@redhat.com>
References: <1337273387.3403.24.camel@edumazet-glaptop>
 <1337276056.3403.37.camel@edumazet-glaptop>
 <20120604123738.GA28992@redhat.com>
 <1338815213.2760.1806.camel@edumazet-glaptop>
 <20120604134138.GA29814@redhat.com>
 <1338818501.2760.1821.camel@edumazet-glaptop>
 <20120604141731.GA30226@redhat.com>
 <1338822064.2760.1834.camel@edumazet-glaptop>
 <20120604172030.GA32205@redhat.com>
 <1338831890.2760.1842.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56423 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754248Ab2FDSRA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 14:17:00 -0400
Content-Disposition: inline
In-Reply-To: <1338831890.2760.1842.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 04, 2012 at 07:44:50PM +0200, Eric Dumazet wrote:
> On Mon, 2012-06-04 at 20:20 +0300, Michael S. Tsirkin wrote:
> 
> > I see. virtio allocates full 4K pages which works well for GSO
> > but it means smaller packets would get large truesize
> > wasting lots of memory.
> > So maybe we should keep copying packets < 128 bytes.
> 
> Yet, but restrict the copy to bare minimum if > 128 bytes
> 
> See following commit for details (actual changelog bigger than patch
> itself)
> 
> commit 56138f50d1900b0c3d8647376e37b488b23ba53d
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Fri May 18 04:48:33 2012 +0000
> 
>     iwlwifi: dont pull too much payload in skb head
>     
>     As iwlwifi use fat skbs, it should not pull too much data in skb->head,
>     and particularly no tcp data payload, or splice() is slower, and TCP
>     coalescing is disabled. Copying payload to userland also involves at
>     least two copies (part from header, part from fragment)
>     
>     Each layer will pull its header from the fragment as needed.
>     
>     (on 64bit arches, skb_tailroom(skb) at this point is 192 bytes)
>     
>     With this patch applied, I have a major reduction of collapsed/pruned
>     TCP packets, a nice increase of TCPRcvCoalesce counter, and overall
>     better Internet User experience.
>     
>     Small packets are still using a fragless skb, so that page can be reused
>     by the driver.
>     

Will take a look, thanks.
By the way, this comment at build_skb:
* @frag_size: size of fragment, or 0 if head was kmalloced

is not very clear to me. Could you clarify what exactly size
of fragment means in this context?
