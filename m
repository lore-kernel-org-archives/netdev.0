From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 1/2] ptp: reduce stack usage when reading external time stamps
Date: Mon, 26 Nov 2012 12:44:34 +0100
Message-ID: <1146e32bcb835ebf394bab91db3161600ab5213a.1353929829.git.richardcochran@gmail.com>
References: <20121102020631.GI16883@yliu-dev.sh.intel.com>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:51179 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279Ab2KZLoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 06:44:46 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so4359895eaa.19
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2012 03:44:45 -0800 (PST)
In-Reply-To: <20121102020631.GI16883@yliu-dev.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the large buffer from the stack of the read file
operation and replaces it with a kmalloced buffer.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/ptp/ptp_chardev.c |   22 +++++++++++++++++-----
 1 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/ptp/ptp_chardev.c b/drivers/ptp/ptp_chardev.c
index 4f8ae80..9d7542e 100644
--- a/drivers/ptp/ptp_chardev.c
+++ b/drivers/ptp/ptp_chardev.c
@@ -21,6 +21,7 @@
 #include <linux/posix-clock.h>
 #include <linux/poll.h>
 #include <linux/sched.h>
+#include <linux/slab.h>
 
 #include "ptp_private.h"
 
@@ -136,20 +137,23 @@ unsigned int ptp_poll(struct posix_clock *pc, struct file *fp, poll_table *wait)
 	return queue_cnt(&ptp->tsevq) ? POLLIN : 0;
 }
 
+#define EXTTS_BUFSIZE (PTP_BUF_TIMESTAMPS * sizeof(struct ptp_extts_event))
+
 ssize_t ptp_read(struct posix_clock *pc,
 		 uint rdflags, char __user *buf, size_t cnt)
 {
 	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
 	struct timestamp_event_queue *queue = &ptp->tsevq;
-	struct ptp_extts_event event[PTP_BUF_TIMESTAMPS];
+	struct ptp_extts_event *event;
 	unsigned long flags;
 	size_t qcnt, i;
+	int result;
 
 	if (cnt % sizeof(struct ptp_extts_event) != 0)
 		return -EINVAL;
 
-	if (cnt > sizeof(event))
-		cnt = sizeof(event);
+	if (cnt > EXTTS_BUFSIZE)
+		cnt = EXTTS_BUFSIZE;
 
 	cnt = cnt / sizeof(struct ptp_extts_event);
 
@@ -167,6 +171,12 @@ ssize_t ptp_read(struct posix_clock *pc,
 		return -ENODEV;
 	}
 
+	event = kmalloc(EXTTS_BUFSIZE, GFP_KERNEL);
+	if (!event) {
+		mutex_unlock(&ptp->tsevq_mux);
+		return -ENOMEM;
+	}
+
 	spin_lock_irqsave(&queue->lock, flags);
 
 	qcnt = queue_cnt(queue);
@@ -185,8 +195,10 @@ ssize_t ptp_read(struct posix_clock *pc,
 
 	mutex_unlock(&ptp->tsevq_mux);
 
+	result = cnt;
 	if (copy_to_user(buf, event, cnt))
-		return -EFAULT;
+		result = -EFAULT;
 
-	return cnt;
+	kfree(event);
+	return result;
 }
-- 
1.7.2.5
