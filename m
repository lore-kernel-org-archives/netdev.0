From: Nikhil Agarwal <hi2nikhil@gmail.com>
Subject: Re: Fwd: Memory exhaust issue with only IPsec policies configured on
 continuous traffic
Date: Thu, 10 May 2012 15:12:53 +0530
Message-ID: <CAETiZ-SjDwMb2Qct-eheLqGYrZn_NuZ4Zc9VUE+DYV287jQShw@mail.gmail.com>
References: <F0B93D0554724543876B9A180DC988575B8867@039-SN1MPN1-001.039d.mgd.msft.net>
 <CAETiZ-QTWN2U=hmaCS39Q8hzNysjam+eS5FSi-EYO7cXtTbGKQ@mail.gmail.com>
 <CAETiZ-QvamMJxfGJDK4CiKngELNevmOXnh7M=UGnkH61XrT5dw@mail.gmail.com>
 <1336627627.12504.127.camel@edumazet-glaptop> <1336627923.12504.128.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, benjamin.thery@bull.net,
	davem@davemloft.net, pstaszewski@itcare.pl
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1336627923.12504.128.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If i disable this cache of DST, dst are working fine. But now XFRM
state is allocated for every incoming packet and then freed. But while
freeing the xfrm state same garbage collection logic is there. Now
since packets are coming continuously garbage collector may not get
scheduled and large amount of memory is stuck to be freed causing the
system to go into non-recoverable state.

It seems that ther should be some change garbage collection scheduling
logic or  some mechnism to decide wether to cache some entry or not.

On Thu, May 10, 2012 at 11:02 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> On Thu, 2012-05-10 at 07:27 +0200, Eric Dumazet wrote:
>
>> Yep, we can use DST_NOCACHE
>>
>
> Please try following patch :
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 5773f5d..172c251 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2896,6 +2896,7 @@ struct dst_entry *ipv4_blackhole_route(struct n=
et *net, struct dst_entry *dst_or
> =A0 =A0 =A0 =A0if (rt) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct dst_entry *new =3D &rt->dst;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->flags |=3D DST_NOCACHE;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0new->__use =3D 1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0new->input =3D dst_discard;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0new->output =3D dst_discard;
>
>
