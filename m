From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 14/17]: Clean up pedit action
Date: Thu, 30 Dec 2004 04:40:56 +0100
Message-ID: <41D378C8.9070808@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010800010105060800030209"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010800010105060800030209
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Clean up pedit action, same as for gact and ipt.


--------------010800010105060800030209
Content-Type: text/x-patch;
 name="14.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="14.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/30 03:44:02+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Clean up pedit action
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/pedit.c
#   2004/12/30 03:43:55+01:00 kaber@coreworks.de +25 -41
#   [PKT_SCHED]: Clean up pedit action
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/pedit.c b/net/sched/pedit.c
--- a/net/sched/pedit.c	2004-12-30 04:01:56 +01:00
+++ b/net/sched/pedit.c	2004-12-30 04:01:56 +01:00
@@ -54,36 +54,30 @@
 
 
 static int
-tcf_pedit_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,int ovr, int bind)
+tcf_pedit_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,
+               int ovr, int bind)
 {
 	struct rtattr *tb[TCA_PEDIT_MAX];
 	struct tc_pedit *parm;
 	int size = 0;
 	int ret = 0;
-	struct tcf_pedit *p = NULL;
+	struct tcf_pedit *p;
 
 	if (rtattr_parse(tb, TCA_PEDIT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
 		return -1;
-
-	if (NULL == a || NULL == tb[TCA_PEDIT_PARMS - 1]) {
+	if (a == NULL || tb[TCA_PEDIT_PARMS - 1] == NULL) {
 		printk("BUG: tcf_pedit_init called with NULL params\n");
 		return -1;
 	}
 
 	parm = RTA_DATA(tb[TCA_PEDIT_PARMS - 1]);
-
 	p = tcf_hash_check(parm, a, ovr, bind);
-
-	if (NULL == p) { /* new */
-
+	if (p == NULL) { /* new */
 		if (!parm->nkeys)
 			return -1;
-
-		size = sizeof (*p)+ (parm->nkeys*sizeof(struct tc_pedit_key));
-
-		p = tcf_hash_create(parm,est,a,size,ovr,bind);
-
-		if (NULL == p)
+		size = sizeof(*p) + parm->nkeys * sizeof(struct tc_pedit_key);
+		p = tcf_hash_create(parm, est, a, size, ovr, bind);
+		if (p == NULL)
 			return -1;
 		ret = 1;
 		goto override;
@@ -94,7 +88,8 @@
 		p->flags = parm->flags;
 		p->nkeys = parm->nkeys;
 		p->action = parm->action;
-		memcpy(p->keys,parm->keys,parm->nkeys*(sizeof(struct tc_pedit_key)));
+		memcpy(p->keys, parm->keys,
+		       parm->nkeys * sizeof(struct tc_pedit_key));
 	}
 
 	return ret;
@@ -103,27 +98,22 @@
 static int
 tcf_pedit_cleanup(struct tc_action *a, int bind)
 {
-	struct tcf_pedit *p;
-	p = PRIV(a,pedit);
+	struct tcf_pedit *p = PRIV(a,pedit);
+
 	if (NULL != p)
-		return	tcf_hash_release(p, bind);
+		return tcf_hash_release(p, bind);
 	return 0;
 }
 
-/*
-**
-*/
 static int
 tcf_pedit(struct sk_buff **pskb, struct tc_action *a)
 {
-	struct tcf_pedit *p;
+	struct tcf_pedit *p = PRIV(a, pedit);
 	struct sk_buff *skb = *pskb;
 	int i, munged = 0;
 	u8 *pptr;
 
-	p = PRIV(a,pedit);
-
-	if (NULL == p) {
+	if (p == NULL) {
 		printk("BUG: tcf_pedit called with NULL params\n");
 		return -1; /* change to something symbolic */
 	}
@@ -141,11 +131,11 @@
 
 	p->tm.lastuse = jiffies;
 
-	if (0 < p->nkeys) {
+	if (p->nkeys > 0) {
 		struct tc_pedit_key *tkey = p->keys;
 
 		for (i = p->nkeys; i > 0; i--, tkey++) {
-			u32 *ptr ;
+			u32 *ptr;
 
 			int offset = tkey->off;
 			if (tkey->offmask) {
@@ -168,7 +158,6 @@
 				goto bad;
 			}
 
-
 			ptr = (u32 *)(pptr+offset);
 			/* just do it, baby */
 			*ptr = ((*ptr & tkey->mask) ^ tkey->val);
@@ -196,29 +185,24 @@
 {
 	unsigned char *b = skb->tail;
 	struct tc_pedit *opt;
-	struct tcf_pedit *p;
+	struct tcf_pedit *p = PRIV(a, pedit);
 	struct tcf_t t;
 	int s; 
 		
-
-	p = PRIV(a,pedit);
-
-	if (NULL == p) {
+	if (p == NULL) {
 		printk("BUG: tcf_pedit_dump called with NULL params\n");
 		goto rtattr_failure;
 	}
 
-	s = sizeof (*opt)+(p->nkeys*sizeof(struct tc_pedit_key));
+	s = sizeof(*opt) + p->nkeys * sizeof(struct tc_pedit_key);
 
-	/* netlink spinlocks held above us - must use ATOMIC
-	 * */
+	/* netlink spinlocks held above us - must use ATOMIC */
 	opt = kmalloc(s, GFP_ATOMIC);
 	if (opt == NULL)
 		return -ENOBUFS;
-
 	memset(opt, 0, s);
 
-	memcpy(opt->keys,p->keys,p->nkeys*(sizeof(struct tc_pedit_key)));
+	memcpy(opt->keys, p->keys, p->nkeys * sizeof(struct tc_pedit_key));
 	opt->index = p->index;
 	opt->nkeys = p->nkeys;
 	opt->flags = p->flags;
@@ -239,15 +223,15 @@
 			(unsigned int)key->off,
 			(unsigned int)key->val,
 			(unsigned int)key->mask);
-												}
-											}
+		}
+	}
 #endif
 
 	RTA_PUT(skb, TCA_PEDIT_PARMS, s, opt);
 	t.install = jiffies_to_clock_t(jiffies - p->tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - p->tm.lastuse);
 	t.expires = jiffies_to_clock_t(p->tm.expires);
-	RTA_PUT(skb, TCA_PEDIT_TM, sizeof (t), &t);
+	RTA_PUT(skb, TCA_PEDIT_TM, sizeof(t), &t);
 	return skb->len;
 
 rtattr_failure:

--------------010800010105060800030209--
