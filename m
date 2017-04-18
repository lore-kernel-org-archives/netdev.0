From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH net-next v6 10/11] bpf,landlock: Add tests for Landlock
Date: Tue, 18 Apr 2017 16:16:52 -0700
Message-ID: <CAGXu5j+-sFD5z2daPjvM0Q8vM=g9ZtwJ7-ZakqoUcjsiAD=+1A@mail.gmail.com>
References: <20170328234650.19695-1-mic@digikod.net> <20170328234650.19695-11-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Jann Horn <jann@thejh.net>, Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>,
        Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@kernel.org>,
        Thomas Graf <tgraf@suug.ch>, Will Drewry <wa
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20170328234650.19695-11-mic@digikod.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 28, 2017 at 4:46 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>=
 wrote:
> Test basic context access, ptrace protection and filesystem event with
> multiple cases.
>
> Changes since v5:
> * add subtype test
> * add ptrace tests
> * split and rename files
> * cleanup and rebase
>
> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: James Morris <james.l.morris@oracle.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Serge E. Hallyn <serge@hallyn.com>
> Cc: Shuah Khan <shuah@kernel.org>
> Cc: Will Drewry <wad@chromium.org>
> ---
>  tools/testing/selftests/Makefile                   |   1 +
>  tools/testing/selftests/bpf/test_verifier.c        |  64 +++++
>  tools/testing/selftests/landlock/.gitignore        |   4 +
>  tools/testing/selftests/landlock/Makefile          |  47 ++++
>  tools/testing/selftests/landlock/rules/Makefile    |  52 ++++
>  tools/testing/selftests/landlock/rules/README.rst  |   1 +
>  .../testing/selftests/landlock/rules/bpf_helpers.h |   1 +
>  .../testing/selftests/landlock/rules/fs_no_open.c  |  31 +++
>  .../selftests/landlock/rules/fs_read_only.c        |  31 +++
>  tools/testing/selftests/landlock/test.h            |  35 +++
>  tools/testing/selftests/landlock/test_base.c       |  31 +++
>  tools/testing/selftests/landlock/test_fs.c         | 305 +++++++++++++++=
++++++
>  tools/testing/selftests/landlock/test_ptrace.c     | 161 +++++++++++
>  13 files changed, 764 insertions(+)
>  create mode 100644 tools/testing/selftests/landlock/.gitignore
>  create mode 100644 tools/testing/selftests/landlock/Makefile
>  create mode 100644 tools/testing/selftests/landlock/rules/Makefile
>  create mode 120000 tools/testing/selftests/landlock/rules/README.rst
>  create mode 120000 tools/testing/selftests/landlock/rules/bpf_helpers.h
>  create mode 100644 tools/testing/selftests/landlock/rules/fs_no_open.c
>  create mode 100644 tools/testing/selftests/landlock/rules/fs_read_only.c
>  create mode 100644 tools/testing/selftests/landlock/test.h
>  create mode 100644 tools/testing/selftests/landlock/test_base.c
>  create mode 100644 tools/testing/selftests/landlock/test_fs.c
>  create mode 100644 tools/testing/selftests/landlock/test_ptrace.c
>
> diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/M=
akefile
> index d8593f1251ec..b584ad456428 100644
> --- a/tools/testing/selftests/Makefile
> +++ b/tools/testing/selftests/Makefile
> @@ -12,6 +12,7 @@ TARGETS +=3D gpio
>  TARGETS +=3D intel_pstate
>  TARGETS +=3D ipc
>  TARGETS +=3D kcmp
> +TARGETS +=3D landlock
>  TARGETS +=3D lib
>  TARGETS +=3D membarrier
>  TARGETS +=3D memfd
> diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/=
selftests/bpf/test_verifier.c
> index daa87dd7c80e..77255b14871e 100644
> --- a/tools/testing/selftests/bpf/test_verifier.c
> +++ b/tools/testing/selftests/bpf/test_verifier.c
> @@ -4536,6 +4536,70 @@ static struct bpf_test tests[] =3D {
>                 .result =3D REJECT,
>                 .has_prog_subtype =3D true,
>         },
> +       {
> +               "missing subtype",
> +               .insns =3D {
> +                       BPF_MOV32_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .errstr =3D "",
> +               .result =3D REJECT,
> +               .prog_type =3D BPF_PROG_TYPE_LANDLOCK,
> +       },
> +       {
> +               "landlock/fs: always accept",
> +               .insns =3D {
> +                       BPF_MOV32_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .result =3D ACCEPT,
> +               .prog_type =3D BPF_PROG_TYPE_LANDLOCK,
> +               .has_prog_subtype =3D true,
> +               .prog_subtype =3D {
> +                       .landlock_rule =3D {
> +                               .version =3D 1,
> +                               .event =3D LANDLOCK_SUBTYPE_EVENT_FS,
> +                       }
> +               },
> +       },
> +       {
> +               "landlock/fs: read context",
> +               .insns =3D {
> +                       BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
> +                       BPF_LDX_MEM(BPF_DW, BPF_REG_7, BPF_REG_6,
> +                               offsetof(struct landlock_context, status)=
),
> +                       /* test operations on raw values */
> +                       BPF_ALU64_IMM(BPF_ADD, BPF_REG_7, 1),
> +                       BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_6,
> +                               offsetof(struct landlock_context, arch)),
> +                       BPF_ALU64_IMM(BPF_ADD, BPF_REG_7, 1),
> +                       BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_6,
> +                               offsetof(struct landlock_context, syscall=
_nr)),
> +                       BPF_ALU64_IMM(BPF_ADD, BPF_REG_7, 1),
> +                       BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_6,
> +                               offsetof(struct landlock_context, syscall=
_cmd)),
> +                       BPF_ALU64_IMM(BPF_ADD, BPF_REG_7, 1),
> +                       BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_6,
> +                               offsetof(struct landlock_context, event))=
,
> +                       BPF_ALU64_IMM(BPF_ADD, BPF_REG_7, 1),
> +                       BPF_LDX_MEM(BPF_DW, BPF_REG_7, BPF_REG_6,
> +                               offsetof(struct landlock_context, arg1)),
> +                       BPF_LDX_MEM(BPF_DW, BPF_REG_7, BPF_REG_6,
> +                               offsetof(struct landlock_context, arg2)),
> +                       BPF_ALU64_IMM(BPF_ADD, BPF_REG_7, 1),
> +                       BPF_MOV32_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .result =3D ACCEPT,
> +               .prog_type =3D BPF_PROG_TYPE_LANDLOCK,
> +               .has_prog_subtype =3D true,
> +               .prog_subtype =3D {
> +                       .landlock_rule =3D {
> +                               .version =3D 1,
> +                               .event =3D LANDLOCK_SUBTYPE_EVENT_FS,
> +                       }
> +               },
> +       },
>  };
>
>  static int probe_filter_length(const struct bpf_insn *fp)
> diff --git a/tools/testing/selftests/landlock/.gitignore b/tools/testing/=
selftests/landlock/.gitignore
> new file mode 100644
> index 000000000000..25b9cd834c3c
> --- /dev/null
> +++ b/tools/testing/selftests/landlock/.gitignore
> @@ -0,0 +1,4 @@
> +/test_base
> +/test_fs
> +/test_ptrace
> +/tmp_*
> diff --git a/tools/testing/selftests/landlock/Makefile b/tools/testing/se=
lftests/landlock/Makefile
> new file mode 100644
> index 000000000000..9a52c82d64fa
> --- /dev/null
> +++ b/tools/testing/selftests/landlock/Makefile
> @@ -0,0 +1,47 @@
> +LIBDIR :=3D ../../../lib
> +BPFOBJ :=3D $(LIBDIR)/bpf/bpf.o
> +LOADOBJ :=3D ../../../../samples/bpf/bpf_load.o

Is the selftest tarball creation tool okay with this? IIRC, it should
be fine since it'll be a built object already, but it's a random
thought I had while looking at this.

> +
> +CFLAGS +=3D -Wl,-no-as-needed -Wall -O2 -I../../../include/uapi -I$(LIBD=
IR)
> +LDFLAGS +=3D -lelf
> +
> +test_src =3D $(wildcard test_*.c)
> +rule_src =3D $(wildcard rules/*.c)
> +
> +test_objs :=3D $(test_src:.c=3D)
> +rule_objs :=3D $(rule_src:.c=3D.o)
> +
> +TEST_PROGS :=3D $(test_objs)
> +
> +.PHONY: all clean clean_tmp force
> +
> +all: $(test_objs) $(rule_objs)
> +
> +# force a rebuild of BPFOBJ when its dependencies are updated
> +force:
> +
> +$(BPFOBJ): force
> +       $(MAKE) -C $(dir $(BPFOBJ))
> +
> +$(LOADOBJ):
> +       $(MAKE) -C $(dir $(LOADOBJ))
> +
> +# minimize builds
> +rules/modules.order: $(rule_src)
> +       $(MAKE) -C rules
> +       @touch $@
> +
> +$(rule_objs): rules/modules.order
> +       @
> +
> +$(test_objs): $(BPFOBJ) $(LOADOBJ)
> +
> +include ../lib.mk
> +
> +clean_tmp:
> +       $(RM) -r tmp_*
> +
> +clean: clean_tmp
> +       $(MAKE) -C rules clean
> +       $(RM) $(test_objs)
> +
> diff --git a/tools/testing/selftests/landlock/rules/Makefile b/tools/test=
ing/selftests/landlock/rules/Makefile
> new file mode 100644
> index 000000000000..8d6ff960ff7c
> --- /dev/null
> +++ b/tools/testing/selftests/landlock/rules/Makefile
> @@ -0,0 +1,52 @@
> +# kbuild trick to avoid linker error. Can be omitted if a module is buil=
t.
> +obj- :=3D dummy.o
> +
> +# Tell kbuild to always build the programs
> +always :=3D fs_read_only.o
> +always +=3D fs_no_open.o
> +
> +EXTRA_CFLAGS =3D -Wall -Wextra
> +
> +# Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine=
 on cmdline:
> +#  make samples/bpf/ LLC=3D~/git/llvm/build/bin/llc CLANG=3D~/git/llvm/b=
uild/bin/clang
> +LLC ?=3D llc
> +CLANG ?=3D clang
> +
> +# Verify LLVM compiler tools are available and bpf target is supported b=
y llc
> +.PHONY: all clean verify_cmds verify_target_bpf $(CLANG) $(LLC)
> +
> +# Trick to allow make to be run from this directory
> +all:
> +       $(MAKE) -C ../../../../../ $(CURDIR)/
> +
> +clean:
> +       $(MAKE) -C ../../../../../ M=3D$(CURDIR) clean

Is this really needed? Others don't have it, I think.

> +verify_cmds: $(CLANG) $(LLC)
> +       @for TOOL in $^ ; do \
> +               if ! (which -- "$${TOOL}" > /dev/null 2>&1); then \
> +                       echo "*** ERROR: Cannot find LLVM tool $${TOOL}" =
;\
> +                       exit 1; \
> +               else true; fi; \
> +       done
> +
> +verify_target_bpf: verify_cmds
> +       @if ! (${LLC} -march=3Dbpf -mattr=3Dhelp > /dev/null 2>&1); then =
\
> +               echo "*** ERROR: LLVM (${LLC}) does not support 'bpf' tar=
get" ;\
> +               echo "   NOTICE: LLVM version >=3D 3.7.1 required" ;\
> +               exit 2; \
> +       else true; fi
> +
> +%_kern.c: verify_target_bpf
> +
> +# asm/sysreg.h - inline assembly used by it is incompatible with llvm.
> +# But, there is no easy way to fix it, so just exclude it since it is
> +# useless for BPF samples.
> +$(obj)/%.o: $(src)/%.c
> +       $(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
> +               -D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-poin=
ter-sign \
> +               -Wno-compare-distinct-pointer-types \
> +               -Wno-gnu-variable-sized-type-not-at-end \
> +               -Wno-tautological-compare \
> +               -O2 -emit-llvm -c $< -o -| $(LLC) -march=3Dbpf -filetype=
=3Dobj -o $@

Is clang required for the samples and the selftests? That needs to be
avoided... there needs to be a way to show people how to build a
landlock rule without requiring clang.

> +
> diff --git a/tools/testing/selftests/landlock/rules/README.rst b/tools/te=
sting/selftests/landlock/rules/README.rst
> new file mode 120000
> index 000000000000..605f48aa6f72
> --- /dev/null
> +++ b/tools/testing/selftests/landlock/rules/README.rst
> @@ -0,0 +1 @@
> +../../../../../samples/bpf/README.rst
> \ No newline at end of file
> diff --git a/tools/testing/selftests/landlock/rules/bpf_helpers.h b/tools=
/testing/selftests/landlock/rules/bpf_helpers.h
> new file mode 120000
> index 000000000000..0aa1a521b39a
> --- /dev/null
> +++ b/tools/testing/selftests/landlock/rules/bpf_helpers.h
> @@ -0,0 +1 @@
> +../../../../../samples/bpf/bpf_helpers.h
> \ No newline at end of file
> diff --git a/tools/testing/selftests/landlock/rules/fs_no_open.c b/tools/=
testing/selftests/landlock/rules/fs_no_open.c
> new file mode 100644
> index 000000000000..c6ea305e58a7
> --- /dev/null
> +++ b/tools/testing/selftests/landlock/rules/fs_no_open.c
> @@ -0,0 +1,31 @@
> +/*
> + * Landlock rule - no-open filesystem
> + *
> + * Copyright =C2=A9 2017 Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2, as
> + * published by the Free Software Foundation.
> + */
> +
> +#include <uapi/linux/bpf.h>
> +#include "bpf_helpers.h"
> +
> +SEC("landlock1")
> +static int landlock_fs_prog1(struct landlock_context *ctx)
> +{
> +       if (!(ctx->arg2 & LANDLOCK_ACTION_FS_GET))
> +               return 0;
> +       return 1;
> +}
> +
> +SEC("subtype")
> +static union bpf_prog_subtype _subtype =3D {
> +       .landlock_rule =3D {
> +               .version =3D 1,
> +               .event =3D LANDLOCK_SUBTYPE_EVENT_FS,
> +       }
> +};
> +
> +SEC("license")
> +static const char _license[] =3D "GPL";
> diff --git a/tools/testing/selftests/landlock/rules/fs_read_only.c b/tool=
s/testing/selftests/landlock/rules/fs_read_only.c
> new file mode 100644
> index 000000000000..212dda7c0c27
> --- /dev/null
> +++ b/tools/testing/selftests/landlock/rules/fs_read_only.c
> @@ -0,0 +1,31 @@
> +/*
> + * Landlock rule - read-only filesystem
> + *
> + * Copyright =C2=A9 2017 Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2, as
> + * published by the Free Software Foundation.
> + */
> +
> +#include <uapi/linux/bpf.h>
> +#include "bpf_helpers.h"
> +
> +SEC("landlock1")
> +static int landlock_fs_prog1(struct landlock_context *ctx)
> +{
> +       if (!(ctx->arg2 & LANDLOCK_ACTION_FS_WRITE))
> +               return 0;
> +       return 1;
> +}
> +
> +SEC("subtype")
> +static union bpf_prog_subtype _subtype =3D {
> +       .landlock_rule =3D {
> +               .version =3D 1,
> +               .event =3D LANDLOCK_SUBTYPE_EVENT_FS,
> +       }
> +};
> +
> +SEC("license")
> +static const char _license[] =3D "GPL";
> diff --git a/tools/testing/selftests/landlock/test.h b/tools/testing/self=
tests/landlock/test.h
> new file mode 100644
> index 000000000000..7a194815391b
> --- /dev/null
> +++ b/tools/testing/selftests/landlock/test.h
> @@ -0,0 +1,35 @@
> +/*
> + * Landlock helpers
> + *
> + * Copyright =C2=A9 2017 Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2, as
> + * published by the Free Software Foundation.
> + */
> +
> +#include <errno.h>
> +#include <sys/prctl.h>
> +#include <sys/syscall.h>
> +
> +#include "../seccomp/test_harness.h"
> +#include "../../../../samples/bpf/bpf_load.h"
> +
> +#ifndef SECCOMP_APPEND_LANDLOCK_RULE
> +#define SECCOMP_APPEND_LANDLOCK_RULE   2
> +#endif
> +
> +#ifndef seccomp
> +static int seccomp(unsigned int op, unsigned int flags, void *args)
> +{
> +       errno =3D 0;
> +       return syscall(__NR_seccomp, op, flags, args);
> +}
> +#endif
> +
> +#define ASSERT_STEP(cond) \
> +       { \
> +               step--; \
> +               if (!(cond)) \
> +                       _exit(step); \
> +       }

Can you explain this in more detail? I'm assuming there is a problem
with writing to the TH_LOG_STREAM fd or something?

> diff --git a/tools/testing/selftests/landlock/test_base.c b/tools/testing=
/selftests/landlock/test_base.c
> new file mode 100644
> index 000000000000..bdf056edee03
> --- /dev/null
> +++ b/tools/testing/selftests/landlock/test_base.c
> @@ -0,0 +1,31 @@
> +/*
> + * Landlock tests - base
> + *
> + * Copyright =C2=A9 2017 Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2, as
> + * published by the Free Software Foundation.
> + */
> +
> +#define _GNU_SOURCE
> +#include <errno.h>
> +
> +#include "test.h"
> +
> +TEST(seccomp_landlock)
> +{
> +       int ret;
> +
> +       ret =3D prctl(PR_SET_NO_NEW_PRIVS, 1, NULL, 0, 0);
> +       ASSERT_EQ(0, ret) {
> +               TH_LOG("Kernel does not support PR_SET_NO_NEW_PRIVS");
> +       }
> +       ret =3D seccomp(SECCOMP_APPEND_LANDLOCK_RULE, 0, NULL);
> +       EXPECT_EQ(-1, ret);
> +       EXPECT_EQ(EFAULT, errno) {
> +               TH_LOG("Kernel does not support CONFIG_SECURITY_LANDLOCK"=
);
> +       }
> +}
> +
> +TEST_HARNESS_MAIN
> diff --git a/tools/testing/selftests/landlock/test_fs.c b/tools/testing/s=
elftests/landlock/test_fs.c
> new file mode 100644
> index 000000000000..e69eda433716
> --- /dev/null
> +++ b/tools/testing/selftests/landlock/test_fs.c
> @@ -0,0 +1,305 @@
> +/*
> + * Landlock tests - filesystem
> + *
> + * Copyright =C2=A9 2017 Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2, as
> + * published by the Free Software Foundation.
> + */
> +
> +#define _GNU_SOURCE
> +#include <errno.h>
> +#include <linux/bpf.h>
> +#include <linux/filter.h>
> +#include <linux/seccomp.h>
> +#include <stddef.h>
> +#include <string.h>
> +#include <sys/prctl.h>
> +#include <sys/syscall.h>
> +
> +#include <fcntl.h> /* open() */
> +#include <sys/mount.h>
> +#include <sys/stat.h> /* mkdir() */
> +#include <sys/mman.h> /* mmap() */
> +
> +#include "test.h"
> +
> +#define TMP_PREFIX "tmp_"
> +
> +struct layout1 {
> +       int file_ro;
> +       int file_rw;
> +       int file_wo;
> +};
> +
> +static void setup_layout1(struct __test_metadata *_metadata,
> +               struct layout1 *l1)
> +{
> +       int fd;
> +       char buf[] =3D "fs_read_only";
> +
> +       l1->file_ro =3D -1;
> +       l1->file_rw =3D -1;
> +       l1->file_wo =3D -1;
> +
> +       fd =3D open(TMP_PREFIX "file_created",
> +                       O_CREAT | O_EXCL | O_WRONLY | O_CLOEXEC, 0600);
> +       ASSERT_GE(fd, 0);
> +       ASSERT_EQ(sizeof(buf), write(fd, buf, sizeof(buf)));
> +       ASSERT_EQ(0, close(fd));
> +
> +       fd =3D mkdir(TMP_PREFIX "dir_created", 0600);
> +       ASSERT_GE(fd, 0);
> +       ASSERT_EQ(0, close(fd));
> +
> +       l1->file_ro =3D open(TMP_PREFIX "file_ro",
> +                       O_CREAT | O_EXCL | O_WRONLY | O_CLOEXEC, 0600);
> +       ASSERT_LE(0, l1->file_ro);
> +       ASSERT_EQ(sizeof(buf), write(l1->file_ro, buf, sizeof(buf)));
> +       ASSERT_EQ(0, close(l1->file_ro));
> +       l1->file_ro =3D open(TMP_PREFIX "file_ro",
> +                       O_RDONLY | O_CLOEXEC, 0600);
> +       ASSERT_LE(0, l1->file_ro);
> +
> +       l1->file_rw =3D open(TMP_PREFIX "file_rw",
> +                       O_CREAT | O_EXCL | O_RDWR | O_CLOEXEC, 0600);
> +       ASSERT_LE(0, l1->file_rw);
> +       ASSERT_EQ(sizeof(buf), write(l1->file_rw, buf, sizeof(buf)));
> +       ASSERT_EQ(0, lseek(l1->file_rw, 0, SEEK_SET));
> +
> +       l1->file_wo =3D open(TMP_PREFIX "file_wo",
> +                       O_CREAT | O_EXCL | O_WRONLY | O_CLOEXEC, 0600);
> +       ASSERT_LE(0, l1->file_wo);
> +       ASSERT_EQ(sizeof(buf), write(l1->file_wo, buf, sizeof(buf)));
> +       ASSERT_EQ(0, lseek(l1->file_wo, 0, SEEK_SET));
> +}
> +
> +static void cleanup_layout1(void)
> +{
> +       unlink(TMP_PREFIX "file_created");
> +       unlink(TMP_PREFIX "file_ro");
> +       unlink(TMP_PREFIX "file_rw");
> +       unlink(TMP_PREFIX "file_wo");
> +       unlink(TMP_PREFIX "should_not_exist");
> +       rmdir(TMP_PREFIX "dir_created");
> +}
> +
> +FIXTURE(fs_read_only) {
> +       struct layout1 l1;
> +       int prog;
> +};
> +
> +FIXTURE_SETUP(fs_read_only)
> +{
> +       cleanup_layout1();
> +       setup_layout1(_metadata, &self->l1);
> +
> +       ASSERT_EQ(0, load_bpf_file("rules/fs_read_only.o")) {
> +               TH_LOG("%s", bpf_log_buf);
> +       }
> +       self->prog =3D prog_fd[0];
> +       ASSERT_EQ(0, prctl(PR_SET_NO_NEW_PRIVS, 1, NULL, 0, 0)) {
> +               TH_LOG("Kernel does not support PR_SET_NO_NEW_PRIVS");
> +       }
> +}
> +
> +FIXTURE_TEARDOWN(fs_read_only)
> +{
> +       EXPECT_EQ(0, close(self->prog));
> +       /* cleanup_layout1() would be denied here */
> +}
> +
> +TEST_F(fs_read_only, load_prog) {}
> +
> +TEST_F(fs_read_only, read_only_file)
> +{
> +       int fd;
> +       int step =3D 0;
> +       char buf_write[] =3D "should not be written";
> +       char buf_read[2];
> +
> +       ASSERT_EQ(-1, write(self->l1.file_ro, buf_write, sizeof(buf_write=
)));
> +       ASSERT_EQ(EBADF, errno);
> +
> +       ASSERT_EQ(-1, read(self->l1.file_wo, buf_read, sizeof(buf_read)))=
;
> +       ASSERT_EQ(EBADF, errno);
> +
> +       ASSERT_EQ(0, seccomp(SECCOMP_APPEND_LANDLOCK_RULE, 0, &self->prog=
)) {
> +               TH_LOG("Failed to apply rule fs_read_only: %s",
> +                               strerror(errno));
> +       }
> +
> +       fd =3D open(".", O_TMPFILE | O_EXCL | O_RDWR | O_CLOEXEC, 0600);
> +       ASSERT_STEP(fd =3D=3D -1);
> +       ASSERT_STEP(errno !=3D EOPNOTSUPP)
> +       ASSERT_STEP(errno =3D=3D EPERM);
> +
> +       fd =3D open(TMP_PREFIX "file_created",
> +                       O_RDONLY | O_CLOEXEC);
> +       ASSERT_STEP(fd >=3D 0);
> +       ASSERT_STEP(!close(fd));
> +
> +       fd =3D open(TMP_PREFIX "file_created",
> +                       O_RDWR | O_CLOEXEC);
> +       ASSERT_STEP(fd =3D=3D -1);
> +       ASSERT_STEP(errno =3D=3D EPERM);
> +
> +       fd =3D open(TMP_PREFIX "file_created",
> +                       O_WRONLY | O_CLOEXEC);
> +       ASSERT_STEP(fd =3D=3D -1);
> +       ASSERT_STEP(errno =3D=3D EPERM);
> +
> +       fd =3D open(TMP_PREFIX "should_not_exist",
> +                       O_CREAT | O_EXCL | O_CLOEXEC, 0600);
> +       ASSERT_STEP(fd =3D=3D -1);
> +       ASSERT_STEP(errno =3D=3D EPERM);
> +
> +       ASSERT_STEP(-1 =3D=3D
> +                       write(self->l1.file_ro, buf_write, sizeof(buf_wri=
te)));
> +       ASSERT_STEP(errno =3D=3D EBADF);
> +       ASSERT_STEP(sizeof(buf_read) =3D=3D
> +                       read(self->l1.file_ro, buf_read, sizeof(buf_read)=
));
> +
> +       ASSERT_STEP(-1 =3D=3D
> +                       write(self->l1.file_rw, buf_write, sizeof(buf_wri=
te)));
> +       ASSERT_STEP(errno =3D=3D EPERM);
> +       ASSERT_STEP(sizeof(buf_read) =3D=3D
> +                       read(self->l1.file_rw, buf_read, sizeof(buf_read)=
));
> +
> +       ASSERT_STEP(-1 =3D=3D write(self->l1.file_wo, buf_write, sizeof(b=
uf_write)));
> +       ASSERT_STEP(errno =3D=3D EPERM);
> +       ASSERT_STEP(-1 =3D=3D read(self->l1.file_wo, buf_read, sizeof(buf=
_read)));
> +       ASSERT_STEP(errno =3D=3D EBADF);
> +
> +       ASSERT_STEP(-1 =3D=3D unlink(TMP_PREFIX "file_created"));
> +       ASSERT_STEP(errno =3D=3D EPERM);
> +       ASSERT_STEP(-1 =3D=3D rmdir(TMP_PREFIX "dir_created"));
> +       ASSERT_STEP(errno =3D=3D EPERM);
> +
> +       ASSERT_STEP(0 =3D=3D close(self->l1.file_ro));
> +       ASSERT_STEP(0 =3D=3D close(self->l1.file_rw));
> +       ASSERT_STEP(0 =3D=3D close(self->l1.file_wo));
> +}
> +
> +TEST_F(fs_read_only, read_only_mount)
> +{
> +       int step =3D 0;
> +
> +       ASSERT_EQ(0, mount(".", TMP_PREFIX "dir_created",
> +                               NULL, MS_BIND, NULL));
> +       ASSERT_EQ(0, umount2(TMP_PREFIX "dir_created", MNT_FORCE));
> +
> +       ASSERT_EQ(0, seccomp(SECCOMP_APPEND_LANDLOCK_RULE, 0, &self->prog=
)) {
> +               TH_LOG("Failed to apply rule fs_read_only: %s",
> +                               strerror(errno));
> +       }
> +
> +       ASSERT_STEP(-1 =3D=3D mount(".", TMP_PREFIX "dir_created",
> +                               NULL, MS_BIND, NULL));
> +       ASSERT_STEP(errno =3D=3D EPERM);
> +       ASSERT_STEP(-1 =3D=3D umount("/"));
> +       ASSERT_STEP(errno =3D=3D EPERM);
> +}
> +
> +TEST_F(fs_read_only, read_only_mem)
> +{
> +       int step =3D 0;
> +       void *addr;
> +
> +       addr =3D mmap(NULL, 1, PROT_READ | PROT_WRITE,
> +                       MAP_SHARED, self->l1.file_rw, 0);
> +       ASSERT_NE(NULL, addr);
> +       ASSERT_EQ(0, munmap(addr, 1));
> +
> +       ASSERT_EQ(0, seccomp(SECCOMP_APPEND_LANDLOCK_RULE, 0, &self->prog=
)) {
> +               TH_LOG("Failed to apply rule fs_read_only: %s",
> +                               strerror(errno));
> +       }
> +
> +       addr =3D mmap(NULL, 1, PROT_READ, MAP_SHARED,
> +                       self->l1.file_rw, 0);
> +       ASSERT_STEP(addr !=3D NULL);
> +       ASSERT_STEP(-1 =3D=3D mprotect(addr, 1, PROT_WRITE));
> +       ASSERT_STEP(errno =3D=3D EPERM);
> +       ASSERT_STEP(0 =3D=3D munmap(addr, 1));
> +
> +       addr =3D mmap(NULL, 1, PROT_READ | PROT_WRITE, MAP_SHARED,
> +                       self->l1.file_rw, 0);
> +       ASSERT_STEP(addr !=3D NULL);
> +       ASSERT_STEP(errno =3D=3D EPERM);
> +
> +       addr =3D mmap(NULL, 1, PROT_READ | PROT_WRITE, MAP_PRIVATE,
> +                       self->l1.file_rw, 0);
> +       ASSERT_STEP(addr !=3D NULL);
> +       ASSERT_STEP(0 =3D=3D munmap(addr, 1));
> +}
> +
> +FIXTURE(fs_no_open) {
> +       struct layout1 l1;
> +       int prog;
> +};
> +
> +FIXTURE_SETUP(fs_no_open)
> +{
> +       cleanup_layout1();
> +       setup_layout1(_metadata, &self->l1);
> +
> +       ASSERT_EQ(0, load_bpf_file("rules/fs_no_open.o")) {
> +               TH_LOG("%s", bpf_log_buf);
> +       }
> +       self->prog =3D prog_fd[0];
> +       ASSERT_EQ(0, prctl(PR_SET_NO_NEW_PRIVS, 1, NULL, 0, 0)) {
> +               TH_LOG("Kernel does not support PR_SET_NO_NEW_PRIVS");
> +       }
> +}
> +
> +FIXTURE_TEARDOWN(fs_no_open)
> +{
> +       EXPECT_EQ(0, close(self->prog));
> +       cleanup_layout1();
> +}
> +
> +static void landlocked_deny_open(struct __test_metadata *_metadata,
> +               struct layout1 *l1)
> +{
> +       int fd;
> +       void *addr;
> +
> +       fd =3D open(".", O_DIRECTORY | O_CLOEXEC);
> +       ASSERT_EQ(-1, fd);
> +       ASSERT_EQ(EPERM, errno);
> +
> +       addr =3D mmap(NULL, 1, PROT_READ | PROT_WRITE,
> +                       MAP_SHARED, l1->file_rw, 0);
> +       ASSERT_NE(NULL, addr);
> +       ASSERT_EQ(0, munmap(addr, 1));
> +}
> +
> +TEST_F(fs_no_open, deny_open_for_hierarchy) {
> +       int fd;
> +       int status;
> +       pid_t child;
> +
> +       fd =3D open(".", O_DIRECTORY | O_CLOEXEC);
> +       ASSERT_LE(0, fd);
> +       ASSERT_EQ(0, close(fd));
> +
> +       ASSERT_EQ(0, seccomp(SECCOMP_APPEND_LANDLOCK_RULE, 0, &self->prog=
)) {
> +               TH_LOG("Failed to apply rule fs_no_open: %s", strerror(er=
rno));
> +       }
> +
> +       landlocked_deny_open(_metadata, &self->l1);
> +
> +       child =3D fork();
> +       ASSERT_LE(0, child);
> +       if (!child) {
> +               landlocked_deny_open(_metadata, &self->l1);
> +               _exit(1);
> +       }
> +       ASSERT_EQ(child, waitpid(child, &status, 0));
> +       ASSERT_TRUE(WIFEXITED(status));
> +       _exit(WEXITSTATUS(status));
> +}
> +
> +TEST_HARNESS_MAIN
> diff --git a/tools/testing/selftests/landlock/test_ptrace.c b/tools/testi=
ng/selftests/landlock/test_ptrace.c
> new file mode 100644
> index 000000000000..0c940a7fd3d0
> --- /dev/null
> +++ b/tools/testing/selftests/landlock/test_ptrace.c
> @@ -0,0 +1,161 @@
> +/*
> + * Landlock tests - ptrace
> + *
> + * Copyright =C2=A9 2017 Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2, as
> + * published by the Free Software Foundation.
> + */
> +
> +#define _GNU_SOURCE
> +#include <signal.h> /* raise */
> +#include <sys/ptrace.h>
> +#include <sys/types.h> /* waitpid */
> +#include <sys/wait.h> /* waitpid */
> +#include <unistd.h> /* fork, pipe */
> +
> +#include "test.h"
> +
> +static void apply_null_sandbox(struct __test_metadata *_metadata)
> +{
> +       const struct bpf_insn prog_accept[] =3D {
> +               BPF_MOV32_IMM(BPF_REG_0, 0),
> +               BPF_EXIT_INSN(),
> +       };
> +       const union bpf_prog_subtype subtype =3D {
> +               .landlock_rule =3D {
> +                       .version =3D 1,
> +                       .event =3D LANDLOCK_SUBTYPE_EVENT_FS,
> +               }
> +       };
> +       int prog;
> +       char log[256] =3D "";
> +
> +       prog =3D bpf_load_program(BPF_PROG_TYPE_LANDLOCK,
> +                       (const struct bpf_insn *)&prog_accept,
> +                       sizeof(prog_accept) / sizeof(struct bpf_insn), "G=
PL",
> +                       0, log, sizeof(log), &subtype);
> +       ASSERT_NE(-1, prog) {
> +               TH_LOG("Failed to load minimal rule: %s\n%s",
> +                               strerror(errno), log);
> +       }
> +       ASSERT_EQ(0, prctl(PR_SET_NO_NEW_PRIVS, 1, NULL, 0, 0)) {
> +               TH_LOG("Kernel does not support PR_SET_NO_NEW_PRIVS");
> +       }
> +       ASSERT_EQ(0, seccomp(SECCOMP_APPEND_LANDLOCK_RULE, 0, &prog)) {
> +               TH_LOG("Failed to apply minimal rule: %s", strerror(errno=
));
> +       }
> +       EXPECT_EQ(0, close(prog));
> +}
> +
> +/* PTRACE_TRACEME and PTRACE_ATTACH without Landlock rules effect */
> +static void check_ptrace(struct __test_metadata *_metadata,
> +               int sandbox_both, int sandbox_parent, int sandbox_child,
> +               int expect_ptrace)
> +{
> +       pid_t child;
> +       int status;
> +       int pipefd[2];
> +
> +       ASSERT_EQ(0, pipe(pipefd));
> +       if (sandbox_both)
> +               apply_null_sandbox(_metadata);
> +
> +       child =3D fork();
> +       ASSERT_LE(0, child);
> +       if (child =3D=3D 0) {
> +               char buf;
> +
> +               EXPECT_EQ(0, close(pipefd[1]));
> +               if (sandbox_child)
> +                       apply_null_sandbox(_metadata);
> +
> +               /* test traceme */
> +               ASSERT_EQ(expect_ptrace, ptrace(PTRACE_TRACEME));
> +               if (expect_ptrace) {
> +                       ASSERT_EQ(EPERM, errno);
> +               } else {
> +                       ASSERT_EQ(0, raise(SIGSTOP));
> +               }
> +
> +               /* sync */
> +               ASSERT_EQ(1, read(pipefd[0], &buf, 1)) {
> +                       TH_LOG("Failed to read() sync from parent");
> +               }
> +               ASSERT_EQ('.', buf);
> +               _exit(_metadata->passed ? EXIT_SUCCESS : EXIT_FAILURE);
> +       }
> +
> +       EXPECT_EQ(0, close(pipefd[0]));
> +       if (sandbox_parent)
> +               apply_null_sandbox(_metadata);
> +
> +       /* test traceme */
> +       if (!expect_ptrace) {
> +               ASSERT_EQ(child, waitpid(child, &status, 0));
> +               ASSERT_EQ(1, WIFSTOPPED(status));
> +               ASSERT_EQ(0, ptrace(PTRACE_DETACH, child, NULL, 0));
> +       }
> +       /* test attach */
> +       ASSERT_EQ(expect_ptrace, ptrace(PTRACE_ATTACH, child, NULL, 0));
> +       if (expect_ptrace) {
> +               ASSERT_EQ(EPERM, errno);
> +       } else {
> +               ASSERT_EQ(child, waitpid(child, &status, 0));
> +               ASSERT_EQ(1, WIFSTOPPED(status));
> +               ASSERT_EQ(0, ptrace(PTRACE_CONT, child, NULL, 0));
> +       }
> +
> +       /* sync */
> +       ASSERT_EQ(1, write(pipefd[1], ".", 1)) {
> +               TH_LOG("Failed to write() sync to child");
> +       }
> +       ASSERT_EQ(child, waitpid(child, &status, 0));
> +       if (WIFSIGNALED(status) || WEXITSTATUS(status))
> +               _metadata->passed =3D 0;
> +}
> +
> +TEST(ptrace_allow_without_sandbox)
> +{
> +       /* no sandbox */
> +       check_ptrace(_metadata, 0, 0, 0, 0);
> +}
> +
> +TEST(ptrace_allow_with_one_sandbox)
> +{
> +       /* child sandbox */
> +       check_ptrace(_metadata, 0, 0, 1, 0);
> +}
> +
> +TEST(ptrace_allow_with_nested_sandbox)
> +{
> +       /* inherited and child sandbox */
> +       check_ptrace(_metadata, 1, 0, 1, 0);
> +}
> +
> +TEST(ptrace_deny_with_parent_sandbox)
> +{
> +       /* parent sandbox */
> +       check_ptrace(_metadata, 0, 1, 0, -1);
> +}
> +
> +TEST(ptrace_deny_with_nested_and_parent_sandbox)
> +{
> +       /* inherited and parent sandbox */
> +       check_ptrace(_metadata, 1, 1, 0, -1);
> +}
> +
> +TEST(ptrace_deny_with_forked_sandbox)
> +{
> +       /* inherited, parent and child sandbox */
> +       check_ptrace(_metadata, 1, 1, 1, -1);
> +}
> +
> +TEST(ptrace_deny_with_sibling_sandbox)
> +{
> +       /* parent and child sandbox */
> +       check_ptrace(_metadata, 0, 1, 1, -1);
> +}
> +
> +TEST_HARNESS_MAIN
> --
> 2.11.0
>

Awesome. I love to see all these tests, with both positive and
negative checks. Nice!

-Kees

--=20
Kees Cook
Pixel Security
