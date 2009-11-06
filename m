From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] can: should not use __dev_get_by_index() without locks
Date: Fri, 06 Nov 2009 11:23:01 +0100
Message-ID: <4AF3F905.4030608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37647 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754654AbZKFKW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 05:22:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David

A more elegant patch will be possible for 2.6.33, but for 2.6.32,
I think following patch is needed (Please note I did not test it)

(More elegant : use RCU lookups ;) , I'll wait for net-next-2.6 
 upgrade as well)

Thanks

[PATCH] can: should not use __dev_get_by_index() without locks

bcm_proc_getifname() is called with RTNL and dev_base_lock
not held. It calls __dev_get_by_index() without locks, and
this is illegal (might crash)

Close the race by holding dev_base_lock and copying dev->name
in the protected section.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/can/bcm.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/can/bcm.c b/net/can/bcm.c
index 597da4f..e8d58f3 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -132,23 +132,27 @@ static inline struct bcm_sock *bcm_sk(const struct sock *sk)
 /*
  * procfs functions
  */
-static char *bcm_proc_getifname(int ifindex)
+static char *bcm_proc_getifname(char *result, int ifindex)
 {
 	struct net_device *dev;
 
 	if (!ifindex)
 		return "any";
 
-	/* no usage counting */
+	read_lock(&dev_base_lock);
 	dev = __dev_get_by_index(&init_net, ifindex);
 	if (dev)
-		return dev->name;
+		strcpy(result, dev->name);
+	else
+		strcpy(result, "???");
+	read_unlock(&dev_base_lock);
 
-	return "???";
+	return result;
 }
 
 static int bcm_proc_show(struct seq_file *m, void *v)
 {
+	char ifname[IFNAMSIZ];
 	struct sock *sk = (struct sock *)m->private;
 	struct bcm_sock *bo = bcm_sk(sk);
 	struct bcm_op *op;
@@ -157,7 +161,7 @@ static int bcm_proc_show(struct seq_file *m, void *v)
 	seq_printf(m, " / sk %p", sk);
 	seq_printf(m, " / bo %p", bo);
 	seq_printf(m, " / dropped %lu", bo->dropped_usr_msgs);
-	seq_printf(m, " / bound %s", bcm_proc_getifname(bo->ifindex));
+	seq_printf(m, " / bound %s", bcm_proc_getifname(ifname, bo->ifindex));
 	seq_printf(m, " <<<\n");
 
 	list_for_each_entry(op, &bo->rx_ops, list) {
@@ -169,7 +173,7 @@ static int bcm_proc_show(struct seq_file *m, void *v)
 			continue;
 
 		seq_printf(m, "rx_op: %03X %-5s ",
-				op->can_id, bcm_proc_getifname(op->ifindex));
+				op->can_id, bcm_proc_getifname(ifname, op->ifindex));
 		seq_printf(m, "[%d]%c ", op->nframes,
 				(op->flags & RX_CHECK_DLC)?'d':' ');
 		if (op->kt_ival1.tv64)
@@ -194,7 +198,8 @@ static int bcm_proc_show(struct seq_file *m, void *v)
 	list_for_each_entry(op, &bo->tx_ops, list) {
 
 		seq_printf(m, "tx_op: %03X %s [%d] ",
-				op->can_id, bcm_proc_getifname(op->ifindex),
+				op->can_id,
+				bcm_proc_getifname(ifname, op->ifindex),
 				op->nframes);
 
 		if (op->kt_ival1.tv64)
