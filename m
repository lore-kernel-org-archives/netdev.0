From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/5] s390/ctcm,netiucv: migrate variables to handle y2038 problem
Date: Fri, 16 Jan 2015 14:05:45 +0100
Message-ID: <1421413549-56937-2-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1421413549-56937-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:53015 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbbAPNGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 08:06:14 -0500
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 16 Jan 2015 13:06:12 -0000
In-Reply-To: <1421413549-56937-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>

This patch is concerned with migrating the time variables for the s390
network drivers. The changes handle the y2038 problem where timespec will
overflow in the year 2038. timespec was replaced by unsigned long and
all time variables get their values from the jiffies global variable.
This was done for the sake of speed and efficiency.

Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/ctcm_fsms.c  | 18 +++++++-----------
 drivers/s390/net/ctcm_main.c  |  4 ++--
 drivers/s390/net/ctcm_main.h  |  2 +-
 drivers/s390/net/ctcm_sysfs.c |  4 ++--
 drivers/s390/net/netiucv.c    |  6 +++---
 5 files changed, 15 insertions(+), 19 deletions(-)

diff --git a/drivers/s390/net/ctcm_fsms.c b/drivers/s390/net/ctcm_fsms.c
index fb92524..fd5944b 100644
--- a/drivers/s390/net/ctcm_fsms.c
+++ b/drivers/s390/net/ctcm_fsms.c
@@ -251,13 +251,11 @@ static void chx_txdone(fsm_instance *fi, int event, void *arg)
 	int first = 1;
 	int i;
 	unsigned long duration;
-	struct timespec done_stamp = current_kernel_time(); /* xtime */
+	unsigned long done_stamp = jiffies;
 
 	CTCM_PR_DEBUG("%s(%s): %s\n", __func__, ch->id, dev->name);
 
-	duration =
-	    (done_stamp.tv_sec - ch->prof.send_stamp.tv_sec) * 1000000 +
-	    (done_stamp.tv_nsec - ch->prof.send_stamp.tv_nsec) / 1000;
+	duration = done_stamp - ch->prof.send_stamp;
 	if (duration > ch->prof.tx_time)
 		ch->prof.tx_time = duration;
 
@@ -307,7 +305,7 @@ static void chx_txdone(fsm_instance *fi, int event, void *arg)
 		spin_unlock(&ch->collect_lock);
 		ch->ccw[1].count = ch->trans_skb->len;
 		fsm_addtimer(&ch->timer, CTCM_TIME_5_SEC, CTC_EVENT_TIMER, ch);
-		ch->prof.send_stamp = current_kernel_time(); /* xtime */
+		ch->prof.send_stamp = jiffies;
 		rc = ccw_device_start(ch->cdev, &ch->ccw[0],
 						(unsigned long)ch, 0xff, 0);
 		ch->prof.doios_multi++;
@@ -1229,14 +1227,12 @@ static void ctcmpc_chx_txdone(fsm_instance *fi, int event, void *arg)
 	int		rc;
 	struct th_header *header;
 	struct pdu	*p_header;
-	struct timespec done_stamp = current_kernel_time(); /* xtime */
+	unsigned long done_stamp = jiffies;
 
 	CTCM_PR_DEBUG("Enter %s: %s cp:%i\n",
 			__func__, dev->name, smp_processor_id());
 
-	duration =
-		(done_stamp.tv_sec - ch->prof.send_stamp.tv_sec) * 1000000 +
-		(done_stamp.tv_nsec - ch->prof.send_stamp.tv_nsec) / 1000;
+	duration = done_stamp - ch->prof.send_stamp;
 	if (duration > ch->prof.tx_time)
 		ch->prof.tx_time = duration;
 
@@ -1361,7 +1357,7 @@ static void ctcmpc_chx_txdone(fsm_instance *fi, int event, void *arg)
 
 	ch->ccw[1].count = ch->trans_skb->len;
 	fsm_addtimer(&ch->timer, CTCM_TIME_5_SEC, CTC_EVENT_TIMER, ch);
-	ch->prof.send_stamp = current_kernel_time(); /* xtime */
+	ch->prof.send_stamp = jiffies;
 	if (do_debug_ccw)
 		ctcmpc_dumpit((char *)&ch->ccw[0], sizeof(struct ccw1) * 3);
 	rc = ccw_device_start(ch->cdev, &ch->ccw[0],
@@ -1827,7 +1823,7 @@ static void ctcmpc_chx_send_sweep(fsm_instance *fsm, int event, void *arg)
 	fsm_newstate(wch->fsm, CTC_STATE_TX);
 
 	spin_lock_irqsave(get_ccwdev_lock(wch->cdev), saveflags);
-	wch->prof.send_stamp = current_kernel_time(); /* xtime */
+	wch->prof.send_stamp = jiffies;
 	rc = ccw_device_start(wch->cdev, &wch->ccw[3],
 					(unsigned long) wch, 0xff, 0);
 	spin_unlock_irqrestore(get_ccwdev_lock(wch->cdev), saveflags);
diff --git a/drivers/s390/net/ctcm_main.c b/drivers/s390/net/ctcm_main.c
index e056dd4..05c37d6 100644
--- a/drivers/s390/net/ctcm_main.c
+++ b/drivers/s390/net/ctcm_main.c
@@ -567,7 +567,7 @@ static int ctcm_transmit_skb(struct channel *ch, struct sk_buff *skb)
 	fsm_newstate(ch->fsm, CTC_STATE_TX);
 	fsm_addtimer(&ch->timer, CTCM_TIME_5_SEC, CTC_EVENT_TIMER, ch);
 	spin_lock_irqsave(get_ccwdev_lock(ch->cdev), saveflags);
-	ch->prof.send_stamp = current_kernel_time(); /* xtime */
+	ch->prof.send_stamp = jiffies;
 	rc = ccw_device_start(ch->cdev, &ch->ccw[ccw_idx],
 					(unsigned long)ch, 0xff, 0);
 	spin_unlock_irqrestore(get_ccwdev_lock(ch->cdev), saveflags);
@@ -831,7 +831,7 @@ static int ctcmpc_transmit_skb(struct channel *ch, struct sk_buff *skb)
 					sizeof(struct ccw1) * 3);
 
 	spin_lock_irqsave(get_ccwdev_lock(ch->cdev), saveflags);
-	ch->prof.send_stamp = current_kernel_time(); /* xtime */
+	ch->prof.send_stamp = jiffies;
 	rc = ccw_device_start(ch->cdev, &ch->ccw[ccw_idx],
 					(unsigned long)ch, 0xff, 0);
 	spin_unlock_irqrestore(get_ccwdev_lock(ch->cdev), saveflags);
diff --git a/drivers/s390/net/ctcm_main.h b/drivers/s390/net/ctcm_main.h
index 477c933..6f4417c 100644
--- a/drivers/s390/net/ctcm_main.h
+++ b/drivers/s390/net/ctcm_main.h
@@ -121,7 +121,7 @@ struct ctcm_profile {
 	unsigned long doios_multi;
 	unsigned long txlen;
 	unsigned long tx_time;
-	struct timespec send_stamp;
+	unsigned long send_stamp;
 };
 
 /*
diff --git a/drivers/s390/net/ctcm_sysfs.c b/drivers/s390/net/ctcm_sysfs.c
index 47773c4..ddb0aa3 100644
--- a/drivers/s390/net/ctcm_sysfs.c
+++ b/drivers/s390/net/ctcm_sysfs.c
@@ -100,8 +100,8 @@ static void ctcm_print_statistics(struct ctcm_priv *priv)
 		     priv->channel[WRITE]->prof.doios_multi);
 	p += sprintf(p, "  Netto bytes written: %ld\n",
 		     priv->channel[WRITE]->prof.txlen);
-	p += sprintf(p, "  Max. TX IO-time: %ld\n",
-		     priv->channel[WRITE]->prof.tx_time);
+	p += sprintf(p, "  Max. TX IO-time: %u\n",
+		     jiffies_to_usecs(priv->channel[WRITE]->prof.tx_time));
 
 	printk(KERN_INFO "Statistics for %s:\n%s",
 				priv->channel[CTCM_WRITE]->netdev->name, sbuf);
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index 0a87809..7e91f54 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -178,7 +178,7 @@ struct connection_profile {
 	unsigned long doios_multi;
 	unsigned long txlen;
 	unsigned long tx_time;
-	struct timespec send_stamp;
+	unsigned long send_stamp;
 	unsigned long tx_pending;
 	unsigned long tx_max_pending;
 };
@@ -786,7 +786,7 @@ static void conn_action_txdone(fsm_instance *fi, int event, void *arg)
 
 	header.next = 0;
 	memcpy(skb_put(conn->tx_buff, NETIUCV_HDRLEN), &header, NETIUCV_HDRLEN);
-	conn->prof.send_stamp = current_kernel_time();
+	conn->prof.send_stamp = jiffies;
 	txmsg.class = 0;
 	txmsg.tag = 0;
 	rc = iucv_message_send(conn->path, &txmsg, 0, 0,
@@ -1220,7 +1220,7 @@ static int netiucv_transmit_skb(struct iucv_connection *conn,
 		memcpy(skb_put(nskb, NETIUCV_HDRLEN), &header,  NETIUCV_HDRLEN);
 
 		fsm_newstate(conn->fsm, CONN_STATE_TX);
-		conn->prof.send_stamp = current_kernel_time();
+		conn->prof.send_stamp = jiffies;
 
 		msg.tag = 1;
 		msg.class = 0;
-- 
2.1.4
