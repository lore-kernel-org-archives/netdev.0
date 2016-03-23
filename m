From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net v2] xfrm: Fix crash observed during device
 unregistration and decryption
Date: Wed, 23 Mar 2016 13:50:48 +0100
Message-ID: <20160323125048.GC3347@gauss.secunet.com>
References: <001c01d1849b$1c7c98e0$5575caa0$@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>,
	'Herbert Xu' <herbert@gondor.apana.org.au>,
	<jeromes@codeaurora.org>
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:41182 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932306AbcCWMu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2016 08:50:57 -0400
Content-Disposition: inline
In-Reply-To: <001c01d1849b$1c7c98e0$5575caa0$@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2016 at 06:29:48PM -0600, Subash Abhinov Kasiviswanathan wrote:
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

Looks good.

David, in case you want to take it directly into the net tree:

Acked-by: Steffen Klassert <steffen.klassert@secunet.com>
