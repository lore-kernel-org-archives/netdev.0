From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 13/17]: Clean up tcf_ipt_init
Date: Thu, 30 Dec 2004 04:40:39 +0100
Message-ID: <41D378B7.9020407@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090008040607010802060306"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090008040607010802060306
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Clean up tcf_ipt_init:

- Return proper error codes
- Check size of TCA_IPT_INDEX attribute
- Remove useless cast
- Rip out totally broken override bits
- Consolidate error path

The override part leaks memory, does not uninit the old
iptables target, needs GFP_ATOMIC allocations because a
lock is held and fails anyway. It think sharing code with
normal initialization obfuscates both parts, so I ripped
it out for now.


--------------090008040607010802060306
Content-Type: text/x-patch;
 name="13.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="13.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/30 03:29:42+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Clean up tcf_ipt_init
#   
#   - Return proper error codes
#   - Check size of TCA_IPT_INDEX attribute
#   - Remove useless cast
#   - Rip out totally broken override bits
#   - Consolidate error path
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/ipt.c
#   2004/12/30 03:29:35+01:00 kaber@coreworks.de +30 -56
#   [PKT_SCHED]: Clean up tcf_ipt_init
#   
#   - Return proper error codes
#   - Check size of TCA_IPT_INDEX attribute
#   - Remove useless cast
#   - Rip out totally broken override bits
#   - Consolidate error path
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/ipt.c b/net/sched/ipt.c
--- a/net/sched/ipt.c	2004-12-30 04:01:51 +01:00
+++ b/net/sched/ipt.c	2004-12-30 04:01:51 +01:00
@@ -60,12 +60,10 @@
 	struct ipt_target *target;
 	int ret = 0;
 	struct ipt_entry_target *t = p->t;
-	target = __ipt_find_target_lock(t->u.user.name, &ret);
 
-	if (!target) {
-		printk("init_targ: Failed to find %s\n", t->u.user.name);
-		return -1;
-	}
+	target = __ipt_find_target_lock(t->u.user.name, &ret);
+	if (!target)
+		return -ENOENT;
 
 	DPRINTK("init_targ: found %s\n", target->name);
 	/* we really need proper ref counting
@@ -105,33 +103,31 @@
 	u32 hook = 0;
 
 	if (rtattr_parse(tb, TCA_IPT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
-		return -1;
+		return -EINVAL;
 
-	if (tb[TCA_IPT_INDEX - 1]) {
+	if (tb[TCA_IPT_INDEX - 1] &&
+	    RTA_PAYLOAD(tb[TCA_IPT_INDEX - 1]) >= sizeof(index))
 		index = *(u32 *) RTA_DATA(tb[TCA_IPT_INDEX - 1]);
-		DPRINTK("ipt index %d\n", index);
-	}
 
 	if (index && (p = tcf_hash_lookup(index)) != NULL) {
-		a->priv = (void *) p;
+		a->priv = p;
 		spin_lock(&p->lock);
 		if (bind) {
 			p->bindcnt += 1;
 			p->refcnt += 1;
 		}
-		if (ovr) {
-			goto override;
-		}
+		if (ovr)
+			ret = -EOPNOTSUPP;
 		spin_unlock(&p->lock);
 		return ret;
 	}
 
 	if (tb[TCA_IPT_TARG - 1] == NULL || tb[TCA_IPT_HOOK - 1] == NULL)
-		return -1;
+		return -EINVAL;
 
 	p = kmalloc(sizeof(*p), GFP_KERNEL);
 	if (p == NULL)
-		return -1;
+		return -ENOMEM;
 	memset(p, 0, sizeof(*p));
 	p->refcnt = 1;
 	ret = 1;
@@ -140,45 +136,30 @@
 	if (bind)
 		p->bindcnt = 1;
 
-override:
+ /* override: */
 	hook = *(u32 *) RTA_DATA(tb[TCA_IPT_HOOK - 1]);
 
 	t = (struct ipt_entry_target *) RTA_DATA(tb[TCA_IPT_TARG - 1]);
 
+	ret = -ENOMEM;
 	p->t = kmalloc(t->u.target_size, GFP_KERNEL);
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
+	if (p->t == NULL)
+		goto err1;
 	memcpy(p->t, RTA_DATA(tb[TCA_IPT_TARG - 1]), t->u.target_size);
+
 	DPRINTK(" target NAME %s size %d data[0] %x data[1] %x\n",
 		t->u.user.name, t->u.target_size, t->data[0], t->data[1]);
 
 	p->tname = kmalloc(IFNAMSIZ, GFP_KERNEL);
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
-	} else {
+	if (p->tname == NULL)
+		goto err2;
+	else {
 		int csize = IFNAMSIZ - 1;
 
 		memset(p->tname, 0, IFNAMSIZ);
 		if (tb[TCA_IPT_TABLE - 1]) {
-			if (strlen((char *) RTA_DATA(tb[TCA_IPT_TABLE - 1])) <
-			    csize)
-				csize = strlen(RTA_DATA(tb[TCA_IPT_TABLE - 1]));
+			if (RTA_PAYLOAD(tb[TCA_IPT_TABLE - 1]) < csize)
+				csize = RTA_PAYLOAD(tb[TCA_IPT_TABLE - 1]);
 			strncpy(p->tname, RTA_DATA(tb[TCA_IPT_TABLE - 1]),
 				csize);
 			DPRINTK("table name %s\n", p->tname);
@@ -187,22 +168,8 @@
 		}
 	}
 
-	if (init_targ(p) < 0) {
-		if (ovr) {
-			printk("ipt policy messed up 2 \n");
-			spin_unlock(&p->lock);
-			return -1;
-		}
-		kfree(p->tname);
-		kfree(p->t);
-		kfree(p);
-		return -1;
-	}
-
-	if (ovr) {
-		spin_unlock(&p->lock);
-		return -1;
-	}
+	if ((ret = init_targ(p)) < 0)
+		goto err3;
 
 	p->index = index ? : tcf_hash_new_index();
 
@@ -223,6 +190,13 @@
 	a->priv = p;
 	return ret;
 
+err3:
+	kfree(p->tname);
+err2:
+	kfree(p->t);
+err1:
+	kfree(p);
+	return -1;
 }
 
 static int

--------------090008040607010802060306--
