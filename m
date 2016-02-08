From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH net-next v7 01/19] lib/bitmap.c: conversion routines
 to/from u32 array
Date: Mon, 8 Feb 2016 15:36:35 -0800
Message-ID: <20160208153635.67df5ac2576138088a859087@linux-foundation.org>
References: <1454893743-6285-1-git-send-email-ddecotig@gmail.com>
	<1454893743-6285-2-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eugenia Emantayev <eugenia-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Ido Shamay <idos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Govindarajulu Varadarajan <_govind-KK0ffGbhmjU@public.gmane.org>,
	Venkata Duvvuru <VenkatKumar.Duvvuru-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Ed Swierk <eswierk-FilZDy9cOaHkQYj/0HfcvtBPR1lH4CV8@public.gmane.org>,
	Robert Love <robert.w.love-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"James E.J. Bottomley" <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Yuval Mintz <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
	Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>,
	David Decotigny <decot@googlers
To: David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1454893743-6285-2-git-send-email-ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun,  7 Feb 2016 17:08:45 -0800 David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> From: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
> 
> Aimed at transferring bitmaps to/from user-space in a 32/64-bit agnostic
> way.
> 
> Tested:
>   unit tests (next patch) on qemu i386, x86_64, ppc, ppc64 BE and LE,
>   ARM.
> 
> @@ -1060,6 +1062,90 @@ int bitmap_allocate_region(unsigned long *bitmap, unsigned int pos, int order)
>  EXPORT_SYMBOL(bitmap_allocate_region);
>  
>  /**
> + * bitmap_from_u32array - copy the contents of a u32 array of bits to bitmap
> + *	@bitmap: array of unsigned longs, the destination bitmap, non NULL
> + *	@nbits: number of bits in @bitmap
> + *	@buf: array of u32 (in host byte order), the source bitmap, non NULL
> + *	@nwords: number of u32 words in @buf
> + *
> + * copy min(nbits, 32*nwords) bits from @buf to @bitmap, remaining
> + * bits between nword and nbits in @bitmap (if any) are cleared. In
> + * last word of @bitmap, the bits beyond nbits (if any) are kept
> + * unchanged.
> + */

This will leave the caller not knowing how many valid bits are actually
present in the resulting bitmap.  To determine that, the caller will
need to perform (duplicated) math on `nbits' and `nwords'.

> +void bitmap_from_u32array(unsigned long *bitmap, unsigned int nbits,
> +			  const u32 *buf, unsigned int nwords)

So how about we make this return the number of valid bits in *bitmap?

> +/**
> + * bitmap_to_u32array - copy the contents of bitmap to a u32 array of bits
> + *	@buf: array of u32 (in host byte order), the dest bitmap, non NULL
> + *	@nwords: number of u32 words in @buf
> + *	@bitmap: array of unsigned longs, the source bitmap, non NULL
> + *	@nbits: number of bits in @bitmap
> + *
> + * copy min(nbits, 32*nwords) bits from @bitmap to @buf. Remaining
> + * bits after nbits in @buf (if any) are cleared.
> + */
> +void bitmap_to_u32array(u32 *buf, unsigned int nwords,
> +			const unsigned long *bitmap, unsigned int nbits)

Ditto.
