From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v3] sh_eth: fix kernel oops in skb_put()
Date: Fri, 04 Dec 2015 01:45:40 +0300
Message-ID: <1498048.4g9dLWgJuk@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org, yashi@atmark-techno.com
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In a low memory situation the following kernel oops occurs:

Unable to handle kernel NULL pointer dereference at virtual address 00000050
pgd = 8490c000
[00000050] *pgd=4651e831, *pte=00000000, *ppte=00000000
Internal error: Oops: 17 [#1] PREEMPT ARM
Modules linked in:
CPU: 0    Not tainted  (3.4-at16 #9)
PC is at skb_put+0x10/0x98
LR is at sh_eth_poll+0x2c8/0xa10
pc : [<8035f780>]    lr : [<8028bf50>]    psr: 60000113
sp : 84eb1a90  ip : 84eb1ac8  fp : 84eb1ac4
r10: 0000003f  r9 : 000005ea  r8 : 00000000
r7 : 00000000  r6 : 940453b0  r5 : 00030000  r4 : 9381b180
r3 : 00000000  r2 : 00000000  r1 : 000005ea  r0 : 00000000
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 10c53c7d  Table: 4248c059  DAC: 00000015
Process klogd (pid: 2046, stack limit = 0x84eb02e8)
[...]

This is  because netdev_alloc_skb() fails and 'mdp->rx_skbuff[entry]' is left
NULL but sh_eth_rx() later  uses it without checking.  Add such check...

Reported-by: Yasushi SHOJI <yashi@atmark-techno.com>
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against Dave Miller's 'net.git' repo.

Changes in version 3:
- refreshed the patch;
- reformatted the changelog;
- removed [RFT] from the subject.

Changes in version 2:
- moved reading 'mdp->rx_skbuff[entry]' earlier to avoid *goto*.

drivers/net/ethernet/renesas/sh_eth.c |    4 ++--
 drivers/net/ethernet/renesas/sh_eth.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -1462,6 +1462,7 @@ static int sh_eth_rx(struct net_device *
 		if (mdp->cd->shift_rd0)
 			desc_status >>= 16;
 
+		skb = mdp->rx_skbuff[entry];
 		if (desc_status & (RD_RFS1 | RD_RFS2 | RD_RFS3 | RD_RFS4 |
 				   RD_RFS5 | RD_RFS6 | RD_RFS10)) {
 			ndev->stats.rx_errors++;
@@ -1477,12 +1478,11 @@ static int sh_eth_rx(struct net_device *
 				ndev->stats.rx_missed_errors++;
 			if (desc_status & RD_RFS10)
 				ndev->stats.rx_over_errors++;
-		} else {
+		} else	if (skb) {
 			if (!mdp->cd->hw_swap)
 				sh_eth_soft_swap(
 					phys_to_virt(ALIGN(rxdesc->addr, 4)),
 					pkt_len + 2);
-			skb = mdp->rx_skbuff[entry];
 			mdp->rx_skbuff[entry] = NULL;
 			if (mdp->cd->rpadir)
 				skb_reserve(skb, NET_IP_ALIGN);

