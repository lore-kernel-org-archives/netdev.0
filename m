From: Dave Chinner <david@fromorbit.com>
Subject: Re: [xfs-masters] linux-next: arm allmodconfig
Date: Wed, 29 Oct 2008 18:40:32 +1100
Message-ID: <20081029074032.GI4985@disturbed>
References: <20081028175604.81c31cea.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	Dave Airlie <airlied@linux.ie>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Moore <paul.moore@hp.com>, Takashi Iwai <tiwai@suse.de>,
	Pekka Enberg <penberg@cs.helsinki.fi>
To: xfs-masters@oss.sgi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail01.adl6.internode.on.net ([203.16.214.146]:41462 "EHLO
	ipmail01.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752448AbYJ2Hkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 03:40:37 -0400
Content-Disposition: inline
In-Reply-To: <20081028175604.81c31cea.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2008 at 05:56:04PM -0700, Andrew Morton wrote:
> > fs/xfs/quota/xfs_qm_syscalls.c: In function `xfs_qm_dqrele_inodes_ag':
> > fs/xfs/quota/xfs_qm_syscalls.c:1039: warning: 'inode_refed' might be used uninitialized in this function

I haven't seen this one before. And it's a real bug, too.
gcc-4.3.1 on x86_64 is not picking this warning up:

$ gcc -v
Using built-in specs.
Target: x86_64-linux-gnu
Configured with: ../src/configure -v --with-pkgversion='Debian 4.3.1-9' --with-bugurl=file:///usr/share/doc/gcc-4.3/README.Bugs --enable-languages=c,c++,fortran,objc,obj-c++ --prefix=/usr --enable-shared --with-system-zlib --libexecdir=/usr/lib --without-included-gettext --enable-threads=posix --enable-nls --with-gxx-include-dir=/usr/include/c++/4.3 --program-suffix=-4.3 --enable-clocale=gnu --enable-libstdcxx-debug --enable-objc-gc --enable-mpfr --enable-cld --enable-checking=release --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-gnu
Thread model: posix
gcc version 4.3.1 (Debian 4.3.1-9)
$
$
$ touch fs/xfs/quota/xfs_qm_syscalls.c
$ make -j2 ARCH=um
  SYMLINK arch/um/include/shared/kern_constants.h
make[1]: `arch/um/sys-x86_64/user-offsets.s' is up to date.
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CALL    scripts/checksyscalls.sh
  CHK     include/linux/compile.h
  CC      fs/xfs/quota/xfs_qm_syscalls.o
  LD      fs/xfs/xfs.o
  LD      fs/xfs/built-in.o
  LD      fs/built-in.o

What compiler version are you using?

I'll send out a patch to fix this in a minute.

> > fs/xfs/xfs_rtalloc.c: In function `xfs_growfs_rt':
> > fs/xfs/xfs_rtalloc.c:1875: warning: 'tp' might be used uninitialized in this function

False positive, and I don't get this reported, either.

Hold on - the above gcc binary only emits a warning for the xfs_growfs_rt issue
when CONFIG_CC_OPTIMIZE_FOR_SIZE=y is set. It still doesn't catch the quota
bug, though. This is so fucked up....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
