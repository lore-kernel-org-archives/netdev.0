From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] openvswitch: Fix alignment of struct sw_flow_key.
Date: Thu, 05 Sep 2013 12:47:00 -0700
Message-ID: <1378410420.1944.45.camel@joe-AO722>
References: <1378402887-17331-1-git-send-email-jesse@nicira.com>
	 <20130905.141751.945639989861997124.davem@davemloft.net>
	 <CAEP_g=8gcCtkv=no=HkVmS+NDWPM-Uu-SVyR+vb-YQ=7TWJsXA@mail.gmail.com>
	 <20130905.144044.1053960608071929025.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, netdev@vger.kernel.org, dev@openvswitch.org,
	azhou@nicira.com, fengguan.wu@intel.com, geert@linux-m68k.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:44774 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753914Ab3IETrC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Sep 2013 15:47:02 -0400
In-Reply-To: <20130905.144044.1053960608071929025.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-05 at 14:40 -0400, David Miller wrote:
> From: Jesse Gross <jesse@nicira.com>
> Date: Thu, 5 Sep 2013 11:36:19 -0700
> > On Thu, Sep 5, 2013 at 11:17 AM, David Miller <davem@davemloft.net> wrote:
> >> From: Jesse Gross <jesse@nicira.com>
> >> Date: Thu,  5 Sep 2013 10:41:27 -0700
> >>
> >>> -} __aligned(__alignof__(long));
> >>> +} __aligned(8); /* 8 byte alignment ensures this can be accessed as a long */
> >>
> >> This kind of stuff drives me crazy.
> >>
> >> If the issue is the type, therefore at least use an expression that
> >> mentions the type explicitly.  And mention the actual type that
> >> matters.  "long" isn't it.
> > 
> > 'long' actually is the real type here.
> > 
> > When doing comparisons, this structure is being accessed as a byte
> > array in 'long' sized chunks, not by its members. Therefore, the
> > compiler's alignment does not necessarily correspond to anything for
> > this purpose. It could be a struct full of u16's and we would still
> > want to access it in chunks of 'long'.
> > 
> > To completely honest, I think the correct alignment should be
> > sizeof(long) because I know that 'long' is not always 8 bytes on all
> > architectures. However, you made the point before that this could
> > break the alignment of the 64-bit values on architectures where 'long'
> > is 32 bits wide, so 8 bytes is the generic solution.
> 
> Look at net/core/flow.c:flow_key_compare().
> 
> And then we annotate struct flowi with
> 
> } __attribute__((__aligned__(BITS_PER_LONG/8)));
> 
> Don't reinvent the wheel, either mimick how existing code does
> this kind of thing or provide a justification for doing it differently
> and update the existing cases to match and be consistent.

I think using the BITS_PER_LONG #define is pretty odd
as it's set using a test for CONFIG_64BIT and that

	__aligned(__alignof__(long))
or
	__aligned(sizeof(long))

may be simpler to read. That first would allow
architectures that can read any long on an arbitrary
boundary to pack the structure as densely as possible.
That may not work if the entire structure is always
read with via long *.

If so, my choice would be to standardize using

} __aligned(sizeof(long));

Currently, what happens to a struct that isn't
actually a multiple of long bytes?  Are these
structs guaranteed to be zero padded right now?

Also, what happens for structs like:

struct foo {
	u8	bar[6];
	long	baz;
	u8	qux[2];
} __aligned(sizeof(long));

where the padding may or may not exist if
__packed is also specified?

btw:

all the __attribute__((__aligned__(foo)...)) and
__aligned(...) / __packed(...) uses could be rewritten
to a more standard style.

$ grep -rP --include=*.[ch] -oh "\b__aligned[^\(\n_]*\s*\([^;\n]+[;\n]" * | \
  sed -r -e 's/\s//g' -e 's/\)[^\)]*$/\)/' | sort | uniq -c
      3 __aligned(1)
      3 __aligned(16)
      1 __aligned(1<<WORK_STRUCT_FLAG_BITS)
     12 __aligned(2)
      7 __aligned(32)
     32 __aligned(4)
      8 __aligned(64)
     15 __aligned(8)
      1 __aligned(__alignof__(long))
      3 __aligned(__CACHE_WRITEBACK_GRANULE)
      1 __aligned((IOR_DMA_OFFSET_BITS/IOR_BPC))
      1 __aligned((IOR_PHYS_OFFSET_BITS/IOR_BPC))
      1 __aligned(LOG_ALIGN)
      2 __aligned(NETDEV_ALIGN)
     10 __aligned(PAGE_SIZE)
      2 __aligned(sizeof(s64))
      4 __aligned(sizeof(u16))
      2 __aligned(sizeof(u32))
      7 __aligned(sizeof(void*))

$ grep -rP --include=*.[ch] -oh "\b__attribute.*aligned[^\(\n]*\s*\([^;\n]+[;\n]" * | \
  sed -r -e 's/\s//g' -e 's/\)[^\)]*$/\)/' | sort | uniq -c
      2 __attribute__((aligned(0x100)))
      1 __attribute__((aligned(0x2000)))
      2 __attribute__((aligned(0x20000)))
      1 __attribute__((__aligned__(0x400)))
      3 __attribute__((aligned(0x80)))
      1 __attribute__((aligned(1024),packed))
      2 __attribute__((__aligned__(128)))
      9 __attribute__((__aligned__(16)))
     30 __attribute__((aligned(16)))
      2 __attribute__((aligned(1),packed))
      1 __attribute__((aligned(2)))
      1 __attribute__((aligned(2048)))
     14 __attribute__((aligned(256)))
      1 __attribute__((aligned(256),packed))
      5 __attribute__((aligned(2),packed))
      1 __attribute__((aligned(2*sizeof(long))))
      1 __attribute((aligned(2*sizeof(unsignedlong))))
      3 __attribute__((__aligned__(32)))
     53 __attribute__((aligned(32)))
      2 __attribute__((aligned(32),packed))
      2 __attribute__((__aligned__(4)))
     22 __attribute__((aligned(4)))
      2 __attribute__((aligned(4096)))
      1 __attribute__((aligned(4<<10)))
      1 __attribute__((aligned(4),packed))
     18 __attribute__((aligned(64)))
      1 __attribute__((aligned(65536)))
     15 __attribute__((__aligned__(8)))
     89 __attribute__((aligned(8)))
      2 __attribute__((aligned(a)))
      5 __attribute__((aligned(__alignof__(structebt_replace))))
      1 __attribute__((aligned(__alignof__(structhash_alg_common))))
      1 __attribute__((aligned(__alignof__(u32))))
      1 __attribute__((aligned(ATOMIC_HASH_L2_SIZE*4)))
      4 __attribute__((__aligned__(BITS_PER_LONG/8)))
      1 __attribute__((aligned(BUFFER_SIZE)))
      2 __attribute__((aligned(CHIP_L2_LINE_SIZE())))
      1 __attribute__((aligned(CPPI_DESCRIPTOR_ALIGN)))
      1 __attribute__((aligned(DM_IO_MAX_REGIONS)))
      1 __attribute__((aligned(HV_PAGE_TABLE_ALIGN)))
      1 __attribute__((aligned(_K_SS_ALIGNSIZE)))
      1 __attribute__((aligned(L1_CACHE_BYTES)))
      3 __attribute__((aligned(L2_CACHE_BYTES)))
      1 __attribute__((__aligned__(NETDEV_ALIGN)))
      3 __attribute__((__aligned__(PADLOCK_ALIGNMENT)))
      4 __attribute__((__aligned__(PAGE_SIZE)))
      7 __attribute__((aligned(PAGE_SIZE)))
      1 __attribute__((aligned(PS3_BMP_MINALIGN)))
      2 __attribute__((aligned(sizeof(Elf##size##_Word))))
      1 __attribute__((aligned(sizeof(int))))
      1 __attribute__((aligned(sizeof(__kernel_size_t))))
      1 __attribute__((aligned(sizeof(kernel_ulong_t))))
      7 __attribute__((aligned(sizeof(long))))
      1 __attribute__((aligned(sizeof(s64))))
      1 __attribute__((__aligned__(sizeof(structxencomm_mini))))
      1 __attribute__((aligned(sizeof(__u64))))
      8 __attribute__((aligned(sizeof(uint64_t))))
      6 __attribute__((aligned(sizeof(unsignedlong))))
      1 __attribute__((__aligned__(sizeof(void*))))
      1 __attribute__((aligned(sizeof(void*))))
      7 __attribute__((__aligned__(SMP_CACHE_BYTES)))
      6 __attribute__((aligned(SMP_CACHE_BYTES)))
      1 __attribute__((aligned(stackalign)))
      1 __attribute__((aligned(THREAD_SIZE)))
      1 __attribute__((aligned(TSB_ENTRY_ALIGNMENT)))
      1 __attribute__((aligned(XCHAL_CP0_SA_ALIGN)))
      1 __attribute__((aligned(XCHAL_CP1_SA_ALIGN)))
      1 __attribute__((aligned(XCHAL_CP2_SA_ALIGN)))
      1 __attribute__((aligned(XCHAL_CP3_SA_ALIGN)))
      1 __attribute__((aligned(XCHAL_CP4_SA_ALIGN)))
      1 __attribute__((aligned(XCHAL_CP5_SA_ALIGN)))
      1 __attribute__((aligned(XCHAL_CP6_SA_ALIGN)))
      1 __attribute__((aligned(XCHAL_CP7_SA_ALIGN)))
      2 __attribute__((aligned(XCHAL_NCP_SA_ALIGN)))
      1 __attribute__((packed,aligned(1024)))
      1 __attribute__((packed,__aligned__(16)))
      4 __attribute__((packed,aligned(16)))
      7 __attribute__((packed,aligned(2)))
      1 __attribute__((packed,aligned(2048)))
      4 __attribute__((packed,aligned(256)))
    177 __attribute__((packed,aligned(4)))
      2 __attribute__((packed,aligned(4096)))
      2 __attribute__((packed,aligned(64)))
     47 __attribute__((packed,aligned(8)))
      2 __attribute__((packed,aligned(PAGE_SIZE)))
      1 __attribute__((packed,aligned(PMCRAID_IOADL_ALIGNMENT)))
      2 __attribute__((packed,aligned(PMCRAID_IOARCB_ALIGNMENT)))
      1 __attribute__((__section__(".data..vm0.pgd"),aligned(PAGE_SIZE)))
      1 __attribute__((__section__(".data..vm0.pmd"),aligned(PAGE_SIZE)))
      1 __attribute__((__section__(".data..vm0.pte"),aligned(PAGE_SIZE)))
