From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH RFC v4 net-next 00/26] BPF syscall, maps, verifier, samples, llvm
Date: Wed, 13 Aug 2014 00:57:11 -0700
Message-ID: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi All,

one more RFC...

Major difference vs previous set is a new 'load 64-bit immediate' eBPF insn.
Which is first 16-byte instruction. It shows how eBPF ISA can be extended
while maintaining backward compatibility, but mainly it cleans up eBPF
program access to maps and improves run-time performance.
In V3 I've been using 'fixup' section in eBPF program to tell kernel
which instructions are accessing maps. With new instruction 'fixup' is gone
and map IDR (internal map_ids) are removed.
To understand the logic behind new insn, I need to explain two main
eBPF design constraints:
1. eBPF interpreter must be generic. It should know nothing about maps or
   any custom instructions or functions.
2. llvm compiler backend must be generic. It also should know nothing about
   maps, helper functions, sockets, tracing, etc. LLVM just takes normal C
   and compiles it for some 'fake' HW that happened to be called eBPF ISA.

patch #1 implements BPF_LD_IMM64 insn. It's just a move of 64-bit immediate
value into a register. Nothing fancy.

The reason it improved eBPF program run-time is the following:
in V3 the program used to look like:
  bpf_mov r1, const_internal_map_id
  bpf_call bpf_map_lookup
so in-kernel bpf_map_lookup() helper would do map_id->map_ptr conversion via
  map = idr_find(&bpf_map_id_idr, map_id);
For the life of the program map_id is constant and that lookup was returning
the same value, but there was no easy way to store pointer inside eBPF insn.

With new insn the programs look like:
  bpf_ld_imm64 r1, const_internal_map_ptr
  bpf_call bpf_map_lookup
and the bpf_map_lookup() helper does:
  struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
Though it's a small performance gain, every nsec counts.
Also new insn allows further optimizations in JIT compilers.

How does it help to cleanup program interface towards maps?
Obviously user space doesn't know what kernel map pointer is associated
with process-local map-FD.
So it's using pseudo BPF_LD_IMM64 instruction.
BPF_LD_IMM64 with src_reg == 0 -> generic move 64-bit immediate into dst_reg
BPF_LD_IMM64 with src_reg == BPF_PSEUDO_MAP_FD -> mov map_fd into dst_reg
Other values are reserved for now. (They will be used to implement
global variables, strings and other constants and per-cpu areas in the future)
So the programs look like:
  BPF_LD_MAP_FD(BPF_REG_1, process_local_map_fd),
  BPF_CALL(BPF_FUNC_map_lookup_elem),
eBPF verifier scans the program for such pseudo instructions, converts
process_local_map_fd -> in-kernel map pointer
and drops 'pseudo' flag of BPF_LD_IMM64 instruction.
eBPF interpreter stays generic and LLVM stays generic, since they know
nothing about pseudo instructions.
Another pseudo instruction is BPF_CALL. User space encodes one of
BPF_FUNC_xxx function ids as part of 'imm' field of the instruction
and eBPF program loader converts it to in-kernel helper function pointer.

The idea to use special instructions to access maps was suggested by Jonathan ;)
It took awhile to figure out how to do it within above two design constraints,
but the end result I think is much cleaner than what I had in V2/V3.

Another difference vs previous set is verifier split into 6 patches and
verifier testsuite is added. Beyond old checks verifier got 'tidiness' checks
to make sure all unused fields of instructions are zero.
Unfortunately classic BPF doesn't check for this. Lesson learned.

Tracing use case got some improvements as well. Now eBPF programs can be
attached to tracepoint, syscall, kprobe and C examples are more usable:
ex1_kern.c - demonstrate how programs can walk in-kernel data structures
ex2_kern.c - in-kernel event accounting and user space histograms
See patch #25

TODO:
- verifier is safe, but not secure, since it allows kernel address leaking.
  fix that before lifting root-only restriction
- allow seecomp to use eBPF
- write manpage for eBPF syscall

As always all patches are available at:

  git://git.kernel.org/pub/scm/linux/kernel/git/ast/bpf master

V3->V4:
- introduced 'load 64-bit immediate' eBPF instruction
- use BPF_LD_IMM64 in LLVM, verifier, programs
- got rid of 'fixup' section in eBPF programs
- got rid of map IDR and internal map_id
- split verifier into 6 patches and added verifier testsuite
- add verifier check for reserved instruction fields
- fixed bug in LLVM eBPF backend (it was miscompiling __builtin_expect)
- fixed race condition in htab_map_update_elem()
- tracing filters can now attach to tracepoint, syscall, kprobe events
- improved C examples 

V2->V3:
- fixed verifier register range bug and addressed other comments (Thanks Kees!)
- re-added LLVM eBPF backend
- added two examples in C
- user space ELF parser and loader example

V1->V2:
- got rid of global id, everything now FD based (Thanks Andy!)
- split type enum in verifier (as suggested by Andy and Namhyung)
- switched gpl enforcement to be kmod like (as suggested by Andy and David)
- addressed feedback from Namhyung, Chema, Joe
- added more comments to verifier
- renamed sock_filter_int -> bpf_insn
- rebased on net-next

FD approach made eBPF user interface much cleaner for sockets/seccomp/tracing
use cases. Now socket and tracing examples (patch 15 and 16) can be Ctrl-C in
the middle and kernel will auto cleanup everything including tracing filters.

----

Old V1 cover letter:

'maps' is a generic storage of different types for sharing data between kernel
and userspace. Maps are referrenced by file descriptor. Root process can create
multiple maps of different types where key/value are opaque bytes of data.
It's up to user space and eBPF program to decide what they store in the maps.

eBPF programs are similar to kernel modules. They are loaded by the user space
program and unload on closing of fd. Each program is a safe run-to-completion
set of instructions. eBPF verifier statically determines that the program
terminates and safe to execute. During verification the program takes a hold of
maps that it intends to use, so selected maps cannot be removed until program is
unloaded. The program can be attached to different events. These events can
be packets, tracepoint events and other types in the future. New event triggers
execution of the program which may store information about the event in the maps.
Beyond storing data the programs may call into in-kernel helper functions
which may, for example, dump stack, do trace_printk or other forms of live
kernel debugging. Same program can be attached to multiple events. Different
programs can access the same map:

  tracepoint  tracepoint  tracepoint    sk_buff    sk_buff
   event A     event B     event C      on eth0    on eth1
    |             |          |            |          |
    |             |          |            |          |
    --> tracing <--      tracing       socket      socket
         prog_1           prog_2       prog_3      prog_4
         |  |               |            |
      |---  -----|  |-------|           map_3
    map_1       map_2

User space (via syscall) and eBPF programs access maps concurrently.

------

Alexei Starovoitov (26):
  net: filter: add "load 64-bit immediate" eBPF instruction
  net: filter: split filter.h and expose eBPF to user space
  bpf: introduce syscall(BPF, ...) and BPF maps
  bpf: enable bpf syscall on x64
  bpf: add lookup/update/delete/iterate methods to BPF maps
  bpf: add hashtable type of BPF maps
  bpf: expand BPF syscall with program load/unload
  bpf: handle pseudo BPF_CALL insn
  bpf: verifier (add docs)
  bpf: verifier (add ability to receive verification log)
  bpf: handle pseudo BPF_LD_IMM64 insn
  bpf: verifier (add branch/goto checks)
  bpf: verifier (add verifier core)
  bpf: verifier (add state prunning optimization)
  bpf: allow eBPF programs to use maps
  net: sock: allow eBPF programs to be attached to sockets
  tracing: allow eBPF programs to be attached to events
  tracing: allow eBPF programs to be attached to kprobe/kretprobe
  samples: bpf: add mini eBPF library to manipulate maps and programs
  samples: bpf: example of stateful socket filtering
  samples: bpf: example of tracing filters with eBPF
  bpf: llvm backend
  samples: bpf: elf file loader
  samples: bpf: eBPF example in C
  samples: bpf: counting eBPF example in C
  bpf: verifier test

-- 
1.7.9.5
