From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mac80211: fils_aead: fix encrypt error handling
Date: Fri, 28 Oct 2016 12:25:53 +0200
Message-ID: <20161028102621.1881878-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Jouni Malinen <jouni@qca.qualcomm.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc -Wmaybe-uninitialized reports a bug in aes_siv_encryp:

net/mac80211/fils_aead.c: In function ‘aes_siv_encrypt.constprop’:
net/mac80211/fils_aead.c:84:26: error: ‘tfm2’ may be used uninitialized in this function [-Werror=maybe-uninitialized]

At the time that the memory allocation fails, 'tfm2' has not been
allocated, so we should not attempt to free it later, and we can
simply return an error.

Fixes: 39404feee691 ("mac80211: FILS AEAD protection for station mode association frames")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/mac80211/fils_aead.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/mac80211/fils_aead.c b/net/mac80211/fils_aead.c
index b81b4f2472cf..ecfdd97758a3 100644
--- a/net/mac80211/fils_aead.c
+++ b/net/mac80211/fils_aead.c
@@ -110,10 +110,8 @@ static int aes_siv_encrypt(const u8 *key, size_t key_len,
 	 * overwriting this during AES-CTR.
 	 */
 	tmp = kmemdup(plain, plain_len, GFP_KERNEL);
-	if (!tmp) {
-		res = -ENOMEM;
-		goto fail;
-	}
+	if (!tmp)
+		return -ENOMEM;
 
 	/* IV for CTR before encrypted data */
 	memcpy(out, v, AES_BLOCK_SIZE);
-- 
2.9.0
