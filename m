From: Cong Wang <amwang@redhat.com>
Subject: [Patch net] pktgen: correctly handle failures when adding a device
Date: Mon, 28 Jan 2013 15:14:08 +0800
Message-ID: <1359357248-14863-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54189 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751751Ab3A1HOQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 02:14:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

The return value of pktgen_add_device() is not checked, so
even if we fail to add some device, for example, non-exist one,
we still see "OK:...". This patch fixes it.

After this patch, I got:

	# echo "add_device non-exist" > /proc/net/pktgen/kpktgend_0
	-bash: echo: write error: No such device
	# cat /proc/net/pktgen/kpktgend_0
	Running: 
	Stopped: 
	Result: ERROR: can not add device non-exist
	# echo "add_device eth0" > /proc/net/pktgen/kpktgend_0
	# cat /proc/net/pktgen/kpktgend_0
	Running: 
	Stopped: eth0 
	Result: OK: add_device=eth0

(Candidate for -stable)

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index b29dacf..e6e1cbe 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1781,10 +1781,13 @@ static ssize_t pktgen_thread_write(struct file *file,
 			return -EFAULT;
 		i += len;
 		mutex_lock(&pktgen_thread_lock);
-		pktgen_add_device(t, f);
+		ret = pktgen_add_device(t, f);
 		mutex_unlock(&pktgen_thread_lock);
-		ret = count;
-		sprintf(pg_result, "OK: add_device=%s", f);
+		if (!ret) {
+			ret = count;
+			sprintf(pg_result, "OK: add_device=%s", f);
+		} else
+			sprintf(pg_result, "ERROR: can not add device %s", f);
 		goto out;
 	}
 
