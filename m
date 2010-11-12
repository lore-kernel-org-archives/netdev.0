From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] igmp: RCU conversion of in_dev->mc_list
Date: Fri, 12 Nov 2010 14:34:18 +0100
Message-ID: <1289568858.3185.252.camel@edumazet-laptop>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
	 <1289489007.17691.1310.camel@edumazet-laptop>
	 <AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
	 <20101112071323.GB5660@cr0.nay.redhat.com>
	 <1289546874.17691.1774.camel@edumazet-laptop>
	 <20101112081945.GA5949@cr0.nay.redhat.com>
	 <1289553759.3185.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cypher Wu <cypher.w@gmail.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1289553759.3185.1.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 12 novembre 2010 =C3=A0 10:22 +0100, Eric Dumazet a =C3=A9c=
rit :
> Le vendredi 12 novembre 2010 =C3=A0 16:19 +0800, Am=C3=A9rico Wang a =
=C3=A9crit :
> > On Fri, Nov 12, 2010 at 08:27:54AM +0100, Eric Dumazet wrote:
>=20
> > >A RCU conversion is far more complex.
> > >
> >=20
> > Yup.
>=20
>=20
> Well, actually this is easy in this case.
>=20
> I'll post a patch to do this RCU conversion.
>=20
>=20

Note : compile tested only, I'll appreciate if someone can test it ;)

Note: one patch from net-2.6 is not yet included in net-next-2.6, so
please make sure you have it before testing ;)

( http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcom=
mitdiff;h=3D18943d292facbc70e6a36fc62399ae833f64671b )


Thanks

[PATCH net-next-2.6] igmp: RCU conversion of in_dev->mc_list

in_dev->mc_list is protected by one rwlock (in_dev->mc_list_lock).

This can easily be converted to a RCU protection.

Writers hold RTNL, so mc_list_lock is removed, not replaced by a
spinlock.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Cypher Wu <cypher.w@gmail.com>
Cc: Am=C3=A9rico Wang <xiyou.wangcong@gmail.com>
---
 include/linux/igmp.h       |   12 +
 include/linux/inetdevice.h |    5=20
 include/net/inet_sock.h    |    2=20
 net/ipv4/igmp.c            |  223 ++++++++++++++++-------------------
 4 files changed, 115 insertions(+), 127 deletions(-)

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 93fc244..7d16467 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -167,10 +167,10 @@ struct ip_sf_socklist {
  */
=20
 struct ip_mc_socklist {
-	struct ip_mc_socklist	*next;
+	struct ip_mc_socklist __rcu *next_rcu;
 	struct ip_mreqn		multi;
 	unsigned int		sfmode;		/* MCAST_{INCLUDE,EXCLUDE} */
-	struct ip_sf_socklist	*sflist;
+	struct ip_sf_socklist __rcu	*sflist;
 	struct rcu_head		rcu;
 };
=20
@@ -186,11 +186,14 @@ struct ip_sf_list {
 struct ip_mc_list {
 	struct in_device	*interface;
 	__be32			multiaddr;
+	unsigned int		sfmode;
 	struct ip_sf_list	*sources;
 	struct ip_sf_list	*tomb;
-	unsigned int		sfmode;
 	unsigned long		sfcount[2];
-	struct ip_mc_list	*next;
+	union {
+		struct ip_mc_list *next;
+		struct ip_mc_list __rcu *next_rcu;
+	};
 	struct timer_list	timer;
 	int			users;
 	atomic_t		refcnt;
@@ -201,6 +204,7 @@ struct ip_mc_list {
 	char			loaded;
 	unsigned char		gsquery;	/* check source marks? */
 	unsigned char		crcount;
+	struct rcu_head		rcu;
 };
=20
 /* V3 exponential field decoding */
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index ccd5b07..380ba6b 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -52,9 +52,8 @@ struct in_device {
 	atomic_t		refcnt;
 	int			dead;
 	struct in_ifaddr	*ifa_list;	/* IP ifaddr chain		*/
-	rwlock_t		mc_list_lock;
-	struct ip_mc_list	*mc_list;	/* IP multicast filter chain    */
-	int			mc_count;	          /* Number of installed mcasts	*/
+	struct ip_mc_list __rcu	*mc_list;	/* IP multicast filter chain    */
+	int			mc_count;	/* Number of installed mcasts	*/
 	spinlock_t		mc_tomb_lock;
 	struct ip_mc_list	*mc_tomb;
 	unsigned long		mr_v1_seen;
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 1989cfd..8945f9f 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -141,7 +141,7 @@ struct inet_sock {
 				nodefrag:1;
 	int			mc_index;
 	__be32			mc_addr;
-	struct ip_mc_socklist	*mc_list;
+	struct ip_mc_socklist __rcu	*mc_list;
 	struct {
 		unsigned int		flags;
 		unsigned int		fragsize;
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 08d0d81..ff4e5fd 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -149,11 +149,17 @@ static void ip_mc_clear_src(struct ip_mc_list *pm=
c);
 static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int s=
fmode,
 			 int sfcount, __be32 *psfsrc, int delta);
=20
+
+static void ip_mc_list_reclaim(struct rcu_head *head)
+{
+	kfree(container_of(head, struct ip_mc_list, rcu));
+}
+
 static void ip_ma_put(struct ip_mc_list *im)
 {
 	if (atomic_dec_and_test(&im->refcnt)) {
 		in_dev_put(im->interface);
-		kfree(im);
+		call_rcu(&im->rcu, ip_mc_list_reclaim);
 	}
 }
=20
@@ -163,7 +169,7 @@ static void ip_ma_put(struct ip_mc_list *im)
  *	Timer management
  */
=20
-static __inline__ void igmp_stop_timer(struct ip_mc_list *im)
+static void igmp_stop_timer(struct ip_mc_list *im)
 {
 	spin_lock_bh(&im->lock);
 	if (del_timer(&im->timer))
@@ -496,14 +502,24 @@ empty_source:
 	return skb;
 }
=20
+#define for_each_pmc_rcu(in_dev, pmc)				\
+	for (pmc =3D rcu_dereference(in_dev->mc_list);		\
+	     pmc !=3D NULL;					\
+	     pmc =3D rcu_dereference(pmc->next_rcu))
+
+#define for_each_pmc_rtnl(in_dev, pmc)				\
+	for (pmc =3D rtnl_dereference(in_dev->mc_list);		\
+	     pmc !=3D NULL;					\
+	     pmc =3D rtnl_dereference(pmc->next_rcu))
+
 static int igmpv3_send_report(struct in_device *in_dev, struct ip_mc_l=
ist *pmc)
 {
 	struct sk_buff *skb =3D NULL;
 	int type;
=20
 	if (!pmc) {
-		read_lock(&in_dev->mc_list_lock);
-		for (pmc=3Din_dev->mc_list; pmc; pmc=3Dpmc->next) {
+		rcu_read_lock();
+		for_each_pmc_rcu(in_dev, pmc) {
 			if (pmc->multiaddr =3D=3D IGMP_ALL_HOSTS)
 				continue;
 			spin_lock_bh(&pmc->lock);
@@ -514,7 +530,7 @@ static int igmpv3_send_report(struct in_device *in_=
dev, struct ip_mc_list *pmc)
 			skb =3D add_grec(skb, pmc, type, 0, 0);
 			spin_unlock_bh(&pmc->lock);
 		}
-		read_unlock(&in_dev->mc_list_lock);
+		rcu_read_unlock();
 	} else {
 		spin_lock_bh(&pmc->lock);
 		if (pmc->sfcount[MCAST_EXCLUDE])
@@ -556,7 +572,7 @@ static void igmpv3_send_cr(struct in_device *in_dev=
)
 	struct sk_buff *skb =3D NULL;
 	int type, dtype;
=20
-	read_lock(&in_dev->mc_list_lock);
+	rcu_read_lock();
 	spin_lock_bh(&in_dev->mc_tomb_lock);
=20
 	/* deleted MCA's */
@@ -593,7 +609,7 @@ static void igmpv3_send_cr(struct in_device *in_dev=
)
 	spin_unlock_bh(&in_dev->mc_tomb_lock);
=20
 	/* change recs */
-	for (pmc=3Din_dev->mc_list; pmc; pmc=3Dpmc->next) {
+	for_each_pmc_rcu(in_dev, pmc) {
 		spin_lock_bh(&pmc->lock);
 		if (pmc->sfcount[MCAST_EXCLUDE]) {
 			type =3D IGMPV3_BLOCK_OLD_SOURCES;
@@ -616,7 +632,7 @@ static void igmpv3_send_cr(struct in_device *in_dev=
)
 		}
 		spin_unlock_bh(&pmc->lock);
 	}
-	read_unlock(&in_dev->mc_list_lock);
+	rcu_read_unlock();
=20
 	if (!skb)
 		return;
@@ -813,14 +829,14 @@ static void igmp_heard_report(struct in_device *i=
n_dev, __be32 group)
 	if (group =3D=3D IGMP_ALL_HOSTS)
 		return;
=20
-	read_lock(&in_dev->mc_list_lock);
-	for (im=3Din_dev->mc_list; im!=3DNULL; im=3Dim->next) {
+	rcu_read_lock();
+	for_each_pmc_rcu(in_dev, im) {
 		if (im->multiaddr =3D=3D group) {
 			igmp_stop_timer(im);
 			break;
 		}
 	}
-	read_unlock(&in_dev->mc_list_lock);
+	rcu_read_unlock();
 }
=20
 static void igmp_heard_query(struct in_device *in_dev, struct sk_buff =
*skb,
@@ -906,8 +922,8 @@ static void igmp_heard_query(struct in_device *in_d=
ev, struct sk_buff *skb,
 	 * - Use the igmp->igmp_code field as the maximum
 	 *   delay possible
 	 */
-	read_lock(&in_dev->mc_list_lock);
-	for (im=3Din_dev->mc_list; im!=3DNULL; im=3Dim->next) {
+	rcu_read_lock();
+	for_each_pmc_rcu(in_dev, im) {
 		int changed;
=20
 		if (group && group !=3D im->multiaddr)
@@ -925,7 +941,7 @@ static void igmp_heard_query(struct in_device *in_d=
ev, struct sk_buff *skb,
 		if (changed)
 			igmp_mod_timer(im, max_delay);
 	}
-	read_unlock(&in_dev->mc_list_lock);
+	rcu_read_unlock();
 }
=20
 /* called in rcu_read_lock() section */
@@ -1110,8 +1126,8 @@ static void igmpv3_clear_delrec(struct in_device =
*in_dev)
 		kfree(pmc);
 	}
 	/* clear dead sources, too */
-	read_lock(&in_dev->mc_list_lock);
-	for (pmc=3Din_dev->mc_list; pmc; pmc=3Dpmc->next) {
+	rcu_read_lock();
+	for_each_pmc_rcu(in_dev, pmc) {
 		struct ip_sf_list *psf, *psf_next;
=20
 		spin_lock_bh(&pmc->lock);
@@ -1123,7 +1139,7 @@ static void igmpv3_clear_delrec(struct in_device =
*in_dev)
 			kfree(psf);
 		}
 	}
-	read_unlock(&in_dev->mc_list_lock);
+	rcu_read_unlock();
 }
 #endif
=20
@@ -1209,7 +1225,7 @@ void ip_mc_inc_group(struct in_device *in_dev, __=
be32 addr)
=20
 	ASSERT_RTNL();
=20
-	for (im=3Din_dev->mc_list; im; im=3Dim->next) {
+	for_each_pmc_rtnl(in_dev, im) {
 		if (im->multiaddr =3D=3D addr) {
 			im->users++;
 			ip_mc_add_src(in_dev, &addr, MCAST_EXCLUDE, 0, NULL, 0);
@@ -1217,7 +1233,7 @@ void ip_mc_inc_group(struct in_device *in_dev, __=
be32 addr)
 		}
 	}
=20
-	im =3D kmalloc(sizeof(*im), GFP_KERNEL);
+	im =3D kzalloc(sizeof(*im), GFP_KERNEL);
 	if (!im)
 		goto out;
=20
@@ -1227,26 +1243,18 @@ void ip_mc_inc_group(struct in_device *in_dev, =
__be32 addr)
 	im->multiaddr =3D addr;
 	/* initial mode is (EX, empty) */
 	im->sfmode =3D MCAST_EXCLUDE;
-	im->sfcount[MCAST_INCLUDE] =3D 0;
 	im->sfcount[MCAST_EXCLUDE] =3D 1;
-	im->sources =3D NULL;
-	im->tomb =3D NULL;
-	im->crcount =3D 0;
 	atomic_set(&im->refcnt, 1);
 	spin_lock_init(&im->lock);
 #ifdef CONFIG_IP_MULTICAST
-	im->tm_running =3D 0;
 	setup_timer(&im->timer, &igmp_timer_expire, (unsigned long)im);
 	im->unsolicit_count =3D IGMP_Unsolicited_Report_Count;
-	im->reporter =3D 0;
-	im->gsquery =3D 0;
 #endif
-	im->loaded =3D 0;
-	write_lock_bh(&in_dev->mc_list_lock);
-	im->next =3D in_dev->mc_list;
-	in_dev->mc_list =3D im;
+
+	im->next_rcu =3D in_dev->mc_list;
 	in_dev->mc_count++;
-	write_unlock_bh(&in_dev->mc_list_lock);
+	rcu_assign_pointer(in_dev->mc_list, im);
+
 #ifdef CONFIG_IP_MULTICAST
 	igmpv3_del_delrec(in_dev, im->multiaddr);
 #endif
@@ -1287,17 +1295,18 @@ EXPORT_SYMBOL(ip_mc_rejoin_group);
=20
 void ip_mc_dec_group(struct in_device *in_dev, __be32 addr)
 {
-	struct ip_mc_list *i, **ip;
+	struct ip_mc_list *i;
+	struct ip_mc_list __rcu **ip;
=20
 	ASSERT_RTNL();
=20
-	for (ip=3D&in_dev->mc_list; (i=3D*ip)!=3DNULL; ip=3D&i->next) {
+	for (ip =3D &in_dev->mc_list;
+	     (i =3D rtnl_dereference(*ip)) !=3D NULL;
+	     ip =3D &i->next_rcu) {
 		if (i->multiaddr =3D=3D addr) {
 			if (--i->users =3D=3D 0) {
-				write_lock_bh(&in_dev->mc_list_lock);
-				*ip =3D i->next;
+				*ip =3D i->next_rcu;
 				in_dev->mc_count--;
-				write_unlock_bh(&in_dev->mc_list_lock);
 				igmp_group_dropped(i);
=20
 				if (!in_dev->dead)
@@ -1316,34 +1325,34 @@ EXPORT_SYMBOL(ip_mc_dec_group);
=20
 void ip_mc_unmap(struct in_device *in_dev)
 {
-	struct ip_mc_list *i;
+	struct ip_mc_list *pmc;
=20
 	ASSERT_RTNL();
=20
-	for (i =3D in_dev->mc_list; i; i =3D i->next)
-		igmp_group_dropped(i);
+	for_each_pmc_rtnl(in_dev, pmc)
+		igmp_group_dropped(pmc);
 }
=20
 void ip_mc_remap(struct in_device *in_dev)
 {
-	struct ip_mc_list *i;
+	struct ip_mc_list *pmc;
=20
 	ASSERT_RTNL();
=20
-	for (i =3D in_dev->mc_list; i; i =3D i->next)
-		igmp_group_added(i);
+	for_each_pmc_rtnl(in_dev, pmc)
+		igmp_group_added(pmc);
 }
=20
 /* Device going down */
=20
 void ip_mc_down(struct in_device *in_dev)
 {
-	struct ip_mc_list *i;
+	struct ip_mc_list *pmc;
=20
 	ASSERT_RTNL();
=20
-	for (i=3Din_dev->mc_list; i; i=3Di->next)
-		igmp_group_dropped(i);
+	for_each_pmc_rtnl(in_dev, pmc)
+		igmp_group_dropped(pmc);
=20
 #ifdef CONFIG_IP_MULTICAST
 	in_dev->mr_ifc_count =3D 0;
@@ -1374,7 +1383,6 @@ void ip_mc_init_dev(struct in_device *in_dev)
 	in_dev->mr_qrv =3D IGMP_Unsolicited_Report_Count;
 #endif
=20
-	rwlock_init(&in_dev->mc_list_lock);
 	spin_lock_init(&in_dev->mc_tomb_lock);
 }
=20
@@ -1382,14 +1390,14 @@ void ip_mc_init_dev(struct in_device *in_dev)
=20
 void ip_mc_up(struct in_device *in_dev)
 {
-	struct ip_mc_list *i;
+	struct ip_mc_list *pmc;
=20
 	ASSERT_RTNL();
=20
 	ip_mc_inc_group(in_dev, IGMP_ALL_HOSTS);
=20
-	for (i=3Din_dev->mc_list; i; i=3Di->next)
-		igmp_group_added(i);
+	for_each_pmc_rtnl(in_dev, pmc);
+		igmp_group_added(pmc);
 }
=20
 /*
@@ -1405,17 +1413,13 @@ void ip_mc_destroy_dev(struct in_device *in_dev=
)
 	/* Deactivate timers */
 	ip_mc_down(in_dev);
=20
-	write_lock_bh(&in_dev->mc_list_lock);
-	while ((i =3D in_dev->mc_list) !=3D NULL) {
-		in_dev->mc_list =3D i->next;
+	while ((i =3D rtnl_dereference(in_dev->mc_list)) !=3D NULL) {
+		in_dev->mc_list =3D i->next_rcu;
 		in_dev->mc_count--;
-		write_unlock_bh(&in_dev->mc_list_lock);
+
 		igmp_group_dropped(i);
 		ip_ma_put(i);
-
-		write_lock_bh(&in_dev->mc_list_lock);
 	}
-	write_unlock_bh(&in_dev->mc_list_lock);
 }
=20
 /* RTNL is locked */
@@ -1513,18 +1517,18 @@ static int ip_mc_del_src(struct in_device *in_d=
ev, __be32 *pmca, int sfmode,
=20
 	if (!in_dev)
 		return -ENODEV;
-	read_lock(&in_dev->mc_list_lock);
-	for (pmc=3Din_dev->mc_list; pmc; pmc=3Dpmc->next) {
+	rcu_read_lock();
+	for_each_pmc_rcu(in_dev, pmc) {
 		if (*pmca =3D=3D pmc->multiaddr)
 			break;
 	}
 	if (!pmc) {
 		/* MCA not found?? bug */
-		read_unlock(&in_dev->mc_list_lock);
+		rcu_read_unlock();
 		return -ESRCH;
 	}
 	spin_lock_bh(&pmc->lock);
-	read_unlock(&in_dev->mc_list_lock);
+	rcu_read_unlock();
 #ifdef CONFIG_IP_MULTICAST
 	sf_markstate(pmc);
 #endif
@@ -1685,18 +1689,18 @@ static int ip_mc_add_src(struct in_device *in_d=
ev, __be32 *pmca, int sfmode,
=20
 	if (!in_dev)
 		return -ENODEV;
-	read_lock(&in_dev->mc_list_lock);
-	for (pmc=3Din_dev->mc_list; pmc; pmc=3Dpmc->next) {
+	rcu_read_lock();
+	for_each_pmc_rcu(in_dev, pmc) {
 		if (*pmca =3D=3D pmc->multiaddr)
 			break;
 	}
 	if (!pmc) {
 		/* MCA not found?? bug */
-		read_unlock(&in_dev->mc_list_lock);
+		rcu_read_unlock();
 		return -ESRCH;
 	}
 	spin_lock_bh(&pmc->lock);
-	read_unlock(&in_dev->mc_list_lock);
+	rcu_read_unlock();
=20
 #ifdef CONFIG_IP_MULTICAST
 	sf_markstate(pmc);
@@ -1793,7 +1797,7 @@ int ip_mc_join_group(struct sock *sk , struct ip_=
mreqn *imr)
=20
 	err =3D -EADDRINUSE;
 	ifindex =3D imr->imr_ifindex;
-	for (i =3D inet->mc_list; i; i =3D i->next) {
+	for_each_pmc_rtnl(inet, i) {
 		if (i->multi.imr_multiaddr.s_addr =3D=3D addr &&
 		    i->multi.imr_ifindex =3D=3D ifindex)
 			goto done;
@@ -1807,7 +1811,7 @@ int ip_mc_join_group(struct sock *sk , struct ip_=
mreqn *imr)
 		goto done;
=20
 	memcpy(&iml->multi, imr, sizeof(*imr));
-	iml->next =3D inet->mc_list;
+	iml->next_rcu =3D inet->mc_list;
 	iml->sflist =3D NULL;
 	iml->sfmode =3D MCAST_EXCLUDE;
 	rcu_assign_pointer(inet->mc_list, iml);
@@ -1821,17 +1825,14 @@ EXPORT_SYMBOL(ip_mc_join_group);
=20
 static void ip_sf_socklist_reclaim(struct rcu_head *rp)
 {
-	struct ip_sf_socklist *psf;
-
-	psf =3D container_of(rp, struct ip_sf_socklist, rcu);
+	kfree(container_of(rp, struct ip_sf_socklist, rcu));
 	/* sk_omem_alloc should have been decreased by the caller*/
-	kfree(psf);
 }
=20
 static int ip_mc_leave_src(struct sock *sk, struct ip_mc_socklist *iml=
,
 			   struct in_device *in_dev)
 {
-	struct ip_sf_socklist *psf =3D iml->sflist;
+	struct ip_sf_socklist *psf =3D rtnl_dereference(iml->sflist);
 	int err;
=20
 	if (psf =3D=3D NULL) {
@@ -1851,11 +1852,8 @@ static int ip_mc_leave_src(struct sock *sk, stru=
ct ip_mc_socklist *iml,
=20
 static void ip_mc_socklist_reclaim(struct rcu_head *rp)
 {
-	struct ip_mc_socklist *iml;
-
-	iml =3D container_of(rp, struct ip_mc_socklist, rcu);
+	kfree(container_of(rp, struct ip_mc_socklist, rcu));
 	/* sk_omem_alloc should have been decreased by the caller*/
-	kfree(iml);
 }
=20
=20
@@ -1866,7 +1864,8 @@ static void ip_mc_socklist_reclaim(struct rcu_hea=
d *rp)
 int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 {
 	struct inet_sock *inet =3D inet_sk(sk);
-	struct ip_mc_socklist *iml, **imlp;
+	struct ip_mc_socklist *iml;
+	struct ip_mc_socklist __rcu **imlp;
 	struct in_device *in_dev;
 	struct net *net =3D sock_net(sk);
 	__be32 group =3D imr->imr_multiaddr.s_addr;
@@ -1876,7 +1875,9 @@ int ip_mc_leave_group(struct sock *sk, struct ip_=
mreqn *imr)
 	rtnl_lock();
 	in_dev =3D ip_mc_find_dev(net, imr);
 	ifindex =3D imr->imr_ifindex;
-	for (imlp =3D &inet->mc_list; (iml =3D *imlp) !=3D NULL; imlp =3D &im=
l->next) {
+	for (imlp =3D &inet->mc_list;
+	     (iml =3D rtnl_dereference(*imlp)) !=3D NULL;
+	     imlp =3D &iml->next_rcu) {
 		if (iml->multi.imr_multiaddr.s_addr !=3D group)
 			continue;
 		if (ifindex) {
@@ -1888,7 +1889,7 @@ int ip_mc_leave_group(struct sock *sk, struct ip_=
mreqn *imr)
=20
 		(void) ip_mc_leave_src(sk, iml, in_dev);
=20
-		rcu_assign_pointer(*imlp, iml->next);
+		*imlp =3D iml->next_rcu;
=20
 		if (in_dev)
 			ip_mc_dec_group(in_dev, group);
@@ -1934,7 +1935,7 @@ int ip_mc_source(int add, int omode, struct sock =
*sk, struct
 	}
 	err =3D -EADDRNOTAVAIL;
=20
-	for (pmc=3Dinet->mc_list; pmc; pmc=3Dpmc->next) {
+	for_each_pmc_rtnl(inet, pmc) {
 		if ((pmc->multi.imr_multiaddr.s_addr =3D=3D
 		     imr.imr_multiaddr.s_addr) &&
 		    (pmc->multi.imr_ifindex =3D=3D imr.imr_ifindex))
@@ -1958,7 +1959,7 @@ int ip_mc_source(int add, int omode, struct sock =
*sk, struct
 		pmc->sfmode =3D omode;
 	}
=20
-	psl =3D pmc->sflist;
+	psl =3D rtnl_dereference(pmc->sflist);
 	if (!add) {
 		if (!psl)
 			goto done;	/* err =3D -EADDRNOTAVAIL */
@@ -2077,7 +2078,7 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msf=
ilter *msf, int ifindex)
 		goto done;
 	}
=20
-	for (pmc=3Dinet->mc_list; pmc; pmc=3Dpmc->next) {
+	for_each_pmc_rtnl(inet, pmc) {
 		if (pmc->multi.imr_multiaddr.s_addr =3D=3D msf->imsf_multiaddr &&
 		    pmc->multi.imr_ifindex =3D=3D imr.imr_ifindex)
 			break;
@@ -2107,7 +2108,7 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msf=
ilter *msf, int ifindex)
 		(void) ip_mc_add_src(in_dev, &msf->imsf_multiaddr,
 				     msf->imsf_fmode, 0, NULL, 0);
 	}
-	psl =3D pmc->sflist;
+	psl =3D rtnl_dereference(pmc->sflist);
 	if (psl) {
 		(void) ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
 			psl->sl_count, psl->sl_addr, 0);
@@ -2155,7 +2156,7 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfil=
ter *msf,
 	}
 	err =3D -EADDRNOTAVAIL;
=20
-	for (pmc=3Dinet->mc_list; pmc; pmc=3Dpmc->next) {
+	for_each_pmc_rtnl(inet, pmc) {
 		if (pmc->multi.imr_multiaddr.s_addr =3D=3D msf->imsf_multiaddr &&
 		    pmc->multi.imr_ifindex =3D=3D imr.imr_ifindex)
 			break;
@@ -2163,7 +2164,7 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfil=
ter *msf,
 	if (!pmc)		/* must have a prior join */
 		goto done;
 	msf->imsf_fmode =3D pmc->sfmode;
-	psl =3D pmc->sflist;
+	psl =3D rtnl_dereference(pmc->sflist);
 	rtnl_unlock();
 	if (!psl) {
 		len =3D 0;
@@ -2208,7 +2209,7 @@ int ip_mc_gsfget(struct sock *sk, struct group_fi=
lter *gsf,
=20
 	err =3D -EADDRNOTAVAIL;
=20
-	for (pmc=3Dinet->mc_list; pmc; pmc=3Dpmc->next) {
+	for_each_pmc_rtnl(inet, pmc) {
 		if (pmc->multi.imr_multiaddr.s_addr =3D=3D addr &&
 		    pmc->multi.imr_ifindex =3D=3D gsf->gf_interface)
 			break;
@@ -2216,7 +2217,7 @@ int ip_mc_gsfget(struct sock *sk, struct group_fi=
lter *gsf,
 	if (!pmc)		/* must have a prior join */
 		goto done;
 	gsf->gf_fmode =3D pmc->sfmode;
-	psl =3D pmc->sflist;
+	psl =3D rtnl_dereference(pmc->sflist);
 	rtnl_unlock();
 	count =3D psl ? psl->sl_count : 0;
 	copycount =3D count < gsf->gf_numsrc ? count : gsf->gf_numsrc;
@@ -2257,7 +2258,7 @@ int ip_mc_sf_allow(struct sock *sk, __be32 loc_ad=
dr, __be32 rmt_addr, int dif)
 		goto out;
=20
 	rcu_read_lock();
-	for (pmc=3Drcu_dereference(inet->mc_list); pmc; pmc=3Drcu_dereference=
(pmc->next)) {
+	for_each_pmc_rcu(inet, pmc) {
 		if (pmc->multi.imr_multiaddr.s_addr =3D=3D loc_addr &&
 		    pmc->multi.imr_ifindex =3D=3D dif)
 			break;
@@ -2265,7 +2266,7 @@ int ip_mc_sf_allow(struct sock *sk, __be32 loc_ad=
dr, __be32 rmt_addr, int dif)
 	ret =3D inet->mc_all;
 	if (!pmc)
 		goto unlock;
-	psl =3D pmc->sflist;
+	psl =3D rcu_dereference(pmc->sflist);
 	ret =3D (pmc->sfmode =3D=3D MCAST_EXCLUDE);
 	if (!psl)
 		goto unlock;
@@ -2300,10 +2301,10 @@ void ip_mc_drop_socket(struct sock *sk)
 		return;
=20
 	rtnl_lock();
-	while ((iml =3D inet->mc_list) !=3D NULL) {
+	while ((iml =3D rtnl_dereference(inet->mc_list)) !=3D NULL) {
 		struct in_device *in_dev;
-		rcu_assign_pointer(inet->mc_list, iml->next);
=20
+		inet->mc_list =3D iml->next_rcu;
 		in_dev =3D inetdev_by_index(net, iml->multi.imr_ifindex);
 		(void) ip_mc_leave_src(sk, iml, in_dev);
 		if (in_dev !=3D NULL) {
@@ -2323,8 +2324,8 @@ int ip_check_mc(struct in_device *in_dev, __be32 =
mc_addr, __be32 src_addr, u16 p
 	struct ip_sf_list *psf;
 	int rv =3D 0;
=20
-	read_lock(&in_dev->mc_list_lock);
-	for (im=3Din_dev->mc_list; im; im=3Dim->next) {
+	rcu_read_lock();
+	for_each_pmc_rcu(in_dev, im) {
 		if (im->multiaddr =3D=3D mc_addr)
 			break;
 	}
@@ -2345,7 +2346,7 @@ int ip_check_mc(struct in_device *in_dev, __be32 =
mc_addr, __be32 src_addr, u16 p
 		} else
 			rv =3D 1; /* unspecified source; tentatively allow */
 	}
-	read_unlock(&in_dev->mc_list_lock);
+	rcu_read_unlock();
 	return rv;
 }
=20
@@ -2371,13 +2372,11 @@ static inline struct ip_mc_list *igmp_mc_get_fi=
rst(struct seq_file *seq)
 		in_dev =3D __in_dev_get_rcu(state->dev);
 		if (!in_dev)
 			continue;
-		read_lock(&in_dev->mc_list_lock);
-		im =3D in_dev->mc_list;
+		im =3D rcu_dereference(in_dev->mc_list);
 		if (im) {
 			state->in_dev =3D in_dev;
 			break;
 		}
-		read_unlock(&in_dev->mc_list_lock);
 	}
 	return im;
 }
@@ -2385,11 +2384,9 @@ static inline struct ip_mc_list *igmp_mc_get_fir=
st(struct seq_file *seq)
 static struct ip_mc_list *igmp_mc_get_next(struct seq_file *seq, struc=
t ip_mc_list *im)
 {
 	struct igmp_mc_iter_state *state =3D igmp_mc_seq_private(seq);
-	im =3D im->next;
-	while (!im) {
-		if (likely(state->in_dev !=3D NULL))
-			read_unlock(&state->in_dev->mc_list_lock);
=20
+	im =3D rcu_dereference(im->next_rcu);
+	while (!im) {
 		state->dev =3D next_net_device_rcu(state->dev);
 		if (!state->dev) {
 			state->in_dev =3D NULL;
@@ -2398,8 +2395,7 @@ static struct ip_mc_list *igmp_mc_get_next(struct=
 seq_file *seq, struct ip_mc_li
 		state->in_dev =3D __in_dev_get_rcu(state->dev);
 		if (!state->in_dev)
 			continue;
-		read_lock(&state->in_dev->mc_list_lock);
-		im =3D state->in_dev->mc_list;
+		im =3D rcu_dereference(state->in_dev->mc_list);
 	}
 	return im;
 }
@@ -2435,10 +2431,8 @@ static void igmp_mc_seq_stop(struct seq_file *se=
q, void *v)
 	__releases(rcu)
 {
 	struct igmp_mc_iter_state *state =3D igmp_mc_seq_private(seq);
-	if (likely(state->in_dev !=3D NULL)) {
-		read_unlock(&state->in_dev->mc_list_lock);
-		state->in_dev =3D NULL;
-	}
+
+	state->in_dev =3D NULL;
 	state->dev =3D NULL;
 	rcu_read_unlock();
 }
@@ -2460,7 +2454,7 @@ static int igmp_mc_seq_show(struct seq_file *seq,=
 void *v)
 		querier =3D "NONE";
 #endif
=20
-		if (state->in_dev->mc_list =3D=3D im) {
+		if (rcu_dereference(state->in_dev->mc_list) =3D=3D im) {
 			seq_printf(seq, "%d\t%-10s: %5d %7s\n",
 				   state->dev->ifindex, state->dev->name, state->in_dev->mc_count,=
 querier);
 		}
@@ -2519,8 +2513,7 @@ static inline struct ip_sf_list *igmp_mcf_get_fir=
st(struct seq_file *seq)
 		idev =3D __in_dev_get_rcu(state->dev);
 		if (unlikely(idev =3D=3D NULL))
 			continue;
-		read_lock(&idev->mc_list_lock);
-		im =3D idev->mc_list;
+		im =3D rcu_dereference(idev->mc_list);
 		if (likely(im !=3D NULL)) {
 			spin_lock_bh(&im->lock);
 			psf =3D im->sources;
@@ -2531,7 +2524,6 @@ static inline struct ip_sf_list *igmp_mcf_get_fir=
st(struct seq_file *seq)
 			}
 			spin_unlock_bh(&im->lock);
 		}
-		read_unlock(&idev->mc_list_lock);
 	}
 	return psf;
 }
@@ -2545,9 +2537,6 @@ static struct ip_sf_list *igmp_mcf_get_next(struc=
t seq_file *seq, struct ip_sf_l
 		spin_unlock_bh(&state->im->lock);
 		state->im =3D state->im->next;
 		while (!state->im) {
-			if (likely(state->idev !=3D NULL))
-				read_unlock(&state->idev->mc_list_lock);
-
 			state->dev =3D next_net_device_rcu(state->dev);
 			if (!state->dev) {
 				state->idev =3D NULL;
@@ -2556,8 +2545,7 @@ static struct ip_sf_list *igmp_mcf_get_next(struc=
t seq_file *seq, struct ip_sf_l
 			state->idev =3D __in_dev_get_rcu(state->dev);
 			if (!state->idev)
 				continue;
-			read_lock(&state->idev->mc_list_lock);
-			state->im =3D state->idev->mc_list;
+			state->im =3D rcu_dereference(state->idev->mc_list);
 		}
 		if (!state->im)
 			break;
@@ -2603,10 +2591,7 @@ static void igmp_mcf_seq_stop(struct seq_file *s=
eq, void *v)
 		spin_unlock_bh(&state->im->lock);
 		state->im =3D NULL;
 	}
-	if (likely(state->idev !=3D NULL)) {
-		read_unlock(&state->idev->mc_list_lock);
-		state->idev =3D NULL;
-	}
+	state->idev =3D NULL;
 	state->dev =3D NULL;
 	rcu_read_unlock();
 }
