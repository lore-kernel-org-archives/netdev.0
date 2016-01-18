From: Marc Zyngier <marc.zyngier@arm.com>
Subject: Re: [GIT] Networking
Date: Mon, 18 Jan 2016 11:30:26 +0000
Message-ID: <569CCCD2.4040105@arm.com>
References: <20160112.215136.850414372508130298.davem@davemloft.net>
 <56978094.4050302@arm.com> <87k2n97n5e.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Arend van Spriel <arend@broadcom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
	Hante Meuleman <meuleman@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:33980 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754767AbcARLa3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jan 2016 06:30:29 -0500
In-Reply-To: <87k2n97n5e.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Kalle,

On 16/01/16 11:57, Kalle Valo wrote:
> Marc Zyngier <marc.zyngier@arm.com> writes:
> 
>> David, Hante,
>>
>> On 13/01/16 02:51, David Miller wrote:
>>
>> [...]
>>
>>> Hante Meuleman (33):
>> [...]
>>>       brcmfmac: Move all module parameters to one place
> 
> As a reminder to myself this is the commit id:
> 
> 7d34b0560567 brcmfmac: Move all module parameters to one place
> 
>> This particular patch breaks one of my boxes in a spectacular way:
>>
>> [    3.602155] Unable to handle kernel paging request at virtual address 000027e4
>> [    3.602160] pgd = c0003000
>> [    3.602169] [000027e4] *pgd=80000040004003, *pmd=00000000
>> [    3.602181] Internal error: Oops: 206 [#1] PREEMPT SMP ARM
> 
> [...]
> 
>> This is caused by this hunk:
>>
>> @@ -890,7 +887,8 @@ static void brcmf_sdiod_sgtable_alloc(struct brcmf_sdio_dev *sdiodev)
>>  	if (!sdiodev->sg_support)
>>  		return;
>>  
>> -	nents = max_t(uint, BRCMF_DEFAULT_RXGLOM_SIZE, brcmf_sdiod_txglomsz);
>> +	nents = max_t(uint, BRCMF_DEFAULT_RXGLOM_SIZE,
>> +		      sdiodev->bus_if->drvr->settings->sdiod_txglomsz);
>>  	nents += (nents >> 4) + 1;
>>  
>>  	WARN_ON(nents > sdiodev->max_segment_count);
>>
>> were drvr->settings is NULL (as the settings allocation seems to be done
>> much later). The fix is not completely obvious to me (probably requires
>> pushing the call to brcmf_mp_device_attach() down into the various bus
>> specific functions). An alternative would be to restore the txglomsz
>> parameter as it was before and not rely on settings being allocated.
> 
> Should we revert the patch or can you Hante fix this? The revert doesn't
> seem to be trivial so I would appreciate if someone could send a patch.

I've worked out a partial revert (see below) that allows my system to
boot, but I'd rather see a proper fix from the maintainer of this code.

Thanks,

	M.

>From 4dcd43e859ebf4453da90de2034c37174bb88d13 Mon Sep 17 00:00:00 2001
From: Marc Zyngier <marc.zyngier@arm.com>
Date: Mon, 18 Jan 2016 11:16:36 +0000
Subject: [PATCH] brcmfmac: Partial revert of module parameter rework

Commit 7d34b0560567 ("brcmfmac: Move all module parameters to one
place") reworked the brcmfmac driver parameters and moved them to
a dynamically allocated structure.

It turns out that at least one parameter (sdiod_txglomsz) is required
before this structure is allocated, leading to a crash.

This patch reverts the handling of that parameter until the maintainer
of this driver can sort it out for good.

Cc: Arend Van Spriel <arend@broadcom.com>
Cc: Hante Meuleman <meuleman@broadcom.com>
Cc: Kalle Valo <kvalo@codeaurora.org>
Signed-off-by: Marc Zyngier <marc.zyngier@arm.com>
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c | 12 +++++++-----
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/common.c |  7 -------
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/common.h |  2 --
 3 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
index 5363739..410a664 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
@@ -47,8 +47,6 @@
 #include "debug.h"
 #include "sdio.h"
 #include "of.h"
-#include "core.h"
-#include "common.h"
 
 #define SDIOH_API_ACCESS_RETRY_LIMIT	2
 
@@ -59,6 +57,7 @@
 /* Maximum milliseconds to wait for F2 to come up */
 #define SDIO_WAIT_F2RDY	3000
 
+#define BRCMF_DEFAULT_TXGLOM_SIZE	32  /* max tx frames in glom chain */
 #define BRCMF_DEFAULT_RXGLOM_SIZE	32  /* max rx frames in glom chain */
 
 struct brcmf_sdiod_freezer {
@@ -69,6 +68,10 @@ struct brcmf_sdiod_freezer {
 	struct completion resumed;
 };
 
+static int brcmf_sdiod_txglomsz = BRCMF_DEFAULT_TXGLOM_SIZE;
+module_param_named(txglomsz, brcmf_sdiod_txglomsz, int, 0);
+MODULE_PARM_DESC(txglomsz, "maximum tx packet chain size [SDIO]");
+
 static irqreturn_t brcmf_sdiod_oob_irqhandler(int irq, void *dev_id)
 {
 	struct brcmf_bus *bus_if = dev_get_drvdata(dev_id);
@@ -887,8 +890,7 @@ static void brcmf_sdiod_sgtable_alloc(struct brcmf_sdio_dev *sdiodev)
 	if (!sdiodev->sg_support)
 		return;
 
-	nents = max_t(uint, BRCMF_DEFAULT_RXGLOM_SIZE,
-		      sdiodev->bus_if->drvr->settings->sdiod_txglomsz);
+	nents = max_t(uint, BRCMF_DEFAULT_RXGLOM_SIZE, brcmf_sdiod_txglomsz);
 	nents += (nents >> 4) + 1;
 
 	WARN_ON(nents > sdiodev->max_segment_count);
@@ -900,7 +902,7 @@ static void brcmf_sdiod_sgtable_alloc(struct brcmf_sdio_dev *sdiodev)
 		sdiodev->sg_support = false;
 	}
 
-	sdiodev->txglomsz = sdiodev->bus_if->drvr->settings->sdiod_txglomsz;
+	sdiodev->txglomsz = brcmf_sdiod_txglomsz;
 }
 
 #ifdef CONFIG_PM_SLEEP
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/common.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/common.c
index 4265b50..1f57c42 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/common.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/common.c
@@ -35,12 +35,6 @@ const u8 ALLFFMAC[ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
 /* boost value for RSSI_DELTA in preferred join selection */
 #define BRCMF_JOIN_PREF_RSSI_BOOST	8
 
-#define BRCMF_DEFAULT_TXGLOM_SIZE	32  /* max tx frames in glom chain */
-
-static int brcmf_sdiod_txglomsz = BRCMF_DEFAULT_TXGLOM_SIZE;
-module_param_named(txglomsz, brcmf_sdiod_txglomsz, int, 0);
-MODULE_PARM_DESC(txglomsz, "Maximum tx packet chain size [SDIO]");
-
 /* Debug level configuration. See debug.h for bits, sysfs modifiable */
 int brcmf_msg_level;
 module_param_named(debug, brcmf_msg_level, int, S_IRUSR | S_IWUSR);
@@ -234,7 +228,6 @@ int brcmf_mp_device_attach(struct brcmf_pub *drvr)
 		return -ENOMEM;
 	}
 
-	drvr->settings->sdiod_txglomsz = brcmf_sdiod_txglomsz;
 	drvr->settings->p2p_enable = !!brcmf_p2p_enable;
 	drvr->settings->feature_disable = brcmf_feature_disable;
 	drvr->settings->fcmode = brcmf_fcmode;
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/common.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/common.h
index 3b0a63b..05ad4b8 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/common.h
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/common.h
@@ -41,7 +41,6 @@ extern struct brcmf_mp_global_t brcmf_mp_global;
 /**
  * struct brcmf_mp_device - Device module paramaters.
  *
- * @sdiod_txglomsz: SDIO txglom size.
  * @joinboost_5g_rssi: 5g rssi booost for preferred join selection.
  * @p2p_enable: Legacy P2P0 enable (old wpa_supplicant).
  * @feature_disable: Feature_disable bitmask.
@@ -49,7 +48,6 @@ extern struct brcmf_mp_global_t brcmf_mp_global;
  * @roamoff: Firmware roaming off?
  */
 struct brcmf_mp_device {
-	int	sdiod_txglomsz;
 	int	joinboost_5g_rssi;
 	bool	p2p_enable;
 	int	feature_disable;
-- 
2.1.4


-- 
Jazz is not dead. It just smells funny...
