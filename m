From: David Daney <ddaney@avtrex.com>
Subject: [PATCH] e100: Add missing dma sync for proper
 operation with non-coherent caches.
Date: Mon, 25 Aug 2008 23:55:12 -0700
Message-ID: <48B3A8D0.2040108@avtrex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips <linux-mips@linux-mips.org>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

I am running the e100 driver on a MIPS 4KEc system (32 bit mips with
non-coherent DMA).  There was a problem where received packets would
get 'stuck' for several seconds at a time and then be released all at
once.

The cause was that if an interrupt were received when no RX packets
were available, the status for the receive buffer would be stuck in
the cache, so when the next interrupt arrived the old status value was
read (indicating no packets available) instead of the new value.

The fix is to call pci_dma_sync_single_for_device on the RX if the
packet is not available to invalidate the cache so that at the next
interrupt valid status is returned.

The driver currently calls pci_dma_sync_single_for_cpu before reading
the status, and this is indeed needed for cases like the R10000 CPU
where the cache can be polluted by speculative execution, but for most
machines it is a nop.

The patch was tested on 2.6.17-rc4 on a MIPS 4KEc.

Signed-off-by: David Daney <ddaney@avtrex.com>
---
 drivers/net/e100.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 19d32a2..fb8d551 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1840,6 +1840,11 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 
 			if (readb(&nic->csr->scb.status) & rus_no_res)
 				nic->ru_running = RU_SUSPENDED;
+		/* We are done looking at the buffer.  Prepare it for
+		 * more DMA.  */
+		pci_dma_sync_single_for_device(nic->pdev, rx->dma_addr,
+					       sizeof(struct rfd),
+					       PCI_DMA_FROMDEVICE);
 		return -ENODATA;
 	}
 
-- 
1.5.5.1


-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
