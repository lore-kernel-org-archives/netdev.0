From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6]: Resolve race condition with module unload in qdisc_create
Date: Tue, 17 Aug 2004 02:00:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41214A95.2000103@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000808090602090109040007"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000808090602090109040007
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch resolves the race condition with module unload
in qdisc_create by moving try_module_get up to the first
qdisc_lookup_ops call.


--------------000808090602090109040007
Content-Type: text/x-patch;
 name="qdisc_create-race.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="qdisc_create-race.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/17 01:32:55+02:00 kaber@coreworks.de 
#   [PKT_SCHED]: Resolve race condition with module unload in qdisc_create()
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_api.c
#   2004/08/17 01:32:36+02:00 kaber@coreworks.de +6 -13
#   [PKT_SCHED]: Resolve race condition with module unload in qdisc_create()
# 
diff -Nru a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	2004-08-17 01:35:50 +02:00
+++ b/net/sched/sch_api.c	2004-08-17 01:35:50 +02:00
@@ -407,6 +407,9 @@
 	err = -EINVAL;
 	if (ops == NULL)
 		goto err_out;
+	err = -EBUSY;
+	if (!try_module_get(ops->owner))
+		goto err_out;
 
 	/* ensure that the Qdisc and the private data are 32-byte aligned */
 	size = ((sizeof(*sch) + QDISC_ALIGN_CONST) & ~QDISC_ALIGN_CONST);
@@ -415,18 +418,12 @@
 	p = kmalloc(size, GFP_KERNEL);
 	err = -ENOBUFS;
 	if (!p)
-		goto err_out;
+		goto err_out2;
 	memset(p, 0, size);
 	sch = (struct Qdisc *)(((unsigned long)p + QDISC_ALIGN_CONST)
 	                       & ~QDISC_ALIGN_CONST);
 	sch->padded = (char *)sch - (char *)p;
 
-	/* Grrr... Resolve race condition with module unload */
-
-	err = -EINVAL;
-	if (ops != qdisc_lookup_ops(kind))
-		goto err_out;
-
 	INIT_LIST_HEAD(&sch->list);
 	skb_queue_head_init(&sch->q);
 
@@ -444,7 +441,7 @@
 		handle = qdisc_alloc_handle(dev);
 		err = -ENOMEM;
 		if (handle == 0)
-			goto err_out;
+			goto err_out2;
 	}
 
 	if (handle == TC_H_INGRESS)
@@ -452,10 +449,6 @@
         else
                 sch->handle = handle;
 
-	err = -EBUSY;
-	if (!try_module_get(ops->owner))
-		goto err_out;
-
 	/* enqueue is accessed locklessly - make sure it's visible
 	 * before we set a netdevice's qdisc pointer to sch */
 	smp_wmb();
@@ -471,8 +464,8 @@
 #endif
 		return sch;
 	}
+err_out2:
 	module_put(ops->owner);
-
 err_out:
 	*errp = err;
 	if (p)

--------------000808090602090109040007--
