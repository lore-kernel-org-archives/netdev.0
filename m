From: fpavlic@de.ibm.com
Subject: [PATCH 1/9] s390: minor s390 network driver fixes
Date: Wed, 6 Sep 2006 17:05:09 +0200
Message-ID: <200609061705.09801.fpavlic@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev Mailinglist <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:38785 "EHLO
	mtagate1.de.ibm.com") by vger.kernel.org with ESMTP
	id S1751280AbWIFPEN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 11:04:13 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.7/8.13.7) with ESMTP id k86F4CBg174544
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 15:04:12 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k86F8b2n2367724
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 17:08:37 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k86F4BWn023627
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 17:04:12 +0200
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
following 9 patches are all s390 network device drivers related .

Frank

[PATCH 1/9] s390: minor s390 network driver fixes

From: Frank Pavlic <fpavlic@de.ibm.com>
 - iucv driver:
          use do { } while (0) constructs 
   instead of empty defines to avoid compile bugs.
        - ctc driver:
          missing lock initialization added
        - lcs driver:
          BUG_ON usage was removed accidently 
   with the last lcs patch.
          Put them back in place.
   
Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 drivers/s390/net/ctcmain.c |    3 +++
 drivers/s390/net/iucv.c    |    4 ++--
 drivers/s390/net/lcs.c     |   13 +++++--------
 3 files changed, 10 insertions(+), 10 deletions(-)

d7012f9f15697e7dc7901108401bd8bcea1bd97d
diff --git a/drivers/s390/net/ctcmain.c b/drivers/s390/net/ctcmain.c
index 8a4b581..3257c22 100644
--- a/drivers/s390/net/ctcmain.c
+++ b/drivers/s390/net/ctcmain.c
@@ -1714,6 +1714,9 @@ add_channel(struct ccw_device *cdev, enu
   kfree(ch);
   return 0;
  }
+
+ spin_lock_init(&ch->collect_lock);
+
  fsm_settimer(ch->fsm, &ch->timer);
  skb_queue_head_init(&ch->io_queue);
  skb_queue_head_init(&ch->collect_queue);
diff --git a/drivers/s390/net/iucv.c b/drivers/s390/net/iucv.c
index 0e863df..821dde8 100644
--- a/drivers/s390/net/iucv.c
+++ b/drivers/s390/net/iucv.c
@@ -335,8 +335,8 @@ do { \
 
 #else
 
-#define iucv_debug(lvl, fmt, args...)
-#define iucv_dumpit(title, buf, len)
+#define iucv_debug(lvl, fmt, args...) do { } while (0)
+#define iucv_dumpit(title, buf, len) do { } while (0)
 
 #endif
 
diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index 2eded55..16ac68c 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -670,9 +670,8 @@ lcs_ready_buffer(struct lcs_channel *cha
  int index, rc;
 
  LCS_DBF_TEXT(5, trace, "rdybuff");
- if (buffer->state != BUF_STATE_LOCKED &&
-     buffer->state != BUF_STATE_PROCESSED)
-  BUG();
+ BUG_ON(buffer->state != BUF_STATE_LOCKED &&
+        buffer->state != BUF_STATE_PROCESSED);
  spin_lock_irqsave(get_ccwdev_lock(channel->ccwdev), flags);
  buffer->state = BUF_STATE_READY;
  index = buffer - channel->iob;
@@ -696,8 +695,7 @@ __lcs_processed_buffer(struct lcs_channe
  int index, prev, next;
 
  LCS_DBF_TEXT(5, trace, "prcsbuff");
- if (buffer->state != BUF_STATE_READY)
-  BUG();
+ BUG_ON(buffer->state != BUF_STATE_READY);
  buffer->state = BUF_STATE_PROCESSED;
  index = buffer - channel->iob;
  prev = (index - 1) & (LCS_NUM_BUFFS - 1);
@@ -729,9 +727,8 @@ lcs_release_buffer(struct lcs_channel *c
  unsigned long flags;
 
  LCS_DBF_TEXT(5, trace, "relbuff");
- if (buffer->state != BUF_STATE_LOCKED &&
-     buffer->state != BUF_STATE_PROCESSED)
-  BUG();
+ BUG_ON(buffer->state != BUF_STATE_LOCKED &&
+        buffer->state != BUF_STATE_PROCESSED);
  spin_lock_irqsave(get_ccwdev_lock(channel->ccwdev), flags);
  buffer->state = BUF_STATE_EMPTY;
  spin_unlock_irqrestore(get_ccwdev_lock(channel->ccwdev), flags);
-- 
1.2.4

