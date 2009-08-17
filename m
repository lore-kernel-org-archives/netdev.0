From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: Very strange issues with ethernet wake on lan
Date: Mon, 17 Aug 2009 12:16:28 +0300
Message-ID: <1250500588.4301.5.camel@localhost.localdomain>
References: <1250394174.32268.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-pm@lists.linux-foundation.org"
	<linux-pm@lists.linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:63547 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757525AbZHQJQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 05:16:33 -0400
Received: by fg-out-1718.google.com with SMTP id e12so364671fga.17
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 02:16:33 -0700 (PDT)
In-Reply-To: <1250394174.32268.13.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-08-16 at 06:42 +0300, Maxim Levitsky wrote:
> Hi,
> 
> I have recently put back the davicom dm9009 ethernet card into my
> computer.
> 
> Some long time ago, I have written its suspend/resume routines.
> Now I see that few things have changed, like I need to enable wake in
> sysfs or better patch the code to do so, some nice helpers like
> pci_prepare_to_sleep have arrived, etc.
> 
> 
> I narrowed the strange issue down to following situation:
> 
> I reload dmfe.ko (and networkmanager is disabled)
> I don't ifup the device, thus pretty much no hardware initialization
> takes place (but this appears not to matter anyway)
> 
> I then suspend the system, and WOL doesn't work (I have patched the
> driver to enable WOL automaticly)
> 
> I then, suspend again. WOL works, and continues to work as long as I
> don't reload the driver. If I do, same situation repeats.
> 
> Also, after a boot, WOL works, so a reload cycle triggers that issue.
> 
> And most importantly, if I don't do a
> 
> pci_set_power_state(pci_dev, pci_choose_state (pci_dev, state));
> 
> in .suspend, then WOL always works.
> 
> and I have even tried to set state manually to PCI_D3hot or PCI_D3cold, 
> 
> I also tried to use pci_save_state
> 
> 
> I also have 2 copies of this card, and both have this issue.
> I also tried 2 pci slots.
> 
> Kernel is vanilla 2.6.31-rc5


Bisect reveals:

44e4e66eeae5338b3ca0b28f8352e60bf18d5ba8 is first bad commit
commit 44e4e66eeae5338b3ca0b28f8352e60bf18d5ba8
Author: Rafael J. Wysocki <rjw@sisk.pl>
Date:   Mon Jul 7 03:32:52 2008 +0200

    PCI: rework pci_set_power_state function to call platform first
    
    Rework pci_set_power_state() so that the platform callback is
    invoked before the native mechanism, if necessary.  Also, make
    the function check if the device is power manageable by the
    platform before invoking the platform callback.
    
    This may matter if the device dependent on additional power
    resources controlled by the platform is being put into D0, in which
    case those power resources must be turned on before we attempt to
    handle the device itself.
    
    Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
    Acked-by: Pavel Machek <pavel@suse.cz>
    Signed-off-by: Jesse Barnes <jbarnes@virtuousgeek.org>


Note that probably this device has no acpi entries, because it is an
addon card, bios knows nothing about it


Best regards,
	Maxim Levitsky


