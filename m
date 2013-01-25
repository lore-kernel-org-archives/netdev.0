From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 16/19] mac80211: avoid a build warning
Date: Fri, 25 Jan 2013 14:14:33 +0000
Message-ID: <1359123276-15833-17-git-send-email-arnd@arndb.de>
References: <1359123276-15833-1-git-send-email-arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-arm-kernel@list.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:56757 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932348Ab3AYOPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 09:15:21 -0500
In-Reply-To: <1359123276-15833-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gcc cannot prove that the value of sdata->vif.type does not
change between the switch() statement and the second
comparison to NL80211_IFTYPE_AP, causing a harmless
warning.
Slightly reordering the code makes the warning go away
with no functional change.

Without this patch, building ARM at91sam9g45_defconfig with
gcc-4.6 results in:

net/mac80211/tx.c: In function 'ieee80211_subif_start_xmit':
net/mac80211/tx.c:1797:22: warning: 'chanctx_conf' may be used uninitialized in this function [-Wuninitialized]

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 net/mac80211/tx.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index e9eadc4..df589bf 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1784,16 +1784,16 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 			break;
 		/* fall through */
 	case NL80211_IFTYPE_AP:
+		if (sdata->vif.type == NL80211_IFTYPE_AP)
+			chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
+		if (!chanctx_conf)
+			goto fail_rcu;
 		fc |= cpu_to_le16(IEEE80211_FCTL_FROMDS);
 		/* DA BSSID SA */
 		memcpy(hdr.addr1, skb->data, ETH_ALEN);
 		memcpy(hdr.addr2, sdata->vif.addr, ETH_ALEN);
 		memcpy(hdr.addr3, skb->data + ETH_ALEN, ETH_ALEN);
 		hdrlen = 24;
-		if (sdata->vif.type == NL80211_IFTYPE_AP)
-			chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
-		if (!chanctx_conf)
-			goto fail_rcu;
 		band = chanctx_conf->def.chan->band;
 		break;
 	case NL80211_IFTYPE_WDS:
-- 
1.8.0
