From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 2.6] iptables CLUSTERIP target, seq_file version
Date: Thu, 21 Oct 2004 18:36:55 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20041021163655.GK3551@sunbeam.de.gnumonks.org>
References: <20041020223828.GP19899@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="oYAXToTM8kn9Ra/9"
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>, Linux Netdev List <netdev@oss.sgi.com>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	lmb@suse.de
Content-Disposition: inline
In-Reply-To: <20041020223828.GP19899@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--oYAXToTM8kn9Ra/9
Content-Type: multipart/mixed; boundary="ZrCu0B0FMx3UnjE2"
Content-Disposition: inline


--ZrCu0B0FMx3UnjE2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 21, 2004 at 12:38:28AM +0200, Harald Welte wrote:
Hi Dave!

This is the 'CLUSTERIP' target for iptables, this time no core kernel
changes required, please apply.

This enables you to build a static load sharing cluster between multiple
nodes - without the requirement to have a load balancer.  It uses a
series of [evil] tricks like replying with linklayer multicast addresses
to ARP requests, and using CONNMARK for stateful blocking all traffic
not intended for the local node.

Apart from the usual netfilter-specific file additions and
Kconfig/Makefile patches, this needs to export proc_file_operations in
order to get the reference counting of certain data objects right.  I
hope this change is acceptable.

Signed-off-by: Harald Welte <laforge@netfilter.org>

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--ZrCu0B0FMx3UnjE2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="2.6.9-clusterip.patch"
Content-Transfer-Encoding: quoted-printable

diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-connmark/include/linux/netfilter_ipv4/ipt_CLUSTERIP.h linux-2.6.9-conn=
mark-clusterip/include/linux/netfilter_ipv4/ipt_CLUSTERIP.h
--- linux-2.6.9-connmark/include/linux/netfilter_ipv4/ipt_CLUSTERIP.h	1970-=
01-01 01:00:00.000000000 +0100
+++ linux-2.6.9-connmark-clusterip/include/linux/netfilter_ipv4/ipt_CLUSTER=
IP.h	2004-10-21 00:22:29.000000000 +0200
@@ -0,0 +1,32 @@
+#ifndef _IPT_CLUSTERIP_H_target
+#define _IPT_CLUSTERIP_H_target
+
+enum clusterip_hashmode {
+    CLUSTERIP_HASHMODE_SIP =3D 0,
+    CLUSTERIP_HASHMODE_SIP_SPT,
+    CLUSTERIP_HASHMODE_SIP_SPT_DPT,
+};
+
+#define CLUSTERIP_HASHMODE_MAX CLUSTERIP_HASHMODE_SIP_SPT_DPT
+
+#define CLUSTERIP_MAX_NODES 16
+
+#define CLUSTERIP_FLAG_NEW 0x00000001
+
+struct clusterip_config;
+
+struct ipt_clusterip_tgt_info {
+
+	u_int32_t flags;
+	struct clusterip_config *config;
+=09
+	/* only relevant for new ones */
+	u_int8_t clustermac[6];
+	u_int16_t num_total_nodes;
+	u_int16_t num_local_nodes;
+	u_int16_t local_nodes[CLUSTERIP_MAX_NODES];
+	enum clusterip_hashmode hash_mode;
+	u_int32_t hash_initval;
+};
+
+#endif /*_IPT_CLUSTERIP_H_target*/
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-connmark/net/ipv4/netfilter/Kconfig linux-2.6.9-connmark-clusterip/net=
/ipv4/netfilter/Kconfig
--- linux-2.6.9-connmark/net/ipv4/netfilter/Kconfig	2004-10-21 00:16:30.000=
000000 +0200
+++ linux-2.6.9-connmark-clusterip/net/ipv4/netfilter/Kconfig	2004-10-21 00=
:30:17.000000000 +0200
@@ -628,6 +628,16 @@
 	  Documentation/modules.txt.  The module will be called
 	  ipt_CONNMARK.o.  If unsure, say `N'.
=20
+config IP_NF_TARGET_CLUSTERIP
+	tristate "CLUSTERIP target support (EXPERIMENTAL)"
+	depends on IP_NF_CONNTRACK_MARK && IP_NF_IPTABLES && EXPERIMENTAL
+	help
+	  The CLUSTERIP target allows you to build load-balancing clusters of
+	  network servers without having a dedicated load-balancing
+	  router/server/switch.
+=09
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 # raw + specific targets
 config IP_NF_RAW
 	tristate  'raw table support (required for NOTRACK/TRACE)'
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-connmark/net/ipv4/netfilter/Makefile linux-2.6.9-connmark-clusterip/ne=
t/ipv4/netfilter/Makefile
--- linux-2.6.9-connmark/net/ipv4/netfilter/Makefile	2004-10-20 23:59:36.00=
0000000 +0200
+++ linux-2.6.9-connmark-clusterip/net/ipv4/netfilter/Makefile	2004-10-21 0=
0:23:57.000000000 +0200
@@ -86,6 +86,7 @@
 obj-$(CONFIG_IP_NF_TARGET_ULOG) +=3D ipt_ULOG.o
 obj-$(CONFIG_IP_NF_TARGET_TCPMSS) +=3D ipt_TCPMSS.o
 obj-$(CONFIG_IP_NF_TARGET_NOTRACK) +=3D ipt_NOTRACK.o
+obj-$(CONFIG_IP_NF_TARGET_CLUSTERIP) +=3D ipt_CLUSTERIP.o
=20
 # generic ARP tables
 obj-$(CONFIG_IP_NF_ARPTABLES) +=3D arp_tables.o
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-connmark/net/ipv4/netfilter/ipt_CLUSTERIP.c linux-2.6.9-connmark-clust=
erip/net/ipv4/netfilter/ipt_CLUSTERIP.c
--- linux-2.6.9-connmark/net/ipv4/netfilter/ipt_CLUSTERIP.c	1970-01-01 01:0=
0:00.000000000 +0100
+++ linux-2.6.9-connmark-clusterip/net/ipv4/netfilter/ipt_CLUSTERIP.c	2004-=
10-21 18:28:30.195525212 +0200
@@ -0,0 +1,760 @@
+/* Cluster IP hashmark target=20
+ * (C) 2003-2004 by Harald Welte <laforge@netfilter.org>
+ * based on ideas of Fabio Olive Leite <olive@unixforge.org>
+ *
+ * Development of this code funded by SuSE Linux AG, http://www.suse.com/
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+#include <linux/module.h>
+#include <linux/config.h>
+#include <linux/proc_fs.h>
+#include <linux/jhash.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <linux/icmp.h>
+#include <linux/if_arp.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+
+#include <net/checksum.h>
+
+#include <linux/netfilter_arp.h>
+
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv4/ipt_CLUSTERIP.h>
+#include <linux/netfilter_ipv4/ip_conntrack.h>
+
+#define CLUSTERIP_VERSION "0.6"
+
+#define DEBUG_CLUSTERIP
+
+#ifdef DEBUG_CLUSTERIP
+#define DEBUGP	printk
+#else
+#define DEBUGP
+#endif
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
+MODULE_DESCRIPTION("iptables target for CLUSTERIP");
+
+struct clusterip_config {
+	struct list_head list;			/* list of all configs */
+	atomic_t refcount;			/* reference count */
+
+	u_int32_t clusterip;			/* the IP address */
+	u_int8_t clustermac[ETH_ALEN];		/* the MAC address */
+	struct net_device *dev;			/* device */
+	u_int16_t num_total_nodes;		/* total number of nodes */
+	u_int16_t num_local_nodes;		/* number of local nodes */
+	u_int16_t local_nodes[CLUSTERIP_MAX_NODES];	/* node number array */
+
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry *pde;		/* proc dir entry */
+#endif
+	enum clusterip_hashmode hash_mode;	/* which hashing mode */
+	u_int32_t hash_initval;			/* hash initialization */
+};
+
+static LIST_HEAD(clusterip_configs);
+
+/* clusterip_lock protects the clusterip_configs list _AND_ the configurab=
le
+ * data within all structurses (num_local_nodes, local_nodes[]) */
+DECLARE_RWLOCK(clusterip_lock);
+
+#ifdef CONFIG_PROC_FS
+static struct file_operations clusterip_proc_fops;
+static struct proc_dir_entry *clusterip_procdir;
+#endif
+
+static inline void
+clusterip_config_get(struct clusterip_config *c) {
+	atomic_inc(&c->refcount);
+}
+
+static inline void
+clusterip_config_put(struct clusterip_config *c) {
+	if (atomic_dec_and_test(&c->refcount)) {
+		WRITE_LOCK(&clusterip_lock);
+		list_del(&c->list);
+		WRITE_UNLOCK(&clusterip_lock);
+		dev_mc_delete(c->dev, c->clustermac, ETH_ALEN, 0);
+		dev_put(c->dev);
+		kfree(c);
+	}
+}
+
+
+static struct clusterip_config *
+__clusterip_config_find(u_int32_t clusterip)
+{
+	struct list_head *pos;
+
+	MUST_BE_READ_LOCKED(&clusterip_lock);
+	list_for_each(pos, &clusterip_configs) {
+		struct clusterip_config *c =3D list_entry(pos,=20
+					struct clusterip_config, list);
+		if (c->clusterip =3D=3D clusterip) {
+			return c;
+		}
+	}
+
+	return NULL;
+}
+
+static inline struct clusterip_config *
+clusterip_config_find_get(u_int32_t clusterip)
+{
+	struct clusterip_config *c;
+
+	READ_LOCK(&clusterip_lock);
+	c =3D __clusterip_config_find(clusterip);
+	if (!c) {
+		READ_UNLOCK(&clusterip_lock);
+		return NULL;
+	}
+	atomic_inc(&c->refcount);
+	READ_UNLOCK(&clusterip_lock);
+
+	return c;
+}
+
+static struct clusterip_config *
+clusterip_config_init(struct ipt_clusterip_tgt_info *i, u_int32_t ip,
+			struct net_device *dev)
+{
+	struct clusterip_config *c;
+	char buffer[16];
+
+	c =3D kmalloc(sizeof(*c), GFP_ATOMIC);
+	if (!c)
+		return NULL;
+
+	memset(c, 0, sizeof(*c));
+	c->dev =3D dev;
+	c->clusterip =3D ip;
+	memcpy(&c->clustermac, &i->clustermac, ETH_ALEN);
+	c->num_total_nodes =3D i->num_total_nodes;
+	c->num_local_nodes =3D i->num_local_nodes;
+	memcpy(&c->local_nodes, &i->local_nodes, sizeof(&c->local_nodes));
+	c->hash_mode =3D i->hash_mode;
+	c->hash_initval =3D i->hash_initval;
+	atomic_set(&c->refcount, 1);
+
+#ifdef CONFIG_PROC_FS
+	/* create proc dir entry */
+	sprintf(buffer, "%u.%u.%u.%u", NIPQUAD(ip));
+	c->pde =3D create_proc_entry(buffer, S_IWUSR|S_IRUSR, clusterip_procdir);
+	if (!c->pde) {
+		kfree(c);
+		return NULL;
+	}
+	c->pde->proc_fops =3D &clusterip_proc_fops;
+	c->pde->data =3D c;
+#endif
+
+	WRITE_LOCK(&clusterip_lock);
+	list_add(&c->list, &clusterip_configs);
+	WRITE_UNLOCK(&clusterip_lock);
+
+	return c;
+}
+
+static int
+clusterip_add_node(struct clusterip_config *c, u_int16_t nodenum)
+{
+	int i;
+
+	WRITE_LOCK(&clusterip_lock);
+
+	if (c->num_local_nodes >=3D CLUSTERIP_MAX_NODES
+	    || nodenum > CLUSTERIP_MAX_NODES) {
+		WRITE_UNLOCK(&clusterip_lock);
+		return 1;
+	}
+
+	/* check if we alrady have this number in our array */
+	for (i =3D 0; i < c->num_local_nodes; i++) {
+		if (c->local_nodes[i] =3D=3D nodenum) {
+			WRITE_UNLOCK(&clusterip_lock);
+			return 1;
+		}
+	}
+
+	c->local_nodes[c->num_local_nodes++] =3D nodenum;
+
+	WRITE_UNLOCK(&clusterip_lock);
+	return 0;
+}
+
+static int
+clusterip_del_node(struct clusterip_config *c, u_int16_t nodenum)
+{
+	int i;
+
+	WRITE_LOCK(&clusterip_lock);
+
+	if (c->num_local_nodes <=3D 1 || nodenum > CLUSTERIP_MAX_NODES) {
+		WRITE_UNLOCK(&clusterip_lock);
+		return 1;
+	}
+	=09
+	for (i =3D 0; i < c->num_local_nodes; i++) {
+		if (c->local_nodes[i] =3D=3D nodenum) {
+			int size =3D sizeof(u_int16_t)*(c->num_local_nodes-(i+1));
+			memmove(&c->local_nodes[i], &c->local_nodes[i+1], size);
+			c->num_local_nodes--;
+			WRITE_UNLOCK(&clusterip_lock);
+			return 0;
+		}
+	}
+
+	WRITE_UNLOCK(&clusterip_lock);
+	return 1;
+}
+
+static inline u_int32_t
+clusterip_hashfn(struct sk_buff *skb, struct clusterip_config *config)
+{
+	struct iphdr *iph =3D skb->nh.iph;
+	unsigned long hashval;
+	u_int16_t sport, dport;
+	struct tcphdr *th;
+	struct udphdr *uh;
+	struct icmphdr *ih;
+
+	switch (iph->protocol) {
+	case IPPROTO_TCP:
+		th =3D (void *)iph+iph->ihl*4;
+		sport =3D ntohs(th->source);
+		dport =3D ntohs(th->dest);
+		break;
+	case IPPROTO_UDP:
+		uh =3D (void *)iph+iph->ihl*4;
+		sport =3D ntohs(uh->source);
+		dport =3D ntohs(uh->dest);
+		break;
+	case IPPROTO_ICMP:
+		ih =3D (void *)iph+iph->ihl*4;
+		sport =3D ntohs(ih->un.echo.id);
+		dport =3D (ih->type<<8)|ih->code;
+		break;
+	default:
+		if (net_ratelimit()) {
+			printk(KERN_NOTICE "CLUSTERIP: unknown protocol `%u'\n",
+				iph->protocol);
+		}
+		sport =3D dport =3D 0;
+	}
+
+	switch (config->hash_mode) {
+	case CLUSTERIP_HASHMODE_SIP:
+		hashval =3D jhash_1word(ntohl(iph->saddr),
+				      config->hash_initval);
+		break;
+	case CLUSTERIP_HASHMODE_SIP_SPT:
+		hashval =3D jhash_2words(ntohl(iph->saddr), sport,=20
+				       config->hash_initval);
+		break;
+	case CLUSTERIP_HASHMODE_SIP_SPT_DPT:
+		hashval =3D jhash_3words(ntohl(iph->saddr), sport, dport,
+				       config->hash_initval);
+		break;
+	default:
+		/* to make gcc happy */
+		hashval =3D 0;
+		/* This cannot happen, unless the check function wasn't called
+		 * at rule load time */
+		printk("CLUSTERIP: unknown mode `%u'\n", config->hash_mode);
+		BUG();
+		break;
+	}
+
+	/* node numbers are 1..n, not 0..n */
+	return ((hashval % config->num_total_nodes)+1);
+}
+
+static inline int
+clusterip_responsible(struct clusterip_config *config, u_int32_t hash)
+{
+	int i;
+
+	READ_LOCK(&clusterip_lock);
+
+	if (config->num_local_nodes =3D=3D 0) {
+		READ_UNLOCK(&clusterip_lock);
+		return 0;
+	}
+
+	for (i =3D 0; i < config->num_local_nodes; i++) {
+		if (config->local_nodes[i] =3D=3D hash) {
+			READ_UNLOCK(&clusterip_lock);
+			return 1;
+		}
+	}
+
+	READ_UNLOCK(&clusterip_lock);
+
+	return 0;
+}
+
+/***********************************************************************=
=20
+ * IPTABLES TARGET=20
+ ***********************************************************************/
+
+static unsigned int
+target(struct sk_buff **pskb,
+       const struct net_device *in,
+       const struct net_device *out,
+       unsigned int hooknum,
+       const void *targinfo,
+       void *userinfo)
+{
+	const struct ipt_clusterip_tgt_info *cipinfo =3D targinfo;
+	enum ip_conntrack_info ctinfo;
+	struct ip_conntrack *ct =3D ip_conntrack_get((*pskb), &ctinfo);
+	u_int32_t hash;
+
+	/* don't need to clusterip_config_get() here, since refcount
+	 * is only decremented by destroy() - and ip_tables guarantees
+	 * that the ->target() function isn't called after ->destroy() */
+
+	if (!ct) {
+		printk(KERN_ERR "CLUSTERIP: no conntrack!\n");
+			/* FIXME: need to drop invalid ones, since replies
+			 * to outgoing connections of other nodes will be=20
+			 * marked as INVALID */
+		return NF_DROP;
+	}
+
+	/* special case: ICMP error handling. conntrack distinguishes between
+	 * error messages (RELATED) and information requests (see below) */
+	if ((*pskb)->nh.iph->protocol =3D=3D IPPROTO_ICMP
+	    && (ctinfo =3D=3D IP_CT_RELATED=20
+		|| ctinfo =3D=3D IP_CT_IS_REPLY+IP_CT_IS_REPLY))
+		return IPT_CONTINUE;
+
+	/* ip_conntrack_icmp guarantees us that we only have ICMP_ECHO,=20
+	 * TIMESTAMP, INFO_REQUEST or ADDRESS type icmp packets from here
+	 * on, which all have an ID field [relevant for hashing]. */
+
+	hash =3D clusterip_hashfn(*pskb, cipinfo->config);
+
+	switch (ctinfo) {
+		case IP_CT_NEW:
+			ct->mark =3D hash;
+			break;
+		case IP_CT_RELATED:
+		case IP_CT_RELATED+IP_CT_IS_REPLY:
+			/* FIXME: we don't handle expectations at the
+			 * moment.  they can arrive on a different node than
+			 * the master connection (e.g. FTP passive mode) */
+		case IP_CT_ESTABLISHED:
+		case IP_CT_ESTABLISHED+IP_CT_IS_REPLY:
+			break;
+		default:
+			break;
+	}
+
+#ifdef DEBUG_CLUSTERP
+	DUMP_TUPLE(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
+#endif
+	DEBUGP("hash=3D%u ct_hash=3D%lu ", hash, ct->mark);
+	if (!clusterip_responsible(cipinfo->config, hash)) {
+		DEBUGP("not responsible\n");
+		return NF_DROP;
+	}
+	DEBUGP("responsible\n");
+
+	/* despite being received via linklayer multicast, this is
+	 * actually a unicast IP packet. TCP doesn't like PACKET_MULTICAST */
+	(*pskb)->pkt_type =3D PACKET_HOST;
+
+	return IPT_CONTINUE;
+}
+
+static int
+checkentry(const char *tablename,
+	   const struct ipt_entry *e,
+           void *targinfo,
+           unsigned int targinfosize,
+           unsigned int hook_mask)
+{
+	struct ipt_clusterip_tgt_info *cipinfo =3D targinfo;
+
+	struct clusterip_config *config;
+
+	if (targinfosize !=3D IPT_ALIGN(sizeof(struct ipt_clusterip_tgt_info))) {
+		printk(KERN_WARNING "CLUSTERIP: targinfosize %u !=3D %Zu\n",
+		       targinfosize,
+		       IPT_ALIGN(sizeof(struct ipt_clusterip_tgt_info)));
+		return 0;
+	}
+
+	if (cipinfo->hash_mode !=3D CLUSTERIP_HASHMODE_SIP &&
+	    cipinfo->hash_mode !=3D CLUSTERIP_HASHMODE_SIP_SPT &&
+	    cipinfo->hash_mode !=3D CLUSTERIP_HASHMODE_SIP_SPT_DPT) {
+		printk(KERN_WARNING "CLUSTERIP: unknown mode `%u'\n",
+			cipinfo->hash_mode);
+		return 0;
+
+	}
+	if (e->ip.dmsk.s_addr !=3D 0xffffffff
+	    || e->ip.dst.s_addr =3D=3D 0) {
+		printk(KERN_ERR "CLUSTERIP: Please specify destination IP\n");
+		return 0;
+	}
+
+	/* FIXME: further sanity checks */
+
+	config =3D clusterip_config_find_get(e->ip.dst.s_addr);
+	if (!config) {
+		if (!(cipinfo->flags & CLUSTERIP_FLAG_NEW)) {
+			printk(KERN_WARNING "CLUSTERIP: no config found for %u.%u.%u.%u, need '=
new'\n", NIPQUAD(e->ip.dst.s_addr));
+			return 0;
+		} else {
+			struct net_device *dev;
+
+			if (e->ip.iniface[0] =3D=3D '\0') {
+				printk(KERN_WARNING "CLUSTERIP: Please specify an interface name\n");
+				return 0;
+			}
+
+			dev =3D dev_get_by_name(e->ip.iniface);
+			if (!dev) {
+				printk(KERN_WARNING "CLUSTERIP: no such interface %s\n", e->ip.iniface=
);
+				return 0;
+			}
+
+			config =3D clusterip_config_init(cipinfo,=20
+							e->ip.dst.s_addr, dev);
+			if (!config) {
+				printk(KERN_WARNING "CLUSTERIP: cannot allocate config\n");
+				dev_put(dev);
+				return 0;
+			}
+			dev_mc_add(config->dev,config->clustermac, ETH_ALEN, 0);
+		}
+	}
+
+	cipinfo->config =3D config;
+
+	return 1;
+}
+
+/* drop reference count of cluster config when rule is deleted */
+static void destroy(void *matchinfo, unsigned int matchinfosize)
+{
+	struct ipt_clusterip_tgt_info *cipinfo =3D matchinfo;
+
+	/* we first remove the proc entry and then drop the reference
+	 * count.  In case anyone still accesses the file, the open/close
+	 * functions are also incrementing the refcount on their own */
+#ifdef CONFIG_PROC_FS
+	remove_proc_entry(cipinfo->config->pde->name,
+			  cipinfo->config->pde->parent);
+#endif
+	clusterip_config_put(cipinfo->config);
+}
+
+static struct ipt_target clusterip_tgt =3D {=20
+	.name =3D "CLUSTERIP",
+	.target =3D &target,=20
+	.checkentry =3D &checkentry,=20
+	.destroy =3D &destroy,
+	.me =3D THIS_MODULE
+};
+
+
+/***********************************************************************=
=20
+ * ARP MANGLING CODE=20
+ ***********************************************************************/
+
+/* hardcoded for 48bit ethernet and 32bit ipv4 addresses */
+struct arp_payload {
+	u_int8_t src_hw[ETH_ALEN];
+	u_int32_t src_ip;
+	u_int8_t dst_hw[ETH_ALEN];
+	u_int32_t dst_ip;
+} __attribute__ ((packed));
+
+#ifdef CLUSTERIP_DEBUG
+static void arp_print(struct arp_payload *payload)=20
+{
+#define HBUFFERLEN 30
+	char hbuffer[HBUFFERLEN];
+	int j,k;
+	const char hexbuf[]=3D "0123456789abcdef";
+
+	for (k=3D0, j=3D0; k < HBUFFERLEN-3 && j < ETH_ALEN; j++) {
+		hbuffer[k++]=3Dhexbuf[(payload->src_hw[j]>>4)&15];
+		hbuffer[k++]=3Dhexbuf[payload->src_hw[j]&15];
+		hbuffer[k++]=3D':';
+	}
+	hbuffer[--k]=3D'\0';
+
+	printk("src %u.%u.%u.%u@%s, dst %u.%u.%u.%u\n",=20
+		NIPQUAD(payload->src_ip), hbuffer,
+		NIPQUAD(payload->dst_ip));
+}
+#endif
+
+static unsigned int
+arp_mangle(unsigned int hook,
+	   struct sk_buff **pskb,
+	   const struct net_device *in,
+	   const struct net_device *out,
+	   int (*okfn)(struct sk_buff *))
+{
+	struct arphdr *arp =3D (*pskb)->nh.arph;
+	struct arp_payload *payload;
+	struct clusterip_config *c;
+
+	/* we don't care about non-ethernet and non-ipv4 ARP */
+	if (arp->ar_hrd !=3D htons(ARPHRD_ETHER)
+	    || arp->ar_pro !=3D htons(ETH_P_IP)
+	    || arp->ar_pln !=3D 4 || arp->ar_hln !=3D ETH_ALEN)
+		return NF_ACCEPT;
+
+	/* we only want to mangle arp replies */
+	if (arp->ar_op !=3D htons(ARPOP_REPLY))
+		return NF_ACCEPT;
+
+	payload =3D (void *)(arp+1);
+
+	/* if there is no clusterip configuration for the arp reply's=20
+	 * source ip, we don't want to mangle it */
+	c =3D clusterip_config_find_get(payload->src_ip);
+	if (!c)
+		return NF_ACCEPT;
+
+	/* normally the linux kernel always replies to arp queries of=20
+	 * addresses on different interfacs.  However, in the CLUSTERIP case
+	 * this wouldn't work, since we didn't subscribe the mcast group on
+	 * other interfaces */
+	if (c->dev !=3D out) {
+		DEBUGP("CLUSTERIP: not mangling arp reply on different "
+		       "interface: cip'%s'-skb'%s'\n", c->dev->name, out->name);
+		clusterip_config_put(c);
+		return NF_ACCEPT;
+	}
+
+	/* mangle reply hardware address */
+	memcpy(payload->src_hw, c->clustermac, arp->ar_hln);
+
+#ifdef CLUSTERIP_DEBUG
+	DEBUGP(KERN_DEBUG "CLUSTERIP mangled arp reply: ");
+	arp_print(payload);
+#endif
+
+	clusterip_config_put(c);
+
+	return NF_ACCEPT;
+}
+
+static struct nf_hook_ops cip_arp_ops =3D {
+	.hook =3D arp_mangle,
+	.pf =3D NF_ARP,
+	.hooknum =3D NF_ARP_OUT,
+	.priority =3D -1
+};
+
+/***********************************************************************=
=20
+ * PROC DIR HANDLING=20
+ ***********************************************************************/
+
+#ifdef CONFIG_PROC_FS
+
+static void *clusterip_seq_start(struct seq_file *s, loff_t *pos)
+{
+	struct proc_dir_entry *pde =3D s->private;
+	struct clusterip_config *c =3D pde->data;
+	unsigned int *nodeidx;
+
+	READ_LOCK(&clusterip_lock);
+	if (*pos >=3D c->num_local_nodes)
+		return NULL;
+
+	nodeidx =3D kmalloc(sizeof(unsigned int), GFP_KERNEL);
+	if (!nodeidx)
+		return ERR_PTR(-ENOMEM);
+
+	*nodeidx =3D *pos;
+	return nodeidx;
+}
+
+static void *clusterip_seq_next(struct seq_file *s, void *v, loff_t *pos)
+{
+	struct proc_dir_entry *pde =3D s->private;
+	struct clusterip_config *c =3D pde->data;
+	unsigned int *nodeidx =3D (unsigned int *)v;
+
+	*pos =3D ++(*nodeidx);
+	if (*pos >=3D c->num_local_nodes) {
+		kfree(v);
+		return NULL;
+	}
+	return nodeidx;
+}
+
+static void clusterip_seq_stop(struct seq_file *s, void *v)
+{
+	kfree(v);
+
+	READ_UNLOCK(&clusterip_lock);
+}
+
+static int clusterip_seq_show(struct seq_file *s, void *v)
+{
+	struct proc_dir_entry *pde =3D s->private;
+	struct clusterip_config *c =3D pde->data;
+	unsigned int *nodeidx =3D (unsigned int *)v;
+
+	if (*nodeidx !=3D 0)=20
+		seq_putc(s, ',');
+	seq_printf(s, "%u", c->local_nodes[*nodeidx]);
+
+	if (*nodeidx =3D=3D c->num_local_nodes-1)
+		seq_putc(s, '\n');
+
+	return 0;
+}
+
+static struct seq_operations clusterip_seq_ops =3D {
+	.start	=3D clusterip_seq_start,
+	.next	=3D clusterip_seq_next,
+	.stop	=3D clusterip_seq_stop,
+	.show	=3D clusterip_seq_show,
+};
+
+static int clusterip_proc_open(struct inode *inode, struct file *file)
+{
+	int ret =3D seq_open(file, &clusterip_seq_ops);
+
+	if (!ret) {
+		struct seq_file *sf =3D file->private_data;
+		struct proc_dir_entry *pde =3D PDE(inode);
+		struct clusterip_config *c =3D pde->data;
+
+		sf->private =3D pde;
+
+		clusterip_config_get(c);
+	}
+
+	return ret;
+}
+
+static int clusterip_proc_release(struct inode *inode, struct file *file)
+{
+	struct proc_dir_entry *pde =3D PDE(inode);
+	struct clusterip_config *c =3D pde->data;
+	int ret;
+
+	ret =3D seq_release(inode, file);
+
+	if (!ret)
+		clusterip_config_put(c);
+
+	return ret;
+}
+
+static ssize_t clusterip_proc_write(struct file *file, const char *input,
+				size_t size, loff_t *ofs)
+{
+#define PROC_WRITELEN	10
+	char buffer[PROC_WRITELEN+1];
+	struct proc_dir_entry *pde =3D PDE(file->f_dentry->d_inode);
+	struct clusterip_config *c =3D pde->data;
+	unsigned long nodenum;
+
+	if (copy_from_user(buffer, input, PROC_WRITELEN))
+		return -EFAULT;
+
+	if (*buffer =3D=3D '+') {
+		nodenum =3D simple_strtoul(buffer+1, NULL, 10);
+		if (clusterip_add_node(c, nodenum))
+			return -ENOMEM;
+	} else if (*buffer =3D=3D '-') {
+		nodenum =3D simple_strtoul(buffer+1, NULL,10);
+		if (clusterip_del_node(c, nodenum))
+			return -ENOENT;
+	} else
+		return -EIO;
+
+	return size;
+}
+
+static struct file_operations clusterip_proc_fops =3D {
+	.owner	 =3D THIS_MODULE,
+	.open	 =3D clusterip_proc_open,
+	.read	 =3D seq_read,
+	.write	 =3D clusterip_proc_write,
+	.llseek	 =3D seq_lseek,
+	.release =3D clusterip_proc_release,
+};
+
+#endif /* CONFIG_PROC_FS */
+
+static int init_or_cleanup(int fini)
+{
+	int ret;
+
+	if (fini)
+		goto cleanup;
+
+	if (ipt_register_target(&clusterip_tgt)) {
+		ret =3D -EINVAL;
+		goto cleanup_none;
+	}
+
+	if (nf_register_hook(&cip_arp_ops) < 0) {
+		ret =3D -EINVAL;
+		goto cleanup_target;
+	}
+
+#ifdef CONFIG_PROC_FS
+	clusterip_procdir =3D proc_mkdir("ipt_CLUSTERIP", proc_net);
+	if (!clusterip_procdir) {
+		printk(KERN_ERR "CLUSTERIP: Unable to proc dir entry\n");
+		ret =3D -ENOMEM;
+		goto cleanup_hook;
+	}
+#endif /* CONFIG_PROC_FS */
+
+	printk(KERN_NOTICE "ClusterIP Version %s loaded successfully\n",
+		CLUSTERIP_VERSION);
+
+	return 0;
+
+cleanup:
+	printk(KERN_NOTICE "ClusterIP Version %s unloading\n",
+		CLUSTERIP_VERSION);
+#ifdef CONFIG_PROC_FS
+	remove_proc_entry(clusterip_procdir->name, clusterip_procdir->parent);
+#endif
+cleanup_hook:
+	nf_unregister_hook(&cip_arp_ops);
+cleanup_target:
+	ipt_unregister_target(&clusterip_tgt);
+cleanup_none:
+	return -EINVAL;
+}
+
+static int __init init(void)
+{
+	return init_or_cleanup(0);
+}
+
+static void __exit fini(void)
+{
+	init_or_cleanup(1);
+}
+
+module_init(init);
+module_exit(fini);

--ZrCu0B0FMx3UnjE2--

--oYAXToTM8kn9Ra/9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBd+WnXaXGVTD0i/8RAg+fAKCB0pXIwdakIKjK81MdvCjVCitVEgCfU26B
Kq9Z7KFrBn7pkorc7YfPhOc=
=7ZlP
-----END PGP SIGNATURE-----

--oYAXToTM8kn9Ra/9--
