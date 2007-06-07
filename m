From: =?iso-8859-1?Q?Bj=F6rn?= Steinbrink <B.Steinbrink@gmx.de>
Subject: Re: 2.6.22-rc4-mm2 -- ipw2200 -- SIOCSIFADDR: No buffer space available
Date: Fri, 8 Jun 2007 00:20:15 +0200
Message-ID: <20070607222015.GA14966@atjola.homenet>
References: <a44ae5cd0706071125p2079472eme52821bd134d26b0@mail.gmail.com> <20070607131559.cd95a181.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Miles Lane <miles.lane@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:49587 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S937154AbXFGWUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 18:20:19 -0400
Content-Disposition: inline
In-Reply-To: <20070607131559.cd95a181.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2007.06.07 13:15:59 -0700, Andrew Morton wrote:
> On Thu, 7 Jun 2007 11:25:30 -0700
> "Miles Lane" <miles.lane@gmail.com> wrote:
>=20
> > Hi Andrew,
> >=20
> > This might be some problem with my kernel configuration.
> > I added:
> > CONFIG_BONDING=3Dy
> >=20
> > # dhclient eth1
> > There is already a pid file /var/run/dhclient.pid with pid 13499341=
6
> > Internet Systems Consortium DHCP Client V3.0.4
> > Copyright 2004-2006 Internet Systems Consortium.
> > All rights reserved.
> > For info, please visit http://www.isc.org/sw/dhcp/
> > SIOCSIFADDR: No buffer space available
> > Listening on LPF/eth1/00:12:f0:5e:db:2f
> > Sending on   LPF/eth1/00:12:f0:5e:db:2f
> > Sending on   Socket/fallback
> > DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 6
> > DHCPOFFER from 192.168.1.1
> > DHCPREQUEST on eth1 to 255.255.255.255 port 67
> > DHCPACK from 192.168.1.1
> > SIOCSIFADDR: No buffer space available
> > SIOCSIFNETMASK: Cannot assign requested address
> > SIOCSIFBRDADDR: Cannot assign requested address
> > SIOCADDRT: Network is unreachable
> > bound to 192.168.1.2 -- renewal in 2993 seconds.
> >=20
> > # ping www.yahoo.com
> > ping: unknown host www.yahoo.com
> >=20
> > Any suggestions what to try now?  I'll go ahead and turn off the
> > bonding option and see if that helps.
> >=20
>=20
> It won't be related to bonding.
>=20
> It has a high probability of being very related to Herbert's changes
> to inet_set_ifa().

Hm, as inetdev_init() is now only called at the time the device is
registered, it seems wrong that inetdev_destroy() is also called in
__inet_del_ifa() when all addresses got deleted.

Miles, could you try if this patch helps?

Bj=F6rn


Stop destroying devices when all of their ifas are gone, as we no longe=
r
recreate them when ifas are added.

Signed-off-by: Bj=F6rn Steinbrink <B.Steinbrink@gmx.de>
--
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index fa97b96..abf6352 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -327,12 +327,8 @@ static void __inet_del_ifa(struct in_device *in_de=
v, struct in_ifaddr **ifap,
 		}
=20
 	}
-	if (destroy) {
+	if (destroy)
 		inet_free_ifa(ifa1);
-
-		if (!in_dev->ifa_list)
-			inetdev_destroy(in_dev);
-	}
 }
=20
 static void inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **=
ifap,
