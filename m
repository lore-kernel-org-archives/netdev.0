From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH] e100: Use pci_pme_active for clearing wake-up events and disabling PME# (was: Re: [regression] e100: PCI wake-up handling rework causes "Error clearing wake event")
Date: Tue, 9 Sep 2008 15:14:22 +0200
Message-ID: <200809091514.23817.rjw@sisk.pl>
References: <200809090812.37649.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, kernel-testers@vger.kernel.org,
	jesse.brandeburg@intel.com,
	Andrew Morton <akpm@linux-foundation.org>
To: Frans Pop <elendil@planet.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:51288 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751606AbYIINJ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 09:09:57 -0400
In-Reply-To: <200809090812.37649.elendil@planet.nl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, 9 of September 2008, Frans Pop wrote:
> (Resending because of error in mail headers in previous attempt; sorry)
> 
> On my Toshiba Satellite A40 with 2.6.27-rc4/5 I noticed the following 
> error in the boot log (not there with 2.6.26):
> e100: 0000:01:08.0: e100_probe: Error clearing wake event
> 
> Bisection has fingered the following patch as the cause of the message.
> 
> commit eb9d0fe40e313c0a74115ef456a2e43a6c8da72f
> Author: Rafael J. Wysocki <rjw@sisk.pl>
> Date:   Mon Jul 7 03:34:48 2008 +0200
>     PCI ACPI: Rework PCI handling of wake-up
> 
> The test this error originates from in drivers/net/e100.c is old and has 
> not changed recently.
> 
> Surrounding messages (full dmesg attached):
> e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
> e100: Copyright(c) 1999-2006 Intel Corporation
> e100 0000:01:08.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
> e100: 0000:01:08.0: e100_probe: Error clearing wake event
> e100: eth0: e100_probe: addr 0xcffff000, irq 20, MAC addr 
> 00:08:0d:17:bf:f5
> 
> The NIC is:
> 01:08.0 Ethernet controller [0200]: Intel Corporation 82801DB PRO/100 VE 
> (MOB) Ethernet Controller [8086:103d] (rev 83)
>         Kernel driver in use: e100

The message is actually harmless, but I agree that it's confusing.

The appended patch should fix the problem (ISTR sending it some time ago
already).

Thanks,
Rafael

---
From: Rafael J. Wysocki <rjw@sisk.pl>

e100: Use pci_pme_active for clearing wake-up events and disabling PME#

Currently e100 uses pci_enable_wake() to clear pending wake-up events
and disable PME# during intitialization, but that function is not
suitable for this purpose, because it immediately returns error code
if device_may_wakeup() returns false for given device.

Make e100 use pci_pme_active(), which carries out exactly the
required operations, instead.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/e100.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

Index: linux-2.6/drivers/net/e100.c
===================================================================
--- linux-2.6.orig/drivers/net/e100.c
+++ linux-2.6/drivers/net/e100.c
@@ -2738,9 +2738,7 @@ static int __devinit e100_probe(struct p
 		nic->flags |= wol_magic;
 
 	/* ack any pending wake events, disable PME */
-	err = pci_enable_wake(pdev, 0, 0);
-	if (err)
-		DPRINTK(PROBE, ERR, "Error clearing wake event\n");
+	pci_pme_active(pdev, false);
 
 	strcpy(netdev->name, "eth%d");
 	if((err = register_netdev(netdev))) {
