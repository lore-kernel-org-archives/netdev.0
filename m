From: Doug Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] brcmfmac: sdio: Increase the default timeouts a bit
Date: Mon, 25 Jan 2016 12:32:54 -0800
Message-ID: <CAD=FV=XEuEdUH+cj0qGgszY5_BExsHKrpt31068j_XticsabKA@mail.gmail.com>
References: <1453718849-3508-1-git-send-email-sjoerd.simons@collabora.co.uk>
	<56A64114.3010400@gmail.com>
	<CAD=FV=X-ejMLnh30TofU7dKP5WwZaXcgLaQwFs__wo9wHsv53Q@mail.gmail.com>
	<56A68064.5020702@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arend van Spriel <aspriel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Sjoerd Simons <sjoerd.simons-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	"open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Adrian Hunter <adrian.hunter-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56A68064.5020702-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, Jan 25, 2016 at 12:07 PM, Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
>> In any case, in my experience the Broadcom firmware is fairly
>> complicated and has numerous cases where it stretches SDIO more than
>> the other SDIO WiFi chip I've worked with.  It wouldn't terribly
>> surprise me if there was a period of time during bootup where it was
>> non-responsive for 2 seconds.  As unrelated "evidence" showing some of
>> the Broadcom SDIO limitations, you can see
>> <https://chromium-review.googlesource.com/#/c/250228/> and also the
>> fact that Broadcom often holds the SDIO "busy" signal whereas the
>> other SDIO WiFi chip I've worked never did that.  Also, even with all
>> fixes the Broadcom WiFi module will still show periodic SDIO errors
>> that the higher level driver just knows to ignore.
>
> The busy signal is in accordance with the SDIO spec.

Sorry, didn't mean to imply that it wasn't.  That particular instance
is definitely legal, but it was also just showing a case where the
Broadcom WiFi needed something that wasn't needed elsewhere.

AKA: it's kinda like saying that other modules work on a UART without
flow control lines and the Broadcom needs the flow control lines.
UARTs are designed with flow control lines and it's totally legal to
need them.  ...but if you saw that one serial device didn't need them
then you would presume that maybe the device on the other end had very
low interrupt latency or had some other hardware help (large FIFOs,
DMA, fast processor, hard real time OS, etc).  A device with low
interrupt latency, large FIFOs, DMA, fast processor, etc would
presumably be less likely to have other pauses in communication.


> It would be good to
> know if that is what is happening. Unfortunately I do have an SDIO
> analyzer, but not reproduced it. May retry on veyron device.

You might just be able to put a trace to see if it hits the busy
signal.  Depending on your Linux version you might just be able to put
a trace in __mmc_start_request().  If not and if you're on dw_mmc you
can put a trace in dw_mci_wait_while_busy().


>> My old debugging from the (sorry, private) bug
>> http://crosbug.com/p/36975 showed this periodically even with all
>> known fixes:
>>
>> [21310.271635] dwmmc_rockchip ff0d0000.dwmmc: CMD ERR: 0x00000104
>> [21550.583598] dwmmc_rockchip ff0d0000.dwmmc: CMD ERR: 0x00000104
>> [21550.616035] brcmfmac: brcmf_sdio_readframes: RXHEADER FAILED: -110
>> [21550.648460] brcmfmac: brcmf_sdio_rxfail: abort command, terminate
>> frame, send NAK
>> [21550.683502] dwmmc_rockchip ff0d0000.dwmmc: CMD ERR: 0x00000104
>> [21550.691214] dwmmc_rockchip ff0d0000.dwmmc: CMD ERR: 0x00000100
>> [22671.121329] dwmmc_rockchip ff0d0000.dwmmc: CMD ERR: 0x00000104
>> [22671.153167] dwmmc_rockchip ff0d0000.dwmmc: CMD ERR: 0x01000104
>> [22671.184581] brcmfmac: brcmf_sdio_readframes: RXHEADER FAILED: -110
>> [22671.192600] brcmfmac: brcmf_sdio_rxfail: abort command, terminate
>> frame, send NAK
>> [22671.201929] dwmmc_rockchip ff0d0000.dwmmc: CMD ERR: 0x00000114
>> [22671.209536] dwmmc_rockchip ff0d0000.dwmmc: CMD ERR: 0x00000100
>> [28463.941736] dwmmc_rockchip ff0d0000.dwmmc: CMD ERR: 0x00000104
>>
>> At the time dekim@ responded:
>>
>>> There are several sleep/wake control at different level. The one we're talking
>>> about here is controlled by brcmf_sdio_bus_sleep() in the host driver to turn
>>> on/off bus core on the chip. There can be a period of time when chip is not
>>> paying attention to the host command (cmd52 to the
>>> SBSDIO_FUNC1_SLEEPCSR).
>>
>> ...and we decided that the periodic SDIO errors weren't causing any
>> huge problems (since they were retried).  As far as I know, they still
>> happen today.
>
> Were these true periodic errors or random at interval.

I believe they were random, and I believe that I needed "power save"
mode turned on for WiFi.  I believe errors were made worse if I had a
TCP/IP ping running (AKA bring out of power save and go back in
constantly).
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
