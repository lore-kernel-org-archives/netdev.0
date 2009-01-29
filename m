From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Wed, 28 Jan 2009 18:10:37 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0901281757240.3123@localhost.localdomain>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <alpine.LFD.2.00.0901281636270.3123@localhost.localdomain> <alpine.DEB.2.00.0901282049040.5026@parag-desktop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Matt Carlson <mcarlson@broadcom.com>
To: Parag Warudkar <parag.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52331 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751302AbZA2CLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 21:11:00 -0500
In-Reply-To: <alpine.DEB.2.00.0901282049040.5026@parag-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 28 Jan 2009, Parag Warudkar wrote:
> 
> Sure, diff -u below. There are differences but not sure if they are 
> abnormal or expected.

Well, they're all in the "extended set", ie not the basic registers that 
the PCI layer saves. The PCI layer normally just saves the low 16 dwords, 
along with the PCI[EX] capability thing.

None of the PCI save/restore routines have ever saved the extended state 
(well, "ever" is a strong word - I think we long ago used to pass in how 
many bytes we wanted saved, but got rid of it), and it certainly didn't 
change with the recent PCI suspend/resume changes.

I get the feeling that it's some odd tg3 issue. That tg3 driver does have 
that special

        /* Make sure register accesses (indirect or otherwise)
         * will function correctly.
         */
        pci_write_config_dword(tp->pdev,
                               TG3PCI_MISC_HOST_CTRL,
                               tp->misc_host_ctrl);

in its own version of setting the power state, and maybe that really 
_must_ happen before we actually set the state back to PCI_D0. That sounds 
very odd, but hey..

I added Matt Carlson to the cc, since he seems to be the main tg3 
authority here.

Matt: the whole discussion is on netdev and the kernel mailing list, but 
the short version is that -rc3 suspends and resumes for Parag again 
(unlike -rc2), but tg3 doesn't appear to resume properly. The generic PCI 
layer now does more at resume time (very early, when interrupts are still 
off), see

 - pci_pm_resume_noirq ->
     pci_pm_default_resume_noirq() ->
       pci_restore_standard_config()

for more of the details (basically it always does that 
"pci_restore_state()" and tries to bring the device back to PCI_D0).

			Linus
