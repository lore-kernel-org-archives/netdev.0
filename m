From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 14/22]: pedit action: fix multiple bugs in init
 path
Date: Mon, 10 Jan 2005 20:38:06 +0100
Message-ID: <41E2D99E.3060704@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050207030106090207020901"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050207030106090207020901
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------050207030106090207020901
Content-Type: text/x-patch;
 name="14.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="14.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 02:34:15+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: pedit action: fix multiple bugs in init path
#   
#   - Return proper error codes
#   - Attribute sizes are not checked
#   - rta may by NULL
#   - The action is inserted into the hash before its parameters are set
#   - replacement happens without locking
#   - no reallocation on replacement for possibly changed numbers of keys
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/pedit.c
#   2005/01/10 02:34:07+01:00 kaber@coreworks.de +53 -28
#   [PKT_SCHED]: pedit action: fix multiple bugs in init path
#   
#   - Return proper error codes
#   - Attribute sizes are not checked
#   - rta may by NULL
#   - The action is inserted into the hash before its parameters are set
#   - replacement happens without locking
#   - no reallocation on replacement for possibly changed numbers of keys
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/net/tc_act/tc_pedit.h
#   2005/01/10 02:34:07+01:00 kaber@coreworks.de +1 -1
#   [PKT_SCHED]: pedit action: fix multiple bugs in init path
#   
#   - Return proper error codes
#   - Attribute sizes are not checked
#   - rta may by NULL
#   - The action is inserted into the hash before its parameters are set
#   - replacement happens without locking
#   - no reallocation on replacement for possibly changed numbers of keys
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/include/net/tc_act/tc_pedit.h b/include/net/tc_act/tc_pedit.h
--- a/include/net/tc_act/tc_pedit.h	2005-01-10 06:22:44 +01:00
+++ b/include/net/tc_act/tc_pedit.h	2005-01-10 06:22:44 +01:00
@@ -8,7 +8,7 @@
 	tca_gen(pedit);
 	unsigned char           nkeys;
 	unsigned char           flags;
-	struct tc_pedit_key     keys[0];
+	struct tc_pedit_key     *keys;
 };
 
 #endif
diff -Nru a/net/sched/pedit.c b/net/sched/pedit.c
--- a/net/sched/pedit.c	2005-01-10 06:22:44 +01:00
+++ b/net/sched/pedit.c	2005-01-10 06:22:44 +01:00
@@ -58,40 +58,60 @@
 {
 	struct rtattr *tb[TCA_PEDIT_MAX];
 	struct tc_pedit *parm;
-	int size = 0;
 	int ret = 0;
 	struct tcf_pedit *p;
+	struct tc_pedit_key *keys = NULL;
+	int ksize;
 
-	if (rtattr_parse(tb, TCA_PEDIT_MAX, RTA_DATA(rta),
-	                 RTA_PAYLOAD(rta)) < 0)
-		return -1;
-	if (tb[TCA_PEDIT_PARMS - 1] == NULL) {
-		printk("BUG: tcf_pedit_init called with NULL params\n");
-		return -1;
-	}
+	if (rta == NULL || rtattr_parse(tb, TCA_PEDIT_MAX, RTA_DATA(rta),
+	                                RTA_PAYLOAD(rta)) < 0)
+		return -EINVAL;
+
+	if (tb[TCA_PEDIT_PARMS - 1] == NULL ||
+	    RTA_PAYLOAD(tb[TCA_PEDIT_PARMS-1]) < sizeof(*parm))
+		return -EINVAL;
+	parm = RTA_DATA(tb[TCA_PEDIT_PARMS-1]);
+	ksize = parm->nkeys * sizeof(struct tc_pedit_key);
+	if (RTA_PAYLOAD(tb[TCA_PEDIT_PARMS-1]) < sizeof(*parm) + ksize)
+		return -EINVAL;
 
-	parm = RTA_DATA(tb[TCA_PEDIT_PARMS - 1]);
-	p = tcf_hash_check(parm, a, ovr, bind);
-	if (p == NULL) { /* new */
+	p = tcf_hash_check(parm->index, a, ovr, bind);
+	if (p == NULL) {
 		if (!parm->nkeys)
-			return -1;
-		size = sizeof(*p) + parm->nkeys * sizeof(struct tc_pedit_key);
-		p = tcf_hash_create(parm, est, a, size, ovr, bind);
+			return -EINVAL;
+		p = tcf_hash_create(parm->index, est, a, sizeof(*p), ovr, bind);
 		if (p == NULL)
-			return -1;
-		ret = 1;
-		goto override;
-	} 
-
-	if (ovr) {
-override:
-		p->flags = parm->flags;
-		p->nkeys = parm->nkeys;
-		p->action = parm->action;
-		memcpy(p->keys, parm->keys,
-		       parm->nkeys * sizeof(struct tc_pedit_key));
+			return -ENOMEM;
+		keys = kmalloc(ksize, GFP_KERNEL);
+		if (keys == NULL) {
+			kfree(p);
+			return -ENOMEM;
+		}
+		ret = ACT_P_CREATED;
+	} else {
+		if (!ovr) {
+			tcf_hash_release(p, bind);
+			return -EEXIST;
+		}
+		if (p->nkeys && p->nkeys != parm->nkeys) {
+			keys = kmalloc(ksize, GFP_KERNEL);
+			if (keys == NULL)
+				return -ENOMEM;
+		}
 	}
 
+	spin_lock_bh(&p->lock);
+	p->flags = parm->flags;
+	p->action = parm->action;
+	if (keys) {
+		kfree(p->keys);
+		p->keys = keys;
+		p->nkeys = parm->nkeys;
+	}
+	memcpy(p->keys, parm->keys, ksize);
+	spin_unlock_bh(&p->lock);
+	if (ret == ACT_P_CREATED)
+		tcf_hash_insert(p);
 	return ret;
 }
 
@@ -100,8 +120,13 @@
 {
 	struct tcf_pedit *p = PRIV(a, pedit);
 
-	if (NULL != p)
-		return tcf_hash_release(p, bind);
+	if (p != NULL) {
+		struct tc_pedit_key *keys = p->keys;
+		if (tcf_hash_release(p, bind)) {
+			kfree(keys);
+			return 1;
+		}
+	}
 	return 0;
 }
 

--------------050207030106090207020901--
