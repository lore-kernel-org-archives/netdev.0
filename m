From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 1/3] NETFILTER: CLUSTERIP entry refcounting
Date: Thu, 15 Sep 2005 16:51:21 +0200
Message-ID: <20050915145121.GA17121@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Kj7319i9nmIyA2yE"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave, please push this bugfix to mainline.

CLUSTERIP: introduce reference counting for entries

The CLUSTERIP target creates a procfs entry for all different cluster
IPs.  Although more than one rules can refer to a single cluster IP (and
thus a single config structure), removal of the procfs entry is done
unconditionally in destroy(). In more complicated situations involving
deferred dereferencing of the config structure by procfs and creating a
new rule with the same cluster IP it's also possible that no entry will
be created for the new rule.

This patch fixes the problem by counting the number of entries
referencing a given config structure and moving the config list
manipulation and procfs entry deletion parts to the
clusterip_config_entry_put() function.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 8d5367b6545c19e551564c26adc808861624ef15
tree 33e3c99394a7f9fae6cc09e5f328144f4786c9f0
parent 8e662a0c0b3aa1257641dd32d5c92d880c110623
author Harald Welte <laforge@netfilter.org> Di, 13 Sep 2005 14:53:17 +0200
committer Harald Welte <laforge@netfilter.org> Di, 13 Sep 2005 14:53:17 +02=
00

 net/ipv4/netfilter/ipt_CLUSTERIP.c |   80 ++++++++++++++++++++++++++++----=
----
 1 files changed, 62 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CL=
USTERIP.c
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -49,6 +49,8 @@ MODULE_DESCRIPTION("iptables target for=20
 struct clusterip_config {
 	struct list_head list;			/* list of all configs */
 	atomic_t refcount;			/* reference count */
+	atomic_t entries;			/* number of entries/rules
+						 * referencing us */
=20
 	u_int32_t clusterip;			/* the IP address */
 	u_int8_t clustermac[ETH_ALEN];		/* the MAC address */
@@ -76,23 +78,48 @@ static struct proc_dir_entry *clusterip_
 #endif
=20
 static inline void
-clusterip_config_get(struct clusterip_config *c) {
+clusterip_config_get(struct clusterip_config *c)
+{
 	atomic_inc(&c->refcount);
 }
=20
 static inline void
-clusterip_config_put(struct clusterip_config *c) {
-	if (atomic_dec_and_test(&c->refcount)) {
+clusterip_config_put(struct clusterip_config *c)
+{
+	if (atomic_dec_and_test(&c->refcount))
+		kfree(c);
+}
+
+/* increase the count of entries(rules) using/referencing this config */
+static inline void
+clusterip_config_entry_get(struct clusterip_config *c)
+{
+	atomic_inc(&c->entries);
+}
+
+/* decrease the count of entries using/referencing this config.  If last
+ * entry(rule) is removed, remove the config from lists, but don't free it
+ * yet, since proc-files could still be holding references */
+static inline void
+clusterip_config_entry_put(struct clusterip_config *c)
+{
+	if (atomic_dec_and_test(&c->entries)) {
 		write_lock_bh(&clusterip_lock);
 		list_del(&c->list);
 		write_unlock_bh(&clusterip_lock);
+
 		dev_mc_delete(c->dev, c->clustermac, ETH_ALEN, 0);
 		dev_put(c->dev);
-		kfree(c);
+
+		/* In case anyone still accesses the file, the open/close
+		 * functions are also incrementing the refcount on their own,
+		 * so it's safe to remove the entry even if it's in use. */
+#ifdef CONFIG_PROC_FS
+		remove_proc_entry(c->pde->name, c->pde->parent);
+#endif
 	}
 }
=20
-
 static struct clusterip_config *
 __clusterip_config_find(u_int32_t clusterip)
 {
@@ -111,7 +138,7 @@ __clusterip_config_find(u_int32_t cluste
 }
=20
 static inline struct clusterip_config *
-clusterip_config_find_get(u_int32_t clusterip)
+clusterip_config_find_get(u_int32_t clusterip, int entry)
 {
 	struct clusterip_config *c;
=20
@@ -122,6 +149,8 @@ clusterip_config_find_get(u_int32_t clus
 		return NULL;
 	}
 	atomic_inc(&c->refcount);
+	if (entry)
+		atomic_inc(&c->entries);
 	read_unlock_bh(&clusterip_lock);
=20
 	return c;
@@ -148,6 +177,7 @@ clusterip_config_init(struct ipt_cluster
 	c->hash_mode =3D i->hash_mode;
 	c->hash_initval =3D i->hash_initval;
 	atomic_set(&c->refcount, 1);
+	atomic_set(&c->entries, 1);
=20
 #ifdef CONFIG_PROC_FS
 	/* create proc dir entry */
@@ -415,8 +445,26 @@ checkentry(const char *tablename,
=20
 	/* FIXME: further sanity checks */
=20
-	config =3D clusterip_config_find_get(e->ip.dst.s_addr);
-	if (!config) {
+	config =3D clusterip_config_find_get(e->ip.dst.s_addr, 1);
+	if (config) {
+		if (cipinfo->config !=3D NULL) {
+			/* Case A: This is an entry that gets reloaded, since
+			 * it still has a cipinfo->config pointer. Simply
+			 * increase the entry refcount and return */
+			if (cipinfo->config !=3D config) {
+				printk(KERN_ERR "CLUSTERIP: Reloaded entry "
+				       "has invalid config pointer!\n");
+				return 0;
+			}
+			clusterip_config_entry_get(cipinfo->config);
+		} else {
+			/* Case B: This is a new rule referring to an existing
+			 * clusterip config. */
+			cipinfo->config =3D config;
+			clusterip_config_entry_get(cipinfo->config);
+		}
+	} else {
+		/* Case C: This is a completely new clusterip config */
 		if (!(cipinfo->flags & CLUSTERIP_FLAG_NEW)) {
 			printk(KERN_WARNING "CLUSTERIP: no config found for %u.%u.%u.%u, need '=
new'\n", NIPQUAD(e->ip.dst.s_addr));
 			return 0;
@@ -443,10 +491,9 @@ checkentry(const char *tablename,
 			}
 			dev_mc_add(config->dev,config->clustermac, ETH_ALEN, 0);
 		}
+		cipinfo->config =3D config;
 	}
=20
-	cipinfo->config =3D config;
-
 	return 1;
 }
=20
@@ -455,13 +502,10 @@ static void destroy(void *matchinfo, uns
 {
 	struct ipt_clusterip_tgt_info *cipinfo =3D matchinfo;
=20
-	/* we first remove the proc entry and then drop the reference
-	 * count.  In case anyone still accesses the file, the open/close
-	 * functions are also incrementing the refcount on their own */
-#ifdef CONFIG_PROC_FS
-	remove_proc_entry(cipinfo->config->pde->name,
-			  cipinfo->config->pde->parent);
-#endif
+	/* if no more entries are referencing the config, remove it
+	 * from the list and destroy the proc entry */
+	clusterip_config_entry_put(cipinfo->config);
+
 	clusterip_config_put(cipinfo->config);
 }
=20
@@ -533,7 +577,7 @@ arp_mangle(unsigned int hook,
=20
 	/* if there is no clusterip configuration for the arp reply's=20
 	 * source ip, we don't want to mangle it */
-	c =3D clusterip_config_find_get(payload->src_ip);
+	c =3D clusterip_config_find_get(payload->src_ip, 0);
 	if (!c)
 		return NF_ACCEPT;
=20
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--Kj7319i9nmIyA2yE
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDKYppXaXGVTD0i/8RAmGbAKCsps8GP+u5RCmyVC4yE/HbSnZK0wCeORyR
Pi0r8cUofJMC4UwUS6Imwi0=
=rdtd
-----END PGP SIGNATURE-----

--Kj7319i9nmIyA2yE--
