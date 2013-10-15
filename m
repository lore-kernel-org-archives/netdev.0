From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH 03/18] rt18187se: use wrapper functions of net_ratelimit() to simplify code
Date: Tue, 15 Oct 2013 19:44:59 +0800
Message-ID: <1381837514-50660-4-git-send-email-wangkefeng.wang@huawei.com>
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

Wrapper functions net_ratelimited_function() and net_XXX_ratelimited()
are called to simplify code.

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 .../rtl8187se/ieee80211/ieee80211_crypt_ccmp.c     | 16 ++++---------
 .../rtl8187se/ieee80211/ieee80211_crypt_tkip.c     | 27 ++++++----------------
 drivers/staging/rtl8187se/ieee80211/ieee80211_rx.c |  4 +---
 drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c |  7 ++----
 4 files changed, 14 insertions(+), 40 deletions(-)

diff --git a/drivers/staging/rtl8187se/ieee80211/ieee80211_crypt_ccmp.c b/drivers/staging/rtl8187se/ieee80211/ieee80211_crypt_ccmp.c
index f5949e8..be6c5a1 100644
--- a/drivers/staging/rtl8187se/ieee80211/ieee80211_crypt_ccmp.c
+++ b/drivers/staging/rtl8187se/ieee80211/ieee80211_crypt_ccmp.c
@@ -282,10 +282,8 @@ static int ieee80211_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	pos = skb->data + hdr_len;
 	keyidx = pos[3];
 	if (!(keyidx & (1 << 5))) {
-		if (net_ratelimit()) {
-			pr_debug("received packet without ExtIV flag from %pM\n",
+		net_dbg_ratelimited("received packet without ExtIV flag from %pM\n",
 				 hdr->addr2);
-		}
 		key->dot11RSNAStatsCCMPFormatErrors++;
 		return -2;
 	}
@@ -296,10 +294,8 @@ static int ieee80211_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 		return -6;
 	}
 	if (!key->key_set) {
-		if (net_ratelimit()) {
-			pr_debug("received packet from %pM with keyid=%d that does not have a configured key\n",
+		net_dbg_ratelimited("received packet from %pM with keyid=%d that does not have a configured key\n",
 				 hdr->addr2, keyidx);
-		}
 		return -3;
 	}
 
@@ -312,10 +308,8 @@ static int ieee80211_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	pos += 8;
 
 	if (memcmp(pn, key->rx_pn, CCMP_PN_LEN) <= 0) {
-		if (net_ratelimit()) {
-			pr_debug("replay detected: STA=%pM previous PN %pm received PN %pm\n",
+		net_dbg_ratelimited("replay detected: STA=%pM previous PN %pm received PN %pm\n",
 				 hdr->addr2, key->rx_pn, pn);
-		}
 		key->dot11RSNAStatsCCMPReplays++;
 		return -4;
 	}
@@ -340,9 +334,7 @@ static int ieee80211_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	}
 
 	if (memcmp(mic, a, CCMP_MIC_LEN) != 0) {
-		if (net_ratelimit())
-			pr_debug("decrypt failed: STA=%pM\n", hdr->addr2);
-
+		net_dbg_ratelimited("decrypt failed: STA=%pM\n", hdr->addr2);
 		key->dot11RSNAStatsCCMPDecryptErrors++;
 		return -5;
 	}
diff --git a/drivers/staging/rtl8187se/ieee80211/ieee80211_crypt_tkip.c b/drivers/staging/rtl8187se/ieee80211/ieee80211_crypt_tkip.c
index da24e43..03e1961 100644
--- a/drivers/staging/rtl8187se/ieee80211/ieee80211_crypt_tkip.c
+++ b/drivers/staging/rtl8187se/ieee80211/ieee80211_crypt_tkip.c
@@ -381,10 +381,8 @@ static int ieee80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
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
@@ -394,11 +392,9 @@ static int ieee80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
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
@@ -407,12 +403,9 @@ static int ieee80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 
 	if (iv32 < tkey->rx_iv32 ||
 	    (iv32 == tkey->rx_iv32 && iv16 <= tkey->rx_iv16)) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "TKIP: replay detected: STA=%pM"
-			       " previous TSC %08x%04x received TSC "
-			       "%08x%04x\n", hdr->addr2,
-			       tkey->rx_iv32, tkey->rx_iv16, iv32, iv16);
-		}
+		net_dbg_ratelimited("TKIP: replay detected: STA=%pM"
+			" previous TSC %08x%04x received TSC %08x%04x\n",
+			hdr->addr2, tkey->rx_iv32, tkey->rx_iv16, iv32, iv16);
 		tkey->dot11RSNAStatsTKIPReplays++;
 		return -4;
 	}
@@ -427,11 +420,8 @@ static int ieee80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	crypto_blkcipher_setkey(tkey->rx_tfm_arc4, rc4key, 16);
 	sg_init_one(&sg, pos, plen + 4);
 	if (crypto_blkcipher_decrypt(&desc, &sg, &sg, plen + 4)) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG ": TKIP: failed to decrypt "
-			       "received packet from %pM\n",
+		net_dbg_ratelimited(": TKIP: failed to decrypt received packet from %pM\n",
 			       hdr->addr2);
-		}
 		return -7;
 	}
 
@@ -446,10 +436,7 @@ static int ieee80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 			 * it needs to be recalculated for the next packet. */
 			tkey->rx_phase1_done = 0;
 		}
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "TKIP: ICV error detected: STA="
-			       "%pM\n", hdr->addr2);
-		}
+		net_dbg_ratelimited("TKIP: ICV error detected: STA=%pM\n", hdr->addr2);
 		tkey->dot11RSNAStatsTKIPICVErrors++;
 		return -5;
 	}
diff --git a/drivers/staging/rtl8187se/ieee80211/ieee80211_rx.c b/drivers/staging/rtl8187se/ieee80211/ieee80211_rx.c
index 10b2210..fa125f2 100644
--- a/drivers/staging/rtl8187se/ieee80211/ieee80211_rx.c
+++ b/drivers/staging/rtl8187se/ieee80211/ieee80211_rx.c
@@ -307,11 +307,9 @@ ieee80211_rx_frame_decrypt(struct ieee80211_device *ieee, struct sk_buff *skb,
 #ifdef CONFIG_IEEE80211_CRYPT_TKIP
 	if (ieee->tkip_countermeasures &&
 	    strcmp(crypt->ops->name, "TKIP") == 0) {
-		if (net_ratelimit()) {
-			netdev_dbg(ieee->dev,
+		net_ratelimited_function(netdev_dbg, ieee->dev,
 				   "TKIP countermeasures: dropped received packet from %pM\n",
 				   ieee->dev->name, hdr->addr2);
-		}
 		return -1;
 	}
 #endif
diff --git a/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c b/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c
index b346653..366b1df3 100644
--- a/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c
+++ b/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c
@@ -196,11 +196,8 @@ int ieee80211_encrypt_fragment(
 	if (ieee->tkip_countermeasures &&
 	    crypt && crypt->ops && strcmp(crypt->ops->name, "TKIP") == 0) {
 		header = (struct ieee80211_hdr_4addr *)frag->data;
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: TKIP countermeasures: dropped "
-			       "TX packet to %pM\n",
-			       ieee->dev->name, header->addr1);
-		}
+		net_dbg_ratelimited("%s: TKIP countermeasures: dropped "
+			"TX packet to %pM\n", ieee->dev->name, header->addr1);
 		return -1;
 	}
 #endif
-- 
1.8.2.1
