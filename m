From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 5/8] s390: Use ccw_device_get_id() in qeth/claw drivers
Date: Wed, 20 Jun 2007 13:00:20 +0200
Message-ID: <20070620110020.GE9454@de.ibm.com>
References: <20070620104817.GA2627@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:36929 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751755AbXFTK6q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2007 06:58:46 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5KAxrW7023692
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 06:59:53 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5KAwjAX458142
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 06:58:45 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5KAwjPb007520
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 06:58:45 -0400
Content-Disposition: inline
In-Reply-To: <20070620104817.GA2627@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cornelia Huck <cornelia.huck@de.ibm.com>

Use ccw_device_get_id() to get a device number 
instead of parsing the ccw device's bus id.

Signed-off-by: Cornelia Huck <cornelia.huck@de.ibm.com>
Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---
 drivers/s390/net/claw.c      |   13 ++++++++-----
 drivers/s390/net/qeth_main.c |   12 +++---------
 2 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/drivers/s390/net/claw.c b/drivers/s390/net/claw.c
index 6dd64d0..348bb7b 100644
--- a/drivers/s390/net/claw.c
+++ b/drivers/s390/net/claw.c
@@ -3912,6 +3912,7 @@ static int
 add_channel(struct ccw_device *cdev,int i,struct claw_privbk *privptr)
 {
 	struct chbk *p_ch;
+	struct ccw_dev_id dev_id;
 
 #ifdef FUNCTRACE
         printk(KERN_INFO "%s:%s Enter\n",cdev->dev.bus_id,__FUNCTION__);
@@ -3921,7 +3922,8 @@ add_channel(struct ccw_device *cdev,int i,struct claw_privbk *privptr)
 	p_ch = &privptr->channel[i];
 	p_ch->cdev = cdev;
 	snprintf(p_ch->id, CLAW_ID_SIZE, "cl-%s", cdev->dev.bus_id);
-	sscanf(cdev->dev.bus_id+4,"%x",&p_ch->devno);
+	ccw_device_get_id(cdev, &dev_id);
+	p_ch->devno = dev_id.devno;
 	if ((p_ch->irb = kmalloc(sizeof (struct irb),GFP_KERNEL)) == NULL) {
 		printk(KERN_WARNING "%s Out of memory in %s for irb\n",
 			p_ch->id,__FUNCTION__);
@@ -3955,6 +3957,7 @@ claw_new_device(struct ccwgroup_device *cgdev)
 	struct claw_env *p_env;
 	struct net_device *dev;
 	int ret;
+	struct ccw_dev_id dev_id;
 
 	pr_debug("%s() called\n", __FUNCTION__);
 	printk(KERN_INFO "claw: add for %s\n",cgdev->cdev[READ]->dev.bus_id);
@@ -3965,10 +3968,10 @@ claw_new_device(struct ccwgroup_device *cgdev)
 	if (!privptr)
 		return -ENODEV;
 	p_env = privptr->p_env;
-	sscanf(cgdev->cdev[READ]->dev.bus_id+4,"%x",
-		&p_env->devno[READ]);
-        sscanf(cgdev->cdev[WRITE]->dev.bus_id+4,"%x",
-		&p_env->devno[WRITE]);
+	ccw_device_get_id(cgdev->cdev[READ], &dev_id);
+	p_env->devno[READ] = dev_id.devno;
+	ccw_device_get_id(cgdev->cdev[WRITE], &dev_id);
+	p_env->devno[WRITE] = dev_id.devno;
 	ret = add_channel(cgdev->cdev[0],0,privptr);
 	if (ret == 0)
 		ret = add_channel(cgdev->cdev[1],1,privptr);
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index 79b7379..86b0c44 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -2176,13 +2176,6 @@ qeth_ulp_enable(struct qeth_card *card)
 
 }
 
-static inline __u16
-__raw_devno_from_bus_id(char *id)
-{
-	id += (strlen(id) - 4);
-	return (__u16) simple_strtoul(id, &id, 16);
-}
-
 static int
 qeth_ulp_setup_cb(struct qeth_card *card, struct qeth_reply *reply,
 		  unsigned long data)
@@ -2205,6 +2198,7 @@ qeth_ulp_setup(struct qeth_card *card)
 	int rc;
 	__u16 temp;
 	struct qeth_cmd_buffer *iob;
+	struct ccw_dev_id dev_id;
 
 	QETH_DBF_TEXT(setup,2,"ulpsetup");
 
@@ -2218,8 +2212,8 @@ qeth_ulp_setup(struct qeth_card *card)
 	memcpy(QETH_ULP_SETUP_FILTER_TOKEN(iob->data),
 	       &card->token.ulp_filter_r, QETH_MPC_TOKEN_LENGTH);
 
-	temp = __raw_devno_from_bus_id(CARD_DDEV_ID(card));
-	memcpy(QETH_ULP_SETUP_CUA(iob->data), &temp, 2);
+	ccw_device_get_id(CARD_DDEV(card), &dev_id);
+	memcpy(QETH_ULP_SETUP_CUA(iob->data), &dev_id.devno, 2);
 	temp = (card->info.cula << 8) + card->info.unit_addr2;
 	memcpy(QETH_ULP_SETUP_REAL_DEVADDR(iob->data), &temp, 2);
 	rc = qeth_send_control_data(card, ULP_SETUP_SIZE, iob,
-- 
1.5.2.1

