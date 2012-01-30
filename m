From: Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: RE: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB
 originated TCP streams
Date: Mon, 30 Jan 2012 07:44:09 +0000
Message-ID: <36F7E4A28C18BE4DB7C86058E7B607240BE9687A@MTRDAG01.mtl.com>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com>
 <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>
 <CAL1RGDUm8ROxFFMa+D1ZD5jF+cK+kV8aEVzspgnZFNXeuai+fA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDUm8ROxFFMa+D1ZD5jF+cK+kV8aEVzspgnZFNXeuai+fA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Roland,

I see this fix as part of a more general fix, one that will enable more=
 protocols (e.g. X25, PPP) to enjoy the benefit of GRO.
I think that the more general fix should include adding a MAC compariso=
n function to the header_ops structure in netdev.h.
Then network drivers which are not Ethernet will register their own com=
parison function, and the GRO code will check if such routine exists an=
d if so will use it.
The problem with this approach is that until such a major fix is integr=
ated the IPoIB performance will suffer.
This simple fix will enable us to use the benefit of GRO until the more=
 general fix is integrated.

Best regards,

S.P.
=20

-----Original Message-----
=46rom: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org [mailto:roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org] On Behal=
f Of Roland Dreier
Sent: Monday, January 30, 2012 6:44 AM
To: Or Gerlitz
Cc: linux-rdma; Shlomo Pongratz; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB orig=
inated TCP streams

On Thu, Jan 26, 2012 at 6:43 AM, Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wro=
te:
> From: Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>
> The GRO flow makes a check in every layer to ensure the packets are=20
> actually merged only if they match at all layers.
>
> The first GRO check, at L2 always fails for IPoIB, since it assumes=20
> that all packets have 14 bytes of Ethernet link layer header. Using=20
> the IPoIB header will not help here either, since its only four bytes=
=2E=20
> To overcome this, the skb mac header pointer is set to an area within=
=20
> the packet IB GRH headroom, such that later, the L2 check done by GRO=
=20
> succeeds and it can move to checks at the network and transport layer=
s.

> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c=20
> b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
> index 4115be5..89cfaf7 100644
> --- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
> +++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
> @@ -286,10 +287,20 @@ static void ipoib_ib_handle_rx_wc(struct=20
> net_device *dev, struct ib_wc *wc)
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->pkt_type =3D PACKET_MULTICAST;
>
> - =A0 =A0 =A0 skb_pull(skb, IB_GRH_BYTES);
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* GRO first does L2 compares (14 bytes). We must not=
 let it=20
> + start from
> + =A0 =A0 =A0 =A0* the IPoIB header as ten octets of the IP header, c=
ontaining=20
> + fields
> + =A0 =A0 =A0 =A0* which vary from packet to packet will cause non-me=
rging of packets.
> + =A0 =A0 =A0 =A0* from the same TCP stream.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 psgid =3D skb_pull(skb, offsetof(struct ib_grh, sgid));
> + =A0 =A0 =A0 /* if there's no GRH, that area could contain random da=
ta */
> + =A0 =A0 =A0 if (!(wc->wc_flags & IB_WC_GRH))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(psgid, 0, 16);
> + =A0 =A0 =A0 skb_reset_mac_header(skb);
> + =A0 =A0 =A0 skb_pull(skb, IB_GRH_BYTES - offsetof(struct ib_grh, sg=
id));
>
> =A0 =A0 =A0 =A0skb->protocol =3D ((struct ipoib_header *) skb->data)-=
>proto;
> - =A0 =A0 =A0 skb_reset_mac_header(skb);

This seems like a really weird place to fix this.  Wouldn't it make mor=
e sense to fix the GRO check to handle non-ethernet
L2 headers?

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
