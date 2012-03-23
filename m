From: <Parav.Pandit-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH 2/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Fri, 23 Mar 2012 07:03:37 -0700
Message-ID: <88B766C272F2C64B944B21AD078333151C964A67E0@EXMAIL.ad.emulex.com>
References: <CAL1RGDVxCE--P78bk0Me5o+ekSzgBYG0UJT6y3O7cK3mUGBjuQ@mail.gmail.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6EB4@saturn3.aculab.com>
 <88B766C272F2C64B944B21AD078333151C964A66EF@EXMAIL.ad.emulex.com>
 <20120322205824.GC9614@obsidianresearch.com>
 <88B766C272F2C64B944B21AD078333151C964A670B@EXMAIL.ad.emulex.com>
 <3ae9829d-f8dd-4268-918a-94616eff0915@exht1.ad.emulex.com>
 <20120322224429.GA12980@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>, <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120322224429.GA12980-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Jason Gunthorpe [mailto:jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org]
> Sent: Friday, March 23, 2012 4:14 AM
> To: Pandit, Parav
> Cc: David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org; roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org; linux-
> rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: Re: [PATCH 2/9] ocrdma: Driver for Emulex OneConnect RDMA
> adapter
> 
> On Thu, Mar 22, 2012 at 02:20:28PM -0700, Parav.Pandit-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org
> wrote:
> > I got a question here lately.
> >
> > aligned directive will ensure that it will fall on boundary.  Say
> > aligned(4) ensures that structure is aligned to 4 byte boundary.
> > Compiler can (at least theoretically) still have 4 byte structure
> > aligned to 8 byte boundary on 64-bit platform (which is 4 byte aligned
> > too).
> 
> There are very specific rules defined in the platform's ABI for how C
> structures are layed out in memory, each ABI (ie CPU) has its own specific
> quirks, but broadly in Linux land you can boil it down to:
> 
> 1) The alignment of a structure is the greatest alignment of all the
>    members
> 2) Each member is aligned to its alignment.
> 
> The alignment of the structure drives the total size of the structure, and
> specifically the padding added at the end to reach that alignment.
> 
> So, no, a compiler that increased the alignment of a struct with one
> u32 to 8 would violate the various ABIs and not be usuable for Linux. It is
> important to bear in mind that Linux targets a particular set of ABI
> conventions, and it is not 'anything goes'.
> 
> > struct {
> > 	u32 field;
> > };
> 
> So in this case: the u32 is aligned to 4, the structure is aligned to
> 4 and the total size of the structure is 4 on everything linux supports.
> 
> > struct {
> >       u64 fielda
> > 	u32 field;
> > };
> 
> In this case: On 64 bit: the u64 is aligned to 8 and the u32 is aligned to 4. So
> the structure is aligned to 8. A pad is inserted at the end of the struct to bring
> it out. On 32 bit, the u64 is aligned to 4, so the struct is aligned to 4, so no pad
> is added.
> 
> > struct {
> >       __float128 fielda
> > 	u32 field;
> > };
> 
> In this case the float128 is aligned to 16 and thus the structure is aligned to 16
> and 12 pad bytes are added.
> 
> > However requirement is to have this structure only 4 byte size(
> > because adapter excepts it to be 4B sise) and therefor packed is used.
> > I don't know the way to ensure size of 4 byte and alignment too.  Or I
> > am misunderstanding?
> 
> Yes, you are mis-understanding the rules for padding.. Structures are only
> padded out to their alignment, which depends on their constituent types.
> This is so arrays of structures have each array element starting on its natural
> alignment.
> 
> The aligned attribute overrides the automatic determination of the
> alignment based on the contents and just forces it.
> 
> So, as an example, if you have this hardware layout:
> 
> struct {
>   u32 fielda;
>   u64 fieldb;
> } attribute ((aligned(4));
> 
> David is saying you will get a 12 byte struct and fieldb will be unaligned. Since
> 12 is aligned to 4 no padding is added.

So I decided to experiment above example before implementing in driver. However I find structure of 16 bytes (instead of 12) with padding after fielda in below example.
Am I missing some compiler option or syntax error in attribute? Sorry to ask this silly question.
I tried __attribute__((__aligned__(4))); too based on usage in other kernel code.

#include <linux/module.h>

struct foo {
        u32 a;
        u64 b;
} __attribute__((aligned(4)));

static int __init main_init(void)
{
        printk("<1> sizeof foo=%ld\n", sizeof(struct foo));
        printk("<1> offset of a=%ld\n", offsetof(struct foo, a));
        printk("<1> offset of b=%ld\n", offsetof(struct foo, b));
        return 0;
}
static void __exit main_exit(void)
{
}
module_init(main_init);
module_exit(main_exit);
Output:
Mar 24 05:44:10 parav-sles11-sp1-64 kernel: [2006356.094931]  sizeof foo=16
Mar 24 05:44:10 parav-sles11-sp1-64 kernel: [2006356.094934]  offset of a=0
Mar 24 05:44:10 parav-sles11-sp1-64 kernel: [2006356.094936]  offset of b=8

Gcc version is below.

Using built-in specs.
Target: x86_64-suse-linux
Configured with: ../configure --prefix=/usr --infodir=/usr/share/info --mandir=/usr/share/man --libdir=/usr/lib64 --libexecdir=/usr/lib64 --enable-languages=c,c++,objc,fortran,obj-c++,java,ada --enable-checking=release --with-gxx-include-dir=/usr/include/c++/4.3 --enable-ssp --disable-libssp --with-bugurl=http://bugs.opensuse.org/ --with-pkgversion='SUSE Linux' --disable-libgcj --disable-libmudflap --with-slibdir=/lib64 --with-system-zlib --enable-__cxa_atexit --enable-libstdcxx-allocator=new --disable-libstdcxx-pch --enable-version-specific-runtime-libs --program-suffix=-4.3 --enable-linux-futex --without-system-libunwind --with-cpu=generic --build=x86_64-suse-linux
Thread model: posix
gcc version 4.3.4 [gcc-4_3-branch revision 152973] (SUSE Linux)

> For hardware facing structures I'd combine this with a static assert to verify
> structure size at compile time.
> 
> So..
> 
> 1) Avoid using attributes unless the structure has unaligned members.
> 2) Avoid creating structures with unaligned members (eg for userspace
>    communication)
> 3) Frown at hardware/firmware developers who make communication
>    structures with unaligned members :)
> 4) Be explicit about padding in your layout for 64/32
>    compatibility.
> 
> Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
