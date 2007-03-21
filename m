From: jamal <hadi@cyberus.ca>
Subject: [PATCH 1/1][PKT_CLS] Avoid multiple tree locks
Date: Wed, 21 Mar 2007 05:58:36 -0400
Message-ID: <1174471116.16343.10.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-HCz1u+QHG/QIXbS/g9xf"
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:61424 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbXCUJ6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 05:58:44 -0400
Received: by py-out-1112.google.com with SMTP id a29so68413pyi
        for <netdev@vger.kernel.org>; Wed, 21 Mar 2007 02:58:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-HCz1u+QHG/QIXbS/g9xf
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Seems to have been around a while. IMO, mterial for 2.6.21 but not
stable. I have only compile-tested but it looks right(tm).
I could have moved the lock down, but this looked safer.

cheers,
jamal

--=-HCz1u+QHG/QIXbS/g9xf
Content-Disposition: attachment; filename=qdtl_p
Content-Type: text/plain; name=qdtl_p; charset=us-ascii
Content-Transfer-Encoding: 7bit

[PKT_CLS] Avoid multiple tree locks
This fixes: When dumping filters the tree is locked first in the main
dump function then when looking qdisc

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 4a52cdd599f259b05320219d7aba1bac58fdf6d0
tree e9e4b83f7a2925b4408e4f18211365c3f9bff3fa
parent 0a14fe6e5efd0af0f9c6c01e0433445d615d0110
author Jamal Hadi Salim <hadi@cyberus.ca> Wed, 21 Mar 2007 05:27:55 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Wed, 21 Mar 2007 05:27:55 -0400

 include/net/pkt_sched.h |    1 +
 net/sched/cls_api.c     |    2 +-
 net/sched/sch_api.c     |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index f6afee7..dd930bd 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -212,6 +212,7 @@ extern struct Qdisc_ops bfifo_qdisc_ops;
 
 extern int register_qdisc(struct Qdisc_ops *qops);
 extern int unregister_qdisc(struct Qdisc_ops *qops);
+extern struct Qdisc *__qdisc_lookup(struct net_device *dev, u32 handle);
 extern struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle);
 extern struct Qdisc *qdisc_lookup_class(struct net_device *dev, u32 handle);
 extern struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 5c6ffdb..17d4d37 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -403,7 +403,7 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	if (!tcm->tcm_parent)
 		q = dev->qdisc_sleeping;
 	else
-		q = qdisc_lookup(dev, TC_H_MAJ(tcm->tcm_parent));
+		q = __qdisc_lookup(dev, TC_H_MAJ(tcm->tcm_parent));
 	if (!q)
 		goto out;
 	if ((cops = q->ops->cl_ops) == NULL)
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index ecc988a..1a3b65e 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -190,7 +190,7 @@ int unregister_qdisc(struct Qdisc_ops *qops)
    (root qdisc, all its children, children of children etc.)
  */
 
-static struct Qdisc *__qdisc_lookup(struct net_device *dev, u32 handle)
+struct Qdisc *__qdisc_lookup(struct net_device *dev, u32 handle)
 {
 	struct Qdisc *q;
 

--=-HCz1u+QHG/QIXbS/g9xf--

