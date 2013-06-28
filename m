From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Subject: Re: [RFC PATCH] usb: hcd: warn about URB buffers that are not DMA
 aligned and are about to be DMA mapped
Date: Fri, 28 Jun 2013 15:39:27 +0300
Message-ID: <51CD83FF.2030704@iki.fi>
References: <20130614133803.25747.98705.stgit@localhost6.localdomain6> <51BC67D7.90006@iki.fi> <51BC6A96.7030707@iki.fi> <6777683.xBFsv58ruI@linux-5eaq.site> <51BD94F5.2060803@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Oliver Neukum <oliver@neukum.org>,
	Ming Lei <tom.leiming@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Network Development <netdev@vger.kernel.org>
To: linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sypressi.dnainternet.net ([83.102.40.135]:37311 "EHLO
	sypressi.dnainternet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228Ab3F1Mji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 08:39:38 -0400
In-Reply-To: <51BD94F5.2060803@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.06.2013 13:35, Jussi Kivilinna wrote:
> On 16.06.2013 11:21, Oliver Neukum wrote:
>> On Saturday 15 June 2013 16:22:30 Jussi Kivilinna wrote:
>>
>>> Hm.. rethink this a bit.
>>>
>>> Transfer buffer might be dma aligned but shorter than cacheline and end of cacheline
>>> used as something else. Manual alignment by host driver does not catch that
>>> or fix that.
>>> So, yes.. dma mapping should work with unaligned buffers, but maybe the actual
>>> problem is multiple buffers from same cacheline.
>>
>> The buffers kmalloc() returns are OK in that regard. A driver that uses
>> a buffer for anything but buffering is buggy.
> 
> Ok, I'll look at that direction. Thanks.
> 

So if I understood correctly, drivers that allocate these as part of larger structures (struct *_device etc) are doing wrong thing and are potentially buggy. And this is because cachelines of buffers can be DMA mapped after usb_submit_urb() and editing same cacheline while URB is in-flight can therefore be hazardous.

I checked setup_packet and transfer_buffer usage of some drivers in 3.9.8 and made some observations. Should these be fixed?

URB setup_packet and transfer_buffer part of same structure (might share same cacheline for same URB):
 * iforce:
  - http://lxr.linux.no/linux+v3.9.8/drivers/input/joystick/iforce/iforce-usb.c#L173
  - http://lxr.linux.no/linux+v3.9.8/drivers/input/joystick/iforce/iforce.h#L101
 * usbvision:
  - http://lxr.linux.no/linux+v3.9.8/drivers/media/usb/usbvision/usbvision-core.c#L1445
  - http://lxr.linux.no/linux+v3.9.8/drivers/media/usb/usbvision/usbvision.h#L366
 * catc:
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/catc.c#L499
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/catc.c#L500
  - ctrl_buf, ctrl_dr: http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/catc.c#L162
 * rtl8150:
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/rtl8150.c#L200
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/rtl8150.c#L128
 * rt2x000usb:
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/rt2x00/rt2x00usb.c#L212
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/rt2x00/rt2x00usb.c#L169
 * rtl8187:
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/rtl818x/rtl8187/dev.c#L156
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/rtl818x/rtl8187/dev.c#L130
 * uss720:
  - http://lxr.linux.no/linux+v3.9.8/drivers/usb/misc/uss720.c#L176
  - http://lxr.linux.no/linux+v3.9.8/drivers/usb/misc/uss720.c#L72

URB transfer_buffer array (transfer buffers preloaded as array, element size less than cacheline):
 * rtlwifi:
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/rtlwifi/usb.c#L152
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/rtlwifi/wifi.h#L1859
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/rtlwifi/usb.c#L980
 * catc:
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/catc.c#L371
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/catc.c#L162

URB setup_packet part of larger structure:
 * gigaset:
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/gigaset/bas-gigaset.c#L90
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/gigaset/bas-gigaset.c#L581
 * mISDN/hfcsusb:
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/hardware/mISDN/hfcsusb.c#L1732
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/hardware/mISDN/hfcsusb.c#L74
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/hardware/mISDN/hfcsusb.h#L270
 * hisax/hfc_usb:
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/hisax/hfc_usb.c#L1185
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/hisax/hfc_usb.c#L227
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/hisax/hfc_usb.c#L193
 * hisax/st5481:
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/hisax/st5481_usb.c#L42
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/hisax/st5481.h#L326
 * hso:
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/hso.c#L1812
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/hso.c#L1846
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/hso.c#L220
 * pegasus:
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/pegasus.c#L169
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/pegasus.h#L111
 * brcmfmac:
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/brcm80211/brcmfmac/usb.c#L209
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/brcm80211/brcmfmac/usb.c#L71
 * staging/vt6656:
  - http://lxr.linux.no/linux+v3.9.8/drivers/staging/vt6656/usbpipe.c#L142
  - http://lxr.linux.no/linux+v3.9.8/drivers/staging/vt6656/device.h#L390

URB transfer_buffer part of larger structure:
 * iforce:
  - http://lxr.linux.no/linux+v3.9.8/drivers/input/joystick/iforce/iforce-usb.c#L170
  - http://lxr.linux.no/linux+v3.9.8/drivers/input/joystick/iforce/iforce-usb.c#L167
  - http://lxr.linux.no/linux+v3.9.8/drivers/input/joystick/iforce/iforce.h#L101
  - http://lxr.linux.no/linux+v3.9.8/drivers/input/joystick/iforce/iforce-usb.c#L147
 * ks959:
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/irda/ks959-sir.c#L278
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/irda/ks959-sir.c#L172
 * ksdazzle-sir:
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/irda/ksdazzle-sir.c#L199
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/irda/ksdazzle-sir.c#L138
 * wusbcore:
  - http://lxr.linux.no/linux+v3.9.8/drivers/usb/wusbcore/security.c#L568
  - http://lxr.linux.no/linux+v3.9.8/drivers/usb/wusbcore/wusbhc.h#L288
  - http://lxr.linux.no/linux+v3.9.8/drivers/usb/wusbcore/wa-xfer.c#L378
  - http://lxr.linux.no/linux+v3.9.8/drivers/usb/wusbcore/wa-xfer.c#L337
  - http://lxr.linux.no/linux+v3.9.8/drivers/usb/wusbcore/wa-xfer.c#L661
  - http://lxr.linux.no/linux+v3.9.8/drivers/usb/wusbcore/wa-xfer.c#L115
 * mISDN/hfcsusb:
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/hardware/mISDN/hfcsusb.c#L1515
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/hardware/mISDN/hfcsusb.h#L247
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/hardware/mISDN/hfcsusb.c#L1071
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/hardware/mISDN/hfcsusb.h#L236
 * hisax/hfc_usb:
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/hisax/hfc_usb.c#L924
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/hisax/hfc_usb.c#L148
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/hisax/hfc_usb.c#L591
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/hisax/hfc_usb.c#L144
 * rc/imon:
  - http://lxr.linux.no/linux+v3.9.8/drivers/media/rc/imon.c#L480
  - http://lxr.linux.no/linux+v3.9.8/drivers/media/rc/imon.c#L504
  - http://lxr.linux.no/linux+v3.9.8/drivers/media/rc/imon.c#L2148
  - http://lxr.linux.no/linux+v3.9.8/drivers/media/rc/imon.c#L2232
  - http://lxr.linux.no/linux+v3.9.8/drivers/media/rc/imon.c#L2452
  - http://lxr.linux.no/linux+v3.9.8/drivers/media/rc/imon.c#L2462
  - http://lxr.linux.no/linux+v3.9.8/drivers/media/rc/imon.c#L90
 * catc:
  - tx_buf, rx_buf, irq_buf: http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/catc.c#L162
 * hso:
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/hso.c#L1464
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/hso.c#L208
 * pegasus:
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/pegasus.c#L1030
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/pegasus.h#L111
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/pegasus.c#L886
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/pegasus.h#L107
 * brcmfmac:
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/brcm80211/brcmfmac/usb.c#L631
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/brcm80211/brcmfmac/usb.c#L71
 * staging/bcm:
  - http://lxr.linux.no/linux+v3.9.8/drivers/staging/bcm/InterfaceIsr.c#L125
  - http://lxr.linux.no/linux+v3.9.8/drivers/staging/bcm/InterfaceAdapter.h#L63
 * speedtch:
  - http://lxr.linux.no/linux+v3.9.8/drivers/usb/atm/speedtch.c#L888
  - http://lxr.linux.no/linux+v3.9.8/drivers/usb/atm/speedtch.c#L137
 * gigaset:
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/gigaset/usb-gigaset.c#L467
  - http://lxr.linux.no/linux+v3.9.8/drivers/isdn/gigaset/gigaset.h#L521
 * ttusbir:
  - http://lxr.linux.no/linux+v3.9.8/drivers/media/rc/ttusbir.c#L300
  - http://lxr.linux.no/linux+v3.9.8/drivers/media/rc/ttusbir.c#L48
 * vub300:
  - http://lxr.linux.no/linux+v3.9.8/drivers/mmc/host/vub300.c#L467
  - http://lxr.linux.no/linux+v3.9.8/drivers/mmc/host/vub300.c#L346
  - http://lxr.linux.no/linux+v3.9.8/drivers/mmc/host/vub300.c#L491
  - http://lxr.linux.no/linux+v3.9.8/drivers/mmc/host/vub300.c#L345
  - http://lxr.linux.no/linux+v3.9.8/drivers/mmc/host/vub300.c#L1526
  - http://lxr.linux.no/linux+v3.9.8/drivers/mmc/host/vub300.c#L355
 * mcs7780:
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/irda/mcs7780.c#L519
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/irda/mcs7780.c#L844
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/irda/mcs7780.h#L103
 * rt2x00usb:
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/rt2x00/rt2500usb.c#L1194
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/rt2x00/rt2x00usb.h#L387
 * rtl8187:
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/rtl818x/rtl8187/dev.c#L551
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/rtl818x/rtl8187/rtl8187.h#L142
 * zd1201:
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/zd1201.c#L817
  - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/zd1201.h#L42
 * quatech2:
  - http://lxr.linux.no/linux+v3.9.8/drivers/usb/serial/quatech2.c#L769
  - http://lxr.linux.no/linux+v3.9.8/drivers/usb/serial/quatech2.c#L111
  - http://lxr.linux.no/linux+v3.9.8/drivers/usb/serial/quatech2.c#L841
  - http://lxr.linux.no/linux+v3.9.8/drivers/usb/serial/quatech2.c#L118
 * caiaq:
  - http://lxr.linux.no/linux+v3.9.8/sound/usb/caiaq/device.c#L425
  - http://lxr.linux.no/linux+v3.9.8/sound/usb/caiaq/device.c#L430
  - http://lxr.linux.no/linux+v3.9.8/sound/usb/caiaq/device.h#L77
  - http://lxr.linux.no/linux+v3.9.8/sound/usb/caiaq/device.h#L79

URB transfer buffer in stack:
 * alauda:
  - command: http://lxr.linux.no/linux+v3.9.8/drivers/mtd/nand/alauda.c#L226
  - command: http://lxr.linux.no/linux+v3.9.8/drivers/mtd/nand/alauda.c#L210
  - command: http://lxr.linux.no/linux+v3.9.8/drivers/mtd/nand/alauda.c#L291
  - command: http://lxr.linux.no/linux+v3.9.8/drivers/mtd/nand/alauda.c#L275
  - command: http://lxr.linux.no/linux+v3.9.8/drivers/mtd/nand/alauda.c#L342
  - command: http://lxr.linux.no/linux+v3.9.8/drivers/mtd/nand/alauda.c#L325
  - command: http://lxr.linux.no/linux+v3.9.8/drivers/mtd/nand/alauda.c#L165
  - oob: http://lxr.linux.no/linux+v3.9.8/drivers/mtd/nand/alauda.c#L230
  - oob: http://lxr.linux.no/linux+v3.9.8/drivers/mtd/nand/alauda.c#L377
  - oob: http://lxr.linux.no/linux+v3.9.8/drivers/mtd/nand/alauda.c#L401
  - oob: http://lxr.linux.no/linux+v3.9.8/drivers/mtd/nand/alauda.c#L467
  - oob: http://lxr.linux.no/linux+v3.9.8/drivers/mtd/nand/alauda.c#L295
 * pn533:
  - ack: http://lxr.linux.no/linux+v3.9.8/drivers/nfc/pn533.c#L630
 * i2c-tiny-usb:
  - func: http://lxr.linux.no/linux+v3.9.8/drivers/i2c/busses/i2c-tiny-usb.c#L116
  - func: http://lxr.linux.no/linux+v3.9.8/drivers/i2c/busses/i2c-tiny-usb.c#L159
 * zd1201:
  - ret: http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/zd1201.c#L100
 * rndis_host:
  - notification: http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/rndis_host.c#L143
 * 6fire:
  - buffer: http://lxr.linux.no/linux+v3.9.8/sound/usb/6fire/comm.c#L113
  - buffer: http://lxr.linux.no/linux+v3.9.8/sound/usb/6fire/comm.c#L122
  - send_buffer: http://lxr.linux.no/linux+v3.9.8/sound/usb/6fire/comm.c#L96

-Jussi
