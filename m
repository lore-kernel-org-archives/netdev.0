From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: [PATCH] #2: add more reset debug messages
Date: Tue, 10 Aug 2004 18:24:28 +0300
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200408101824.28368.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_siOGB9xPqwDdqgJ"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_siOGB9xPqwDdqgJ
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Luis,

On top of previous one:

* Some not needed NULL assignments removed
* Add some more printks to reset code path
* mgt_commit_list(): tell which oid has failed

All previous concerns about this patch are addressed
(some of removed NULL assignments were indeed needed).

Please apply.
--
vda

--Boundary-00=_siOGB9xPqwDdqgJ
Content-Type: text/x-diff; charset="us-ascii"; name="prism54-20040810.2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="prism54-20040810.2.patch"

* some not needed NULL assignments removed
* add some more printks to reset codepath
* mgt_commit_list(): tell which oid has failed

diff -urpN prism54-20040810.1/isl_ioctl.c prism54-20040810.2/isl_ioctl.c
--- prism54-20040810.1/isl_ioctl.c	Tue Aug 10 14:10:58 2004
+++ prism54-20040810.2/isl_ioctl.c	Tue Aug 10 17:21:27 2004
@@ -1946,7 +1946,7 @@ prism54_debug_get_oid(struct net_device 
 		      struct iw_point *data, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
-	struct islpci_mgmtframe *response = NULL;
+	struct islpci_mgmtframe *response;
 	int ret = -EIO;
 
 	printk("%s: get_oid 0x%08X\n", ndev->name, priv->priv_oid);
@@ -1982,7 +1982,7 @@ prism54_debug_set_oid(struct net_device 
 		      struct iw_point *data, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
-	struct islpci_mgmtframe *response = NULL;
+	struct islpci_mgmtframe *response;
 	int ret = 0, response_op = PIMFOR_OP_ERROR;
 
 	printk("%s: set_oid 0x%08X\tlen: %d\n", ndev->name, priv->priv_oid,
diff -urpN prism54-20040810.1/islpci_dev.c prism54-20040810.2/islpci_dev.c
--- prism54-20040810.1/islpci_dev.c	Fri Jul 30 12:18:45 2004
+++ prism54-20040810.2/islpci_dev.c	Tue Aug 10 17:24:32 2004
@@ -462,8 +462,7 @@ islpci_upload_fw(islpci_private *priv)
 		return rc;
 	}
 
-	printk(KERN_DEBUG
-	       "%s: firmware uploaded done, now triggering reset...\n",
+	printk(KERN_DEBUG "%s: islpci_upload_fw: success\n",
 	       priv->ndev->name);
 
 	islpci_set_state(priv, PRV_STATE_POSTBOOT);
@@ -499,16 +498,18 @@ islpci_reset_if(islpci_private *priv)
 		/* If we're here it's because our IRQ hasn't yet gone through. 
 		 * Retry a bit more...
 		 */
-		 printk(KERN_ERR "%s: device soft reset timed out\n",
-		       priv->ndev->name);
-
+		printk(KERN_ERR "%s: reset problem: no 'reset complete' IRQ seen\n",
+			priv->ndev->name);
 	}
 
 	finish_wait(&priv->reset_done, &wait);
 
-	if(result)
+	if (result) {
+		printk(KERN_ERR "%s: islpci_reset_if: failure\n", priv->ndev->name);
 		return result;
+	}
 
+	printk(KERN_DEBUG "%s: got 'reset complete' IRQ\n", priv->ndev->name);
 	islpci_set_state(priv, PRV_STATE_INIT);
 
 	/* Now that the device is 100% up, let's allow
@@ -524,6 +525,7 @@ islpci_reset_if(islpci_private *priv)
 
 	islpci_set_state(priv, PRV_STATE_READY);
 
+	printk(KERN_DEBUG "%s: islpci_reset_if: success\n", priv->ndev->name);
 	return 0;
 }
 
@@ -584,18 +586,21 @@ islpci_reset(islpci_private *priv, int r
 	/* now that the data structures are cleaned up, upload
 	 * firmware and reset interface */
 		rc = islpci_upload_fw(priv);
-		if (rc) 
+		if (rc) {
+			printk(KERN_ERR "%s: islpci_reset: failure\n",
+				priv->ndev->name);
 			return rc;
+		}
 	}
 
 	/* finally reset interface */
 	rc = islpci_reset_if(priv);
-	if (!rc) /* If successful */
-		return rc;
-	
-	printk(KERN_DEBUG  "prism54: Your card/socket may be faulty, or IRQ line too busy :(\n");
+	if (rc)
+		printk(KERN_ERR "prism54: Your card/socket may be faulty, or IRQ line too busy :(\n");
+	else
+		printk(KERN_DEBUG "%s: islpci_reset: success\n",
+			priv->ndev->name);
 	return rc;
-
 }
 
 struct net_device_stats *
@@ -604,7 +609,7 @@ islpci_statistics(struct net_device *nde
 	islpci_private *priv = netdev_priv(ndev);
 
 #if VERBOSE > SHOW_ERROR_MESSAGES
-	DEBUG(SHOW_FUNCTION_CALLS, "islpci_statistics \n");
+	DEBUG(SHOW_FUNCTION_CALLS, "islpci_statistics\n");
 #endif
 
 	return &priv->statistics;
diff -urpN prism54-20040810.1/islpci_eth.c prism54-20040810.2/islpci_eth.c
--- prism54-20040810.1/islpci_eth.c	Thu Jul  1 08:54:35 2004
+++ prism54-20040810.2/islpci_eth.c	Tue Aug 10 17:27:42 2004
@@ -508,11 +508,11 @@ islpci_eth_tx_timeout(struct net_device 
 	/* increment the transmit error counter */
 	statistics->tx_errors++;
 
+	printk(KERN_WARNING "%s: tx_timeout", ndev->name);
 	if (!priv->reset_task_pending) {
-		priv->reset_task_pending = 1;
+		printk(", scheduling a reset");
 		netif_stop_queue(ndev);
 		schedule_work(&priv->reset_task);
 	}
-
-	return;
+	printk("\n");
 }
diff -urpN prism54-20040810.1/oid_mgt.c prism54-20040810.2/oid_mgt.c
--- prism54-20040810.1/oid_mgt.c	Tue Aug 10 17:18:37 2004
+++ prism54-20040810.2/oid_mgt.c	Tue Aug 10 17:29:35 2004
@@ -555,15 +555,18 @@ mgt_commit_list(islpci_private *priv, en
 		u32 oid = t->oid;
 		BUG_ON(data == NULL);
 		while (j <= t->range) {
-			response = NULL;
-			ret |= islpci_mgt_transaction(priv->ndev, PIMFOR_OP_SET,
+			int r = islpci_mgt_transaction(priv->ndev, PIMFOR_OP_SET,
 						      oid, data, t->size,
 						      &response);
 			if (response) {
-				ret |= (response->header->operation ==
-					PIMFOR_OP_ERROR);
+				r |= (response->header->operation == PIMFOR_OP_ERROR);
 				islpci_mgt_release(response);
 			}
+			if (r)
+				printk(KERN_ERR "%s: mgt_commit_list: failure. "
+					"oid=%08x err=%d\n",
+					priv->ndev->name, oid, r);
+			ret |= r;
 			j++;
 			oid++;
 			data += t->size;
@@ -624,7 +627,7 @@ static enum oid_num_t commit_part2[] = {
 static int
 mgt_update_addr(islpci_private *priv)
 {
-	struct islpci_mgmtframe *res = NULL;
+	struct islpci_mgmtframe *res;
 	int ret;
 
 	ret = islpci_mgt_transaction(priv->ndev, PIMFOR_OP_GET,

--Boundary-00=_siOGB9xPqwDdqgJ
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_siOGB9xPqwDdqgJ--
