From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH 1/3] tg3: Limit minimum tx queue wakeup threshold
Date: Tue, 19 Aug 2014 11:52:49 -0700
Message-ID: <1408474371-19509-1-git-send-email-bpoirier@suse.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:61011 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbaHSSxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2014 14:53:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tx_pending may be set by the user (via ethtool -G) to a low enough value that
TG3_TX_WAKEUP_THRESH becomes smaller than MAX_SKB_FRAGS + 1. This may cause
the tx queue to be waked when there are in fact not enough descriptors to
handle an skb with max frags. This in turn causes tg3_start_xmit() to return
NETDEV_TX_BUSY and print error messages. Fix the problem by putting a limit to
how low TG3_TX_WAKEUP_THRESH can go.

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
---

I noticed the problem in a 3.0 kernel when setting `ethtool eth0 -G tx 50` and
running a netperf TCP_STREAM test. The console fills up with 
[10597.596155] tg3 0000:06:00.0: eth0: BUG! Tx Ring full when queue awake!
The problem in tg3 remains in current kernels though it does not reproduce as
easily since "5640f76 net: use a per task frag allocator (v3.7-rc1)". I
reproduced on current kernels by using the fail_page_alloc fault injection
mechanism to force the creation of skbs with many order-0 frags. Note that the
following script may also trigger another bug (NETDEV WATCHDOG), which is
fixed in the next patch.

$ cat /tmp/doit.sh
#!/bin/bash

F="/sys/kernel/debug/fail_page_alloc"

echo -1 > "$F/times"
echo 0 > "$F/verbose"
echo 0 > "$F/ignore-gfp-wait"
echo 1 > "$F/task-filter"
echo 100 > "$F/probability"

netperf -H 192.168.9.30 -l100 -t omni -- -d send &

n=$!

sleep 0.3
echo 1 > "/proc/$n/make-it-fail"
sleep 10

kill "$n"

---
 drivers/net/ethernet/broadcom/tg3.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3ac5d23..b11c0fd 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -202,7 +202,8 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 #endif
 
 /* minimum number of free TX descriptors required to wake up TX process */
-#define TG3_TX_WAKEUP_THRESH(tnapi)		((tnapi)->tx_pending / 4)
+#define TG3_TX_WAKEUP_THRESH(tnapi)	max_t(u32, (tnapi)->tx_pending / 4, \
+					      MAX_SKB_FRAGS + 1)
 #define TG3_TX_BD_DMA_MAX_2K		2048
 #define TG3_TX_BD_DMA_MAX_4K		4096
 
-- 
1.8.4.5
