From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] wireless: fix bogus maybe-uninitialized warning
Date: Mon, 24 Oct 2016 17:38:35 +0200
Message-ID: <20161024153918.2810634-2-arnd@arndb.de>
References: <20161024153918.2810634-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>,
        Stanislav Yakovlev <stas.yakovlev@gmail.com>,
        Jouni Malinen <j@w1.fi>,
        Johannes Berg <johannes@sipsolutions.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161024153918.2810634-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The hostap_80211_rx() function is supposed to set up the mac addresses
for four possible cases, based on two bits of input data. For
some reason, gcc decides that it's possible that none of the these
four cases apply and the addresses remain uninitialized:

drivers/net/wireless/intersil/hostap/hostap_80211_rx.c: In function ‘hostap_80211_rx’:
arch/x86/include/asm/string_32.h:77:14: warning: ‘src’ may be used uninitialized in this function [-Wmaybe-uninitialized]
drivers/net/wireless/intel/ipw2x00/libipw_rx.c: In function ‘libipw_rx’:
arch/x86/include/asm/string_32.h:77:14: error: ‘dst’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
arch/x86/include/asm/string_32.h:78:22: error: ‘*((void *)&dst+4)’ may be used uninitialized in this function [-Werror=maybe-uninitialized]

This warning is clearly nonsense, but changing the last case into
'default' makes it obvious to the compiler too, which avoids the
warning and probably leads to better object code too.

The same code is duplicated several times in the kernel, so this
patch uses the same workaround for all copies. The exact configuration
was hit only very rarely in randconfig builds and I only saw it
in three drivers, but I assume that all of them are potentially
affected, and it's better to keep the code consistent.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/wireless/ath/ath6kl/wmi.c                  | 8 ++++----
 drivers/net/wireless/intel/ipw2x00/libipw_rx.c         | 2 +-
 drivers/net/wireless/intersil/hostap/hostap_80211_rx.c | 2 +-
 net/wireless/lib80211_crypt_tkip.c                     | 2 +-
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/wmi.c b/drivers/net/wireless/ath/ath6kl/wmi.c
index 3fd1cc98fd2f..84a6d12c3f8a 100644
--- a/drivers/net/wireless/ath/ath6kl/wmi.c
+++ b/drivers/net/wireless/ath/ath6kl/wmi.c
@@ -421,10 +421,6 @@ int ath6kl_wmi_dot11_hdr_remove(struct wmi *wmi, struct sk_buff *skb)
 
 	switch ((le16_to_cpu(wh.frame_control)) &
 		(IEEE80211_FCTL_FROMDS | IEEE80211_FCTL_TODS)) {
-	case 0:
-		memcpy(eth_hdr.h_dest, wh.addr1, ETH_ALEN);
-		memcpy(eth_hdr.h_source, wh.addr2, ETH_ALEN);
-		break;
 	case IEEE80211_FCTL_TODS:
 		memcpy(eth_hdr.h_dest, wh.addr3, ETH_ALEN);
 		memcpy(eth_hdr.h_source, wh.addr2, ETH_ALEN);
@@ -435,6 +431,10 @@ int ath6kl_wmi_dot11_hdr_remove(struct wmi *wmi, struct sk_buff *skb)
 		break;
 	case IEEE80211_FCTL_FROMDS | IEEE80211_FCTL_TODS:
 		break;
+	default:
+		memcpy(eth_hdr.h_dest, wh.addr1, ETH_ALEN);
+		memcpy(eth_hdr.h_source, wh.addr2, ETH_ALEN);
+		break;
 	}
 
 	skb_pull(skb, sizeof(struct ath6kl_llc_snap_hdr));
diff --git a/drivers/net/wireless/intel/ipw2x00/libipw_rx.c b/drivers/net/wireless/intel/ipw2x00/libipw_rx.c
index cef7f7d79cd9..1c1ec7bb9302 100644
--- a/drivers/net/wireless/intel/ipw2x00/libipw_rx.c
+++ b/drivers/net/wireless/intel/ipw2x00/libipw_rx.c
@@ -507,7 +507,7 @@ int libipw_rx(struct libipw_device *ieee, struct sk_buff *skb,
 		memcpy(dst, hdr->addr3, ETH_ALEN);
 		memcpy(src, hdr->addr4, ETH_ALEN);
 		break;
-	case 0:
+	default:
 		memcpy(dst, hdr->addr1, ETH_ALEN);
 		memcpy(src, hdr->addr2, ETH_ALEN);
 		break;
diff --git a/drivers/net/wireless/intersil/hostap/hostap_80211_rx.c b/drivers/net/wireless/intersil/hostap/hostap_80211_rx.c
index 599f30f22841..34dbddbf3f9b 100644
--- a/drivers/net/wireless/intersil/hostap/hostap_80211_rx.c
+++ b/drivers/net/wireless/intersil/hostap/hostap_80211_rx.c
@@ -855,7 +855,7 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 		memcpy(dst, hdr->addr3, ETH_ALEN);
 		memcpy(src, hdr->addr4, ETH_ALEN);
 		break;
-	case 0:
+	default:
 		memcpy(dst, hdr->addr1, ETH_ALEN);
 		memcpy(src, hdr->addr2, ETH_ALEN);
 		break;
diff --git a/net/wireless/lib80211_crypt_tkip.c b/net/wireless/lib80211_crypt_tkip.c
index 71447cf86306..ba0a1f398ce5 100644
--- a/net/wireless/lib80211_crypt_tkip.c
+++ b/net/wireless/lib80211_crypt_tkip.c
@@ -556,7 +556,7 @@ static void michael_mic_hdr(struct sk_buff *skb, u8 * hdr)
 		memcpy(hdr, hdr11->addr3, ETH_ALEN);	/* DA */
 		memcpy(hdr + ETH_ALEN, hdr11->addr4, ETH_ALEN);	/* SA */
 		break;
-	case 0:
+	default:
 		memcpy(hdr, hdr11->addr1, ETH_ALEN);	/* DA */
 		memcpy(hdr + ETH_ALEN, hdr11->addr2, ETH_ALEN);	/* SA */
 		break;
-- 
2.9.0
