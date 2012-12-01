From: Sven Eckelmann <sven@narfation.org>
Subject: Re: [B.A.T.M.A.N.] [PATCH] net: fix possible deadlocks in rtnl_trylock/unlock
Date: Sat, 01 Dec 2012 19:07:56 +0100
Message-ID: <5233033.Yg8T20E3Sl@sven-laptop.home.narfation.org>
References: <1354382991-31350-1-git-send-email-siwu@hrz.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart4022694.fXEdSxRaOt"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	davem@davemloft.net, netdev@vger.kernel.org,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
To: b.a.t.m.a.n@lists.open-mesh.org, bridge@lists.linux-foundation.org,
	linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>, Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:40776 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752679Ab2LASIC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2012 13:08:02 -0500
In-Reply-To: <1354382991-31350-1-git-send-email-siwu@hrz.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart4022694.fXEdSxRaOt
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="ISO-8859-1"

On Saturday 01 December 2012 18:29:51 Simon Wunderlich wrote:
> If rtnl_trylock() is used to prevent circular dependencies, rtnl_unlock()
> may destroy this attempt because it first unlocks rtnl_mutex but may
> lock it again later. The callgraph roughly looks like:
> 
> rtnl_unlock()
>    netdev_run_todo()
>       __rtnl_unlock()
>       netdev_wait_allrefs()
>          rtnl_lock()
>          ...
>          __rtnl_unlock()
> 
> There are two users which have possible deadlocks and are fixed in this
> patch: batman-adv and bridge. Their problematic access pattern is the same:
> 
> notifier_call handler:
>  * holds rtnl lock when called
>  * calls sysfs code at some point (acquiring sysfs locks)
> 
> sysfs code:
>  * holds sysfs lock when called
>  * calls rtnl_trylock() and rtnl_unlock(), rtnl_unlock() calls rtnl_lock
>    implicitly
> 
> Fix this by exporting __rtnl_unlock() to just unlock the mutex without
> implicitly locking again.
> 
> Reported-by: Sven Eckelmann <sven@narfation.org>
> Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
> 
> ---
> Of course, an alternative would be to not lock again after unlocking
> within rtnl_unlock(), or put the todo handling into the locked section.
> I'm not familiar enough with this code to know what would be best.
> 
> There are others using rtnl_trylock(), but I'm not sure if they
> are affected.

At least they look like they have a problem in a parallel user scenario 
involving another lock and locking order (most of them s_active or a device 
lock). So just to list the places and poke some other users. They can better 
decide for themself because they know the code.

drivers/infiniband/ulp/ipoib/ipoib_cm.c:  if (!rtnl_trylock())
drivers/infiniband/ulp/ipoib/ipoib_vlan.c:        if (!rtnl_trylock())
drivers/infiniband/ulp/ipoib/ipoib_vlan.c:        if (!rtnl_trylock())
drivers/net/bonding/bond_alb.c:                   if (!rtnl_trylock()) {
drivers/net/bonding/bond_main.c:          if (!rtnl_trylock()) {
drivers/net/bonding/bond_main.c:          if (!rtnl_trylock()) {
drivers/net/bonding/bond_main.c:          if (!rtnl_trylock()) {
drivers/net/bonding/bond_main.c:          if (!rtnl_trylock()) {
drivers/net/bonding/bond_sysfs.c: if (!rtnl_trylock())
drivers/net/bonding/bond_sysfs.c: if (!rtnl_trylock())
drivers/net/bonding/bond_sysfs.c: if (!rtnl_trylock())
drivers/net/bonding/bond_sysfs.c: if (!rtnl_trylock())
drivers/net/bonding/bond_sysfs.c: if (!rtnl_trylock())
drivers/net/bonding/bond_sysfs.c: if (!rtnl_trylock())
drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c:  if (!rtnl_trylock())    /* 
synchronize with ifdown */
drivers/s390/net/qeth_l2_main.c:          if (rtnl_trylock()) {
drivers/s390/net/qeth_l3_main.c:          if (rtnl_trylock()) {
net/bridge/br_sysfs_br.c: if (!rtnl_trylock())
net/bridge/br_sysfs_if.c:         if (!rtnl_trylock())
net/core/net-sysfs.c:     if (!rtnl_trylock())
net/core/net-sysfs.c:     if (!rtnl_trylock())
net/core/net-sysfs.c:     if (!rtnl_trylock())
net/core/net-sysfs.c:     if (!rtnl_trylock())
net/core/net-sysfs.c:     if (!rtnl_trylock())
net/ipv4/devinet.c:                       if (!rtnl_trylock()) {
net/ipv6/addrconf.c:      if (!rtnl_trylock())
net/ipv6/addrconf.c:      if (!rtnl_trylock())

Kind regards,
	Sven
--nextPart4022694.fXEdSxRaOt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQukd8AAoJEF2HCgfBJntGjQAP/iZNTmIofZitO2/2cOQ8+87S
PwWyB7onTT1f0YW96anwb/fas+X5+9gd2DhIX1b7IywuJ02Y8MiY5vaCUSkmCdi9
2MUSGk4l+dRCu3H4Bo/8iNZyEFgDeZXp+YeJkq7Ry8riYWCAEnIG/zdigqBVUO+N
3mMcs9wEbzj2tBBIzkXyPrB5Gm4sut6nmjOxNbDY7CIb7VWQI/s4r5kqb+uKYsLL
Xl75m/HR45ZcS71uw7s62u+A+eyYW9o937If4rgMWmoO/MEl5LIXa7i7+xcfSNUQ
HUT367nmM+AMjLozlFbGsqOKDlUQIZLRj1uVAjcXSIeqf7ObnTdlJp1Gp0NHlBv9
4YRPldVO+wU5tB6zazvs4JLtf3/+9iz0bYQ0Afw4BFwSLWHhOfVc4JO4CGO2iHqP
9CWgM+eirZ0lVTBgTrANpX+M+iVQN2zPGDuS/iNyh6BNtu0SHo/Wih1TIjivYKTn
Z2B4bcms085ipdAMCoboBnmTeCYIUDm51Sf16To0oikZb45Z1DBhm6tMfIl1QyM2
Dp4FinhmcZBuAO8LBVTYfQisLiL26XWs+q4g+MS5QJXe9NbfdjkvIAjGu/J2e9FL
XEwXPhnlU9WDPIZn5dtiEftVPKF4zPdo0Dt5UPczvhvkaQaMIUzCu/NiAfuGNLgp
kS9injKwBA5v1cZCfBZK
=E+pM
-----END PGP SIGNATURE-----

--nextPart4022694.fXEdSxRaOt--
