From: Thomas Graf <tgraf@suug.ch>
Subject: Re: cls_u32 compile failure in current 2.6.12-rc1+BK tree
Date: Wed, 30 Mar 2005 03:02:09 +0200
Message-ID: <20050330010209.GN3086@postel.suug.ch>
References: <20050328123801.GY3086@postel.suug.ch> <1112014261.1089.1018.camel@jzny.localdomain> <20050328125802.GZ3086@postel.suug.ch> <1112015725.1089.1045.camel@jzny.localdomain> <20050328155523.GD3086@postel.suug.ch> <1112038128.1119.5.camel@jzny.localdomain> <20050328195320.GE3086@postel.suug.ch> <20050328223310.GH3086@postel.suug.ch> <20050329011058.GJ3086@postel.suug.ch> <1112129516.1076.90.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="6sX45UoQRIJXqkqR"
Cc: Meelis Roos <mroos@linux.ee>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112129516.1076.90.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--6sX45UoQRIJXqkqR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

* jamal <1112129516.1076.90.camel@jzny.localdomain> 2005-03-29 15:51
> 
> In general (from 1 mile away looks fine).
> One issue: a->type could be used for in the future to carry
> other things in addition to backward compatibility. So you cant assume
> it being set means only backward compat is needed (and nothing else).

Not sure if I get you but maybe a mistake of mine while mapping
the logic in mind into code has confused you. The code really
should have been:

	/* compat_mode being true specifies a call that is supposed
	 * to add additional backward compatiblity statistic TLVs.
	 */
	if (compat_mode) {
		if (a->type == TCA_OLD_COMPAT)
			err = gnet_stats_start_copy_compat(skb, 0,
				TCA_STATS, TCA_XSTATS, h->stats_lock, &d);
	} else
		err = gnet_stats_start_copy(skb, TCA_ACT_STATS,
			h->stats_lock, &d);

So we always dump TCA_ACT_STATS when calling from tcf_exts_dump
and add the backward compatibility TLVs in the second call
comming from tcf_exts_dump_stats for actions that need it.

Patches tested, works for me but might be worth for someone
else to give it a try as well just to make sure. Meelis, could
you give the 3 attched patches a try?

Dave, you can pull from bk://kernel.bkbits.net/tgraf/net-2.6-tcf_exts
if everyone can agree on this.

--6sX45UoQRIJXqkqR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=1

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/29 02:45:52+02:00 tgraf@suug.ch 
#   Cset exclude: hadi@cyberus.ca|ChangeSet|20050325173452|50562
# 
# net/sched/cls_u32.c
#   2005/03/29 02:45:46+02:00 tgraf@suug.ch +0 -0
#   Exclude
# 
# net/sched/cls_tcindex.c
#   2005/03/29 02:45:46+02:00 tgraf@suug.ch +0 -0
#   Exclude
# 
# net/sched/cls_route.c
#   2005/03/29 02:45:46+02:00 tgraf@suug.ch +0 -0
#   Exclude
# 
# net/sched/cls_fw.c
#   2005/03/29 02:45:46+02:00 tgraf@suug.ch +0 -0
#   Exclude
# 
diff -Nru a/net/sched/cls_fw.c b/net/sched/cls_fw.c
--- a/net/sched/cls_fw.c	2005-03-30 02:59:05 +02:00
+++ b/net/sched/cls_fw.c	2005-03-30 02:59:05 +02:00
@@ -338,9 +338,8 @@
 
 	rta->rta_len = skb->tail - b;
 
-	if (f->exts.action && f->exts.action->type == TCA_OLD_COMPAT)
-		if (tcf_exts_dump_stats(skb, &f->exts, &fw_ext_map) < 0)
-			goto rtattr_failure;
+	if (tcf_exts_dump_stats(skb, &f->exts, &fw_ext_map) < 0)
+		goto rtattr_failure;
 
 	return skb->len;
 
diff -Nru a/net/sched/cls_route.c b/net/sched/cls_route.c
--- a/net/sched/cls_route.c	2005-03-30 02:59:05 +02:00
+++ b/net/sched/cls_route.c	2005-03-30 02:59:05 +02:00
@@ -599,9 +599,8 @@
 
 	rta->rta_len = skb->tail - b;
 
-	if (f->exts.action && f->exts.action->type == TCA_OLD_COMPAT)
-		if (tcf_exts_dump_stats(skb, &f->exts, &route_ext_map) < 0)
-			goto rtattr_failure;
+	if (tcf_exts_dump_stats(skb, &f->exts, &route_ext_map) < 0)
+		goto rtattr_failure;
 
 	return skb->len;
 
diff -Nru a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
--- a/net/sched/cls_tcindex.c	2005-03-30 02:59:05 +02:00
+++ b/net/sched/cls_tcindex.c	2005-03-30 02:59:05 +02:00
@@ -496,9 +496,8 @@
 			goto rtattr_failure;
 		rta->rta_len = skb->tail-b;
 
-		if (r->exts.action && r->exts.action->type == TCA_OLD_COMPAT)
-			if (tcf_exts_dump_stats(skb, &r->exts, &tcindex_ext_map) < 0)
-				goto rtattr_failure;
+		if (tcf_exts_dump_stats(skb, &r->exts, &tcindex_ext_map) < 0)
+			goto rtattr_failure;
 	}
 	
 	return skb->len;
diff -Nru a/net/sched/cls_u32.c b/net/sched/cls_u32.c
--- a/net/sched/cls_u32.c	2005-03-30 02:59:05 +02:00
+++ b/net/sched/cls_u32.c	2005-03-30 02:59:05 +02:00
@@ -775,7 +775,7 @@
 	}
 
 	rta->rta_len = skb->tail - b;
-	if (TC_U32_KEY(n->handle) && n->exts.action && n->exts.action->type == TCA_OLD_COMPAT)
+	if (TC_U32_KEY(n->handle))
 		if (tcf_exts_dump_stats(skb, &n->exts, &u32_ext_map) < 0)
 			goto rtattr_failure;
 	return skb->len;

--6sX45UoQRIJXqkqR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=2

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/29 02:55:11+02:00 tgraf@suug.ch 
#   [NET]: Make primary TLV type optional
#   
#   Allows the use of the gnet_stats API for backward compatiblity
#   cases where no "modern" TLV structure is needed.
#   
#   Signed-off-by: Thomas Graf <tgraf@suug.ch>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/core/gen_stats.c
#   2005/03/29 02:54:56+02:00 tgraf@suug.ch +7 -3
#   [NET]: Make primary TLV type optional
# 
diff -Nru a/net/core/gen_stats.c b/net/core/gen_stats.c
--- a/net/core/gen_stats.c	2005-03-30 02:59:19 +02:00
+++ b/net/core/gen_stats.c	2005-03-30 02:59:19 +02:00
@@ -26,7 +26,9 @@
 static inline int
 gnet_stats_copy(struct gnet_dump *d, int type, void *buf, int size)
 {
-	RTA_PUT(d->skb, type, size, buf);
+	if (type)
+		RTA_PUT(d->skb, type, size, buf);
+
 	return 0;
 
 rtattr_failure:
@@ -58,7 +60,8 @@
 {
 	spin_lock_bh(lock);
 	d->lock = lock;
-	d->tail = (struct rtattr *) skb->tail;
+	if (type)
+		d->tail = (struct rtattr *) skb->tail;
 	d->skb = skb;
 	d->compat_tc_stats = tc_stats_type;
 	d->compat_xstats = xstats_type;
@@ -194,7 +197,8 @@
 int
 gnet_stats_finish_copy(struct gnet_dump *d)
 {
-	d->tail->rta_len = d->skb->tail - (u8 *) d->tail;
+	if (d->tail)
+		d->tail->rta_len = d->skb->tail - (u8 *) d->tail;
 
 	if (d->compat_tc_stats)
 		if (gnet_stats_copy(d, d->compat_tc_stats, &d->tc_stats,

--6sX45UoQRIJXqkqR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=3

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/30 01:34:30+02:00 tgraf@suug.ch 
#   [PKT_SCHED]: Fix action statistics dumping in compatibility mode
#   
#   Extends the action dumping function by a parameter to differ between
#   regular calls and the one supposed to add the backward compatiblity
#   bits for old userspace applications.
#   
#   Signed-off-by: Thomas Graf <tgraf@suug.ch>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/sched/cls_api.c
#   2005/03/30 01:34:14+02:00 tgraf@suug.ch +1 -1
#   [PKT_SCHED]: Fix action statistics dumping in compatibility mode
# 
# net/sched/act_api.c
#   2005/03/30 01:34:14+02:00 tgraf@suug.ch +12 -7
#   [PKT_SCHED]: Fix action statistics dumping in compatibility mode
# 
# include/net/act_api.h
#   2005/03/30 01:34:14+02:00 tgraf@suug.ch +1 -1
#   [PKT_SCHED]: Fix action statistics dumping in compatibility mode
# 
diff -Nru a/include/net/act_api.h b/include/net/act_api.h
--- a/include/net/act_api.h	2005-03-30 03:00:38 +02:00
+++ b/include/net/act_api.h	2005-03-30 03:00:38 +02:00
@@ -81,7 +81,7 @@
 extern int tcf_action_dump(struct sk_buff *skb, struct tc_action *a, int, int);
 extern int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
 extern int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
-extern int tcf_action_copy_stats (struct sk_buff *,struct tc_action *);
+extern int tcf_action_copy_stats (struct sk_buff *,struct tc_action *, int);
 #endif /* CONFIG_NET_CLS_ACT */
 
 extern int tcf_police(struct sk_buff *skb, struct tcf_police *p);
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2005-03-30 03:00:38 +02:00
+++ b/net/sched/act_api.c	2005-03-30 03:00:38 +02:00
@@ -228,7 +228,7 @@
 		return err;
 
 	RTA_PUT(skb, TCA_KIND, IFNAMSIZ, a->ops->kind);
-	if (tcf_action_copy_stats(skb, a))
+	if (tcf_action_copy_stats(skb, a, 0))
 		goto rtattr_failure;
 	r = (struct rtattr*) skb->tail;
 	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
@@ -380,19 +380,24 @@
 	return NULL;
 }
 
-int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a)
+int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
+			  int compat_mode)
 {
-	int err;
+	int err = 0;
 	struct gnet_dump d;
 	struct tcf_act_hdr *h = a->priv;
 	
 	if (h == NULL)
 		goto errout;
 
-	if (a->type == TCA_OLD_COMPAT)
-		err = gnet_stats_start_copy_compat(skb, TCA_ACT_STATS,
-			TCA_STATS, TCA_XSTATS, h->stats_lock, &d);
-	else
+	/* compat_mode being true specifies a call that is supposed
+	 * to add additional backward compatiblity statistic TLVs.
+	 */
+	if (compat_mode) {
+		if (a->type == TCA_OLD_COMPAT)
+			err = gnet_stats_start_copy_compat(skb, 0,
+				TCA_STATS, TCA_XSTATS, h->stats_lock, &d);
+	} else
 		err = gnet_stats_start_copy(skb, TCA_ACT_STATS,
 			h->stats_lock, &d);
 
diff -Nru a/net/sched/cls_api.c b/net/sched/cls_api.c
--- a/net/sched/cls_api.c	2005-03-30 03:00:38 +02:00
+++ b/net/sched/cls_api.c	2005-03-30 03:00:38 +02:00
@@ -602,7 +602,7 @@
 {
 #ifdef CONFIG_NET_CLS_ACT
 	if (exts->action)
-		if (tcf_action_copy_stats(skb, exts->action) < 0)
+		if (tcf_action_copy_stats(skb, exts->action, 1) < 0)
 			goto rtattr_failure;
 #elif defined CONFIG_NET_CLS_POLICE
 	if (exts->police)

--6sX45UoQRIJXqkqR--
