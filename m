From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 2/4] [PATCH] ctcm: suspend has to wait for outstanding I/O
Date: Fri, 13 Nov 2009 08:46:28 +0100
Message-ID: <20091113075050.593503000@linux.vnet.ibm.com>
References: <20091113074626.078348000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Frank Blaschka <frank.blaschka@de.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.17.167]:52546 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506AbZKMHuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 02:50:46 -0500
Content-Disposition: inline; filename=614-ctcm-suspend-wait.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

State transition to DEV_STATE_STOPPED indicates all outstanding I/O has
finished. Add wait queue to wait for this state.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/ctcm_main.c |    5 +++++
 drivers/s390/net/fsm.c       |    1 +
 drivers/s390/net/fsm.h       |    2 ++
 3 files changed, 8 insertions(+)

diff -urpN linux-2.6/drivers/s390/net/ctcm_main.c linux-2.6-patched/drivers/s390/net/ctcm_main.c
--- linux-2.6/drivers/s390/net/ctcm_main.c	2009-11-12 14:59:32.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/ctcm_main.c	2009-11-12 14:59:32.000000000 +0100
@@ -1720,6 +1720,11 @@ static int ctcm_pm_suspend(struct ccwgro
 		return 0;
 	netif_device_detach(priv->channel[READ]->netdev);
 	ctcm_close(priv->channel[READ]->netdev);
+	if (!wait_event_timeout(priv->fsm->wait_q,
+	    fsm_getstate(priv->fsm) == DEV_STATE_STOPPED, CTCM_TIME_5_SEC)) {
+		netif_device_attach(priv->channel[READ]->netdev);
+		return -EBUSY;
+	}
 	ccw_device_set_offline(gdev->cdev[1]);
 	ccw_device_set_offline(gdev->cdev[0]);
 	return 0;
diff -urpN linux-2.6/drivers/s390/net/fsm.c linux-2.6-patched/drivers/s390/net/fsm.c
--- linux-2.6/drivers/s390/net/fsm.c	2009-09-10 00:13:59.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/fsm.c	2009-11-12 14:59:32.000000000 +0100
@@ -27,6 +27,7 @@ init_fsm(char *name, const char **state_
 		return NULL;
 	}
 	strlcpy(this->name, name, sizeof(this->name));
+	init_waitqueue_head(&this->wait_q);
 
 	f = kzalloc(sizeof(fsm), order);
 	if (f == NULL) {
diff -urpN linux-2.6/drivers/s390/net/fsm.h linux-2.6-patched/drivers/s390/net/fsm.h
--- linux-2.6/drivers/s390/net/fsm.h	2009-09-10 00:13:59.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/fsm.h	2009-11-12 14:59:32.000000000 +0100
@@ -66,6 +66,7 @@ typedef struct fsm_instance_t {
 	char name[16];
 	void *userdata;
 	int userint;
+	wait_queue_head_t wait_q;
 #if FSM_DEBUG_HISTORY
 	int         history_index;
 	int         history_size;
@@ -197,6 +198,7 @@ fsm_newstate(fsm_instance *fi, int newst
 	printk(KERN_DEBUG "fsm(%s): New state %s\n", fi->name,
 		fi->f->state_names[newstate]);
 #endif
+	wake_up(&fi->wait_q);
 }
 
 /**

