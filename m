From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 3/3] netfilter: xt_CT: remove a compile warning
Date: Tue, 3 Apr 2012 14:09:00 +0200
Message-ID: <20120403120900.GB6010@1984>
References: <1333448001-2507-1-git-send-email-pablo@netfilter.org>
 <1333448001-2507-4-git-send-email-pablo@netfilter.org>
 <201204031927.AIJ09351.FQFMJOOVFSOtHL@I-love.SAKURA.ne.jp>
 <201204032048.GFH51564.QSOVLMOOJHtFFF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="7JfCtLOvnd9MIVvH"
Cc: netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60814 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753240Ab2DCMJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 08:09:09 -0400
Content-Disposition: inline
In-Reply-To: <201204032048.GFH51564.QSOVLMOOJHtFFF@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--7JfCtLOvnd9MIVvH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Apr 03, 2012 at 08:48:21PM +0900, Tetsuo Handa wrote:
> One more question.
> 
> Tetsuo Handa wrote:
> > 216 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
> > 217         if (info->timeout) {
> > 218                 typeof(nf_ct_timeout_find_get_hook) timeout_find_get;
> > 219                 struct ctnl_timeout *timeout;
> > 220                 struct nf_conn_timeout *timeout_ext;
> > 221 
> > 222                 rcu_read_lock();
> > 223                 timeout_find_get =
> > 224                         rcu_dereference(nf_ct_timeout_find_get_hook);
> > 225 
> > 226                 if (timeout_find_get) {
> 
> I assume timeout_find_get points to e.g. ctnl_timeout_find_get in
> net/netfilter/nfnetlink_cttimeout.c . If yes,
> 
> > 227                         const struct ipt_entry *e = par->entryinfo;
> > 228                         struct nf_conntrack_l4proto *l4proto;
> > 229 
> > 230                         if (e->ip.invflags & IPT_INV_PROTO) {
> > 231                                 ret = -EINVAL;
> > 232                                 pr_info("You cannot use inversion on "
> > 233                                          "L4 protocol\n");
> > 234                                 goto err4;
> > 235                         }
> > 236                         timeout = timeout_find_get(info->timeout);
> > 237                         if (timeout == NULL) {
> > 238                                 ret = -ENOENT;
> > 239                                 pr_info("No such timeout policy \"%s\"\n",
> > 240                                         info->timeout);
> > 241                                 goto err4;
> > 242                         }
> 
> I think "goto err4;" after successful timeout_find_get() wants e.g.
> nf_ct_timeout_put_hook call (e.g. ctnl_timeout_put()).

Indeed. The patch attached should fix this problem. Thanks.

--7JfCtLOvnd9MIVvH
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-xt_CT-fix-missing-put-timeout-object-in-er.patch"

>From a7ff65f786a38c6a612eb3b65ccdf9ea4c517503 Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 3 Apr 2012 14:00:18 +0200
Subject: [PATCH] netfilter: xt_CT: fix missing put timeout object in error path

The error path misses putting the timeout object. This patch adds
new function xt_ct_tg_timeout_put() to do that to avoid code
duplication.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_CT.c |   44 +++++++++++++++++++++++++-------------------
 1 files changed, 25 insertions(+), 19 deletions(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 4babb27..89126fc 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -150,6 +150,24 @@ err1:
 	return ret;
 }
 
+static void xt_ct_tg_timeout_put(struct nf_conn *ct)
+{
+#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
+	struct nf_conn_timeout *timeout_ext;
+	typeof(nf_ct_timeout_put_hook) timeout_put;
+
+	rcu_read_lock();
+	timeout_put = rcu_dereference(nf_ct_timeout_put_hook);
+
+	if (timeout_put) {
+		timeout_ext = nf_ct_timeout_find(ct);
+		if (timeout_ext)
+			timeout_put(timeout_ext->timeout);
+	}
+	rcu_read_unlock();
+#endif
+}
+
 static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 {
 	struct xt_ct_target_info_v1 *info = par->targinfo;
@@ -245,7 +263,7 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 				pr_info("Timeout policy `%s' can only be "
 					"used by L3 protocol number %d\n",
 					info->timeout, timeout->l3num);
-				goto err4;
+				goto err5;
 			}
 			/* Make sure the timeout policy matches any existing
 			 * protocol tracker, otherwise default to generic.
@@ -258,13 +276,13 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 					"used by L4 protocol number %d\n",
 					info->timeout,
 					timeout->l4proto->l4proto);
-				goto err4;
+				goto err5;
 			}
 			timeout_ext = nf_ct_timeout_ext_add(ct, timeout,
 							    GFP_ATOMIC);
 			if (timeout_ext == NULL) {
 				ret = -ENOMEM;
-				goto err4;
+				goto err5;
 			}
 		} else {
 			ret = -ENOENT;
@@ -282,6 +300,8 @@ out:
 	return 0;
 
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
+err5:
+	xt_ct_tg_timeout_put(ct);
 err4:
 	rcu_read_unlock();
 #endif
@@ -314,28 +334,14 @@ static void xt_ct_tg_destroy_v1(const struct xt_tgdtor_param *par)
 	struct xt_ct_target_info_v1 *info = par->targinfo;
 	struct nf_conn *ct = info->ct;
 	struct nf_conn_help *help;
-#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
-	struct nf_conn_timeout *timeout_ext;
-	typeof(nf_ct_timeout_put_hook) timeout_put;
-#endif
+
 	if (!nf_ct_is_untracked(ct)) {
 		help = nfct_help(ct);
 		if (help)
 			module_put(help->helper->me);
 
 		nf_ct_l3proto_module_put(par->family);
-
-#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
-		rcu_read_lock();
-		timeout_put = rcu_dereference(nf_ct_timeout_put_hook);
-
-		if (timeout_put) {
-			timeout_ext = nf_ct_timeout_find(ct);
-			if (timeout_ext)
-				timeout_put(timeout_ext->timeout);
-		}
-		rcu_read_unlock();
-#endif
+		xt_ct_tg_timeout_put(ct);
 	}
 	nf_ct_put(info->ct);
 }
-- 
1.7.2.5


--7JfCtLOvnd9MIVvH--
