From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC net-next v3 4/7] net: use skb->csum_algo to identify
 packets needing crc32c
Date: Fri, 7 Apr 2017 08:43:51 -0700
Message-ID: <CALx6S34DdGZo7e1e37UCtpZ48jgdvHJ5nR=keyGFq3O3-b2_YQ@mail.gmail.com>
References: <cover.1491562390.git.dcaratti@redhat.com> <CALx6S34cSH+z+humkp5s7UHAqnafHHB-GTqobHyb-SfKNe+MiA@mail.gmail.com>
 <1b776a2f30504c01cbad6a9230840dd0e79ffc0c.1491562390.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        David Laight <David.Laight@aculab.com>,
        "David S . Miller" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "linux-sctp @ vger . kernel . org" <linux-sctp@vger.kernel.org>
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:36675 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755252AbdDGPnx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 11:43:53 -0400
Received: by mail-qt0-f196.google.com with SMTP id v3so1888750qtd.3
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 08:43:52 -0700 (PDT)
In-Reply-To: <1b776a2f30504c01cbad6a9230840dd0e79ffc0c.1491562390.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 7, 2017 at 7:16 AM, Davide Caratti <dcaratti@redhat.com> wrote:
> skb->csum_algo carries the indication on which algorithm is needed to
> compute checksum on skb in the transmit path, when skb->ip_summed is
> equal to CHECKSUM_PARTIAL. If skb carries a SCTP packet and crc32c
> hasn't been yet written in L4 header, skb->csum_algo is assigned to
> CRC32C_CHECKSUM. In any other case, skb->csum_algo is set to
> INTERNET_CHECKSUM.
>
> Suggested-by: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>
> ---
>  include/linux/skbuff.h                | 28 ++++++++++++++++++++--------
>  net/core/dev.c                        |  2 +-
>  net/netfilter/ipvs/ip_vs_proto_sctp.c |  2 +-
>  net/netfilter/nf_nat_proto_sctp.c     |  2 +-
>  net/sched/act_csum.c                  |  2 +-
>  net/sctp/offload.c                    |  2 +-
>  net/sctp/output.c                     |  3 ++-
>  7 files changed, 27 insertions(+), 14 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index aaf1072..527be47 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -189,12 +189,13 @@
>   *
>   *   NETIF_F_SCTP_CRC - This feature indicates that a device is capable of
>   *     offloading the SCTP CRC in a packet. To perform this offload the stack
> - *     will set ip_summed to CHECKSUM_PARTIAL and set csum_start and csum_offset
> - *     accordingly. Note the there is no indication in the skbuff that the
> - *     CHECKSUM_PARTIAL refers to an SCTP checksum, a driver that supports
> - *     both IP checksum offload and SCTP CRC offload must verify which offload
> - *     is configured for a packet presumably by inspecting packet headers; in
> - *     case, skb_crc32c_csum_help is provided to compute CRC on SCTP packets.
> + *     will set set csum_start and csum_offset accordingly, set ip_summed to
> + *     CHECKSUM_PARTIAL and set csum_algo to CRC32C_CHECKSUM, to provide an
> + *     indication in the skbuff that the CHECKSUM_PARTIAL refers to CRC32c.
> + *     A driver that supports both IP checksum offload and SCTP CRC32c offload
> + *     must verify which offload is configured for a packet by testing the
> + *     value of skb->csum_algo; skb_crc32c_csum_help is provided to resolve
> + *     CHECKSUM_PARTIAL on skbs where csum_algo is CRC32C_CHECKSUM.
>   *
>   *   NETIF_F_FCOE_CRC - This feature indicates that a device is capable of
>   *     offloading the FCOE CRC in a packet. To perform this offload the stack
> @@ -614,6 +615,7 @@ static inline bool skb_mstamp_after(const struct skb_mstamp *t1,
>   *     @wifi_acked_valid: wifi_acked was set
>   *     @wifi_acked: whether frame was acked on wifi or not
>   *     @no_fcs:  Request NIC to treat last 4 bytes as Ethernet FCS
> + *     @csum_algo: algorithm used to compute checksum
>   *     @dst_pending_confirm: need to confirm neighbour
>    *    @napi_id: id of the NAPI struct this skb came from
>   *     @secmark: security marking
> @@ -742,8 +744,10 @@ struct sk_buff {
>         __u8                    csum_valid:1;
>         __u8                    csum_complete_sw:1;
>         __u8                    csum_level:2;
> -       __u8                    __unused:1; /* one bit hole */
> -
> +       enum {
> +               INTERNET_CHECKSUM = 0,
> +               CRC32C_CHECKSUM,
> +       }                       csum_algo:1;

I am worried this opens the door to a new open ended functionality
that will be rarely used in practice. Checksum offload is pervasive,
CRC offload is still a very narrow use case. Adding yet more
CRC/checksum variants will need more bits. It may be sufficient for
now just to make this a single bit which indicates "ones' checksum" or
indicates "other". In this case of "other" we need some analysis so
determine which checksum it is, this might be something that flow
dissector could support.

>         __u8                    dst_pending_confirm:1;
>  #ifdef CONFIG_IPV6_NDISC_NODETYPE
>         __u8                    ndisc_nodetype:2;
> @@ -3129,6 +3133,14 @@ struct skb_checksum_ops {
>
>  extern const struct skb_checksum_ops *crc32c_csum_stub __read_mostly;
>
> +static inline void skb_set_crc32c_ipsummed(struct sk_buff *skb,
> +                                          const u8 ip_summed)
> +{
> +       skb->csum_algo = ip_summed == CHECKSUM_PARTIAL ? CRC32C_CHECKSUM :
> +               INTERNET_CHECKSUM;
> +       skb->ip_summed = ip_summed;

This seems odd to me. skb->csum_algo and skb->ip_summed always end up
having the same value.

> +}
> +
>  __wsum __skb_checksum(const struct sk_buff *skb, int offset, int len,
>                       __wsum csum, const struct skb_checksum_ops *ops);
>  __wsum skb_checksum(const struct sk_buff *skb, int offset, int len,
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 91ba01a..c6a4281 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2641,7 +2641,7 @@ int skb_crc32c_csum_help(struct sk_buff *skb)
>                         goto out;
>         }
>         *(__le32 *)(skb->data + offset) = crc32c_csum;
> -       skb->ip_summed = CHECKSUM_NONE;
> +       skb_set_crc32c_ipsummed(skb, CHECKSUM_NONE);
>  out:
>         return ret;
>  }
> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> index 56f8e4b..8800bf7 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> @@ -81,7 +81,7 @@ static void sctp_nat_csum(struct sk_buff *skb, sctp_sctphdr_t *sctph,
>                           unsigned int sctphoff)
>  {
>         sctph->checksum = sctp_compute_cksum(skb, sctphoff);
> -       skb->ip_summed = CHECKSUM_UNNECESSARY;
> +       skb_set_crc32c_ipsummed(skb, CHECKSUM_UNNECESSARY);

The old code is better. CHECKSUM_UNNECESSARY already applies to non IP
checksums. There is nothing special about crc32 in this regard and
skb->csum_algo should only be valid when skb->ip_summed ==
CHECKSUM_PARTIAL so no need to set it here. This point should also be
in documentation.

>  }
>
>  static int
> diff --git a/net/netfilter/nf_nat_proto_sctp.c b/net/netfilter/nf_nat_proto_sctp.c
> index 804e8a0..82a7c4c 100644
> --- a/net/netfilter/nf_nat_proto_sctp.c
> +++ b/net/netfilter/nf_nat_proto_sctp.c
> @@ -60,7 +60,7 @@ sctp_manip_pkt(struct sk_buff *skb,
>
>         if (skb->ip_summed != CHECKSUM_PARTIAL) {
>                 hdr->checksum = sctp_compute_cksum(skb, hdroff);
> -               skb->ip_summed = CHECKSUM_NONE;
> +               skb_set_crc32c_ipsummed(skb, CHECKSUM_NONE);
>         }
>
>         return true;
> diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
> index 6c319a4..6e7e862 100644
> --- a/net/sched/act_csum.c
> +++ b/net/sched/act_csum.c
> @@ -349,7 +349,7 @@ static int tcf_csum_sctp(struct sk_buff *skb, unsigned int ihl,
>
>         sctph->checksum = sctp_compute_cksum(skb,
>                                              skb_network_offset(skb) + ihl);
> -       skb->ip_summed = CHECKSUM_NONE;
> +       skb_set_crc32c_ipsummed(skb, CHECKSUM_NONE);
>
>         return 1;
>  }
> diff --git a/net/sctp/offload.c b/net/sctp/offload.c
> index 378f462..4b98339 100644
> --- a/net/sctp/offload.c
> +++ b/net/sctp/offload.c
> @@ -34,7 +34,7 @@
>
>  static __le32 sctp_gso_make_checksum(struct sk_buff *skb)
>  {
> -       skb->ip_summed = CHECKSUM_NONE;
> +       skb_set_crc32c_ipsummed(skb, CHECKSUM_NONE);
>         return sctp_compute_cksum(skb, skb_transport_offset(skb));
>  }
>
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 1224421..386cbd8 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -524,10 +524,11 @@ static int sctp_packet_pack(struct sctp_packet *packet,
>                 struct sctphdr *sh =
>                         (struct sctphdr *)skb_transport_header(head);
>
> +               skb_set_crc32c_ipsummed(head, CHECKSUM_NONE);
>                 sh->checksum = sctp_compute_cksum(head, 0);
>         } else {
>  chksum:
> -               head->ip_summed = CHECKSUM_PARTIAL;
> +               skb_set_crc32c_ipsummed(head, CHECKSUM_PARTIAL);
>                 head->csum_start = skb_transport_header(head) - head->head;
>                 head->csum_offset = offsetof(struct sctphdr, checksum);
>         }
> --
> 2.7.4
>
