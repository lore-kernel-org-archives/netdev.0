From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] brcm80211: Don't leak 'vbuffer' in
 brcmf_sdbrcm_write_vars()
Date: Sun, 8 Jan 2012 23:41:21 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1201082338350.24030@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, Alwin Beukers <alwin@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Franky Lin <frankyl@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the memory allocation 'nvram_ularray = kmalloc(varsize,
GFP_ATOMIC);' fails we'll leak the memory allocated to 'vbuffer' when
we return -ENOMEM from the function.

This patch resolves the leak by kfree()'ing the allocated memory
before the return.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

  compile tested only.

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
index 5a002a2..f7eeee1 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -3119,8 +3119,10 @@ static int brcmf_sdbrcm_write_vars(struct brcmf_sdio *bus)
 		/* Verify NVRAM bytes */
 		brcmf_dbg(INFO, "Compare NVRAM dl & ul; varsize=%d\n", varsize);
 		nvram_ularray = kmalloc(varsize, GFP_ATOMIC);
-		if (!nvram_ularray)
+		if (!nvram_ularray) {
+			kfree(vbuffer);
 			return -ENOMEM;
+		}
 
 		/* Upload image to verify downloaded contents. */
 		memset(nvram_ularray, 0xaa, varsize);
-- 
1.7.8.1



PS. Please CC me on replies.

-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
