From: frank.blaschka@de.ibm.com
Subject: [patch 05/13] [PATCH] af_iucv: use loadable iucv interface
Date: Mon, 08 Aug 2011 13:33:51 +0200
Message-ID: <20110808113515.814738984@de.ibm.com>
References: <20110808113346.516293249@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:59924 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562Ab1HHLfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 07:35:31 -0400
Content-Disposition: inline; filename=net1117-af_iucv-use-loadable-iucv-interface.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

For future af_iucv extensions the module should be able to run in LPAR
mode too. For this we use the new dynamic loading iucv interface.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 net/iucv/af_iucv.c |  119 ++++++++++++++++++++++++++++++++---------------------
 1 file changed, 74 insertions(+), 45 deletions(-)

--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -42,6 +42,8 @@ static struct proto iucv_proto = {
 	.obj_size	= sizeof(struct iucv_sock),
 };
 
+static struct iucv_interface *pr_iucv;
+
 /* special AF_IUCV IPRM messages */
 static const u8 iprm_shutdown[8] =
 	{0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01};
@@ -165,7 +167,7 @@ static int afiucv_pm_freeze(struct devic
 		case IUCV_CLOSING:
 		case IUCV_CONNECTED:
 			if (iucv->path) {
-				err = iucv_path_sever(iucv->path, NULL);
+				err = pr_iucv->path_sever(iucv->path, NULL);
 				iucv_path_free(iucv->path);
 				iucv->path = NULL;
 			}
@@ -229,7 +231,7 @@ static const struct dev_pm_ops afiucv_pm
 static struct device_driver af_iucv_driver = {
 	.owner = THIS_MODULE,
 	.name = "afiucv",
-	.bus  = &iucv_bus,
+	.bus  = NULL,
 	.pm   = &afiucv_pm_ops,
 };
 
@@ -412,7 +414,7 @@ static void iucv_sock_close(struct sock 
 			low_nmcpy(user_data, iucv->src_name);
 			high_nmcpy(user_data, iucv->dst_name);
 			ASCEBC(user_data, sizeof(user_data));
-			iucv_path_sever(iucv->path, user_data);
+			pr_iucv->path_sever(iucv->path, user_data);
 			iucv_path_free(iucv->path);
 			iucv->path = NULL;
 		}
@@ -704,8 +706,9 @@ static int iucv_sock_connect(struct sock
 		err = -ENOMEM;
 		goto done;
 	}
-	err = iucv_path_connect(iucv->path, &af_iucv_handler,
-				sa->siucv_user_id, NULL, user_data, sk);
+	err = pr_iucv->path_connect(iucv->path, &af_iucv_handler,
+				    sa->siucv_user_id, NULL, user_data,
+				    sk);
 	if (err) {
 		iucv_path_free(iucv->path);
 		iucv->path = NULL;
@@ -738,7 +741,7 @@ static int iucv_sock_connect(struct sock
 	}
 
 	if (err) {
-		iucv_path_sever(iucv->path, NULL);
+		pr_iucv->path_sever(iucv->path, NULL);
 		iucv_path_free(iucv->path);
 		iucv->path = NULL;
 	}
@@ -871,7 +874,7 @@ static int iucv_send_iprm(struct iucv_pa
 
 	memcpy(prmdata, (void *) skb->data, skb->len);
 	prmdata[7] = 0xff - (u8) skb->len;
-	return iucv_message_send(path, msg, IUCV_IPRMDATA, 0,
+	return pr_iucv->message_send(path, msg, IUCV_IPRMDATA, 0,
 				 (void *) prmdata, 8);
 }
 
@@ -999,13 +1002,13 @@ static int iucv_sock_sendmsg(struct kioc
 		/* this error should never happen since the
 		 * IUCV_IPRMDATA path flag is set... sever path */
 		if (err == 0x15) {
-			iucv_path_sever(iucv->path, NULL);
+			pr_iucv->path_sever(iucv->path, NULL);
 			skb_unlink(skb, &iucv->send_skb_q);
 			err = -EPIPE;
 			goto fail;
 		}
 	} else
-		err = iucv_message_send(iucv->path, &txmsg, 0, 0,
+		err = pr_iucv->message_send(iucv->path, &txmsg, 0, 0,
 					(void *) skb->data, skb->len);
 	if (err) {
 		if (err == 3) {
@@ -1095,8 +1098,9 @@ static void iucv_process_message(struct 
 			skb->len = 0;
 		}
 	} else {
-		rc = iucv_message_receive(path, msg, msg->flags & IUCV_IPRMDATA,
-					  skb->data, len, NULL);
+		rc = pr_iucv->message_receive(path, msg,
+					      msg->flags & IUCV_IPRMDATA,
+					      skb->data, len, NULL);
 		if (rc) {
 			kfree_skb(skb);
 			return;
@@ -1110,7 +1114,7 @@ static void iucv_process_message(struct 
 			kfree_skb(skb);
 			skb = NULL;
 			if (rc) {
-				iucv_path_sever(path, NULL);
+				pr_iucv->path_sever(path, NULL);
 				return;
 			}
 			skb = skb_dequeue(&iucv_sk(sk)->backlog_skb_q);
@@ -1327,8 +1331,8 @@ static int iucv_sock_shutdown(struct soc
 	if (how == SEND_SHUTDOWN || how == SHUTDOWN_MASK) {
 		txmsg.class = 0;
 		txmsg.tag = 0;
-		err = iucv_message_send(iucv->path, &txmsg, IUCV_IPRMDATA, 0,
-					(void *) iprm_shutdown, 8);
+		err = pr_iucv->message_send(iucv->path, &txmsg, IUCV_IPRMDATA,
+					0, (void *) iprm_shutdown, 8);
 		if (err) {
 			switch (err) {
 			case 1:
@@ -1345,7 +1349,7 @@ static int iucv_sock_shutdown(struct soc
 	}
 
 	if (how == RCV_SHUTDOWN || how == SHUTDOWN_MASK) {
-		err = iucv_path_quiesce(iucv_sk(sk)->path, NULL);
+		err = pr_iucv->path_quiesce(iucv->path, NULL);
 		if (err)
 			err = -ENOTCONN;
 
@@ -1372,7 +1376,7 @@ static int iucv_sock_release(struct sock
 
 	/* Unregister with IUCV base support */
 	if (iucv_sk(sk)->path) {
-		iucv_path_sever(iucv_sk(sk)->path, NULL);
+		pr_iucv->path_sever(iucv_sk(sk)->path, NULL);
 		iucv_path_free(iucv_sk(sk)->path);
 		iucv_sk(sk)->path = NULL;
 	}
@@ -1514,14 +1518,14 @@ static int iucv_callback_connreq(struct 
 	high_nmcpy(user_data, iucv->dst_name);
 	ASCEBC(user_data, sizeof(user_data));
 	if (sk->sk_state != IUCV_LISTEN) {
-		err = iucv_path_sever(path, user_data);
+		err = pr_iucv->path_sever(path, user_data);
 		iucv_path_free(path);
 		goto fail;
 	}
 
 	/* Check for backlog size */
 	if (sk_acceptq_is_full(sk)) {
-		err = iucv_path_sever(path, user_data);
+		err = pr_iucv->path_sever(path, user_data);
 		iucv_path_free(path);
 		goto fail;
 	}
@@ -1529,7 +1533,7 @@ static int iucv_callback_connreq(struct 
 	/* Create the new socket */
 	nsk = iucv_sock_alloc(NULL, sk->sk_type, GFP_ATOMIC);
 	if (!nsk) {
-		err = iucv_path_sever(path, user_data);
+		err = pr_iucv->path_sever(path, user_data);
 		iucv_path_free(path);
 		goto fail;
 	}
@@ -1553,9 +1557,9 @@ static int iucv_callback_connreq(struct 
 	/* set message limit for path based on msglimit of accepting socket */
 	niucv->msglimit = iucv->msglimit;
 	path->msglim = iucv->msglimit;
-	err = iucv_path_accept(path, &af_iucv_handler, nuser_data, nsk);
+	err = pr_iucv->path_accept(path, &af_iucv_handler, nuser_data, nsk);
 	if (err) {
-		err = iucv_path_sever(path, user_data);
+		err = pr_iucv->path_sever(path, user_data);
 		iucv_path_free(path);
 		iucv_sock_kill(nsk);
 		goto fail;
@@ -1589,7 +1593,7 @@ static void iucv_callback_rx(struct iucv
 	int len;
 
 	if (sk->sk_shutdown & RCV_SHUTDOWN) {
-		iucv_message_reject(path, msg);
+		pr_iucv->message_reject(path, msg);
 		return;
 	}
 
@@ -1718,6 +1722,41 @@ static const struct net_proto_family iuc
 	.create	= iucv_sock_create,
 };
 
+static int __init afiucv_iucv_init(void)
+{
+	int err;
+
+	err = pr_iucv->iucv_register(&af_iucv_handler, 0);
+	if (err)
+		goto out;
+	/* establish dummy device */
+	af_iucv_driver.bus = pr_iucv->bus;
+	err = driver_register(&af_iucv_driver);
+	if (err)
+		goto out_iucv;
+	af_iucv_dev = kzalloc(sizeof(struct device), GFP_KERNEL);
+	if (!af_iucv_dev) {
+		err = -ENOMEM;
+		goto out_driver;
+	}
+	dev_set_name(af_iucv_dev, "af_iucv");
+	af_iucv_dev->bus = pr_iucv->bus;
+	af_iucv_dev->parent = pr_iucv->root;
+	af_iucv_dev->release = (void (*)(struct device *))kfree;
+	af_iucv_dev->driver = &af_iucv_driver;
+	err = device_register(af_iucv_dev);
+	if (err)
+		goto out_driver;
+	return 0;
+
+out_driver:
+	driver_unregister(&af_iucv_driver);
+out_iucv:
+	pr_iucv->iucv_unregister(&af_iucv_handler, 0);
+out:
+	return err;
+}
+
 static int __init afiucv_init(void)
 {
 	int err;
@@ -1735,44 +1774,33 @@ static int __init afiucv_init(void)
 		goto out;
 	}
 
-	err = iucv_register(&af_iucv_handler, 0);
-	if (err)
+	pr_iucv = try_then_request_module(symbol_get(iucv_if), "iucv");
+	if (!pr_iucv) {
+		printk(KERN_WARNING "iucv_if lookup failed\n");
+		err = -EPROTONOSUPPORT;
 		goto out;
+	}
+
 	err = proto_register(&iucv_proto, 0);
 	if (err)
-		goto out_iucv;
+		goto out;
 	err = sock_register(&iucv_sock_family_ops);
 	if (err)
 		goto out_proto;
-	/* establish dummy device */
-	err = driver_register(&af_iucv_driver);
+
+	err = afiucv_iucv_init();
 	if (err)
 		goto out_sock;
-	af_iucv_dev = kzalloc(sizeof(struct device), GFP_KERNEL);
-	if (!af_iucv_dev) {
-		err = -ENOMEM;
-		goto out_driver;
-	}
-	dev_set_name(af_iucv_dev, "af_iucv");
-	af_iucv_dev->bus = &iucv_bus;
-	af_iucv_dev->parent = iucv_root;
-	af_iucv_dev->release = (void (*)(struct device *))kfree;
-	af_iucv_dev->driver = &af_iucv_driver;
-	err = device_register(af_iucv_dev);
-	if (err)
-		goto out_driver;
 
 	return 0;
 
-out_driver:
-	driver_unregister(&af_iucv_driver);
 out_sock:
 	sock_unregister(PF_IUCV);
 out_proto:
 	proto_unregister(&iucv_proto);
-out_iucv:
-	iucv_unregister(&af_iucv_handler, 0);
 out:
+	if (pr_iucv)
+		symbol_put(iucv_if);
 	return err;
 }
 
@@ -1780,9 +1808,10 @@ static void __exit afiucv_exit(void)
 {
 	device_unregister(af_iucv_dev);
 	driver_unregister(&af_iucv_driver);
+	pr_iucv->iucv_unregister(&af_iucv_handler, 0);
+	symbol_put(iucv_if);
 	sock_unregister(PF_IUCV);
 	proto_unregister(&iucv_proto);
-	iucv_unregister(&af_iucv_handler, 0);
 }
 
 module_init(afiucv_init);

