From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH net v2] macvtap: fix network header pointer for VLAN tagged
 pkts
Date: Tue, 21 Jul 2015 23:44:58 +0900
Message-ID: <55AE5AEA.5010802@gmail.com>
References: <1437463115-2881-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com
To: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36349 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932067AbbGUOpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 10:45:03 -0400
Received: by pachj5 with SMTP id hj5so121623064pac.3
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 07:45:02 -0700 (PDT)
In-Reply-To: <1437463115-2881-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/07/21 (火) 16:18, Ivan Vecera wrote:
> Network header is set with offset ETH_HLEN but it is not true for VLAN
> (multiple-)tagged and results in checksum issues in lower devices.
> 
> v2: leave skb->protocol untouched (thx Vlad), comment added
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> ---
>   drivers/net/macvtap.c | 7 +++++++
>   1 file changed, 7 insertions(+)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 3b933bb..b75776b 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -796,6 +796,13 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
>   	skb_reset_mac_header(skb);
>   	skb->protocol = eth_hdr(skb)->h_proto;
>   
> +	/* Move network header to the right position for VLAN tagged packets */
> +	if (skb_vlan_tagged(skb)) {

I guess you don't need the condition skb_vlan_tag_present(skb), i.e.,

if (skb->protocol == htons(ETH_P_8021Q) ||
    skb->protocol == htons(ETH_P_8021AD))

> +		int depth;
> +		__vlan_get_protocol(skb, skb->protocol, &depth);

__vlan_get_protocol() can fail, and then, depth will not be initialized.

> +		skb_set_network_header(skb, depth);

I think you should set network_header after
skb_probe_transport_header(). It calls skb_flow_dissect_flow_keys(),
which seems to expect network_header to be ETH_HLEN.

Toshiaki Makita
