From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 04/14] tg3: use netdev_rss_key_fill() helper
Date: Sun, 16 Nov 2014 06:23:08 -0800
Message-ID: <1416147798-16561-5-git-send-email-edumazet@google.com>
References: <1416147798-16561-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Thomas Lendacky <Thomas.Lendacky@amd.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	Shradha Shah <sshah@solarflare.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:56396 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754691AbaKPOXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 09:23:50 -0500
Received: by mail-pd0-f202.google.com with SMTP id g10so28847pdj.3
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 06:23:49 -0800 (PST)
In-Reply-To: <1416147798-16561-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use of well known RSS key increases attack surface.
Switch to a random one, using generic helper so that all
ports share a common key.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Prashant Sreedharan <prashant@broadcom.com>
Cc: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index dbb41c1923e6..2dc001559a97 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -10540,19 +10540,14 @@ static int tg3_reset_hw(struct tg3 *tp, bool reset_phy)
 	udelay(100);
 
 	if (tg3_flag(tp, ENABLE_RSS)) {
+		u32 rss_key[10];
+
 		tg3_rss_write_indir_tbl(tp);
 
-		/* Setup the "secret" hash key. */
-		tw32(MAC_RSS_HASH_KEY_0, 0x5f865437);
-		tw32(MAC_RSS_HASH_KEY_1, 0xe4ac62cc);
-		tw32(MAC_RSS_HASH_KEY_2, 0x50103a45);
-		tw32(MAC_RSS_HASH_KEY_3, 0x36621985);
-		tw32(MAC_RSS_HASH_KEY_4, 0xbf14c0e8);
-		tw32(MAC_RSS_HASH_KEY_5, 0x1bc27a1e);
-		tw32(MAC_RSS_HASH_KEY_6, 0x84f4b556);
-		tw32(MAC_RSS_HASH_KEY_7, 0x094ea6fe);
-		tw32(MAC_RSS_HASH_KEY_8, 0x7dda01e7);
-		tw32(MAC_RSS_HASH_KEY_9, 0xc04d7481);
+		netdev_rss_key_fill(rss_key, 10 * sizeof(u32));
+
+		for (i = 0; i < 10 ; i++)
+			tw32(MAC_RSS_HASH_KEY_0 + i*4, rss_key[i]);
 	}
 
 	tp->rx_mode = RX_MODE_ENABLE;
-- 
2.1.0.rc2.206.gedb03e5
