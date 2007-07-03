From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based PCI Express adapters...
Date: Mon, 2 Jul 2007 17:16:48 -0700
Message-ID: <200707021716.49637.inaky@linux.intel.com>
References: <4688F512.3030801@garzik.org> <46897934.5040101@garzik.org> <468990D8.6040604@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Michael Buesch <mb@bu3sch.de>,
	Christoph Hellwig <hch@infradead.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org, arjan@linux.intel.com,
	akpm@linux-foundation.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:32513 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756014AbXGCAQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 20:16:57 -0400
In-Reply-To: <468990D8.6040604@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 02 July 2007, Kok, Auke wrote:
> Jeff Garzik wrote:
> > Michael Buesch wrote:
> >> On Tuesday 03 July 2007 00:02:57 Kok, Auke wrote:
> >>> well, FWIW when I started looking at adding these flags I looked in various 
> >>> subsystems in the kernel and picked an implementation that suited. Guess what 
> >>> pci.h has? ...:
> >>>
> >>> 	unsigned int msi_enabled:1;
> >>> 	unsigned int msix_enabled:1;
> >>>
> >>> this is literally where I copied the example from
> >>>
> >>> I suppose I can fix those, but I really don't understand what all the fuzz is 
> >>> about here. We're only conserving memory and staying far away from the real 
> >> I'm not sure if these bitfields actually _do_ conserve memory.
> >> Generated code gets bigger (need bitwise masks and stuff).
> >> Code also needs memory. It probably only conserves memory, if the
> >> structure is instanciated a lot.
> > 
> > Actually, that's a good point.  On several RISC architectures it 
> > certainly generates bigger code.
> 
>...
>
> but let's stay constructive here:
> 
> ~/git/linux-2.6 $ grep -r 'unsigned int.*:1;' * | wc -l
> 748
> 
> Is anyone going to fix those? If we don't, someone will certainly again submit 
> patches to add more of these bitfields, after all, some very prominent parts of 
> the kernel still use them. Only recently for instance mac80211 merged like 30 of 
> these.... and drivers/net, include etc.. certainly has a lot of these.

I don't think bitfields are broken. Maybe it's the compiler what should be fixed (*)

...bitfields are there to save the coder having to type masks by hand. There should 
be no difference in the generated code from doing

u32 value = readl(fromsomewhere);
printf("bits 16 & 15 0x%08x\n", value & 0x00018000 >> 15);

union {
  struct {
    u32 reserved1:15;
    u32 val:2;
   } __attribute__((packed))
   u32 data;
} value;
value.data = readl(fromsomewhere);
printf("bits 16 & 15 0x%08x\n", value.val);

Granted, that looks big, but once you nail it out at your struct definitons, it
makes maintenance much easier when looking at the bitmasks in the specs. Masks and
shifts tend to suck on the long term when they accumulate.

-- Inaky


(*) not to mention the endianness mess
