From: Johannes Thumshirn <jthumshirn-l3A5Bk7waGM@public.gmane.org>
Subject: [PATCH v2] cw1200: Don't leak memory if krealloc failes
Date: Fri, 30 Sep 2016 14:39:17 +0200
Message-ID: <1475239157-16448-1-git-send-email-jthumshirn@suse.de>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Johannes Thumshirn <jthumshirn-l3A5Bk7waGM@public.gmane.org>,
        Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
To: Solomon Peachy <pizza-pCgMCH4qpMRg9hUCZPvPmw@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The call to krealloc() in wsm_buf_reserve() directly assigns the newly
returned memory to buf->begin. This is all fine except when krealloc()
failes we loose the ability to free the old memory pointed to by
buf->begin. If we just create a temporary variable to assign memory to
and assign the memory to it we can mitigate the memory leak.

Signed-off-by: Johannes Thumshirn <jthumshirn-l3A5Bk7waGM@public.gmane.org>
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
 drivers/net/wireless/st/cw1200/wsm.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

Changes from v1:
* Do the correct check for a failed re-allocation (Johannes Berg)

diff --git a/drivers/net/wireless/st/cw1200/wsm.c b/drivers/net/wireless/st/cw1200/wsm.c
index 680d60e..ffb245e 100644
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
+	if (!tmp) {
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
