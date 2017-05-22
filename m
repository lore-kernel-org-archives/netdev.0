From: Franky Lin <franky.lin@broadcom.com>
Subject: Re: brcmfmac firmware issue on NanoPi K2
Date: Mon, 22 May 2017 14:39:13 -0700
Message-ID: <CA+8PC_c1YYMif-+2wY8zVMDJ3zthj2LcraDJqEyDObj=C4MqWw@mail.gmail.com>
References: <ab713116-ab12-5f87-1ecf-cae2e0d68b93@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless@vger.kernel.org,
        "open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
        <brcm80211-dev-list.pdl@broadcom.com>, netdev@vger.kernel.org,
        technicalsupport <techsupport@friendlyarm.com>,
        Arend Van Spriel <arend.vanspriel@broadcom.com>,
        linux-amlogic <linux-amlogic@lists.infradead.org>
To: =?UTF-8?Q?Andreas_F=C3=A4rber?= <afaerber@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f182.google.com ([209.85.213.182]:36382 "EHLO
        mail-yb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933917AbdEVVje (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 17:39:34 -0400
Received: by mail-yb0-f182.google.com with SMTP id 130so15531757ybl.3
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 14:39:34 -0700 (PDT)
In-Reply-To: <ab713116-ab12-5f87-1ecf-cae2e0d68b93@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andreas,

On Sun, May 21, 2017 at 9:20 AM, Andreas F=C3=A4rber <afaerber@suse.de> wro=
te:
> Hello,
>
> The NanoPi K2 has an Ampak AP6212 SDIO module. brcmfmac driver loads
> brcmfmac43430-sdio.bin.
>
> When using the firmware file from linux-firmware.git that openSUSE ships
> I get the following errors on 4.11.0 and next-20170519:
>
> [ 2103.618716] brcmfmac: brcmf_sdio_htclk: HT Avail timeout (1000000):
> clkctl 0x50
> [ 2104.668746] brcmfmac: brcmf_sdio_htclk: HT Avail timeout (1000000):
> clkctl 0x50
> [ 2105.678677] brcmfmac: brcmf_sdio_htclk: HT Avail timeout (1000000):
> clkctl 0x50
>
> If I overwrite /lib/firmware/brcm/bcm43430-sdio.bin with
> fw_bcm43438a0.bin from FriendlyARM's Android repository it suddenly works=
:
>
> [  +0.157738] brcmfmac: brcmf_c_preinit_dcmds: Firmware version =3D wl0:
> Jun  6 2014 14:50:39 version 7.10.226.49 (r) FWID 01-8962686a
> [  +0.160108] brcmfmac: brcmf_cfg80211_reg_notifier: not a ISO3166 code
> (0x30 0x30)
>
> I recall using the linux-firmware.git brcmfmac43430-sdio.bin file
> successfully on the Raspberry Pi 3 with a downstream (Leap 42.2) kernel.
>
> I've tested both nvram_ap6212.txt and nvram_ap6212a.txt, the latter has
> the following diff to nvram.txt:
>
> --- nvram_ap6212.txt    2017-05-21 04:24:40.372113426 +0200
> +++ nvram_ap6212a.txt   2017-05-21 04:24:49.852116599 +0200
> @@ -1,4 +1,4 @@
> -#AP6212_NVRAM_V1.0_20140603
> +#AP6212_NVRAM_V1.0.1_20160606
>  # 2.4 GHz, 20 MHz BW mode
>
>  # The following parameter values are just placeholders, need to be updat=
ed.
> @@ -51,4 +51,4 @@
>  muxenab=3D0x10
>  # CLDO PWM voltage settings - 0x4 - 1.1 volt
>  #cldo_pwm=3D0x4
> -
> +glitch_based_crsmin=3D1
>
> https://github.com/friendlyarm/android_hardware_amlogic_wifi/tree/l-amlog=
ic-gx-sync/bcm_ampak/config/6212
>
> * Does the linux-firmware.git brcmfmac43430-sdio.bin need a fix for AP621=
2?
> https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.g=
it/tree/brcm
>
> * Does the brcmfmac driver need to distinguish revisions in sdio.c as
> done for 43241, plus a separate firmware file?
>         BRCMF_FW_NVRAM_ENTRY(BRCM_CC_43430_CHIP_ID, 0xFFFFFFFF, 43430),

It seems we are dealing with different revisions of 43430. The
firmware file you pointed to is for 43430a0 and raspberry pi 3 is
using 43430a1. So yes brcmfmac needs to load different firmware and
nvram for them just like 43241.

Could you please help try the attached patch? I don't have the
hardware to test it. Please rename the 43438 firmware and nvram to
brcmfmac43430a0-sdio.bin/txt.

Thanks,
Franky

---

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
index a999f95..1b12ccb 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
@@ -608,6 +608,7 @@ BRCMF_FW_NVRAM_DEF(43340,
"brcmfmac43340-sdio.bin", "brcmfmac43340-sdio.txt");
 BRCMF_FW_NVRAM_DEF(4335, "brcmfmac4335-sdio.bin", "brcmfmac4335-sdio.txt")=
;
 BRCMF_FW_NVRAM_DEF(43362, "brcmfmac43362-sdio.bin", "brcmfmac43362-sdio.tx=
t");
 BRCMF_FW_NVRAM_DEF(4339, "brcmfmac4339-sdio.bin", "brcmfmac4339-sdio.txt")=
;
+BRCMF_FW_NVRAM_DEF(43430A0, "brcmfmac43430a0-sdio.bin",
"brcmfmac43430a0-sdio.txt");
 BRCMF_FW_NVRAM_DEF(43430, "brcmfmac43430-sdio.bin", "brcmfmac43430-sdio.tx=
t");
 BRCMF_FW_NVRAM_DEF(43455, "brcmfmac43455-sdio.bin", "brcmfmac43455-sdio.tx=
t");
 BRCMF_FW_NVRAM_DEF(4354, "brcmfmac4354-sdio.bin", "brcmfmac4354-sdio.txt")=
;
@@ -626,7 +627,8 @@ static struct brcmf_firmware_mapping
brcmf_sdio_fwnames[] =3D {
  BRCMF_FW_NVRAM_ENTRY(BRCM_CC_4335_CHIP_ID, 0xFFFFFFFF, 4335),
  BRCMF_FW_NVRAM_ENTRY(BRCM_CC_43362_CHIP_ID, 0xFFFFFFFE, 43362),
  BRCMF_FW_NVRAM_ENTRY(BRCM_CC_4339_CHIP_ID, 0xFFFFFFFF, 4339),
- BRCMF_FW_NVRAM_ENTRY(BRCM_CC_43430_CHIP_ID, 0xFFFFFFFF, 43430),
+ BRCMF_FW_NVRAM_ENTRY(BRCM_CC_43430_CHIP_ID, 0x00000001, 43430A0),
+ BRCMF_FW_NVRAM_ENTRY(BRCM_CC_43430_CHIP_ID, 0xFFFFFFFE, 43430),
  BRCMF_FW_NVRAM_ENTRY(BRCM_CC_4345_CHIP_ID, 0xFFFFFFC0, 43455),
  BRCMF_FW_NVRAM_ENTRY(BRCM_CC_4354_CHIP_ID, 0xFFFFFFFF, 4354),
  BRCMF_FW_NVRAM_ENTRY(BRCM_CC_4356_CHIP_ID, 0xFFFFFFFF, 4356)
