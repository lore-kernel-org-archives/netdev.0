From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: brcm80211 breakage..
Date: Wed, 11 Jan 2012 11:00:32 -0600
Message-ID: <4F0DC030.6090500@lwfinger.net>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com> <4F0D6806.4080201@broadcom.com> <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com> <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arend van Spriel <arend@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:42648 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756329Ab2AKRAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 12:00:37 -0500
Received: by iabz25 with SMTP id z25so1350440iab.19
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2012 09:00:37 -0800 (PST)
In-Reply-To: <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2012 10:04 AM, Linus Torvalds wrote:
> On Wed, Jan 11, 2012 at 7:05 AM, Linus Torvalds
>
> Ok, could do it now. But that really doesn't give much more
> information. Here it is anyway:
>
> [    0.746530] bcma-pci-bridge 0000:02:00.0: PCI INT A ->  GSI 17
> (level, low) ->  IRQ 17
> [    0.746544] bcma-pci-bridge 0000:02:00.0: setting latency timer to 64
> [    0.746617] bcma: Core 0 found: ChipCommon (manuf 0x4BF, id 0x800,
> rev 0x22, class 0x0)
> [    0.746646] bcma: Core 1 found: IEEE 802.11 (manuf 0x4BF, id 0x812,
> rev 0x17, class 0x0)
> [    0.746709] bcma: Core 2 found: PCIe (manuf 0x4BF, id 0x820, rev
> 0x0F, class 0x0)
> [    0.746845] bcma: Switched to core: 0x800
> [    0.746859] bcma: Found rev 6 PMU (capabilities 0x108C2606)
> [    0.746880] bcma: Switched to core: 0x820
> [    0.775510] bcma: Switched to core: 0x800
> [    0.815750] bcma: Unsupported SPROM revision: 255
> [    0.815804] bcma: No SPROM available

I'm not a bcma or brcmsmac expert, but the above result of SPROM version 0xFF 
looks as if the read was from a non-existent register. If you get a chance, 
please try this patch, which will dump the offset that is being used.

Index: wireless-testing-new/drivers/bcma/sprom.c
===================================================================
--- wireless-testing-new.orig/drivers/bcma/sprom.c
+++ wireless-testing-new/drivers/bcma/sprom.c
@@ -230,6 +230,7 @@ int bcma_sprom_get(struct bcma_bus *bus)
  	 * TODO: understand this condition and use it */
  	offset = (bus->chipinfo.id == 0x4331) ? BCMA_CC_SPROM :
  		BCMA_CC_SPROM_PCIE6;
+	pr_debug("SPROM offset 0x%x\n", offset);
  	bcma_sprom_read(bus, offset, sprom);

  	if (bus->chipinfo.id == 0x4331)

As the TODO indicates, this part is not understood.

One other thing to try. If the new output says that the offset is 0x830, try 
forcing it to 0x800, or vice versa. I don't think you have a 4331, and I expect 
that the current code is trying 0x830, but should be using 0x800.

Larry
