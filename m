From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/2 net-next] vxlan: Be liberal on receive and only
 require the I bit to be set
Date: Sun, 13 Jul 2014 15:08:20 -0700
Message-ID: <CA+mtBx_VpbrddO3AMRZbZ3Qdkp2QBs5i7rN2tqD4GFM0hT7zYg@mail.gmail.com>
References: <cover.1405097440.git.tgraf@suug.ch>
	<cc7b11d065475a303d4a12a34acfded4e830c313.1405097440.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	nicolas.dichtel@6wind.com, Pravin B Shelar <pshelar@nicira.com>,
	xiyou.wangcong@gmail.com, Or Gerlitz <ogerlitz@mellanox.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Pritesh Kothari (pritkoth)" <pritkoth@cisco.com>,
	Madhu Challa <challa@noironetworks.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:58382 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbaGMWIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2014 18:08:21 -0400
Received: by mail-ie0-f180.google.com with SMTP id at20so2576937iec.25
        for <netdev@vger.kernel.org>; Sun, 13 Jul 2014 15:08:20 -0700 (PDT)
In-Reply-To: <cc7b11d065475a303d4a12a34acfded4e830c313.1405097440.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 11, 2014 at 9:59 AM, Thomas Graf <tgraf@suug.ch> wrote:
> The VXLAN receive code is currently conservative in what it accepts and
> will reject any frame that uses any of the reserved fields. The VXLAN
> draft specifies that "reserved fields MUST be set to zero on transmit
> and ignored on receive." though.
>
> Be liberal in only requiring the I bit to allow for VXLAN extensions
> to be implemented.
>
This is not robust (this is a problem in the VXLAN spec not your
patch). There is no requirement that the VXLAN bits are optional. For
example, if a receiver accepts a GPE packet but doesn't implement it
the packet will be misinterpreted. I've already pointed this out to
the VLXAN folks on nvo3 list. Dropping packets with unknown bits set
is the only sane approach.

Tom


> Cc: Pritesh Kothari (pritkoth) <pritkoth@cisco.com>
> Cc: Madhu Challa <challa@noironetworks.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>  drivers/net/vxlan.c | 53 +++++++++++++++++++++++++++++++++++++++++++----------
>  1 file changed, 43 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index e6808f7..2e9fbcc 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -63,12 +63,43 @@
>  #define VXLAN_VID_MASK (VXLAN_N_VID - 1)
>  #define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
>
> -#define VXLAN_FLAGS 0x08000000 /* struct vxlanhdr.vx_flags required value. */
> -
> +/* Base VXLAN header:
> + * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + * |R|R|R|R|I|R|R|R|               Reserved                        |
> + * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + * |                VXLAN Network Identifier (VNI) |   Reserved    |
> + * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + *
> + * I = 1       VXLAN Network Identifier (VNI) present
> + */
>  /* VXLAN protocol header */
>  struct vxlanhdr {
> -       __be32 vx_flags;
> -       __be32 vx_vni;
> +#ifdef __LITTLE_ENDIAN_BITFIELD
> +       __u8    reserved_flags1:3,
> +               vni_present:1,
> +               reserved_flags2:4;
> +#elif defined(__BIG_ENDIAN_BITFIELD)
> +       __u8    reserved_flags2:4,
> +               vni_present:1,
> +               reserved_flags1:3;
> +#else
> +#error "Please fix <asm/byteorder.h>"
> +#endif
> +       __u8    vx_reserved1;
> +       __be16  vx_reserved2;
> +       __be32  vx_vni;
> +};
> +
> +union vxlan_oct_hdr {
> +       struct vxlanhdr hdr;
> +       __u8            octets[8];
> +};
> +
> +#define vxlan_flags(vxh) (((union vxlan_oct_hdr *)(vxh))->octets[0])
> +
> +enum {
> +       VXLAN_FLAG_VNI          = 0x08,
> +       VXLAN_FLAG_RESERVED     = 0xF7,
>  };
>
>  /* UDP port for VXLAN traffic.
> @@ -1141,12 +1172,10 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
>         if (!pskb_may_pull(skb, VXLAN_HLEN))
>                 goto error;
>
> -       /* Return packets with reserved bits set */
>         vxh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
> -       if (vxh->vx_flags != htonl(VXLAN_FLAGS) ||
> -           (vxh->vx_vni & htonl(0xff))) {
> +       if (!vxh->vni_present) {
>                 netdev_dbg(skb->dev, "invalid vxlan flags=%#x vni=%#x\n",
> -                          ntohl(vxh->vx_flags), ntohl(vxh->vx_vni));
> +                          vxlan_flags(vxh), ntohl(vxh->vx_vni));
>                 goto error;
>         }
>
> @@ -1617,7 +1646,9 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
>         }
>
>         vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
> -       vxh->vx_flags = htonl(VXLAN_FLAGS);
> +       vxlan_flags(vxh) = VXLAN_FLAG_VNI;
> +       vxh->vx_reserved1 = 0;
> +       vxh->vx_reserved2 = 0;
>         vxh->vx_vni = vni;
>
>         __skb_push(skb, sizeof(*uh));
> @@ -1689,7 +1720,9 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
>         }
>
>         vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
> -       vxh->vx_flags = htonl(VXLAN_FLAGS);
> +       vxlan_flags(vxh) = VXLAN_FLAG_VNI;
> +       vxh->vx_reserved1 = 0;
> +       vxh->vx_reserved2 = 0;
>         vxh->vx_vni = vni;
>
>         __skb_push(skb, sizeof(*uh));
> --
> 1.9.3
>
