From: Marc Zyngier <mzyngier@freesurf.fr>
Subject: Re: 2.6.4-rc1 + hp100 EISA, not working
Date: Mon, 08 Mar 2004 22:55:32 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <wrpu10zf1gr.fsf@hina.wild-wind.fr.eu.org>
References: <Pine.LNX.4.58.0402292149230.25624@don.falconne.eu.org>
	<wrpptbwyiyx.fsf@hina.wild-wind.fr.eu.org>
	<Pine.LNX.4.58.0403012353560.25624@don.falconne.eu.org>
Reply-To: mzyngier@freesurf.fr
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Stephen Hemminger <shemminger@osdl.org>,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pawel.sokolowski@muflon.linux.pl
In-Reply-To: <Pine.LNX.4.58.0403012353560.25624@don.falconne.eu.org> (Pawel
 Sokolowski's message of "Tue, 2 Mar 2004 00:04:11 +0100 (CET)")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "Pawel" == Pawel Sokolowski <falcon@muflon.linux.pl> writes:

Pawel> This machine has RAM BIOS booted from floppy. I ran it and EISA
Pawel> configure utility to check this once more. Card is enabled and not
Pawel> locked. I added eisa_bus.enable_dev=2 parameter but it didn't help much.
Pawel> I'm getting:

Pawel> EISA: Probing bus 0 at eisa0
Pawel> EISA: Mainboard HWPC061 detected.
Pawel> EISA: slot 2 : HWP1940 detected (forced enabled).
Pawel> EISA: Detected 1 card.

Pawel> I added this final entry you mailed but nothing changed. Still - module
Pawel> loads and unloads cleanly and without any warnings on 2.6.4-rc1. But
Pawel> does nothing - not a single line in logs/dmesg after it's loaded. Card
Pawel> does not work after modprobe, I can't get interface up.

Ok, found it.

It really looks like the new EISA probing code in hp100 never got
tested, since a precious offset has disappeared during the rewriting
process.

Please note that you still need to enable the device by hand, since
your BIOS (or maybe the EISA CFG file, since I'm seeing the exact same
problem on a Compaq machine here) doesn't properly enable the card.

Here is what I'm getting on my test system :

EISA: Probing bus 0 at 0000:00:0f.0
EISA: Mainboard CPQ0541 detected.
EISA: slot 1 : DEC4250 detected.
EISA: slot 2 : UNB0048 detected.
EISA: slot 3 : HWP1940 detected (forced enabled).
hp100: Using (slow) programmed i/o mode.
hp100: at 0x3c38, IRQ 3, EISA bus, 128k SRAM (rx/tx 75%).
hp100: Adapter is attached to 10Mb/s network (10baseT).
EISA: slot 4 : NVL0701 detected.

Jeff, please apply.

	M.

===== drivers/net/hp100.c 1.26 vs edited =====
--- 1.26/drivers/net/hp100.c	Mon Mar  1 12:18:00 2004
+++ edited/drivers/net/hp100.c	Mon Mar  8 22:42:53 2004
@@ -2862,7 +2862,7 @@
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &edev->dev);
 
-	err = hp100_probe1(dev, edev->base_addr, HP100_BUS_EISA, NULL);
+	err = hp100_probe1(dev, edev->base_addr + 0xC38, HP100_BUS_EISA, NULL);
 	if (err)
 		goto out1;
 

-- 
Places change, faces change. Life is so very strange.
