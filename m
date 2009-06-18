From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: make namespace iteration possible under RCU
Date: Thu, 18 Jun 2009 14:15:04 +0200
Message-ID: <1245327304.13790.19.camel@johannes.local>
References: <1245323303.31588.86.camel@johannes.local>
	 <20090618114516.GA6107@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-jVx4K1ja94R1iH649Snw"
Cc: Netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:34829 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961AbZFRMPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 08:15:34 -0400
In-Reply-To: <20090618114516.GA6107@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jVx4K1ja94R1iH649Snw
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-06-18 at 13:45 +0200, Jiri Pirko wrote:
> Thu, Jun 18, 2009 at 01:08:23PM CEST, johannes@sipsolutions.net wrote:
> >All we need to take care of is using proper RCU list
> >add/del primitives and inserting a synchronize_rcu()
> >at one place to make sure the exit notifiers are run
> >after everybody has stopped iterating the list.
> >
> >Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> >---
> > include/net/net_namespace.h |    3 +++
> > net/core/net_namespace.c    |   10 +++++++---
> > 2 files changed, 10 insertions(+), 3 deletions(-)
> >
> >--- wireless-testing.orig/include/net/net_namespace.h	2009-06-18 01:36:2=
6.000000000 +0200
> >+++ wireless-testing/include/net/net_namespace.h	2009-06-18 02:17:14.000=
000000 +0200
> >@@ -211,6 +211,9 @@ static inline struct net *read_pnet(stru
> > #define for_each_net(VAR)				\
> > 	list_for_each_entry(VAR, &net_namespace_list, list)
> >=20
> >+#define for_each_net_rcu(VAR)				\
> >+	list_for_each_entry_rcu(VAR, &net_namespace_list, list)
> >+
> > #ifdef CONFIG_NET_NS
> > #define __net_init
> > #define __net_exit
> >--- wireless-testing.orig/net/core/net_namespace.c	2009-06-18 01:36:39.0=
00000000 +0200
> >+++ wireless-testing/net/core/net_namespace.c	2009-06-18 02:03:06.000000=
000 +0200
> >@@ -6,6 +6,7 @@
> > #include <linux/delay.h>
> > #include <linux/sched.h>
> > #include <linux/idr.h>
> >+#include <linux/rculist.h>
> > #include <net/net_namespace.h>
> > #include <net/netns/generic.h>
> >=20
> >@@ -134,7 +135,7 @@ struct net *copy_net_ns(unsigned long fl
> > 	err =3D setup_net(new_net);
> > 	if (!err) {
> > 		rtnl_lock();
> >-		list_add_tail(&new_net->list, &net_namespace_list);
> >+		list_add_tail_rcu(&new_net->list, &net_namespace_list);
> > 		rtnl_unlock();
> > 	}
> > 	mutex_unlock(&net_mutex);
> >@@ -163,9 +164,12 @@ static void cleanup_net(struct work_stru
> >=20
> > 	/* Don't let anyone else find us. */
> > 	rtnl_lock();
> >-	list_del(&net->list);
> >+	list_del_rcu(&net->list);
> > 	rtnl_unlock();
> >=20
> >+	/* if somebody is rcu-iterating the list, wait */
> >+	synchronize_rcu();
>=20
> IMHO you do not need to call synchronize_rcu() here since rcu_barrier() i=
s
> called later just before net_free(net). Seems redundant.

Heh, well, I discussed that earlier with Eric and we do not want anyone
to have a reference to the struct net while the pernet->exit calls are
run, and thus we do need it here.

johannes

--=-jVx4K1ja94R1iH649Snw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKOi/DAAoJEODzc/N7+QmauyIP/1jQVMjl6IDLRxSg/NmGpbVS
8y7y73kplmPNDzqbnhomUVz7c7Tdeb30dhuFKbknOlv8EgLbQNd2X5U5SrynGseU
fNK8Qu1xapRix94EOqOFsP8tetttxtg7TuyeMNRuIW54TlU2Fgy9sunGFHXqbfYT
7gv7q/y9BNM7LTH+mU5KIpTFhSx+mVx3Ugo/vkBqPRuy3pszizTpFV5mCBUOSRoL
2KAaisBe83+EhdjhIO+ykWAncDaAQe11TlGHYHEVeeCTDzKWy/8cGzxw2LcELDtl
SrFbDXpLmtJgweMnlogoARkIwCrOnRiujtqLL8WBHG0jHyUCb+k/zhtAKrdu+XXh
4uvIS2wWIzKbJQ6ETwc0Dz04PJiCEYWi4/nnPspuzK47xBpmZKtWIJsrr0kU+DY7
Ym+9pq0vIzBRt7zm87aC1lJgnkF2vus994dV1i3PQOO0Jr+RJtQFULsqRkTPqRZm
sQuqBrI36ExpB4NaG74yPnLGbZlqa/6dOaFsEguXpKhOPmafWv2EfkejxdXFxTfR
NnXuL//dyMjq+eLs0pb9r9CfBmtyh3qlL4ez0OijHOVw+Q4qcwq7BlMnl/BxiQBT
sREh+4jfucq+lW6Lx9zFdajASbZeJd17aqjB/7fPKBrM8+OuvauULRdyz1Cm/xiw
7lTdu+H3QI5EGzhfK0wO
=Fuus
-----END PGP SIGNATURE-----

--=-jVx4K1ja94R1iH649Snw--

