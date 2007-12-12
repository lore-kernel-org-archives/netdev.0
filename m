From: Dor Laor <dor.laor@gmail.com>
Subject: [virtio-net][PATCH] Don't arm tx hrtimer with a constant 500us each
 transmit
Date: Wed, 12 Dec 2007 14:54:00 +0200
Message-ID: <475FD9E8.1060109@qumranet.com>
Reply-To: dor.laor@qumranet.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>,
	kvm-devel <kvm-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org,
	virtualization <virtualization@lists.linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:23938 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbXLLMyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 07:54:10 -0500
Received: by nf-out-0910.google.com with SMTP id g13so197416nfb.21
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 04:54:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 763769621d271d92204ed27552d75448587c1ac0
Author: Dor Laor <dor.laor@qumranet.com>
Date:   Wed Dec 12 14:52:00 2007 +0200

    [virtio-net][PATCH] Don't arm tx hrtimer with a constant 50us each 
transmit
   
    The current start_xmit sets 500us hrtimer to kick the host.
    The problem is that if another xmit happens before the timer was 
fired then
    the first xmit will have to wait additional 500us.
    This patch does not re-arm the timer if there is existing one.
    This will shorten the latency for tx.
   
    Signed-off-by: Dor Laor <dor.laor@qumranet.com>

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 7b051d5..8bb17d1
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -406,10 +405,10 @@ again:
         virtio_debug(vdebug, "%s: before calling kick %d\n", 
__FUNCTION__, __LINE__);
         vi->svq->vq_ops->kick(vi->svq);
         vi->out_num = 0;
-    } else {
-        vi->stats.hrtimer_starts++;
-        hrtimer_start(&vi->tx_timer, ktime_set(0,500000),
-                  HRTIMER_MODE_REL);
+    } else if (!hrtimer_is_queued(&vi->tx_timer)) {
+            vi->stats.hrtimer_starts++;
+            hrtimer_start(&vi->tx_timer, ktime_set(0,500000),
+                      HRTIMER_MODE_REL);
     }
     return 0;
 }

