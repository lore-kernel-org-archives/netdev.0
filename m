From: "Michael K. Edwards" <medwards.linux@gmail.com>
Subject: Re: [PATCH 1/2] pcnet32: only allocate init_block dma consistent
Date: Wed, 7 Mar 2007 08:35:30 -0800
Message-ID: <f2b55d220703070835n16fbb052ub80be3e3e6d326a3@mail.gmail.com>
References: <20070306184523.GA23268@verizon.net>
	 <20070307031011.GA4281@linux-mips.org>
	 <f2b55d220703061939w731dfcc4t8e0ddcf238203bd@mail.gmail.com>
	 <20070307042155.GA6495@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Don Fry" <pcnet32@verizon.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: "Ralf Baechle" <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.237]:57131 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965254AbXCGQfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 11:35:32 -0500
Received: by wr-out-0506.google.com with SMTP id 57so348158wri
        for <netdev@vger.kernel.org>; Wed, 07 Mar 2007 08:35:31 -0800 (PST)
In-Reply-To: <20070307042155.GA6495@linux-mips.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/6/07, Ralf Baechle <ralf@linux-mips.org> wrote:
> Price question: why would this patch make a difference under VMware? :-)

Moving the struct pcnet32_private from the GFP_DMA32 init_block to the
GFP_KERNEL netdev allocation may be a win even on systems where
GFP_DMA32 is normally cached, because the private area will get read
ahead into cache when the netdev is touched.  (This could be a bigger
win if the most often accessed members were moved to the beginning of
the pcnet32_private struct.)

On the other hand, VMWare may engage in some sort of sleight of hand
to keep the low 16MB or more of the VM's memory contiguously allocated
and warm in the real MMU (locked hugepage TLB entries?  I'm
speculating).  So having allocated the private area as part of a
DMA-able page may have silently spared you a page fault on access.

On the third hand, the new layout will rarely be a problem if the
whole netdev (including private area) fits in one page, since if you
were going to take a page fault you took it when you looked into the
netdev.  So it's hard to see how it could cause a performance
regression unless VMWare loses its timeslice (and the TLB entry for
the page containing the netdev) in the middle of pcnet32_rx, etc.

Lennart is of course right that most VMWare VMs are using vmxnet
instead, but they're also using distro kernels.  :-)  I find VMWare
useful for certain kinds of kernel experimentation, and don't want to
fool with vmxnet every time I flip a kernel config switch.  Linus
kernels run just fine on VMWare Workstation using piix, mptspi, and
pcnet32 (I'm running vanilla 2.6.20.1 right now).  I would think that
changes to those drivers should be regression tested under VMWare, and
I'm happy to help.

Cheers,
- Michael
