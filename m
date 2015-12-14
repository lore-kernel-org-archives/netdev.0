From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH v3 net] ravb: clear RIC1 in init instead of stop
Date: Tue, 15 Dec 2015 01:24:58 +0900
Message-ID: <1450110298-21392-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>

AVB-DMAC Receive FIFO Warning interrupt is not enabled, so it is not
necessary to disable the interrupt in ravb_close().
On the other hand, this patch disables the interrupt in ravb_dmac_init() to
prevent the possibility that the interrupt is issued by the state that
a boot loader left.

Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---

This patch is based on the master branch of David Miller's networking
tree.

v3 [Yoshihiro Kaneko]
* compile tested only
* As suggested by Sergei Shtylyov
  - update the subject to reflect what this patch is doing.
  - clear RIC1 in ravb_dmac_init() instead of ravb_open().

v2 [Yoshihiro Kaneko]
* compile tested only
* As suggested by Sergei Shtylyov
  - clear RIC1 in ndo_open() to disable the interrupt regardless of
    a left state from a bootloader.

 drivers/net/ethernet/renesas/ravb_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index b69e0c2..b76303e 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -405,9 +405,11 @@ static int ravb_dmac_init(struct net_device *ndev)
 	/* Timestamp enable */
 	ravb_write(ndev, TCCR_TFEN, TCCR);
 
-	/* Interrupt enable: */
+	/* Interrupt init: */
 	/* Frame receive */
 	ravb_write(ndev, RIC0_FRE0 | RIC0_FRE1, RIC0);
+	/* Disable FIFO full warning */
+	ravb_write(ndev, 0, RIC1);
 	/* Receive FIFO full error, descriptor empty */
 	ravb_write(ndev, RIC2_QFE0 | RIC2_QFE1 | RIC2_RFFE, RIC2);
 	/* Frame transmitted, timestamp FIFO updated */
@@ -1471,7 +1473,6 @@ static int ravb_close(struct net_device *ndev)
 
 	/* Disable interrupts by clearing the interrupt masks. */
 	ravb_write(ndev, 0, RIC0);
-	ravb_write(ndev, 0, RIC1);
 	ravb_write(ndev, 0, RIC2);
 	ravb_write(ndev, 0, TIC);
 
-- 
1.9.1

