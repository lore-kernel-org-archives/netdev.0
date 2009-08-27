From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 1/5] ucc_geth: Fix NULL pointer dereference in
	uec_get_ethtool_stats()
Date: Thu, 27 Aug 2009 21:35:47 +0400
Message-ID: <20090827173547.GA1580@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Scott Wood <scottwood@freescale.com>, Timur Tabi <timur@freescale.com>
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

In commit 3e73fc9a12679a546284d597c1f19165792d0b83 ("ucc_geth: Fix IO
memory (un)mapping code") I fixed ug_regs IO memory leak by properly
freeing the allocated memory. But ethtool_stats() callback doesn't
check for ug_regs being NULL, and that causes following oops if
'ethtool -S' is executed on a closed eth device:

  Unable to handle kernel paging request for data at address 0x00000180
  Faulting instruction address: 0xc0208228
  Oops: Kernel access of bad area, sig: 11 [#1]
  ...
  NIP [c0208228] uec_get_ethtool_stats+0x38/0x140
  LR [c02559a0] ethtool_get_stats+0xf8/0x23c
  Call Trace:
  [ef87bcd0] [c025597c] ethtool_get_stats+0xd4/0x23c (unreliable)
  [ef87bd00] [c025706c] dev_ethtool+0xfe8/0x11bc
  [ef87be00] [c0252b5c] dev_ioctl+0x454/0x6a8
  ...
  ---[ end trace 77fff1162a9586b0 ]---
  Segmentation fault

This patch fixes the issue.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth_ethtool.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index 61fe80d..304128f 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -319,9 +319,13 @@ static void uec_get_ethtool_stats(struct net_device *netdev,
 	int i, j = 0;
 
 	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_HARDWARE) {
-		base = (u32 __iomem *)&ugeth->ug_regs->tx64;
+		if (ugeth->ug_regs)
+			base = (u32 __iomem *)&ugeth->ug_regs->tx64;
+		else
+			base = NULL;
+
 		for (i = 0; i < UEC_HW_STATS_LEN; i++)
-			data[j++] = in_be32(&base[i]);
+			data[j++] = base ? in_be32(&base[i]) : 0;
 	}
 	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_TX) {
 		base = (u32 __iomem *)ugeth->p_tx_fw_statistics_pram;
-- 
1.6.3.3
