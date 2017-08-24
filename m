From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] isdn: hisax: fix buffer overflow check
Date: Fri, 25 Aug 2017 00:58:33 +0200
Message-ID: <20170824225931.1602326-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc-8 warns about a corner case that can overflow a memcpy buffer when a
length variable is negative. While the code checks for an overly large
value, it does not check for a negative length that would get turned
into a large positive number:

In function 'memcpy',
    inlined from 'skb_put_data' at include/linux/skbuff.h:2042:2,
    inlined from 'l3dss1_cmd_global' at drivers/isdn/hisax/l3dss1.c:2219:4:
include/linux/string.h:348:9: error: '__builtin_memcpy' reading 266 or more bytes from a region of size 265 [-Werror=stringop-overflow=]

In function 'memcpy',
    inlined from 'skb_put_data' at include/linux/skbuff.h:2042:2,
    inlined from 'l3ni1_cmd_global' at drivers/isdn/hisax/l3ni1.c:2079:4:
include/linux/string.h:348:9: error: '__builtin_memcpy' reading between 266 and 4294967295 bytes from a region of size 265 [-Werror=stringop-overflow=]

It's not clear to me whether the warning should be here, or if this
is another case of an optimization step in gcc causing a warning about
something that would otherwise be silently ignored. Either way, making
the length 'unsigned int' instead ensures that no overflow can happen
here, and avoids the warning. The same code exists in two files, so I'm
patching both the same way.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/isdn/hisax/l3dss1.c | 3 ++-
 drivers/isdn/hisax/l3ni1.c  | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hisax/l3dss1.c b/drivers/isdn/hisax/l3dss1.c
index 18a3484b1f7e..85cef7a2e709 100644
--- a/drivers/isdn/hisax/l3dss1.c
+++ b/drivers/isdn/hisax/l3dss1.c
@@ -2168,7 +2168,8 @@ static int l3dss1_cmd_global(struct PStack *st, isdn_ctrl *ic)
 { u_char id;
 	u_char temp[265];
 	u_char *p = temp;
-	int i, l, proc_len;
+	int i;
+	unsigned int l, proc_len;
 	struct sk_buff *skb;
 	struct l3_process *pc = NULL;
 
diff --git a/drivers/isdn/hisax/l3ni1.c b/drivers/isdn/hisax/l3ni1.c
index ea311e7df48e..99e0ba5d49a1 100644
--- a/drivers/isdn/hisax/l3ni1.c
+++ b/drivers/isdn/hisax/l3ni1.c
@@ -2024,7 +2024,8 @@ static int l3ni1_cmd_global(struct PStack *st, isdn_ctrl *ic)
 { u_char id;
 	u_char temp[265];
 	u_char *p = temp;
-	int i, l, proc_len;
+	int i;
+	unsigned int l, proc_len;
 	struct sk_buff *skb;
 	struct l3_process *pc = NULL;
 
-- 
2.9.0
