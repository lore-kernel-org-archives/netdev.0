From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] sky2: Fix checksum endianness
Date: Fri, 26 Jun 2009 18:51:59 +0400
Message-ID: <20090626145159.GA2242@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

sky2 driver on PowerPC targets floods kernel log with following errors:

  eth1: hw csum failure.
  Call Trace:
  [ef84b8a0] [c00075e4] show_stack+0x50/0x160 (unreliable)
  [ef84b8d0] [c02fa178] netdev_rx_csum_fault+0x3c/0x5c
  [ef84b8f0] [c02f6920] __skb_checksum_complete_head+0x7c/0x84
  [ef84b900] [c02f693c] __skb_checksum_complete+0x14/0x24
  [ef84b910] [c0337e08] tcp_v4_rcv+0x4c8/0x6f8
  [ef84b940] [c031a9c8] ip_local_deliver+0x98/0x210
  [ef84b960] [c031a788] ip_rcv+0x38c/0x534
  [ef84b990] [c0300338] netif_receive_skb+0x260/0x36c
  [ef84b9c0] [c025de00] sky2_poll+0x5dc/0xcf8
  [ef84ba20] [c02fb7fc] net_rx_action+0xc0/0x144

The NIC is Yukon-2 EC chip revision 1.

Converting checksum field from le16 to CPU byte order fixes the issue.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/sky2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 7681d28..daf961a 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2495,7 +2495,7 @@ static int sky2_status_intr(struct sky2_hw *hw, int to_do, u16 idx)
 			if (likely(status >> 16 == (status & 0xffff))) {
 				skb = sky2->rx_ring[sky2->rx_next].skb;
 				skb->ip_summed = CHECKSUM_COMPLETE;
-				skb->csum = status & 0xffff;
+				skb->csum = le16_to_cpu(status);
 			} else {
 				printk(KERN_NOTICE PFX "%s: hardware receive "
 				       "checksum problem (status = %#x)\n",
-- 
1.6.3.1
