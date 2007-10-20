From: linas@austin.ibm.com (Linas Vepstas)
Subject: [BUG] powerpc does not save msi state [was Re: [PATCH 5/7] pci: Export the pci_restore_msi_state() function
Date: Fri, 19 Oct 2007 19:46:10 -0500
Message-ID: <20071020004610.GR29903@austin.ibm.com>
References: <20071019232926.GL29903@austin.ibm.com> <1192840577.5369.9.camel@dell> <20071020000421.GO29903@austin.ibm.com> <20071019.172706.57467960.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, mcarlson@broadcom.com, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz,
	Michael Ellerman <michael@ellerman.id.au>
To: David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:38562 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751278AbXJTAqh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 20:46:37 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9K0kWHK025506
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2007 20:46:32 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9K0kWCQ062398
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2007 20:46:32 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9K0kLNA013361
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2007 20:46:22 -0400
Content-Disposition: inline
In-Reply-To: <20071019.172706.57467960.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Fri, Oct 19, 2007 at 05:27:06PM -0700, David Miller wrote:
> From: linas@austin.ibm.com (Linas Vepstas)
> Date: Fri, 19 Oct 2007 19:04:21 -0500
> 
> > I'm working in linux-2.6.23-rc8-mm1 at the moment, and I don't see
> > that happening. viz. read_msi_msg() is not called anywhere, and I need
> > to have valid msg->address_lo and msg->address_hi and msg->data
> > in order to be able to restore.
> 
> See the pci_restore_msi_state() call done from pci_restore_state()
> in drivers/pci/pci.c, that pci_restore_msi_state() code in
> drivers/pci/msi.c very much relies upon the entry->msg values
> being uptodate and valid.
> 
> The MSI arch layer code is supposed to fill the entry->msg values in
> via arch_setup_msi_irq().  Perhaps the pseries code is forgetting to
> do that.

Yep.  Thank you for confirming the correct location for the fix.

FWIW, it looks like not all that many arches do this; the output
for grep -r address_hi * is pretty thin. Then, looking at
i386/kernel/io_apic.c as an example, one can see that the 
msi state save happens "by accident" if CONFIG_SMP is enabled;
and so its surely broekn on uniprocesor machines.

I'm cc'ing the powerpc mailing list to point this out: 
it looks like only cell/axon_msi.c and mpic_u3msi.c 
bother do do anything.  I guess that there aren't any old 
macintosh laptops that have msi on them? Because without
this, suspend and resume breaks.

Paul,
On the off chance your reading this, I'll send a pseries
patch on Monday, with luck (and some other patches too).
I'm not touching any of the other plaforms, you and benh 
would know those better.

--linas
