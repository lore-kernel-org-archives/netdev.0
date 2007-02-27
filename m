From: Sergio Paracuellos <sparacuellos@lock-linux.com>
Subject: Re: Adding data to SKB - odd checksum errors
Date: Tue, 27 Feb 2007 11:57:25 +0100
Message-ID: <1172573845.13609.12.camel@localhost.localdomain>
References: <45E19076.1080600@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: Kristian Evensen <kristrev@ifi.uio.no>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <45E19076.1080600@ifi.uio.no>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This is because if you change the skb you must calcutale checksum for
tcp and ip headers changes again. For example:

struct iphdr *new_iph =3D NULL;
struct tcphdr *new_th =3D NULL;

/* copy skb to another skb with skb_copy */
new_skb =3D skb_copy_expand(skb, skb_headroom(skb), MY_SIZE, GFP_ATOMIC=
);

/* more bytes for buffer */
skb_put(new_skb, MY_SIZE);

/* now get pointer to the the new ip and tcp headers (should be the sam=
e
in the other skb */
new_th =3D new_skb->h.th;
new_iph =3D new_skb->nh.iph;

/* suppose I change the len */
new_ip_tot_len =3D htons(ntohs(new_iph->tot_len) + MY_SIZE);
new_iph->check =3D new_check(new_iph->tot_len ^ 0xFFFF, new_ip_tot_len,
iph->check)

where new_check can be something similar to:

static inline u_int16_t
new_check(u_int32_t oldvalinv, u_int32_t newval, u_int16_t oldcheck)
{
	u_int32_t diffs[] =3D { oldvalinv, newval };
	return csum_fold(csum_partial((char *)diffs, sizeof(diffs),
				oldcheck^0xFFFF));
}

Am I in a mistake? I suppose this can be done in this way, but I am not
sure.

Good luck!

Cheers,
	Sergio

El dom, 25-02-2007 a las 15:34 +0200, Kristian Evensen escribi=C3=B3:
> Hello,
>=20
> I am working on an algorithm to add data from the previous skb (on th=
e=20
> queue) to the front of the current skb. This should be beneficial for=
 a=20
> certain kind of TCP-traffic, and I am curious as to wether it will wo=
rk=20
> or not.
>=20
> Currently I have implemented a small algorithm to copy the data that=20
> works most of the time. It is called from write_xmit (right before th=
e=20
> while-loop) and performs a number of checks (does the skb fit in the=20
> window, does it have enought space - mostly the same as the=20
> retrans_try_collapse-function) before it copies the data. I first=20
> "allocate" new data at the back of the skb using skb_put, and if that=
 is=20
> succsessfull I copy the new data (using first memmove to move the old=
=20
> data and then memcpy), update the seq-number of this skb and calculat=
e a=20
> new checksum. The algorithm will (currently) not work with non-linear=
=20
> skbs. I have pasted the code at the bottom of this mail.
>=20
> The weird thing about this algorithm is that something will suddenly=20
> make it go wrong/it makes something else go wrong, and the packets th=
at=20
> I send have the wrong TCP-checksum. I have looked around the code for=
=20
> any counters I might have missed or similar, but I cant find any. If =
I=20
> have understod skb's correctly, I shouldn't have to update any counte=
rs=20
> except skb->len (which put does) since I dont expand the SKB I only u=
se=20
> the space already reserved for it.
>=20
> Does anyone have any ideas to what might be wrong or can spot any=20
> errors/misunderstandings in my code?
>=20
> Thanks,
> Kristian
>=20
> The code:
>=20
> This goes into write_xmit before the loop:
> if(sysctl_tcp_thin_aggressive_bundling && tcp_stream_is_thin(tp)){
>     if(skb->prev !=3D (struct sk_buff*) &(sk)->sk_write_queue
>         && !(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_SYN)
>         && (skb_shinfo(skb)->nr_frags =3D=3D 0 &&
>         skb_shinfo(skb->prev)->nr_frags =3D=3D 0)){
>             tcp_trans_try_collapse2(sk, skb, tcp_current_mss(sk, 0))
>         }
> }
>=20
> This is the code that copies the data:
> static int tcp_trans_try_collapse2(struct sock *sk, struct sk_buff *s=
kb,=20
> int mss_now)
> {
>     struct tcp_sock *tp =3D tcp_sk(sk);
>=20
>     /* Make sure that this isnt refereced by somebody else
>      */
>     if(!skb_cloned(skb)){
>         struct sk_buff *prev_skb =3D skb_copy(skb->prev, GFP_ATOMIC);
>         int skb_size =3D skb->len, prev_skb_size =3D prev_skb->len;
>         u16 flags =3D TCP_SKB_CB(prev_skb)->flags;
>=20
>         /* Since this technique currently does not support SACK, I
>             * return -1 if the previous has been SACK'd. */
>         if(TCP_SKB_CB(prev_skb)->sacked & TCPCB_SACKED_ACKED){
>             return -1;
>         }
>=20
>         /* Current skb is out of window. */
>         if (after(TCP_SKB_CB(skb)->end_seq, tp->snd_una+tp->snd_wnd))=
{
>             return -1;
>         }
>=20
>         /* Punt if not enough space exists in the first SKB for
>          * the data in the second, or the total combined payload
>          * would exceed the MSS.
>          */
>         if ((prev_skb_size > skb_tailroom(skb)) ||
>             ((skb_size + prev_skb_size) > mss_now)){
>             return -1;
>         }
>=20
>         /*To avoid duplicate copies.*/
>         if(TCP_SKB_CB(skb)->seq <=3D TCP_SKB_CB(prev_skb)->seq)
>             return -1;
>=20
>         /*First, check I have enough room*/
>         if(skb_tailroom(skb) < prev_skb->len)
>             return -1;
>=20
>         copy =3D skb_put(skb, prev_skb->len);
>=20
>         if(copy){
>             memmove(skb->data + prev_skb->len, skb->data, skb->len -=20
> prev_skb->len);
>             memcpy(skb->data, prev_skb->data, prev_skb->len);
>             TCP_SKB_CB(skb)->seq =3D TCP_SKB_CB(prev_skb)->seq;
>             skb->csum =3D csum_partial(skb->data, skb->len, 0);
>         }
>=20
>         __kfree_skb(prev_skb);
>     }
>=20
>     return 1;
> }
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--=20
=E2=80=9CNo quiero mandar en naide ni que me manden a mi. Me gusta vivi=
r
errante, hoy aqu=C3=AD y ma=C3=B1ana all=C3=AD, y mi vida sigue adelant=
e.=E2=80=9D=20

Camar=C3=B3n

