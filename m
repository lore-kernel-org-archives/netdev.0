From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: atl1 64-bit => 32-bit DMA borkage (reproducible, bisected)
Date: Tue, 6 May 2008 11:02:25 -0500
Message-ID: <20080506110225.31fd61a4@osprey.hogchain.net>
References: <20080419111719.GA6724@martell.zuzino.mipt.ru>
	<20080419144535.GA4814@martell.zuzino.mipt.ru>
	<20080419215444.2d4623f5@osprey.hogchain.net>
	<20080420111453.GA4902@martell.zuzino.mipt.ru>
	<20080420060607.2b1be48b@osprey.hogchain.net>
	<20080420122631.GA4761@martell.zuzino.mipt.ru>
	<20080420133704.63f5cc10@osprey.hogchain.net>
	<20080420205500.GA4762@martell.zuzino.mipt.ru>
	<20080421210821.28053a92@osprey.hogchain.net>
	<20080425195743.2bfe66ee@osprey.hogchain.net>
	<20080504211507.GC1040@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	Chris Snook <csnook@redhat.com>, Jeff Garzik <jeff@garzik.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christoph Lameter <clameter@sgi.com>, torvalds@osdl.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost05.isp.att.net ([207.115.11.55]:47376 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759544AbYEFQC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 12:02:29 -0400
In-Reply-To: <20080504211507.GC1040@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 May 2008 01:15:07 +0400
Alexey Dobriyan <adobriyan@gmail.com> wrote:

> Looking at how other netdevice drivers:
> 
> 8139too and others checks netif_running() in interrupt handler.
> 
> r8169 has scary "50k$" question comment re irqs disabled after
> interacting with hardware.
> 
> But the r8169 case should be fixed by atlx_irq_disable()?
> 
> Writes to REG_IMR, REG_ISR are commented in atl1_reset_hw(), why?
> (I'll test that soon)

I've tried all the stuff you mentioned above, and more, to prevent the
memory corruption, all to no avail.

I booted with mem=4000M and didn't hit the bug.  I diffed dmesg between
booting with mem=4000M and booting without it, and found that iommu
was being disabled when booting with full memory:

--- dmesg-4000.txt      2008-05-06 10:14:07.000000000 -0500
+++ dmesg-4096.txt      2008-05-06 10:09:19.000000000 -0500
@@ -1,5 +1,5 @@
 Linux version 2.6.26-rc1 (jcliburn@finch.hogchain.net) (gcc version 4.1.2 20070
925 (Red Hat 4.1.2-27)) #4 SMP Mon May 5 18:03:48 CDT 2008
-Command line: ro root=LABEL=/1 console=ttyS0,38400 console=tty0 slub_debug=FZPU mem=4000M
+Command line: ro root=LABEL=/1 console=ttyS0,38400 console=tty0 slub_debug=FZPU
[...]
+Looks like a VIA chipset. Disabling IOMMU. Override with iommu=allowed
[...]

So I then booted with iommu=allowed.  No errors.  Can't hit the bug to
save my life.

Why would disabling iommu cause the atl1 driver to write over poisoned
memory?

Alexey, can you please try booting with iommu=allowed and see if you
avoid the problem?

Thanks,
Jay
