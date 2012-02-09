From: Tim Gardner <rtg.canonical@gmail.com>
Subject: Re: [PATCH v3] rtlwifi: rtl8192se firmware load can overflow target
 buffer
Date: Thu, 09 Feb 2012 10:25:50 -0700
Message-ID: <4F34019E.60007@canonical.com>
References: <1328735291-33220-1-git-send-email-tim.gardner@canonical.com> <1328737514.2627.14.camel@bwh-desktop> <4F332FC3.7000808@lwfinger.net> <4F33DAFC.1000502@canonical.com> <4F33F7C8.2090105@lwfinger.net>
Reply-To: tim.gardner@canonical.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020302060405040907050708"
Cc: Tim Gardner <rtg.canonical@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F33F7C8.2090105@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020302060405040907050708
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 02/09/2012 09:43 AM, Larry Finger wrote:
> On 02/09/2012 08:41 AM, Tim Gardner wrote:
>>
>> I agree with you about the semantics of rtlpriv->max_fw_size, but I
>> don't agree
>> that the size check is correct. While rtlpriv->max_fw_size has been
>> set to
>> sizeof(struct rt_firmware), that value is _way_ bigger then the size
>> of the
>> target buffer.
>>
>> sizeof(struct rt_firmware) == 64000+64000+164000 plus some change
>>
>> The target buffer size is only 164000 bytes.
>>
>> I've attached v2 of the patch that is simpler and may serve to better
>> illustrate
>> my point. By the way, Ben Hutchings was right about the original patch
>> having an
>> off by one error. This version also clears rtlpriv->max_fw_size if the
>> size
>> check fails. Probably should have mentioned that in the commit log.
>
> I agree that Ben is right.
>
> This thread forced me to go back to square one in analyzing the
> situation. For the other drivers in the rtlwifi family, the firmware
> file contains an image that is directly stuffed into the device. For the
> RTL8192SE devices, it is more complicated. The structure is described in
> struct rt_firmware. At the moment, the arrays there are grossly
> oversized. They could be as follows:
>
> struct rt_firmware {
> struct fw_hdr *pfwheader;
> enum fw_status fwstatus;
> u16 firmwareversion;
> u8 fw_imem[RTL8190_MAX_IMEM_CODE_SIZE];
> u8 fw_emem[RTL8190_MAX_DMEM_CODE_SIZE];
> u32 fw_imem_len;
> u32 fw_emem_len;
> u8 sz_fw_tmpbuffer[RTL8190_MAX_FIRMWARE_SIZE];
> u32 sz_fw_tmpbufferlen;
> u16 cmdpacket_fragthresold;
> };
>
> with
>
> RTL8190_MAX_IMEM_CODE_SIZE = 54000 (current fw is 51,208),
> RTL8190_MAX_DMEM_CODE_SIZE = 40000 (current fw is 37,520), and
> RTL8190_MAX_FIRMWARE_SIZE = 90000 (it holds the raw firmware image,
> which is currently 88,856).
>
> Ultimately, all three arrays should be eliminated. Now that we are using
> asynchronous loading, the kernel should keep its cached data and not
> copy it into the driver's private storage when a pointer will suffice.
> All the drivers need this change, but that can wait for now.
>
> I will ACK the patch if you resumit it with
> #define RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE 90000
>
> Larry

v3 expands the commit log a bit. It doesn't apply to stable 3.2.y, but 
could easily be backported. If I remember I'll do it when its merged in 
Linus' tree.

rtg
-- 
Tim Gardner tim.gardner@canonical.com

--------------020302060405040907050708
Content-Type: text/x-patch;
 name="0001-rtlwifi-rtl8192se-firmware-load-can-overflow-target-.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-rtlwifi-rtl8192se-firmware-load-can-overflow-target-.pa";
 filename*1="tch"

>From 1c26d8e099c2720aebf106daeb7814114051a596 Mon Sep 17 00:00:00 2001
From: Tim Gardner <tim.gardner@canonical.com>
Date: Wed, 8 Feb 2012 13:11:47 -0700
Subject: [PATCH v3] rtlwifi: rtl8192se firmware load can overflow target buffer

Define RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE which represents the
maximimum possible firmware file size. Use it in the definition
of the buffer which receives the firmware file data.

Set RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE closer to the actual size of
the firmware file, e.g., 90000 (down from hard coded 164000). The current
size of rtlwifi/rtl8192sefw.bin is 88856.

Set max_fw_size to RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE for the size limit
check. Fix the error case where max_fw_size is not cleared if the size
limit check fails.

Cc: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Chaoming Li <chaoming_li@realsil.com.cn>
Cc: John W. Linville <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 drivers/net/wireless/rtlwifi/rtl8192se/fw.h |    3 ++-
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/fw.h b/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
index babe85d..b4afff6 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
@@ -30,6 +30,7 @@
 #define __REALTEK_FIRMWARE92S_H__
 
 #define RTL8190_MAX_FIRMWARE_CODE_SIZE		64000
+#define RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE	90000
 #define RTL8190_CPU_START_OFFSET		0x80
 /* Firmware Local buffer size. 64k */
 #define	MAX_FIRMWARE_CODE_SIZE			0xFF00
@@ -217,7 +218,7 @@ struct rt_firmware {
 	u8 fw_emem[RTL8190_MAX_FIRMWARE_CODE_SIZE];
 	u32 fw_imem_len;
 	u32 fw_emem_len;
-	u8 sz_fw_tmpbuffer[164000];
+	u8 sz_fw_tmpbuffer[RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE];
 	u32 sz_fw_tmpbufferlen;
 	u16 cmdpacket_fragthresold;
 };
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index ca38dd9..345d752 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -108,6 +108,7 @@ static void rtl92se_fw_cb(const struct firmware *firmware, void *context)
 	if (firmware->size > rtlpriv->max_fw_size) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "Firmware is too big!\n");
+		rtlpriv->max_fw_size = 0;
 		release_firmware(firmware);
 		return;
 	}
@@ -232,7 +233,7 @@ static int rtl92s_init_sw_vars(struct ieee80211_hw *hw)
 		return 1;
 	}
 
-	rtlpriv->max_fw_size = sizeof(struct rt_firmware);
+	rtlpriv->max_fw_size = RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE;
 
 	pr_info("Driver for Realtek RTL8192SE/RTL8191SE\n"
 		"Loading firmware %s\n", rtlpriv->cfg->fw_name);
-- 
1.7.9


--------------020302060405040907050708--
