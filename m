From: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [GIT] Networking
Date: Mon, 18 Jan 2016 23:05:46 +0100
Message-ID: <569D61BA.8020701@broadcom.com>
References: <20160112.215136.850414372508130298.davem@davemloft.net>
 <56978094.4050302@arm.com> <87k2n97n5e.fsf@kamboji.qca.qualcomm.com>
 <569CCCD2.4040105@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <569CCCD2.4040105-5wv7dgnIgG8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 18-1-2016 12:30, Marc Zyngier wrote:
> Hi Kalle,
> 
> On 16/01/16 11:57, Kalle Valo wrote:
>> Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org> writes:
>>
>>> David, Hante,
>>>
>>> On 13/01/16 02:51, David Miller wrote:
>>>
>>> [...]
>>>
>>>> Hante Meuleman (33):
>>> [...]
>>>>       brcmfmac: Move all module parameters to one place
>>
>> As a reminder to myself this is the commit id:
>>
>> 7d34b0560567 brcmfmac: Move all module parameters to one place
>>
>>> This particular patch breaks one of my boxes in a spectacular way:
>>>
>>> [    3.602155] Unable to handle kernel paging request at virtual address 000027e4
>>> [    3.602160] pgd = c0003000
>>> [    3.602169] [000027e4] *pgd=80000040004003, *pmd=00000000
>>> [    3.602181] Internal error: Oops: 206 [#1] PREEMPT SMP ARM
>>
>> [...]
>>
>>> This is caused by this hunk:
>>>
>>> @@ -890,7 +887,8 @@ static void brcmf_sdiod_sgtable_alloc(struct brcmf_sdio_dev *sdiodev)
>>>  	if (!sdiodev->sg_support)
>>>  		return;
>>>  
>>> -	nents = max_t(uint, BRCMF_DEFAULT_RXGLOM_SIZE, brcmf_sdiod_txglomsz);
>>> +	nents = max_t(uint, BRCMF_DEFAULT_RXGLOM_SIZE,
>>> +		      sdiodev->bus_if->drvr->settings->sdiod_txglomsz);
>>>  	nents += (nents >> 4) + 1;
>>>  
>>>  	WARN_ON(nents > sdiodev->max_segment_count);
>>>
>>> were drvr->settings is NULL (as the settings allocation seems to be done
>>> much later). The fix is not completely obvious to me (probably requires
>>> pushing the call to brcmf_mp_device_attach() down into the various bus
>>> specific functions). An alternative would be to restore the txglomsz
>>> parameter as it was before and not rely on settings being allocated.
>>
>> Should we revert the patch or can you Hante fix this? The revert doesn't
>> seem to be trivial so I would appreciate if someone could send a patch.
> 
> I've worked out a partial revert (see below) that allows my system to
> boot, but I'd rather see a proper fix from the maintainer of this code.

Hi Marc,

Thanks for the patch, but Hante has created a different patch basically
deferring the allocation of the sgtable. Feel free to give it a spin on
your box and share the results. I am looking for a arm64 platform to add
to my test machines so if you can recommend one (with PCIe).

Regards,
Arend

>From f7d015866f24cfad5af0c35b1ab60c567835c5e8 Mon Sep 17 00:00:00 2001
From: Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Date: Mon, 18 Jan 2016 15:19:45 +0100
Subject: [PATCH] brcmfmac: fix sdio sg table alloc crash

With the patch to move all module paramaters to one place a bug was
introduced causing a null pointer exception. This patch fixes the
bug by initializing the sg table till after the settings have been
initialized.

Reviewed-by: Arend Van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Reviewed-by: Franky (Zhenhui) Lin <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Reviewed-by: Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 .../wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c  | 40
++++++++--------------
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |  5 +++
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.h    |  1 +
 3 files changed, 21 insertions(+), 25 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
index 5363739..b98db8a 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
@@ -879,11 +879,24 @@ int brcmf_sdiod_abort(struct brcmf_sdio_dev
*sdiodev, uint fn)
 	return 0;
 }

-static void brcmf_sdiod_sgtable_alloc(struct brcmf_sdio_dev *sdiodev)
+void brcmf_sdiod_sgtable_alloc(struct brcmf_sdio_dev *sdiodev)
 {
+	struct sdio_func *func;
+	struct mmc_host *host;
+	uint max_blocks;
 	uint nents;
 	int err;

+	func = sdiodev->func[2];
+	host = func->card->host;
+	sdiodev->sg_support = host->max_segs > 1;
+	max_blocks = min_t(uint, host->max_blk_count, 511u);
+	sdiodev->max_request_size = min_t(uint, host->max_req_size,
+					  max_blocks * func->cur_blksize);
+	sdiodev->max_segment_count = min_t(uint, host->max_segs,
+					   SG_MAX_SINGLE_ALLOC);
+	sdiodev->max_segment_size = host->max_seg_size;
+
 	if (!sdiodev->sg_support)
 		return;

@@ -1021,9 +1034,6 @@ static void brcmf_sdiod_host_fixup(struct mmc_host
*host)

 static int brcmf_sdiod_probe(struct brcmf_sdio_dev *sdiodev)
 {
-	struct sdio_func *func;
-	struct mmc_host *host;
-	uint max_blocks;
 	int ret = 0;

 	sdiodev->num_funcs = 2;
@@ -1054,26 +1064,6 @@ static int brcmf_sdiod_probe(struct
brcmf_sdio_dev *sdiodev)
 		goto out;
 	}

-	/*
-	 * determine host related variables after brcmf_sdiod_probe()
-	 * as func->cur_blksize is properly set and F2 init has been
-	 * completed successfully.
-	 */
-	func = sdiodev->func[2];
-	host = func->card->host;
-	sdiodev->sg_support = host->max_segs > 1;
-	max_blocks = min_t(uint, host->max_blk_count, 511u);
-	sdiodev->max_request_size = min_t(uint, host->max_req_size,
-					  max_blocks * func->cur_blksize);
-	sdiodev->max_segment_count = min_t(uint, host->max_segs,
-					   SG_MAX_SINGLE_ALLOC);
-	sdiodev->max_segment_size = host->max_seg_size;
-
-	/* allocate scatter-gather table. sg support
-	 * will be disabled upon allocation failure.
-	 */
-	brcmf_sdiod_sgtable_alloc(sdiodev);
-
 	ret = brcmf_sdiod_freezer_attach(sdiodev);
 	if (ret)
 		goto out;
@@ -1084,7 +1074,7 @@ static int brcmf_sdiod_probe(struct brcmf_sdio_dev
*sdiodev)
 		ret = -ENODEV;
 		goto out;
 	}
-	brcmf_sdiod_host_fixup(host);
+	brcmf_sdiod_host_fixup(sdiodev->func[2]->card->host);
 out:
 	if (ret)
 		brcmf_sdiod_remove(sdiodev);
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
index dd66143..a14d9d9d 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
@@ -4114,6 +4114,11 @@ struct brcmf_sdio *brcmf_sdio_probe(struct
brcmf_sdio_dev *sdiodev)
 		goto fail;
 	}

+	/* allocate scatter-gather table. sg support
+	 * will be disabled upon allocation failure.
+	 */
+	brcmf_sdiod_sgtable_alloc(bus->sdiodev);
+
 	/* Query the F2 block size, set roundup accordingly */
 	bus->blocksize = bus->sdiodev->func[2]->cur_blksize;
 	bus->roundup = min(max_roundup, bus->blocksize);
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.h
b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.h
index 5ec7a6d..23f2231 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.h
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.h
@@ -342,6 +342,7 @@ int brcmf_sdiod_ramrw(struct brcmf_sdio_dev
*sdiodev, bool write, u32 address,

 /* Issue an abort to the specified function */
 int brcmf_sdiod_abort(struct brcmf_sdio_dev *sdiodev, uint fn);
+void brcmf_sdiod_sgtable_alloc(struct brcmf_sdio_dev *sdiodev);
 void brcmf_sdiod_change_state(struct brcmf_sdio_dev *sdiodev,
 			      enum brcmf_sdiod_state state);
 #ifdef CONFIG_PM_SLEEP
-- 
1.9.1
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
