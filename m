From: Tom Herbert <therbert@google.com>
Subject: Re: [net v2 2/3] i40e: Fix Rx checksum error counter
Date: Tue, 6 Jan 2015 21:43:57 -0800
Message-ID: <CA+mtBx-VgUCCxnkayoqR6AwYXu_mfzbtGZzH+oeT3wrOznzWGg@mail.gmail.com>
References: <1420594317-6191-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1420594317-6191-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Anjali Singhai <anjali.singhai@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:51770 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870AbbAGFn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 00:43:58 -0500
Received: by mail-ie0-f177.google.com with SMTP id rd18so1949798iec.8
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 21:43:58 -0800 (PST)
In-Reply-To: <1420594317-6191-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 6, 2015 at 5:31 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Anjali Singhai <anjali.singhai@intel.com>
>
> The Rx port checksum error counter was incrementing incorrectly with
> UDP encapsulated tunneled traffic.  This patch fixes the problem so that
> the port_rx_csum counter will show accurate statistics.
>
> Signed-off-by: Anjali Singhai <anjali.singhai@intel.com>
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Tested-by: Jim Young <james.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c | 24 +++++++++++++-----------
>  1 file changed, 13 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> index f145aaf..38c7638 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> @@ -1325,9 +1325,7 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
>          * so the total length of IPv4 header is IHL*4 bytes
>          * The UDP_0 bit *may* bet set if the *inner* header is UDP
>          */
> -       if (ipv4_tunnel &&
> -           (decoded.inner_prot != I40E_RX_PTYPE_INNER_PROT_UDP) &&
> -           !(rx_status & (1 << I40E_RX_DESC_STATUS_UDP_0_SHIFT))) {
> +       if (ipv4_tunnel) {
>                 skb->transport_header = skb->mac_header +
>                                         sizeof(struct ethhdr) +
>                                         (ip_hdr(skb)->ihl * 4);
> @@ -1337,15 +1335,19 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
>                                           skb->protocol == htons(ETH_P_8021AD))
>                                           ? VLAN_HLEN : 0;
>
> -               rx_udp_csum = udp_csum(skb);
> -               iph = ip_hdr(skb);
> -               csum = csum_tcpudp_magic(
> -                               iph->saddr, iph->daddr,
> -                               (skb->len - skb_transport_offset(skb)),
> -                               IPPROTO_UDP, rx_udp_csum);
> +               if ((ip_hdr(skb)->protocol == IPPROTO_UDP) &&
> +                   (udp_hdr(skb)->check != 0)) {
> +                       rx_udp_csum = udp_csum(skb);

Doesn't this compute the whole checksum of the packet making the fact
that device verified inner checksum pretty much irrelevant? It would
probably be just as well to return CHECKSUM_NONE and let the stack
deal with it and remove all this complexity.

> +                       iph = ip_hdr(skb);
> +                       csum = csum_tcpudp_magic(
> +                                       iph->saddr, iph->daddr,
> +                                       (skb->len - skb_transport_offset(skb)),
> +                                       IPPROTO_UDP, rx_udp_csum);
>
> -               if (udp_hdr(skb)->check != csum)
> -                       goto checksum_fail;
> +                       if (udp_hdr(skb)->check != csum)
> +                               goto checksum_fail;
> +
> +               } /* else its GRE and so no outer UDP header */
>         }
>
>         skb->ip_summed = CHECKSUM_UNNECESSARY;
> --
> 1.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
