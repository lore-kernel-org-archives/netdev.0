From: Robert Sander <r.sander@heinlein-support.de>
Subject: Re: Configure ICMP error source address
Date: Sun, 10 Jan 2016 20:12:09 +0100
Message-ID: <5692AD09.80406@heinlein-support.de>
References: <568F8207.9040305@heinlein-support.de>
 <20160108152448.5251154.50977.21786@gmail.com>
 <568FDFBF.3010300@stressinduktion.org>
 <20160109035708.5251154.82433.21820@gmail.com>
 <5690D98B.7070003@stressinduktion.org> <56913852.4030608@heinlein-support.de>
 <56919144.4060508@stressinduktion.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="F3r6jqpXWpqNUb94qMLjTc8cW0eVkK1GC"
To: netfilter@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <56919144.4060508@stressinduktion.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--F3r6jqpXWpqNUb94qMLjTc8cW0eVkK1GC
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 10.01.2016 um 00:01 schrieb Hannes Frederic Sowa:

> I am not a fan of such implicit assumptions. I would prefer the direct
> specification of the source ip address over writing interface
> information to a procfs file.

I tried that but as I am not a seasoned kernel hacker introducing a new
sysctl including the validation of an IPv4 address was a bit too much.

Instead I created this patch (applicable against kernel version 3.2):

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index ab188ae..eba2071 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -567,7 +567,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int =
code, __be32 info)
=20
                rcu_read_lock();
                if (rt_is_input_route(rt) &&
-                   net->ipv4.sysctl_icmp_errors_use_inbound_ifaddr)
+                   net->ipv4.sysctl_icmp_errors_use_inbound_ifaddr =3D=3D=
 1)
                        dev =3D dev_get_by_index_rcu(net, rt->rt_iif);
=20
                if (dev)
@@ -577,6 +577,23 @@ void icmp_send(struct sk_buff *skb_in, int type, int=
 code, __be32 info)
                rcu_read_unlock();
        }
=20
+       /*
+        *      Set source in case of error reply
+        */
+
+       if (icmp_pointers[type].error && net->ipv4.sysctl_icmp_errors_use=
_inbound_ifaddr =3D=3D 2) {
+               struct net_device *dev =3D NULL;
+               __be32 tmpaddr =3D 0;
+
+               rcu_read_lock();
+               dev =3D dev_get_by_name_rcu(net, "lo");
+               if (dev)
+                       tmpaddr =3D inet_select_addr(dev, 0, RT_SCOPE_UNI=
VERSE);
+                       if (tmpaddr)
+                               saddr =3D tmpaddr;
+               rcu_read_unlock();
+       }
+
        tos =3D icmp_pointers[type].error ? ((iph->tos & IPTOS_TOS_MASK) =
|
                                           IPTOS_PREC_INTERNETCONTROL) :
                                          iph->tos;


It currently works in my testbed (Debian wheezy based, therefor kernel 3.=
2).

Maybe there is someone more experienced with introducing new sysctl
files and handling strings in kernel space than me that is able to
pick up this idea and implement it properly.

Regards
--=20
Robert Sander
Heinlein Support GmbH
Schwedter Str. 8/9b, 10119 Berlin

http://www.heinlein-support.de

Tel: 030 / 405051-43
Fax: 030 / 405051-19

Zwangsangaben lt. =C2=A735a GmbHG:=20
HRB 93818 B / Amtsgericht Berlin-Charlottenburg,
Gesch=C3=A4ftsf=C3=BChrer: Peer Heinlein -- Sitz: Berlin


--F3r6jqpXWpqNUb94qMLjTc8cW0eVkK1GC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJWkq0JAAoJEPC7kVgj3lsonJMP/2Har7mNsTpCwlrTqmkwZvUG
bj5iM3U4nzWaNqrNeOsrfw0YbGDvzEFF1NP2/WEkZ5SeLbbbhuwU2AUGtP7bgxhl
IEDKZcE/7RE3O6Wezc9C+jjoPzOjefD1UIfYHBQsZukA4b4FOggmGsYgDYPzPOlE
3uXOineZnsxFV/NrQT1Lqsde3LIiF9vMzE9k7BZmYBqIMtt0xvK2euCjaiBTtGBT
MZfCRJxWQ05SUDINkX+raf6oh6JIh7yZEXxfw4Lg1FZMZGQ0OAR3KRycfyOcGlKR
PqMectdz1FJBJHeDVcDFUAxQ8M6+6UoiUkd1SODxf8As6y+67pFnokXqQl1+iwmp
K5CAgc41v6dyyrmXV65Mpbd3fRmu/mYioFwy3R9SFez6uZhD43aeSyAr/LwC1JLS
6nJKVCIK3kRcBu/QFjrnXeQtaFb5ygtUa0aXMvhv6DhXv36svTgWVxZDhJXMAnyq
hiWip5IEvHz1UD5gsPPdZKmhmuZMzDRerzz7zNZbix72kHvmF3XZz7NDLc4F4h+P
7nuD1BVUJd8YgbeYwTuEgtLh0XJ1DTl5MUYaxLrJSR5m2sd7CyIUuNcGq/JwN0K7
7tiuUpDkEgi/3L4B5SfsB9Qmo4bypaiqxAjOHBKpIq3nlJRdUoWW+RPZERwB/X9f
tR/mLIVVcdoJxRywMxjL
=Qu3C
-----END PGP SIGNATURE-----

--F3r6jqpXWpqNUb94qMLjTc8cW0eVkK1GC--
