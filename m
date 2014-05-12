From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: [PATCH ipsec-next 2/2] xfrm: configure policy hash table thresholds by /proc
Date: Mon, 12 May 2014 15:45:25 +0200
Message-ID: <1399902325-1788-3-git-send-email-christophe.gouault@6wind.com>
References: <1399902325-1788-1-git-send-email-christophe.gouault@6wind.com>
Cc: netdev@vger.kernel.org,
	Christophe Gouault <christophe.gouault@6wind.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:33346 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754889AbaELNp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 09:45:57 -0400
Received: by mail-wi0-f172.google.com with SMTP id hi2so4498123wib.11
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 06:45:56 -0700 (PDT)
In-Reply-To: <1399902325-1788-1-git-send-email-christophe.gouault@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable to specify local and remote prefix length thresholds
for the policy hash table via /proc entries. Example:

echo 0 24 > /proc/sys/net/ipv4/xfrm4_policy_hash_tresh
echo 0 56 > /proc/sys/net/ipv6/xfrm6_policy_hash_tresh

The numbers are the policy selector minimum prefix lengths to put a
policy in the hash table.

The first number is the local threshold (source address for out
policies, destination address for in and fwd policies).

The second number is the remote threshold (destination address for out
policies, source address for in and fwd policies).

The default values are:

/proc/sys/net/ipv4/xfrm4_policy_hash_tresh: 32 32
/proc/sys/net/ipv6/xfrm6_policy_hash_tresh: 128 128

Dynamic re-building of the SPD is performed when the /proc values
are changed.

Signed-off-by: Christophe Gouault <christophe.gouault@6wind.com>
---
 include/net/netns/xfrm.h |  4 +++
 include/net/xfrm.h       |  1 +
 net/ipv4/xfrm4_policy.c  | 67 ++++++++++++++++++++++++++++++++++++
 net/ipv6/xfrm6_policy.c  | 67 ++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_policy.c   | 89 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_sysctl.c   |  3 ++
 6 files changed, 231 insertions(+)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 41902a8..0a23d02 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -45,6 +45,7 @@ struct netns_xfrm {
 	struct xfrm_policy_hash	policy_bydst[XFRM_POLICY_MAX * 2];
 	unsigned int		policy_count[XFRM_POLICY_MAX * 2];
 	struct work_struct	policy_hash_work;
+	struct work_struct	policy_hash_thresh_work;
 
 
 	struct sock		*nlsk;
@@ -54,6 +55,9 @@ struct netns_xfrm {
 	u32			sysctl_aevent_rseqth;
 	int			sysctl_larval_drop;
 	u32			sysctl_acq_expires;
+	u8			sysctl_xfrm4_policy_hash_thresh[2];
+	u8			sysctl_xfrm6_policy_hash_thresh[2];
+	seqlock_t		sysctl_policy_hash_thresh_lock;
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*sysctl_hdr;
 #endif
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 721e9c3..dc4865e 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1591,6 +1591,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark,
 struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8, int dir,
 				     u32 id, int delete, int *err);
 int xfrm_policy_flush(struct net *net, u8 type, bool task_valid);
+void xfrm_policy_hash_rebuild(struct net *net);
 u32 xfrm_get_acqseq(void);
 int verify_spi_info(u8 proto, u32 min, u32 max);
 int xfrm_alloc_spi(struct xfrm_state *x, u32 minspi, u32 maxspi);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 6156f68..4b7b29d 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -256,6 +256,61 @@ static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
 };
 
 #ifdef CONFIG_SYSCTL
+static int xfrm4_policy_hash_thresh_min[] = { 0, 0 };
+static int xfrm4_policy_hash_thresh_max[] = { 32, 32 };
+
+/* Read xfrm4 policy hash table thresholds */
+static void get_xfrm4_policy_hash_thresh(struct net *net, int thresh[2])
+{
+	unsigned seq;
+
+	do {
+		seq = read_seqbegin(&net->xfrm.sysctl_policy_hash_thresh_lock);
+
+		thresh[0] = net->xfrm.sysctl_xfrm4_policy_hash_thresh[0];
+		thresh[1] = net->xfrm.sysctl_xfrm4_policy_hash_thresh[1];
+	} while (read_seqretry(&net->xfrm.sysctl_policy_hash_thresh_lock, seq));
+}
+
+/* Update xfrm4 policy hash table thresholds */
+static void set_xfrm4_policy_hash_thresh(struct net *net, int thresh[2])
+{
+	write_seqlock(&net->xfrm.sysctl_policy_hash_thresh_lock);
+	net->xfrm.sysctl_xfrm4_policy_hash_thresh[0] = thresh[0];
+	net->xfrm.sysctl_xfrm4_policy_hash_thresh[1] = thresh[1];
+	write_sequnlock(&net->xfrm.sysctl_policy_hash_thresh_lock);
+
+	xfrm_policy_hash_rebuild(net);
+}
+
+/* Validate changes from /proc interface. */
+static int xfrm4_policy_hash_thresh(struct ctl_table *table, int write,
+				 void __user *buffer,
+				 size_t *lenp, loff_t *ppos)
+{
+	struct net *net =
+		container_of(table->data, struct net,
+			     xfrm.sysctl_xfrm4_policy_hash_thresh);
+	int ret;
+	int thresh[2];
+	struct ctl_table tmp = {
+		.data = &thresh,
+		.maxlen = sizeof(thresh),
+		.mode = table->mode,
+		.extra1 = &xfrm4_policy_hash_thresh_min,
+		.extra2 = &xfrm4_policy_hash_thresh_max,
+	};
+
+	get_xfrm4_policy_hash_thresh(net, thresh);
+
+	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
+
+	if (write && ret == 0)
+		set_xfrm4_policy_hash_thresh(net, thresh);
+
+	return ret;
+}
+
 static struct ctl_table xfrm4_policy_table[] = {
 	{
 		.procname       = "xfrm4_gc_thresh",
@@ -264,6 +319,13 @@ static struct ctl_table xfrm4_policy_table[] = {
 		.mode           = 0644,
 		.proc_handler   = proc_dointvec,
 	},
+	{
+		.procname       = "xfrm4_policy_hash_thresh",
+		.data           = &init_net.xfrm.sysctl_xfrm4_policy_hash_thresh,
+		.maxlen         = sizeof(init_net.xfrm.sysctl_xfrm4_policy_hash_thresh),
+		.mode           = 0644,
+		.proc_handler   = xfrm4_policy_hash_thresh,
+	},
 	{ }
 };
 
@@ -279,8 +341,13 @@ static int __net_init xfrm4_net_init(struct net *net)
 			goto err_alloc;
 
 		table[0].data = &net->xfrm.xfrm4_dst_ops.gc_thresh;
+		table[1].data = &net->xfrm.sysctl_xfrm4_policy_hash_thresh;
 	}
 
+	/* Set defaults for xfrm4 policy hash thresholds */
+	net->xfrm.sysctl_xfrm4_policy_hash_thresh[0] = 32;
+	net->xfrm.sysctl_xfrm4_policy_hash_thresh[1] = 32;
+
 	hdr = register_net_sysctl(net, "net/ipv4", table);
 	if (!hdr)
 		goto err_reg;
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 2a0bbda..7d7ca9af 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -316,6 +316,61 @@ static void xfrm6_policy_fini(void)
 }
 
 #ifdef CONFIG_SYSCTL
+static int xfrm6_policy_hash_thresh_min[] = { 0, 0 };
+static int xfrm6_policy_hash_thresh_max[] = { 128, 128 };
+
+/* Read xfrm6 policy hash table thresholds */
+static void get_xfrm6_policy_hash_thresh(struct net *net, int thresh[2])
+{
+	unsigned seq;
+
+	do {
+		seq = read_seqbegin(&net->xfrm.sysctl_policy_hash_thresh_lock);
+
+		thresh[0] = net->xfrm.sysctl_xfrm6_policy_hash_thresh[0];
+		thresh[1] = net->xfrm.sysctl_xfrm6_policy_hash_thresh[1];
+	} while (read_seqretry(&net->xfrm.sysctl_policy_hash_thresh_lock, seq));
+}
+
+/* Update xfrm6 policy hash table thresholds */
+static void set_xfrm6_policy_hash_thresh(struct net *net, int thresh[2])
+{
+	write_seqlock(&net->xfrm.sysctl_policy_hash_thresh_lock);
+	net->xfrm.sysctl_xfrm6_policy_hash_thresh[0] = thresh[0];
+	net->xfrm.sysctl_xfrm6_policy_hash_thresh[1] = thresh[1];
+	write_sequnlock(&net->xfrm.sysctl_policy_hash_thresh_lock);
+
+	xfrm_policy_hash_rebuild(net);
+}
+
+/* Validate changes from /proc interface. */
+static int xfrm6_policy_hash_thresh(struct ctl_table *table, int write,
+				 void __user *buffer,
+				 size_t *lenp, loff_t *ppos)
+{
+	struct net *net =
+		container_of(table->data, struct net,
+			     xfrm.sysctl_xfrm6_policy_hash_thresh);
+	int ret;
+	int thresh[2];
+	struct ctl_table tmp = {
+		.data = &thresh,
+		.maxlen = sizeof(thresh),
+		.mode = table->mode,
+		.extra1 = &xfrm6_policy_hash_thresh_min,
+		.extra2 = &xfrm6_policy_hash_thresh_max,
+	};
+
+	get_xfrm6_policy_hash_thresh(net, thresh);
+
+	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
+
+	if (write && ret == 0)
+		set_xfrm6_policy_hash_thresh(net, thresh);
+
+	return ret;
+}
+
 static struct ctl_table xfrm6_policy_table[] = {
 	{
 		.procname       = "xfrm6_gc_thresh",
@@ -324,6 +379,13 @@ static struct ctl_table xfrm6_policy_table[] = {
 		.mode	   	= 0644,
 		.proc_handler   = proc_dointvec,
 	},
+	{
+		.procname       = "xfrm6_policy_hash_thresh",
+		.data           = &init_net.xfrm.sysctl_xfrm6_policy_hash_thresh,
+		.maxlen         = sizeof(init_net.xfrm.sysctl_xfrm6_policy_hash_thresh),
+		.mode           = 0644,
+		.proc_handler   = xfrm6_policy_hash_thresh,
+	},
 	{ }
 };
 
@@ -339,8 +401,13 @@ static int __net_init xfrm6_net_init(struct net *net)
 			goto err_alloc;
 
 		table[0].data = &net->xfrm.xfrm6_dst_ops.gc_thresh;
+		table[1].data = &net->xfrm.sysctl_xfrm6_policy_hash_thresh;
 	}
 
+	/* Set defaults for xfrm6 policy hash thresholds */
+	net->xfrm.sysctl_xfrm6_policy_hash_thresh[0] = 128;
+	net->xfrm.sysctl_xfrm6_policy_hash_thresh[1] = 128;
+
 	hdr = register_net_sysctl(net, "net/ipv6", table);
 	if (!hdr)
 		goto err_reg;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index d65e254..0b968ca 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -566,6 +566,90 @@ static void xfrm_hash_resize(struct work_struct *work)
 	mutex_unlock(&hash_resize_mutex);
 }
 
+/* selector source side (local/remote) according to direction (in/out/fwd) */
+static int __src_side(int dir)
+{
+	return (dir & XFRM_POLICY_MASK) == XFRM_POLICY_OUT ? 0 : 1;
+}
+
+/* selector dest side (local/remote) according to direction (in/out/fwd) */
+static int __dst_side(int dir)
+{
+	return (dir & XFRM_POLICY_MASK) == XFRM_POLICY_OUT ? 1 : 0;
+}
+
+static void xfrm_hash_rebuild(struct work_struct *work)
+{
+	struct net *net = container_of(work, struct net,
+				       xfrm.policy_hash_thresh_work);
+	unsigned int hmask;
+	struct xfrm_policy *pol;
+	struct xfrm_policy *policy;
+	struct hlist_head *chain;
+	struct hlist_head *odst;
+	struct hlist_node *newpos;
+	int i;
+	int dir;
+	unsigned seq;
+	u8 thresh4[2];
+	u8 thresh6[2];
+
+	mutex_lock(&hash_resize_mutex);
+
+	/* copy thresholds from sysctl */
+	do {
+		seq = read_seqbegin(&net->xfrm.sysctl_policy_hash_thresh_lock);
+
+		thresh4[0] = net->xfrm.sysctl_xfrm4_policy_hash_thresh[0];
+		thresh4[1] = net->xfrm.sysctl_xfrm4_policy_hash_thresh[1];
+		thresh6[0] = net->xfrm.sysctl_xfrm6_policy_hash_thresh[0];
+		thresh6[1] = net->xfrm.sysctl_xfrm6_policy_hash_thresh[1];
+	} while (read_seqretry(&net->xfrm.sysctl_policy_hash_thresh_lock, seq));
+
+	write_lock_bh(&net->xfrm.xfrm_policy_lock);
+
+	/* reset the bydst and inexact table in all directions */
+	for (dir = 0; dir < XFRM_POLICY_MAX * 2; dir++) {
+
+		INIT_HLIST_HEAD(&net->xfrm.policy_inexact[dir]);
+		hmask = net->xfrm.policy_bydst[dir].hmask;
+		odst = net->xfrm.policy_bydst[dir].table;
+		for (i = hmask; i >= 0; i--)
+			INIT_HLIST_HEAD(odst + i);
+		net->xfrm.policy_bydst[dir].dbits4 = thresh4[__dst_side(dir)];
+		net->xfrm.policy_bydst[dir].sbits4 = thresh4[__src_side(dir)];
+		net->xfrm.policy_bydst[dir].dbits6 = thresh6[__dst_side(dir)];
+		net->xfrm.policy_bydst[dir].sbits6 = thresh6[__src_side(dir)];
+	}
+
+	/* re-insert all policies by order of creation */
+	list_for_each_entry_reverse(policy, &net->xfrm.policy_all, walk.all) {
+		newpos = NULL;
+		chain = policy_hash_bysel(net, &policy->selector,
+					  policy->family,
+					  xfrm_policy_id2dir(policy->index));
+		hlist_for_each_entry(pol, chain, bydst) {
+			if (policy->priority >= pol->priority)
+				newpos = &pol->bydst;
+			else
+				break;
+		}
+		if (newpos)
+			hlist_add_after(newpos, &policy->bydst);
+		else
+			hlist_add_head(&policy->bydst, chain);
+	}
+
+	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+
+	mutex_unlock(&hash_resize_mutex);
+}
+
+void xfrm_policy_hash_rebuild(struct net *net)
+{
+	schedule_work(&net->xfrm.policy_hash_thresh_work);
+}
+
 /* Generate new index... KAME seems to generate them ordered by cost
  * of an absolute inpredictability of ordering of rules. This will not pass. */
 static u32 xfrm_gen_index(struct net *net, int dir, u32 index)
@@ -2872,9 +2956,14 @@ static int __net_init xfrm_policy_init(struct net *net)
 		htab->dbits6 = 128;
 		htab->sbits6 = 128;
 	}
+	net->xfrm.sysctl_xfrm4_policy_hash_thresh[0] = 32;
+	net->xfrm.sysctl_xfrm4_policy_hash_thresh[1] = 32;
+	net->xfrm.sysctl_xfrm6_policy_hash_thresh[0] = 128;
+	net->xfrm.sysctl_xfrm6_policy_hash_thresh[1] = 128;
 
 	INIT_LIST_HEAD(&net->xfrm.policy_all);
 	INIT_WORK(&net->xfrm.policy_hash_work, xfrm_hash_resize);
+	INIT_WORK(&net->xfrm.policy_hash_thresh_work, xfrm_hash_rebuild);
 	if (net_eq(net, &init_net))
 		register_netdevice_notifier(&xfrm_dev_notifier);
 	return 0;
diff --git a/net/xfrm/xfrm_sysctl.c b/net/xfrm/xfrm_sysctl.c
index 05a6e3d..5fefb9d 100644
--- a/net/xfrm/xfrm_sysctl.c
+++ b/net/xfrm/xfrm_sysctl.c
@@ -54,6 +54,9 @@ int __net_init xfrm_sysctl_init(struct net *net)
 	table[2].data = &net->xfrm.sysctl_larval_drop;
 	table[3].data = &net->xfrm.sysctl_acq_expires;
 
+	/* initialize policy hash threshold sysctl lock */
+	seqlock_init(&net->xfrm.sysctl_policy_hash_thresh_lock);
+
 	/* Don't export sysctls to unprivileged users */
 	if (net->user_ns != &init_user_ns)
 		table[0].procname = NULL;
-- 
1.9.1
