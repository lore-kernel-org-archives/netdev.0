From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 1/3] net: sched: consolidate offload decision in
 cls_u32
Date: Thu, 25 Feb 2016 15:19:44 -0800
Message-ID: <20160225231944.9820.40012.stgit@john-Precision-Tower-5810>
References: <20160225231540.9820.7688.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, jhs@mojatatu.com
To: jiri@resnulli.us, john.fastabend@gmail.com, daniel@iogearbox.net,
	simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35001 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbcBYXUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 18:20:10 -0500
Received: by mail-pf0-f170.google.com with SMTP id c10so42075742pfc.2
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 15:20:10 -0800 (PST)
In-Reply-To: <20160225231540.9820.7688.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The offload decision was originally very basic and tied to if the dev
implemented the appropriate ndo op hook. The next step is to allow
the user to more flexibly define if any paticular rule should be
offloaded or not. In order to have this logic in one function lift
the current check into a helper routine tc_should_offload().

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/pkt_cls.h |    5 +++++
 net/sched/cls_u32.c   |    8 ++++----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 2121df5..e64d20b 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -392,4 +392,9 @@ struct tc_cls_u32_offload {
 	};
 };
 
+static inline bool tc_should_offload(struct net_device *dev)
+{
+	return dev->netdev_ops->ndo_setup_tc;
+}
+
 #endif
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index d54bc94..24e888b 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -434,7 +434,7 @@ static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (dev->netdev_ops->ndo_setup_tc) {
+	if (tc_should_offload(dev)) {
 		offload.cls_u32->command = TC_CLSU32_DELETE_KNODE;
 		offload.cls_u32->knode.handle = handle;
 		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
@@ -451,7 +451,7 @@ static void u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (dev->netdev_ops->ndo_setup_tc) {
+	if (tc_should_offload(dev)) {
 		offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
 		offload.cls_u32->hnode.divisor = h->divisor;
 		offload.cls_u32->hnode.handle = h->handle;
@@ -471,7 +471,7 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (dev->netdev_ops->ndo_setup_tc) {
+	if (tc_should_offload(dev)) {
 		offload.cls_u32->command = TC_CLSU32_DELETE_HNODE;
 		offload.cls_u32->hnode.divisor = h->divisor;
 		offload.cls_u32->hnode.handle = h->handle;
@@ -491,7 +491,7 @@ static void u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n)
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (dev->netdev_ops->ndo_setup_tc) {
+	if (tc_should_offload(dev)) {
 		offload.cls_u32->command = TC_CLSU32_REPLACE_KNODE;
 		offload.cls_u32->knode.handle = n->handle;
 		offload.cls_u32->knode.fshift = n->fshift;
