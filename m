From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NET : convert network timestamps to ktime_t
Date: Fri, 02 Mar 2007 23:46:14 +0100
Message-ID: <45E8A936.9050908@cosmosbay.com>
References: <45E5570E.7050301@free.fr>	<200703011230.50596.dada1@cosmosbay.com>	<45E6F744.8070106@linux-foundation.org>	<200703021538.41284.dada1@cosmosbay.com> <20070302130210.57883edc@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	John find <linux.kernel@free.fr>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:34493 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422695AbXCBWqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 17:46:30 -0500
In-Reply-To: <20070302130210.57883edc@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =E9crit :
> On Fri, 2 Mar 2007 15:38:41 +0100
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>> We currently use a special structure (struct skb_timeval) and plain =
'struct=20
>> timeval' to store packet timestamps in sk_buffs and struct sock.
>>
>> This has some drawbacks :
>> - Fixed resolution of micro second.
>> - Waste of space on 64bit platforms where sizeof(struct timeval)=3D1=
6
>>
>> I suggest using ktime_t that is a nice abstraction of high resolutio=
n time=20
>> services, currently capable of nanosecond resolution.
>>
>> As sizeof(ktime_t) is 8 bytes, using ktime_t in 'struct sock' permit=
s a 8 byte=20
>> shrink of this structure on 64bit architectures. Some other structur=
es also=20
>> benefit from this size reduction (struct ipq in ipv4/ip_fragment.c, =
struct=20
>> frag_queue in ipv6/reassembly.c, ...)
>>
>>
>=20
> You missed a couple of spots.

Arg yes...

>=20
> --- tcp-2.6.orig/net/sunrpc/svcsock.c	2007-03-02 12:50:45.000000000 -=
0800
> +++ tcp-2.6/net/sunrpc/svcsock.c	2007-03-02 12:58:28.000000000 -0800
> @@ -805,16 +805,9 @@
>  		/* possibly an icmp error */
>  		dprintk("svc: recvfrom returned error %d\n", -err);
>  	}
> -	if (skb->tstamp.off_sec =3D=3D 0) {
> -		struct timeval tv;
> =20
> -		tv.tv_sec =3D xtime.tv_sec;
> -		tv.tv_usec =3D xtime.tv_nsec / NSEC_PER_USEC;
> -		skb_set_timestamp(skb, &tv);
> -		/* Don't enable netstamp, sunrpc doesn't
> -		   need that much accuracy */
> -	}
> -	skb_get_timestamp(skb, &svsk->sk_sk->sk_stamp);
> +	svsk->sk_sk->sk_stamp =3D (skb->tstamp.tv64 !=3D 0) ? skb->tstamp
> +		: ktime_get_real();

Well, if we want to stay in the spirit of old code, we probably want to=
 use=20
current_kernel_time() (+ timespec_to_ktime()), because its less expensi=
ve.

And also setting the skb tstamp, no ?


