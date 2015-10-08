From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH] ip: find correct route for socket which is not bound (v2)
Date: Thu, 8 Oct 2015 11:31:05 +0800
Message-ID: <5615E379.1040206@oracle.com>
References: <1443145960-20514-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Wengang Wang <wen.gang.wang@oracle.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:36155 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbbJHD2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 23:28:54 -0400
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t983Srbf002356
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 8 Oct 2015 03:28:53 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.13.8/8.13.8) with ESMTP id t983Srsi011569
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 8 Oct 2015 03:28:53 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by aserv0122.oracle.com (8.13.8/8.13.8) with ESMTP id t983SrTv027073
	for <netdev@vger.kernel.org>; Thu, 8 Oct 2015 03:28:53 GMT
In-Reply-To: <1443145960-20514-1-git-send-email-wen.gang.wang@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Any comment on this patch?

thanks,
wengang

=D4=DA 2015=C4=EA09=D4=C225=C8=D5 09:52, Wengang Wang =D0=B4=B5=C0:
> This is the v2, comparing the v1, the changes is:
>   * for loopback outbound device, it continue skipping cached route;
>     for others, it goes through the cached route.
>
> For multicast, we should find valid route(thus get the meaniful pmtu)=
 for
> the packet on the socket which is not bound to a device(sk_bound_dev_=
if
> being 0) too.
>
>  From man page of socket(7)
>
>         SO_BINDTODEVICE
> 		Bind this socket to a particular device like =A1=B0eth0=A1=B1, as
> 		specified in the passed interface name.  If the name is an
> 		empty string or the option length is zero, the socket
> 		device binding is removed. The  passed  option is  a
> 		variable-length null-terminated interface name string with
> 		the maximum size of IFNAMSIZ.  If a socket is bound to an
> 		interface, only packets received from that particular
> 		interface are processed by the socket. Note that this works
> 		only for some socket types, particularly AF_INET sockets.
> 		It is not supported for packet sockets (use normal bind(2)
> 		there).
>
> The man page doesn't say when socket not bound packets won't be route=
d.
>
> A problem is hit that all multicast packets dropped by kernel(from se=
nder
> host). The lower layer is IPoIB with MTU being 7000. And I was sendin=
g 4096
> length multicast  packets. Inside IPoIB the first send is dropped bec=
ause
> is exeeding the internal packet size limitation mcast_mtu which is 20=
44.
> So IPoIB calls ip_rt_update_pmtu (indirectly) trying to set path mtu.=
 A
> correct route is configured for the multicast, so the setting of pmtu
> cucceeded and the next multicast packet(to the same target) is expect=
ed
> to succeed(it would be well fragmented accroding to the pmtu I just s=
et).
> But actually the second and later multicast packets got dropped too. =
And
> the reason is that the neighor looking up(fib_lookup) is skipped beca=
use of
> the socket is not bound to device(sk_bound_dev_if being 0). After app=
lied
> the patch I proposed here, it works fine.
>
> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> ---
>   net/ipv4/route.c | 6 +++++-
>   1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 5f4a556..c0534c2 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2097,7 +2097,10 @@ struct rtable *__ip_route_output_key(struct ne=
t *net, struct flowi4 *fl4)
>   			 */
>  =20
>   			fl4->flowi4_oif =3D dev_out->ifindex;
> -			goto make_route;
> +			if (dev_out->flags & IFF_LOOPBACK)
> +				goto make_route;
> +			else
> +				goto lookup;
>   		}
>  =20
>   		if (!(fl4->flowi4_flags & FLOWI_FLAG_ANYSRC)) {
> @@ -2153,6 +2156,7 @@ struct rtable *__ip_route_output_key(struct net=
 *net, struct flowi4 *fl4)
>   		goto make_route;
>   	}
>  =20
> +lookup:
>   	if (fib_lookup(net, fl4, &res, 0)) {
>   		res.fi =3D NULL;
>   		res.table =3D NULL;
