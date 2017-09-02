From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: Problem compiling iproute2 on older systems
Date: Sat, 2 Sep 2017 09:55:24 +0200
Message-ID: <20170902075523.aton5r4p4bgcupra@unicorn.suse.cz>
References: <bf2c63d1-42cc-7fd3-7d79-945feabda50e@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50402 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751510AbdIBHzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 2 Sep 2017 03:55:25 -0400
Content-Disposition: inline
In-Reply-To: <bf2c63d1-42cc-7fd3-7d79-945feabda50e@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 01, 2017 at 04:52:20PM -0700, Ben Greear wrote:
> In the patch below, usage of __kernel_ulong_t and __kernel_long_t is
> introduced, but that is not available on older system (fedora-14, at least).
> 
> It is not a #define, so I am having trouble finding a quick hack
> around this.
> 
> Any ideas on how to make this work better on older OSs running
> modern kernels?
> 
> 
> Author: Stephen Hemminger <stephen@networkplumber.org>  2017-01-12 17:54:39
> Committer: Stephen Hemminger <stephen@networkplumber.org>  2017-01-12 17:54:39
> Child:  c7ec7697e3f000359aa317394e6dd972e35c1f84 (Fix build on fedora-14 (and other older systems))
> Branches: master, remotes/origin/master
> Follows: v3.10.0
> Precedes:
> 
>     add more uapi header files
> 
>     In order to ensure no backward/forward compatiablity problems,
>     make sure that all kernel headers used come from the local copy.
> 
>     Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> --------------------------- include/linux/sysinfo.h ---------------------------
> new file mode 100644
> index 0000000..934335a
> @@ -0,0 +1,24 @@
> +#ifndef _LINUX_SYSINFO_H
> +#define _LINUX_SYSINFO_H
> +
> +#include <linux/types.h>
> +
> +#define SI_LOAD_SHIFT	16
> +struct sysinfo {
> +	__kernel_long_t uptime;		/* Seconds since boot */
> +	__kernel_ulong_t loads[3];	/* 1, 5, and 15 minute load averages */
> +	__kernel_ulong_t totalram;	/* Total usable main memory size */
> +	__kernel_ulong_t freeram;	/* Available memory size */
> +	__kernel_ulong_t sharedram;	/* Amount of shared memory */
> +	__kernel_ulong_t bufferram;	/* Memory used by buffers */
> +	__kernel_ulong_t totalswap;	/* Total swap space size */
> +	__kernel_ulong_t freeswap;	/* swap space still available */
> +	__u16 procs;		   	/* Number of current processes */
> +	__u16 pad;		   	/* Explicit padding for m68k */
> +	__kernel_ulong_t totalhigh;	/* Total high memory size */
> +	__kernel_ulong_t freehigh;	/* Available high memory size */
> +	__u32 mem_unit;			/* Memory unit size in bytes */
> +	char _f[20-2*sizeof(__kernel_ulong_t)-sizeof(__u32)];	/* Padding: libc5 uses this.. */
> +};
> +
> +#endif /* _LINUX_SYSINFO_H */

I've been already thinking about this a bit. Normally, we would simply
add the file where __kernel_long_t and __kernel_ulong_t are defined.
The problem is this is <asm/posix_types.h> which depends on
architecture - which is the point of these types.

Good thing is iproute2 doesn't actually use struct sysinfo anywhere so
we don't need to have them defined correctly. One possible workaround
would therefore be defining them as long and unsigned long. As long as
we don't use the types anywhere, we would be fine.

Another option would be to replace include/linux/sysinfo.h with an empty
file. The problem I can see with this is that if someone uses a script
to refresh all copies of uapi headers automatically, the script would
have to be aware that it must not update this file and preserve the fake
empty one.

Compiling with -D_LINUX_SYSINFO_H should also do the trick but it seems
to be a bit dirty.

Michal Kubecek
