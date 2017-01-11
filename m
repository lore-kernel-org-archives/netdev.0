From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] wext: handle NULL exta data in iwe_stream_add_point better
Date: Wed, 11 Jan 2017 15:35:25 +0100
Message-ID: <20170111143532.485827-1-arnd@arndb.de>
Cc: linux-wireless@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc-7 complains that wl3501_cs passes NULL into a function that
then uses the argument as the input for memcpy:

drivers/net/wireless/wl3501_cs.c: In function 'wl3501_get_scan':
include/net/iw_handler.h:559:3: error: argument 2 null where non-null expected [-Werror=nonnull]
   memcpy(stream + point_len, extra, iwe->u.data.length);

This works fine here because iwe->u.data.length is guaranteed to be
NULL, and the memcpy doesn't actually have an effect.

Making the length check explicit avoids the warning and should have
no other effect here.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/net/iw_handler.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/iw_handler.h b/include/net/iw_handler.h
index e0f4109e64c6..1a41043688bc 100644
--- a/include/net/iw_handler.h
+++ b/include/net/iw_handler.h
@@ -556,7 +556,8 @@ iwe_stream_add_point(struct iw_request_info *info, char *stream, char *ends,
 		memcpy(stream + lcp_len,
 		       ((char *) &iwe->u) + IW_EV_POINT_OFF,
 		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
-		memcpy(stream + point_len, extra, iwe->u.data.length);
+		if (iwe->u.data.length)
+			memcpy(stream + point_len, extra, iwe->u.data.length);
 		stream += event_len;
 	}
 	return stream;
-- 
2.9.0
