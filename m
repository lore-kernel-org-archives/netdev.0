From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 12/22]: ipt action: fix multiple bugs in init path
Date: Mon, 10 Jan 2005 20:38:03 +0100
Message-ID: <41E2D99B.3040100@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090604020609090608000005"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090604020609090608000005
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------090604020609090608000005
Content-Type: text/x-patch;
 name="12.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="12.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 02:10:14+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: ipt action: fix multiple bugs in init path
#   
#   - Return proper error codes
#   - Attribute sizes are not checked
#   - rta may be NULL
#   - Several leaks and locking errors
#   - When replacement fails the old action is freed while in use
#   
#   This patch makes replacement atomic, so the old action is either
#   replaced entirely or not touched at all.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/ipt.c
#   2005/01/10 02:10:08+01:00 kaber@coreworks.de +80 -122
#   [PKT_SCHED]: ipt action: fix multiple bugs in init path
#   
#   - Return proper error codes
#   - Attribute sizes are not checked
#   - rta may be NULL
#   - Several leaks and locking errors
#   - When replacement fails the old action is freed while in use
#   
#   This patch makes replacement atomic, so the old action is either
#   replaced entirely or not touched at all.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/ipt.c b/net/sched/ipt.c
--- a/net/sched/ipt.c	2005-01-10 06:22:34 +01:00
+++ b/net/sched/ipt.c	2005-01-10 06:22:34 +01:00
@@ -53,29 +53,27 @@
 #define tcf_t_lock	ipt_lock
 #define tcf_ht		tcf_ipt_ht
 
+#define CONFIG_NET_ACT_INIT
 #include <net/pkt_act.h>
 
-static inline int
-init_targ(struct tcf_ipt *p)
+static int
+ipt_init_target(struct ipt_entry_target *t, char *table, unsigned int hook)
 {
 	struct ipt_target *target;
 	int ret = 0;
-	struct ipt_entry_target *t = p->t;
 
 	target = ipt_find_target(t->u.user.name, t->u.user.revision);
-	if (!target) {
-		printk("init_targ: Failed to find %s\n", t->u.user.name);
-		return -1;
-	}
+	if (!target)
+		return -ENOENT;
 
-	DPRINTK("init_targ: found %s\n", target->name);
+	DPRINTK("ipt_init_target: found %s\n", target->name);
 	t->u.kernel.target = target;
 
 	if (t->u.kernel.target->checkentry
-	    && !t->u.kernel.target->checkentry(p->tname, NULL, t->data,
+	    && !t->u.kernel.target->checkentry(table, NULL, t->data,
 					       t->u.target_size - sizeof(*t),
-					       p->hook)) {
-		DPRINTK("ip_tables: check failed for `%s'.\n",
+					       hook)) {
+		DPRINTK("ipt_init_target: check failed for `%s'.\n",
 			t->u.kernel.target->name);
 		module_put(t->u.kernel.target->me);
 		ret = -EINVAL;
@@ -84,137 +82,97 @@
 	return ret;
 }
 
+static void
+ipt_destroy_target(struct ipt_entry_target *t)
+{
+	if (t->u.kernel.target->destroy)
+		t->u.kernel.target->destroy(t->data,
+		                            t->u.target_size - sizeof(*t));
+        module_put(t->u.kernel.target->me);
+}
+
 static int
 tcf_ipt_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,
              int ovr, int bind)
 {
-	struct ipt_entry_target *t;
-	unsigned h;
 	struct rtattr *tb[TCA_IPT_MAX];
 	struct tcf_ipt *p;
-	int ret = 0;
-	u32 index = 0;
+	struct ipt_entry_target *td, *t;
+	char *tname;
+	int ret = 0, err;
 	u32 hook = 0;
+	u32 index = 0;
 
 	if (rta == NULL ||
 	    rtattr_parse(tb, TCA_IPT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
-		return -1;
-
-	if (tb[TCA_IPT_INDEX - 1]) {
-		index = *(u32 *) RTA_DATA(tb[TCA_IPT_INDEX - 1]);
-		DPRINTK("ipt index %d\n", index);
-	}
-
-	if (index && (p = tcf_hash_lookup(index)) != NULL) {
-		a->priv = (void *) p;
-		spin_lock(&p->lock);
-		if (bind) {
-			p->bindcnt += 1;
-			p->refcnt += 1;
-		}
-		if (ovr)
-			goto override;
-		spin_unlock(&p->lock);
-		return ret;
-	}
+		return -EINVAL;
 
-	if (tb[TCA_IPT_TARG - 1] == NULL || tb[TCA_IPT_HOOK - 1] == NULL)
-		return -1;
-
-	p = kmalloc(sizeof(*p), GFP_KERNEL);
-	if (p == NULL)
-		return -1;
-	memset(p, 0, sizeof(*p));
-	p->refcnt = 1;
-	ret = 1;
-	spin_lock_init(&p->lock);
-	p->stats_lock = &p->lock;
-	if (bind)
-		p->bindcnt = 1;
-
-override:
-	hook = *(u32 *) RTA_DATA(tb[TCA_IPT_HOOK - 1]);
-
-	t = (struct ipt_entry_target *) RTA_DATA(tb[TCA_IPT_TARG - 1]);
-
-	p->t = kmalloc(t->u.target_size, GFP_KERNEL);
-	if (p->t == NULL) {
-		if (ovr) {
-			printk("ipt policy messed up \n");
-			spin_unlock(&p->lock);
-			return -1;
-		}
-		kfree(p);
-		return -1;
-	}
-
-	memcpy(p->t, RTA_DATA(tb[TCA_IPT_TARG - 1]), t->u.target_size);
-	DPRINTK(" target NAME %s size %d data[0] %x data[1] %x\n",
-		t->u.user.name, t->u.target_size, t->data[0], t->data[1]);
-
-	p->tname = kmalloc(IFNAMSIZ, GFP_KERNEL);
-
-	if (p->tname == NULL) {
-		if (ovr) {
-			printk("ipt policy messed up 2 \n");
-			spin_unlock(&p->lock);
-			return -1;
-		}
-		kfree(p->t);
-		kfree(p);
-		return -1;
+	if (tb[TCA_IPT_HOOK-1] == NULL ||
+	    RTA_PAYLOAD(tb[TCA_IPT_HOOK-1]) < sizeof(u32))
+		return -EINVAL;
+	if (tb[TCA_IPT_TARG-1] == NULL ||
+	    RTA_PAYLOAD(tb[TCA_IPT_TARG-1]) < sizeof(*t))
+		return -EINVAL;
+	td = (struct ipt_entry_target *)RTA_DATA(tb[TCA_IPT_TARG-1]);
+	if (RTA_PAYLOAD(tb[TCA_IPT_TARG-1]) < td->u.target_size)
+		return -EINVAL;
+
+	if (tb[TCA_IPT_INDEX-1] != NULL &&
+	    RTA_PAYLOAD(tb[TCA_IPT_INDEX-1]) >= sizeof(u32))
+		index = *(u32 *)RTA_DATA(tb[TCA_IPT_INDEX-1]);
+
+	p = tcf_hash_check(index, a, ovr, bind);
+	if (p == NULL) {
+		p = tcf_hash_create(index, est, a, sizeof(*p), ovr, bind);
+		if (p == NULL)
+			return -ENOMEM;
+		ret = ACT_P_CREATED;
 	} else {
-		int csize = IFNAMSIZ - 1;
-
-		memset(p->tname, 0, IFNAMSIZ);
-		if (tb[TCA_IPT_TABLE - 1]) {
-			if (strlen((char *) RTA_DATA(tb[TCA_IPT_TABLE - 1])) <
-			    csize)
-				csize = strlen(RTA_DATA(tb[TCA_IPT_TABLE - 1]));
-			strncpy(p->tname, RTA_DATA(tb[TCA_IPT_TABLE - 1]),
-				csize);
-			DPRINTK("table name %s\n", p->tname);
-		} else {
-			strncpy(p->tname, "mangle", 1 + strlen("mangle"));
+		if (!ovr) {
+			tcf_hash_release(p, bind);
+			return -EEXIST;
 		}
 	}
 
-	if (init_targ(p) < 0) {
-		if (ovr) {
-			printk("ipt policy messed up 2 \n");
-			spin_unlock(&p->lock);
-			return -1;
-		}
+	hook = *(u32 *)RTA_DATA(tb[TCA_IPT_HOOK-1]);
+
+	err = -ENOMEM;
+	tname = kmalloc(IFNAMSIZ, GFP_KERNEL);
+	if (tname == NULL)
+		goto err1;
+	if (tb[TCA_IPT_TABLE - 1] == NULL ||
+	    rtattr_strlcpy(tname, tb[TCA_IPT_TABLE-1], IFNAMSIZ) >= IFNAMSIZ)
+		strcpy(tname, "mangle");
+
+	t = kmalloc(td->u.target_size, GFP_KERNEL);
+	if (t == NULL)
+		goto err2;
+	memcpy(t, td, td->u.target_size);
+
+	if ((err = ipt_init_target(t, tname, hook)) < 0)
+		goto err3;
+
+	spin_lock_bh(&p->lock);
+	if (ret != ACT_P_CREATED) {
+		ipt_destroy_target(p->t);
 		kfree(p->tname);
 		kfree(p->t);
-		kfree(p);
-		return -1;
-	}
-
-	if (ovr) {
-		spin_unlock(&p->lock);
-		return -1;
 	}
-
-	p->index = index ? : tcf_hash_new_index();
-
-	p->tm.lastuse = jiffies;
-	/*
-	p->tm.expires = jiffies;
-	*/
-	p->tm.install = jiffies;
-#ifdef CONFIG_NET_ESTIMATOR
-	if (est)
-		gen_new_estimator(&p->bstats, &p->rate_est, p->stats_lock, est);
-#endif
-	h = tcf_hash(p->index);
-	write_lock_bh(&ipt_lock);
-	p->next = tcf_ipt_ht[h];
-	tcf_ipt_ht[h] = p;
-	write_unlock_bh(&ipt_lock);
-	a->priv = p;
+	p->tname = tname;
+	p->t     = t;
+	p->hook  = hook;
+	spin_unlock_bh(&p->lock);
+	if (ret == ACT_P_CREATED)
+		tcf_hash_insert(p);
 	return ret;
 
+err3:
+	kfree(t);
+err2:
+	kfree(tname);
+err1:
+	kfree(p);
+	return err;
 }
 
 static int

--------------090604020609090608000005--
