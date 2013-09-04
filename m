From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH] ethernet/arc/arc_emac: Fix huge delays in large file copies
Date: Wed, 4 Sep 2013 17:17:15 +0530
Message-ID: <1378295235-18928-1-git-send-email-vgupta@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <arc-linux-dev@synopsys.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

copying large files to a NFS mounted host was taking absurdly large
time.

Turns out that TX BD reclaim had a sublte bug.

Loop starts off from @txbd_dirty cursor and stops when it hits a BD
still in use by controller. However when it stops it needs to keep the
cursor at that very BD to resume scanning in next iteration. However it
was erroneously incrementing the cursor, causing the next scan(s) to
fail too, unless the BD chain was completely drained out.

[ARCLinux]$ ls -l -sh /disk/log.txt
 17976 -rw-r--r--    1 root     root       17.5M Sep  /disk/log.txt

========== Before =====================
[ARCLinux]$ time cp /disk/log.txt /mnt/.
real    31m 7.95s
user    0m 0.00s
sys     0m 0.10s

========== After =====================
[ARCLinux]$ time cp /disk/log.txt /mnt/.
real    0m 24.33s
user    0m 0.00s
sys     0m 0.19s

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
Cc: Alexey Brodkin <abrodkin@synopsys.com> (commit_signer:3/4=75%)
Cc: "David S. Miller" <davem@davemloft.net> (commit_signer:3/4=75%)
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: arc-linux-dev@synopsys.com
---
 drivers/net/ethernet/arc/emac_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 55d79cb..9e16014 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -149,8 +149,6 @@ static void arc_emac_tx_clean(struct net_device *ndev)
 		struct sk_buff *skb = tx_buff->skb;
 		unsigned int info = le32_to_cpu(txbd->info);
 
-		*txbd_dirty = (*txbd_dirty + 1) % TX_BD_NUM;
-
 		if ((info & FOR_EMAC) || !txbd->data)
 			break;
 
@@ -180,6 +178,8 @@ static void arc_emac_tx_clean(struct net_device *ndev)
 		txbd->data = 0;
 		txbd->info = 0;
 
+		*txbd_dirty = (*txbd_dirty + 1) % TX_BD_NUM;
+
 		if (netif_queue_stopped(ndev))
 			netif_wake_queue(ndev);
 	}
-- 
1.8.1.2
