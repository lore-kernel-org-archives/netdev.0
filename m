From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH net-next] can: fix CAN BCM build with CONFIG_PROC_FS disabled
Date: Wed, 26 Apr 2017 20:14:34 +0200
Message-ID: <20170426181434.9635-1-socketcan@hartkopp.net>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, mkl@pengutronix.de,
        netdev@vger.kernel.org
To: linux-can@vger.kernel.org, davem@davemloft.net,
        rdunlap@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.220]:32768 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932942AbdDZSOv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 14:14:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The introduced namespace support moved the BCM variables for procfs into a
per-net data structure. This leads to a build failure with disabled procfs:

on x86_64:

when CONFIG_PROC_FS is not enabled:

../net/can/bcm.c:1541:14: error: 'struct netns_can' has no member named 'bcmproc_dir'
../net/can/bcm.c:1601:14: error: 'struct netns_can' has no member named 'bcmproc_dir'
../net/can/bcm.c:1696:11: error: 'struct netns_can' has no member named 'bcmproc_dir'
../net/can/bcm.c:1707:15: error: 'struct netns_can' has no member named 'bcmproc_dir'

http://marc.info/?l=linux-can&m=149321842526524&w=2

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
---
 net/can/bcm.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/net/can/bcm.c b/net/can/bcm.c
index 0e855917b7e1..78409841b74c 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -147,6 +147,7 @@ static inline ktime_t bcm_timeval_to_ktime(struct bcm_timeval tv)
 /*
  * procfs functions
  */
+#if IS_ENABLED(CONFIG_PROC_FS)
 static char *bcm_proc_getifname(struct net *net, char *result, int ifindex)
 {
 	struct net_device *dev;
@@ -251,6 +252,7 @@ static const struct file_operations bcm_proc_fops = {
 	.llseek		= seq_lseek,
 	.release	= single_release,
 };
+#endif /* CONFIG_PROC_FS */
 
 /*
  * bcm_can_tx - send the (next) CAN frame to the appropriate CAN interface
@@ -1537,9 +1539,11 @@ static int bcm_release(struct socket *sock)
 		bcm_remove_op(op);
 	}
 
+#if IS_ENABLED(CONFIG_PROC_FS)
 	/* remove procfs entry */
 	if (net->can.bcmproc_dir && bo->bcm_proc_read)
 		remove_proc_entry(bo->procname, net->can.bcmproc_dir);
+#endif /* CONFIG_PROC_FS */
 
 	/* remove device reference */
 	if (bo->bound) {
@@ -1598,6 +1602,7 @@ static int bcm_connect(struct socket *sock, struct sockaddr *uaddr, int len,
 		bo->ifindex = 0;
 	}
 
+#if IS_ENABLED(CONFIG_PROC_FS)
 	if (net->can.bcmproc_dir) {
 		/* unique socket address as filename */
 		sprintf(bo->procname, "%lu", sock_i_ino(sk));
@@ -1609,6 +1614,7 @@ static int bcm_connect(struct socket *sock, struct sockaddr *uaddr, int len,
 			goto fail;
 		}
 	}
+#endif /* CONFIG_PROC_FS */
 
 	bo->bound = 1;
 
@@ -1691,22 +1697,22 @@ static const struct can_proto bcm_can_proto = {
 
 static int canbcm_pernet_init(struct net *net)
 {
+#if IS_ENABLED(CONFIG_PROC_FS)
 	/* create /proc/net/can-bcm directory */
-	if (IS_ENABLED(CONFIG_PROC_FS)) {
-		net->can.bcmproc_dir =
-			proc_net_mkdir(net, "can-bcm", net->proc_net);
-	}
+	net->can.bcmproc_dir =
+		proc_net_mkdir(net, "can-bcm", net->proc_net);
+#endif /* CONFIG_PROC_FS */
 
 	return 0;
 }
 
 static void canbcm_pernet_exit(struct net *net)
 {
+#if IS_ENABLED(CONFIG_PROC_FS)
 	/* remove /proc/net/can-bcm directory */
-	if (IS_ENABLED(CONFIG_PROC_FS)) {
-		if (net->can.bcmproc_dir)
-			remove_proc_entry("can-bcm", net->proc_net);
-	}
+	if (net->can.bcmproc_dir)
+		remove_proc_entry("can-bcm", net->proc_net);
+#endif /* CONFIG_PROC_FS */
 }
 
 static struct pernet_operations canbcm_pernet_ops __read_mostly = {
-- 
2.11.0
