From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v4 7/9] rocker: fix rocker_tlv_put_* functions for KASAN
Date: Fri, 22 Sep 2017 23:29:18 +0200
Message-ID: <20170922212930.620249-8-arnd@arndb.de>
References: <20170922212930.620249-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Michal Marek <mmarek@suse.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kees Cook <keescook@chromium.org>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-media@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com,
        brcm80211-dev-list@cypress.com, kasan
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170922212930.620249-1-arnd@arndb.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Inlining these functions creates lots of stack variables that each take
64 bytes when KASAN is enabled, leading to this warning about potential
stack overflow:

drivers/net/ethernet/rocker/rocker_ofdpa.c: In function 'ofdpa_cmd_flow_tbl_add':
drivers/net/ethernet/rocker/rocker_ofdpa.c:621:1: error: the frame size of 2752 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]

gcc-8 can now consolidate the stack slots itself, but on older versions
we get the same behavior by using a temporary variable that holds a
copy of the inline function argument.

Cc: stable@vger.kernel.org
Link: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81715
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/rocker/rocker_tlv.h | 48 ++++++++++++++++++++------------
 1 file changed, 30 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_tlv.h b/drivers/net/ethernet/rocker/rocker_tlv.h
index a63ef82e7c72..dfae3c9d57c6 100644
--- a/drivers/net/ethernet/rocker/rocker_tlv.h
+++ b/drivers/net/ethernet/rocker/rocker_tlv.h
@@ -139,40 +139,52 @@ rocker_tlv_start(struct rocker_desc_info *desc_info)
 int rocker_tlv_put(struct rocker_desc_info *desc_info,
 		   int attrtype, int attrlen, const void *data);
 
-static inline int rocker_tlv_put_u8(struct rocker_desc_info *desc_info,
-				    int attrtype, u8 value)
+static inline int
+rocker_tlv_put_u8(struct rocker_desc_info *desc_info, int attrtype, u8 value)
 {
-	return rocker_tlv_put(desc_info, attrtype, sizeof(u8), &value);
+	u8 tmp = value; /* work around GCC PR81715 */
+
+	return rocker_tlv_put(desc_info, attrtype, sizeof(u8), &tmp);
 }
 
-static inline int rocker_tlv_put_u16(struct rocker_desc_info *desc_info,
-				     int attrtype, u16 value)
+static inline int
+rocker_tlv_put_u16(struct rocker_desc_info *desc_info, int attrtype, u16 value)
 {
-	return rocker_tlv_put(desc_info, attrtype, sizeof(u16), &value);
+	u16 tmp = value;
+
+	return rocker_tlv_put(desc_info, attrtype, sizeof(u16), &tmp);
 }
 
-static inline int rocker_tlv_put_be16(struct rocker_desc_info *desc_info,
-				      int attrtype, __be16 value)
+static inline int
+rocker_tlv_put_be16(struct rocker_desc_info *desc_info, int attrtype, __be16 value)
 {
-	return rocker_tlv_put(desc_info, attrtype, sizeof(__be16), &value);
+	__be16 tmp = value;
+
+	return rocker_tlv_put(desc_info, attrtype, sizeof(__be16), &tmp);
 }
 
-static inline int rocker_tlv_put_u32(struct rocker_desc_info *desc_info,
-				     int attrtype, u32 value)
+static inline int
+rocker_tlv_put_u32(struct rocker_desc_info *desc_info, int attrtype, u32 value)
 {
-	return rocker_tlv_put(desc_info, attrtype, sizeof(u32), &value);
+	u32 tmp = value;
+
+	return rocker_tlv_put(desc_info, attrtype, sizeof(u32), &tmp);
 }
 
-static inline int rocker_tlv_put_be32(struct rocker_desc_info *desc_info,
-				      int attrtype, __be32 value)
+static inline int
+rocker_tlv_put_be32(struct rocker_desc_info *desc_info, int attrtype, __be32 value)
 {
-	return rocker_tlv_put(desc_info, attrtype, sizeof(__be32), &value);
+	__be32 tmp = value;
+
+	return rocker_tlv_put(desc_info, attrtype, sizeof(__be32), &tmp);
 }
 
-static inline int rocker_tlv_put_u64(struct rocker_desc_info *desc_info,
-				     int attrtype, u64 value)
+static inline int
+rocker_tlv_put_u64(struct rocker_desc_info *desc_info, int attrtype, u64 value)
 {
-	return rocker_tlv_put(desc_info, attrtype, sizeof(u64), &value);
+	u64 tmp = value;
+
+	return rocker_tlv_put(desc_info, attrtype, sizeof(u64), &tmp);
 }
 
 static inline struct rocker_tlv *
-- 
2.9.0
