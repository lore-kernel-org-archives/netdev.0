From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v2 4/6] selftests: move vDSO tests from Documentation/vDSO
Date: Tue, 13 Sep 2016 14:18:43 -0600
Message-ID: <e3b126f66e732d003322bdcecc90eb508a5d7327.1473795601.git.shuahkh@osg.samsung.com>
References: <cover.1473795601.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-watchdog@vger.kernel.org, linux-kselftest@vger.kernel.org
To: corbet@lwn.net, richardcochran@gmail.com, wim@iguana.be,
        linux@roeck-us.net, nab@linux-iscsi.org,
        maheshkhanwalkar@gmail.com, timur@codeaurora.org, arnd@arndb.de,
        ghackmann@google.com, ben@decadent.org.uk, thuth@redhat.com,
        christopher.s.hall@intel.com, john.stultz@linaro.org,
        sergei.shtylyov@cogentembedded.com, mpe@ellerman.id.au,
        jani.nikula@linux.intel.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <cover.1473795601.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1473795601.git.shuahkh@osg.samsung.com>
References: <cover.1473795601.git.shuahkh@osg.samsung.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove vDSO from Makefile to move the to selftests. Update vDSO Makefile
to work under selftests. vDSO will not be run as part of selftests suite
and will not be included in install targets. They can be built separately
for now.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 Documentation/Makefile                             |   2 +-
 Documentation/vDSO/.gitignore                      |   2 -
 Documentation/vDSO/Makefile                        |  17 --
 Documentation/vDSO/parse_vdso.c                    | 269 ---------------------
 Documentation/vDSO/vdso_standalone_test_x86.c      | 128 ----------
 Documentation/vDSO/vdso_test.c                     |  52 ----
 tools/testing/selftests/vDSO/.gitignore            |   2 +
 tools/testing/selftests/vDSO/Makefile              |  20 ++
 tools/testing/selftests/vDSO/parse_vdso.c          | 269 +++++++++++++++++++++
 .../selftests/vDSO/vdso_standalone_test_x86.c      | 128 ++++++++++
 tools/testing/selftests/vDSO/vdso_test.c           |  52 ++++
 11 files changed, 472 insertions(+), 469 deletions(-)
 delete mode 100644 Documentation/vDSO/.gitignore
 delete mode 100644 Documentation/vDSO/Makefile
 delete mode 100644 Documentation/vDSO/parse_vdso.c
 delete mode 100644 Documentation/vDSO/vdso_standalone_test_x86.c
 delete mode 100644 Documentation/vDSO/vdso_test.c
 create mode 100644 tools/testing/selftests/vDSO/.gitignore
 create mode 100644 tools/testing/selftests/vDSO/Makefile
 create mode 100644 tools/testing/selftests/vDSO/parse_vdso.c
 create mode 100644 tools/testing/selftests/vDSO/vdso_standalone_test_x86.c
 create mode 100644 tools/testing/selftests/vDSO/vdso_test.c

diff --git a/Documentation/Makefile b/Documentation/Makefile
index 8cd6d1a..085b917 100644
--- a/Documentation/Makefile
+++ b/Documentation/Makefile
@@ -1,3 +1,3 @@
 subdir-y := accounting auxdisplay blackfin \
 	ia64 laptops mic misc-devices \
-	networking pcmcia timers vDSO watchdog
+	networking pcmcia timers watchdog
diff --git a/Documentation/vDSO/.gitignore b/Documentation/vDSO/.gitignore
deleted file mode 100644
index 133bf9e..0000000
--- a/Documentation/vDSO/.gitignore
+++ /dev/null
@@ -1,2 +0,0 @@
-vdso_test
-vdso_standalone_test_x86
diff --git a/Documentation/vDSO/Makefile b/Documentation/vDSO/Makefile
deleted file mode 100644
index b12e987..0000000
--- a/Documentation/vDSO/Makefile
+++ /dev/null
@@ -1,17 +0,0 @@
-ifndef CROSS_COMPILE
-# vdso_test won't build for glibc < 2.16, so disable it
-# hostprogs-y := vdso_test
-hostprogs-$(CONFIG_X86) := vdso_standalone_test_x86
-vdso_standalone_test_x86-objs := vdso_standalone_test_x86.o parse_vdso.o
-vdso_test-objs := parse_vdso.o vdso_test.o
-
-# Tell kbuild to always build the programs
-always := $(hostprogs-y)
-
-HOSTCFLAGS := -I$(objtree)/usr/include -std=gnu99
-HOSTCFLAGS_vdso_standalone_test_x86.o := -fno-asynchronous-unwind-tables -fno-stack-protector
-HOSTLOADLIBES_vdso_standalone_test_x86 := -nostdlib
-ifeq ($(CONFIG_X86_32),y)
-HOSTLOADLIBES_vdso_standalone_test_x86 += -lgcc_s
-endif
-endif
diff --git a/Documentation/vDSO/parse_vdso.c b/Documentation/vDSO/parse_vdso.c
deleted file mode 100644
index 1dbb4b8..0000000
--- a/Documentation/vDSO/parse_vdso.c
+++ /dev/null
@@ -1,269 +0,0 @@
-/*
- * parse_vdso.c: Linux reference vDSO parser
- * Written by Andrew Lutomirski, 2011-2014.
- *
- * This code is meant to be linked in to various programs that run on Linux.
- * As such, it is available with as few restrictions as possible.  This file
- * is licensed under the Creative Commons Zero License, version 1.0,
- * available at http://creativecommons.org/publicdomain/zero/1.0/legalcode
- *
- * The vDSO is a regular ELF DSO that the kernel maps into user space when
- * it starts a program.  It works equally well in statically and dynamically
- * linked binaries.
- *
- * This code is tested on x86.  In principle it should work on any
- * architecture that has a vDSO.
- */
-
-#include <stdbool.h>
-#include <stdint.h>
-#include <string.h>
-#include <limits.h>
-#include <elf.h>
-
-/*
- * To use this vDSO parser, first call one of the vdso_init_* functions.
- * If you've already parsed auxv, then pass the value of AT_SYSINFO_EHDR
- * to vdso_init_from_sysinfo_ehdr.  Otherwise pass auxv to vdso_init_from_auxv.
- * Then call vdso_sym for each symbol you want.  For example, to look up
- * gettimeofday on x86_64, use:
- *
- *     <some pointer> = vdso_sym("LINUX_2.6", "gettimeofday");
- * or
- *     <some pointer> = vdso_sym("LINUX_2.6", "__vdso_gettimeofday");
- *
- * vdso_sym will return 0 if the symbol doesn't exist or if the init function
- * failed or was not called.  vdso_sym is a little slow, so its return value
- * should be cached.
- *
- * vdso_sym is threadsafe; the init functions are not.
- *
- * These are the prototypes:
- */
-extern void vdso_init_from_auxv(void *auxv);
-extern void vdso_init_from_sysinfo_ehdr(uintptr_t base);
-extern void *vdso_sym(const char *version, const char *name);
-
-
-/* And here's the code. */
-#ifndef ELF_BITS
-# if ULONG_MAX > 0xffffffffUL
-#  define ELF_BITS 64
-# else
-#  define ELF_BITS 32
-# endif
-#endif
-
-#define ELF_BITS_XFORM2(bits, x) Elf##bits##_##x
-#define ELF_BITS_XFORM(bits, x) ELF_BITS_XFORM2(bits, x)
-#define ELF(x) ELF_BITS_XFORM(ELF_BITS, x)
-
-static struct vdso_info
-{
-	bool valid;
-
-	/* Load information */
-	uintptr_t load_addr;
-	uintptr_t load_offset;  /* load_addr - recorded vaddr */
-
-	/* Symbol table */
-	ELF(Sym) *symtab;
-	const char *symstrings;
-	ELF(Word) *bucket, *chain;
-	ELF(Word) nbucket, nchain;
-
-	/* Version table */
-	ELF(Versym) *versym;
-	ELF(Verdef) *verdef;
-} vdso_info;
-
-/* Straight from the ELF specification. */
-static unsigned long elf_hash(const unsigned char *name)
-{
-	unsigned long h = 0, g;
-	while (*name)
-	{
-		h = (h << 4) + *name++;
-		if (g = h & 0xf0000000)
-			h ^= g >> 24;
-		h &= ~g;
-	}
-	return h;
-}
-
-void vdso_init_from_sysinfo_ehdr(uintptr_t base)
-{
-	size_t i;
-	bool found_vaddr = false;
-
-	vdso_info.valid = false;
-
-	vdso_info.load_addr = base;
-
-	ELF(Ehdr) *hdr = (ELF(Ehdr)*)base;
-	if (hdr->e_ident[EI_CLASS] !=
-	    (ELF_BITS == 32 ? ELFCLASS32 : ELFCLASS64)) {
-		return;  /* Wrong ELF class -- check ELF_BITS */
-	}
-
-	ELF(Phdr) *pt = (ELF(Phdr)*)(vdso_info.load_addr + hdr->e_phoff);
-	ELF(Dyn) *dyn = 0;
-
-	/*
-	 * We need two things from the segment table: the load offset
-	 * and the dynamic table.
-	 */
-	for (i = 0; i < hdr->e_phnum; i++)
-	{
-		if (pt[i].p_type == PT_LOAD && !found_vaddr) {
-			found_vaddr = true;
-			vdso_info.load_offset =	base
-				+ (uintptr_t)pt[i].p_offset
-				- (uintptr_t)pt[i].p_vaddr;
-		} else if (pt[i].p_type == PT_DYNAMIC) {
-			dyn = (ELF(Dyn)*)(base + pt[i].p_offset);
-		}
-	}
-
-	if (!found_vaddr || !dyn)
-		return;  /* Failed */
-
-	/*
-	 * Fish out the useful bits of the dynamic table.
-	 */
-	ELF(Word) *hash = 0;
-	vdso_info.symstrings = 0;
-	vdso_info.symtab = 0;
-	vdso_info.versym = 0;
-	vdso_info.verdef = 0;
-	for (i = 0; dyn[i].d_tag != DT_NULL; i++) {
-		switch (dyn[i].d_tag) {
-		case DT_STRTAB:
-			vdso_info.symstrings = (const char *)
-				((uintptr_t)dyn[i].d_un.d_ptr
-				 + vdso_info.load_offset);
-			break;
-		case DT_SYMTAB:
-			vdso_info.symtab = (ELF(Sym) *)
-				((uintptr_t)dyn[i].d_un.d_ptr
-				 + vdso_info.load_offset);
-			break;
-		case DT_HASH:
-			hash = (ELF(Word) *)
-				((uintptr_t)dyn[i].d_un.d_ptr
-				 + vdso_info.load_offset);
-			break;
-		case DT_VERSYM:
-			vdso_info.versym = (ELF(Versym) *)
-				((uintptr_t)dyn[i].d_un.d_ptr
-				 + vdso_info.load_offset);
-			break;
-		case DT_VERDEF:
-			vdso_info.verdef = (ELF(Verdef) *)
-				((uintptr_t)dyn[i].d_un.d_ptr
-				 + vdso_info.load_offset);
-			break;
-		}
-	}
-	if (!vdso_info.symstrings || !vdso_info.symtab || !hash)
-		return;  /* Failed */
-
-	if (!vdso_info.verdef)
-		vdso_info.versym = 0;
-
-	/* Parse the hash table header. */
-	vdso_info.nbucket = hash[0];
-	vdso_info.nchain = hash[1];
-	vdso_info.bucket = &hash[2];
-	vdso_info.chain = &hash[vdso_info.nbucket + 2];
-
-	/* That's all we need. */
-	vdso_info.valid = true;
-}
-
-static bool vdso_match_version(ELF(Versym) ver,
-			       const char *name, ELF(Word) hash)
-{
-	/*
-	 * This is a helper function to check if the version indexed by
-	 * ver matches name (which hashes to hash).
-	 *
-	 * The version definition table is a mess, and I don't know how
-	 * to do this in better than linear time without allocating memory
-	 * to build an index.  I also don't know why the table has
-	 * variable size entries in the first place.
-	 *
-	 * For added fun, I can't find a comprehensible specification of how
-	 * to parse all the weird flags in the table.
-	 *
-	 * So I just parse the whole table every time.
-	 */
-
-	/* First step: find the version definition */
-	ver &= 0x7fff;  /* Apparently bit 15 means "hidden" */
-	ELF(Verdef) *def = vdso_info.verdef;
-	while(true) {
-		if ((def->vd_flags & VER_FLG_BASE) == 0
-		    && (def->vd_ndx & 0x7fff) == ver)
-			break;
-
-		if (def->vd_next == 0)
-			return false;  /* No definition. */
-
-		def = (ELF(Verdef) *)((char *)def + def->vd_next);
-	}
-
-	/* Now figure out whether it matches. */
-	ELF(Verdaux) *aux = (ELF(Verdaux)*)((char *)def + def->vd_aux);
-	return def->vd_hash == hash
-		&& !strcmp(name, vdso_info.symstrings + aux->vda_name);
-}
-
-void *vdso_sym(const char *version, const char *name)
-{
-	unsigned long ver_hash;
-	if (!vdso_info.valid)
-		return 0;
-
-	ver_hash = elf_hash(version);
-	ELF(Word) chain = vdso_info.bucket[elf_hash(name) % vdso_info.nbucket];
-
-	for (; chain != STN_UNDEF; chain = vdso_info.chain[chain]) {
-		ELF(Sym) *sym = &vdso_info.symtab[chain];
-
-		/* Check for a defined global or weak function w/ right name. */
-		if (ELF64_ST_TYPE(sym->st_info) != STT_FUNC)
-			continue;
-		if (ELF64_ST_BIND(sym->st_info) != STB_GLOBAL &&
-		    ELF64_ST_BIND(sym->st_info) != STB_WEAK)
-			continue;
-		if (sym->st_shndx == SHN_UNDEF)
-			continue;
-		if (strcmp(name, vdso_info.symstrings + sym->st_name))
-			continue;
-
-		/* Check symbol version. */
-		if (vdso_info.versym
-		    && !vdso_match_version(vdso_info.versym[chain],
-					   version, ver_hash))
-			continue;
-
-		return (void *)(vdso_info.load_offset + sym->st_value);
-	}
-
-	return 0;
-}
-
-void vdso_init_from_auxv(void *auxv)
-{
-	ELF(auxv_t) *elf_auxv = auxv;
-	for (int i = 0; elf_auxv[i].a_type != AT_NULL; i++)
-	{
-		if (elf_auxv[i].a_type == AT_SYSINFO_EHDR) {
-			vdso_init_from_sysinfo_ehdr(elf_auxv[i].a_un.a_val);
-			return;
-		}
-	}
-
-	vdso_info.valid = false;
-}
diff --git a/Documentation/vDSO/vdso_standalone_test_x86.c b/Documentation/vDSO/vdso_standalone_test_x86.c
deleted file mode 100644
index 93b0ebf..0000000
--- a/Documentation/vDSO/vdso_standalone_test_x86.c
+++ /dev/null
@@ -1,128 +0,0 @@
-/*
- * vdso_test.c: Sample code to test parse_vdso.c on x86
- * Copyright (c) 2011-2014 Andy Lutomirski
- * Subject to the GNU General Public License, version 2
- *
- * You can amuse yourself by compiling with:
- * gcc -std=gnu99 -nostdlib
- *     -Os -fno-asynchronous-unwind-tables -flto -lgcc_s
- *      vdso_standalone_test_x86.c parse_vdso.c
- * to generate a small binary.  On x86_64, you can omit -lgcc_s
- * if you want the binary to be completely standalone.
- */
-
-#include <sys/syscall.h>
-#include <sys/time.h>
-#include <unistd.h>
-#include <stdint.h>
-
-extern void *vdso_sym(const char *version, const char *name);
-extern void vdso_init_from_sysinfo_ehdr(uintptr_t base);
-extern void vdso_init_from_auxv(void *auxv);
-
-/* We need a libc functions... */
-int strcmp(const char *a, const char *b)
-{
-	/* This implementation is buggy: it never returns -1. */
-	while (*a || *b) {
-		if (*a != *b)
-			return 1;
-		if (*a == 0 || *b == 0)
-			return 1;
-		a++;
-		b++;
-	}
-
-	return 0;
-}
-
-/* ...and two syscalls.  This is x86-specific. */
-static inline long x86_syscall3(long nr, long a0, long a1, long a2)
-{
-	long ret;
-#ifdef __x86_64__
-	asm volatile ("syscall" : "=a" (ret) : "a" (nr),
-		      "D" (a0), "S" (a1), "d" (a2) :
-		      "cc", "memory", "rcx",
-		      "r8", "r9", "r10", "r11" );
-#else
-	asm volatile ("int $0x80" : "=a" (ret) : "a" (nr),
-		      "b" (a0), "c" (a1), "d" (a2) :
-		      "cc", "memory" );
-#endif
-	return ret;
-}
-
-static inline long linux_write(int fd, const void *data, size_t len)
-{
-	return x86_syscall3(__NR_write, fd, (long)data, (long)len);
-}
-
-static inline void linux_exit(int code)
-{
-	x86_syscall3(__NR_exit, code, 0, 0);
-}
-
-void to_base10(char *lastdig, time_t n)
-{
-	while (n) {
-		*lastdig = (n % 10) + '0';
-		n /= 10;
-		lastdig--;
-	}
-}
-
-__attribute__((externally_visible)) void c_main(void **stack)
-{
-	/* Parse the stack */
-	long argc = (long)*stack;
-	stack += argc + 2;
-
-	/* Now we're pointing at the environment.  Skip it. */
-	while(*stack)
-		stack++;
-	stack++;
-
-	/* Now we're pointing at auxv.  Initialize the vDSO parser. */
-	vdso_init_from_auxv((void *)stack);
-
-	/* Find gettimeofday. */
-	typedef long (*gtod_t)(struct timeval *tv, struct timezone *tz);
-	gtod_t gtod = (gtod_t)vdso_sym("LINUX_2.6", "__vdso_gettimeofday");
-
-	if (!gtod)
-		linux_exit(1);
-
-	struct timeval tv;
-	long ret = gtod(&tv, 0);
-
-	if (ret == 0) {
-		char buf[] = "The time is                     .000000\n";
-		to_base10(buf + 31, tv.tv_sec);
-		to_base10(buf + 38, tv.tv_usec);
-		linux_write(1, buf, sizeof(buf) - 1);
-	} else {
-		linux_exit(ret);
-	}
-
-	linux_exit(0);
-}
-
-/*
- * This is the real entry point.  It passes the initial stack into
- * the C entry point.
- */
-asm (
-	".text\n"
-	".global _start\n"
-	".type _start,@function\n"
-	"_start:\n\t"
-#ifdef __x86_64__
-	"mov %rsp,%rdi\n\t"
-	"jmp c_main"
-#else
-	"push %esp\n\t"
-	"call c_main\n\t"
-	"int $3"
-#endif
-	);
diff --git a/Documentation/vDSO/vdso_test.c b/Documentation/vDSO/vdso_test.c
deleted file mode 100644
index 8daeb7d7..0000000
--- a/Documentation/vDSO/vdso_test.c
+++ /dev/null
@@ -1,52 +0,0 @@
-/*
- * vdso_test.c: Sample code to test parse_vdso.c
- * Copyright (c) 2014 Andy Lutomirski
- * Subject to the GNU General Public License, version 2
- *
- * Compile with:
- * gcc -std=gnu99 vdso_test.c parse_vdso.c
- *
- * Tested on x86, 32-bit and 64-bit.  It may work on other architectures, too.
- */
-
-#include <stdint.h>
-#include <elf.h>
-#include <stdio.h>
-#include <sys/auxv.h>
-#include <sys/time.h>
-
-extern void *vdso_sym(const char *version, const char *name);
-extern void vdso_init_from_sysinfo_ehdr(uintptr_t base);
-extern void vdso_init_from_auxv(void *auxv);
-
-int main(int argc, char **argv)
-{
-	unsigned long sysinfo_ehdr = getauxval(AT_SYSINFO_EHDR);
-	if (!sysinfo_ehdr) {
-		printf("AT_SYSINFO_EHDR is not present!\n");
-		return 0;
-	}
-
-	vdso_init_from_sysinfo_ehdr(getauxval(AT_SYSINFO_EHDR));
-
-	/* Find gettimeofday. */
-	typedef long (*gtod_t)(struct timeval *tv, struct timezone *tz);
-	gtod_t gtod = (gtod_t)vdso_sym("LINUX_2.6", "__vdso_gettimeofday");
-
-	if (!gtod) {
-		printf("Could not find __vdso_gettimeofday\n");
-		return 1;
-	}
-
-	struct timeval tv;
-	long ret = gtod(&tv, 0);
-
-	if (ret == 0) {
-		printf("The time is %lld.%06lld\n",
-		       (long long)tv.tv_sec, (long long)tv.tv_usec);
-	} else {
-		printf("__vdso_gettimeofday failed\n");
-	}
-
-	return 0;
-}
diff --git a/tools/testing/selftests/vDSO/.gitignore b/tools/testing/selftests/vDSO/.gitignore
new file mode 100644
index 0000000..133bf9e
--- /dev/null
+++ b/tools/testing/selftests/vDSO/.gitignore
@@ -0,0 +1,2 @@
+vdso_test
+vdso_standalone_test_x86
diff --git a/tools/testing/selftests/vDSO/Makefile b/tools/testing/selftests/vDSO/Makefile
new file mode 100644
index 0000000..706b68b
--- /dev/null
+++ b/tools/testing/selftests/vDSO/Makefile
@@ -0,0 +1,20 @@
+ifndef CROSS_COMPILE
+CFLAGS := -std=gnu99
+CFLAGS_vdso_standalone_test_x86 := -nostdlib -fno-asynchronous-unwind-tables -fno-stack-protector
+ifeq ($(CONFIG_X86_32),y)
+LDLIBS += -lgcc_s
+endif
+
+TEST_PROGS := vdso_test vdso_standalone_test_x86
+
+all: $(TEST_PROGS)
+vdso_test: parse_vdso.c vdso_test.c
+vdso_standalone_test_x86: vdso_standalone_test_x86.c parse_vdso.c
+	$(CC) $(CFLAGS) $(CFLAGS_vdso_standalone_test_x86) \
+		vdso_standalone_test_x86.c parse_vdso.c \
+		-o vdso_standalone_test_x86
+
+include ../lib.mk
+clean:
+	rm -fr $(TEST_PROGS)
+endif
diff --git a/tools/testing/selftests/vDSO/parse_vdso.c b/tools/testing/selftests/vDSO/parse_vdso.c
new file mode 100644
index 0000000..1dbb4b8
--- /dev/null
+++ b/tools/testing/selftests/vDSO/parse_vdso.c
@@ -0,0 +1,269 @@
+/*
+ * parse_vdso.c: Linux reference vDSO parser
+ * Written by Andrew Lutomirski, 2011-2014.
+ *
+ * This code is meant to be linked in to various programs that run on Linux.
+ * As such, it is available with as few restrictions as possible.  This file
+ * is licensed under the Creative Commons Zero License, version 1.0,
+ * available at http://creativecommons.org/publicdomain/zero/1.0/legalcode
+ *
+ * The vDSO is a regular ELF DSO that the kernel maps into user space when
+ * it starts a program.  It works equally well in statically and dynamically
+ * linked binaries.
+ *
+ * This code is tested on x86.  In principle it should work on any
+ * architecture that has a vDSO.
+ */
+
+#include <stdbool.h>
+#include <stdint.h>
+#include <string.h>
+#include <limits.h>
+#include <elf.h>
+
+/*
+ * To use this vDSO parser, first call one of the vdso_init_* functions.
+ * If you've already parsed auxv, then pass the value of AT_SYSINFO_EHDR
+ * to vdso_init_from_sysinfo_ehdr.  Otherwise pass auxv to vdso_init_from_auxv.
+ * Then call vdso_sym for each symbol you want.  For example, to look up
+ * gettimeofday on x86_64, use:
+ *
+ *     <some pointer> = vdso_sym("LINUX_2.6", "gettimeofday");
+ * or
+ *     <some pointer> = vdso_sym("LINUX_2.6", "__vdso_gettimeofday");
+ *
+ * vdso_sym will return 0 if the symbol doesn't exist or if the init function
+ * failed or was not called.  vdso_sym is a little slow, so its return value
+ * should be cached.
+ *
+ * vdso_sym is threadsafe; the init functions are not.
+ *
+ * These are the prototypes:
+ */
+extern void vdso_init_from_auxv(void *auxv);
+extern void vdso_init_from_sysinfo_ehdr(uintptr_t base);
+extern void *vdso_sym(const char *version, const char *name);
+
+
+/* And here's the code. */
+#ifndef ELF_BITS
+# if ULONG_MAX > 0xffffffffUL
+#  define ELF_BITS 64
+# else
+#  define ELF_BITS 32
+# endif
+#endif
+
+#define ELF_BITS_XFORM2(bits, x) Elf##bits##_##x
+#define ELF_BITS_XFORM(bits, x) ELF_BITS_XFORM2(bits, x)
+#define ELF(x) ELF_BITS_XFORM(ELF_BITS, x)
+
+static struct vdso_info
+{
+	bool valid;
+
+	/* Load information */
+	uintptr_t load_addr;
+	uintptr_t load_offset;  /* load_addr - recorded vaddr */
+
+	/* Symbol table */
+	ELF(Sym) *symtab;
+	const char *symstrings;
+	ELF(Word) *bucket, *chain;
+	ELF(Word) nbucket, nchain;
+
+	/* Version table */
+	ELF(Versym) *versym;
+	ELF(Verdef) *verdef;
+} vdso_info;
+
+/* Straight from the ELF specification. */
+static unsigned long elf_hash(const unsigned char *name)
+{
+	unsigned long h = 0, g;
+	while (*name)
+	{
+		h = (h << 4) + *name++;
+		if (g = h & 0xf0000000)
+			h ^= g >> 24;
+		h &= ~g;
+	}
+	return h;
+}
+
+void vdso_init_from_sysinfo_ehdr(uintptr_t base)
+{
+	size_t i;
+	bool found_vaddr = false;
+
+	vdso_info.valid = false;
+
+	vdso_info.load_addr = base;
+
+	ELF(Ehdr) *hdr = (ELF(Ehdr)*)base;
+	if (hdr->e_ident[EI_CLASS] !=
+	    (ELF_BITS == 32 ? ELFCLASS32 : ELFCLASS64)) {
+		return;  /* Wrong ELF class -- check ELF_BITS */
+	}
+
+	ELF(Phdr) *pt = (ELF(Phdr)*)(vdso_info.load_addr + hdr->e_phoff);
+	ELF(Dyn) *dyn = 0;
+
+	/*
+	 * We need two things from the segment table: the load offset
+	 * and the dynamic table.
+	 */
+	for (i = 0; i < hdr->e_phnum; i++)
+	{
+		if (pt[i].p_type == PT_LOAD && !found_vaddr) {
+			found_vaddr = true;
+			vdso_info.load_offset =	base
+				+ (uintptr_t)pt[i].p_offset
+				- (uintptr_t)pt[i].p_vaddr;
+		} else if (pt[i].p_type == PT_DYNAMIC) {
+			dyn = (ELF(Dyn)*)(base + pt[i].p_offset);
+		}
+	}
+
+	if (!found_vaddr || !dyn)
+		return;  /* Failed */
+
+	/*
+	 * Fish out the useful bits of the dynamic table.
+	 */
+	ELF(Word) *hash = 0;
+	vdso_info.symstrings = 0;
+	vdso_info.symtab = 0;
+	vdso_info.versym = 0;
+	vdso_info.verdef = 0;
+	for (i = 0; dyn[i].d_tag != DT_NULL; i++) {
+		switch (dyn[i].d_tag) {
+		case DT_STRTAB:
+			vdso_info.symstrings = (const char *)
+				((uintptr_t)dyn[i].d_un.d_ptr
+				 + vdso_info.load_offset);
+			break;
+		case DT_SYMTAB:
+			vdso_info.symtab = (ELF(Sym) *)
+				((uintptr_t)dyn[i].d_un.d_ptr
+				 + vdso_info.load_offset);
+			break;
+		case DT_HASH:
+			hash = (ELF(Word) *)
+				((uintptr_t)dyn[i].d_un.d_ptr
+				 + vdso_info.load_offset);
+			break;
+		case DT_VERSYM:
+			vdso_info.versym = (ELF(Versym) *)
+				((uintptr_t)dyn[i].d_un.d_ptr
+				 + vdso_info.load_offset);
+			break;
+		case DT_VERDEF:
+			vdso_info.verdef = (ELF(Verdef) *)
+				((uintptr_t)dyn[i].d_un.d_ptr
+				 + vdso_info.load_offset);
+			break;
+		}
+	}
+	if (!vdso_info.symstrings || !vdso_info.symtab || !hash)
+		return;  /* Failed */
+
+	if (!vdso_info.verdef)
+		vdso_info.versym = 0;
+
+	/* Parse the hash table header. */
+	vdso_info.nbucket = hash[0];
+	vdso_info.nchain = hash[1];
+	vdso_info.bucket = &hash[2];
+	vdso_info.chain = &hash[vdso_info.nbucket + 2];
+
+	/* That's all we need. */
+	vdso_info.valid = true;
+}
+
+static bool vdso_match_version(ELF(Versym) ver,
+			       const char *name, ELF(Word) hash)
+{
+	/*
+	 * This is a helper function to check if the version indexed by
+	 * ver matches name (which hashes to hash).
+	 *
+	 * The version definition table is a mess, and I don't know how
+	 * to do this in better than linear time without allocating memory
+	 * to build an index.  I also don't know why the table has
+	 * variable size entries in the first place.
+	 *
+	 * For added fun, I can't find a comprehensible specification of how
+	 * to parse all the weird flags in the table.
+	 *
+	 * So I just parse the whole table every time.
+	 */
+
+	/* First step: find the version definition */
+	ver &= 0x7fff;  /* Apparently bit 15 means "hidden" */
+	ELF(Verdef) *def = vdso_info.verdef;
+	while(true) {
+		if ((def->vd_flags & VER_FLG_BASE) == 0
+		    && (def->vd_ndx & 0x7fff) == ver)
+			break;
+
+		if (def->vd_next == 0)
+			return false;  /* No definition. */
+
+		def = (ELF(Verdef) *)((char *)def + def->vd_next);
+	}
+
+	/* Now figure out whether it matches. */
+	ELF(Verdaux) *aux = (ELF(Verdaux)*)((char *)def + def->vd_aux);
+	return def->vd_hash == hash
+		&& !strcmp(name, vdso_info.symstrings + aux->vda_name);
+}
+
+void *vdso_sym(const char *version, const char *name)
+{
+	unsigned long ver_hash;
+	if (!vdso_info.valid)
+		return 0;
+
+	ver_hash = elf_hash(version);
+	ELF(Word) chain = vdso_info.bucket[elf_hash(name) % vdso_info.nbucket];
+
+	for (; chain != STN_UNDEF; chain = vdso_info.chain[chain]) {
+		ELF(Sym) *sym = &vdso_info.symtab[chain];
+
+		/* Check for a defined global or weak function w/ right name. */
+		if (ELF64_ST_TYPE(sym->st_info) != STT_FUNC)
+			continue;
+		if (ELF64_ST_BIND(sym->st_info) != STB_GLOBAL &&
+		    ELF64_ST_BIND(sym->st_info) != STB_WEAK)
+			continue;
+		if (sym->st_shndx == SHN_UNDEF)
+			continue;
+		if (strcmp(name, vdso_info.symstrings + sym->st_name))
+			continue;
+
+		/* Check symbol version. */
+		if (vdso_info.versym
+		    && !vdso_match_version(vdso_info.versym[chain],
+					   version, ver_hash))
+			continue;
+
+		return (void *)(vdso_info.load_offset + sym->st_value);
+	}
+
+	return 0;
+}
+
+void vdso_init_from_auxv(void *auxv)
+{
+	ELF(auxv_t) *elf_auxv = auxv;
+	for (int i = 0; elf_auxv[i].a_type != AT_NULL; i++)
+	{
+		if (elf_auxv[i].a_type == AT_SYSINFO_EHDR) {
+			vdso_init_from_sysinfo_ehdr(elf_auxv[i].a_un.a_val);
+			return;
+		}
+	}
+
+	vdso_info.valid = false;
+}
diff --git a/tools/testing/selftests/vDSO/vdso_standalone_test_x86.c b/tools/testing/selftests/vDSO/vdso_standalone_test_x86.c
new file mode 100644
index 0000000..93b0ebf
--- /dev/null
+++ b/tools/testing/selftests/vDSO/vdso_standalone_test_x86.c
@@ -0,0 +1,128 @@
+/*
+ * vdso_test.c: Sample code to test parse_vdso.c on x86
+ * Copyright (c) 2011-2014 Andy Lutomirski
+ * Subject to the GNU General Public License, version 2
+ *
+ * You can amuse yourself by compiling with:
+ * gcc -std=gnu99 -nostdlib
+ *     -Os -fno-asynchronous-unwind-tables -flto -lgcc_s
+ *      vdso_standalone_test_x86.c parse_vdso.c
+ * to generate a small binary.  On x86_64, you can omit -lgcc_s
+ * if you want the binary to be completely standalone.
+ */
+
+#include <sys/syscall.h>
+#include <sys/time.h>
+#include <unistd.h>
+#include <stdint.h>
+
+extern void *vdso_sym(const char *version, const char *name);
+extern void vdso_init_from_sysinfo_ehdr(uintptr_t base);
+extern void vdso_init_from_auxv(void *auxv);
+
+/* We need a libc functions... */
+int strcmp(const char *a, const char *b)
+{
+	/* This implementation is buggy: it never returns -1. */
+	while (*a || *b) {
+		if (*a != *b)
+			return 1;
+		if (*a == 0 || *b == 0)
+			return 1;
+		a++;
+		b++;
+	}
+
+	return 0;
+}
+
+/* ...and two syscalls.  This is x86-specific. */
+static inline long x86_syscall3(long nr, long a0, long a1, long a2)
+{
+	long ret;
+#ifdef __x86_64__
+	asm volatile ("syscall" : "=a" (ret) : "a" (nr),
+		      "D" (a0), "S" (a1), "d" (a2) :
+		      "cc", "memory", "rcx",
+		      "r8", "r9", "r10", "r11" );
+#else
+	asm volatile ("int $0x80" : "=a" (ret) : "a" (nr),
+		      "b" (a0), "c" (a1), "d" (a2) :
+		      "cc", "memory" );
+#endif
+	return ret;
+}
+
+static inline long linux_write(int fd, const void *data, size_t len)
+{
+	return x86_syscall3(__NR_write, fd, (long)data, (long)len);
+}
+
+static inline void linux_exit(int code)
+{
+	x86_syscall3(__NR_exit, code, 0, 0);
+}
+
+void to_base10(char *lastdig, time_t n)
+{
+	while (n) {
+		*lastdig = (n % 10) + '0';
+		n /= 10;
+		lastdig--;
+	}
+}
+
+__attribute__((externally_visible)) void c_main(void **stack)
+{
+	/* Parse the stack */
+	long argc = (long)*stack;
+	stack += argc + 2;
+
+	/* Now we're pointing at the environment.  Skip it. */
+	while(*stack)
+		stack++;
+	stack++;
+
+	/* Now we're pointing at auxv.  Initialize the vDSO parser. */
+	vdso_init_from_auxv((void *)stack);
+
+	/* Find gettimeofday. */
+	typedef long (*gtod_t)(struct timeval *tv, struct timezone *tz);
+	gtod_t gtod = (gtod_t)vdso_sym("LINUX_2.6", "__vdso_gettimeofday");
+
+	if (!gtod)
+		linux_exit(1);
+
+	struct timeval tv;
+	long ret = gtod(&tv, 0);
+
+	if (ret == 0) {
+		char buf[] = "The time is                     .000000\n";
+		to_base10(buf + 31, tv.tv_sec);
+		to_base10(buf + 38, tv.tv_usec);
+		linux_write(1, buf, sizeof(buf) - 1);
+	} else {
+		linux_exit(ret);
+	}
+
+	linux_exit(0);
+}
+
+/*
+ * This is the real entry point.  It passes the initial stack into
+ * the C entry point.
+ */
+asm (
+	".text\n"
+	".global _start\n"
+	".type _start,@function\n"
+	"_start:\n\t"
+#ifdef __x86_64__
+	"mov %rsp,%rdi\n\t"
+	"jmp c_main"
+#else
+	"push %esp\n\t"
+	"call c_main\n\t"
+	"int $3"
+#endif
+	);
diff --git a/tools/testing/selftests/vDSO/vdso_test.c b/tools/testing/selftests/vDSO/vdso_test.c
new file mode 100644
index 0000000..8daeb7d7
--- /dev/null
+++ b/tools/testing/selftests/vDSO/vdso_test.c
@@ -0,0 +1,52 @@
+/*
+ * vdso_test.c: Sample code to test parse_vdso.c
+ * Copyright (c) 2014 Andy Lutomirski
+ * Subject to the GNU General Public License, version 2
+ *
+ * Compile with:
+ * gcc -std=gnu99 vdso_test.c parse_vdso.c
+ *
+ * Tested on x86, 32-bit and 64-bit.  It may work on other architectures, too.
+ */
+
+#include <stdint.h>
+#include <elf.h>
+#include <stdio.h>
+#include <sys/auxv.h>
+#include <sys/time.h>
+
+extern void *vdso_sym(const char *version, const char *name);
+extern void vdso_init_from_sysinfo_ehdr(uintptr_t base);
+extern void vdso_init_from_auxv(void *auxv);
+
+int main(int argc, char **argv)
+{
+	unsigned long sysinfo_ehdr = getauxval(AT_SYSINFO_EHDR);
+	if (!sysinfo_ehdr) {
+		printf("AT_SYSINFO_EHDR is not present!\n");
+		return 0;
+	}
+
+	vdso_init_from_sysinfo_ehdr(getauxval(AT_SYSINFO_EHDR));
+
+	/* Find gettimeofday. */
+	typedef long (*gtod_t)(struct timeval *tv, struct timezone *tz);
+	gtod_t gtod = (gtod_t)vdso_sym("LINUX_2.6", "__vdso_gettimeofday");
+
+	if (!gtod) {
+		printf("Could not find __vdso_gettimeofday\n");
+		return 1;
+	}
+
+	struct timeval tv;
+	long ret = gtod(&tv, 0);
+
+	if (ret == 0) {
+		printf("The time is %lld.%06lld\n",
+		       (long long)tv.tv_sec, (long long)tv.tv_usec);
+	} else {
+		printf("__vdso_gettimeofday failed\n");
+	}
+
+	return 0;
+}
-- 
2.7.4

