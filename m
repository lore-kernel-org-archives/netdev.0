From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/2] [PCI] Check that MWI bit really did get set
Date: Sat, 14 Oct 2006 23:53:59 -0700
Message-ID: <20061014235359.6d65647d.akpm@osdl.org>
References: <1160161519800-git-send-email-matthew@wil.cx>
	<20061013214135.8fbc9f04.akpm@osdl.org>
	<20061014140249.GL11633@parisc-linux.org>
	<20061014134855.b66d7e65.akpm@osdl.org>
	<20061015032000.GP11633@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Val Henson <val_henson@linux.intel.com>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:42160 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752496AbWJOGyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2006 02:54:08 -0400
To: Matthew Wilcox <matthew@wil.cx>
In-Reply-To: <20061015032000.GP11633@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 14 Oct 2006 21:20:01 -0600
Matthew Wilcox <matthew@wil.cx> wrote:

> On Sat, Oct 14, 2006 at 01:48:55PM -0700, Andrew Morton wrote:
> > On Sat, 14 Oct 2006 08:02:49 -0600
> > Matthew Wilcox <matthew@wil.cx> wrote:
> > 
> > > On Fri, Oct 13, 2006 at 09:41:35PM -0700, Andrew Morton wrote:
> > > > Bisection shows that this patch
> > > > (pci-check-that-mwi-bit-really-did-get-set.patch in Greg's PCI tree) breaks
> > > > suspend-to-disk on my Vaio.  It writes the suspend image and gets to the
> > > > point where it's supposed to power down, but doesn't.
> > > 
> > > How odd.  What driver is calling pci_set_mwi() on the suspend path?
> > 
> > ehci_pci_reinit().  I stuck a dump_stack() in there.  See
> > http://userweb.kernel.org/~akpm/s5000342.jpg
> 
> Thanks for the picture; that's really helpful.
> 
> I see.  We hibernate all the devices then wake them all back up again.
> No doubt there's a good reason for this.
> 
> Still doesn't make much sense, though.  As far as I can see, the only
> consequence of this particular patch is that 1) we do an additional read
> from PCI_COMMAND and 2) we can return -EINVAL in one additional case.
> But the only effect of returning EINVAL is a printk (for this particular
> driver):
> 
>         /* PCI Memory-Write-Invalidate cycle support is optional (uncommon) */
>         retval = pci_set_mwi(pdev);
>         if (!retval)
>                 ehci_dbg(ehci, "MWI active\n");
> 
>         ehci_port_power(ehci, 0);
> 
>         return 0;
> 
> So even if we return EINVAL ... big deal.
> 
> Is it possible reading PCI_COMMAND too quickly after writing it causes
> a foul-up?  That would be weird ...
> 
> so I suppose there's a few things I can ask you to try:

It seems to have stopped happening.  I don't know why.

gregkh-pci-pci-prevent-user-config-space-access-during-power-state-transitions.patch
still breaks suspend though: http://userweb.kernel.org/~akpm/s5000349.jpg
