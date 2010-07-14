From: Greg KH <greg@kroah.com>
Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Wed, 14 Jul 2010 14:06:06 -0700
Message-ID: <20100714210606.GA29786@kroah.com>
References: <20100504230225.GP8323@vmware.com> <201005051029.42052.dtor@vmware.com> <20100505173120.GA1752@infradead.org> <201005051035.29831.dtor@vmware.com> <20100505173951.GA8388@infradead.org> <20100505105253.0a8bc465@nehalam> <20100506202113.GC17922@infradead.org> <1278990388.32650.22.camel@eng-rhel5-64> <20100714094952.GA16209@kroah.com> <alpine.LRH.2.00.1007141335570.12881@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pankaj Thakkar <pthakkar@vmware.com>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.00.1007141335570.12881@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 14, 2010 at 01:42:59PM -0700, Shreyas Bhatewara wrote:
> +/* vmkernel and device backend shared definitions */
> +
> +#define VMXNET3_PLUGIN_NAME_LEN  256
> +#define VMXNET3_PLUGIN_REPOSITORY "/usr/lib/vmware/npa_plugins"

Why would the kernel care about this file path?  And since when do we
hard-code file paths in the kernel in the first place (yeah, in some
places we do, but not like this...)

> +#define NPA_MEMIO_REGIONS_u64X    6
> +
> +typedef u32 VF_ID;
> +
> +struct Vmxnet3_VFInfo {
> +	char     pluginName[VMXNET3_PLUGIN_NAME_LEN];

This is never used.

> +	u32   deviceInfo[VMXNET3_PLUGIN_INFO_LEN];	/* opaque data returned
> +							 * by PF driver */

This is happily copied around and zeroed out, but never actually used by
anything.


> +	u64       memioAddr;
> +	u32   memioLen;

This field is never used.

Why have fields in a structure that are never used?

> +};

<...>

> +/*
> + * Easy shell API calling macros.
> + */
> +#define Shell_AllocSmallBuffer(_state, _handle, _ringOffset)		\
> +	((_state)->shellApi.allocSmallBuffer((_handle), (_ringOffset)))
> +#define Shell_AllocLargeBuffer(_state, _handle, _ringOffset)		\
> +	((_state)->shellApi.allocLargeBuffer((_handle), (_ringOffset)))
> +#define Shell_FreeBuffer(_state, _handle, _ringOffset)			\
> +	((_state)->shellApi.freeBuffer((_handle), (_ringOffset)))
> +#define Shell_CompleteSend(_state, _handle, _numPkt)			\
> +	((_state)->shellApi.completeSend((_handle), (_numPkt)))
> +#define Shell_IndicateRecv(_state, _handle, _frame)			\
> +	((_state)->shellApi.indicateRecv((_handle), (_frame)))
> +#define Shell_Log(_state, _loglevel, _n, _fmt, ...)			\
> +	do {								\
> +		if (logEnabled && (_loglevel) <= (u32)logLevel) {	\
> +			(_state)->shellApi.log((_n) + 1,		\
> +					"%s: " _fmt,		\
> +					__func__,		\
> +##__VA_ARGS__);		\
> +		}							\
> +	} while (0)


This hiding of functions kind of implies that something odd is going on
here, right?  At the least, make them inline functions so you get the
proper typechecking warnings/errors in a format that you can understand.

> +/*
> + * Some standard definitions
> + */
> +#ifndef NULL
> +#define NULL (void *)0
> +#endif

What's wrong with the kernel-provided version of this?

> +/*
> + * Utility macro to write a register's value (BAR0)
> + */
> +#define VMXNET3_WRITE_REG(_state, _offset, _value)		\
> +	(*(u32 *)((u8 *)(_state)->memioAddr + (_offset)) =	\
> +	(_value))

This will never work, sorry.  Please use the proper functions for doing
this type of access.  I'm amazed that anyone even thought this would
succeed...

> +/*
> + * Utility macro to align a virtual address
> + */
> +#define ALIGN_VA(_ptr, _align) ((void *)(((uintptr_t)(_ptr) + ((_align) - 1)) &\
> +			~((_align) - 1)))

What's wrong with the kernel provided function for this?

Anyway, just randomly poking at the code like this turns up these types
of trivial issues, has this code ever been run?

wierd,

greg k-h
