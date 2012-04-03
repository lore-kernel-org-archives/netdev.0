From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 3/3] netfilter: xt_CT: remove a compile warning
Date: Tue, 3 Apr 2012 15:06:20 +0200
Message-ID: <20120403130620.GA15385@1984>
References: <1333448001-2507-1-git-send-email-pablo@netfilter.org>
 <1333448001-2507-4-git-send-email-pablo@netfilter.org>
 <201204031927.AIJ09351.FQFMJOOVFSOtHL@I-love.SAKURA.ne.jp>
 <201204032048.GFH51564.QSOVLMOOJHtFFF@I-love.SAKURA.ne.jp>
 <20120403120900.GB6010@1984>
 <201204032128.JEG78136.JStMOHQOVFFFLO@I-love.SAKURA.ne.jp>
 <20120403125755.GA15339@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="cNdxnHkX5QqsyA0e"
Cc: netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39746 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754177Ab2DCNG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 09:06:26 -0400
Content-Disposition: inline
In-Reply-To: <20120403125755.GA15339@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Apr 03, 2012 at 02:57:55PM +0200, Pablo Neira Ayuso wrote:
> On Tue, Apr 03, 2012 at 09:28:38PM +0900, Tetsuo Handa wrote:
> > Pablo Neira Ayuso wrote:
> > > Indeed. The patch attached should fix this problem. Thanks.
> > 
> > It seems to me that the timeout object is associated with the "ct"
> > by successful nf_ct_timeout_ext_add() call. If yes,
> > 
> >  +err5:
> >  +	xt_ct_tg_timeout_put(ct);
> > 
> > will not be able to find the timeout object.
> 
> You're right again. New patch attached.

> From 6b9599e7a092a241e86e376d14bb1b45902f19b5 Mon Sep 17 00:00:00 2001
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> Date: Tue, 3 Apr 2012 14:50:07 +0200
> Subject: [PATCH] netfilter: xt_CT: fix missing put timeout object in error path

A bit better patch, no need to hold rcu_read_lock again in
xt_ct_tg_timeout_put (even if that doesn't harm).

--cNdxnHkX5QqsyA0e
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-xt_CT-fix-missing-put-timeout-object-in-er.patch"

>From 96a1ee814eef63a917e2a0af7a70bbf85511d285 Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 3 Apr 2012 14:50:07 +0200
Subject: [PATCH] netfilter: xt_CT: fix missing put timeout object in error path

The error path misses putting the timeout object. This patch adds
new function xt_ct_tg_timeout_put() to put the timeout object.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_CT.c |   24 +++++++++++++++++++-----
 1 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 4babb27..59530e9 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -150,6 +150,17 @@ err1:
 	return ret;
 }
 
+#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
+static void __xt_ct_tg_timeout_put(struct ctnl_timeout *timeout)
+{
+	typeof(nf_ct_timeout_put_hook) timeout_put;
+
+	timeout_put = rcu_dereference(nf_ct_timeout_put_hook);
+	if (timeout_put)
+		timeout_put(timeout);
+}
+#endif
+
 static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 {
 	struct xt_ct_target_info_v1 *info = par->targinfo;
@@ -158,7 +169,9 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 	struct nf_conn *ct;
 	int ret = 0;
 	u8 proto;
-
+#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
+	struct ctnl_timeout *timeout;
+#endif
 	if (info->flags & ~XT_CT_NOTRACK)
 		return -EINVAL;
 
@@ -216,7 +229,6 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
 	if (info->timeout) {
 		typeof(nf_ct_timeout_find_get_hook) timeout_find_get;
-		struct ctnl_timeout *timeout;
 		struct nf_conn_timeout *timeout_ext;
 
 		rcu_read_lock();
@@ -245,7 +257,7 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 				pr_info("Timeout policy `%s' can only be "
 					"used by L3 protocol number %d\n",
 					info->timeout, timeout->l3num);
-				goto err4;
+				goto err5;
 			}
 			/* Make sure the timeout policy matches any existing
 			 * protocol tracker, otherwise default to generic.
@@ -258,13 +270,13 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
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
@@ -282,6 +294,8 @@ out:
 	return 0;
 
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
+err5:
+	__xt_ct_tg_timeout_put(timeout);
 err4:
 	rcu_read_unlock();
 #endif
-- 
1.7.2.5


--cNdxnHkX5QqsyA0e--
