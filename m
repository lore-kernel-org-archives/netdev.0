From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCHv3 perf/core 0/7] Reuse libbpf from samples/bpf
Date: Wed, 14 Dec 2016 11:55:12 -0300
Message-ID: <20161214145512.GQ5482@kernel.org>
References: <20161209024620.31660-1-joe@ovn.org>
 <20161209150907.GM8257@kernel.org>
 <584ACE2E.2090108@iogearbox.net>
 <20161214132501.GP5482@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        wangnan0@huawei.com, ast@fb.com
To: Daniel Borkmann <daniel@iogearbox.net>, Joe Stringer <joe@ovn.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161214132501.GP5482@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Wed, Dec 14, 2016 at 10:25:01AM -0300, Arnaldo Carvalho de Melo escreveu:
> Em Fri, Dec 09, 2016 at 04:30:54PM +0100, Daniel Borkmann escreveu:
> > On 12/09/2016 04:09 PM, Arnaldo Carvalho de Melo wrote:
> > > > v3: Add ack for first patch.
> > > >      Split out second patch from v2 into separate changes for remaining diff.
> > > >      Add patches to switch samples/bpf over to using tools/lib/.
> > > > v2: https://www.mail-archive.com/netdev@vger.kernel.org/msg135088.html
> > > >      Don't shift non-bpf code into libbpf.
> > > >      Drop the patch to synchronize ELF definitions with tc.
> > > > v1: https://www.mail-archive.com/netdev@vger.kernel.org/msg135088.html
> > > >      First post.

> > > Thanks, applied after addressing the -I$(objtree) issue raised by Wang,

> > [ Sorry for late reply. ]

> > First of all, glad to see us getting rid of the duplicate lib eventually! :)
> > 
> > Please note that this might result in hopefully just a minor merge issue
> > with net-next. Looks like patch 4/7 touches test_maps.c and test_verifier.c,
> > which moved to a new bpf selftest suite [1] this net-next cycle. Seems it's
> > just log buffer and some renames there, which can be discarded for both
> > files sitting in selftests.
> 
> Yeah, I've got to this point, and the merge has a little bit more than
> that, including BPF_PROG_ATTACH/BPF_PROG_DETACH, etc, working on it...

So, Joe, can you try refreshing this work, starting from what I have in
perf/core? It has the changes coming from net-next that Daniel warned us about
and some more.

[acme@jouet linux]$ git log --oneline -5
1f125a4aa4d8 tools lib bpf: Add flags to bpf_create_map()
5adf5614f72d tools lib bpf: use __u32 from linux/types.h
ff687c38d803 tools lib bpf: Sync {tools,}/include/uapi/linux/bpf.h
53452c69b4c3 perf annotate: Fix jump target outside of function address range
2f41ae602b57 perf annotate: Support jump instruction with target as second operand
[acme@jouet linux]$

I tried refreshing it, but it seems samples/bpf/ needs some love and
care first, as I can't get it to build before these patches, to make
sure nothing gets broken.

Trying to bisect it I get to what seems multiple bisect breakages, last
tag I got it to build, with lots of warnings, was v4.8, after that I get
things like the ones below.

I could try fixing it, but may be missing something, and want to push the other
stuff in this branch...

[acme@jouet linux]$ egrep SAMPLES\|BPF .config
CONFIG_BPF=y
CONFIG_BPF_SYSCALL=y
CONFIG_NETFILTER_XT_MATCH_BPF=m
CONFIG_NET_CLS_BPF=m
CONFIG_NET_ACT_BPF=m
CONFIG_BPF_JIT=y
CONFIG_HAVE_EBPF_JIT=y
CONFIG_BPF_EVENTS=y
# CONFIG_TEST_BPF is not set
CONFIG_SAMPLES=y
[acme@jouet linux]$ 

[acme@jouet linux]$ make -C samples/bpf
make: Entering directory '/home/acme/git/linux/samples/bpf'
make -C ../../ $PWD/
make[1]: Entering directory '/home/acme/git/linux'
  CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
  CHK     include/generated/timeconst.h
  CHK     include/generated/bounds.h
  CHK     include/generated/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  HOSTCC  /home/acme/git/linux/samples/bpf/bpf_load.o
In file included from /home/acme/git/linux/samples/bpf/bpf_load.c:21:0:
/home/acme/git/linux/samples/bpf/bpf_helpers.h:76:11: error: ‘BPF_FUNC_skb_in_cgroup’ undeclared here (not in a function)
  (void *) BPF_FUNC_skb_in_cgroup;
           ^~~~~~~~~~~~~~~~~~~~~~
scripts/Makefile.host:124: recipe for target '/home/acme/git/linux/samples/bpf/bpf_load.o' failed
make[2]: *** [/home/acme/git/linux/samples/bpf/bpf_load.o] Error 1
Makefile:1646: recipe for target '/home/acme/git/linux/samples/bpf/' failed

[acme@jouet linux]$ make -C samples/bpf
make: Entering directory '/home/acme/git/linux/samples/bpf'
make -C ../../ $PWD/
make[1]: Entering directory '/home/acme/git/linux'
scripts/kconfig/conf  --silentoldconfig Kconfig
#
# configuration written to .config
#
  SYSTBL  arch/x86/entry/syscalls/../../include/generated/asm/syscalls_32.h
  SYSHDR  arch/x86/entry/syscalls/../../include/generated/asm/unistd_32_ia32.h
  SYSHDR  arch/x86/entry/syscalls/../../include/generated/uapi/asm/unistd_32.h
  CHK     include/config/kernel.release
  UPD     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  UPD     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
  UPD     include/generated/utsrelease.h
  CHK     include/generated/timeconst.h
  CC      kernel/bounds.s
  CHK     include/generated/bounds.h
  GEN     scripts/gdb/linux/constants.py
  CC      arch/x86/kernel/asm-offsets.s
  CHK     include/generated/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  HOSTCC  /home/acme/git/linux/samples/bpf/bpf_load.o
In file included from /home/acme/git/linux/samples/bpf/bpf_load.c:21:0:
/home/acme/git/linux/samples/bpf/bpf_helpers.h:49:11: error: ‘BPF_FUNC_current_task_under_cgroup’ undeclared here (not in a function)
  (void *) BPF_FUNC_current_task_under_cgroup;
           ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/home/acme/git/linux/samples/bpf/bpf_helpers.h:80:11: error: ‘BPF_FUNC_skb_in_cgroup’ undeclared here (not in a function)
  (void *) BPF_FUNC_skb_in_cgroup;
           ^~~~~~~~~~~~~~~~~~~~~~
scripts/Makefile.host:124: recipe for target '/home/acme/git/linux/samples/bpf/bpf_load.o' failed
