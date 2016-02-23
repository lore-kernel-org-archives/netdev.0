From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 1/4] net: sched: consolidate offload decision in
 cls_u32
Date: Tue, 23 Feb 2016 11:02:33 -0800
Message-ID: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, jhs@mojatatu.com
To: jiri@resnulli.us, john.fastabend@gmail.com, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35244 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbcBWTCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 14:02:51 -0500
Received: by mail-pa0-f45.google.com with SMTP id ho8so117980378pac.2
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 11:02:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The offload decision was originally very basic and tied to if the dev
implemented the appropriate ndo op hook. The next step is to allow
the user to more flexibly define if any paticular rule should be
offloaded or not. In order to have this logic in one function lift
the current check into a helper routine tc_should_offload().

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_u32.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index d54bc94..1f31929 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -425,6 +425,11 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
 	return 0;
 }
 
+static bool u32_should_offload(struct net_device *dev)
+{
+	return dev->netdev_ops->ndo_setup_tc;
+}
+
 static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
@@ -434,7 +439,7 @@ static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (dev->netdev_ops->ndo_setup_tc) {
+	if (u32_should_offload(dev)) {
 		offload.cls_u32->command = TC_CLSU32_DELETE_KNODE;
 		offload.cls_u32->knode.handle = handle;
 		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
@@ -451,7 +456,7 @@ static void u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (dev->netdev_ops->ndo_setup_tc) {
+	if (u32_should_offload(dev)) {
 		offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
 		offload.cls_u32->hnode.divisor = h->divisor;
 		offload.cls_u32->hnode.handle = h->handle;
@@ -471,7 +476,7 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (dev->netdev_ops->ndo_setup_tc) {
+	if (u32_should_offload(dev)) {
 		offload.cls_u32->command = TC_CLSU32_DELETE_HNODE;
 		offload.cls_u32->hnode.divisor = h->divisor;
 		offload.cls_u32->hnode.handle = h->handle;
@@ -491,7 +496,7 @@ static void u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n)
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (dev->netdev_ops->ndo_setup_tc) {
+	if (u32_should_offload(dev)) {
 		offload.cls_u32->command = TC_CLSU32_REPLACE_KNODE;
 		offload.cls_u32->knode.handle = n->handle;
 		offload.cls_u32->knode.fshift = n->fshift;
