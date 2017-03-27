From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH v2] net: moxa: fix TX overrun memory leak
Date: Mon, 27 Mar 2017 14:31:19 +0200
Message-ID: <1490617879-14014-1-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

moxart_mac_start_xmit() doesn't care where tx_tail is, tx_head can
catch and pass tx_tail, which is bad because moxart_tx_finished()
isn't guaranteed to catch up on freeing resources from tx_tail.

Add a check in moxart_mac_start_xmit() stopping the queue at
the end of the circular buffer. Wake it on completion.

Addresses https://bugzilla.kernel.org/show_bug.cgi?id=99451

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    ChangeLog v1->v2:
    - stop queue instead of dropping frames
    
    The following trick was used to trigger the leak.
    
    On the host (where this driver runs):
    1. iptables-restore /etc/iptables.conf && echo 1 > /proc/sys/net/ipv4/ip_forward && ifconfig eth0:0 192.168.5.1
    2. cat /dev/zero | nc -l -p 3334
    
    On a client configured with 192.168.5.1 as a gateway:
    1. nc -v 192.168.5.1 3334 > /dev/null &
    repeat the following multiple times, interrup after a few seconds with CTRL+C:
    2. wget http://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-8.7.1-amd64-netinst.iso
    
    Result (especially note columns <active_objs> and <num_objs> of kmalloc-192 and kmalloc-2048):
    
    date && ifconfig && echo 1 > /proc/sys/vm/drop_caches && cat /proc/slabinfo
    Fri Mar 24 16:22:54 CET 2017
    ..
              RX bytes:57737 (56.3 KiB)  TX bytes:6638 (6.4 KiB)
    ..
     # name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> ..
    ..
    kmalloc-8192           8      8   8192    4    8 : tunables    0    0    0 : slabdata      2      2      0
    kmalloc-4096          13     16   4096    8    8 : tunables    0    0    0 : slabdata      2      2      0
    kmalloc-2048          40     40   2048    8    4 : tunables    0    0    0 : slabdata      5      5      0
    kmalloc-1024          94     96   1024    8    2 : tunables    0    0    0 : slabdata     12     12      0
    kmalloc-512          179    184    512    8    1 : tunables    0    0    0 : slabdata     23     23      0
    kmalloc-256           76     80    256   16    1 : tunables    0    0    0 : slabdata      5      5      0
    kmalloc-192          126    126    192   21    1 : tunables    0    0    0 : slabdata      6      6      0
    kmalloc-128          340    416    128   32    1 : tunables    0    0    0 : slabdata     13     13      0
    kmalloc-96          8353   8358     96   42    1 : tunables    0    0    0 : slabdata    199    199      0
    kmalloc-64           313    320     64   64    1 : tunables    0    0    0 : slabdata      5      5      0
    kmalloc-32          1460   1536     32  128    1 : tunables    0    0    0 : slabdata     12     12      0
    
    date && ifconfig && echo 1 > /proc/sys/vm/drop_caches && cat /proc/slabinfo
    Fri Mar 24 16:26:36 CET 2017
    ..
              RX bytes:70381213 (67.1 MiB)  TX bytes:86208719 (82.2 MiB)
    ..
     # name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> ..
    ..
    kmalloc-8192           8      8   8192    4    8 : tunables    0    0    0 : slabdata      2      2      0
    kmalloc-4096          13     16   4096    8    8 : tunables    0    0    0 : slabdata      2      2      0
    kmalloc-2048        2159   2194   2048    8    4 : tunables    0    0    0 : slabdata    275    275      0
    kmalloc-1024         100    104   1024    8    2 : tunables    0    0    0 : slabdata     13     13      0
    kmalloc-512          182    184    512    8    1 : tunables    0    0    0 : slabdata     23     23      0
    kmalloc-256           76     80    256   16    1 : tunables    0    0    0 : slabdata      5      5      0
    kmalloc-192         2638   2667    192   21    1 : tunables    0    0    0 : slabdata    127    127      0
    kmalloc-128          344    416    128   32    1 : tunables    0    0    0 : slabdata     13     13      0
    kmalloc-96          8353   8358     96   42    1 : tunables    0    0    0 : slabdata    199    199      0
    kmalloc-64           313    320     64   64    1 : tunables    0    0    0 : slabdata      5      5      0
    kmalloc-32          1625   1664     32  128    1 : tunables    0    0    0 : slabdata     13     13      0
    
    Applies to next-20170310

 drivers/net/ethernet/moxa/moxart_ether.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 06c9f41..fa571d5 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -25,6 +25,7 @@
 #include <linux/of_irq.h>
 #include <linux/crc32.h>
 #include <linux/crc32c.h>
+#include <linux/circ_buf.h>
 
 #include "moxart_ether.h"
 
@@ -297,6 +298,7 @@ static void moxart_tx_finished(struct net_device *ndev)
 		tx_tail = TX_NEXT(tx_tail);
 	}
 	priv->tx_tail = tx_tail;
+	netif_wake_queue(ndev);
 }
 
 static irqreturn_t moxart_mac_interrupt(int irq, void *dev_id)
@@ -324,13 +326,19 @@ static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
 	void *desc;
 	unsigned int len;
-	unsigned int tx_head = priv->tx_head;
+	unsigned int tx_head, tx_tail;
 	u32 txdes1;
 	int ret = NETDEV_TX_BUSY;
 
+	spin_lock_irq(&priv->txlock);
+
+	tx_head = priv->tx_head;
+	tx_tail = priv->tx_tail;
 	desc = priv->tx_desc_base + (TX_REG_DESC_SIZE * tx_head);
 
-	spin_lock_irq(&priv->txlock);
+	if (CIRC_SPACE(tx_head, tx_tail, TX_DESC_NUM) == 1)
+		netif_stop_queue(ndev);
+
 	if (moxart_desc_read(desc + TX_REG_OFFSET_DESC0) & TX_DESC0_DMA_OWN) {
 		net_dbg_ratelimited("no TX space for packet\n");
 		priv->stats.tx_dropped++;
-- 
1.8.2.1
