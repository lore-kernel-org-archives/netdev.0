From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Sun, 25 Dec 2016 21:15:40 +0100
Message-ID: <e728586e-80bf-c9e0-0063-71da4c4aba85@broadcom.com>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
 <1482598381-16513-3-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: =?UTF-8?Q?Pali_Roh=c3=a1r?= <pali.rohar@gmail.com>,
        Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Pavel Machek <pavel@ucw.cz>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Grazvydas Ignotas <notasas@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482598381-16513-3-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24-12-2016 17:52, Pali Rohár wrote:
> NVS calibration data for wl1251 are model specific. Every one device with
> wl1251 chip has different and calibrated in factory.
> 
> Not all wl1251 chips have own EEPROM where are calibration data stored. And
> in that case there is no "standard" place. Every device has stored them on
> different place (some in rootfs file, some in dedicated nand partition,
> some in another proprietary structure).
> 
> Kernel wl1251 driver cannot support every one different storage decided by
> device manufacture so it will use request_firmware_prefer_user() call for
> loading NVS calibration data and userspace helper will be responsible to
> prepare correct data.

Responding to this patch as it provides a lot of context to discuss. As
you might have gathered from earlier discussions I am not a fan of using
user-space helper. I can agree that the kernel driver, wl1251 in this
case, should be agnostic to platform specific details regarding storage
solutions and the firmware api should hide that. However, it seems your
only solution is adding user-space to the mix and changing the api
towards that. Can we solve it without user-space help?

The firmware_class already supports a number of path prefixes it
traverses looking for the requested firmware. So I was thinking about
adding a hashtable in which a platform driver can add firmware which are
stored in the hashtable using the hashed firmware name. Upon a firmware
request from the driver we could check the hashtable before traversing
the path prefixes on VFS. The obvious problem is that the request may
come before the firmware is added to the hashtable. Just wanted to pitch
the idea first and hear what others think about it and maybe someone has
a nice solution for this problem. Fingers crossed :-p

> In case userspace helper fails request_firmware_prefer_user() still try to
> load data file directly from VFS as fallback mechanism.
> 
> On Nokia N900 device which has wl1251 chip, NVS calibration data are stored
> in CAL nand partition. CAL is proprietary Nokia key/value format for nand
> devices.

With the firmware hashtable api on N900 a platform driver could
interpret the CAL data in the nand partition and provide it through the
firmware_class.

> With this patch it is finally possible to load correct model specific NVS
> calibration data for Nokia N900.

But on other devices that use wl1251, but for instance have no userspace
helper the request to userspace will fail (after 60 sec?) and try VFS
after that. Maybe not so nice. You should consider other device
configurations. Not just N900.

Regards,
Arend

> Signed-off-by: Pali Rohár <pali.rohar@gmail.com>
> ---
>  drivers/net/wireless/ti/wl1251/Kconfig |    1 +
>  drivers/net/wireless/ti/wl1251/main.c  |    2 +-
>  2 files changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/ti/wl1251/Kconfig b/drivers/net/wireless/ti/wl1251/Kconfig
> index 7142ccf..affe154 100644
> --- a/drivers/net/wireless/ti/wl1251/Kconfig
> +++ b/drivers/net/wireless/ti/wl1251/Kconfig
> @@ -2,6 +2,7 @@ config WL1251
>  	tristate "TI wl1251 driver support"
>  	depends on MAC80211
>  	select FW_LOADER
> +	select FW_LOADER_USER_HELPER
>  	select CRC7
>  	---help---
>  	  This will enable TI wl1251 driver support. The drivers make
> diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
> index 208f062..24f8866 100644
> --- a/drivers/net/wireless/ti/wl1251/main.c
> +++ b/drivers/net/wireless/ti/wl1251/main.c
> @@ -110,7 +110,7 @@ static int wl1251_fetch_nvs(struct wl1251 *wl)
>  	struct device *dev = wiphy_dev(wl->hw->wiphy);
>  	int ret;
>  
> -	ret = request_firmware(&fw, WL1251_NVS_NAME, dev);
> +	ret = request_firmware_prefer_user(&fw, WL1251_NVS_NAME, dev);
>  
>  	if (ret < 0) {
>  		wl1251_error("could not get nvs file: %d", ret);
> 
