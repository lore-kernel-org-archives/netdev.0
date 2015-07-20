From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] macvtap: fix network header pointer for VLAN tagged
 pkts
Date: Mon, 20 Jul 2015 12:42:42 -0400
Message-ID: <55AD2502.5060203@gmail.com>
References: <1437407061-8698-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:34393 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752884AbbGTQmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 12:42:45 -0400
Received: by qgeu79 with SMTP id u79so19445929qge.1
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 09:42:45 -0700 (PDT)
In-Reply-To: <1437407061-8698-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/2015 11:44 AM, Ivan Vecera wrote:
> Network header is set with offset ETH_HLEN but it is not true for VLAN
> (multiple-)tagged and results in checksum issues in lower devices.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> ---
>  drivers/net/macvtap.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 3b933bb..cdcbab4 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -796,6 +796,12 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
>  	skb_reset_mac_header(skb);
>  	skb->protocol = eth_hdr(skb)->h_proto;
>  
> +	if (skb_vlan_tagged(skb)) {
> +		int depth;
> +		skb->protocol = __vlan_get_protocol(skb, skb->protocol, &depth);

I don't think this is right.  This would reset the protocol to the encapsulated
protocol which isn't really the case since you are not really stripping vlan
encapsulations.

-vlad

> +		skb_set_network_header(skb, depth);
> +	}
> +
>  	if (vnet_hdr_len) {
>  		err = macvtap_skb_from_vnet_hdr(q, skb, &vnet_hdr);
>  		if (err)
> 
