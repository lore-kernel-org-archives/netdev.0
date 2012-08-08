From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] rndis_wlan: Fix potential memory leak in update_pmkid()
Date: Wed,  8 Aug 2012 19:44:21 +0400
Message-ID: <1344440661-32322-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@ispras.ru
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not leak memory by updating pointer with potentially NULL realloc return value.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wireless/rndis_wlan.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 241162e..7a4ae9e 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -1803,6 +1803,7 @@ static struct ndis_80211_pmkid *update_pmkid(struct usbnet *usbdev,
 						struct cfg80211_pmksa *pmksa,
 						int max_pmkids)
 {
+	struct ndis_80211_pmkid *new_pmkids;
 	int i, err, newlen;
 	unsigned int count;
 
@@ -1833,11 +1834,12 @@ static struct ndis_80211_pmkid *update_pmkid(struct usbnet *usbdev,
 	/* add new pmkid */
 	newlen = sizeof(*pmkids) + (count + 1) * sizeof(pmkids->bssid_info[0]);
 
-	pmkids = krealloc(pmkids, newlen, GFP_KERNEL);
-	if (!pmkids) {
+	new_pmkids = krealloc(pmkids, newlen, GFP_KERNEL);
+	if (!new_pmkids) {
 		err = -ENOMEM;
 		goto error;
 	}
+	pmkids = new_pmkids;
 
 	pmkids->length = cpu_to_le32(newlen);
 	pmkids->bssid_info_count = cpu_to_le32(count + 1);
-- 
1.7.9.5
