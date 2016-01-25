From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] brcmfmac: sdio: Increase the default timeouts a bit
Date: Mon, 25 Jan 2016 21:07:00 +0100
Message-ID: <56A68064.5020702@broadcom.com>
References: <1453718849-3508-1-git-send-email-sjoerd.simons@collabora.co.uk>
 <56A64114.3010400@gmail.com>
 <CAD=FV=X-ejMLnh30TofU7dKP5WwZaXcgLaQwFs__wo9wHsv53Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Sjoerd Simons <sjoerd.simons@collabora.co.uk>,
	Kalle Valo <kvalo@codeaurora.org>,
	Paul Stewart <pstew@chromium.org>,
	"open list:ARM/Rockchip SoC..." <linux-rockchip@lists.infradead.org>,
	"Pieter-Paul Giesberts" <pieterpg@broadcom.com>,
	<brcm80211-dev-list@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Hante Meuleman <meuleman@broadcom.com>,
	Brett Rudley <brudley@broadcom.com>, <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Adrian Hunter <adrian.hunter@intel.com>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>
To: Doug Anderson <dianders@chromium.org>,
	Arend van Spriel <aspriel@gmail.com>
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <CAD=FV=X-ejMLnh30TofU7dKP5WwZaXcgLaQwFs__wo9wHsv53Q@mail.gmail.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25-1-2016 20:23, Doug Anderson wrote:
> Hi,
> 
> On Mon, Jan 25, 2016 at 7:36 AM, Arend van Spriel <aspriel@gmail.com> wrote:
>> On 25-01-16 11:47, Sjoerd Simons wrote:
>>> On a Radxa Rock2 board with a Ampak AP6335 (Broadcom 4339 core) it seems
>>> the card responds very quickly most of the time, unfortunately during
>>> initialisation it sometimes seems to take just a bit over 2 seconds to
>>> respond.
>>>
>>> This results intialization failing with message like:
>>>   brcmf_c_preinit_dcmds: Retreiving cur_etheraddr failed, -52
>>>   brcmf_bus_start: failed: -52
>>>   brcmf_sdio_firmware_callback: dongle is not responding
>>>
>>> Increasing the timeout to allow for a bit more headroom allows the
>>> card to initialize reliably.
>>
>> I would prefer to know where the 2 second response time comes from.
>> Could be sdio retuning. Maybe the chromeos people can comment whether
>> this has been root caused.

Hi Doug,

Thanks for the elaborate response

> I reviewed Paul's change here
> <https://chromium-review.googlesource.com/#/c/225921/> but didn't do
> any root causing.
> 
> I think that, like Sjoerd saw, we were seeing this problem at boot
> time.  Certainly at boot time lots of things are happening all at the
> same time in the system and there are often delays, so anything that
> might have been close to timing out in the past may now be actually
> timing out.
> 
> This is the kind of thing that, IMHO, should have a real timeout that
> is 10x what was expected and a non-fatal warning whenever we go over
> the expected time.  ...but maybe that's overdesign.  :-P
> 
> Kinda curious: do we get one or two really slow responses on every
> bootup, or just some bootups?  Do we ever succeed even with a slow
> (like 1.8 or 1.9 seconds) response, or is it always either "fast" or
> "2.1" seconds?

Now these are interesting questions that I should have spilled out in
the first place. Thanks.

> In any case, in my experience the Broadcom firmware is fairly
> complicated and has numerous cases where it stretches SDIO more than
> the other SDIO WiFi chip I've worked with.  It wouldn't terribly
> surprise me if there was a period of time during bootup where it was
> non-responsive for 2 seconds.  As unrelated "evidence" showing some of
> the Broadcom SDIO limitations, you can see
> <https://chromium-review.googlesource.com/#/c/250228/> and also the
> fact that Broadcom often holds the SDIO "busy" signal whereas the
> other SDIO WiFi chip I've worked never did that.  Also, even with all
> fixes the Broadcom WiFi module will still show periodic SDIO errors
> that the higher level driver just knows to ignore.

The busy signal is in accordance with the SDIO spec. It would be good to
know if that is what is happening. Unfortunately I do have an SDIO
analyzer, but not reproduced it. May retry on veyron device.

> My old debugging from the (sorry, private) bug
> http://crosbug.com/p/36975 showed this periodically even with all
> known fixes:
> 
> [21310.271635] dwmmc_rockchip ff0d0000.dwmmc: CMD ERR: 0x00000104
> [21550.583598] dwmmc_rockchip ff0d0000.dwmmc: CMD ERR: 0x00000104
> [21550.616035] brcmfmac: brcmf_sdio_readframes: RXHEADER FAILED: -110
> [21550.648460] brcmfmac: brcmf_sdio_rxfail: abort command, terminate
> frame, send NAK
> [21550.683502] dwmmc_rockchip ff0d0000.dwmmc: CMD ERR: 0x00000104
> [21550.691214] dwmmc_rockchip ff0d0000.dwmmc: CMD ERR: 0x00000100
> [22671.121329] dwmmc_rockchip ff0d0000.dwmmc: CMD ERR: 0x00000104
> [22671.153167] dwmmc_rockchip ff0d0000.dwmmc: CMD ERR: 0x01000104
> [22671.184581] brcmfmac: brcmf_sdio_readframes: RXHEADER FAILED: -110
> [22671.192600] brcmfmac: brcmf_sdio_rxfail: abort command, terminate
> frame, send NAK
> [22671.201929] dwmmc_rockchip ff0d0000.dwmmc: CMD ERR: 0x00000114
> [22671.209536] dwmmc_rockchip ff0d0000.dwmmc: CMD ERR: 0x00000100
> [28463.941736] dwmmc_rockchip ff0d0000.dwmmc: CMD ERR: 0x00000104
> 
> At the time dekim@ responded:
> 
>> There are several sleep/wake control at different level. The one we're talking
>> about here is controlled by brcmf_sdio_bus_sleep() in the host driver to turn
>> on/off bus core on the chip. There can be a period of time when chip is not
>> paying attention to the host command (cmd52 to the
>> SBSDIO_FUNC1_SLEEPCSR).
> 
> ...and we decided that the periodic SDIO errors weren't causing any
> huge problems (since they were retried).  As far as I know, they still
> happen today.

Were these true periodic errors or random at interval.

> 
> All of the above may not help you, but it serves as evidence that the
> SDIO communication to Broadcom isn't terribly amazing and apparently
> that's just the way that the module (or perhaps its firmware) is
> designed.  It doesn't seem to affect anything in the real world, so I
> suppose it is just something we need to live with.
> 
> 
> Obviously if you have access to the firmware source code and can debug
> further, that would be awesome.  I'm just not hopeful.

I have, but that does not get my hopes up either. The issue may just as
well be in backplane access during boot and then we are talking VHDL.

> In any case:
> 
> Reviewed-by: Douglas Anderson <dianders@chromium.org>

Thanks again ;-)

Regards,
Arend
