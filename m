From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] pci: Export the pci_restore_msi_state() function
Date: Sun, 21 Oct 2007 21:45:20 -0700 (PDT)
Message-ID: <20071021.214520.66310568.davem@davemloft.net>
References: <20071021.162131.43417026.davem@davemloft.net>
	<1551EAE59135BE47B544934E30FC4FC002AABB04@nt-irva-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linas@austin.ibm.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35064
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750989AbXJVEpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 00:45:07 -0400
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC002AABB04@nt-irva-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Sun, 21 Oct 2007 21:01:17 -0700

> David Miller wrote:
> 
> > I'm not so sure about this.
> > 
> > Perhaps, instead, you should do a pci_msi_disable() and
> > pci_msi_enable() in the error detection and recovery sequence.
> 
> If we just detected PCI errors on this slot, I don't think it's
> a good idea to continue writing to the config space to disable
> MSI.  Perhaps we can disable/enable after the slot reset.

Right, it would have to be after the slot reset.

> > Or, alternatively, save/restore those MSI registers by hand.
> 
> We can do that, but we'll have to do it ahead of time when we enable
> MSI, not after errors have been detected.  But the address/data can
> change as the CPU affinity changes during run time, right?

Yes, it can.

The core issue is that the ARCH level MSI code invokes
write_msi_msg(), not the generic code, exactly because there
are platform level issues wherein the firmware is the only
legal way to write the MSI settings in PCI config space.

However, the MSI state restore code was not architected similarly.  It
does the write_msi_msg() directly, instead of letting platform level
code is in ARCH hooks.

Therefore I think we need to attack this in two stages:

1) First changeset moves the write_msi_msg() call currently in
   __pci_restore_msi_state() into an ARCH overridable handler.

   This would allow powerpc to deal with this properly.

   pci_restor_msi_state() can get exported to modules in this
   change

2) The Tigon3 error recovery changes, as they were.

But I have to ask, can anyone see how e1000 handles MSI properly
in it's PCI error support?
