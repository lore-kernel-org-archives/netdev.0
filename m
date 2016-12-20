From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH perf/core REBASE 3/5] tools lib bpf: Add
 bpf_prog_{attach,detach}
Date: Tue, 20 Dec 2016 11:32:17 -0300
Message-ID: <20161220143217.GC32756@kernel.org>
References: <20161214224342.12858-1-joe@ovn.org>
 <20161214224342.12858-4-joe@ovn.org>
 <20161220141851.GB32756@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net
To: Joe Stringer <joe@ovn.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161220141851.GB32756@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Dec 20, 2016 at 11:18:51AM -0300, Arnaldo Carvalho de Melo escreveu:
> Em Wed, Dec 14, 2016 at 02:43:40PM -0800, Joe Stringer escreveu:
> > Commit d8c5b17f2bc0 ("samples: bpf: add userspace example for attaching
> > eBPF programs to cgroups") added these functions to samples/libbpf, but
> > during this merge all of the samples libbpf functionality is shifting to
> > tools/lib/bpf. Shift these functions there.
> > 
> > Signed-off-by: Joe Stringer <joe@ovn.org>
> > ---
> > Arnaldo, this is a new patch you didn't previously review which I've
> > prepared due to the conflict with net-next. I figured it's better to try
> > to get samples/bpf properly switched over this window rather than defer the
> > problem and end up having to deal with another merge problem next time
> > around. I hope that is fine for you. If not, this patch onwards will need
> > to be dropped
> > 
> > It's a simple copy/paste/delete with a minor change for sys_bpf() vs
> > syscall().
> > ---
> >  samples/bpf/libbpf.c | 21 ---------------------
> >  samples/bpf/libbpf.h |  3 ---
> >  tools/lib/bpf/bpf.c  | 21 +++++++++++++++++++++
> >  tools/lib/bpf/bpf.h  |  3 +++
> >  4 files changed, 24 insertions(+), 24 deletions(-)
> > 
> > diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
> > index 3391225ad7e9..d9af876b4a2c 100644
> > --- a/samples/bpf/libbpf.c
> > +++ b/samples/bpf/libbpf.c
> > @@ -11,27 +11,6 @@
> >  #include <arpa/inet.h>
> >  #include "libbpf.h"
> >  
> > -int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type)
> > -{
> > -	union bpf_attr attr = {
> > -		.target_fd = target_fd,
> > -		.attach_bpf_fd = prog_fd,
> > -		.attach_type = type,
> > -	};
> > -
> > -	return syscall(__NR_bpf, BPF_PROG_ATTACH, &attr, sizeof(attr));
> 
> This one makes it fail for CentOS 5 and 6, others may fail as well,
> still building, investigating...

Ok, fixed it by making it follow the model of the other sys_bpf wrappers
setting up that bpf_attr union wrt initializing unamed struct members:

 int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type)
 {
-       union bpf_attr attr = {
-               .target_fd = target_fd,
-               .attach_bpf_fd = prog_fd,
-               .attach_type = type,
-       };
+       union bpf_attr attr;
+
+       bzero(&attr, sizeof(attr));
+       attr.target_fd     = target_fd;
+       attr.attach_bpf_fd = prog_fd;
+       attr.attach_type   = type;
 
        return sys_bpf(BPF_PROG_ATTACH, &attr, sizeof(attr));
 }
 
> 
>    4 10.853874028 centos:5: FAIL
> ...                         glibc: [ on  ]
> ...                          gtk2: [ OFF ]
> ...                      libaudit: [ on  ]
> ...                        libbfd: [ OFF ]
> ...                        libelf: [ on  ]
> ...                       libnuma: [ on  ]
> ...        numa_num_possible_cpus: [ OFF ]
> ...                       libperl: [ on  ]
> ...                     libpython: [ OFF ]
> ...                      libslang: [ on  ]
> ...                     libcrypto: [ on  ]
> ...                     libunwind: [ OFF ]
> ...            libdw-dwarf-unwind: [ OFF ]
> ...                          zlib: [ on  ]
> ...                          lzma: [ on  ]
> ...                     get_cpuid: [ OFF ]
> ...                           bpf: [ on  ]
> 
> Makefile.config:290: No libdw DWARF unwind found, Please install elfutils-devel/libdw-dev >= 0.158 and/or set LIBDW_DIR
> Makefile.config:294: No libdw.h found or old libdw.h found or elfutils is older than 0.138, disables dwarf support. Please install new elfutils-devel/libdw-dev
> Makefile.config:363: DWARF support is off, BPF prologue is disabled
> Makefile.config:417: No libunwind found. Please install libunwind-dev[el] >= 1.1 and/or set LIBUNWIND_DIR
> Makefile.config:444: Disabling post unwind, no support found.
> Makefile.config:530: GTK2 not found, disables GTK2 support. Please install gtk2-devel or libgtk2.0-dev
> Makefile.config:569: No timerfd support. Disables 'perf kvm stat live'
> Makefile.config:589: No 'python-config' tool was found: disables Python support - please install python-devel/python-dev
> Makefile.config:662: No bfd.h/libbfd found, please install binutils-dev[el]/zlib-static/libiberty-dev to gain symbol demangling
> Makefile.config:708: Old numa library found, disables 'perf bench numa mem' benchmark, please install numactl-devel/libnuma-devel/libnuma-dev >= 2.0.8
> Makefile.config:762: Your gcc lacks the __get_cpuid() builtin, disables support for auxtrace/Intel PT, please install a newer gcc
> Makefile.config:792: No openjdk development package found, please install JDK package
>   GEN      /tmp/build/perf/common-cmds.h
>   MKDIR    /tmp/build/perf/fd/
>   CC       /tmp/build/perf/fd/array.o
>   CC       /tmp/build/perf/event-parse.o
>   CC       /tmp/build/perf/exec-cmd.o
>   MKDIR    /tmp/build/perf/fd/
>   CC       /tmp/build/perf/help.o
>   LD       /tmp/build/perf/fd/libapi-in.o
>   MKDIR    /tmp/build/perf/fs/
>   CC       /tmp/build/perf/fs/fs.o
>   CC       /tmp/build/perf/event-plugin.o
>   CC       /tmp/build/perf/pager.o
>   MKDIR    /tmp/build/perf/fs/
>   CC       /tmp/build/perf/fs/tracing_path.o
>   CC       /tmp/build/perf/trace-seq.o
>   CC       /tmp/build/perf/parse-options.o
>   CC       /tmp/build/perf/parse-filter.o
>   MKDIR    /tmp/build/perf/fs/
>   LD       /tmp/build/perf/fs/libapi-in.o
>   CC       /tmp/build/perf/cpu.o
>   CC       /tmp/build/perf/debug.o
>   CC       /tmp/build/perf/str_error_r.o
>   CC       /tmp/build/perf/parse-utils.o
>   CC       /tmp/build/perf/kbuffer-parse.o
>   LD       /tmp/build/perf/libapi-in.o
>   AR       /tmp/build/perf/libapi.a
>   LD       /tmp/build/perf/libtraceevent-in.o
>   CC       /tmp/build/perf/libbpf.o
>   LINK     /tmp/build/perf/libtraceevent.a
>   MKDIR    /tmp/build/perf/pmu-events/
>   HOSTCC   /tmp/build/perf/pmu-events/json.o
>   CC       /tmp/build/perf/run-command.o
>   MKDIR    /tmp/build/perf/pmu-events/
>   HOSTCC   /tmp/build/perf/pmu-events/jsmn.o
>   MKDIR    /tmp/build/perf/pmu-events/
>   HOSTCC   /tmp/build/perf/pmu-events/jevents.o
>   CC       /tmp/build/perf/bpf.o
>   PERF_VERSION = 4.9.0
>   CC       /tmp/build/perf/sigchain.o
> bpf.c: In function 'bpf_prog_attach':
> bpf.c:174: error: unknown field 'target_fd' specified in initializer
> cc1: warnings being treated as errors
> bpf.c:174: warning: missing braces around initializer
> bpf.c:174: warning: (near initialization for 'attr.<anonymous>')
> bpf.c:175: error: unknown field 'attach_bpf_fd' specified in initializer
> bpf.c:175: warning: excess elements in union initializer
> bpf.c:175: warning: (near initialization for 'attr')
> bpf.c:176: error: unknown field 'attach_type' specified in initializer
> bpf.c:176: warning: excess elements in union initializer
> bpf.c:176: warning: (near initialization for 'attr')
> bpf.c: In function 'bpf_prog_detach':
> bpf.c:185: error: unknown field 'target_fd' specified in initializer
> bpf.c:185: warning: missing braces around initializer
> bpf.c:185: warning: (near initialization for 'attr.<anonymous>')
> bpf.c:186: error: unknown field 'attach_type' specified in initializer
> bpf.c:186: warning: excess elements in union initializer
> bpf.c:186: warning: (near initialization for 'attr')
> mv: cannot stat `/tmp/build/perf/.bpf.o.tmp': No such file or directory
> make[4]: *** [/tmp/build/perf/bpf.o] Error 1
> make[3]: *** [/tmp/build/perf/libbpf-in.o] Error 2
> make[2]: *** [/tmp/build/perf/libbpf.a] Error 2
> make[2]: *** Waiting for unfinished jobs....
>   CC       /tmp/build/perf/subcmd-config.o
>   MKDIR    /tmp/build/perf/pmu-events/
>   HOSTLD   /tmp/build/perf/pmu-events/jevents-in.o
>   LD       /tmp/build/perf/libsubcmd-in.o
>   AR       /tmp/build/perf/libsubcmd.a
> make[1]: *** [sub-make] Error 2
> make: *** [all] Error 2
> make: Leaving directory `/git/linux/tools/perf'
> 
