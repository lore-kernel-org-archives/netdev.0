From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH 2/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Fri, 23 Mar 2012 09:41:25 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6EB7@saturn3.aculab.com>
References: <20120322224429.GA12980@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Jason Gunthorpe" <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	<Parav.Pandit-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <20120322224429.GA12980-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 
> > struct {
> >       u64 fielda
> > 	u32 field;
> > };
> 
> In this case: On 64 bit: the u64 is aligned to 8 and the u32 
> is aligned to 4. So
> the structure is aligned to 8. A pad is inserted at the end of the
> struct to bring it out. On 32 bit, the u64 is aligned to 4, so the
> struct is aligned to 4, so no pad is added.

That is true for 32bit i386, some 32bit ABI may require 64bit
alignment for 64bit items.

...
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
> David is saying you will get a 12 byte struct and fieldb will be
> unaligned. Since 12 is aligned to 4 no padding is added.

I was actually suggesting defining (modulo syntax errors):
typedef u64 u64_aligned_8 attribute ((aligned(8));

Then you can define:
struct foo {
	u32 fielda;
	u64_aligned_8 fieldb;
};
and know that the aligment should be the same on all systems.
(But I'd still add the explicit pad in the above.)

This is actually more useful when you need to process structures
that have misaligned 64bit items - as happens when doing 'compat 32'
code in a 64bit kernel. Or trying to map the x86 disk mbr.

> For hardware facing structures I'd combine this with a static assert
> to verify structure size at compile time.

Also useful if you need to ensure a structure doesn't accidentally
change size when you need to preserve a userspace interface.

> So..
> 
> 1) Avoid using attributes unless the structure has unaligned members.
> 2) Avoid creating structures with unaligned members (eg for userspace
>    communication)
> 3) Frown at hardware/firmware developers who make communication
>    structures with unaligned members :)
> 4) Be explicit about padding in your layout for 64/32
>    compatibility.

Agreed.

	David
 


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
