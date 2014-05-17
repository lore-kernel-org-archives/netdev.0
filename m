From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 3/4] atm: idt77252: Remove redundant error check
Date: Sat, 17 May 2014 20:22:59 +0200
Message-ID: <1400350980-30455-3-git-send-email-peter.senna@gmail.com>
Cc: Peter Senna Tschudin <peter.senna@gmail.com>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove double checks, and move the call to printk to the
first check. Also adds KERN_WARNING to printk. The simplified version
of the coccinelle semantic patch that fixes this issue is as follows:

// <smpl>
@@
expression E; identifier pr; expression list es;
@@
while(...){
...
-	if (E) break;
+	if (E){
+		pr(es);
+		break;
+	}
...
}
- if(E) pr(es);
// </smpl>

Tested by compilation only.

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
 drivers/atm/idt77252.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 1bdf104..a8b6402 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -2551,12 +2551,12 @@ done:
 		timeout = 5 * 1000;
 		while (atomic_read(&vc->scq->used) > 0) {
 			timeout = msleep_interruptible(timeout);
-			if (!timeout)
+			if (!timeout) {
+				printk(KERN_WARNING "%s: SCQ drain timeout: %u used\n",
+				       card->name, atomic_read(&vc->scq->used));
 				break;
+			}
 		}
-		if (!timeout)
-			printk("%s: SCQ drain timeout: %u used\n",
-			       card->name, atomic_read(&vc->scq->used));
 
 		writel(TCMDQ_HALT | vc->index, SAR_REG_TCMDQ);
 		clear_scd(card, vc->scq, vc->class);
