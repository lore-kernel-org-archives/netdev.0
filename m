From: Eric Wheeler <netdev@lists.ewheeler.net>
Subject: Re: [PATCH net] bna: page allocation during interrupts to use a
 mempool.
Date: Tue, 7 Oct 2014 17:48:59 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1410071746230.3503@ware.dreamhost.com>
References: <alpine.DEB.2.00.1409271631530.26069@ware.dreamhost.com>   <20140929092833.6c2cb7e9@urahara>   <262CB373A6D1F14F9B81E82F74F77D5A4704FAE7@avmb2.qlogic.org>   <alpine.DEB.2.00.1410061850120.5129@ware.dreamhost.com>
 <1412646735.11091.93.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.DEB.2.00.1410061956410.7392@ware.dreamhost.com> <1412651746.11091.98.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	Rasesh Mody <rasesh.mody@qlogic.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from homie.mail.dreamhost.com ([208.97.132.208]:49698 "EHLO
	homiemail-a99.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755732AbaJHAd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 20:33:28 -0400
In-Reply-To: <1412651746.11091.98.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 6 Oct 2014, Eric Dumazet wrote:
> On Mon, 2014-10-06 at 20:05 -0700, Eric Wheeler wrote:
>> On Mon, 6 Oct 2014, Eric Dumazet wrote:
>>> On Mon, 2014-10-06 at 18:57 -0700, Eric Wheeler wrote:
>>>> This patch fixes an order:2 memory allocation error backtrace by
>>>> guaranteeing that memory is available during simultaneous high memory
>>>> pressure and packet rates when using 9k jumbo frames.
>>>
>>> This is highly suspect to me.
>>> Most likely yet another truesize lie.
>>> At a first glance, bnad_cq_setup_skb_frags() is buggy here :
>>> skb->truesize += totlen;
>
> It seems many drivers make this assumption that a frame of 1000 bytes
> consumes 1000 bytes of memory.
>
> Reality is that driver allocated more memory, because it can not predict
> how many bytes are going to be received from the network.
>
> By lying on skb->truesize (underestimating real memory cost), this
> prevents networking stack making appropriate memory checks.
>
> Here, it seems clear to me the following fix is needed, at very minimum.
>
> And it might be that something better is needed :  MTU=9000 might force
> the driver to allocate 16384 bytes per frame, not 9018
>
> So it is possible that unmap->vector.len needs to be changed to the real
> size of memory region (for example : PAGE_SIZE << 2)

Just += unmap->vector.len still did not work (same backtrace), so I've 
rebuilt with PAGE_SIZE<<2 and so far so good.  I'll let it run all night 
and see if we get any problems.

-Eric

--
Eric Wheeler, President           eWheeler, Inc. dba Global Linux Security
888-LINUX26 (888-546-8926)        Fax: 503-716-3878           PO Box 25107
www.GlobalLinuxSecurity.pro       Linux since 1996!     Portland, OR 97298

>
>
> diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
> index ffc92a41d75be550d27698af6ca3e600d9a146fe..ce867219e2ceaf33b17595b67bae99e964d5a6b6 100644
> --- a/drivers/net/ethernet/brocade/bna/bnad.c
> +++ b/drivers/net/ethernet/brocade/bna/bnad.c
> @@ -550,6 +550,7 @@ bnad_cq_setup_skb_frags(struct bna_rcb *rcb, struct sk_buff *skb,
> 				dma_unmap_addr(&unmap->vector, dma_addr),
> 				unmap->vector.len, DMA_FROM_DEVICE);
>
> +		skb->truesize += unmap->vector.len;
> 		len = (vec == nvecs) ?
> 			last_fraglen : unmap->vector.len;
> 		totlen += len;
> @@ -563,7 +564,6 @@ bnad_cq_setup_skb_frags(struct bna_rcb *rcb, struct sk_buff *skb,
>
> 	skb->len += totlen;
> 	skb->data_len += totlen;
> -	skb->truesize += totlen;
> }
>
> static inline void
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
