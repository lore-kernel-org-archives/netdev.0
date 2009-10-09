From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/8] bitmap: Introduce bitmap_set, bitmap_clear,
	bitmap_find_next_zero_area
Date: Fri, 9 Oct 2009 16:41:00 -0700
Message-ID: <20091009164100.85a36188.akpm@linux-foundation.org>
References: <1255076961-21325-1-git-send-email-akinobu.mita@gmail.com>
	<1255076961-21325-2-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@suse.de>,
	linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>,
	x86@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-altix@sgi.com,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	linuxppc-dev@ozlabs.org, Ingo Molnar <mingo@redhat.com>,
	Paul Mackerras <paulus@samba.org>,
	"H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>, linux-usb@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Lothar Wassmann <LW@KARO-electronics.de>
To: Akinobu Mita <akinobu.mita@gmail.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1255076961-21325-2-git-send-email-akinobu.mita@gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Fri,  9 Oct 2009 17:29:15 +0900
Akinobu Mita <akinobu.mita@gmail.com> wrote:

> This introduces new bitmap functions:
> 
> bitmap_set: Set specified bit area
> bitmap_clear: Clear specified bit area
> bitmap_find_next_zero_area: Find free bit area
> 
> These are stolen from iommu helper.
> 
> I changed the return value of bitmap_find_next_zero_area if there is
> no zero area.
> 
> find_next_zero_area in iommu helper: returns -1
> bitmap_find_next_zero_area: return >= bitmap size

I'll plan to merge this patch into 2.6.32 so we can trickle all the
other patches into subsystems in an orderly fashion.

> +void bitmap_set(unsigned long *map, int i, int len)
> +{
> +	int end = i + len;
> +
> +	while (i < end) {
> +		__set_bit(i, map);
> +		i++;
> +	}
> +}

This is really inefficient, isn't it?  It's a pretty trivial matter to
romp through memory 32 or 64 bits at a time.

> +EXPORT_SYMBOL(bitmap_set);
> +
> +void bitmap_clear(unsigned long *map, int start, int nr)
> +{
> +	int end = start + nr;
> +
> +	while (start < end) {
> +		__clear_bit(start, map);
> +		start++;
> +	}
> +}
> +EXPORT_SYMBOL(bitmap_clear);

Ditto.

> +unsigned long bitmap_find_next_zero_area(unsigned long *map,
> +					 unsigned long size,
> +					 unsigned long start,
> +					 unsigned int nr,
> +					 unsigned long align_mask)
> +{
> +	unsigned long index, end, i;
> +again:
> +	index = find_next_zero_bit(map, size, start);
> +
> +	/* Align allocation */
> +	index = (index + align_mask) & ~align_mask;
> +
> +	end = index + nr;
> +	if (end >= size)
> +		return end;
> +	i = find_next_bit(map, end, index);
> +	if (i < end) {
> +		start = i + 1;
> +		goto again;
> +	}
> +	return index;
> +}
> +EXPORT_SYMBOL(bitmap_find_next_zero_area);

This needs documentation, please.  It appears that `size' is the size
of the bitmap and `nr' is the number of zeroed bits we're looking for,
but an inattentive programmer could get those reversed.

Also the semantics of `align_mask' could benefit from spelling out.  Is
the alignment with respect to memory boundaries or with respect to
`map' or with respect to map+start or what?

And why does align_mask exist at all?  I was a bit surprised to see it
there.  In which scenarios will it be non-zero?
