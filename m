From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] af_unix: fix a fatal race with bit fields
Date: Tue, 30 Apr 2013 19:24:20 -0700
Message-ID: <1367375060.11020.24.camel@edumazet-glaptop>
References: <1367370761.11020.22.camel@edumazet-glaptop>
	 <20130501115103.58e40f37@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org,
	Paul Mackerras <paulus@samba.org>,
	Ambrose Feinstein <ambrose@google.com>, amodra@gmail.com
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:57903 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933347Ab3EACYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 22:24:23 -0400
Received: by mail-da0-f41.google.com with SMTP id p8so503883dan.28
        for <netdev@vger.kernel.org>; Tue, 30 Apr 2013 19:24:23 -0700 (PDT)
In-Reply-To: <20130501115103.58e40f37@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-01 at 11:51 +1000, Anton Blanchard wrote:
> Hi Eric,
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Using bit fields is dangerous on ppc64, as the compiler uses 64bit
> > instructions to manipulate them. If the 64bit word includes any
> > atomic_t or spinlock_t, we can lose critical concurrent changes.
> > 
> > This is happening in af_unix, where unix_sk(sk)->gc_candidate/
> > gc_maybe_cycle/lock share the same 64bit word.
> > 
> > This leads to fatal deadlock, as one/several cpus spin forever
> > on a spinlock that will never be available again.
> 
> I just spoke to Alan Modra and he suspects this is a compiler
> bug. Can you give us your compiler version info?

$ gcc-4.6.3-nolibc/powerpc64-linux/bin/powerpc64-linux-gcc -v
Using built-in specs.
COLLECT_GCC=gcc-4.6.3-nolibc/powerpc64-linux/bin/powerpc64-linux-gcc
COLLECT_LTO_WRAPPER=/usr/local/google/home/edumazet/cross/gcc-4.6.3-nolibc/powerpc64-linux/bin/../libexec/gcc/powerpc64-linux/4.6.3/lto-wrapper
Target: powerpc64-linux
Configured with: /home/tony/buildall/src/gcc/configure
--target=powerpc64-linux --host=x86_64-linux-gnu
--build=x86_64-linux-gnu --enable-targets=all
--prefix=/opt/cross/gcc-4.6.3-nolibc/powerpc64-linux/
--enable-languages=c --with-newlib --without-headers
--enable-sjlj-exceptions --with-system-libunwind --disable-nls
--disable-threads --disable-shared --disable-libmudflap --disable-libssp
--disable-libgomp --disable-decimal-float --enable-checking=release
--with-mpfr=/home/tony/buildall/src/sys-x86_64
--with-gmp=/home/tony/buildall/src/sys-x86_64 --disable-bootstrap
--disable-libquadmath
Thread model: single
gcc version 4.6.3 (GCC) 


$ cat try.c ; gcc-4.6.3-nolibc/powerpc64-linux/bin/powerpc64-linux-gcc
-O2 -S try.c ; cat try.s
struct s {
	unsigned int lock;
	unsigned int f1 : 1;
	unsigned int f2 : 1;
	void *ptr;
} *p ;

showbug()
{
	p->lock++;
	p->f1 = 1;
}
	.file	"try.c"
	.section	".toc","aw"
	.section	".text"
	.section	".toc","aw"
.LC0:
	.tc p[TC],p
	.section	".text"
	.align 2
	.globl showbug
	.section	".opd","aw"
	.align 3
showbug:
	.quad	.L.showbug,.TOC.@tocbase,0
	.previous
	.type	showbug, @function
.L.showbug:
	addis 9,2,.LC0@toc@ha
	ld 9,.LC0@toc@l(9)
	ld 9,0(9)
	lwz 11,0(9)
	addi 0,11,1
	stw 0,0(9)
	li 11,1
	ld 0,0(9)
	rldimi 0,11,31,32
	std 0,0(9)
	blr
	.long 0
	.byte 0,0,0,0,0,0,0,0
	.size	showbug,.-.L.showbug
	.comm	p,8,8
	.ident	"GCC: (GNU) 4.6.3"

You can see "ld 0,0(9)" is used : its a 64 bit load.
