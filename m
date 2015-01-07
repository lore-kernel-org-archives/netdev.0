From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/6] vxlan: Allow for VXLAN extensions to be implemented
Date: Tue, 6 Jan 2015 19:46:56 -0800
Message-ID: <CA+mtBx_mp1mf_HPp5u9wDfgeOc8pt26Mf1VHFZTAqDhTdZe7cw@mail.gmail.com>
References: <cover.1420594925.git.tgraf@suug.ch>
	<7c5e8240263a22a69042c45a632c9940e5ae1062.1420594925.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:43217 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754243AbbAGDq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 22:46:57 -0500
Received: by mail-ig0-f175.google.com with SMTP id h15so5253850igd.2
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 19:46:56 -0800 (PST)
In-Reply-To: <7c5e8240263a22a69042c45a632c9940e5ae1062.1420594925.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 6, 2015 at 6:05 PM, Thomas Graf <tgraf@suug.ch> wrote:
> The VXLAN receive code is currently conservative in what it accepts and
> will reject any frame that uses any of the reserved VXLAN protocol fields.
> The VXLAN draft specifies that "reserved fields MUST be set to zero on
> transmit and ignored on receive.".
>
IMO it is an unfortunate decision in VXLAN to ignore set reserved
fields on receive. Had they not done this, then adding a protocol
field to the header would have been feasible and we wouldn't need yet
another encapsulation protocol (i.e. VXLAN-GPE). Rejecting frames with
reserved bits set is the better behavior, but I think the comment
about this needs to be clear about why this diverges from RFC7348.

> Retain the current conservative parsing behaviour by default but allows
> these fields to be used by VXLAN extensions which are explicitly enabled
> on the VXLAN socket respectively VXLAN net_device.
>
Conceptually, VXLAN has both mandatory flags and optional flags for
extensions. You may want to look at the VXLAN RCO patches that added
an extension and infrastructure for them.

Tom

> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>  drivers/net/vxlan.c | 29 +++++++++++++++++++----------
>  include/net/vxlan.h | 32 +++++++++++++++++++++++++++++---
>  2 files changed, 48 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 2ab0922..4d52aa9 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -65,7 +65,7 @@
>  #define VXLAN_VID_MASK (VXLAN_N_VID - 1)
>  #define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
>
> -#define VXLAN_FLAGS 0x08000000 /* struct vxlanhdr.vx_flags required value. */
> +#define VXLAN_FLAGS 0x08000000 /* struct vxlanhdr.vx_flags default value. */
>
>  /* UDP port for VXLAN traffic.
>   * The IANA assigned port is 4789, but the Linux default is 8472
> @@ -1100,22 +1100,28 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
>         if (!pskb_may_pull(skb, VXLAN_HLEN))
>                 goto error;
>
> +       vs = rcu_dereference_sk_user_data(sk);
> +       if (!vs)
> +               goto drop;
> +
>         /* Return packets with reserved bits set */
>         vxh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
> -       if (vxh->vx_flags != htonl(VXLAN_FLAGS) ||
> -           (vxh->vx_vni & htonl(0xff))) {
> -               netdev_dbg(skb->dev, "invalid vxlan flags=%#x vni=%#x\n",
> -                          ntohl(vxh->vx_flags), ntohl(vxh->vx_vni));
> -               goto error;
> +
> +       /* For backwards compatibility, only allow reserved fields to be
> +        * used by VXLAN extensions if explicitly requested.
> +        */
> +       if (vs->exts) {
> +               if (!vxh->vni_present)
> +                       goto error_invalid_header;
> +       } else {
> +               if (vxh->vx_flags != htonl(VXLAN_FLAGS) ||
> +                   (vxh->vx_vni & htonl(0xff)))
> +                       goto error_invalid_header;
>         }
>
>         if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
>                 goto drop;
>
> -       vs = rcu_dereference_sk_user_data(sk);
> -       if (!vs)
> -               goto drop;
> -
>         vs->rcv(vs, skb, vxh->vx_vni);
>         return 0;
>
> @@ -1124,6 +1130,9 @@ drop:
>         kfree_skb(skb);
>         return 0;
>
> +error_invalid_header:
> +       netdev_dbg(skb->dev, "invalid vxlan flags=%#x vni=%#x\n",
> +                  ntohl(vxh->vx_flags), ntohl(vxh->vx_vni));
>  error:
>         /* Return non vxlan pkt */
>         return 1;
> diff --git a/include/net/vxlan.h b/include/net/vxlan.h
> index 903461a..3e98d31 100644
> --- a/include/net/vxlan.h
> +++ b/include/net/vxlan.h
> @@ -11,10 +11,35 @@
>  #define VNI_HASH_BITS  10
>  #define VNI_HASH_SIZE  (1<<VNI_HASH_BITS)
>
> -/* VXLAN protocol header */
> +/* VXLAN protocol header:
> + * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + * |R|R|R|R|I|R|R|R|               Reserved                        |
> + * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + * |                VXLAN Network Identifier (VNI) |   Reserved    |
> + * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + *
> + * I = 1       VXLAN Network Identifier (VNI) present
> + */
>  struct vxlanhdr {
> -       __be32 vx_flags;
> -       __be32 vx_vni;
> +       union {
> +               struct {
> +#ifdef __LITTLE_ENDIAN_BITFIELD
> +                       __u8    reserved_flags1:3,
> +                               vni_present:1,
> +                               reserved_flags2:4;
> +#elif defined(__BIG_ENDIAN_BITFIELD)
> +                       __u8    reserved_flags2:4,
> +                               vni_present:1,
> +                               reserved_flags1:3;
> +#else
> +#error "Please fix <asm/byteorder.h>"
> +#endif
> +                       __u8    vx_reserved1;
> +                       __be16  vx_reserved2;
> +               };
> +               __be32 vx_flags;
> +       };
> +       __be32  vx_vni;
>  };
>
>  struct vxlan_sock;
> @@ -25,6 +50,7 @@ struct vxlan_sock {
>         struct hlist_node hlist;
>         vxlan_rcv_t      *rcv;
>         void             *data;
> +       u32               exts;
>         struct work_struct del_work;
>         struct socket    *sock;
>         struct rcu_head   rcu;
> --
> 1.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
