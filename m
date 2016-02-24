From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: [PATCH v17 0/9] Compile-time stack metadata validation
Date: Wed, 24 Feb 2016 10:36:02 -0600
Message-ID: <cover.1456331595.git.jpoimboe@redhat.com>
Cc: linux-kernel@vger.kernel.org, live-patching@vger.kernel.org,
	Michal Marek <mmarek@suse.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@kernel.org>,
	Borislav Petkov <bp@alien8.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	Pedro Alves <palves@redhat.com>,
	Namhyung Kim <namhyung@gmail.com>,
	Bernd Petrovitsch <bernd@petrovitsch.priv.at>,
	Chris J Arges <chris.j.arges@canonical.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jiri Slaby <jslaby@suse.cz>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	Anil S Keshavamurthy <anil.s.keshavam
To: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is v17 of the compile-time stack metadata validation patch set.

It's based on tip:x86/debug.  However, note that when run against that
branch it will give a lot of warnings:

  objtool: arch/x86/ia32/sys_ia32.o: __ex_table size not a multiple of 12
  objtool: arch/x86/ia32/ia32_signal.o: __ex_table size not a multiple of 12
  objtool: arch/x86/entry/common.o: __ex_table size not a multiple of 12
  ...

These warnings means that objtool is expecting the new exception table
format which was introduced with:

  548acf19234d ("x86/mm: Expand the exception table logic to allow new handling options")

So that commit is needed for those warnings to go away.


v16 can be found here:

  https://lkml.kernel.org/r/cover.1453405861.git.jpoimboe@redhat.com

For more information about the motivation behind this patch set, and
more details about what it does, see the first patch changelog and
tools/objtool/Documentation/stack-validation.txt.

Patches 1-4 add objtool and integrate it into the kernel build.

Patches 5-9 add some directories, files, and functions to the
objtool whitelist in order to silence false positive warnings.

v17:
- __ex_table fix
- rename stacktool -> objtool
- STACKTOOL_IGNORE_FUNCTION -> STACK_FRAME_NON_STANDARD
- 'STACKTOOL := n' -> 'OBJECT_FILES_NON_STANDARD := y'
- updated global_noreturns list

v16:
- fix all allyesconfig warnings, except for staging
- get rid of STACKTOOL_IGNORE_INSN which is no longer needed
- remove several whitelists in favor of automatically whitelisting any
  function with a special instruction like ljmp, lret, or vmrun
- split up stacktool patch into 3 parts as suggested by Ingo
- update the global noreturn function list
- detect noreturn function fallthroughs
- skip weak functions in noreturn call detection logic
- add empty function check to noreturn logic
- allow non-section rela symbols for __ex_table sections
- support rare switch table case with jmpq *[addr](%rip)
- don't warn on frame pointer restore without save
- rearrange patch order a bit

v15:
- restructure code for a new cmdline interface "stacktool check" using
  the new subcommand framework in tools/lib/subcmd
- fix 32 bit build fail (put __sp at end) in paravirt_types.h patch 10
  which was reported by 0day

v14:
- make tools/include/linux/list.h self-sufficient
- create FRAME_OFFSET to allow 32-bit code to be able to access function
  arguments on the stack
- add FRAME_OFFSET usage in crypto patch 14/24: "Create stack frames in
  aesni-intel_asm.S"
- rename "index" -> "idx" to fix build with some compilers

v13:
- LDFLAGS order fix from Chris J Arges
- new warning fix patches from Chris J Arges
- "--frame-pointer" -> "--check-frame-pointer"

v12:
- rename "stackvalidate" -> "stacktool"
- move from scripts/ to tools/:
  - makefile rework
  - make a copy of the x86 insn code (and warn if the code diverges)
  - use tools/include/linux/list.h
- move warning macros to a new warn.h file
- change wording: "stack validation" -> "stack metadata validation"

v11:
- attempt to answer the "why" question better in the documentation and
  commit message
- s/FP_SAVE/FRAME_BEGIN/ in documentation

v10:
- add scripts/mod to directory ignores
- remove circular dependencies for ignored objects which are built
  before stackvalidate
- fix CONFIG_MODVERSIONS incompatibility

v9:
- rename FRAME/ENDFRAME -> FRAME_BEGIN/FRAME_END
- fix jump table issue for when the original instruction is a jump
- drop paravirt thunk alignment patch
- add maintainers to CC for proposed warning fixes

v8:
- add proposed fixes for warnings
- fix all memory leaks
- process ignores earlier and add more ignore checks
- always assume POPCNT alternative is enabled
- drop hweight inline asm fix
- drop __schedule() ignore patch
- change .Ltemp_\@ to .Lstackvalidate_ignore_\@ in asm macro
- fix CONFIG_* checks in asm macros
- add C versions of ignore macros and frame macros
- change ";" to "\n" in C macros
- add ifdef CONFIG_STACK_VALIDATION checks in C ignore macros
- use numbered label in C ignore macro
- add missing break in switch case statement in arch-x86.c

v7:
- sibling call support
- document proposed solution for inline asm() frame pointer issues
- say "kernel entry/exit" instead of "context switch"
- clarify the checking of switch statement jump tables
- discard __stackvalidate_ignore_* sections in linker script
- use .Ltemp_\@ to get a unique label instead of static 3-digit number
- change STACKVALIDATE_IGNORE_FUNC variable to a static
- move STACKVALIDATE_IGNORE_INSN to arch-specific .h file

v6:
- rename asmvalidate -> stackvalidate (again)
- gcc-generated object file support
- recursive branch state analysis
- external jump support
- fixup/exception table support
- jump label support
- switch statement jump table support
- added documentation
- detection of "noreturn" dead end functions
- added a Kbuild mechanism for skipping files and dirs
- moved frame pointer macros to arch/x86/include/asm/frame.h
- moved ignore macros to include/linux/stackvalidate.h

v5:
- stackvalidate -> asmvalidate
- frame pointers only required for non-leaf functions
- check for the use of the FP_SAVE/RESTORE macros instead of manually
  analyzing code to detect frame pointer usage
- additional checks to ensure each function doesn't leave its boundaries
- make the macros simpler and more flexible
- support for analyzing ALTERNATIVE macros
- simplified the arch interfaces in scripts/asmvalidate/arch.h
- fixed some asmvalidate warnings
- rebased onto latest tip asm cleanups
- many more small changes

v4:
- Changed the default to CONFIG_STACK_VALIDATION=n, until all the asm
  code can get cleaned up.
- Fixed a stackvalidate error path exit code issue found by Michal
  Marek.

v3:
- Added a patch to make the push/pop CFI macros arch-independent, as
  suggested by H. Peter Anvin

v2:
- Fixed memory leaks reported by Petr Mladek

Cc: linux-kernel@vger.kernel.org
Cc: live-patching@vger.kernel.org
Cc: Michal Marek <mmarek@suse.cz>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Pedro Alves <palves@redhat.com>
Cc: Namhyung Kim <namhyung@gmail.com>
Cc: Bernd Petrovitsch <bernd@petrovitsch.priv.at>
Cc: Chris J Arges <chris.j.arges@canonical.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>

Josh Poimboeuf (9):
  x86/objtool: Compile-time stack metadata validation
  x86/objtool: Add CONFIG_STACK_VALIDATION option
  x86/objtool: Enable objtool on x86_64
  x86/objtool: Add STACK_FRAME_NON_STANDARD macro
  x86/objtool: Add directory and file whitelists
  x86/xen: Add xen_cpuid() to objtool whitelist
  bpf: Add __bpf_prog_run() to objtool whitelist
  sched: Add __schedule() to objtool whitelist
  x86/kprobes: Add kretprobe_trampoline() to objtool whitelist

 MAINTAINERS                                       |   6 +
 Makefile                                          |   5 +-
 arch/Kconfig                                      |   6 +
 arch/x86/Kconfig                                  |   1 +
 arch/x86/boot/Makefile                            |   3 +-
 arch/x86/boot/compressed/Makefile                 |   3 +-
 arch/x86/entry/Makefile                           |   4 +
 arch/x86/entry/vdso/Makefile                      |   6 +-
 arch/x86/kernel/Makefile                          |  11 +-
 arch/x86/kernel/kprobes/core.c                    |   2 +
 arch/x86/kernel/vmlinux.lds.S                     |   5 +-
 arch/x86/platform/efi/Makefile                    |   2 +
 arch/x86/purgatory/Makefile                       |   2 +
 arch/x86/realmode/Makefile                        |   4 +-
 arch/x86/realmode/rm/Makefile                     |   3 +-
 arch/x86/xen/enlighten.c                          |   3 +-
 drivers/firmware/efi/libstub/Makefile             |   1 +
 include/linux/objtool.h                           |  22 +
 kernel/bpf/core.c                                 |   2 +
 kernel/sched/core.c                               |   2 +
 lib/Kconfig.debug                                 |  12 +
 scripts/Makefile.build                            |  39 +-
 scripts/mod/Makefile                              |   2 +
 tools/Makefile                                    |  14 +-
 tools/objtool/.gitignore                          |   2 +
 tools/objtool/Build                               |  13 +
 tools/objtool/Documentation/stack-validation.txt  | 340 ++++++++
 tools/objtool/Makefile                            |  60 ++
 tools/objtool/arch.h                              |  44 +
 tools/objtool/arch/x86/Build                      |  12 +
 tools/objtool/arch/x86/decode.c                   | 172 ++++
 tools/objtool/arch/x86/insn/gen-insn-attr-x86.awk | 387 +++++++++
 tools/objtool/arch/x86/insn/inat.c                |  97 +++
 tools/objtool/arch/x86/insn/inat.h                | 221 +++++
 tools/objtool/arch/x86/insn/inat_types.h          |  29 +
 tools/objtool/arch/x86/insn/insn.c                | 594 +++++++++++++
 tools/objtool/arch/x86/insn/insn.h                | 201 +++++
 tools/objtool/arch/x86/insn/x86-opcode-map.txt    | 984 +++++++++++++++++++++
 tools/objtool/builtin-check.c                     | 993 ++++++++++++++++++++++
 tools/objtool/builtin.h                           |  22 +
 tools/objtool/elf.c                               | 403 +++++++++
 tools/objtool/elf.h                               |  79 ++
 tools/objtool/objtool.c                           | 134 +++
 tools/objtool/special.c                           | 193 +++++
 tools/objtool/special.h                           |  42 +
 tools/objtool/warn.h                              |  60 ++
 46 files changed, 5220 insertions(+), 22 deletions(-)
 create mode 100644 include/linux/objtool.h
 create mode 100644 tools/objtool/.gitignore
 create mode 100644 tools/objtool/Build
 create mode 100644 tools/objtool/Documentation/stack-validation.txt
 create mode 100644 tools/objtool/Makefile
 create mode 100644 tools/objtool/arch.h
 create mode 100644 tools/objtool/arch/x86/Build
 create mode 100644 tools/objtool/arch/x86/decode.c
 create mode 100644 tools/objtool/arch/x86/insn/gen-insn-attr-x86.awk
 create mode 100644 tools/objtool/arch/x86/insn/inat.c
 create mode 100644 tools/objtool/arch/x86/insn/inat.h
 create mode 100644 tools/objtool/arch/x86/insn/inat_types.h
 create mode 100644 tools/objtool/arch/x86/insn/insn.c
 create mode 100644 tools/objtool/arch/x86/insn/insn.h
 create mode 100644 tools/objtool/arch/x86/insn/x86-opcode-map.txt
 create mode 100644 tools/objtool/builtin-check.c
 create mode 100644 tools/objtool/builtin.h
 create mode 100644 tools/objtool/elf.c
 create mode 100644 tools/objtool/elf.h
 create mode 100644 tools/objtool/objtool.c
 create mode 100644 tools/objtool/special.c
 create mode 100644 tools/objtool/special.h
 create mode 100644 tools/objtool/warn.h

-- 
2.4.3
