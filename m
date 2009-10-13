From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH 2/8] bitmap: Introduce bitmap_set, bitmap_clear,
	bitmap_find_next_zero_area
Date: Tue, 13 Oct 2009 11:18:18 +0900
Message-ID: <20091013021818.GA3898@localhost.localdomain>
References: <1255076961-21325-1-git-send-email-akinobu.mita@gmail.com> <1255076961-21325-2-git-send-email-akinobu.mita@gmail.com> <20091009164100.85a36188.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	"David S. Miller" <davem@davemloft.net>,
	sparclinux@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Lothar Wassmann <LW@KARO-electronics.de>,
	linux-usb@vger.kernel.org, Roland Dreier <rolandd@cisco.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	netdev@vger.kernel.org, Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org,
	linux-altix@sgi.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-ia64-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091009164100.85a36188.akpm@linux-foundation.org>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 09, 2009 at 04:41:00PM -0700, Andrew Morton wrote:
> On Fri,  9 Oct 2009 17:29:15 +0900
> Akinobu Mita <akinobu.mita@gmail.com> wrote:
> 
> > This introduces new bitmap functions:
> > 
> > bitmap_set: Set specified bit area
> > bitmap_clear: Clear specified bit area
> > bitmap_find_next_zero_area: Find free bit area
> > 
> > These are stolen from iommu helper.
> > 
> > I changed the return value of bitmap_find_next_zero_area if there is
> > no zero area.
> > 
> > find_next_zero_area in iommu helper: returns -1
> > bitmap_find_next_zero_area: return >= bitmap size
> 
> I'll plan to merge this patch into 2.6.32 so we can trickle all the
> other patches into subsystems in an orderly fashion.

Sounds good.

> > +void bitmap_set(unsigned long *map, int i, int len)
> > +{
> > +	int end = i + len;
> > +
> > +	while (i < end) {
> > +		__set_bit(i, map);
> > +		i++;
> > +	}
> > +}
> 
> This is really inefficient, isn't it?  It's a pretty trivial matter to
> romp through memory 32 or 64 bits at a time.

OK. I'll do

> > +unsigned long bitmap_find_next_zero_area(unsigned long *map,
> > +					 unsigned long size,
> > +					 unsigned long start,
> > +					 unsigned int nr,
> > +					 unsigned long align_mask)
> > +{
> > +	unsigned long index, end, i;
> > +again:
> > +	index = find_next_zero_bit(map, size, start);
> > +
> > +	/* Align allocation */
> > +	index = (index + align_mask) & ~align_mask;
> > +
> > +	end = index + nr;
> > +	if (end >= size)
> > +		return end;
> > +	i = find_next_bit(map, end, index);
> > +	if (i < end) {
> > +		start = i + 1;
> > +		goto again;
> > +	}
> > +	return index;
> > +}
> > +EXPORT_SYMBOL(bitmap_find_next_zero_area);
> 
> This needs documentation, please.  It appears that `size' is the size
> of the bitmap and `nr' is the number of zeroed bits we're looking for,
> but an inattentive programmer could get those reversed.
> 
> Also the semantics of `align_mask' could benefit from spelling out.  Is
> the alignment with respect to memory boundaries or with respect to
> `map' or with respect to map+start or what?

OK. I will document it.

And I plan to change bitmap_find_next_zero_area() to take the alignment
instead of an align_mask as Roland said.

> And why does align_mask exist at all?  I was a bit surprised to see it
> there.  In which scenarios will it be non-zero?

Because the users of iommu-helper and mlx4 need the alignment requirement
for the zero area.

arch/powerpc/kernel/iommu.c
arch/x86/kernel/amd_iommu.c
arch/x86/kernel/pci-gart_64.c
drivers/net/mlx4/alloc.c

