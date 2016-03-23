From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] xfrm: Fix crash observed during device
 unregistration and decryption
Date: Wed, 23 Mar 2016 06:25:47 -0700
Message-ID: <1458739547.10868.37.camel@edumazet-glaptop3.roam.corp.google.com>
References: <001c01d1849b$1c7c98e0$5575caa0$@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Steffen Klassert' <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, 'Herbert Xu' <herbert@gondor.apana.org.au>,
	jeromes@codeaurora.org
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36253 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754988AbcCWN0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 09:26:37 -0400
Received: by mail-pf0-f177.google.com with SMTP id u190so28017888pfb.3
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 06:26:37 -0700 (PDT)
In-Reply-To: <001c01d1849b$1c7c98e0$5575caa0$@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-03-22 at 18:29 -0600, Subash Abhinov Kasiviswanathan wrote:
> A crash is observed when a decrypted packet is processed in receive
> path. get_rps_cpus() tries to dereference the skb->dev fields but it
> appears that the device is freed from the poison pattern.
> 
> [<ffffffc000af58ec>] get_rps_cpu+0x94/0x2f0
> [<ffffffc000af5f94>] netif_rx_internal+0x140/0x1cc
> [<ffffffc000af6094>] netif_rx+0x74/0x94
> [<ffffffc000bc0b6c>] xfrm_input+0x754/0x7d0
> [<ffffffc000bc0bf8>] xfrm_input_resume+0x10/0x1c
> [<ffffffc000ba6eb8>] esp_input_done+0x20/0x30
> [<ffffffc0000b64c8>] process_one_work+0x244/0x3fc
> [<ffffffc0000b7324>] worker_thread+0x2f8/0x418
> [<ffffffc0000bb40c>] kthread+0xe0/0xec
> 
> -013|get_rps_cpu(
>      |    dev = 0xFFFFFFC08B688000,
>      |    skb = 0xFFFFFFC0C76AAC00 -> (
>      |      dev = 0xFFFFFFC08B688000 -> (
>      |        name =
> "......................................................
>      |        name_hlist = (next = 0xAAAAAAAAAAAAAAAA, pprev =
> 0xAAAAAAAAAAA
> 
> Following are the sequence of events observed -
> 
> - Encrypted packet in receive path from netdevice is queued
> - Encrypted packet queued for decryption (asynchronous)
> - Netdevice brought down and freed
> - Packet is decrypted and returned through callback in esp_input_done
> - Packet is queued again for process in network stack using netif_rx
> 
> Since the device appears to have been freed, the dereference of
> skb->dev in get_rps_cpus() leads to an unhandled page fault
> exception.
> 
> Fix this by holding on to device reference when queueing packets
> asynchronously and releasing the reference on call back return.
> 
> v2: Make the change generic to xfrm as mentioned by Steffen and
> update the title to xfrm
> 
> Suggested-by: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Jerome Stanislaus <jeromes@codeaurora.org>
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> ---
>  net/xfrm/xfrm_input.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
> index ad7f5b3..1c4ad47 100644
> --- a/net/xfrm/xfrm_input.c
> +++ b/net/xfrm/xfrm_input.c
> @@ -292,12 +292,15 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32
> spi, int encap_type)
>  		XFRM_SKB_CB(skb)->seq.input.hi = seq_hi;
>  
>  		skb_dst_force(skb);
> +		dev_hold(skb->dev);
>  
>  		nexthdr = x->type->input(x, skb);
>  
>  		if (nexthdr == -EINPROGRESS)
>  			return 0;
>  resume:
> +		dev_put(skb->dev);
> +
>  		spin_lock(&x->lock);
>  		if (nexthdr <= 0) {
>  			if (nexthdr == -EBADMSG) {
> --
> 

Wont this prevent device from being dismantled ?

Where is this xfrm queue purged at device dismantle ?

dev_put() is probably missing, if you add a dev_hold() for every packet
in it.
