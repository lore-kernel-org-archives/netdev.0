From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH 04/18] rt18192e: use wrapper functions of net_ratelimit() to simplify code
Date: Tue, 15 Oct 2013 19:45:00 +0800
Message-ID: <1381837514-50660-5-git-send-email-wangkefeng.wang@huawei.com>
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
 drivers/staging/rtl8192e/rtllib_crypt_ccmp.c | 13 +++----------
 drivers/staging/rtl8192e/rtllib_crypt_tkip.c | 21 +++++----------------
 drivers/staging/rtl8192e/rtllib_rx.c         |  6 ++----
 3 files changed, 10 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/rtl8192e/rtllib_crypt_ccmp.c b/drivers/staging/rtl8192e/rtllib_crypt_ccmp.c
index e51cb49..0d089c1 100644
--- a/drivers/staging/rtl8192e/rtllib_crypt_ccmp.c
+++ b/drivers/staging/rtl8192e/rtllib_crypt_ccmp.c
@@ -275,10 +275,8 @@ static int rtllib_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
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
@@ -289,11 +287,9 @@ static int rtllib_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
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
 
@@ -338,10 +334,7 @@ static int rtllib_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 		}
 
 		if (memcmp(mic, a, CCMP_MIC_LEN) != 0) {
-			if (net_ratelimit()) {
-				printk(KERN_DEBUG "CCMP: decrypt failed: STA="
-				" %pM\n", hdr->addr2);
-			}
+			net_dbg_ratelimited("CCMP: decrypt failed: STA= %pM\n", hdr->addr2);
 			key->dot11RSNAStatsCCMPDecryptErrors++;
 			return -5;
 		}
diff --git a/drivers/staging/rtl8192e/rtllib_crypt_tkip.c b/drivers/staging/rtl8192e/rtllib_crypt_tkip.c
index 5cfd73b..c1f7683 100644
--- a/drivers/staging/rtl8192e/rtllib_crypt_tkip.c
+++ b/drivers/staging/rtl8192e/rtllib_crypt_tkip.c
@@ -396,10 +396,8 @@ static int rtllib_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
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
@@ -409,11 +407,9 @@ static int rtllib_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
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
@@ -424,12 +420,10 @@ static int rtllib_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 		if ((iv32 < tkey->rx_iv32 ||
 		    (iv32 == tkey->rx_iv32 && iv16 <= tkey->rx_iv16)) &&
 		    tkey->initialized) {
-			if (net_ratelimit()) {
-				printk(KERN_DEBUG "TKIP: replay detected: STA="
+			net_dbg_ratelimited("TKIP: replay detected: STA="
 				       " %pM previous TSC %08x%04x received "
 				      "TSC %08x%04x\n",hdr->addr2,
 				      tkey->rx_iv32, tkey->rx_iv16, iv32, iv16);
-			}
 			tkey->dot11RSNAStatsTKIPReplays++;
 			return -4;
 		}
@@ -448,11 +442,9 @@ static int rtllib_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 
 		crypto_blkcipher_setkey(tkey->rx_tfm_arc4, rc4key, 16);
 		if (crypto_blkcipher_decrypt(&desc, &sg, &sg, plen + 4)) {
-			if (net_ratelimit()) {
-				printk(KERN_DEBUG ": TKIP: failed to decrypt "
+			net_dbg_ratelimited(": TKIP: failed to decrypt "
 				       "received packet from %pM\n",
 				       hdr->addr2);
-			}
 			return -7;
 		}
 
@@ -469,10 +461,7 @@ static int rtllib_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 				 * next packet. */
 				tkey->rx_phase1_done = 0;
 			}
-			if (net_ratelimit()) {
-				printk(KERN_DEBUG "TKIP: ICV error detected: STA="
-				" %pM\n", hdr->addr2);
-			}
+			net_dbg_ratelimited("TKIP: ICV error detected: STA= %pM\n", hdr->addr2);
 			tkey->dot11RSNAStatsTKIPICVErrors++;
 			return -5;
 		}
diff --git a/drivers/staging/rtl8192e/rtllib_rx.c b/drivers/staging/rtl8192e/rtllib_rx.c
index 8aeaed5..4335611 100644
--- a/drivers/staging/rtl8192e/rtllib_rx.c
+++ b/drivers/staging/rtl8192e/rtllib_rx.c
@@ -870,8 +870,7 @@ static size_t rtllib_rx_get_hdrlen(struct rtllib_device *ieee,
 
 	hdrlen = rtllib_get_hdrlen(fc);
 	if (HTCCheck(ieee, skb->data)) {
-		if (net_ratelimit())
-			printk(KERN_INFO "%s: find HTCControl!\n", __func__);
+		net_info_ratelimited("%s: find HTCControl!\n", __func__);
 		hdrlen += 4;
 		rx_stats->bContainHTC = 1;
 	}
@@ -1439,8 +1438,7 @@ static int rtllib_rx_Monitor(struct rtllib_device *ieee, struct sk_buff *skb,
 	}
 
 	if (HTCCheck(ieee, skb->data)) {
-		if (net_ratelimit())
-			printk(KERN_INFO "%s: Find HTCControl!\n", __func__);
+		net_info_ratelimited("%s: Find HTCControl!\n", __func__);
 		hdrlen += 4;
 	}
 
-- 
1.8.2.1
