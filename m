From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: fix error recovery at qdisc creation
Date: Fri, 10 Feb 2017 10:31:49 -0800
Message-ID: <1486751509.7793.162.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36702 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752174AbdBJSis (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 13:38:48 -0500
Received: by mail-pg0-f67.google.com with SMTP id 75so3687782pgf.3
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 10:38:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Dmitry reported uses after free in qdisc code [1]

The problem here is that ops->init() can return an error.

qdisc_create_dflt() then call ops->destroy(),
while qdisc_create() does _not_ call it.

Four qdisc chose to call their own ops->destroy(), assuming their caller
would not.

This patch makes sure qdisc_create() calls ops->destroy()
and fixes the four qdisc to avoid double free.

[1]
BUG: KASAN: use-after-free in mq_destroy+0x242/0x290 net/sched/sch_mq.c:33 at addr ffff8801d415d440
Read of size 8 by task syz-executor2/5030
CPU: 0 PID: 5030 Comm: syz-executor2 Not tainted 4.3.5-smp-DEV #119
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
 0000000000000046 ffff8801b435b870 ffffffff81bbbed4 ffff8801db000400
 ffff8801d415d440 ffff8801d415dc40 ffff8801c4988510 ffff8801b435b898
 ffffffff816682b1 ffff8801b435b928 ffff8801d415d440 ffff8801c49880c0
Call Trace:
 [<ffffffff81bbbed4>] __dump_stack lib/dump_stack.c:15 [inline]
 [<ffffffff81bbbed4>] dump_stack+0x6c/0x98 lib/dump_stack.c:51
 [<ffffffff816682b1>] kasan_object_err+0x21/0x70 mm/kasan/report.c:158
 [<ffffffff81668524>] print_address_description mm/kasan/report.c:196 [inline]
 [<ffffffff81668524>] kasan_report_error+0x1b4/0x4b0 mm/kasan/report.c:285
 [<ffffffff81668953>] kasan_report mm/kasan/report.c:305 [inline]
 [<ffffffff81668953>] __asan_report_load8_noabort+0x43/0x50 mm/kasan/report.c:326
 [<ffffffff82527b02>] mq_destroy+0x242/0x290 net/sched/sch_mq.c:33
 [<ffffffff82524bdd>] qdisc_destroy+0x12d/0x290 net/sched/sch_generic.c:953
 [<ffffffff82524e30>] qdisc_create_dflt+0xf0/0x120 net/sched/sch_generic.c:848
 [<ffffffff8252550d>] attach_default_qdiscs net/sched/sch_generic.c:1029 [inline]
 [<ffffffff8252550d>] dev_activate+0x6ad/0x880 net/sched/sch_generic.c:1064
 [<ffffffff824b1db1>] __dev_open+0x221/0x320 net/core/dev.c:1403
 [<ffffffff824b24ce>] __dev_change_flags+0x15e/0x3e0 net/core/dev.c:6858
 [<ffffffff824b27de>] dev_change_flags+0x8e/0x140 net/core/dev.c:6926
 [<ffffffff824f5bf6>] dev_ifsioc+0x446/0x890 net/core/dev_ioctl.c:260
 [<ffffffff824f61fa>] dev_ioctl+0x1ba/0xb80 net/core/dev_ioctl.c:546
 [<ffffffff82430509>] sock_do_ioctl+0x99/0xb0 net/socket.c:879
 [<ffffffff82430d30>] sock_ioctl+0x2a0/0x390 net/socket.c:958
 [<ffffffff816f3b68>] vfs_ioctl fs/ioctl.c:44 [inline]
 [<ffffffff816f3b68>] do_vfs_ioctl+0x8a8/0xe50 fs/ioctl.c:611
 [<ffffffff816f41a4>] SYSC_ioctl fs/ioctl.c:626 [inline]
 [<ffffffff816f41a4>] SyS_ioctl+0x94/0xc0 fs/ioctl.c:617
 [<ffffffff8123e357>] entry_SYSCALL_64_fastpath+0x12/0x17

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
---
 net/sched/sch_api.c    |    2 ++
 net/sched/sch_hhf.c    |    8 ++++++--
 net/sched/sch_mq.c     |   10 +++-------
 net/sched/sch_mqprio.c |   19 ++++++-------------
 net/sched/sch_sfq.c    |    3 ++-
 5 files changed, 19 insertions(+), 23 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index adeabaec0d0b8bd3115e8d8db756460227142c60..a13c15e8f08782f9a428690052bf5585c446b6fe 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1019,6 +1019,8 @@ static struct Qdisc *qdisc_create(struct net_device *dev,
 
 		return sch;
 	}
+	/* ops->init() failed, we call ->destroy() like qdisc_create_dflt() */
+	ops->destroy(sch);
 err_out3:
 	dev_put(dev);
 	kfree((char *) sch - sch->padded);
diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index e3d0458af17ba32cb203d4a5bed952baf9d22588..2fae8b5f1b80c017c4ae60df54c9143f82de4e9d 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -627,7 +627,9 @@ static int hhf_init(struct Qdisc *sch, struct nlattr *opt)
 			q->hhf_arrays[i] = hhf_zalloc(HHF_ARRAYS_LEN *
 						      sizeof(u32));
 			if (!q->hhf_arrays[i]) {
-				hhf_destroy(sch);
+				/* Note: hhf_destroy() will be called
+				 * by our caller.
+				 */
 				return -ENOMEM;
 			}
 		}
@@ -638,7 +640,9 @@ static int hhf_init(struct Qdisc *sch, struct nlattr *opt)
 			q->hhf_valid_bits[i] = hhf_zalloc(HHF_ARRAYS_LEN /
 							  BITS_PER_BYTE);
 			if (!q->hhf_valid_bits[i]) {
-				hhf_destroy(sch);
+				/* Note: hhf_destroy() will be called
+				 * by our caller.
+				 */
 				return -ENOMEM;
 			}
 		}
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index 2bc8d7f8df161005bc89245ca5ebc52f3360e3af..20b7f1646f69270e08d8b7588759a0146f262e89 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -52,7 +52,7 @@ static int mq_init(struct Qdisc *sch, struct nlattr *opt)
 	/* pre-allocate qdiscs, attachment can't fail */
 	priv->qdiscs = kcalloc(dev->num_tx_queues, sizeof(priv->qdiscs[0]),
 			       GFP_KERNEL);
-	if (priv->qdiscs == NULL)
+	if (!priv->qdiscs)
 		return -ENOMEM;
 
 	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
@@ -60,18 +60,14 @@ static int mq_init(struct Qdisc *sch, struct nlattr *opt)
 		qdisc = qdisc_create_dflt(dev_queue, get_default_qdisc_ops(dev, ntx),
 					  TC_H_MAKE(TC_H_MAJ(sch->handle),
 						    TC_H_MIN(ntx + 1)));
-		if (qdisc == NULL)
-			goto err;
+		if (!qdisc)
+			return -ENOMEM;
 		priv->qdiscs[ntx] = qdisc;
 		qdisc->flags |= TCQ_F_ONETXQUEUE | TCQ_F_NOPARENT;
 	}
 
 	sch->flags |= TCQ_F_MQROOT;
 	return 0;
-
-err:
-	mq_destroy(sch);
-	return -ENOMEM;
 }
 
 static void mq_attach(struct Qdisc *sch)
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index b5c502c781439c0440c088b000a7b859271e50b2..922683418e53853cb71747d8d30ab0e4a989254b 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -118,10 +118,8 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 	/* pre-allocate qdisc, attachment can't fail */
 	priv->qdiscs = kcalloc(dev->num_tx_queues, sizeof(priv->qdiscs[0]),
 			       GFP_KERNEL);
-	if (priv->qdiscs == NULL) {
-		err = -ENOMEM;
-		goto err;
-	}
+	if (!priv->qdiscs)
+		return -ENOMEM;
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		dev_queue = netdev_get_tx_queue(dev, i);
@@ -129,10 +127,9 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 					  get_default_qdisc_ops(dev, i),
 					  TC_H_MAKE(TC_H_MAJ(sch->handle),
 						    TC_H_MIN(i + 1)));
-		if (qdisc == NULL) {
-			err = -ENOMEM;
-			goto err;
-		}
+		if (!qdisc)
+			return -ENOMEM;
+
 		priv->qdiscs[i] = qdisc;
 		qdisc->flags |= TCQ_F_ONETXQUEUE | TCQ_F_NOPARENT;
 	}
@@ -148,7 +145,7 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 		priv->hw_owned = 1;
 		err = dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0, &tc);
 		if (err)
-			goto err;
+			return err;
 	} else {
 		netdev_set_num_tc(dev, qopt->num_tc);
 		for (i = 0; i < qopt->num_tc; i++)
@@ -162,10 +159,6 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 
 	sch->flags |= TCQ_F_MQROOT;
 	return 0;
-
-err:
-	mqprio_destroy(sch);
-	return err;
 }
 
 static void mqprio_attach(struct Qdisc *sch)
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 83d06e251b93cda13938cc00d75ff7c45d7785ad..42e8c8615e6563a2deabbb3c3437e3985d01ae14 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -743,9 +743,10 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->ht = sfq_alloc(sizeof(q->ht[0]) * q->divisor);
 	q->slots = sfq_alloc(sizeof(q->slots[0]) * q->maxflows);
 	if (!q->ht || !q->slots) {
-		sfq_destroy(sch);
+		/* Note: sfq_destroy() will be called by our caller */
 		return -ENOMEM;
 	}
+
 	for (i = 0; i < q->divisor; i++)
 		q->ht[i] = SFQ_EMPTY_SLOT;
 
