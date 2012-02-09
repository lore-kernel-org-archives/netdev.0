From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: rtl8192se firmware load can overflow target
 buffer
Date: Wed, 08 Feb 2012 20:30:27 -0600
Message-ID: <4F332FC3.7000808@lwfinger.net>
References: <1328735291-33220-1-git-send-email-tim.gardner@canonical.com> <1328737514.2627.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tim Gardner <tim.gardner@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328737514.2627.14.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/08/2012 03:45 PM, Ben Hutchings wrote:
> On Wed, 2012-02-08 at 14:08 -0700, Tim Gardner wrote:
>> The firmware file size check does not use the
>> correct limit.
>>
>> Cc: Larry Finger<Larry.Finger@lwfinger.net>
>> Cc: Chaoming Li<chaoming_li@realsil.com.cn>
>> Cc: John W. Linville<linville@tuxdriver.com>
>> Cc: linux-wireless@vger.kernel.org
>> Cc: netdev@vger.kernel.org
>> Cc: linux-kernel@vger.kernel.org
>> Signed-off-by: Tim Gardner<tim.gardner@canonical.com>
>> ---
>>   drivers/net/wireless/rtlwifi/rtl8192se/fw.h |    3 ++-
>>   drivers/net/wireless/rtlwifi/rtl8192se/sw.c |    2 +-
>>   2 files changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/fw.h b/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
>> index babe85d..5c377fc 100644
>> --- a/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
>> +++ b/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
>> @@ -30,6 +30,7 @@
>>   #define __REALTEK_FIRMWARE92S_H__
>>
>>   #define RTL8190_MAX_FIRMWARE_CODE_SIZE		64000
>> +#define RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE	164000

The current size of the firmware is 88,856, thus the value of 
RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE should be set to 90,000 to allow for some 
growth in the size of the firmware. Using 164,000 wastes a lot of space.

>>   #define RTL8190_CPU_START_OFFSET		0x80
>>   /* Firmware Local buffer size. 64k */
>>   #define	MAX_FIRMWARE_CODE_SIZE			0xFF00
>> @@ -217,7 +218,7 @@ struct rt_firmware {
>>   	u8 fw_emem[RTL8190_MAX_FIRMWARE_CODE_SIZE];
>>   	u32 fw_imem_len;
>>   	u32 fw_emem_len;
>> -	u8 sz_fw_tmpbuffer[164000];
>> +	u8 sz_fw_tmpbuffer[RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE];
>>   	u32 sz_fw_tmpbufferlen;
>>   	u16 cmdpacket_fragthresold;
>>   };
>> diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
>> index ca38dd9..155da0a 100644
>> --- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
>> +++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
>> @@ -105,7 +105,7 @@ static void rtl92se_fw_cb(const struct firmware *firmware, void *context)
>>   		rtlpriv->max_fw_size = 0;
>>   		return;
>>   	}
>> -	if (firmware->size>  rtlpriv->max_fw_size) {
>> +	if (firmware->size>= RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE) {

Do not change this one. rtlpriv->max_fw_size has been set to sizeof(struct 
rt_firmware), which is correct.

>
> This appears to reject a firmware blob which is exactly the maximum
> size, which looks wrong.  Also doesn't this make the max_fw_size field
> redundant?

I commented on this one earlier, but to reiterate - max_fw_size is not redundant.

Larry
