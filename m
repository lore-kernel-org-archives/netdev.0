From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH] Constrain UFO fragment sizes to multiples of 8 bytes
Date: Tue, 19 Jul 2011 18:30:22 -0700
Message-ID: <CANP3RGdBTXf1+mwJXEW7Nv_jENE_SP00h2W4d05Ki6JT-5LpvQ@mail.gmail.com>
References: <1311124953-32159-1-git-send-email-wsommerfeld@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Bill Sommerfeld <wsommerfeld@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:45451 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395Ab1GTBa0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 21:30:26 -0400
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p6K1UOKG001823
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 18:30:25 -0700
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by wpaz37.hot.corp.google.com with ESMTP id p6K1UM0a010044
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 18:30:23 -0700
Received: by pzk5 with SMTP id 5so7269505pzk.17
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 18:30:22 -0700 (PDT)
In-Reply-To: <1311124953-32159-1-git-send-email-wsommerfeld@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ack.
This should probably make it into all manner of stable branches.

On Tue, Jul 19, 2011 at 6:22 PM, Bill Sommerfeld <wsommerfeld@google.co=
m> wrote:
> Because the ip fragment offset field counts 8-byte chunks, ip
> fragments other than the last must contain a multiple of 8 bytes of
> payload. =C2=A0ip_ufo_append_data wasn't respecting this constraint a=
nd,
> depending on the MTU and ip option sizes, could create malformed
> non-final fragments.
>
> Google-Bug-Id: 5009328
> Signed-off-by: Bill Sommerfeld <wsommerfeld@google.com>
> ---
>
> Note to reviewers: The first two hunks simply rename the "mtu"
> parameter to "maxfraglen"; the real change is in the third hunk.
> maxfraglen (the size of the largest non-final fragment which fits
> inside mtu) is already computed for the non-UFO fragmentation path.
>
> We saw this problem in a 2.6.34-based kernel with a bond device that
> had UFO enabled (as a result of changeset d9f5950f90292f7c);
> 1742f183fc218798 rewrote netdev_increment_features to no longer force
> on UFO. =C2=A0The MTU on this bond device was set to 1470; fragmented
> datagrams were mangled, causing the receiver to get errors of the
> form:
>
> [506259.362640] UDP: short packet: From x.x.x.x:nnnn 1471/1469 to y.y=
=2Ey.y:nnnn
>
> =C2=A0net/ipv4/ip_output.c | =C2=A0 =C2=A06 +++---
> =C2=A01 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index be27e60..ccaaa85 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -734,7 +734,7 @@ static inline int ip_ufo_append_data(struct sock =
*sk,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0int getfrag(void *from, char *to, int offset, int len,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int odd, struct sk_buff *skb),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0void *from, int length, int hh_len, int fragheaderlen,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 int transhdrlen, int mtu, unsigned int flags)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 int transhdrlen, int maxfraglen, unsigned int flags)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sk_buff *skb;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int err;
> @@ -767,7 +767,7 @@ static inline int ip_ufo_append_data(struct sock =
*sk,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0skb->csum =3D =
0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* specify the=
 length of each IP datagram fragment */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb_shinfo(skb)->g=
so_size =3D mtu - fragheaderlen;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb_shinfo(skb)->g=
so_size =3D maxfraglen - fragheaderlen;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0skb_shinfo(skb=
)->gso_type =3D SKB_GSO_UDP;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__skb_queue_ta=
il(queue, skb);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> @@ -831,7 +831,7 @@ static int __ip_append_data(struct sock *sk,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(rt->dst.dev->features & NET=
IF_F_UFO) && !rt->dst.header_len) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D ip_ufo=
_append_data(sk, queue, getfrag, from, length,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
hh_len, fragheaderlen, transhdrlen,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0m=
tu, flags);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0m=
axfraglen, flags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0goto error;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> --
> 1.7.3.1
>
>



--=20
Maciej A. =C5=BBenczykowski
Kernel Networking Developer @ Google
1600 Amphitheatre Parkway, Mountain View, CA 94043
tel: +1 (650) 253-0062
