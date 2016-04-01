From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] samples/bpf: Use llc in PATH, rather than a
 hardcoded value
Date: Fri, 1 Apr 2016 20:07:51 +0530
Message-ID: <20160401143751.GF17907@naverao1-tp.ibm.com>
References: <922f95fb5d16686367a66d2d4bd176149a87e9ad.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
 <ba23d688b3550c3f22dd0dd6d5cb1233c2f34816.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
 <56FD627D.5080405@fb.com>
 <56FD6A2C.2010506@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@fb.com>, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56FD6A2C.2010506@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/03/31 08:19PM, Daniel Borkmann wrote:
> On 03/31/2016 07:46 PM, Alexei Starovoitov wrote:
> >On 3/31/16 4:25 AM, Naveen N. Rao wrote:
> >>      clang $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
> >>          -D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
> >>-        -O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
> >>+        -O2 -emit-llvm -c $< -o -| llc -march=bpf -filetype=obj -o $@
> >>      clang $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
> >>          -D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
> >>-        -O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=asm -o $@.s
> >>+        -O2 -emit-llvm -c $< -o -| llc -march=bpf -filetype=asm -o $@.s
> >
> >that was a workaround when clang/llvm didn't have bpf support.
> >Now clang 3.7 and 3.8 have bpf built-in, so make sense to remove
> >manual calls to llc completely.
> >Just use 'clang -target bpf -O2 -D... -c $< -o $@'
> 
> +1, the clang part in that Makefile should also more correctly be called
> with '-target bpf' as it turns out (despite llc with '-march=bpf' ...).
> Better to use clang directly as suggested by Alexei.

I'm likely missing something obvious, but I cannot get this to work.  
With this diff:

	 $(obj)/%.o: $(src)/%.c
		clang $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
			-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
	-               -O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
	-       clang $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
	-               -D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
	-               -O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=asm -o $@.s
	+               -O2 -target bpf -c $< -o $@

I see far too many errors thrown starting with:

	clang  -nostdinc -isystem 
	/usr/lib/gcc/x86_64-redhat-linux/4.8.2/include 
	-I./arch/x86/include -Iarch/x86/include/generated/uapi 
	-Iarch/x86/include/generated  -Iinclude 
	-I./arch/x86/include/uapi -Iarch/x86/include/generated/uapi 
	-I./include/uapi -Iinclude/generated/uapi -include 
	./include/linux/kconfig.h  \
		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
		-O2 -target bpf -c samples/bpf/map_perf_test_kern.c -o samples/bpf/map_perf_test_kern.o
	In file included from samples/bpf/map_perf_test_kern.c:7:
	In file included from include/linux/skbuff.h:17:
	In file included from include/linux/kernel.h:10:
	In file included from include/linux/bitops.h:36:
	In file included from ./arch/x86/include/asm/bitops.h:500:
	./arch/x86/include/asm/arch_hweight.h:31:10: error: invalid output constraint '=a' in asm
			     : "="REG_OUT (res)
			       ^
	./arch/x86/include/asm/arch_hweight.h:59:10: error: invalid output constraint '=a' in asm
			     : "="REG_OUT (res)


What am I missing?


- Naveen
