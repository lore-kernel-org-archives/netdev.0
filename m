From: =?utf-8?Q?=C3=89meric?= Vigier
	<emeric.vigier@savoirfairelinux.com>
Subject: smsc95xx: download ok, upload hangs
Date: Thu, 21 Jun 2012 10:34:42 -0400 (EDT)
Message-ID: <464058858.159452.1340289282058.JavaMail.root@mail.savoirfairelinux.com>
References: <674701881.595779.1340222798864.JavaMail.root@mail.savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net,
	=?utf-8?B?SsOpcsO0bWU=?= Oufella
	<jerome.oufella@savoirfairelinux.com>
To: netdev kernel <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:54107 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755128Ab2FUOmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 10:42:12 -0400
In-Reply-To: <674701881.595779.1340222798864.JavaMail.root@mail.savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am experiencing ethernet issue with a pandaboard A3 (OMAP4430 rev 2.2) featuring smsc LAN9514-JZX usbnet chipset.
My panda runs android-4.0.4 with linux kernel 3.0.8 (the latest from omapzoom).

Receiving ethernet frames work fine, but transmitting them does not. The driver/chip seems stuck.
Moving the USB mouse (or USB keyboard key pressed) unlocks this behavior and transmission gets resumed for a second or two. Then ethernet transmission gets stuck again.

Recently, I cherry-picked dozen of usbnet and smsc95xx patches, and managed to get a watchdog barking (see test 21 below).

Unfortunately I have no JTAG probe, so I am limited to driver tweaks and tryouts...
Here are the tests I have performed so far, along with a todo list:

FAILED means that the issue came up.
PASSED means that the issue has not come up.
DONE, NOT DONE, ONGOING are more related to a todo list than a test report.

1. check with constant cpu load (stress -c 2) - FAILED
2. check if problem occurs on older releases (non ICS) - NOT DONE
3. try CONFIG_PL310_ERRATA_769419 patch in cpuidle - FAILED
4. check without USB hub connected - FAILED
5. check with usbcore.autosuspend=600 added to cmdline - FAILED
6. patch ehci-omap.c to verify clock frequency - NOT DONE
7. check with CPU1 offlined - FAILED
8. check ethtool on android - FAILED
Cannot get register dump: Operation not supported on transport endpoint
9. check without USB_EHCI_TT_NEWSCHED - FAILED

10. try to unbind, rebind smsc95xx - FAILED
11. disable turbo_mode and reset the chip - FAILED
12. test with "CONFIG_NO_HZ is not set" - FAILED
13. test with another external USB ethernet dongle - NOT DONE
14. test linaro-12.05 ICS release and see ethernet behavior - PASSED
Ethernet runs fine on release:
. 12.05 tracking - PASSED
. 11.10 tracking - PASSED
. 11.09 release - PASSED
15. try with "netcfg eth0 dhcp" - FAILED
16. check datasheet - ONGOING
registers description is missing on 9514.pdf, only eeprom is described
17. adapt driver to ethtool - DONE
18. dump registers and check against linaro 11.09 - ONGOING
19. ethtool returns heaps of "0", the pattern I added to the array is all replaced by "0"...
Actually the eeprom is blank. I found it out since each time I unbind/bind the device to smsc95xx driver, I get a random MAC address...

20. test with 11.09 linaro kernel - NOT DONE
zygote not starting
21. uploading 24MB file on the web (http://dl.free.fr) - FAILED
This occurred only with these patches added to my kernel:
 From 8a78335 [PATCH] usbnet: consider device busy at each recieved packet
 From 5d5440a [PATCH] usbnet: don't clear urb->dev in tx_complete
 From 4231d47 [PATCH] net/usbnet: avoid recursive locking in usbnet_stop()
 From 1aa9bc5 [PATCH] usbnet: use netif_tx_wake_queue instead of netif_start_queue
 From 7bdd402 [PATCH] net/usbnet: reserve headroom on rx skbs
 From 0956a8c [PATCH] usbnet: increase URB reference count before usb_unlink_urb
 From 9bbf566 [PATCH] net: usb: smsc95xx: fix mtu
 From 720f3d7 [PATCH] usbnet: fix leak of transfer buffer of dev->interrupt
 From a472384 [PATCH] usbnet: fix failure handling in usbnet_probe
 From 5b6e9bc [PATCH] usbnet: fix skb traversing races during unlink(v2)
 From 07d69d4 [PATCH] smsc95xx: mark link down on startup and let PHY interrupt
a timeout occurred:
http://pastebin.com/KpaTJY3N

My current kernel is based on:
commit 52f476403350050beb0dff135a55c06c9e7a82a9
Author: Jean-Baptiste Queru <jbq@google.com>
Subject: Revert "gpu: pvr: Revert to 1.8@550175"

I managed to get a register and PHY dump when upload is stuck, thanks to ethtool:

000:     01 00 00 ec 00 00 00 00 00 00 00 00 00 00 00 00
010:     04 00 00 00 00 14 00 00 00 00 00 00 00 20 00 00
020:     81 00 00 00 00 00 11 01 1f 00 00 1f a0 30 f8 00
030:     00 00 00 00 00 00 00 00 00 00 00 00 03 00 00 00
040:     00 00 00 80 00 00 00 00 00 00 00 00 00 00 00 00
050:     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
060:     00 00 00 00 00 00 00 00 00 80 00 00 00 20 00 00
070:     00 00 00 00 83 0f 83 0f 00 00 00 00 0f 06 0f 06
080:     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
090:     00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00
0a0:     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0b0:     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0c0:     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0d0:     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0e0:     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0f0:     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
100:     0c 20 10 00 f7 6f 00 00 a2 7d 13 dd 00 00 00 40
110:     20 00 00 80 40 09 00 00 e1 c1 00 00 00 00 00 00
120:     00 81 00 00 ff ff 00 00 00 00 00 00 00 00 00 00
130:     00 31 00 00 2d 78 00 00 07 00 00 00 c3 c0 00 00
140:     e1 0d 00 00 e1 c1 00 00 0b 00 00 00 ff ff 00 00
150:     ff ff 00 00 ff ff 00 00 ff ff 00 00 ff ff 00 00
160:     ff ff 00 00 ff ff 00 00 ff ff 00 00 00 00 00 00
170:     40 00 00 00 02 00 00 00 e1 00 00 00 ff ff 00 00
180:     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
190:     ff ff 00 00 ff ff 00 00 00 00 00 00 0a 00 00 00
1a0:     00 00 00 00 c8 00 00 00 50 00 00 00 58 10 00 00

But the 9514.pdf datasheet I have misses register description.
Then decoding all this is quite troublesome.

I saw that Ubuntu release got trouble with this chipset and acpi. But there is no acpi on Android AFAIK.
Did anyone else experience this issue?
Does anyone have an idea where it can come from?


Thanks a lot for your kind support,
Emeric
