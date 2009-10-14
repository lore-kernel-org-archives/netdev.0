From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH 2/8] bitmap: Introduce bitmap_set, bitmap_clear,
	bitmap_find_next_zero_area
Date: Wed, 14 Oct 2009 12:39:39 +0900
Message-ID: <20091014033939.GB18527@localhost.localdomain>
References: <1255076961-21325-1-git-send-email-akinobu.mita@gmail.com>
	<1255076961-21325-2-git-send-email-akinobu.mita@gmail.com>
	<20091009164100.85a36188.akpm@linux-foundation.org>
	<20091013021818.GA3898@localhost.localdomain>
	<20091013091017.GA18431@localhost.localdomain>
	<1255470887.21871.2.camel@concordia>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Fenghua Yu <fenghua.yu@intel.com>, x86@kernel.org,
	linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@suse.de>,
	linux-kernel@vger.kernel.org, linux-altix@sgi.com,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	linuxppc-dev@ozlabs.org, Tony Luck <tony.luck@intel.com>,
	Paul Mackerras <paulus@samba.org>,
	"H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-usb@vger.kernel.org, Ingo Molnar <mingo@redhat.com>,
	Lothar Wassmann <LW@KARO-electronics.de>
To: Michael Ellerman <michael@ellerman.id.au>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <1255470887.21871.2.camel@concordia>
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

On Wed, Oct 14, 2009 at 08:54:47AM +1100, Michael Ellerman wrote:
> On Tue, 2009-10-13 at 18:10 +0900, Akinobu Mita wrote:
> > My user space testing exposed off-by-one error find_next_zero_area
> > in iommu-helper.
> 
> Why not merge those tests into the kernel as a configurable boot-time
> self-test?

I send the test program that I used. Obviously it needs
better diagnostic messages and cleanup to be added into kernel tests.

#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>

#if 1 /* Copy and paste from kernel source */

#define BITS_PER_BYTE  8
#define BITS_PER_LONG (sizeof(long) * BITS_PER_BYTE)

#define BIT_WORD(nr)	((nr) / BITS_PER_LONG)
#define BITOP_WORD(nr)	((nr) / BITS_PER_LONG)

#define BITMAP_LAST_WORD_MASK(nbits)                                    \
(                                                                       \
        ((nbits) % BITS_PER_LONG) ?                                     \
                (1UL<<((nbits) % BITS_PER_LONG))-1 : ~0UL               \
)

#define BITMAP_FIRST_WORD_MASK(start) (~0UL << ((start) % BITS_PER_LONG))

void bitmap_set(unsigned long *map, int start, int nr)
{
	unsigned long *p = map + BIT_WORD(start);
	const int size = start + nr;
	int bits_to_set = BITS_PER_LONG - (start % BITS_PER_LONG);
	unsigned long mask_to_set = BITMAP_FIRST_WORD_MASK(start);

	while (nr - bits_to_set >= 0) {
		*p |= mask_to_set;
		nr -= bits_to_set;
		bits_to_set = BITS_PER_LONG;
		mask_to_set = ~0UL;
		p++;
	}
	if (nr) {
		mask_to_set &= BITMAP_LAST_WORD_MASK(size);
		*p |= mask_to_set;
	}
}

void bitmap_clear(unsigned long *map, int start, int nr)
{
	unsigned long *p = map + BIT_WORD(start);
	const int size = start + nr;
	int bits_to_clear = BITS_PER_LONG - (start % BITS_PER_LONG);
	unsigned long mask_to_clear = BITMAP_FIRST_WORD_MASK(start);

	while (nr - bits_to_clear >= 0) {
		*p &= ~mask_to_clear;
		nr -= bits_to_clear;
		bits_to_clear = BITS_PER_LONG;
		mask_to_clear = ~0UL;
		p++;
	}
	if (nr) {
		mask_to_clear &= BITMAP_LAST_WORD_MASK(size);
		*p &= ~mask_to_clear;
	}
}

static unsigned long __ffs(unsigned long word)
{
	int num = 0;

	if ((word & 0xffff) == 0) {
		num += 16;
		word >>= 16;
	}
	if ((word & 0xff) == 0) {
		num += 8;
		word >>= 8;
	}
	if ((word & 0xf) == 0) {
		num += 4;
		word >>= 4;
	}
	if ((word & 0x3) == 0) {
		num += 2;
		word >>= 2;
	}
	if ((word & 0x1) == 0)
		num += 1;
	return num;
}

unsigned long find_next_bit(const unsigned long *addr, unsigned long size,
			    unsigned long offset)
{
	const unsigned long *p = addr + BITOP_WORD(offset);
	unsigned long result = offset & ~(BITS_PER_LONG-1);
	unsigned long tmp;

	if (offset >= size)
		return size;
	size -= result;
	offset %= BITS_PER_LONG;
	if (offset) {
		tmp = *(p++);
		tmp &= (~0UL << offset);
		if (size < BITS_PER_LONG)
			goto found_first;
		if (tmp)
			goto found_middle;
		size -= BITS_PER_LONG;
		result += BITS_PER_LONG;
	}
	while (size & ~(BITS_PER_LONG-1)) {
		if ((tmp = *(p++)))
			goto found_middle;
		result += BITS_PER_LONG;
		size -= BITS_PER_LONG;
	}
	if (!size)
		return result;
	tmp = *p;

found_first:
	tmp &= (~0UL >> (BITS_PER_LONG - size));
	if (tmp == 0UL)		/* Are any bits set? */
		return result + size;	/* Nope. */
found_middle:
	return result + __ffs(tmp);
}

#define ffz(x)  __ffs(~(x))

unsigned long find_next_zero_bit(const unsigned long *addr, unsigned long size,
				 unsigned long offset)
{
	const unsigned long *p = addr + BITOP_WORD(offset);
	unsigned long result = offset & ~(BITS_PER_LONG-1);
	unsigned long tmp;

	if (offset >= size)
		return size;
	size -= result;
	offset %= BITS_PER_LONG;
	if (offset) {
		tmp = *(p++);
		tmp |= ~0UL >> (BITS_PER_LONG - offset);
		if (size < BITS_PER_LONG)
			goto found_first;
		if (~tmp)
			goto found_middle;
		size -= BITS_PER_LONG;
		result += BITS_PER_LONG;
	}
	while (size & ~(BITS_PER_LONG-1)) {
		if (~(tmp = *(p++)))
			goto found_middle;
		result += BITS_PER_LONG;
		size -= BITS_PER_LONG;
	}
	if (!size)
		return result;
	tmp = *p;

found_first:
	tmp |= ~0UL << size;
	if (tmp == ~0UL)	/* Are any bits zero? */
		return result + size;	/* Nope. */
found_middle:
	return result + ffz(tmp);
}

#define __ALIGN_MASK(x,mask) (((x)+(mask))&~(mask))

static inline int test_bit(int nr, const volatile unsigned long *addr)
{
	return 1UL & (addr[BIT_WORD(nr)] >> (nr & (BITS_PER_LONG-1)));
}

unsigned long bitmap_find_next_zero_area(unsigned long *map,
					 unsigned long size,
					 unsigned long start,
					 unsigned int nr,
					 unsigned long align_mask)
{
	unsigned long index, end, i;
again:
	index = find_next_zero_bit(map, size, start);

	/* Align allocation */
	index = __ALIGN_MASK(index, align_mask);

	end = index + nr;
#ifdef ORIGINAL
	if (end >= size)
#else
	if (end > size)
#endif
		return end;

#ifdef ORIGINAL
	for (i = index; i < end; i++) {
		if (test_bit(i, map)) {
			start = i+1;
			goto again;
		}
	}
#else
	i = find_next_bit(map, end, index);
	if (i < end) {
		start = i + 1;
		goto again;
	}
#endif
	return index;
}

#define DIV_ROUND_UP(n,d) (((n) + (d) - 1) / (d))
#define BITS_TO_LONGS(nr)       DIV_ROUND_UP(nr, BITS_PER_BYTE * sizeof(long))
#define DECLARE_BITMAP(name,bits) unsigned long name[BITS_TO_LONGS(bits)]

#endif /* Copy and paste from kernel source */

static DECLARE_BITMAP(bitmap, 1000);
static DECLARE_BITMAP(empty, 1000);
static DECLARE_BITMAP(full, 1000);

static void bitmap_dump(unsigned long *bitmap, int size)
{
	int i;

	for (i = 0; i < size; i++) {
		if (test_bit(i, bitmap))
			printf("1 ");
		else
			printf("0 ");
		if (i % 10 == 9)
			printf("\n");
	}
	printf("\n");
}

static int test1(int size)
{

	int start = random() % size;
	int nr = random() % (size - start);

	memset(bitmap, 0x00, BITS_TO_LONGS(size) * sizeof(unsigned long));

	bitmap_set(bitmap, start, nr);
	bitmap_clear(bitmap, start, nr);

	if (memcmp(empty, bitmap, BITS_TO_LONGS(size) * sizeof(unsigned long)))
		goto error;

	return 0;
error:
	bitmap_dump(bitmap, size);
	return 1;
}

int test2(int size)
{
	int start = random() % size;
	int nr = random() % (size - start);

	memset(bitmap, 0xff, BITS_TO_LONGS(size) * sizeof(unsigned long));

	bitmap_clear(bitmap, start, nr);
	bitmap_set(bitmap, start, nr);

	if (memcmp(full, bitmap, BITS_TO_LONGS(size) * sizeof(unsigned long)))
		goto error;

	return 0;
error:
	bitmap_dump(bitmap, size);
	return 1;
}

int test3(int size)
{
	int start = random() % size;
	int nr = random() % (size - start);
	unsigned long offset;

	memset(bitmap, 0x00, BITS_TO_LONGS(size) * sizeof(unsigned long));
	bitmap_set(bitmap, start, nr);
	if (start) {
		offset = bitmap_find_next_zero_area(bitmap, size, 0, start, 0);
		if (offset != 0) {
			printf("start %ld nr %ld\n", start, nr);
			printf("offset %ld != 0\n", offset);
			goto error;
		}
	}
	offset = bitmap_find_next_zero_area(bitmap, size, start,
						size - (start + nr), 0);
	if (offset != start + nr) {
		printf("start %ld nr %ld\n", start, nr);
		printf("offset %ld != size + nr %ld\n", offset, start + nr);
		goto error;
	}

	return 0;
error:
	bitmap_dump(bitmap, size);

	return 1;
}

int test4(int size)
{
	int start = random() % size;
	int nr = random() % (size - start);
	unsigned long offset;

	memset(bitmap, 0xff, BITS_TO_LONGS(size) * sizeof(unsigned long));
	bitmap_clear(bitmap, start, nr);
	offset = bitmap_find_next_zero_area(bitmap, size, start, nr, 0);
	if (nr != 0) {
		if (offset != start) {
			printf("start %ld nr %ld\n", start, nr);
			printf("offset %ld != start %ld\n", offset, start);
			goto error;
		}
	}
	return 0;
error:
	bitmap_dump(bitmap, size);

	return 1;
}

int main(int argc, char *argv[])
{
	int err = 0;

	srandom(time(NULL));

	memset(empty, 0x00, sizeof(empty));
	memset(full, 0xff, sizeof(full));

	while (!err) {
		err |= test1(1000);
		err |= test2(1000);
		err |= test3(1000);
		err |= test4(1000);
	}
	return 0;
}
