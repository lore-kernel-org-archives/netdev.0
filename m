From: Chris J Arges <chris.j.arges@canonical.com>
Subject: Re: [PATCH 00/33] Compile-time stack metadata validation
Date: Fri, 22 Jan 2016 11:43:48 -0600
Message-ID: <20160122174348.GB29221@canonical.com>
References: <cover.1453405861.git.jpoimboe@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	linux-kernel@vger.kernel.org, live-patching@vger.kernel.org,
	Michal Marek <mmarek@suse.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@kernel.org>,
	Borislav Petkov <bp@alien8.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	Pedro Alves <palves@redhat.com>,
	Namhyung Kim <namhyung@gmail.com>,
	Bernd Petrovitsch <bernd@petrovitsch.priv.at>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jiri Slaby <jslaby@suse.cz>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Borislav Petkov <bp@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Alok
To: Josh Poimboeuf <jpoimboe@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1453405861.git.jpoimboe@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 21, 2016 at 04:49:04PM -0600, Josh Poimboeuf wrote:
> This is v16 of the compile-time stack metadata validation patch set,
> along with proposed fixes for most of the warnings it found.  It's based
> on the tip/master branch.
>
Josh,

Looks good, with my config [1] I do still get a few warnings building
linux/linux-next.

Here are the warnings:
$ grep ^stacktool build.log | grep -v staging
stacktool: arch/x86/kvm/vmx.o: vmx_handle_external_intr()+0x67: call without frame pointer save/setup
stacktool: fs/reiserfs/namei.o: set_de_name_and_namelen()+0x9e: return without frame pointer restore
stacktool: fs/reiserfs/namei.o: set_de_name_and_namelen()+0x89: duplicate frame pointer save
stacktool: fs/reiserfs/namei.o: set_de_name_and_namelen()+0x8a: duplicate frame pointer setup
stacktool: fs/reiserfs/namei.o: set_de_name_and_namelen()+0x9e: frame pointer state mismatch
stacktool: fs/reiserfs/namei.o: set_de_name_and_namelen()+0x0: frame pointer state mismatch
stacktool: fs/reiserfs/ibalance.o: .text: unexpected end of section
stacktool: fs/reiserfs/tail_conversion.o: .text: unexpected end of section

For vmx_handle_external_intr, I'm wondering if ignoring this function is the
best option.

--

diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index e2951b6..d19dfb2 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -33,6 +33,7 @@
 #include <linux/slab.h>
 #include <linux/tboot.h>
 #include <linux/hrtimer.h>
+#include <linux/stacktool.h>
 #include "kvm_cache_regs.h"
 #include "x86.h"
 
@@ -8398,6 +8399,7 @@ static void vmx_handle_external_intr(struct kvm_vcpu *vcpu)
        } else
                local_irq_enable();
 }
+STACKTOOL_IGNORE_FUNC(vmx_handle_external_intr);
 
 static bool vmx_has_high_real_mode_segbase(void)
 {

--chris

[1] http://paste.ubuntu.com/14599083/

 
> v15 can be found here:
> 
>   https://lkml.kernel.org/r/cover.1450442274.git.jpoimboe@redhat.com
> 
> For more information about the motivation behind this patch set, and
> more details about what it does, see the first patch changelog and
> tools/stacktool/Documentation/stack-validation.txt.
> 
> Patches 1-4 add stacktool and integrate it into the kernel build.
> 
> Patches 5-28 are some proposed fixes for several of the warnings
> reported by stacktool.  They've been compile-tested and boot-tested in a
> VM, but I haven't attempted any meaningful testing for many of them.
> 
> Patches 29-33 add some directories, files, and functions to the
> stacktool whitelist in order to silence false positive warnings.
> 
> v16:
> - fix all allyesconfig warnings, except for staging
> - get rid of STACKTOOL_IGNORE_INSN which is no longer needed
> - remove several whitelists in favor of automatically whitelisting any
>   function with a special instruction like ljmp, lret, or vmrun
> - split up stacktool patch into 3 parts as suggested by Ingo
> - update the global noreturn function list
> - detect noreturn function fallthroughs
> - skip weak functions in noreturn call detection logic
> - add empty function check to noreturn logic
> - allow non-section rela symbols for __ex_table sections
> - support rare switch table case with jmpq *[addr](%rip)
> - don't warn on frame pointer restore without save
> - rearrange patch order a bit
> 
> v15:
> - restructure code for a new cmdline interface "stacktool check" using
>   the new subcommand framework in tools/lib/subcmd
> - fix 32 bit build fail (put __sp at end) in paravirt_types.h patch 10
>   which was reported by 0day
> 
> v14:
> - make tools/include/linux/list.h self-sufficient
> - create FRAME_OFFSET to allow 32-bit code to be able to access function
>   arguments on the stack
> - add FRAME_OFFSET usage in crypto patch 14/24: "Create stack frames in
>   aesni-intel_asm.S"
> - rename "index" -> "idx" to fix build with some compilers
> 
> v13:
> - LDFLAGS order fix from Chris J Arges
> - new warning fix patches from Chris J Arges
> - "--frame-pointer" -> "--check-frame-pointer"
> 
> v12:
> - rename "stackvalidate" -> "stacktool"
> - move from scripts/ to tools/:
>   - makefile rework
>   - make a copy of the x86 insn code (and warn if the code diverges)
>   - use tools/include/linux/list.h
> - move warning macros to a new warn.h file
> - change wording: "stack validation" -> "stack metadata validation"
> 
> v11:
> - attempt to answer the "why" question better in the documentation and
>   commit message
> - s/FP_SAVE/FRAME_BEGIN/ in documentation
> 
> v10:
> - add scripts/mod to directory ignores
> - remove circular dependencies for ignored objects which are built
>   before stackvalidate
> - fix CONFIG_MODVERSIONS incompatibility
> 
> v9:
> - rename FRAME/ENDFRAME -> FRAME_BEGIN/FRAME_END
> - fix jump table issue for when the original instruction is a jump
> - drop paravirt thunk alignment patch
> - add maintainers to CC for proposed warning fixes
> 
> v8:
> - add proposed fixes for warnings
> - fix all memory leaks
> - process ignores earlier and add more ignore checks
> - always assume POPCNT alternative is enabled
> - drop hweight inline asm fix
> - drop __schedule() ignore patch
> - change .Ltemp_\@ to .Lstackvalidate_ignore_\@ in asm macro
> - fix CONFIG_* checks in asm macros
> - add C versions of ignore macros and frame macros
> - change ";" to "\n" in C macros
> - add ifdef CONFIG_STACK_VALIDATION checks in C ignore macros
> - use numbered label in C ignore macro
> - add missing break in switch case statement in arch-x86.c
> 
> v7:
> - sibling call support
> - document proposed solution for inline asm() frame pointer issues
> - say "kernel entry/exit" instead of "context switch"
> - clarify the checking of switch statement jump tables
> - discard __stackvalidate_ignore_* sections in linker script
> - use .Ltemp_\@ to get a unique label instead of static 3-digit number
> - change STACKVALIDATE_IGNORE_FUNC variable to a static
> - move STACKVALIDATE_IGNORE_INSN to arch-specific .h file
> 
> v6:
> - rename asmvalidate -> stackvalidate (again)
> - gcc-generated object file support
> - recursive branch state analysis
> - external jump support
> - fixup/exception table support
> - jump label support
> - switch statement jump table support
> - added documentation
> - detection of "noreturn" dead end functions
> - added a Kbuild mechanism for skipping files and dirs
> - moved frame pointer macros to arch/x86/include/asm/frame.h
> - moved ignore macros to include/linux/stackvalidate.h
> 
> v5:
> - stackvalidate -> asmvalidate
> - frame pointers only required for non-leaf functions
> - check for the use of the FP_SAVE/RESTORE macros instead of manually
>   analyzing code to detect frame pointer usage
> - additional checks to ensure each function doesn't leave its boundaries
> - make the macros simpler and more flexible
> - support for analyzing ALTERNATIVE macros
> - simplified the arch interfaces in scripts/asmvalidate/arch.h
> - fixed some asmvalidate warnings
> - rebased onto latest tip asm cleanups
> - many more small changes
> 
> v4:
> - Changed the default to CONFIG_STACK_VALIDATION=n, until all the asm
>   code can get cleaned up.
> - Fixed a stackvalidate error path exit code issue found by Michal
>   Marek.
> 
> v3:
> - Added a patch to make the push/pop CFI macros arch-independent, as
>   suggested by H. Peter Anvin
> 
> v2:
> - Fixed memory leaks reported by Petr Mladek
> 
> Cc: linux-kernel@vger.kernel.org
> Cc: live-patching@vger.kernel.org
> Cc: Michal Marek <mmarek@suse.cz>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Andi Kleen <andi@firstfloor.org>
> Cc: Pedro Alves <palves@redhat.com>
> Cc: Namhyung Kim <namhyung@gmail.com>
> Cc: Bernd Petrovitsch <bernd@petrovitsch.priv.at>
> Cc: Chris J Arges <chris.j.arges@canonical.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Jiri Slaby <jslaby@suse.cz>
> Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
> 
> Chris J Arges (1):
>   x86/uaccess: Add stack frame output operand in get_user inline asm
> 
> Josh Poimboeuf (32):
>   x86/stacktool: Compile-time stack metadata validation
>   kbuild/stacktool: Add CONFIG_STACK_VALIDATION option
>   x86/stacktool: Enable stacktool on x86_64
>   x86/stacktool: Add STACKTOOL_IGNORE_FUNC macro
>   x86/xen: Add stack frame dependency to hypercall inline asm calls
>   x86/asm/xen: Set ELF function type for xen_adjust_exception_frame()
>   x86/asm/xen: Create stack frames in xen-asm.S
>   x86/paravirt: Add stack frame dependency to PVOP inline asm calls
>   x86/paravirt: Create a stack frame in PV_CALLEE_SAVE_REGS_THUNK
>   x86/amd: Set ELF function type for vide()
>   x86/asm/crypto: Move .Lbswap_mask data to .rodata section
>   x86/asm/crypto: Move jump_table to .rodata section
>   x86/asm/crypto: Simplify stack usage in sha-mb functions
>   x86/asm/crypto: Don't use rbp as a scratch register
>   x86/asm/crypto: Create stack frames in crypto functions
>   x86/asm/entry: Create stack frames in thunk functions
>   x86/asm/acpi: Create a stack frame in do_suspend_lowlevel()
>   x86/asm: Create stack frames in rwsem functions
>   x86/asm/efi: Create a stack frame in efi_call()
>   x86/asm/power: Create stack frames in hibernate_asm_64.S
>   x86/asm/bpf: Annotate callable functions
>   x86/asm/bpf: Create stack frames in bpf_jit.S
>   x86/kprobes: Get rid of kretprobe_trampoline_holder()
>   x86/kvm: Set ELF function type for fastop functions
>   x86/kvm: Add stack frame dependency to test_cc() inline asm
>   watchdog/hpwdt: Create stack frame in asminline_call()
>   x86/locking: Create stack frame in PV unlock
>   x86/stacktool: Add directory and file whitelists
>   x86/xen: Add xen_cpuid() to stacktool whitelist
>   bpf: Add __bpf_prog_run() to stacktool whitelist
>   sched: Add __schedule() to stacktool whitelist
>   x86/kprobes: Add kretprobe_trampoline() to stacktool whitelist
> 
>  MAINTAINERS                                        |   6 +
>  Makefile                                           |   5 +-
>  arch/Kconfig                                       |   6 +
>  arch/x86/Kconfig                                   |   1 +
>  arch/x86/boot/Makefile                             |   1 +
>  arch/x86/boot/compressed/Makefile                  |   3 +-
>  arch/x86/crypto/aesni-intel_asm.S                  |  75 +-
>  arch/x86/crypto/camellia-aesni-avx-asm_64.S        |  15 +
>  arch/x86/crypto/camellia-aesni-avx2-asm_64.S       |  15 +
>  arch/x86/crypto/cast5-avx-x86_64-asm_64.S          |   9 +
>  arch/x86/crypto/cast6-avx-x86_64-asm_64.S          |  13 +
>  arch/x86/crypto/crc32c-pcl-intel-asm_64.S          |   8 +-
>  arch/x86/crypto/ghash-clmulni-intel_asm.S          |   5 +
>  arch/x86/crypto/serpent-avx-x86_64-asm_64.S        |  13 +
>  arch/x86/crypto/serpent-avx2-asm_64.S              |  13 +
>  arch/x86/crypto/sha-mb/sha1_mb_mgr_flush_avx2.S    |  35 +-
>  arch/x86/crypto/sha-mb/sha1_mb_mgr_submit_avx2.S   |  36 +-
>  arch/x86/crypto/twofish-avx-x86_64-asm_64.S        |  13 +
>  arch/x86/entry/Makefile                            |   4 +
>  arch/x86/entry/thunk_64.S                          |   4 +
>  arch/x86/entry/vdso/Makefile                       |   5 +-
>  arch/x86/include/asm/paravirt.h                    |   9 +-
>  arch/x86/include/asm/paravirt_types.h              |  18 +-
>  arch/x86/include/asm/qspinlock_paravirt.h          |   4 +
>  arch/x86/include/asm/uaccess.h                     |   5 +-
>  arch/x86/include/asm/xen/hypercall.h               |   5 +-
>  arch/x86/kernel/Makefile                           |   5 +
>  arch/x86/kernel/acpi/wakeup_64.S                   |   3 +
>  arch/x86/kernel/cpu/amd.c                          |   5 +-
>  arch/x86/kernel/kprobes/core.c                     |  59 +-
>  arch/x86/kernel/vmlinux.lds.S                      |   5 +-
>  arch/x86/kvm/emulate.c                             |  33 +-
>  arch/x86/lib/rwsem.S                               |  11 +-
>  arch/x86/net/bpf_jit.S                             |  48 +-
>  arch/x86/platform/efi/Makefile                     |   2 +
>  arch/x86/platform/efi/efi_stub_64.S                |   3 +
>  arch/x86/power/hibernate_asm_64.S                  |   7 +
>  arch/x86/purgatory/Makefile                        |   2 +
>  arch/x86/realmode/Makefile                         |   4 +-
>  arch/x86/realmode/rm/Makefile                      |   3 +-
>  arch/x86/xen/enlighten.c                           |   3 +-
>  arch/x86/xen/xen-asm.S                             |  10 +-
>  arch/x86/xen/xen-asm_64.S                          |   1 +
>  drivers/firmware/efi/libstub/Makefile              |   1 +
>  drivers/watchdog/hpwdt.c                           |   8 +-
>  include/linux/stacktool.h                          |  23 +
>  kernel/bpf/core.c                                  |   2 +
>  kernel/sched/core.c                                |   2 +
>  lib/Kconfig.debug                                  |  12 +
>  scripts/Makefile.build                             |  38 +-
>  scripts/mod/Makefile                               |   2 +
>  tools/Makefile                                     |  14 +-
>  tools/stacktool/.gitignore                         |   2 +
>  tools/stacktool/Build                              |  13 +
>  tools/stacktool/Documentation/stack-validation.txt | 333 +++++++
>  tools/stacktool/Makefile                           |  60 ++
>  tools/stacktool/arch.h                             |  44 +
>  tools/stacktool/arch/x86/Build                     |  12 +
>  tools/stacktool/arch/x86/decode.c                  | 172 ++++
>  .../stacktool/arch/x86/insn/gen-insn-attr-x86.awk  | 387 ++++++++
>  tools/stacktool/arch/x86/insn/inat.c               |  97 ++
>  tools/stacktool/arch/x86/insn/inat.h               | 221 +++++
>  tools/stacktool/arch/x86/insn/inat_types.h         |  29 +
>  tools/stacktool/arch/x86/insn/insn.c               | 594 ++++++++++++
>  tools/stacktool/arch/x86/insn/insn.h               | 201 +++++
>  tools/stacktool/arch/x86/insn/x86-opcode-map.txt   | 984 ++++++++++++++++++++
>  tools/stacktool/builtin-check.c                    | 991 +++++++++++++++++++++
>  tools/stacktool/builtin.h                          |  22 +
>  tools/stacktool/elf.c                              | 403 +++++++++
>  tools/stacktool/elf.h                              |  79 ++
>  tools/stacktool/special.c                          | 193 ++++
>  tools/stacktool/special.h                          |  42 +
>  tools/stacktool/stacktool.c                        | 134 +++
>  tools/stacktool/warn.h                             |  60 ++
>  74 files changed, 5516 insertions(+), 189 deletions(-)
>  create mode 100644 include/linux/stacktool.h
>  create mode 100644 tools/stacktool/.gitignore
>  create mode 100644 tools/stacktool/Build
>  create mode 100644 tools/stacktool/Documentation/stack-validation.txt
>  create mode 100644 tools/stacktool/Makefile
>  create mode 100644 tools/stacktool/arch.h
>  create mode 100644 tools/stacktool/arch/x86/Build
>  create mode 100644 tools/stacktool/arch/x86/decode.c
>  create mode 100644 tools/stacktool/arch/x86/insn/gen-insn-attr-x86.awk
>  create mode 100644 tools/stacktool/arch/x86/insn/inat.c
>  create mode 100644 tools/stacktool/arch/x86/insn/inat.h
>  create mode 100644 tools/stacktool/arch/x86/insn/inat_types.h
>  create mode 100644 tools/stacktool/arch/x86/insn/insn.c
>  create mode 100644 tools/stacktool/arch/x86/insn/insn.h
>  create mode 100644 tools/stacktool/arch/x86/insn/x86-opcode-map.txt
>  create mode 100644 tools/stacktool/builtin-check.c
>  create mode 100644 tools/stacktool/builtin.h
>  create mode 100644 tools/stacktool/elf.c
>  create mode 100644 tools/stacktool/elf.h
>  create mode 100644 tools/stacktool/special.c
>  create mode 100644 tools/stacktool/special.h
>  create mode 100644 tools/stacktool/stacktool.c
>  create mode 100644 tools/stacktool/warn.h
> 
> -- 
> 2.4.3
> 
