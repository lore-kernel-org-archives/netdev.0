From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next v4 07/16] i40e: Rx checksum offload for VXLAN
Date: Thu, 2 Jan 2014 12:20:54 +0200
Message-ID: <CAJZOPZ+XpHNcMdOKYpALvUXq5-yYuxcwAqG2AEe4DU=d=VGPtg@mail.gmail.com>
References: <1388200940-9113-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1388200940-9113-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:62665 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbaABKUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 05:20:54 -0500
Received: by mail-pb0-f50.google.com with SMTP id rr13so14243302pbb.23
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 02:20:54 -0800 (PST)
In-Reply-To: <1388200940-9113-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 28, 2013 at 5:22 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Joseph Gasparakis <joseph.gasparakis@intel.com>
>
> This implements receive offload for VXLAN for i40e.  The hardware
> supports checksum offload/verification of the inner/outer header.
>
> Change-Id: I450db300af6713f2044fef1191a0d1d294c13369
> Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e.h      |  1 +
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c | 57 ++++++++++++++++++++++++++---
>  drivers/net/ethernet/intel/i40e/i40e_type.h | 51 ++++++++++++++------------
>  3 files changed, 81 insertions(+), 28 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
> index 6f1edc1..34a54e7 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e.h
> @@ -29,6 +29,7 @@
>  #define _I40E_H_
>
>  #include <net/tcp.h>
> +#include <net/udp.h>
>  #include <linux/init.h>
>  #include <linux/types.h>
>  #include <linux/errno.h>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> index 01d0334..a978451 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> @@ -860,12 +860,25 @@ static void i40e_receive_skb(struct i40e_ring *rx_ring,
>   * @skb: skb currently being received and modified
>   * @rx_status: status value of last descriptor in packet
>   * @rx_error: error value of last descriptor in packet
> + * @rx_ptype: ptype value of last descriptor in packet
>   **/
>  static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
>                                     struct sk_buff *skb,
>                                     u32 rx_status,
> -                                   u32 rx_error)
> +                                   u32 rx_error,
> +                                   u16 rx_ptype)
>  {
> +       bool ipv4_tunnel, ipv6_tunnel;
> +       __wsum rx_udp_csum;
> +       __sum16 csum;
> +       struct iphdr *iph;
> +
> +       ipv4_tunnel = (rx_ptype > I40E_RX_PTYPE_GRENAT4_MAC_PAY3) &&
> +                     (rx_ptype < I40E_RX_PTYPE_GRENAT4_MACVLAN_IPV6_ICMP_PAY4);
> +       ipv6_tunnel = (rx_ptype > I40E_RX_PTYPE_GRENAT6_MAC_PAY3) &&
> +                     (rx_ptype < I40E_RX_PTYPE_GRENAT6_MACVLAN_IPV6_ICMP_PAY4);
> +
> +       skb->encapsulation = ipv4_tunnel || ipv6_tunnel;
>         skb->ip_summed = CHECKSUM_NONE;
>
>         /* Rx csum enabled and ip headers found? */
> @@ -873,13 +886,43 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
>               rx_status & (1 << I40E_RX_DESC_STATUS_L3L4P_SHIFT)))
>                 return;
>
> -       /* IP or L4 checksum error */
> +       /* IP or L4 or outmost IP checksum error */
>         if (rx_error & ((1 << I40E_RX_DESC_ERROR_IPE_SHIFT) |
> -                       (1 << I40E_RX_DESC_ERROR_L4E_SHIFT))) {
> +                       (1 << I40E_RX_DESC_ERROR_L4E_SHIFT) |
> +                       (1 << I40E_RX_DESC_ERROR_EIPE_SHIFT))) {
>                 vsi->back->hw_csum_rx_error++;
>                 return;
>         }
>
> +       if (ipv4_tunnel &&
> +           !(rx_status & (1 << I40E_RX_DESC_STATUS_UDP_0_SHIFT))) {
> +               /* If VXLAN traffic has an outer UDPv4 checksum we need to check
> +                * it in the driver, hardware does not do it for us.
> +                * Since L3L4P bit was set we assume a valid IHL value (>=5)
> +                * so the total length of IPv4 header is IHL*4 bytes
> +                */

The comment says that the driver has to compute the udp checksum
**if** the packet has an outer udp checksum,
but the driver call to issue checksumming is done unconditionally

> +               skb->transport_header = skb->mac_header +
> +                                       sizeof(struct ethhdr) +
> +                                       (ip_hdr(skb)->ihl * 4);
> +
> +               /* Add 4 bytes for VLAN tagged packets */
> +               skb->transport_header += (skb->protocol == htons(ETH_P_8021Q) ||
> +                                         skb->protocol == htons(ETH_P_8021AD))
> +                                         ? VLAN_HLEN : 0;
> +
> +               rx_udp_csum = udp_csum(skb);
> +               iph = ip_hdr(skb);
> +               csum = csum_tcpudp_magic(
> +                               iph->saddr, iph->daddr,
> +                               (skb->len - skb_transport_offset(skb)),
> +                               IPPROTO_UDP, rx_udp_csum);
> +
> +               if (udp_hdr(skb)->check != csum) {
> +                       vsi->back->hw_csum_rx_error++;
> +                       return;
> +               }
> +       }
> +
>         skb->ip_summed = CHECKSUM_UNNECESSARY;
>  }

Commit 0afb1666fe4 "vxlan: Add capability of Rx checksum offload for
inner packet" dictates that
the driver is expected to set the skb->encapsulation bit, this is
missing here, and indeed in vxlan_udp_encap_recv
your setting of ip_summed will be ignored and over-rided with
CHECKSUM_NONE, agree?
