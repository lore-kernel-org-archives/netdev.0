From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH perf/core REBASE 2/5] samples/bpf: Switch over to libbpf
Date: Thu, 15 Dec 2016 10:29:19 -0800
Message-ID: <CAPWQB7HMzpPOgA1rdrKHmbxU29gkaUS1UQF69pHLrfsNhjDvMQ@mail.gmail.com>
References: <20161214224342.12858-1-joe@ovn.org> <20161214224342.12858-3-joe@ovn.org>
 <20161215155022.GE6866@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Wang Nan <wangnan0@huawei.com>,
        ast@fb.com, Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161215155022.GE6866@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15 December 2016 at 07:50, Arnaldo Carvalho de Melo <acme@kernel.org> wrote:
> Em Wed, Dec 14, 2016 at 02:43:39PM -0800, Joe Stringer escreveu:
>> Now that libbpf under tools/lib/bpf/* is synced with the version from
>> samples/bpf, we can get rid most of the libbpf library here.
>>
>> Signed-off-by: Joe Stringer <joe@ovn.org>
>> Cc: Alexei Starovoitov <ast@fb.com>
>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: Wang Nan <wangnan0@huawei.com>
>> Link: http://lkml.kernel.org/r/20161209024620.31660-6-joe@ovn.org
>> [ Use -I$(srctree)/tools/lib/ to support out of source code tree builds, as noticed by Wang Nan ]
>> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
>
> So, right before this patch building samples/bpf works, then, after, it fails,
> investigating:
>
> [root@1e797fdfbf4f linux]# make -j4 O=/tmp/build/linux/ headers_install
> make[1]: Entering directory '/tmp/build/linux'
>   CHK     include/generated/uapi/linux/version.h
> make[1]: Leaving directory '/tmp/build/linux'
> [root@1e797fdfbf4f linux]# make -j4 O=/tmp/build/linux/ samples/bpf/
> make[1]: Entering directory '/tmp/build/linux'
>   CHK     include/config/kernel.release
>   GEN     ./Makefile
>   CHK     include/generated/uapi/linux/version.h
>   Using /git/linux as source for kernel
>   CHK     include/generated/utsrelease.h
>   CHK     include/generated/timeconst.h
>   CHK     include/generated/bounds.h
>   CHK     include/generated/asm-offsets.h
>   CALL    /git/linux/scripts/checksyscalls.sh
>   HOSTCC  samples/bpf/test_lru_dist.o
>   HOSTCC  samples/bpf/libbpf.o
>   HOSTCC  samples/bpf/sock_example.o
>   HOSTCC  samples/bpf/bpf_load.o
> In file included from /git/linux/samples/bpf/libbpf.c:12:0:
> /git/linux/samples/bpf/libbpf.h:5:21: fatal error: bpf/bpf.h: No such file or directory
>  #include <bpf/bpf.h>
>                      ^
> compilation terminated.
> In file included from /git/linux/samples/bpf/test_lru_dist.c:24:0:
> /git/linux/samples/bpf/libbpf.h:5:21: fatal error: bpf/bpf.h: No such file or directory
>  #include <bpf/bpf.h>
>                      ^
> compilation terminated.
> make[2]: *** [scripts/Makefile.host:124: samples/bpf/test_lru_dist.o] Error 1
> make[2]: *** Waiting for unfinished jobs....
> make[2]: *** [scripts/Makefile.host:124: samples/bpf/libbpf.o] Error 1
> In file included from /git/linux/samples/bpf/bpf_load.c:24:0:
> /git/linux/samples/bpf/libbpf.h:5:21: fatal error: bpf/bpf.h: No such file or directory
>  #include <bpf/bpf.h>
>                      ^
> compilation terminated.
> make[2]: *** [scripts/Makefile.host:124: samples/bpf/bpf_load.o] Error 1
> In file included from /git/linux/samples/bpf/sock_example.c:29:0:
> /git/linux/samples/bpf/libbpf.h:5:21: fatal error: bpf/bpf.h: No such file or directory
>  #include <bpf/bpf.h>
>                      ^
> compilation terminated.
> make[2]: *** [scripts/Makefile.host:124: samples/bpf/sock_example.o] Error 1
> make[1]: *** [/git/linux/Makefile:1659: samples/bpf/] Error 2
> make[1]: Leaving directory '/tmp/build/linux'
> make: *** [Makefile:150: sub-make] Error 2
> [root@1e797fdfbf4f linux]#

Sorry about that.

It looks like this fragment which ended up in "samples/bpf: Remove
perf_event_open() declaration" patch should be here instead:

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index add514e2984a..9718f664fedf 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -108,6 +108,8 @@ always += xdp_tx_iptunnel_kern.o

HOSTCFLAGS += -I$(objtree)/usr/include
HOSTCFLAGS += -I$(srctree)/tools/testing/selftests/bpf/
+HOSTCFLAGS += -I$(srctree)/tools/lib/ -I$(srctree)/tools/include
+HOSTCFLAGS += -I$(srctree)/tools/perf

HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
HOSTLOADLIBES_fds_example += -lelf
