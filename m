From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 3/5] s390: qeth driver fixes
Date: Mon, 8 Jan 2007 17:30:11 +0100
Message-ID: <20070108163011.GC21639@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:46298 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161318AbXAHQbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jan 2007 11:31:24 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l08GUJPi017036
	for <netdev@vger.kernel.org>; Mon, 8 Jan 2007 11:30:19 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l08GVOat551576
	for <netdev@vger.kernel.org>; Mon, 8 Jan 2007 09:31:24 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l08GVNV4010979
	for <netdev@vger.kernel.org>; Mon, 8 Jan 2007 09:31:23 -0700
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 3/5] s390: qeth driver fixes

From: Frank Blaschka <Frank.Blaschka@de.ibm.com>
    - qeth device functions were not callable
      in atomic context due to usage of wait_event_xxx operations in qeth.
      "schedule while atomic" message appeared and kernel dumped when
      removing slave from bond device.

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---
 drivers/s390/net/qeth.h      |    2 -
 drivers/s390/net/qeth_main.c |  125 ++++++++++--------------------------------
 2 files changed, 30 insertions(+), 97 deletions(-)

diff --git a/drivers/s390/net/qeth.h b/drivers/s390/net/qeth.h
index 53c358c..e95c281 100644
--- a/drivers/s390/net/qeth.h
+++ b/drivers/s390/net/qeth.h
@@ -710,7 +710,7 @@ struct qeth_reply {
 	int (*callback)(struct qeth_card *,struct qeth_reply *,unsigned long);
  	u32 seqno;
 	unsigned long offset;
-	int received;
+	atomic_t received;
 	int rc;
 	void *param;
 	struct qeth_card *card;
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index 337304d..19ec4c8 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -471,7 +471,7 @@ qeth_irq(struct ccw_device *cdev, unsign
 	    channel->state == CH_STATE_UP)
 		qeth_issue_next_read(card);
 
-	tasklet_schedule(&channel->irq_tasklet);
+	qeth_irq_tasklet((unsigned long)channel);
 	return;
 out:
 	wake_up(&card->wait_q);
@@ -951,40 +951,6 @@ qeth_do_run_thread(struct qeth_card *car
 }
 
 static int
-qeth_register_ip_addresses(void *ptr)
-{
-	struct qeth_card *card;
-
-	card = (struct qeth_card *) ptr;
-	daemonize("qeth_reg_ip");
-	QETH_DBF_TEXT(trace,4,"regipth1");
-	if (!qeth_do_run_thread(card, QETH_SET_IP_THREAD))
-		return 0;
-	QETH_DBF_TEXT(trace,4,"regipth2");
-	qeth_set_ip_addr_list(card);
-	qeth_clear_thread_running_bit(card, QETH_SET_IP_THREAD);
-	return 0;
-}
-
-/*
- * Drive the SET_PROMISC_MODE thread
- */
-static int
-qeth_set_promisc_mode(void *ptr)
-{
-	struct qeth_card *card = (struct qeth_card *) ptr;
-
-	daemonize("qeth_setprm");
-	QETH_DBF_TEXT(trace,4,"setprm1");
-	if (!qeth_do_run_thread(card, QETH_SET_PROMISC_MODE_THREAD))
-		return 0;
-	QETH_DBF_TEXT(trace,4,"setprm2");
-	qeth_setadp_promisc_mode(card);
-	qeth_clear_thread_running_bit(card, QETH_SET_PROMISC_MODE_THREAD);
-	return 0;
-}
-
-static int
 qeth_recover(void *ptr)
 {
 	struct qeth_card *card;
@@ -1047,11 +1013,6 @@ qeth_start_kernel_thread(struct work_str
 	if (card->read.state != CH_STATE_UP &&
 	    card->write.state != CH_STATE_UP)
 		return;
-
-	if (qeth_do_start_thread(card, QETH_SET_IP_THREAD))
-		kernel_thread(qeth_register_ip_addresses, (void *)card,SIGCHLD);
-	if (qeth_do_start_thread(card, QETH_SET_PROMISC_MODE_THREAD))
-		kernel_thread(qeth_set_promisc_mode, (void *)card, SIGCHLD);
 	if (qeth_do_start_thread(card, QETH_RECOVER_THREAD))
 		kernel_thread(qeth_recover, (void *) card, SIGCHLD);
 }
@@ -1613,8 +1574,6 @@ qeth_issue_next_read(struct qeth_card *c
 		return -ENOMEM;
 	}
 	qeth_setup_ccw(&card->read, iob->data, QETH_BUFSIZE);
-	wait_event(card->wait_q,
-		   atomic_cmpxchg(&card->read.irq_pending, 0, 1) == 0);
 	QETH_DBF_TEXT(trace, 6, "noirqpnd");
 	rc = ccw_device_start(card->read.ccwdev, &card->read.ccw,
 			      (addr_t) iob, 0, 0);
@@ -1635,6 +1594,7 @@ qeth_alloc_reply(struct qeth_card *card)
 	reply = kzalloc(sizeof(struct qeth_reply), GFP_ATOMIC);
 	if (reply){
 		atomic_set(&reply->refcnt, 1);
+		atomic_set(&reply->received, 0);
 		reply->card = card;
 	};
 	return reply;
@@ -1655,31 +1615,6 @@ qeth_put_reply(struct qeth_reply *reply)
 		kfree(reply);
 }
 
-static void
-qeth_cmd_timeout(unsigned long data)
-{
-	struct qeth_reply *reply, *list_reply, *r;
-	unsigned long flags;
-
-	reply = (struct qeth_reply *) data;
-	spin_lock_irqsave(&reply->card->lock, flags);
-	list_for_each_entry_safe(list_reply, r,
-				 &reply->card->cmd_waiter_list, list) {
-		if (reply == list_reply){
-			qeth_get_reply(reply);
-			list_del_init(&reply->list);
-			spin_unlock_irqrestore(&reply->card->lock, flags);
-			reply->rc = -ETIME;
-			reply->received = 1;
-			wake_up(&reply->wait_q);
-			qeth_put_reply(reply);
-			return;
-		}
-	}
-	spin_unlock_irqrestore(&reply->card->lock, flags);
-}
-
-
 static struct qeth_ipa_cmd *
 qeth_check_ipa_data(struct qeth_card *card, struct qeth_cmd_buffer *iob)
 {
@@ -1745,7 +1680,7 @@ qeth_clear_ipacmd_list(struct qeth_card 
 	list_for_each_entry_safe(reply, r, &card->cmd_waiter_list, list) {
 		qeth_get_reply(reply);
 		reply->rc = -EIO;
-		reply->received = 1;
+		atomic_inc(&reply->received);
 		list_del_init(&reply->list);
 		wake_up(&reply->wait_q);
 		qeth_put_reply(reply);
@@ -1814,7 +1749,7 @@ qeth_send_control_data_cb(struct qeth_ch
 					      &card->cmd_waiter_list);
 				spin_unlock_irqrestore(&card->lock, flags);
 			} else {
-				reply->received = 1;
+				atomic_inc(&reply->received);
 				wake_up(&reply->wait_q);
 			}
 			qeth_put_reply(reply);
@@ -1858,7 +1793,7 @@ qeth_send_control_data(struct qeth_card 
 	int rc;
 	unsigned long flags;
 	struct qeth_reply *reply = NULL;
-	struct timer_list timer;
+	unsigned long timeout;
 
 	QETH_DBF_TEXT(trace, 2, "sendctl");
 
@@ -1873,21 +1808,20 @@ qeth_send_control_data(struct qeth_card 
 		reply->seqno = QETH_IDX_COMMAND_SEQNO;
 	else
 		reply->seqno = card->seqno.ipa++;
-	init_timer(&timer);
-	timer.function = qeth_cmd_timeout;
-	timer.data = (unsigned long) reply;
 	init_waitqueue_head(&reply->wait_q);
 	spin_lock_irqsave(&card->lock, flags);
 	list_add_tail(&reply->list, &card->cmd_waiter_list);
 	spin_unlock_irqrestore(&card->lock, flags);
 	QETH_DBF_HEX(control, 2, iob->data, QETH_DBF_CONTROL_LEN);
-	wait_event(card->wait_q,
-		   atomic_cmpxchg(&card->write.irq_pending, 0, 1) == 0);
+
+	while (atomic_cmpxchg(&card->write.irq_pending, 0, 1)) ;
 	qeth_prepare_control_data(card, len, iob);
+
 	if (IS_IPA(iob->data))
-		timer.expires = jiffies + QETH_IPA_TIMEOUT;
+		timeout = jiffies + QETH_IPA_TIMEOUT;
 	else
-		timer.expires = jiffies + QETH_TIMEOUT;
+		timeout = jiffies + QETH_TIMEOUT;
+
 	QETH_DBF_TEXT(trace, 6, "noirqpnd");
 	spin_lock_irqsave(get_ccwdev_lock(card->write.ccwdev), flags);
 	rc = ccw_device_start(card->write.ccwdev, &card->write.ccw,
@@ -1906,9 +1840,16 @@ qeth_send_control_data(struct qeth_card 
 		wake_up(&card->wait_q);
 		return rc;
 	}
-	add_timer(&timer);
-	wait_event(reply->wait_q, reply->received);
-	del_timer_sync(&timer);
+	while (!atomic_read(&reply->received)) {
+		if (time_after(jiffies, timeout)) {
+			spin_lock_irqsave(&reply->card->lock, flags);
+			list_del_init(&reply->list);
+			spin_unlock_irqrestore(&reply->card->lock, flags);
+			reply->rc = -ETIME;
+			atomic_inc(&reply->received);
+			wake_up(&reply->wait_q);
+		}
+	};
 	rc = reply->rc;
 	qeth_put_reply(reply);
 	return rc;
@@ -5538,12 +5479,10 @@ #ifdef CONFIG_QETH_IPV6
 	qeth_add_multicast_ipv6(card);
 #endif
 out:
- 	if (qeth_set_thread_start_bit(card, QETH_SET_IP_THREAD) == 0)
-		schedule_work(&card->kernel_thread_starter);
+	qeth_set_ip_addr_list(card);
 	if (!qeth_adp_supported(card, IPA_SETADP_SET_PROMISC_MODE))
 		return;
-	if (qeth_set_thread_start_bit(card, QETH_SET_PROMISC_MODE_THREAD)==0)
-		schedule_work(&card->kernel_thread_starter);
+	qeth_setadp_promisc_mode(card);
 }
 
 static int
@@ -8268,8 +8207,7 @@ #endif
 	}
 	if (!qeth_add_ip(card, ipaddr))
 		kfree(ipaddr);
- 	if (qeth_set_thread_start_bit(card, QETH_SET_IP_THREAD) == 0)
-		schedule_work(&card->kernel_thread_starter);
+	qeth_set_ip_addr_list(card);
 	return rc;
 }
 
@@ -8297,8 +8235,7 @@ #endif
 		return;
 	if (!qeth_delete_ip(card, ipaddr))
 		kfree(ipaddr);
- 	if (qeth_set_thread_start_bit(card, QETH_SET_IP_THREAD) == 0)
-		schedule_work(&card->kernel_thread_starter);
+	qeth_set_ip_addr_list(card);
 }
 
 /*
@@ -8341,8 +8278,7 @@ #endif
 	}
 	if (!qeth_add_ip(card, ipaddr))
 		kfree(ipaddr);
- 	if (qeth_set_thread_start_bit(card, QETH_SET_IP_THREAD) == 0)
-		schedule_work(&card->kernel_thread_starter);
+	qeth_set_ip_addr_list(card);
 	return 0;
 }
 
@@ -8370,8 +8306,7 @@ #endif
 		return;
 	if (!qeth_delete_ip(card, ipaddr))
 		kfree(ipaddr);
- 	if (qeth_set_thread_start_bit(card, QETH_SET_IP_THREAD) == 0)
-		schedule_work(&card->kernel_thread_starter);
+	qeth_set_ip_addr_list(card);
 }
 
 /**
@@ -8413,8 +8348,7 @@ qeth_ip_event(struct notifier_block *thi
 	default:
 		break;
 	}
- 	if (qeth_set_thread_start_bit(card, QETH_SET_IP_THREAD) == 0)
-		schedule_work(&card->kernel_thread_starter);
+	qeth_set_ip_addr_list(card);
 out:
 	return NOTIFY_DONE;
 }
@@ -8466,8 +8400,7 @@ qeth_ip6_event(struct notifier_block *th
 	default:
 		break;
 	}
- 	if (qeth_set_thread_start_bit(card, QETH_SET_IP_THREAD) == 0)
-		schedule_work(&card->kernel_thread_starter);
+	qeth_set_ip_addr_list(card);
 out:
 	return NOTIFY_DONE;
 }
-- 
1.4.2.3

