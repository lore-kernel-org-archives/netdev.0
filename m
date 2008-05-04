From: jamal <hadi@cyberus.ca>
Subject: [NET_CLS_ACT] make act_simple use of netlink policy
Date: Sun, 04 May 2008 13:47:14 -0400
Message-ID: <1209923234.6972.95.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-eOTe/n+cWqavEwd93C1N"
Cc: kaber@trash.net, 12o3l@tiscali.nl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.234]:2863 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246AbYEDRrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 13:47:20 -0400
Received: by wr-out-0506.google.com with SMTP id c48so1144040wra.1
        for <netdev@vger.kernel.org>; Sun, 04 May 2008 10:47:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-eOTe/n+cWqavEwd93C1N
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Promised patch - also resolves a leak.

cheers,
jamal

--=-eOTe/n+cWqavEwd93C1N
Content-Disposition: attachment; filename=act_simp1
Content-Type: text/plain; name=act_simp1; charset=us-ascii
Content-Transfer-Encoding: 7bit

[NET_CLS_ACT] make act_simple use of netlink policy

Convert to netlink helpers by using netlink policy validation.
As a side effect fixes a leak.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit a189f0b99f377aeadd1d56046c4c0d2694cd9734
tree b402736fe9c201b4388933d204f608c186d368a8
parent afa26be86b65a7183ceac29bdf1f51d6fc6932f0
author Jamal Hadi Salim <hadi@cyberus.ca> Sun, 04 May 2008 13:42:54 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Sun, 04 May 2008 13:42:54 -0400

 net/sched/act_simple.c |   34 ++++++++++++++++------------------
 1 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 64b2d13..269ab51 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -6,7 +6,7 @@
  *		as published by the Free Software Foundation; either version
  *		2 of the License, or (at your option) any later version.
  *
- * Authors:	Jamal Hadi Salim (2005)
+ * Authors:	Jamal Hadi Salim (2005-8)
  *
  */
 
@@ -34,6 +34,7 @@ static struct tcf_hashinfo simp_hash_info = {
 	.lock	=	&simp_lock,
 };
 
+#define SIMP_MAX_DATA	32
 static int tcf_simp(struct sk_buff *skb, struct tc_action *a, struct tcf_result *res)
 {
 	struct tcf_defact *d = a->priv;
@@ -69,23 +70,24 @@ static int tcf_simp_release(struct tcf_defact *d, int bind)
 	return ret;
 }
 
-static int alloc_defdata(struct tcf_defact *d, u32 datalen, void *defdata)
+static int alloc_defdata(struct tcf_defact *d, char *defdata)
 {
-	d->tcfd_defdata = kmemdup(defdata, datalen, GFP_KERNEL);
+	d->tcfd_defdata = kstrndup(defdata, SIMP_MAX_DATA, GFP_KERNEL);
 	if (unlikely(!d->tcfd_defdata))
 		return -ENOMEM;
-	d->tcfd_datalen = datalen;
+
 	return 0;
 }
 
-static int realloc_defdata(struct tcf_defact *d, u32 datalen, void *defdata)
+static int realloc_defdata(struct tcf_defact *d, char *defdata)
 {
 	kfree(d->tcfd_defdata);
-	return alloc_defdata(d, datalen, defdata);
+	return alloc_defdata(d, defdata);
 }
 
 static const struct nla_policy simple_policy[TCA_DEF_MAX + 1] = {
 	[TCA_DEF_PARMS]	= { .len = sizeof(struct tc_defact) },
+	[TCA_DEF_DATA]	= { .type = NLA_STRING, .len = SIMP_MAX_DATA },
 };
 
 static int tcf_simp_init(struct nlattr *nla, struct nlattr *est,
@@ -95,28 +97,24 @@ static int tcf_simp_init(struct nlattr *nla, struct nlattr *est,
 	struct tc_defact *parm;
 	struct tcf_defact *d;
 	struct tcf_common *pc;
-	void *defdata;
-	u32 datalen = 0;
+	char *defdata;
 	int ret = 0, err;
 
 	if (nla == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_DEF_MAX, nla, NULL);
+	err = nla_parse_nested(tb, TCA_DEF_MAX, nla, simple_policy);
 	if (err < 0)
 		return err;
 
 	if (tb[TCA_DEF_PARMS] == NULL)
 		return -EINVAL;
 
-	parm = nla_data(tb[TCA_DEF_PARMS]);
-	defdata = nla_data(tb[TCA_DEF_DATA]);
-	if (defdata == NULL)
+	if (tb[TCA_DEF_DATA] == NULL)
 		return -EINVAL;
 
-	datalen = nla_len(tb[TCA_DEF_DATA]);
-	if (datalen == 0)
-		return -EINVAL;
+	parm = nla_data(tb[TCA_DEF_PARMS]);
+	defdata = nla_data(tb[TCA_DEF_DATA]);
 
 	pc = tcf_hash_check(parm->index, a, bind, &simp_hash_info);
 	if (!pc) {
@@ -126,7 +124,7 @@ static int tcf_simp_init(struct nlattr *nla, struct nlattr *est,
 			return -ENOMEM;
 
 		d = to_defact(pc);
-		ret = alloc_defdata(d, datalen, defdata);
+		ret = alloc_defdata(d, defdata);
 		if (ret < 0) {
 			kfree(pc);
 			return ret;
@@ -138,7 +136,7 @@ static int tcf_simp_init(struct nlattr *nla, struct nlattr *est,
 			tcf_simp_release(d, bind);
 			return -EEXIST;
 		}
-		realloc_defdata(d, datalen, defdata);
+		realloc_defdata(d, defdata);
 	}
 
 	spin_lock_bh(&d->tcf_lock);
@@ -172,7 +170,7 @@ static inline int tcf_simp_dump(struct sk_buff *skb, struct tc_action *a,
 	opt.bindcnt = d->tcf_bindcnt - bind;
 	opt.action = d->tcf_action;
 	NLA_PUT(skb, TCA_DEF_PARMS, sizeof(opt), &opt);
-	NLA_PUT(skb, TCA_DEF_DATA, d->tcfd_datalen, d->tcfd_defdata);
+	NLA_PUT_STRING(skb, TCA_DEF_DATA, d->tcfd_defdata);
 	t.install = jiffies_to_clock_t(jiffies - d->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - d->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(d->tcf_tm.expires);

--=-eOTe/n+cWqavEwd93C1N--

