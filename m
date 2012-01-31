From: "Henrik Rydberg" <rydberg@euromail.se>
Subject: Re: brcm80211 breakage..
Date: Tue, 31 Jan 2012 13:08:46 +0100
Message-ID: <20120131120846.GA8799@polaris.bitmath.org>
References: <CA+55aFx2UnVZP1Z44dMHeifB2nD1zJ87kz25zZjUdwv0ozwKPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b12.telenor.se ([62.127.194.21]:40528 "EHLO
	smtprelay-b12.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753031Ab2AaMIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 07:08:07 -0500
Received: from ipb4.telenor.se (ipb4.telenor.se [195.54.127.167])
	by smtprelay-b12.telenor.se (Postfix) with ESMTP id 7D352EB725
	for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 13:08:04 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,

Thanks for the MBA31 fixes. Sadly, however, with current git
(27ba234), after encountering the known problem

[  882.064120] bcma: Failed to get SPROM: -71

probing simply fails on my machine,

[  882.064256] bcma-pci-bridge: probe of 0000:01:00.0 failed with error -2

resulting in no wireless. Since the bcma SPROM setup allegedly is
unused, simply ignoring the error with this hack

diff --git a/drivers/bcma/main.c b/drivers/bcma/main.c
index febbc0a..cb69fb0 100644
--- a/drivers/bcma/main.c
+++ b/drivers/bcma/main.c
@@ -171,7 +171,6 @@ int bcma_bus_register(struct bcma_bus *bus)
 		pr_err("No SPROM available\n");
 	} else if (err) {
 		pr_err("Failed to get SPROM: %d\n", err);
-		return -ENOENT;
 	}
 
 	/* Register found cores */

makes the device register as

01:00.0 0280: 14e4:4353 (rev 01)
	Subsystem: 106b:00d1
	Kernel driver in use: bcma-pci-bridge

which seems to actually work. Instead of the failed probe, the log shows

[ 1168.048571] bcma: Core 0 found: ChipCommon (manuf 0x4BF, id 0x800, rev 0x22, class 0x0)
[ 1168.048706] bcma: Core 1 found: IEEE 802.11 (manuf 0x4BF, id 0x812, rev 0x17, class 0x0)
[ 1168.048855] bcma: Core 2 found: PCIe (manuf 0x4BF, id 0x820, rev 0x0F, class 0x0)
[ 1168.049051] bcma: Found rev 6 PMU (capabilities 0x108C2606)
[ 1168.120122] bcma: Failed to get SPROM: -71
[ 1168.120340] bcma: Bus registered
[ 1168.125167] brcmsmac bcma0:0: mfg 4bf core 812 rev 23 class 0 irq 23
[ 1168.175670] bcma: Switched to core: 0x812
[ 1168.182061] brcms_module_init: register returned 0

Given that our machines look the same, this is somewhat odd. Could
this be a config issue or did I miss something else?

Henrik
