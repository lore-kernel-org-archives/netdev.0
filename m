From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: flush cache according to 'preferred life time'
Date: Mon, 23 Jul 2012 16:05:42 +0800
Message-ID: <500D05D6.7090108@cn.fujitsu.com>
References: <4A71D24947E78D43BC584A7CD4391A41017DE48F@SIXPRD0410MB359.apcprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: BALAKUMARAN KANNAN <balakumarank@tataelxsi.co.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:41218 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751110Ab2GWIFX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 04:05:23 -0400
In-Reply-To: <4A71D24947E78D43BC584A7CD4391A41017DE48F@SIXPRD0410MB359.apcprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B407=E6=9C=8823=E6=97=A5 15:36, BALAKUMARAN KANNAN=
 =E5=86=99=E9=81=93:
> Hello all,
>     I am running test casees for IPv6 conformation on linux-3.0.26 ke=
rnel. Here I am facing a problem in routing advertisement. Once test ca=
se sets the 'preferred life time' to 20 seconds for a particular destin=
ation. And continuously sending ICMP REQUEST. It is expected that the I=
CMP_REPLY should stop in 20 seconds. But as because the default gc_inte=
rval is 30seconds, even after the timer expiry of the route, it is stay=
ing in the router cache. So even after 20 seconds, the nut(node under t=
est) sends ICMP_REPLY. So if I changes gc_interval to 1, the test is ge=
tting passed.
>=20
>     But if I changes gc_interval to 1 seconds another test case in pm=
tu section fails. It expects that the nut should hold pmtu(path mtu) in=
formation for different value. So if I flushes the cache, the pmtu valu=
e is turning back to default.
>=20
>     So I made the kernel to alter its gc_interval value according to =
the 'preferred life time' of the path. Here is my path. Kindly tell me =
whether my idea is correct. Am I missing something?
>=20

Is this commit 1716a96101c49186bb0b8491922fd3e69030235f what you need?

> ---------------------------------------------------------------------=
-----------------
> --- ../linux-3.0.y-BRANCH_SS-RT.git.fresh/net/ipv6/ndisc.c.bak  2012-=
07-23 12:50:46.000000000 +0530
> +++ ../linux-3.0.y-BRANCH_SS-RT.git.fresh/net/ipv6/ndisc.c      2012-=
07-23 12:54:17.000000000 +0530
> @@ -1160,6 +1160,9 @@
> =20
>         __u8 * opt =3D (__u8 *)(ra_msg + 1);
> =20
> +        struct net *net =3D dev_net(skb->dev);
> +        fib6_run_gc(1, net);
> +
>         optlen =3D (skb->tail - skb->transport_header) - sizeof(struc=
t ra_msg);
> =20
>         if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKL=
OCAL)) {
> @@ -1200,6 +1203,22 @@
>                 return;
>         }
> =20
> +        if (*opt =3D=3D 3) {
> +                printk("<8> IN OPT 3\n");
> +                struct net *net =3D dev_net(skb->dev);
> +                fib6_run_gc(1, net);
> +                int pref_life_time =3D  ntohl(*((int *) (((char *) (=
opt)) + 8)));
> +                if ((pref_life_time !=3D 0) && (pref_life_time < 50)=
) {
> +                        printk("<8> gc_interval CHANGED\n");
> +                        //init_net.ipv6.sysctl.flush_delay =3D 1;
> +                        init_net.ipv6.sysctl.ip6_rt_gc_interval =3D =
1 * HZ;
> +                }
> +                else {
> +                        init_net.ipv6.sysctl.ip6_rt_gc_interval =3D =
30 * HZ;
> +                }
> +
> +        }
> +
>         if (!accept_ra(in6_dev))
>                 goto skip_linkparms;
> ---------------------------------------------------------------------=
-----------------
>=20
> Note: This is not well structured. I just created it for temparory so=
lution. Just clarify me whether this idea is right.
>=20
> And Please let me know why pmtu value is not stored in routing table =
but only in cache.

I think the pmtu should be belong to destination.the different destinat=
ions may have
different pmtu,even they use same route entry.
