From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [Bugme-new] [Bug 14737] New: e1000e driver experiences large
 packet losses
Date: Mon, 7 Dec 2009 13:53:10 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.0912071340480.2420@jbrandeb-mobl2.amr.corp.intel.com>
References: <bug-14737-10286@http.bugzilla.kernel.org/> <20091207131900.19c776ed.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "xenoterracide@gmail.com" <xenoterracide@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37501 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965065AbZLGVxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2009 16:53:06 -0500
In-Reply-To: <20091207131900.19c776ed.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thanks akpm, I've been watching this thread but now I will try to jump in.

Caleb, can you please summarize where we are today, you've done a lot of 
testing and the thread has gone on a while.

Kernels known to fail (after any length):

Kernels known to work:

Have you been able to try the latest e1000e from 2.6.32?  it has some 
fixes in it, although none right off the top of my head that will fix your 
issue.

I have a couple of related questions, why don't you have irqbalance 
enabled?  Network interrupts should not be migrating across all cpus 
evenly, at the very least your system should be reconfigured to lock the 
interrupts to a particular core with smp_affinity.


           CPU0       CPU1       CPU2       CPU3       
  0:        119         59         69         70   IO-APIC-edge      timer
  1:          1          2          1          0   IO-APIC-edge      i8042
  6:          0          1          0          1   IO-APIC-edge      floppy
  8:        185        178        175        180   IO-APIC-edge      rtc0
  9:          0          0          0          0   IO-APIC-fasteoi   acpi
 12:          0          1          2          3   IO-APIC-edge      i8042
 16:     761720     767583     765772     762262   IO-APIC-fasteoi   uhci_hcd:usb3, EMU10K1
 17:          2          1          0          0   IO-APIC-fasteoi   ohci1394
 18:          0          0          0          2   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb8
 19:     192022     191598     191809     191886   IO-APIC-fasteoi   uhci_hcd:usb5, uhci_hcd:usb7
 21:          0          1          1          3   IO-APIC-fasteoi   uhci_hcd:usb4, eth0
 23:      19600      19263      19489      19502   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
 25:     419910     412980     411109     416834   PCI-MSI-edge      i915
 26:     233236     233744     233647     233567   PCI-MSI-edge      ahci
 27:     709493     708677     709630     708963   PCI-MSI-edge      eth1
NMI:          0          0          0          0   Non-maskable interrupts
LOC:   10375694    9592098    6283658    6319369   Local timer interrupts
SPU:          0          0          0          0   Spurious interrupts
PMI:          0          0          0          0   Performance monitoring interrupts
PND:          0          0          0          0   Performance pending work
RES:      50103      49240      47545      45606   Rescheduling interrupts
CAL:      74174        408      71586        453   Function call interrupts
TLB:      49410      53567      50409      52426   TLB shootdowns
TRM:          0          0          0          0   Thermal event interrupts
THR:          0          0          0          0   Threshold APIC interrupts
MCE:          0          0          0          0   Machine check exceptions
MCP:        271        271        271        271   Machine check polls
ERR:          0
MIS:          0

There is nothing in the ethtool -S statistics that I see that indicates 
anything is wrong, you've gotten no tx timeouts as far as I can tell, have 
you had any system panics (possibly seeming unrelated to network?)


On Mon, 7 Dec 2009, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Sat, 5 Dec 2009 07:02:49 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=14737
> > 
> >            Summary: e1000e driver experiences large packet losses
> >            Product: Drivers
> >            Version: 2.5
> >     Kernel Version: 2.6.32--
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Network
> >         AssignedTo: drivers_network@kernel-bugs.osdl.org
> >         ReportedBy: xenoterracide@gmail.com
> >         Regression: No
> > 
> > 
> > possibly related to this bug #13835 same symptoms and I upped a lot of info for
> > this bug on there.
> > 
> > Also Read this thread http://marc.info/?t=125699907100001&r=1&w=2
> > 
> > I have thus far been able to find similar symptoms all the way back to 2.6.29.6
> > I've not yet done testing farther. problem is intermittent. It does not appear
> > to affect another nic on the system (however testing of that hasn't been
> > extensive,and a different driver). if I do not reboot the computer and the bug
> > hasn't manifested, it will not manifest (perhaps unless I reload modules or
> > restart interfaces (not tested).
> > 
> 
> 
