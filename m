From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: [PATCH 1/3] cw1200: Don't leak memory if krealloc failes
Date: Fri, 30 Sep 2016 14:11:35 +0200
Message-ID: <1475237495-15030-1-git-send-email-jthumshirn@suse.de>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Johannes Thumshirn <jthumshirn@suse.de>
To: Solomon Peachy <pizza@shaftnet.org>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The call to krealloc() in wsm_buf_reserve() directly assigns the newly
returned memory to buf->begin. This is all fine except when krealloc()
failes we loose the ability to free the old memory pointed to by
buf->begin. If we just create a temporary variable to assign memory to
and assign the memory to it we can mitigate the memory leak.

Signed-off-by: Johannes Thumshirn <jthumshirn@suse.de>
---
 drivers/net/wireless/st/cw1200/wsm.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/st/cw1200/wsm.c b/drivers/net/wireless/st/cw1200/wsm.c
index 680d60e..12fad99 100644
--- a/drivers/net/wireless/st/cw1200/wsm.c
+++ b/drivers/net/wireless/st/cw1200/wsm.c
@@ -1807,16 +1807,18 @@ static int wsm_buf_reserve(struct wsm_buf *buf, size_t extra_size)
 {
 	size_t pos = buf->data - buf->begin;
 	size_t size = pos + extra_size;
+	u8 *tmp;
 
 	size = round_up(size, FWLOAD_BLOCK_SIZE);
 
-	buf->begin = krealloc(buf->begin, size, GFP_KERNEL | GFP_DMA);
-	if (buf->begin) {
-		buf->data = &buf->begin[pos];
-		buf->end = &buf->begin[size];
-		return 0;
-	} else {
-		buf->end = buf->data = buf->begin;
+	tmp = krealloc(buf->begin, size, GFP_KERNEL | GFP_DMA);
+	if (tmp) {
+		wsm_buf_deinit(buf);
 		return -ENOMEM;
 	}
+
+	buf->begin = tmp;
+	buf->data = &buf->begin[pos];
+	buf->end = &buf->begin[size];
+	return 0;
 }
-- 
1.8.5.6
