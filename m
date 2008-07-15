From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH] wireless: fix warnings from QoS patch
Date: Tue, 15 Jul 2008 10:09:24 +0200
Message-ID: <1216109364.23746.17.camel@johannes.berg>
References: <20080714192302.GA2541@tuxdriver.com>
	 <20080714.204532.116542087.davem@davemloft.net>
	 (sfid-20080715_054536_698254_D32C0605)  <1216107805.23746.14.camel@johannes.berg>
	 (sfid-20080715_094342_682387_B0174249)
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1216107805.23746.14.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org> (sfid-20080715_094342_682387_B0174249)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When I removed the special "default" meaning from the QoS
parameters, I forgot to update drivers and this lead to
warnings because some drivers were checking for the special
values and putting in defaults. This fixes that by removing
the default special-casing completely.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
 drivers/net/wireless/b43/main.c         |   47 ++++----------------------------
 drivers/net/wireless/rt2x00/rt2x00mac.c |    5 ---
 2 files changed, 8 insertions(+), 44 deletions(-)

--- everything.orig/drivers/net/wireless/b43/main.c	2008-07-15 09:57:06.000000000 +0200
+++ everything/drivers/net/wireless/b43/main.c	2008-07-15 10:01:33.000000000 +0200
@@ -3073,53 +3073,20 @@ static void b43_qos_params_upload(struct
 				  u16 shm_offset)
 {
 	u16 params[B43_NR_QOSPARAMS];
-	int cw_min, cw_max, aifs, bslots, tmp;
+	int bslots, tmp;
 	unsigned int i;
 
-	const u16 aCWmin = 0x0001;
-	const u16 aCWmax = 0x03FF;
-
-	/* Calculate the default values for the parameters, if needed. */
-	switch (shm_offset) {
-	case B43_QOS_VOICE:
-		aifs = (p->aifs == -1) ? 2 : p->aifs;
-		cw_min = (p->cw_min == 0) ? ((aCWmin + 1) / 4 - 1) : p->cw_min;
-		cw_max = (p->cw_max == 0) ? ((aCWmin + 1) / 2 - 1) : p->cw_max;
-		break;
-	case B43_QOS_VIDEO:
-		aifs = (p->aifs == -1) ? 2 : p->aifs;
-		cw_min = (p->cw_min == 0) ? ((aCWmin + 1) / 2 - 1) : p->cw_min;
-		cw_max = (p->cw_max == 0) ? aCWmin : p->cw_max;
-		break;
-	case B43_QOS_BESTEFFORT:
-		aifs = (p->aifs == -1) ? 3 : p->aifs;
-		cw_min = (p->cw_min == 0) ? aCWmin : p->cw_min;
-		cw_max = (p->cw_max == 0) ? aCWmax : p->cw_max;
-		break;
-	case B43_QOS_BACKGROUND:
-		aifs = (p->aifs == -1) ? 7 : p->aifs;
-		cw_min = (p->cw_min == 0) ? aCWmin : p->cw_min;
-		cw_max = (p->cw_max == 0) ? aCWmax : p->cw_max;
-		break;
-	default:
-		B43_WARN_ON(1);
-		return;
-	}
-	if (cw_min <= 0)
-		cw_min = aCWmin;
-	if (cw_max <= 0)
-		cw_max = aCWmin;
-	bslots = b43_read16(dev, B43_MMIO_RNG) % cw_min;
+	bslots = b43_read16(dev, B43_MMIO_RNG) & p->cw_min;
 
 	memset(&params, 0, sizeof(params));
 
 	params[B43_QOSPARAM_TXOP] = p->txop * 32;
-	params[B43_QOSPARAM_CWMIN] = cw_min;
-	params[B43_QOSPARAM_CWMAX] = cw_max;
-	params[B43_QOSPARAM_CWCUR] = cw_min;
-	params[B43_QOSPARAM_AIFS] = aifs;
+	params[B43_QOSPARAM_CWMIN] = p->cw_min;
+	params[B43_QOSPARAM_CWMAX] = p->cw_max;
+	params[B43_QOSPARAM_CWCUR] = p->cw_min;
+	params[B43_QOSPARAM_AIFS] = p->aifs;
 	params[B43_QOSPARAM_BSLOTS] = bslots;
-	params[B43_QOSPARAM_REGGAP] = bslots + aifs;
+	params[B43_QOSPARAM_REGGAP] = bslots + p->aifs;
 
 	for (i = 0; i < ARRAY_SIZE(params); i++) {
 		if (i == B43_QOSPARAM_STATUS) {
--- everything.orig/drivers/net/wireless/rt2x00/rt2x00mac.c	2008-07-15 10:02:02.000000000 +0200
+++ everything/drivers/net/wireless/rt2x00/rt2x00mac.c	2008-07-15 10:02:18.000000000 +0200
@@ -554,10 +554,7 @@ int rt2x00mac_conf_tx(struct ieee80211_h
 	else
 		queue->cw_max = 10; /* cw_min: 2^10 = 1024. */
 
-	if (params->aifs >= 0)
-		queue->aifs = params->aifs;
-	else
-		queue->aifs = 2;
+	queue->aifs = params->aifs;
 
 	INFO(rt2x00dev,
 	     "Configured TX queue %d - CWmin: %d, CWmax: %d, Aifs: %d.\n",


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
