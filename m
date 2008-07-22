From: Ingo Molnar <mingo@elte.hu>
Subject: [bug] hard hang with CONFIG_USB_USBNET=y
Date: Tue, 22 Jul 2008 15:07:27 +0200
Message-ID: <20080722130727.GA13917@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Greg KH <gregkh@suse.de>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:35730 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750975AbYGVNHo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 09:07:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


hi Greg, Jeff,

-tip randconfig based boot testing ran into a weird bootup hard hang 
with one specific config:

  http://redhat.com/~mingo/misc/config-Tue_Jul_22_10_06_14_CEST_2008.bad

the hard hang just happens some time into the bootup - usually somewhere 
around starting up crond.

I first suspected a recent regression, so i tried to bisect it - just to 
discover that it happens with v2.6.26 too and probably goes way back 
into the past.

So i did a ".config bisection" trying to figure out which specific 
.config option (out of thousands) triggers the hang. After a few hours 
of .config bisection i have arrived to CONFIG_USB_USBNET=y - enabling 
_any_ driver there (i tried CONFIG_USB_NET_ZAURUS=y or 
CONFIG_USB_NET_PLUSB=y) causes the hard hang. See the delta patch below 
between a 'good' and 'bad' config.

Also see further below a diff between the good and bad serial log 
output.

The same bzImage boots fine on another testsystem.

The full 'bad' bootlog can be found at:

  http://redhat.com/~mingo/misc/log-Tue_Jul_22_10_06_14_CEST_2008.bad

What do you suggest me to debug this problem? CONFIG_USB_USBNET=y is 
supposed to work just fine even if no such hardware is present, correct? 

Old ISA drivers sometimes fail to boot because they have certain 
assumptions and poke ports randomly - but CONFIG_USB_USBNET is supposed 
to work just fine, correct?

The hang is fully reproducible so i can try any debug patch or other 
test-patch. If you think it's worthwile i can try a bisection back into 
the ancient past.

There's no APIC on this box so no NMI watchdog can be used to punch 
through the hard lockup. It has the feeling of an IRQ flood. (but no 
kernel printks happen after the lockup, even after hours of waiting)

	Ingo

--- .config.good	2008-07-22 14:25:08.000000000 +0200
+++ .config.bad	2008-07-22 14:35:00.000000000 +0200
 CONFIG_USB_RTL8150=y
 CONFIG_USB_USBNET=y
 # CONFIG_USB_NET_AX8817X is not set
-# CONFIG_USB_NET_CDCETHER is not set
+CONFIG_USB_NET_CDCETHER=y
 # CONFIG_USB_NET_DM9601 is not set
 # CONFIG_USB_NET_GL620A is not set
 # CONFIG_USB_NET_NET1080 is not set
@@ -904,7 +904,7 @@ CONFIG_USB_USBNET=y
 # CONFIG_USB_NET_MCS7830 is not set
 # CONFIG_USB_NET_RNDIS_HOST is not set
 # CONFIG_USB_NET_CDC_SUBSET is not set
-# CONFIG_USB_NET_ZAURUS is not set
+CONFIG_USB_NET_ZAURUS=y
 CONFIG_WAN=y
 CONFIG_LANMEDIA=y
 CONFIG_HDLC=y

[ ... uninteresting delta like timestamp differences omitted ... ]

--- dmesg.good	2008-07-22 14:40:54.000000000 +0200
+++ dmesg.bad	2008-07-22 14:48:56.000000000 +0200
@@ -1,4 +1,4 @@
-Linux version 2.6.26-dirty (mingo@dione) (gcc version 4.2.2) #21529 SMP Tue Jul 22 14:21:04 CEST 2008
+Linux version 2.6.26-dirty (mingo@dione) (gcc version 4.2.2) #21530 SMP Tue Jul 22 14:25:39 CEST 2008
 BIOS-provided physical RAM map:
  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
@@ -1076,6 +1076,12 @@ calling  usb_rtl8150_init+0x0/0x30
 rtl8150: rtl8150 based usb-ethernet driver v0.6.2 (2004/08/27)
 usbcore: registered new interface driver rtl8150
 initcall usb_rtl8150_init+0x0/0x30 returned 0 after 7 msecs
+calling  cdc_init+0x0/0x20
+usbcore: registered new interface driver cdc_ether
+initcall cdc_init+0x0/0x20 returned 0 after 5 msecs
+calling  zaurus_init+0x0/0x20
+usbcore: registered new interface driver zaurus
+initcall zaurus_init+0x0/0x20 returned 0 after 4 msecs
 calling  usbnet_init+0x0/0x30
 initcall usbnet_init+0x0/0x30 returned 0 after 0 msecs
 calling  init_netconsole+0x0/0x1d0
@@ -1281,8 +1287,8 @@ ether gadget: using random self ethernet
 ether gadget: using random host ethernet address
 usb0: Ethernet Gadget, version: May Day 2005
 usb0: using dummy_udc, OUT ep-b IN ep-a STATUS ep-c
-usb0: MAC ee:cf:d5:ad:92:32
-usb0: HOST MAC b6:e4:17:99:38:77
+usb0: MAC fa:96:e7:05:b1:96
+usb0: HOST MAC fa:7d:7d:f2:06:1a
 initcall init+0x0/0x10 returned 0 after 19 msecs
 calling  i8042_init+0x0/0x400
 pnp: the driver 'i8042 kbd' has been registered
@@ -1332,10 +1338,10 @@ initcall amd756_init+0x0/0x20 returned 0
 calling  i2c_amd8111_init+0x0/0x20
 initcall i2c_amd8111_init+0x0/0x20 returned 0 after 0 msecs
 calling  nforce2_init+0x0/0x20
-usb 2-1: new high speed USB device using dummy_hcd and address 2
-initcall nforce2_init+0x0/0x20 returned 0 after 3 msecs
+initcall nforce2_init+0x0/0x20 returned 0 after 0 msecs
 calling  i2c_piix4_init+0x0/0x20
 piix4_smbus 0000:00:07.3: Found 0000:00:07.3 device
+usb 2-1: new high speed USB device using dummy_hcd and address 2
 initcall i2c_piix4_init+0x0/0x20 returned 0 after 30 msecs
 calling  i2c_sis630_init+0x0/0x20
 initcall i2c_sis630_init+0x0/0x20 returned 0 after 0 msecs
@@ -1357,6 +1363,7 @@ usb 2-1: configuration #1 chosen from 1 
 initcall sensors_adm1025_init+0x0/0x10<6>usb0: high speed config #1: 100 mA, Ethernet Gadget, using CDC Ethernet
  returned 0 after 23 msecs
 calling  sensors_adm1029_init+0x0/0x10
+usb1: register 'cdc_ether' at usb-dummy_hcd-1, CDC Ethernet Device, fa:7d:7d:f2:06:1a
 usb 2-1: New USB device found, idVendor=0525, idProduct=a4a1
 usb 2-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
 usb 2-1: Product: Ethernet Gadget
