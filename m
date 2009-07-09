From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH] net: ip_push_pending_frames() fix
Date: Thu, 9 Jul 2009 08:32:33 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365F8AD4E64E@rrsmsx501.amr.corp.intel.com>
References: <4A53CD39.7080407@gmail.com>
	<20090707.191424.167842005.davem@davemloft.net>
	<EA929A9653AAE14F841771FB1DE5A1365F8ACEC9A1@rrsmsx501.amr.corp.intel.com>
 <20090708.104539.226485646.davem@davemloft.net> <4A552A0D.8080106@gmail.com>
 <EA929A9653AAE14F841771FB1DE5A1365F8AD4E371@rrsmsx501.amr.corp.intel.com>
 <4A5537DA.1060200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"emils.tantilov@gmail.com" <emils.tantilov@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"jolsa@redhat.com" <jolsa@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47737 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760944AbZGIOcg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 10:32:36 -0400
In-Reply-To: <4A5537DA.1060200@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Tantilov, Emil S a =E9crit :
>> Eric Dumazet wrote:
>>> David Miller a =E9crit :
>>>> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
>>>> Date: Wed, 8 Jul 2009 11:02:22 -0600
>>>>=20
>>>>> Still seeing traces during the test even with this patch applied:
>>>>>=20
>>>>> [ 1089.430093] ------------[ cut here ]------------
>>>>> [ 1089.435667] WARNING: at include/net/sock.h:423
>>>>> udp_lib_unhash+0x73/0xa0() [ 1089.435670] Hardware name: S5520HC
>>>> Ok I'll back this out for now, needs more investigation
>>>> obviously.
>>> Hmm... I never said it was supposed to fix Emil problem, just that
>>> I discovered one potential problem by code inspection.
>>>=20
>>> I could not find yet sk_refcnt mismatch.
>>> As we do less atomic ops per packet than before, some old bug could
>>> surface now...=20
>>>=20
>>> Emil, is it easy to reproduce this problem, considering I have a
>>> similar platform than yours (dual quad core machine, E5450 cpus @
>>> 3GHz) ?
>>=20
>> Eric,
>>=20
>> It should be easy to reproduce. At least I have been able to
>> consistently=20
>> reproduce it on several different systems with different drivers
>> (e1000, e1000e, igb).=20
>>=20
>> The test I'm running is a mix of IPV4/6 TCP/UDP traffic with netperf
>> (also mixing different types TCP/UDP_STREAM, TCP_MAERTS, TCP_UDP_RR
>> etc). How much this matters I don't know - it's possible that just
>> UDP traffic would do it. I also think it may have something to do
>> with IPv6 because of the trace, but I am not sure.  =20
>>=20
>> If you need more information let me know.
>>=20
>=20
> OK thanks, this was helpful, corking or not corking, that is the
> question :)=20
>=20
> I think ip6_push_pending_frames() & ip_push_pending_frames
> have a problem after recent commit
> 2b85a34e911bf483c27cfdd124aeb1605145dc80 (net: No more expensive
> sock_hold()/sock_put() on each tx)=20
>=20
> [PATCH] net: ip_push_pending_frames() fix
>=20
> After commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
> (net: No more expensive sock_hold()/sock_put() on each tx)
> we do not take any more references on sk->sk_refcnt on outgoing
> packets.=20
>=20
> I forgot to delete two __sock_put() from ip_push_pending_frames()
> and ip6_push_pending_frames().
>=20
> Reported-by: Emil S Tantilov <emils.tantilov@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 2470262..7d08210 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -1243,7 +1243,6 @@ int ip_push_pending_frames(struct sock *sk)
>  		skb->len +=3D tmp_skb->len;
>  		skb->data_len +=3D tmp_skb->len;
>  		skb->truesize +=3D tmp_skb->truesize;
> -		__sock_put(tmp_skb->sk);
>  		tmp_skb->destructor =3D NULL;
>  		tmp_skb->sk =3D NULL;
>  	}
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 7c76e3d..87f8419 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -1484,7 +1484,6 @@ int ip6_push_pending_frames(struct sock *sk)
>  		skb->len +=3D tmp_skb->len;
>  		skb->data_len +=3D tmp_skb->len;
>  		skb->truesize +=3D tmp_skb->truesize;
> -		__sock_put(tmp_skb->sk);
>  		tmp_skb->destructor =3D NULL;
>  		tmp_skb->sk =3D NULL;
>  	}

Thanks Eric,

With this patch the test ran all night without issues.

Emil
