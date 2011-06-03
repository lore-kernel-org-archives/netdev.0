From: padmanabh ratnakar <pratnakarlx@gmail.com>
Subject: Re: [PATCH] vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check v2
Date: Fri, 3 Jun 2011 09:04:12 +0530
Message-ID: <BANLkTikjdz+LkavRiuqdDNS6+djAer-a0A@mail.gmail.com>
References: <m1aaectyed.fsf@fess.ebiederm.org>
	<20110524.022406.2228892895515155850.davem@davemloft.net>
	<m1oc2spmyt.fsf@fess.ebiederm.org>
	<20110601.205940.1179055860757569997.davem@davemloft.net>
	<m11uzcidvq.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, greearb@candelatech.com,
	nicolas.2p.debian@gmail.com, jpirko@redhat.com, xiaosuo@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:48153 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701Ab1FCDeM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 23:34:12 -0400
Received: by pvg12 with SMTP id 12so675998pvg.19
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2011 20:34:12 -0700 (PDT)
In-Reply-To: <m11uzcidvq.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Doesnt __vlan_put_tag()/vlan_insert_tag() depend on skb->data pointing
to ethernet header.
Is'nt the skb->data pointing past ethernet header in netif_receive_skb(=
).
Am I missing anything?
Regards,
Padmanabh


On Thu, Jun 2, 2011 at 6:33 PM, Eric W. Biederman <ebiederm@xmission.co=
m> wrote:
>
> Testing of VLAN_FLAG_REORDER_HDR does not belong in vlan_untag
> but rather in vlan_do_receive. =A0Otherwise the vlan header
> will not be properly put on the packet in the case of
> vlan header accelleration.
>
> As we remove the check from vlan_check_reorder_header
> rename it vlan_reorder_header to keep the naming clean.
>
> Fix up the skb->pkt_type early so we don't look at the packet
> after adding the vlan tag, which guarantees we don't goof
> and look at the wrong field.
>
> Use a simple if statement instead of a complicated switch
> statement to decided that we need to increment rx_stats
> for a multicast packet.
>
> Hopefully at somepoint we will just declare the case where
> VLAN_FLAG_REORDER_HDR is cleared as unsupported and remove
> the code. =A0Until then this keeps it working correctly.
>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
> =A0include/linux/if_vlan.h | =A0 25 ++++++++++++++++++++--
> =A0net/8021q/vlan_core.c =A0 | =A0 50 ++++++++++++++++++++++---------=
---------------
> =A02 files changed, 46 insertions(+), 29 deletions(-)
>
> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index 290bd8a..821f0e3 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -220,7 +220,7 @@ static inline int vlan_hwaccel_receive_skb(struct=
 sk_buff *skb,
> =A0}
>
> =A0/**
> - * __vlan_put_tag - regular VLAN tag inserting
> + * vlan_insert_tag - regular VLAN tag inserting
> =A0* @skb: skbuff to tag
> =A0* @vlan_tci: VLAN TCI to insert
> =A0*
> @@ -229,8 +229,10 @@ static inline int vlan_hwaccel_receive_skb(struc=
t sk_buff *skb,
> =A0*
> =A0* Following the skb_unshare() example, in case of error, the calli=
ng function
> =A0* doesn't have to worry about freeing the original skb.
> + *
> + * Does not change skb->protocol so this function can be used during=
 receive.
> =A0*/
> -static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, u1=
6 vlan_tci)
> +static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb, u=
16 vlan_tci)
> =A0{
> =A0 =A0 =A0 =A0struct vlan_ethhdr *veth;
>
> @@ -250,8 +252,25 @@ static inline struct sk_buff *__vlan_put_tag(str=
uct sk_buff *skb, u16 vlan_tci)
> =A0 =A0 =A0 =A0/* now, the TCI */
> =A0 =A0 =A0 =A0veth->h_vlan_TCI =3D htons(vlan_tci);
>
> - =A0 =A0 =A0 skb->protocol =3D htons(ETH_P_8021Q);
> + =A0 =A0 =A0 return skb;
> +}
>
> +/**
> + * __vlan_put_tag - regular VLAN tag inserting
> + * @skb: skbuff to tag
> + * @vlan_tci: VLAN TCI to insert
> + *
> + * Inserts the VLAN tag into @skb as part of the payload
> + * Returns a VLAN tagged skb. If a new skb is created, @skb is freed=
=2E
> + *
> + * Following the skb_unshare() example, in case of error, the callin=
g function
> + * doesn't have to worry about freeing the original skb.
> + */
> +static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, u1=
6 vlan_tci)
> +{
> + =A0 =A0 =A0 skb =3D vlan_insert_tag(skb, vlan_tci);
> + =A0 =A0 =A0 if (skb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->protocol =3D htons(ETH_P_8021Q);
> =A0 =A0 =A0 =A0return skb;
> =A0}
>
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index 41495dc..735c818 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -23,6 +23,20 @@ bool vlan_do_receive(struct sk_buff **skbp)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>
> =A0 =A0 =A0 =A0skb->dev =3D vlan_dev;
> + =A0 =A0 =A0 if (skb->pkt_type =3D=3D PACKET_OTHERHOST) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Our lower layer thinks this is not l=
ocal, let's make sure.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This allows the VLAN to have a dif=
ferent MAC than the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* underlying device, and still route=
 correctly. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!compare_ether_addr(eth_hdr(skb)->h=
_dest,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 vlan_dev->dev_addr))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->pkt_type =3D PACKE=
T_HOST;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (unlikely(!(vlan_dev_info(vlan_dev)->flags & VLAN_FL=
AG_REORDER_HDR))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D *skbp =3D vlan_insert_tag(skb, =
skb->vlan_tci);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!skb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0skb->priority =3D vlan_get_ingress_priority(vlan_dev, =
skb->vlan_tci);
> =A0 =A0 =A0 =A0skb->vlan_tci =3D 0;
>
> @@ -31,22 +45,8 @@ bool vlan_do_receive(struct sk_buff **skbp)
> =A0 =A0 =A0 =A0u64_stats_update_begin(&rx_stats->syncp);
> =A0 =A0 =A0 =A0rx_stats->rx_packets++;
> =A0 =A0 =A0 =A0rx_stats->rx_bytes +=3D skb->len;
> -
> - =A0 =A0 =A0 switch (skb->pkt_type) {
> - =A0 =A0 =A0 case PACKET_BROADCAST:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 case PACKET_MULTICAST:
> + =A0 =A0 =A0 if (skb->pkt_type =3D=3D PACKET_MULTICAST)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rx_stats->rx_multicast++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 case PACKET_OTHERHOST:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Our lower layer thinks this is not l=
ocal, let's make sure.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This allows the VLAN to have a dif=
ferent MAC than the
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* underlying device, and still route=
 correctly. */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!compare_ether_addr(eth_hdr(skb)->h=
_dest,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 vlan_dev->dev_addr))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->pkt_type =3D PACKE=
T_HOST;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0u64_stats_update_end(&rx_stats->syncp);
>
> =A0 =A0 =A0 =A0return true;
> @@ -89,17 +89,15 @@ gro_result_t vlan_gro_frags(struct napi_struct *n=
api, struct vlan_group *grp,
> =A0}
> =A0EXPORT_SYMBOL(vlan_gro_frags);
>
> -static struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb=
)
> +static struct sk_buff *vlan_reorder_header(struct sk_buff *skb)
> =A0{
> - =A0 =A0 =A0 if (vlan_dev_info(skb->dev)->flags & VLAN_FLAG_REORDER_=
HDR) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb_cow(skb, skb_headroom(skb)) < 0=
)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Lifted from Gleb's V=
LAN code... */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memmove(skb->data - ETH=
_HLEN,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->da=
ta - VLAN_ETH_HLEN, 12);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->mac_header +=3D VL=
AN_HLEN;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (skb_cow(skb, skb_headroom(skb)) < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D NULL;
> + =A0 =A0 =A0 if (skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Lifted from Gleb's VLAN code... */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memmove(skb->data - ETH_HLEN,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->data - VLAN_ETH_HL=
EN, 12);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->mac_header +=3D VLAN_HLEN;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return skb;
> =A0}
> @@ -161,7 +159,7 @@ struct sk_buff *vlan_untag(struct sk_buff *skb)
> =A0 =A0 =A0 =A0skb_pull_rcsum(skb, VLAN_HLEN);
> =A0 =A0 =A0 =A0vlan_set_encap_proto(skb, vhdr);
>
> - =A0 =A0 =A0 skb =3D vlan_check_reorder_header(skb);
> + =A0 =A0 =A0 skb =3D vlan_reorder_header(skb);
> =A0 =A0 =A0 =A0if (unlikely(!skb))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_free;
>
> --
> 1.7.5.1.217.g4e3aa
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
