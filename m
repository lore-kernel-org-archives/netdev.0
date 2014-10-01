From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next v3 20/29] fm10k: Add support for netdev offloads
Date: Wed, 1 Oct 2014 11:31:23 +0300
Message-ID: <CAJ3xEMhv-cS+vShPjTvOuWP182wf=zubNU=_p08DSkNv9W2C-w@mail.gmail.com>
References: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1411471017-28213-21-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Tom Herbert <therbert@google.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:50726 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbaJAIbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 04:31:23 -0400
Received: by mail-ob0-f171.google.com with SMTP id va2so256206obc.30
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 01:31:23 -0700 (PDT)
In-Reply-To: <1411471017-28213-21-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2014 at 2:16 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> This patch adds support for basic offloads including TSO, Tx checksum, Rx
> checksum, Rx hash, and the same features applied to VXLAN/NVGRE tunnels.

> --- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
> +++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
[...]
> +#define VXLAN_HLEN (sizeof(struct udphdr) + 8)
> +static struct ethhdr *fm10k_port_is_vxlan(struct sk_buff *skb)
> +{
> +       struct fm10k_intfc *interface = netdev_priv(skb->dev);
> +       struct fm10k_vxlan_port *vxlan_port;
> +
> +       /* we can only offload a vxlan if we recognize it as such */
> +       vxlan_port = list_first_entry_or_null(&interface->vxlan_port,
> +                                             struct fm10k_vxlan_port, list);
> +
> +       if (!vxlan_port)
> +               return NULL;
> +       if (vxlan_port->port != udp_hdr(skb)->dest)
> +               return NULL;
> +
> +       /* return offset of udp_hdr plus 8 bytes for VXLAN header */
> +       return (struct ethhdr *)(skb_transport_header(skb) + VXLAN_HLEN);
> +}
> +
> +#define FM10K_NVGRE_RESERVED0_FLAGS htons(0x9FFF)
> +#define NVGRE_TNI htons(0x2000)
> +struct fm10k_nvgre_hdr {
> +       __be16 flags;
> +       __be16 proto;
> +       __be32 tni;
> +};
> +
> +static struct ethhdr *fm10k_gre_is_nvgre(struct sk_buff *skb)
> +{
> +       struct fm10k_nvgre_hdr *nvgre_hdr;
> +       int hlen = ip_hdrlen(skb);
> +
> +       /* currently only IPv4 is supported due to hlen above */
> +       if (vlan_get_protocol(skb) != htons(ETH_P_IP))
> +               return NULL;
> +
> +       /* our transport header should be NVGRE */
> +       nvgre_hdr = (struct fm10k_nvgre_hdr *)(skb_network_header(skb) + hlen);
> +
> +       /* verify all reserved flags are 0 */
> +       if (nvgre_hdr->flags & FM10K_NVGRE_RESERVED0_FLAGS)
> +               return NULL;
> +
> +       /* verify protocol is transparent Ethernet bridging */
> +       if (nvgre_hdr->proto != htons(ETH_P_TEB))
> +               return NULL;
> +
> +       /* report start of ethernet header */
> +       if (nvgre_hdr->flags & NVGRE_TNI)
> +               return (struct ethhdr *)(nvgre_hdr + 1);
> +
> +       return (struct ethhdr *)(&nvgre_hdr->tni);
> +}

this helper is fully generic, should reside elsewhere in the stack


> +
> +static __be16 fm10k_tx_encap_offload(struct sk_buff *skb)
> +{
> +       struct ethhdr *eth_hdr;
> +       u8 l4_hdr = 0;
> +
> +       switch (vlan_get_protocol(skb)) {
> +       case htons(ETH_P_IP):
> +               l4_hdr = ip_hdr(skb)->protocol;
> +               break;
> +       case htons(ETH_P_IPV6):
> +               l4_hdr = ipv6_hdr(skb)->nexthdr;
> +               break;
> +       default:
> +               return 0;
> +       }
> +
> +       switch (l4_hdr) {
> +       case IPPROTO_UDP:
> +               eth_hdr = fm10k_port_is_vxlan(skb);
> +               break;
> +       case IPPROTO_GRE:
> +               eth_hdr = fm10k_gre_is_nvgre(skb);
> +               break;
> +       default:
> +               return 0;
> +       }
> +
> +       if (!eth_hdr)
> +               return 0;
> +
> +       switch (eth_hdr->h_proto) {
> +       case htons(ETH_P_IP):
> +       case htons(ETH_P_IPV6):
> +               break;
> +       default:
> +               return 0;
> +       }
> +
> +       return eth_hdr->h_proto;
> +}
> +
> +static int fm10k_tso(struct fm10k_ring *tx_ring,
> +                    struct fm10k_tx_buffer *first)
> +{
> +       struct sk_buff *skb = first->skb;
> +       struct fm10k_tx_desc *tx_desc;
> +       unsigned char *th;
> +       u8 hdrlen;
> +
> +       if (skb->ip_summed != CHECKSUM_PARTIAL)
> +               return 0;
> +
> +       if (!skb_is_gso(skb))
> +               return 0;
> +
> +       /* compute header lengths */
> +       if (skb->encapsulation) {
> +               if (!fm10k_tx_encap_offload(skb))
> +                       goto err_vxlan;
> +               th = skb_inner_transport_header(skb);
> +       } else {
> +               th = skb_transport_header(skb);
> +       }
> +
> +       /* compute offset from SOF to transport header and add header len */
> +       hdrlen = (th - skb->data) + (((struct tcphdr *)th)->doff << 2);
> +
> +       first->tx_flags |= FM10K_TX_FLAGS_CSUM;
> +
> +       /* update gso size and bytecount with header size */
> +       first->gso_segs = skb_shinfo(skb)->gso_segs;
> +       first->bytecount += (first->gso_segs - 1) * hdrlen;
> +
> +       /* populate Tx descriptor header size and mss */
> +       tx_desc = FM10K_TX_DESC(tx_ring, tx_ring->next_to_use);
> +       tx_desc->hdrlen = hdrlen;
> +       tx_desc->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
> +
> +       return 1;
> +err_vxlan:
> +       tx_ring->netdev->features &= ~NETIF_F_GSO_UDP_TUNNEL;
> +       if (!net_ratelimit())
> +               netdev_err(tx_ring->netdev,
> +                          "TSO requested for unsupported tunnel, disabling offload\n");
> +       return -1;
> +}

why? if TSO was requested for some packet the driver can't do, you disable GSO
for udp tunnels for any future packets too? maybe just disable it
permanently  till you
feel safer to run under the current stack?


[...]

> @@ -732,6 +1024,7 @@ netdev_tx_t fm10k_xmit_frame_ring(struct sk_buff *skb,
>                                   struct fm10k_ring *tx_ring)
>  {
>         struct fm10k_tx_buffer *first;
> +       int tso;
>         u32 tx_flags = 0;
>  #if PAGE_SIZE > FM10K_MAX_DATA_PER_TXD
>         unsigned short f;
> @@ -763,11 +1056,23 @@ netdev_tx_t fm10k_xmit_frame_ring(struct sk_buff *skb,
>         /* record initial flags and protocol */
>         first->tx_flags = tx_flags;
>
> +       tso = fm10k_tso(tx_ring, first);
> +       if (tso < 0)
> +               goto out_drop;
> +       else if (!tso)
> +               fm10k_tx_csum(tx_ring, first);
> +
>         fm10k_tx_map(tx_ring, first);
>
>         fm10k_maybe_stop_tx(tx_ring, DESC_NEEDED);
>
>         return NETDEV_TX_OK;
> +
> +out_drop:
> +       dev_kfree_skb_any(first->skb);
> +       first->skb = NULL;
> +
> +       return NETDEV_TX_OK;
>  }
