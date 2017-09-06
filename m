From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] isdn: isdnloop: fix logic error in isdnloop_sendbuf
Date: Wed,  6 Sep 2017 15:38:58 +0200
Message-ID: <20170906133928.3152020-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Joe Perches <joe@perches.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc-7 found an ancient bug in the loop driver, leading to a condition that
is always false, meaning we ignore the contents of 'card->flags' here:

drivers/isdn/isdnloop/isdnloop.c:412:37: error: ?: using integer constants in boolean context, the expression will always evaluate to 'true' [-Werror=int-in-bool-context]

This changes the braces in the expression to ensure we actually
compare the flag bits, rather than comparing a constant. As Joe Perches
pointed out, an earlier patch of mine incorrectly assumed this was a
false-positive warning.

Cc: Joe Perches <joe@perches.com>
Link: https://patchwork.kernel.org/patch/9840289/
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/isdn/isdnloop/isdnloop.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/isdnloop/isdnloop.c b/drivers/isdn/isdnloop/isdnloop.c
index 6ffd13466b8c..e97232646ba1 100644
--- a/drivers/isdn/isdnloop/isdnloop.c
+++ b/drivers/isdn/isdnloop/isdnloop.c
@@ -409,7 +409,7 @@ isdnloop_sendbuf(int channel, struct sk_buff *skb, isdnloop_card *card)
 		return -EINVAL;
 	}
 	if (len) {
-		if (!(card->flags & (channel) ? ISDNLOOP_FLAGS_B2ACTIVE : ISDNLOOP_FLAGS_B1ACTIVE))
+		if (!(card->flags & (channel ? ISDNLOOP_FLAGS_B2ACTIVE : ISDNLOOP_FLAGS_B1ACTIVE)))
 			return 0;
 		if (card->sndcount[channel] > ISDNLOOP_MAX_SQUEUE)
 			return 0;
-- 
2.9.0
