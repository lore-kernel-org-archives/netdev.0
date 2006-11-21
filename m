From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 7/11] [SCHED]: Use kmemdup & kzalloc where appropriate
Date: Tue, 21 Nov 2006 01:28:37 -0200
Message-ID: <20061121032837.GH7039@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:13549 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1030689AbWKUD2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 22:28:43 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/sched/act_ipt.c    |    6 ++----
 net/sched/act_simple.c |    3 +--
 net/sched/cls_api.c    |    3 +--
 net/sched/em_meta.c    |    3 +--
 net/sched/em_nbyte.c   |    4 +---
 net/sched/ematch.c     |    3 +--
 6 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index d8c9310..a960806 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -156,10 +156,9 @@ static int tcf_ipt_init(struct rtattr *r
 	    rtattr_strlcpy(tname, tb[TCA_IPT_TABLE-1], IFNAMSIZ) >= IFNAMSIZ)
 		strcpy(tname, "mangle");
 
-	t = kmalloc(td->u.target_size, GFP_KERNEL);
+	t = kmemdup(td, td->u.target_size, GFP_KERNEL);
 	if (unlikely(!t))
 		goto err2;
-	memcpy(t, td, td->u.target_size);
 
 	if ((err = ipt_init_target(t, tname, hook)) < 0)
 		goto err3;
@@ -256,13 +255,12 @@ static int tcf_ipt_dump(struct sk_buff *
 	** for foolproof you need to not assume this
 	*/
 
-	t = kmalloc(ipt->tcfi_t->u.user.target_size, GFP_ATOMIC);
+	t = kmemdup(ipt->tcfi_t, ipt->tcfi_t->u.user.target_size, GFP_ATOMIC);
 	if (unlikely(!t))
 		goto rtattr_failure;
 
 	c.bindcnt = ipt->tcf_bindcnt - bind;
 	c.refcnt = ipt->tcf_refcnt - ref;
-	memcpy(t, ipt->tcfi_t, ipt->tcfi_t->u.user.target_size);
 	strcpy(t->u.user.name, ipt->tcfi_t->u.kernel.target->name);
 
 	RTA_PUT(skb, TCA_IPT_TARG, ipt->tcfi_t->u.user.target_size, t);
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 901571a..5fe8085 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -71,11 +71,10 @@ static int tcf_simp_release(struct tcf_d
 
 static int alloc_defdata(struct tcf_defact *d, u32 datalen, void *defdata)
 {
-	d->tcfd_defdata = kmalloc(datalen, GFP_KERNEL);
+	d->tcfd_defdata = kmemdup(defdata, datalen, GFP_KERNEL);
 	if (unlikely(!d->tcfd_defdata))
 		return -ENOMEM;
 	d->tcfd_datalen = datalen;
-	memcpy(d->tcfd_defdata, defdata, datalen);
 	return 0;
 }
 
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 37a1840..edb8fc9 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -217,7 +217,7 @@ replay:
 		/* Create new proto tcf */
 
 		err = -ENOBUFS;
-		if ((tp = kmalloc(sizeof(*tp), GFP_KERNEL)) == NULL)
+		if ((tp = kzalloc(sizeof(*tp), GFP_KERNEL)) == NULL)
 			goto errout;
 		err = -EINVAL;
 		tp_ops = tcf_proto_lookup_ops(tca[TCA_KIND-1]);
@@ -247,7 +247,6 @@ #endif
 			kfree(tp);
 			goto errout;
 		}
-		memset(tp, 0, sizeof(*tp));
 		tp->ops = tp_ops;
 		tp->protocol = protocol;
 		tp->prio = nprio ? : tcf_auto_prio(*back);
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index d3ff350..45d47d3 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -546,10 +546,9 @@ static int meta_var_change(struct meta_v
 {
 	int len = RTA_PAYLOAD(rta);
 
-	dst->val = (unsigned long) kmalloc(len, GFP_KERNEL);
+	dst->val = (unsigned long)kmemdup(RTA_DATA(rta), len, GFP_KERNEL);
 	if (dst->val == 0UL)
 		return -ENOMEM;
-	memcpy((void *) dst->val, RTA_DATA(rta), len);
 	dst->len = len;
 	return 0;
 }
diff --git a/net/sched/em_nbyte.c b/net/sched/em_nbyte.c
index cc80bab..005db40 100644
--- a/net/sched/em_nbyte.c
+++ b/net/sched/em_nbyte.c
@@ -34,12 +34,10 @@ static int em_nbyte_change(struct tcf_pr
 		return -EINVAL;
 
 	em->datalen = sizeof(*nbyte) + nbyte->len;
-	em->data = (unsigned long) kmalloc(em->datalen, GFP_KERNEL);
+	em->data = (unsigned long)kmemdup(data, em->datalen, GFP_KERNEL);
 	if (em->data == 0UL)
 		return -ENOBUFS;
 
-	memcpy((void *) em->data, data, em->datalen);
-
 	return 0;
 }
 
diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index 0fd0768..8f8a16d 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -251,12 +251,11 @@ static int tcf_em_validate(struct tcf_pr
 					goto errout;
 				em->data = *(u32 *) data;
 			} else {
-				void *v = kmalloc(data_len, GFP_KERNEL);
+				void *v = kmemdup(data, data_len, GFP_KERNEL);
 				if (v == NULL) {
 					err = -ENOBUFS;
 					goto errout;
 				}
-				memcpy(v, data, data_len);
 				em->data = (unsigned long) v;
 			}
 		}
-- 
1.4.2.1.g3d5c

