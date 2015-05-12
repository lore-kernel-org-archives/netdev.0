From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] xen-netfront: reset skb transport header before checksum
Date: Mon, 11 May 2015 18:51:33 -0700
Message-ID: <1431395493.566.54.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150512013424.GA7960@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	davem@davemloft.net, david.vrabel@citrix.com,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	wei.liu2@citrix.com, paul.durrant@citrix.com
To: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:34672 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021AbbELBvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 21:51:35 -0400
Received: by iedfl3 with SMTP id fl3so139596924ied.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 18:51:35 -0700 (PDT)
In-Reply-To: <20150512013424.GA7960@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-11 at 18:34 -0700, Venkat Venkatsubra wrote:
> In ed1f50c3a ("net: add skb_checksum_setup") some checksum functions
> were introduced in core. Subsequent change b5cf66cd1 ("xen-netfront:
> use new skb_checksum_setup function") made use of those functions to
> replace its own implementation. With that change ip_hdr() and tcp_hdr()
> were not pointing at the right place. d554f73df ("xen-netfront: reset
> skb network header before checksum") fixed the ip_hdr().
> 
> This patch fixes tcp_hdr().
> 
> We saw this problem when LRO was enabled on the host and it results in
> netfront setting skb->ip_summed to CHECKSUM_UNNECESSARY.
> 
> Signed-off-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
> ---
>  drivers/net/xen-netfront.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 3f45afd..ed5c242 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -889,6 +889,7 @@ static int handle_incoming_queue(struct netfront_queue *queue,
>  		/* Ethernet work: Delayed to here as it peeks the header. */
>  		skb->protocol = eth_type_trans(skb, queue->info->netdev);
>  		skb_reset_network_header(skb);
> +		skb_set_transport_header(skb, ip_hdrlen(skb));
>  
>  		if (checksum_setup(queue->info->netdev, skb)) {
>  			kfree_skb(skb);

This looks bogus for IPv6.

I would rather fix skb_checksum_setup_ip() and
skb_checksum_setup_ipv6(), since you already use correctly
skb_maybe_pull_tail() there.

In general, setting network and transport header at this point seems
extra work.
