From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/33] Compile-time stack metadata validation
Date: Tue, 23 Feb 2016 09:14:06 +0100
Message-ID: <20160223081406.GA606@gmail.com>
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
	Chris J Arges <chris.j.arges@canonical.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jiri Slaby <jslaby@suse.cz>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Borislav Petkov <bp@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Jeremy Fitzhardinge <jeremy@goop.or
To: Josh Poimboeuf <jpoimboe@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1453405861.git.jpoimboe@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


So I tried out this latest stacktool series and it looks mostly good for an 
upstream merge.

To help this effort move forward I've applied the preparatory/fix patches that are 
part of this series to tip:x86/debug - that's 26 out of 31 patches. (I've 
propagated all the acks that the latest submission got into the changelogs.)

I have 5 (easy to address) observations that need to be addressed before we can 
move on with the rest of the merge:

1)

Due to recent changes to x86 exception handling, I get a lot of bogus warnings 
about exception table sizes:

  stacktool: arch/x86/kernel/cpu/mcheck/mce.o: __ex_table size not a multiple of 24
  stacktool: arch/x86/kernel/cpu/mtrr/generic.o: __ex_table size not a multiple of 24
  stacktool: arch/x86/kernel/cpu/mtrr/cleanup.o: __ex_table size not a multiple of 24

this is due to:

  548acf19234d x86/mm: Expand the exception table logic to allow new handling options

2)

The fact that 'stacktool' already checks about assembly details like __ex_table[] 
shows that my review feedback early iterations of this series, that the 
'stacktool' name is too specific, was correct.

We really need to rename it before it gets upstream and the situation gets worse. 
__ex_table[] has obviously nothing to do with the 'stack layout' of binaries.

Another suitable name would be 'asmtool' or 'objtool'. For example the following 
would naturally express what it does:

  objtool check kernel/built-in.o

the name expresses that the tool checks object files, independently of the 
existing toolchain. Its primary purpose right now is the checking of stack layout 
details, but the tool is not limited to that at all.

3)

There's quite a bit of overhead when running the tool on larger object files, most 
prominently in cmd_check():

    62.06%  stacktool        stacktool                              [.] cmd_check
     6.72%  stacktool        stacktool                              [.] find_rela_by_dest_range

I added -g to the CFLAGS, which made it visible to annotated output of perf top:

    0.00 :        40430d:       lea    0x4(%rdx,%rax,1),%r13
         :      find_instruction():
         :                                                  struct section *sec,
         :                                                  unsigned long offset)
         :      {
         :              struct instruction *insn;
         :
         :              list_for_each_entry(insn, &file->insns, list)
    0.03 :        404312:       mov    0x38(%rsp),%rax
    0.00 :        404317:       cmp    %rbp,%rax
    0.00 :        40431a:       jne    404334 <cmd_check+0x5b4>
    0.00 :        40431c:       jmpq   4045ba <cmd_check+0x83a>
    0.00 :        404321:       nopl   0x0(%rax)
    6.14 :        404328:       mov    (%rax),%rax
    0.00 :        40432b:       cmp    %rbp,%rax
    2.02 :        40432e:       je     4045ba <cmd_check+0x83a>
         :                      if (insn->sec == sec && insn->offset == offset)
    0.55 :        404334:       cmp    %r12,0x10(%rax)
   87.91 :        404338:       jne    404328 <cmd_check+0x5a8>
    0.00 :        40433a:       cmp    %r13,0x18(%rax)
    3.36 :        40433e:       jne    404328 <cmd_check+0x5a8>
         :      get_jump_destinations():
         :                               * later in validate_functions().
         :                               */
         :                              continue;
         :                      }
         :
         :                      insn->jump_dest = find_instruction(file, dest_sec, dest_off);
    0.00 :        404340:       mov    %rax,0x48(%rbx)
    0.00 :        404344:       jmpq   4042b0 <cmd_check+0x530>
    0.00 :        404349:       nopl   0x0(%rax)
         :      fprintf():
         :
         :      # ifdef __va_arg_pack
         :      __fortify_function int
         :      fprintf (FILE *__restrict __stream, const char *__restrict __fmt, ...)
         :      {
         :        return __fprintf_chk (__stream, __USE_FORTIFY_LEVEL - 1, __fmt,

that looks like a linear list search? That would suck with thousands of entries.

(If this is non-trivial to improve then we can delay this optimization to a later 
patch.)

4)

I think the various 'STACKTOOL' flags in the kernel source are a bit of a misnomer 
- it's not the tool we want to name but the actual property of the code.

So instead of:

  STACKTOOL_IGNORE_FUNC(__bpf_prog_run);

we should do something like:

  STACK_FRAME_NON_STANDARD(__bpf_prog_run);

see how much more expressive it is? It becomes a function attribute independent of 
the tooling that makes use of it.

Similarly, for the highest level 'don't check these directories' makefile flags, 
I'd suggest, instead of using this rather opaque, tool dependent naming:

  STACKTOOL := n

something more specific, like:

  OBJECT_FILES_NON_STANDARD := y

which makes it clearer what's going on: these are special object files that are 
not the typical kernel object files.

Stacktool (or objtool) would be one consumer of this annotation.

I think Boris made similar observations in past reviews.

5)

Likewise, I think the CONFIG_STACK_VALIDATION=y Kconfig flag does not express that 
we do exception table checks as well - and it does not express all the other 
things we may check in object files in the future.

Something like CONFIG_CHECK_OBJECT_FILES=y would express it, and the help text 
would list all the things the tool is able to checks for at the moment.

-------------------

Please send followup iterations of the series against the tip:x86/debug tree (or 
tip:master), to keep the size of the series down.

Thanks,

	Ingo
