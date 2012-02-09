From: Tim Gardner <rtg.canonical@gmail.com>
Subject: Re: [PATCH] rtlwifi: rtl8192se firmware load can overflow target
 buffer
Date: Thu, 09 Feb 2012 07:41:00 -0700
Message-ID: <4F33DAFC.1000502@canonical.com>
References: <1328735291-33220-1-git-send-email-tim.gardner@canonical.com> <1328737514.2627.14.camel@bwh-desktop> <4F332FC3.7000808@lwfinger.net>
Reply-To: tim.gardner@canonical.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070605040103040009080109"
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F332FC3.7000808@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070605040103040009080109
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 02/08/2012 07:30 PM, Larry Finger wrote:
> On 02/08/2012 03:45 PM, Ben Hutchings wrote:
>> On Wed, 2012-02-08 at 14:08 -0700, Tim Gardner wrote:
>>> The firmware file size check does not use the
>>> correct limit.
>>>
>>> Cc: Larry Finger<Larry.Finger@lwfinger.net>
>>> Cc: Chaoming Li<chaoming_li@realsil.com.cn>
>>> Cc: John W. Linville<linville@tuxdriver.com>
>>> Cc: linux-wireless@vger.kernel.org
>>> Cc: netdev@vger.kernel.org
>>> Cc: linux-kernel@vger.kernel.org
>>> Signed-off-by: Tim Gardner<tim.gardner@canonical.com>
>>> ---
>>> drivers/net/wireless/rtlwifi/rtl8192se/fw.h | 3 ++-
>>> drivers/net/wireless/rtlwifi/rtl8192se/sw.c | 2 +-
>>> 2 files changed, 3 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
>>> b/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
>>> index babe85d..5c377fc 100644
>>> --- a/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
>>> +++ b/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
>>> @@ -30,6 +30,7 @@
>>> #define __REALTEK_FIRMWARE92S_H__
>>>
>>> #define RTL8190_MAX_FIRMWARE_CODE_SIZE 64000
>>> +#define RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE 164000
>
> The current size of the firmware is 88,856, thus the value of
> RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE should be set to 90,000 to allow for
> some growth in the size of the firmware. Using 164,000 wastes a lot of
> space.
>
>>> #define RTL8190_CPU_START_OFFSET 0x80
>>> /* Firmware Local buffer size. 64k */
>>> #define MAX_FIRMWARE_CODE_SIZE 0xFF00
>>> @@ -217,7 +218,7 @@ struct rt_firmware {
>>> u8 fw_emem[RTL8190_MAX_FIRMWARE_CODE_SIZE];
>>> u32 fw_imem_len;
>>> u32 fw_emem_len;
>>> - u8 sz_fw_tmpbuffer[164000];
>>> + u8 sz_fw_tmpbuffer[RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE];
>>> u32 sz_fw_tmpbufferlen;
>>> u16 cmdpacket_fragthresold;
>>> };
>>> diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
>>> b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
>>> index ca38dd9..155da0a 100644
>>> --- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
>>> +++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
>>> @@ -105,7 +105,7 @@ static void rtl92se_fw_cb(const struct firmware
>>> *firmware, void *context)
>>> rtlpriv->max_fw_size = 0;
>>> return;
>>> }
>>> - if (firmware->size> rtlpriv->max_fw_size) {
>>> + if (firmware->size>= RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE) {
>
> Do not change this one. rtlpriv->max_fw_size has been set to
> sizeof(struct rt_firmware), which is correct.
>
>>
>> This appears to reject a firmware blob which is exactly the maximum
>> size, which looks wrong. Also doesn't this make the max_fw_size field
>> redundant?
>
> I commented on this one earlier, but to reiterate - max_fw_size is not
> redundant.
>
> Larry

I agree with you about the semantics of rtlpriv->max_fw_size, but I 
don't agree that the size check is correct. While rtlpriv->max_fw_size 
has been set to sizeof(struct rt_firmware), that value is _way_ bigger 
then the size of the target buffer.

sizeof(struct rt_firmware) == 64000+64000+164000 plus some change

The target buffer size is only 164000 bytes.

I've attached v2 of the patch that is simpler and may serve to better 
illustrate my point. By the way, Ben Hutchings was right about the 
original patch having an off by one error. This version also clears 
rtlpriv->max_fw_size if the size check fails. Probably should have 
mentioned that in the commit log.

rtg
-- 
Tim Gardner tim.gardner@canonical.com

--------------070605040103040009080109
Content-Type: text/x-patch;
 name="0001-rtlwifi-rtl8192se-firmware-load-can-overflow-target-.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-rtlwifi-rtl8192se-firmware-load-can-overflow-target-.pa";
 filename*1="tch"

>From 1312472fb7b9526c3a3197572c7ba482d6c196a0 Mon Sep 17 00:00:00 2001
From: Tim Gardner <tim.gardner@canonical.com>
Date: Wed, 8 Feb 2012 13:11:47 -0700
Subject: [PATCH v2] rtlwifi: rtl8192se firmware load can overflow target buffer

The firmware file size check does not use the
correct limit.

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
index babe85d..5c377fc 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
@@ -30,6 +30,7 @@
 #define __REALTEK_FIRMWARE92S_H__
 
 #define RTL8190_MAX_FIRMWARE_CODE_SIZE		64000
+#define RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE	164000
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


--------------070605040103040009080109--
