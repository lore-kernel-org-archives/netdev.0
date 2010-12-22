From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv4: dont create routes on down devices
Date: Wed, 22 Dec 2010 15:39:39 +0100
Message-ID: <1293028779.3027.133.camel@edumazet-laptop>
References: <4CA208C9.1020800@6wind.com>
	 <1285691629.3154.80.camel@edumazet-laptop>  <4CA21BC6.5070300@6wind.com>
	 <1285692969.3154.86.camel@edumazet-laptop>  <4CA2EF9C.9040909@6wind.com>
	 <1285749349.2615.27.camel@edumazet-laptop>
	 <1285751929.2615.30.camel@edumazet-laptop>  <4D11B7AC.8000205@6wind.com>
	 <1293011708.3027.28.camel@edumazet-laptop>
	 <1293012464.3027.30.camel@edumazet-laptop>  <4D120096.6080508@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	netdev <netdev@vger.kernel.org>
To: nicolas.dichtel@6wind.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46613 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437Ab0LVOjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 09:39:43 -0500
Received: by wwa36 with SMTP id 36so5346476wwa.1
        for <netdev@vger.kernel.org>; Wed, 22 Dec 2010 06:39:41 -0800 (PST)
In-Reply-To: <4D120096.6080508@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 22 d=C3=A9cembre 2010 =C3=A0 14:43 +0100, Nicolas Dichtel a=
 =C3=A9crit :
> Yes, I saw this commit, but I still got the problem:
>=20
> shelby:/home/root/src# uname -a
> Linux shelby 2.6.37-rc5+ #10 SMP Wed Dec 22 05:02:53 EST 2010 i686 GN=
U/Linux
> shelby:/home/root/src# ip tunnel add mode ipip remote 10.16.0.164 loc=
al=20
> 10.16.0.72 dev eth0
> shelby:/home/root/src# ./a.out tunl1
> shelby:/home/root/src# ip tunnel del tunl1
>=20
> Message from syslogd@shelby at Dec 22 10:12:08 ...
>   kernel:[18459.828011] unregister_netdevice: waiting for tunl1 to be=
come free.=20
> Usage count =3D 3
>=20

On another machine, and net-next-2.6, I reproduced the problem, so we
need the patch after all, sorry for the delay.

Thanks

[PATCH] ipv4: dont create routes on down devices

In ip_route_output_slow(), instead of allowing a route to be created on
a not UPed device, report -ENETUNREACH immediately.

# ip tunnel add mode ipip remote 10.16.0.164 local=20
10.16.0.72 dev eth0
# (Note : tunl1 is down)
# ping -I tunl1 10.1.2.3
PING 10.1.2.3 (10.1.2.3) from 192.168.18.5 tunl1: 56(84) bytes of data.
(nothing)
# ./a.out tunl1
# ip tunnel del tunl1
Message from syslogd@shelby at Dec 22 10:12:08 ...
  kernel: unregister_netdevice: waiting for tunl1 to become free.=20
Usage count =3D 3

After patch:
# ping -I tunl1 10.1.2.3
connect: Network is unreachable


Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Octavian Purdila <opurdila@ixiacom.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/route.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d8b4f4d..f1defb7 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2562,9 +2562,10 @@ static int ip_route_output_slow(struct net *net,=
 struct rtable **rp,
 			goto out;
=20
 		/* RACE: Check return value of inet_select_addr instead. */
-		if (rcu_dereference(dev_out->ip_ptr) =3D=3D NULL)
-			goto out;	/* Wrong error code */
-
+		if (!(dev_out->flags & IFF_UP) || !__in_dev_get_rcu(dev_out)) {
+			err =3D -ENETUNREACH;
+			goto out;
+		}
 		if (ipv4_is_local_multicast(oldflp->fl4_dst) ||
 		    ipv4_is_lbcast(oldflp->fl4_dst)) {
 			if (!fl.fl4_src)


