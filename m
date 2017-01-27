From: Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar@gmail.com>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Fri, 27 Jan 2017 11:34:08 +0100
Message-ID: <20170127103408.GG24223@pali>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
 <1482598381-16513-3-git-send-email-pali.rohar@gmail.com>
 <87tw8lnei3.fsf@codeaurora.org>
 <20170127094342.GC24223@pali>
 <def4c357-64c0-0681-a5d5-f49a6cb84a92@broadcom.com>
 <20170127101043.GD24223@pali>
 <f60cf2c0-bc1e-3a5f-991c-dc6c95a656af@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Kalle Valo <kvalo@codeaurora.org>,
        Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Pavel Machek <pavel@ucw.cz>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: Arend Van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f60cf2c0-bc1e-3a5f-991c-dc6c95a656af@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 27 January 2017 11:19:25 Arend Van Spriel wrote:
> On 27-1-2017 11:10, Pali Rohár wrote:
> > On Friday 27 January 2017 11:05:32 Arend Van Spriel wrote:
> >> On 27-1-2017 10:43, Pali Rohár wrote:
> >>> On Friday 27 January 2017 09:33:40 Kalle Valo wrote:
> >>>> Pali Rohár <pali.rohar@gmail.com> writes:
> >>>>
> >>>>> NVS calibration data for wl1251 are model specific. Every one device with
> >>>>> wl1251 chip has different and calibrated in factory.
> >>>>>
> >>>>> Not all wl1251 chips have own EEPROM where are calibration data stored. And
> >>>>> in that case there is no "standard" place. Every device has stored them on
> >>>>> different place (some in rootfs file, some in dedicated nand partition,
> >>>>> some in another proprietary structure).
> >>>>>
> >>>>> Kernel wl1251 driver cannot support every one different storage decided by
> >>>>> device manufacture so it will use request_firmware_prefer_user() call for
> >>>>> loading NVS calibration data and userspace helper will be responsible to
> >>>>> prepare correct data.
> >>>>>
> >>>>> In case userspace helper fails request_firmware_prefer_user() still try to
> >>>>> load data file directly from VFS as fallback mechanism.
> >>>>>
> >>>>> On Nokia N900 device which has wl1251 chip, NVS calibration data are stored
> >>>>> in CAL nand partition. CAL is proprietary Nokia key/value format for nand
> >>>>> devices.
> >>>>>
> >>>>> With this patch it is finally possible to load correct model specific NVS
> >>>>> calibration data for Nokia N900.
> >>>>>
> >>>>> Signed-off-by: Pali Rohár <pali.rohar@gmail.com>
> >>>>> ---
> >>>>>  drivers/net/wireless/ti/wl1251/Kconfig |    1 +
> >>>>>  drivers/net/wireless/ti/wl1251/main.c  |    2 +-
> >>>>>  2 files changed, 2 insertions(+), 1 deletion(-)
> >>>>>
> >>>>> diff --git a/drivers/net/wireless/ti/wl1251/Kconfig b/drivers/net/wireless/ti/wl1251/Kconfig
> >>>>> index 7142ccf..affe154 100644
> >>>>> --- a/drivers/net/wireless/ti/wl1251/Kconfig
> >>>>> +++ b/drivers/net/wireless/ti/wl1251/Kconfig
> >>>>> @@ -2,6 +2,7 @@ config WL1251
> >>>>>  	tristate "TI wl1251 driver support"
> >>>>>  	depends on MAC80211
> >>>>>  	select FW_LOADER
> >>>>> +	select FW_LOADER_USER_HELPER
> >>>>>  	select CRC7
> >>>>>  	---help---
> >>>>>  	  This will enable TI wl1251 driver support. The drivers make
> >>>>> diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
> >>>>> index 208f062..24f8866 100644
> >>>>> --- a/drivers/net/wireless/ti/wl1251/main.c
> >>>>> +++ b/drivers/net/wireless/ti/wl1251/main.c
> >>>>> @@ -110,7 +110,7 @@ static int wl1251_fetch_nvs(struct wl1251 *wl)
> >>>>>  	struct device *dev = wiphy_dev(wl->hw->wiphy);
> >>>>>  	int ret;
> >>>>>  
> >>>>> -	ret = request_firmware(&fw, WL1251_NVS_NAME, dev);
> >>>>> +	ret = request_firmware_prefer_user(&fw, WL1251_NVS_NAME, dev);
> >>>>
> >>>> I don't see the need for this. Just remove the default nvs file from
> >>>> filesystem and the fallback user helper will be always used, right?
> >>>
> >>> It is part of linux-firmware repository. And already part of all
> >>> previous versions of linux-firmware packages in lot of linux
> >>> distributions. So removing it is not possible...
> >>
> >> You are probably saying that on your platform you can not remove
> >> anything from /lib/firmware, right? I don't see how you come from "it is
> >> part of firmware package" to "removing is not possible". Trying to
> >> understand this and it makes no sense.
> > 
> > It is already in linux distribution packages. If I remove that file from
> > file system it will be placed there again by package management or it it
> > will throw error message about system integrity (missing file, etc...).
> > 
> > Also that file is already in linux-firmware git and so is propagated to
> > /lib/firmware by anybody who is using linux-firmware.
> > 
> >>>> Like we discussed earlier, the default nvs file should not be used by
> >>>> normal users.
> >>>
> >>> But already is and we need to deal with this fact.
> >>
> >> Why?
> > 
> > Because everybody has already installed it.
> > 
> >> Are there other platforms that use the default nvs file and have a
> >> working wifi.
> > 
> > I do not know.
> > 
> >> So your "removing is not possible" would be about
> >> regression for those?
> > 
> > Yes, that is possible.
> > 
> > Also you can use wifi on Nokia N900 with this default file. Yes it is
> > not recommended and probably has performance problems... but more people
> > use it for SSH and it is working. Pavel could confirm this.
> > 
> > So yes, if you remove that file *now* there is regression for Nokia N900
> > when you are using SSH over wifi.
> 
> So you are changing the behavior for all platforms using wl1251, but the
> user-helper preference is (probably) only applicable for N900, right?

No. Some wl1251 chips have internal EEPROM where is stored MAC address
and NVS data. And kernel driver already can read it. So this change is
only for platforms without internal EEPROM.

And all platforms without internal EEPROM should use userspace helper to
provide correct NVS data (and ideally also MAC address).

Except Nokia N900 I know just Pandora who has also wl1251 chip. But
Pandora has EEPROM.

Grepping linux source code... and I see only defines for Nokia N900 and
Pandora. There can be also another user with external DTS file, but what
is reality? Is there still really any other user of wl1251 chip with
upstream kernel? If yes, we can prepare userspace helper if he does not
have NVS stored in EEPROM...

> So
> for those other platforms there will be a delay waiting for user-mode
> helper to fail, before trying to get nvs file from /lib/firmware.

Yes, there will be. But there is no easy way to fix this problem that
kernel is trying to use default/example NVS data...

When helper is not available this patch just adds delay, but
functionality is still there and same. With helper support will be
finally fixed.

And I have no idea if those default NVS data are somehow usable on other
platforms...

-- 
Pali Rohár
pali.rohar@gmail.com
