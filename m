From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: remove all rt cache entries on UNREGISTER event
Date: Tue, 28 Sep 2010 18:56:09 +0200
Message-ID: <1285692969.3154.86.camel@edumazet-laptop>
References: <4CA208C9.1020800@6wind.com>
	 <1285691629.3154.80.camel@edumazet-laptop>  <4CA21BC6.5070300@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45397 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757136Ab0I1Q4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 12:56:14 -0400
Received: by fxm14 with SMTP id 14so139095fxm.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 09:56:13 -0700 (PDT)
In-Reply-To: <4CA21BC6.5070300@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 28 septembre 2010 =C3=A0 18:45 +0200, Nicolas Dichtel a =C3=A9=
crit :
> Eric Dumazet wrote:
> > Le mardi 28 septembre 2010 =C3=A0 17:24 +0200, Nicolas Dichtel a =C3=
=A9crit :
> >> Hi,
> >>
> >> I face a problem when I try to remove an interface,=20
> >> netdev_wait_allrefs() complains about refcount.
> >>
> >> Here is a trivial scenario to reproduce the problem:
> >> # ip tunnel add mode ipip remote 10.16.0.164 local 10.16.0.72 dev =
eth0
> >> # ./a.out tunl1
> >> # ip tunnel del tunl1
> >>
> >> Note: a.out binary create an IPv4 raw socket, attach it to tunl1=20
> >> (SO_BINDTODEVICE), set it as multicast (IP_MULTICAST_LOOP), set th=
e=20
> >> multicast interface to tunl1 (IP_MULTICAST_IF), build the IP heade=
r=20
> >> (IP_HDRINCL) and then send a single packet (192.168.6.1 -> 224.0.0=
=2E18).
> >>
> >> Note2: when a.out is executed, tunl1 has no ip address and is down=
=2E
> >>
> >=20
> > CC Octavian Purdila, the patch author.
> >=20
> > I am just wondering why this route is created in the first place.
> At first, I asked myself the same question, but it seems that this is=
=20
> allowed to send a packet through this kind of socket, even if interfa=
ce=20
> is down. Packet will be destroyed by the noop qdisk.
> But I agree that it is strange to perform route lookup and everything=
 to=20
>    destroy the packet at the end ...
> Maybe raw_sendmsg() can delete it directly ;-) ... or maybe=20
> ip_route_output_flow().
>=20
> Any suggestions welcome.
>=20

Hmm...

One way to track this kind of problem would be to add a WARN_ON() in
dev_hold()

-> Check that when a reference on dev is taken, we are in a known state=
=2E

Something like this ?

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 83de0eb..54bef78 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1773,6 +1774,7 @@ static inline void dev_put(struct net_device *dev=
)
  */
 static inline void dev_hold(struct net_device *dev)
 {
+	WARN_ON(dev->reg_state !=3D NETREG_REGISTERED);
 	atomic_inc(&dev->refcnt);
 }
=20


