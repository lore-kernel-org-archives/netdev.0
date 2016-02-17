From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [linux-nics] e1000e: initialization breaks IPMI support on
	80003ES2LAN
Date: Wed, 17 Feb 2016 19:22:58 +0000
Message-ID: <87618083B2453E4A8714035B62D6799250577DB7@FMSMSX105.amr.corp.intel.com>
References: <20160212155847.GA22910@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Linux NICS <Linux-nics@isotope.jf.intel.com>,
	"Ertman, David M" <david.m.ertman@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Lucas Nussbaum <lucas.nussbaum@loria.fr>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:45019 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030290AbcBQTXR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 14:23:17 -0500
In-Reply-To: <20160212155847.GA22910@xanadu.blop.info>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: linux-nics-bounces@isotope.jf.intel.com [mailto:linux-nics-
>bounces@isotope.jf.intel.com] On Behalf Of Lucas Nussbaum
>Sent: Friday, February 12, 2016 7:59 AM
>To: Linux Kernel Network Developers <netdev@vger.kernel.org>
>Cc: Linux NICS <Linux-nics@isotope.jf.intel.com>; Ertman, David M
><david.m.ertman@intel.com>; Kirsher, Jeffrey T
><jeffrey.t.kirsher@intel.com>; e1000-devel@lists.sourceforge.net
>Subject: [linux-nics] e1000e: initialization breaks IPMI support on
>80003ES2LAN
>
>Hi,
>
>We have Intel 80003ES2LAN nics on SGI Altix XE310 servers (SuperMicro
>Baseboard, with product name X7DGT). On those machines, one of the NIC
>port is bridged internally with the BMC.
>
>It seems that during the e1000e driver initialization (at boot time),
>the NIC is reset, which causes the BMC to stop working (it stops
>responding to pings, the IPMI SOL console stops working; a reboot
>restores it, until the next driver initialization).
>
>The exact same problem also occurs on Bull Novascale R422E1 nodes, with
>the SuperMicro X7DWT baseboard.
>
>It worked in the past (we noticed it when upgrading from Debian wheezy
>(3.2 kernel) to Debian jessie (3.16 kernel)). Using git bisect, I tracked
>this down to commit 2800209994f878b00724ceabb65d744855c8f99a (included
>in Linux 3.15).
>
>Digging further (as this commit is quite large), it seems that this
>specific change introduced the problem:
>
>--- a/drivers/net/ethernet/intel/e1000e/netdev.c
>+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
>@@ -3687,10 +3687,6 @@ void e1000e_power_up_phy(struct e1000_adapter
>*adapter)
>  */
> static void e1000_power_down_phy(struct e1000_adapter *adapter)
> {
>-       /* WoL is enabled */
>-       if (adapter->wol)
>-               return;
>-
>        if (adapter->hw.phy.ops.power_down)
>                adapter->hw.phy.ops.power_down(&adapter->hw);
> }

The WOL check protected you before because it was always done inside
e1000_power_down_phy() and just so happened you had WOL enabled.

The power down PHY function has a check for manageability, but it's
not detecting it in your case.


>I also confirmed that reverting this change on top of a 4.4 kernel, with
>the following patch, fixes the problem (i.e. the BMC works again).
>
>--- a/drivers/net/ethernet/intel/e1000e/netdev.c
>+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
>@@ -3791,6 +3791,8 @@ void e1000e_power_up_phy(struct e1000_adapter
>*adapter)
>  */
> static void e1000_power_down_phy(struct e1000_adapter *adapter)
> {
>+       return;
>+
>        if (adapter->hw.phy.ops.power_down)
>                adapter->hw.phy.ops.power_down(&adapter->hw);
> }
>
>
>My understanding is that, during driver initialization, e1000e_reset()
>is called, which calls e1000_power_down_phy(), which breaks the BMC.

e1000_power_down_phy() is only called in reset if the interface is down.
If you are not using the interface, then you can blacklist the driver.
Otherwise bringing up the interface should power the PHY back up and 
restore the link for the BMC.

>Given the comment above the code that was removed, I suspected that it
>could also break WoL, but I haven't confirmed that.

For WOL the driver has to leave the PHY power on after shutdown - this
check was moved to __e1000_shutdown() from what I can see.

Thanks,
Emil
