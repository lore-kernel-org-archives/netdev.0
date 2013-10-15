From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH 05/18] rt18192u: use wrapper functions of net_ratelimit() to simplify code
Date: Tue, 15 Oct 2013 19:45:01 +0800
Message-ID: <1381837514-50660-6-git-send-email-wangkefeng.wang@huawei.com>
References: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Stephen Hemminger" <stephen@networkplumber.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Samuel Ortiz <samuel@sortiz.org>,
	Paul Mackerras <paulus@samba.org>,
	Oliver Neukum <oneukum@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>, <netfilter@vger.kernel.org>,
	<netdev@vger.ker
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net_XXX_ratelimited() is called to simplify code.

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 .../rtl8192u/ieee80211/ieee80211_crypt_ccmp.c      | 17 ++++-------------
 .../rtl8192u/ieee80211/ieee80211_crypt_tkip.c      | 22 +++++-----------------
 drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c  |  7 ++-----
 drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c  |  4 +---
 4 files changed, 12 insertions(+), 38 deletions(-)

diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_crypt_ccmp.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_crypt_ccmp.c
index f2b1677..534f0a4 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211_crypt_ccmp.c
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_crypt_ccmp.c
@@ -284,10 +284,8 @@ static int ieee80211_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	pos = skb->data + hdr_len;
 	keyidx = pos[3];
 	if (!(keyidx & (1 << 5))) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "CCMP: received packet without ExtIV"
+		net_dbg_ratelimited("CCMP: received packet without ExtIV"
 			       " flag from %pM\n", hdr->addr2);
-		}
 		key->dot11RSNAStatsCCMPFormatErrors++;
 		return -2;
 	}
@@ -298,11 +296,9 @@ static int ieee80211_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 		return -6;
 	}
 	if (!key->key_set) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "CCMP: received packet from %pM"
+		net_dbg_ratelimited("CCMP: received packet from %pM"
 			       " with keyid=%d that does not have a configured"
 			       " key\n", hdr->addr2, keyidx);
-		}
 		return -3;
 	}
 
@@ -315,11 +311,9 @@ static int ieee80211_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	pos += 8;
 
 	if (memcmp(pn, key->rx_pn, CCMP_PN_LEN) <= 0) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "CCMP: replay detected: STA=%pM"
+		net_dbg_ratelimited("CCMP: replay detected: STA=%pM"
 			       " previous PN %pm received PN %pm\n",
 			       hdr->addr2, key->rx_pn, pn);
-		}
 		key->dot11RSNAStatsCCMPReplays++;
 		return -4;
 	}
@@ -353,10 +347,7 @@ static int ieee80211_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 		}
 
 		if (memcmp(mic, a, CCMP_MIC_LEN) != 0) {
-			if (net_ratelimit()) {
-				printk(KERN_DEBUG "CCMP: decrypt failed: STA="
-				"%pM\n", hdr->addr2);
-			}
+			net_dbg_ratelimited("CCMP: decrypt failed: STA=%pM\n", hdr->addr2);
 			key->dot11RSNAStatsCCMPDecryptErrors++;
 			return -5;
 		}
diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_crypt_tkip.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_crypt_tkip.c
index 93121b4..7bb5a96 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211_crypt_tkip.c
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_crypt_tkip.c
@@ -406,10 +406,8 @@ static int ieee80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	pos = skb->data + hdr_len;
 	keyidx = pos[3];
 	if (!(keyidx & (1 << 5))) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "TKIP: received packet without ExtIV"
+		net_dbg_ratelimited("TKIP: received packet without ExtIV"
 			       " flag from %pM\n", hdr->addr2);
-		}
 		return -2;
 	}
 	keyidx >>= 6;
@@ -419,11 +417,9 @@ static int ieee80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 		return -6;
 	}
 	if (!tkey->key_set) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "TKIP: received packet from %pM"
+		net_dbg_ratelimited("TKIP: received packet from %pM"
 			       " with keyid=%d that does not have a configured"
 			       " key\n", hdr->addr2, keyidx);
-		}
 		return -3;
 	}
 	iv16 = (pos[0] << 8) | pos[2];
@@ -434,12 +430,10 @@ static int ieee80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	{
 		if (iv32 < tkey->rx_iv32 ||
 		(iv32 == tkey->rx_iv32 && iv16 <= tkey->rx_iv16)) {
-			if (net_ratelimit()) {
-				printk(KERN_DEBUG "TKIP: replay detected: STA=%pM"
+			net_dbg_ratelimited("TKIP: replay detected: STA=%pM"
 				" previous TSC %08x%04x received TSC "
 				"%08x%04x\n", hdr->addr2,
 				tkey->rx_iv32, tkey->rx_iv16, iv32, iv16);
-			}
 			tkey->dot11RSNAStatsTKIPReplays++;
 			return -4;
 		}
@@ -456,11 +450,8 @@ static int ieee80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 		sg_init_one(&sg, pos, plen+4);
 
 		if (crypto_blkcipher_decrypt(&desc, &sg, &sg, plen + 4)) {
-			if (net_ratelimit()) {
-				printk(KERN_DEBUG ": TKIP: failed to decrypt "
-						"received packet from %pM\n",
+			net_dbg_ratelimited("TKIP: failed to decrypt received packet from %pM\n",
 						hdr->addr2);
-			}
 			return -7;
 		}
 
@@ -476,10 +467,7 @@ static int ieee80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 				* it needs to be recalculated for the next packet. */
 				tkey->rx_phase1_done = 0;
 			}
-			if (net_ratelimit()) {
-				printk(KERN_DEBUG "TKIP: ICV error detected: STA="
-				"%pM\n", hdr->addr2);
-			}
+			net_dbg_ratelimited("TKIP: ICV error detected: STA=%pM\n", hdr->addr2);
 			tkey->dot11RSNAStatsTKIPICVErrors++;
 			return -5;
 		}
diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c
index 59900bf..5e6c1eb 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c
@@ -355,11 +355,9 @@ ieee80211_rx_frame_decrypt(struct ieee80211_device *ieee, struct sk_buff *skb,
 #ifdef CONFIG_IEEE80211_CRYPT_TKIP
 	if (ieee->tkip_countermeasures &&
 	    strcmp(crypt->ops->name, "TKIP") == 0) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: TKIP countermeasures: dropped "
+		net_dbg_ratelimited("%s: TKIP countermeasures: dropped "
 			       "received packet from %pM\n",
 			       ieee->dev->name, hdr->addr2);
-		}
 		return -1;
 	}
 #endif
@@ -946,8 +944,7 @@ int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
 
 	if(HTCCheck(ieee, skb->data))
 	{
-		if(net_ratelimit())
-		printk("find HTCControl\n");
+		net_info_ratelimited("find HTCControl\n");
 		hdrlen += 4;
 		rx_stats->bContainHTC = 1;
 	}
diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c
index a7bcc64f..55c24d7 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c
@@ -197,11 +197,9 @@ int ieee80211_encrypt_fragment(
 	if (ieee->tkip_countermeasures &&
 	    crypt && crypt->ops && strcmp(crypt->ops->name, "TKIP") == 0) {
 		header = (struct ieee80211_hdr *) frag->data;
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: TKIP countermeasures: dropped "
+		net_dbg_ratelimited("%s: TKIP countermeasures: dropped "
 			       "TX packet to %pM\n",
 			       ieee->dev->name, header->addr1);
-		}
 		return -1;
 	}
 #endif
-- 
1.8.2.1
