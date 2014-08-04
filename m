From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] brcmfmac: prevent watchdog from interfering with scanning
 and connecting
Date: Mon, 4 Aug 2014 19:29:04 +0200
Message-ID: <53DFC2E0.1040202@broadcom.com>
References: <539E8559.3010601@linux.intel.com> <539EA79C.7010206@broadcom.com> <53A30F96.3010206@linux.intel.com> <53A311E4.301@broadcom.com> <53CCC44C.2070507@linux.intel.com> <53D124B3.7030807@linux.intel.com> <53DFB6A1.7040900@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <brudley@broadcom.com>, Franky Lin <frankyl@broadcom.com>,
	<meuleman@broadcom.com>, <linville@tuxdriver.com>,
	<pieterpg@broadcom.com>, <dekim@broadcom.com>,
	<mcgrof@do-not-panic.com>, <antonio@open-mesh.com>,
	<johannes.berg@intel.com>, <linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-mmc@vger.kernel.org>,
	Russell King <linux@arm.linux.org.uk>
To: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:1106 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753968AbaHDR3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 13:29:09 -0400
In-Reply-To: <53DFB6A1.7040900@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/04/14 18:36, Fu, Zhonghui wrote:
>
> On 2014/7/24 23:22, Fu, Zhonghui wrote:
>> On 2014/7/21 15:42, Fu, Zhonghui wrote:
>>> On 2014/6/20 0:37, Arend van Spriel wrote:
>>>> On 19-06-14 18:28, Fu, Zhonghui wrote:
>>>>> On 2014/6/16 16:15, Arend van Spriel wrote:
>>>>>> On 16-06-14 07:49, Fu, Zhonghui wrote:
>>>>>>>     From 14485894add32aedacb3e486ebb2cc2b73861abf Mon Sep 17 00:00:00 2001
>>>>>>> From: Fu zhonghui<zhonghui.fu@linux.intel.com>
>>>>>>> Date: Wed, 11 Jun 2014 11:06:55 +0800
>>>>>>> Subject: [PATCH] brcmfmac: prevent watchdog from interfering with scanning and connecting
>>>>>>>
>>>>>>> Watchdog in brcmfmac driver may make WiFi chip enter sleep mode
>>>>>>> before completion of scanning or connecting.
>>>>>>>
>>>>>>> This will lead to scanning or connecting failure.
>>>>>>>
>>>>>>> Increasing temporarily idle-time threshold during scanning or
>>>>>>> connecting can ensure scanning or connecting success without
>>>>>>> watchdog interference.
>>>>>> Are you sure you are not having runtime PM enabled. That could be your problem as the host controller code disables sdio irqs. Please see this thread [1]. For our device runtime pm should not be enabled, but I am not sure if that is taken into account in mmc_attach_sdio() (see code below).
>>>>> I have tried brcmfmac driver with "CONFIG_PM_RUNTIME is not set", and scanning and connecting  always succeeded. This means that CONFIG_PM_RUNTIME should not be set if we use SDIO WiFi device driven by brcmfmac driver, right?
>>>> Depends which kernel you are using. In 3.16-rc1 the sdio interrupt issue has been fixed so you should be fine to use CONFIG_PM_RUNTIME. Here is the commit
>
> Hi, Arend
>
> I investigated this issue, and its root cause is still that sdio controller can't receive interrupts from WiFi chip on sdio bus when sdio controller is in runtime suspend status. I am running 3.16-rc5 linux kernel on ASUS T100TA tablet, and using sdhci-acpi driver.

Thanks, Zhonghui

Given that the patches Russell made were covering sdhci (as far as I 
recall) your issue may be specific to the sdhci-acpi driver. In 
sdhci_acpi_probe() it is enabled by use_runtime_pm field in private data:

c->use_runtime_pm = sdhci_acpi_flag(c, SDHCI_ACPI_RUNTIME_PM);

Regards,
Arend

> Thanks,
> Zhonghui
>> Any clues or comments to the following issue?
>>> I run 3.16-rc4 and 3.16-rc5 kernel with CONFIG_PM_RUNTIME set, the issue still exists as follows:
>>>
>>> 1 step: modprobe brcmfmac
>>> 2 step: iwlist wlan1 scan         get scanning result successfully.
>>> 3 step: wait a while, no any operation
>>> 4 step: iwlist wlan1 scan         scanning timeout, can't get scanning result.
>>>
>>>
>>> Thanks,
>>> Zhonghui
>>>
>>>> commit be138554a7923658ded799b0e8794d9c1d08a6e5
>>>> Author: Russell King<rmk+kernel@arm.linux.org.uk>
>>>> Date:   Fri Apr 25 12:55:56 2014 +0100
>>>>
>>>>      mmc: sdhci: allow sdio interrupts while sdhci runtime suspended
>>>>
>>>> Regards,
>>>> Arend
>>>>
>>>>> Thanks,
>>>>> Zhonghui
>>>>>> Gr. AvS
>>>>>>
>>>>>> [1] http://www.spinics.net/lists/linux-mmc/msg25978.html
>>>>>>
>>>>>> --8<----------------------------------------------------------------
>>>>>>
>>>>>>       /*
>>>>>>        * Enable runtime PM only if supported by host+card+board
>>>>>>        */
>>>>>>       if (host->caps&  MMC_CAP_POWER_OFF_CARD) {
>>>>>>           /*
>>>>>>            * Let runtime PM core know our card is active
>>>>>>            */
>>>>>>           err = pm_runtime_set_active(&card->dev);
>>>>>>           if (err)
>>>>>>               goto remove;
>>>>>>
>>>>>>           /*
>>>>>>            * Enable runtime PM for this card
>>>>>>            */
>>>>>>           pm_runtime_enable(&card->dev);
>>>>>>       }
>>>>>>
>>>>>>> Signed-off-by: Fu zhonghui<zhonghui.fu@linux.intel.com>
>>>>>>> ---
>>>>>>>     drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |   18 ++++++++++++++++--
>>>>>>>     .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |    3 ++-
>>>>>>>     2 files changed, 18 insertions(+), 3 deletions(-)
>>>>>>>
>>>>>>> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
>>>>>>> index 13c89a0..729deab 100644
>>>>>>> --- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
>>>>>>> +++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
>>>>>>> @@ -34,6 +34,7 @@
>>>>>>>     #include<linux/vmalloc.h>
>>>>>>>     #include<linux/platform_data/brcmfmac-sdio.h>
>>>>>>>     #include<linux/moduleparam.h>
>>>>>>> +#include<net/cfg80211.h>
>>>>>>>     #include<asm/unaligned.h>
>>>>>>>     #include<defs.h>
>>>>>>>     #include<brcmu_wifi.h>
>>>>>>> @@ -43,6 +44,10 @@
>>>>>>>     #include "sdio_host.h"
>>>>>>>     #include "chip.h"
>>>>>>>     #include "nvram.h"
>>>>>>> +#include "dhd.h"
>>>>>>> +#include "fwil_types.h"
>>>>>>> +#include "p2p.h"
>>>>>>> +#include "wl_cfg80211.h"
>>>>>>>
>>>>>>>     #define DCMD_RESP_TIMEOUT  2000    /* In milli second */
>>>>>>>
>>>>>>> @@ -307,6 +312,7 @@ struct rte_console {
>>>>>>>                          * when idle
>>>>>>>                          */
>>>>>>>     #define BRCMF_IDLE_INTERVAL    1
>>>>>>> +#define BRCMF_IDLE_INTERVAL_SCANNING_CONNECTING    100
>>>>>>>
>>>>>>>     #define KSO_WAIT_US 50
>>>>>>>     #define MAX_KSO_ATTEMPTS (PMU_MAX_TRANSITION_DLY/KSO_WAIT_US)
>>>>>>> @@ -3613,9 +3619,9 @@ void brcmf_sdio_isr(struct brcmf_sdio *bus)
>>>>>>>
>>>>>>>     static bool brcmf_sdio_bus_watchdog(struct brcmf_sdio *bus)
>>>>>>>     {
>>>>>>> -#ifdef DEBUG
>>>>>>>         struct brcmf_bus *bus_if = dev_get_drvdata(bus->sdiodev->dev);
>>>>>>> -#endif    /* DEBUG */
>>>>>>> +    struct brcmf_cfg80211_info *cfg = bus_if->drvr->config;
>>>>>>> +    struct brcmf_if *ifp = cfg->pub->iflist[0];
>>>>>>>
>>>>>>>         brcmf_dbg(TIMER, "Enter\n");
>>>>>>>
>>>>>>> @@ -3678,6 +3684,14 @@ static bool brcmf_sdio_bus_watchdog(struct brcmf_sdio *bus)
>>>>>>>
>>>>>>>         /* On idle timeout clear activity flag and/or turn off clock */
>>>>>>>         if ((bus->idletime>  0)&&  (bus->clkstate == CLK_AVAIL)) {
>>>>>>> +
>>>>>>> +        if (test_bit(BRCMF_SCAN_STATUS_BUSY,&cfg->scan_status) ||
>>>>>>> +            test_bit(BRCMF_VIF_STATUS_CONNECTING,&ifp->vif->sme_state)) {
>>>>>>> +            bus->idletime = BRCMF_IDLE_INTERVAL_SCANNING_CONNECTING;
>>>>>>> +        } else {
>>>>>>> +            bus->idletime = BRCMF_IDLE_INTERVAL;
>>>>>>> +        }
>>>>>>> +
>>>>>>>             if (++bus->idlecount>= bus->idletime) {
>>>>>>>                 bus->idlecount = 0;
>>>>>>>                 if (bus->activity) {
>>>>>>> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
>>>>>>> index be19852..e76517e 100644
>>>>>>> --- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
>>>>>>> +++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
>>>>>>> @@ -913,6 +913,8 @@ brcmf_cfg80211_escan(struct wiphy *wiphy, struct brcmf_cfg80211_vif *vif,
>>>>>>>             return -EAGAIN;
>>>>>>>         }
>>>>>>>
>>>>>>> +    set_bit(BRCMF_SCAN_STATUS_BUSY,&cfg->scan_status);
>>>>>>> +
>>>>>>>         /* If scan req comes for p2p0, send it over primary I/F */
>>>>>>>         if (vif == cfg->p2p.bss_idx[P2PAPI_BSSCFG_DEVICE].vif)
>>>>>>>             vif = cfg->p2p.bss_idx[P2PAPI_BSSCFG_PRIMARY].vif;
>>>>>>> @@ -933,7 +935,6 @@ brcmf_cfg80211_escan(struct wiphy *wiphy, struct brcmf_cfg80211_vif *vif,
>>>>>>>         }
>>>>>>>
>>>>>>>         cfg->scan_request = request;
>>>>>>> -    set_bit(BRCMF_SCAN_STATUS_BUSY,&cfg->scan_status);
>>>>>>>         if (escan_req) {
>>>>>>>             cfg->escan_info.run = brcmf_run_escan;
>>>>>>>             err = brcmf_p2p_scan_prep(wiphy, request, vif);
>>>>>>> -- 1.7.1
>>>>>>>
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>> Please read the FAQ at  http://www.tux.org/lkml/
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>> Please read the FAQ at  http://www.tux.org/lkml/
>
