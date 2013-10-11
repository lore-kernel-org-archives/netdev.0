From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [ 028/135] ethernet/arc/arc_emac: Fix huge delays in large file copies
Date: Fri, 11 Oct 2013 12:38:29 -0700
Message-ID: <20131011193948.290109551@linuxfoundation.org>
References: <20131011193945.181603934@linuxfoundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	stable@vger.kernel.org, Vineet Gupta <vgupta@synopsys.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Brodkin <abrodkin@synopsys.com>, netdev@vger.kernel.org,
	arc-linux-dev@synopsys.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131011193945.181603934@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3.11-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Vineet Gupta <Vineet.Gupta1@synopsys.com>

[ Upstream commit 27082ee1b92f4d41e78b85fe40f6ab39673fba00 ]

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
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/net/ethernet/arc/emac_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -149,8 +149,6 @@ static void arc_emac_tx_clean(struct net
 		struct sk_buff *skb = tx_buff->skb;
 		unsigned int info = le32_to_cpu(txbd->info);
 
-		*txbd_dirty = (*txbd_dirty + 1) % TX_BD_NUM;
-
 		if ((info & FOR_EMAC) || !txbd->data)
 			break;
 
@@ -180,6 +178,8 @@ static void arc_emac_tx_clean(struct net
 		txbd->data = 0;
 		txbd->info = 0;
 
+		*txbd_dirty = (*txbd_dirty + 1) % TX_BD_NUM;
+
 		if (netif_queue_stopped(ndev))
 			netif_wake_queue(ndev);
 	}
