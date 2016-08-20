From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] wan-cosa: Use memdup_user() rather than duplicating its
 implementation
Date: Sat, 20 Aug 2016 10:25:32 +0200
Message-ID: <5d335025-5f52-d4b6-0b60-89a2fd354694@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        Nicolas Palix <nicolas.palix@imag.fr>
To: netdev@vger.kernel.org, Jan Kasprzak <kas@fi.muni.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 20 Aug 2016 10:10:12 +0200

Reuse existing functionality from memdup_user() instead of keeping
duplicate source code.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wan/cosa.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index b87fe0a..02f5809 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -875,16 +875,10 @@ static ssize_t cosa_write(struct file *file,
 	if (count > COSA_MTU)
 		count = COSA_MTU;
 	
-	/* Allocate the buffer */
-	kbuf = kmalloc(count, GFP_KERNEL|GFP_DMA);
-	if (kbuf == NULL) {
+	kbuf = memdup_user(buf, count);
+	if (IS_ERR(kbuf)) {
 		up(&chan->wsem);
-		return -ENOMEM;
-	}
-	if (copy_from_user(kbuf, buf, count)) {
-		up(&chan->wsem);
-		kfree(kbuf);
-		return -EFAULT;
+		return PTR_ERR(kbuf);
 	}
 	chan->tx_status=0;
 	cosa_start_tx(chan, kbuf, count);
-- 
2.9.3
