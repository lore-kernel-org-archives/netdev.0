From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 2/3] NETFILTER: CLUSTERIP use bitmap for node list
Date: Thu, 15 Sep 2005 16:52:40 +0200
Message-ID: <20050915145240.GB17121@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ADZbWkCsHQ7r3kzd"
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


--ADZbWkCsHQ7r3kzd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave, please push this optimization to mainline.

CLUSTERIP: use a bitmap to store node responsibility data

Instead of maintaining an array containing a list of nodes this instance
is responsible for let's use a simple bitmap. This provides the
following features:

  * clusterip_responsible() and the add_node()/delete_node() operations
    become very simple and don't need locking
  * the config structure is much smaller

In spite of the completely different internal data representation the
user-space interface remains almost unchanged; the only difference is
that the proc file does not list nodes in the order they were added.
(The target info structure remains the same.)

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 6a31666e4f67a3eec97274b4aa8c245d06cd4fd3
tree e3ca62b62871d4836b391261c4fc304585b24242
parent 8d5367b6545c19e551564c26adc808861624ef15
author Harald Welte <laforge@netfilter.org> Di, 13 Sep 2005 14:56:57 +0200
committer Harald Welte <laforge@netfilter.org> Di, 13 Sep 2005 14:56:57 +02=
00

 net/ipv4/netfilter/ipt_CLUSTERIP.c |  143 +++++++++++++++-----------------=
----
 1 files changed, 61 insertions(+), 82 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CL=
USTERIP.c
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -13,6 +13,7 @@
 #include <linux/config.h>
 #include <linux/proc_fs.h>
 #include <linux/jhash.h>
+#include <linux/bitops.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
@@ -30,7 +31,7 @@
 #include <linux/netfilter_ipv4/ipt_CLUSTERIP.h>
 #include <linux/netfilter_ipv4/ip_conntrack.h>
=20
-#define CLUSTERIP_VERSION "0.7"
+#define CLUSTERIP_VERSION "0.8"
=20
 #define DEBUG_CLUSTERIP
=20
@@ -56,8 +57,7 @@ struct clusterip_config {
 	u_int8_t clustermac[ETH_ALEN];		/* the MAC address */
 	struct net_device *dev;			/* device */
 	u_int16_t num_total_nodes;		/* total number of nodes */
-	u_int16_t num_local_nodes;		/* number of local nodes */
-	u_int16_t local_nodes[CLUSTERIP_MAX_NODES];	/* node number array */
+	unsigned long local_nodes;		/* node number array */
=20
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *pde;		/* proc dir entry */
@@ -68,8 +68,7 @@ struct clusterip_config {
=20
 static LIST_HEAD(clusterip_configs);
=20
-/* clusterip_lock protects the clusterip_configs list _AND_ the configurab=
le
- * data within all structurses (num_local_nodes, local_nodes[]) */
+/* clusterip_lock protects the clusterip_configs list */
 static DEFINE_RWLOCK(clusterip_lock);
=20
 #ifdef CONFIG_PROC_FS
@@ -156,6 +155,17 @@ clusterip_config_find_get(u_int32_t clus
 	return c;
 }
=20
+static void
+clusterip_config_init_nodelist(struct clusterip_config *c,
+			       const struct ipt_clusterip_tgt_info *i)
+{
+	int n;
+
+	for (n =3D 0; n < i->num_local_nodes; n++) {
+		set_bit(i->local_nodes[n] - 1, &c->local_nodes);
+	}
+}
+
 static struct clusterip_config *
 clusterip_config_init(struct ipt_clusterip_tgt_info *i, u_int32_t ip,
 			struct net_device *dev)
@@ -172,8 +182,7 @@ clusterip_config_init(struct ipt_cluster
 	c->clusterip =3D ip;
 	memcpy(&c->clustermac, &i->clustermac, ETH_ALEN);
 	c->num_total_nodes =3D i->num_total_nodes;
-	c->num_local_nodes =3D i->num_local_nodes;
-	memcpy(&c->local_nodes, &i->local_nodes, sizeof(c->local_nodes));
+	clusterip_config_init_nodelist(c, i);
 	c->hash_mode =3D i->hash_mode;
 	c->hash_initval =3D i->hash_initval;
 	atomic_set(&c->refcount, 1);
@@ -201,53 +210,28 @@ clusterip_config_init(struct ipt_cluster
 static int
 clusterip_add_node(struct clusterip_config *c, u_int16_t nodenum)
 {
-	int i;
-
-	write_lock_bh(&clusterip_lock);
=20
-	if (c->num_local_nodes >=3D CLUSTERIP_MAX_NODES
-	    || nodenum > CLUSTERIP_MAX_NODES) {
-		write_unlock_bh(&clusterip_lock);
+	if (nodenum =3D=3D 0 ||
+	    nodenum > c->num_total_nodes)
 		return 1;
-	}
-
-	/* check if we alrady have this number in our array */
-	for (i =3D 0; i < c->num_local_nodes; i++) {
-		if (c->local_nodes[i] =3D=3D nodenum) {
-			write_unlock_bh(&clusterip_lock);
-			return 1;
-		}
-	}
=20
-	c->local_nodes[c->num_local_nodes++] =3D nodenum;
+	/* check if we already have this number in our bitfield */
+	if (test_and_set_bit(nodenum - 1, &c->local_nodes))
+		return 1;
=20
-	write_unlock_bh(&clusterip_lock);
 	return 0;
 }
=20
 static int
 clusterip_del_node(struct clusterip_config *c, u_int16_t nodenum)
 {
-	int i;
-
-	write_lock_bh(&clusterip_lock);
-
-	if (c->num_local_nodes <=3D 1 || nodenum > CLUSTERIP_MAX_NODES) {
-		write_unlock_bh(&clusterip_lock);
+	if (nodenum =3D=3D 0 ||
+	    nodenum > c->num_total_nodes)
 		return 1;
-	}
 	=09
-	for (i =3D 0; i < c->num_local_nodes; i++) {
-		if (c->local_nodes[i] =3D=3D nodenum) {
-			int size =3D sizeof(u_int16_t)*(c->num_local_nodes-(i+1));
-			memmove(&c->local_nodes[i], &c->local_nodes[i+1], size);
-			c->num_local_nodes--;
-			write_unlock_bh(&clusterip_lock);
-			return 0;
-		}
-	}
+	if (test_and_clear_bit(nodenum - 1, &c->local_nodes))
+		return 0;
=20
-	write_unlock_bh(&clusterip_lock);
 	return 1;
 }
=20
@@ -315,25 +299,7 @@ clusterip_hashfn(struct sk_buff *skb, st
 static inline int
 clusterip_responsible(struct clusterip_config *config, u_int32_t hash)
 {
-	int i;
-
-	read_lock_bh(&clusterip_lock);
-
-	if (config->num_local_nodes =3D=3D 0) {
-		read_unlock_bh(&clusterip_lock);
-		return 0;
-	}
-
-	for (i =3D 0; i < config->num_local_nodes; i++) {
-		if (config->local_nodes[i] =3D=3D hash) {
-			read_unlock_bh(&clusterip_lock);
-			return 1;
-		}
-	}
-
-	read_unlock_bh(&clusterip_lock);
-
-	return 0;
+	return test_bit(hash - 1, &config->local_nodes);
 }
=20
 /***********************************************************************=
=20
@@ -618,56 +584,69 @@ static struct nf_hook_ops cip_arp_ops =3D=20
=20
 #ifdef CONFIG_PROC_FS
=20
+struct clusterip_seq_position {
+	unsigned int pos;	/* position */
+	unsigned int weight;	/* number of bits set =3D=3D size */
+	unsigned int bit;	/* current bit */
+	unsigned long val;	/* current value */
+};
+
 static void *clusterip_seq_start(struct seq_file *s, loff_t *pos)
 {
 	struct proc_dir_entry *pde =3D s->private;
 	struct clusterip_config *c =3D pde->data;
-	unsigned int *nodeidx;
-
-	read_lock_bh(&clusterip_lock);
-	if (*pos >=3D c->num_local_nodes)
+	unsigned int weight;
+	u_int32_t local_nodes;
+	struct clusterip_seq_position *idx;
+
+	/* FIXME: possible race */
+	local_nodes =3D c->local_nodes;
+	weight =3D hweight32(local_nodes);
+	if (*pos >=3D weight)
 		return NULL;
=20
-	nodeidx =3D kmalloc(sizeof(unsigned int), GFP_KERNEL);
-	if (!nodeidx)
+	idx =3D kmalloc(sizeof(struct clusterip_seq_position), GFP_KERNEL);
+	if (!idx)
 		return ERR_PTR(-ENOMEM);
=20
-	*nodeidx =3D *pos;
-	return nodeidx;
+	idx->pos =3D *pos;
+	idx->weight =3D weight;
+	idx->bit =3D ffs(local_nodes);
+	idx->val =3D local_nodes;
+	clear_bit(idx->bit - 1, &idx->val);
+
+	return idx;
 }
=20
 static void *clusterip_seq_next(struct seq_file *s, void *v, loff_t *pos)
 {
-	struct proc_dir_entry *pde =3D s->private;
-	struct clusterip_config *c =3D pde->data;
-	unsigned int *nodeidx =3D (unsigned int *)v;
+	struct clusterip_seq_position *idx =3D (struct clusterip_seq_position *)v;
=20
-	*pos =3D ++(*nodeidx);
-	if (*pos >=3D c->num_local_nodes) {
+	*pos =3D ++idx->pos;
+	if (*pos >=3D idx->weight) {
 		kfree(v);
 		return NULL;
 	}
-	return nodeidx;
+	idx->bit =3D ffs(idx->val);
+	clear_bit(idx->bit - 1, &idx->val);
+	return idx;
 }
=20
 static void clusterip_seq_stop(struct seq_file *s, void *v)
 {
 	kfree(v);
-
-	read_unlock_bh(&clusterip_lock);
 }
=20
 static int clusterip_seq_show(struct seq_file *s, void *v)
 {
-	struct proc_dir_entry *pde =3D s->private;
-	struct clusterip_config *c =3D pde->data;
-	unsigned int *nodeidx =3D (unsigned int *)v;
+	struct clusterip_seq_position *idx =3D (struct clusterip_seq_position *)v;
=20
-	if (*nodeidx !=3D 0)=20
+	if (idx->pos !=3D 0)=20
 		seq_putc(s, ',');
-	seq_printf(s, "%u", c->local_nodes[*nodeidx]);
=20
-	if (*nodeidx =3D=3D c->num_local_nodes-1)
+	seq_printf(s, "%u", idx->bit);
+
+	if (idx->pos =3D=3D idx->weight - 1)
 		seq_putc(s, '\n');
=20
 	return 0;

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--ADZbWkCsHQ7r3kzd
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDKYq3XaXGVTD0i/8RAhEpAKCwmw0CA0yy0n86SJgqgc1JNmzurgCghu0p
OUuDUQ8I4GpOB+r0ShQ2dNE=
=bAUV
-----END PGP SIGNATURE-----

--ADZbWkCsHQ7r3kzd--
