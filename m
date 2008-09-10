From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] e100: Use pci_pme_active for clearing
 wake-up events and disabling PME# (was: Re: [regression] e100: PCI wake-up
 handling rework causes "Error clearing wake event")
Date: Wed, 10 Sep 2008 15:31:24 -0700
Message-ID: <20080910153124.8536a7db.akpm@linux-foundation.org>
References: <200809090812.37649.elendil@planet.nl>
	<200809091514.23817.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	elendil@planet.nl, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com, kernel-testers@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <200809091514.23817.rjw@sisk.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 9 Sep 2008 15:14:22 +0200
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> On Tuesday, 9 of September 2008, Frans Pop wrote:
> > (Resending because of error in mail headers in previous attempt; sorry)
> > 
> > On my Toshiba Satellite A40 with 2.6.27-rc4/5 I noticed the following 
> > error in the boot log (not there with 2.6.26):
> > e100: 0000:01:08.0: e100_probe: Error clearing wake event
> > 
> > Bisection has fingered the following patch as the cause of the message.
> > 
> > commit eb9d0fe40e313c0a74115ef456a2e43a6c8da72f
> > Author: Rafael J. Wysocki <rjw@sisk.pl>
> > Date:   Mon Jul 7 03:34:48 2008 +0200
> >     PCI ACPI: Rework PCI handling of wake-up
> > 
> > The test this error originates from in drivers/net/e100.c is old and has 
> > not changed recently.
> > 
> > Surrounding messages (full dmesg attached):
> > e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
> > e100: Copyright(c) 1999-2006 Intel Corporation
> > e100 0000:01:08.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
> > e100: 0000:01:08.0: e100_probe: Error clearing wake event
> > e100: eth0: e100_probe: addr 0xcffff000, irq 20, MAC addr 
> > 00:08:0d:17:bf:f5
> > 
> > The NIC is:
> > 01:08.0 Ethernet controller [0200]: Intel Corporation 82801DB PRO/100 VE 
> > (MOB) Ethernet Controller [8086:103d] (rev 83)
> >         Kernel driver in use: e100
> 
> The message is actually harmless, but I agree that it's confusing.
> 
> The appended patch should fix the problem (ISTR sending it some time ago
> already).
> 
> Thanks,
> Rafael
> 
> ---
> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> e100: Use pci_pme_active for clearing wake-up events and disabling PME#
> 
> Currently e100 uses pci_enable_wake() to clear pending wake-up events
> and disable PME# during intitialization, but that function is not
> suitable for this purpose, because it immediately returns error code
> if device_may_wakeup() returns false for given device.
> 
> Make e100 use pci_pme_active(), which carries out exactly the
> required operations, instead.
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> ---
>  drivers/net/e100.c |    4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> Index: linux-2.6/drivers/net/e100.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/e100.c
> +++ linux-2.6/drivers/net/e100.c
> @@ -2738,9 +2738,7 @@ static int __devinit e100_probe(struct p
>  		nic->flags |= wol_magic;
>  
>  	/* ack any pending wake events, disable PME */
> -	err = pci_enable_wake(pdev, 0, 0);
> -	if (err)
> -		DPRINTK(PROBE, ERR, "Error clearing wake event\n");
> +	pci_pme_active(pdev, false);
>  
>  	strcpy(netdev->name, "eth%d");
>  	if((err = register_netdev(netdev))) {

This change is already included in

e100-adapt-to-the-reworked-pci-pm.patch:

  From: "Rafael J. Wysocki" <rjw@sisk.pl>
  
  Adapt the e100 driver to the reworked PCI PM
  
  * Use device_set_wakeup_enable() and friends as needed
  * Use pci_pme_active() to clear PME_Status and disable PME#
  * Use the observation that it is sufficient to call pci_enable_wake()
    once, unless it fails
  
  Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
  Tested-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
  Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
  Cc: Jesse Barnes <jbarnes@virtuousgeek.org>
  Cc: Jeff Garzik <jeff@garzik.org>
  Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
  

which I sent to Jeff on Aug 20 as a for-2.6.28 thing.

Maybe I should just mark e100-adapt-to-the-reworked-pci-pm.patch as a
for-2.6.27 thing next time I send that (large) pile of maybe-for-2.6.27
netdev patches.

e100-adapt-to-the-reworked-pci-pm.patch
drivers-net-skfp-pmfc-use-offsetof-macro.patch
drivers-net-atl1e-dont-take-the-mdio_lock-in-atl1e_probe.patch
e1000e-prevent-corruption-of-eeprom-nvm.patch
drivers-net-mlx4-allocc-needs-mmh.patch
net-forcedeth-call-restore-mac-addr-in-nv_shutdown-path-v2.patch
ehea-fix-dlpar-memory-handling.patch
nec-fix-rmmod-platform-driver-improvements.patch
nec-fix-suspend-and-resume-for-isa-pnp-cards.patch


-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
