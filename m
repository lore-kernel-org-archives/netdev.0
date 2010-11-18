From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] bonding: IGMP handling cleanup
Date: Thu, 18 Nov 2010 11:49:12 +0100
Message-ID: <1290077352.2781.47.camel@edumazet-laptop>
References: <20101118091846.26534.38865.sendpatchset@localhost.localdomain>
	 <1290072794.2781.10.camel@edumazet-laptop>
	 <1290073388.2781.12.camel@edumazet-laptop>
	 <1290075978.2781.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	linux-next@vger.kernel.org, ursula.braun@de.ibm.com,
	Jay Vosburgh <fubar@us.ibm.com>
To: Sachin Sant <sachinp@in.ibm.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:42015 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754480Ab0KRKtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 05:49:17 -0500
In-Reply-To: <1290075978.2781.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 18 novembre 2010 =C3=A0 11:26 +0100, Eric Dumazet a =C3=A9crit=
 :

> Actually this raises an interesting case for bonding as well.
>=20
> Before my RCU conversion __bond_resend_igmp_join_requests() was unsaf=
e.
>=20
> For net-next-2.6, it is now safe (RCU is held), but needs a cleanup
> patch to avoid sparse errors.

[PATCH net-next-2.6] bonding: IGMP handling cleanup

Instead of iterating in_dev->mc_list from bonding driver, its better
to call a helper function provided by igmp.c
Details of implementation (locking) are private to igmp code.

ip_mc_rejoin_group(struct ip_mc_list *im) becomes
ip_mc_rejoin_groups(struct in_device *in_dev);

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Sachin Sant <sachinp@in.ibm.com>
---
 drivers/net/bonding/bond_main.c |    8 +------
 include/linux/igmp.h            |    2 -
 net/ipv4/igmp.c                 |   34 +++++++++++++++++-------------
 3 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 5188448..e588b2e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -873,15 +873,11 @@ static void bond_mc_del(struct bonding *bond, voi=
d *addr)
 static void __bond_resend_igmp_join_requests(struct net_device *dev)
 {
 	struct in_device *in_dev;
-	struct ip_mc_list *im;
=20
 	rcu_read_lock();
 	in_dev =3D __in_dev_get_rcu(dev);
-	if (in_dev) {
-		for (im =3D in_dev->mc_list; im; im =3D im->next)
-			ip_mc_rejoin_group(im);
-	}
-
+	if (in_dev)
+			ip_mc_rejoin_groups(in_dev);
 	rcu_read_unlock();
 }
=20
diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 7d16467..c4987f2 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -238,7 +238,7 @@ extern void ip_mc_unmap(struct in_device *);
 extern void ip_mc_remap(struct in_device *);
 extern void ip_mc_dec_group(struct in_device *in_dev, __be32 addr);
 extern void ip_mc_inc_group(struct in_device *in_dev, __be32 addr);
-extern void ip_mc_rejoin_group(struct ip_mc_list *im);
+extern void ip_mc_rejoin_groups(struct in_device *in_dev);
=20
 #endif
 #endif
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index afb1e82..35f0231 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1267,26 +1267,32 @@ EXPORT_SYMBOL(ip_mc_inc_group);
=20
 /*
  *	Resend IGMP JOIN report; used for bonding.
+ *	Called with rcu_read_lock()
  */
-void ip_mc_rejoin_group(struct ip_mc_list *im)
+void ip_mc_rejoin_groups(struct in_device *in_dev)
 {
 #ifdef CONFIG_IP_MULTICAST
-	struct in_device *in_dev =3D im->interface;
-
-	if (im->multiaddr =3D=3D IGMP_ALL_HOSTS)
-		return;
+	struct ip_mc_list *im;
+	int type;
+=09
+	for_each_pmc_rcu(in_dev, im) {
+		if (im->multiaddr =3D=3D IGMP_ALL_HOSTS)
+			continue;
=20
-	/* a failover is happening and switches
-	 * must be notified immediately */
-	if (IGMP_V1_SEEN(in_dev))
-		igmp_send_report(in_dev, im, IGMP_HOST_MEMBERSHIP_REPORT);
-	else if (IGMP_V2_SEEN(in_dev))
-		igmp_send_report(in_dev, im, IGMPV2_HOST_MEMBERSHIP_REPORT);
-	else
-		igmp_send_report(in_dev, im, IGMPV3_HOST_MEMBERSHIP_REPORT);
+		/* a failover is happening and switches
+		 * must be notified immediately
+		 */
+		if (IGMP_V1_SEEN(in_dev))
+			type =3D IGMP_HOST_MEMBERSHIP_REPORT;
+		else if (IGMP_V2_SEEN(in_dev))
+			type =3D IGMPV2_HOST_MEMBERSHIP_REPORT;
+		else
+			type =3D IGMPV3_HOST_MEMBERSHIP_REPORT;
+		igmp_send_report(in_dev, im, type);
+	}
 #endif
 }
-EXPORT_SYMBOL(ip_mc_rejoin_group);
+EXPORT_SYMBOL(ip_mc_rejoin_groups);
=20
 /*
  *	A socket has left a multicast group on device dev


