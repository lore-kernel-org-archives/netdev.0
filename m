From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v11 net-next 00/12] eBPF syscall, verifier, testsuite
Date: Wed, 10 Sep 2014 11:22:33 -0700
Message-ID: <CALCETrVBb_uQZpodv67XSTGVU40y6+9Ktw=3zAJgGV2mNJ=_0A@mail.gmail.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linuxfoundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 9, 2014 at 10:09 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> Hi David,
>
> I've managed to reduce this set to 12:
> Patches 1-4 establish BPF syscall shell for maps and programs.
> Patches 5-10 add verifier step by step
> Patch 11 exposes existing instruction macros to user space
> Patch 12 adds test stubs and verifier testsuite from user space
>
> I don't know how to reduce it further. Drop verifier and
> have programs loaded without verification? Sounds wrong.
> If anyone has other ideas, I'll gladly reduce it further.
>
> Note that patches 1,3,4,7 add commands and attributes to the syscall
> while being backwards compatible from each other, which should demonstrate
> how other commands can be added in the future.
>
> Daniel,
> bpf_common.h patch (that we discussed earlier) I didn't include here
> to reduce the number of patches. It can come next.
>
> For those who have looked at the last set of 28 patches, the difference is:
> - moved attaching to tracing and sockets to future patches
> - moved hash table map type implementation to future
> - split verifier further and moved LD_ABS checks and state prunning to future
> - instead of running verifier testsuite on real tracing programs added
>   test_stub.c with fake maps, context and helper functions to test verifier only
> - rebased
>
> Note, after this set the programs can be loaded for testing only. They cannot
> be attached to any events. This will come in the next set.
>
> As requested by Andy and others, here is the man page:
>
> BPF(2)                     Linux Programmer's Manual                    BPF(2)
>
>
>
> NAME
>        bpf - perform a command on eBPF map or program
>
> SYNOPSIS
>        #include <linux/bpf.h>
>
>        int bpf(int cmd, union bpf_attr *attr, unsigned int size);
>
>
> DESCRIPTION
>        bpf()  syscall  is a multiplexor for a range of different operations on
>        eBPF  which  can  be  characterized  as  "universal  in-kernel  virtual
>        machine". eBPF is similar to original Berkeley Packet Filter (or "clas-
>        sic BPF") used to filter network packets. Both statically  analyze  the
>        programs  before  loading  them into the kernel to ensure that programs
>        cannot harm the running system.
>
>        eBPF extends classic BPF in multiple ways including ability to call in-
>        kernel  helper  functions  and  access shared data structures like eBPF
>        maps.  The programs can be written in a restricted C that  is  compiled
>        into  eBPF  bytecode  and executed on the eBPF virtual machine or JITed
>        into native instruction set.
>
>    eBPF Design/Architecture
>        eBPF maps is a generic storage of different types.   User  process  can
>        create  multiple  maps  (with key/value being opaque bytes of data) and
>        access them via file descriptor. In parallel eBPF programs  can  access
>        maps  from inside the kernel.  It's up to user process and eBPF program
>        to decide what they store inside maps.
>
>        eBPF programs are similar to kernel modules. They  are  loaded  by  the
>        user  process  and automatically unloaded when process exits. Each eBPF
>        program is a safe run-to-completion set of instructions. eBPF  verifier
>        statically  determines  that the program terminates and is safe to exe-
>        cute. During verification the program takes a  hold  of  maps  that  it
>        intends to use, so selected maps cannot be removed until the program is
>        unloaded. The program can be attached to different events. These events
>        can  be packets, tracepoint events and other types in the future. A new
>        event triggers execution of the program  which  may  store  information
>        about the event in the maps.  Beyond storing data the programs may call
>        into in-kernel helper functions which may, for example, dump stack,  do
>        trace_printk  or other forms of live kernel debugging. The same program
>        can be attached to multiple events. Different programs can  access  the
>        same map:
>          tracepoint  tracepoint  tracepoint    sk_buff    sk_buff
>           event A     event B     event C      on eth0    on eth1
>            |             |          |            |          |
>            |             |          |            |          |
>            --> tracing <--      tracing       socket      socket
>                 prog_1           prog_2       prog_3      prog_4
>                 |  |               |            |
>              |---  -----|  |-------|           map_3
>            map_1       map_2
>
>    Syscall Arguments
>        bpf()  syscall  operation  is determined by cmd which can be one of the
>        following:
>
>        BPF_MAP_CREATE
>               Create a map with given type and attributes and return map FD
>
>        BPF_MAP_LOOKUP_ELEM
>               Lookup element by key in a given map and return its value
>
>        BPF_MAP_UPDATE_ELEM
>               Create or update element (key/value pair) in a given map
>
>        BPF_MAP_DELETE_ELEM
>               Lookup and delete element by key in a given map
>
>        BPF_MAP_GET_NEXT_KEY
>               Lookup element by key in a given map and return key of next ele-
>               ment
>
>        BPF_PROG_LOAD
>               Verify and load eBPF program
>
>        attr   is a pointer to a union of type bpf_attr as defined below.
>
>        size   is the size of the union.

I find this strange.  Why not just make attr be a pointer to the
relevant struct for the operation being invoked?


>
>        union bpf_attr {
>            struct { /* anonymous struct used by BPF_MAP_CREATE command */
>                enum bpf_map_type map_type;

Does this reliably generate the same type on compat systems?  C++11
has a fix for enum ABI compatibility, but this is plain C :(


>            struct { /* anonymous struct used by BPF_PROG_LOAD command */
>                enum bpf_prog_type    prog_type;
>                __u32                 insn_cnt;
>                const struct bpf_insn *insns;
>                const char            *license;
>                __u32                 log_level; /* verbosity level of eBPF verifier */
>                __u32                 log_size;  /* size of user buffer */
>                void                  *log_buf;  /* user supplied buffer */
>            };
>        };

It might be a bit nicer to have separate in and out arguments.


>
>        BPF_MAP_CREATE
>               int bpf_create_map(enum bpf_map_type map_type, int key_size,
>                                  int value_size, int max_entries)
>               {
>                   union bpf_attr attr = {
>                       .map_type = map_type,
>                       .key_size = key_size,
>                       .value_size = value_size,
>                       .max_entries = max_entries
>                   };

I feel like this is asking for trouble, or at least bizarre namespace
collisions in the anonymous struct members.  At least please give the
structs names.  (Also, the first time I read this, I assumed that
those were union members, which would have made the code be nonsense.)

>
>        BPF_MAP_DELETE_ELEM
>               int bpf_delete_elem(int fd, void *key)
>               {
>                   union bpf_attr attr = {
>                       .map_fd = fd,
>                       .key = key,
>                   };
>
>                   return bpf(BPF_MAP_DELETE_ELEM, &attr, sizeof(attr));
>               }
>               The call deletes an element in a map fd with given key.

What does it return?  (The same question goes for a bunch of the map ops.)

>
>    eBPF programs
>        BPF_PROG_LOAD
>               This cmd is used to load eBPF program into the kernel.
>
>               char bpf_log_buf[LOG_BUF_SIZE];

What happens if the size isn't LOG_BUF_SIZE?

>
>               int bpf_prog_load(enum bpf_prog_type prog_type,
>                                 const struct bpf_insn *insns, int insn_cnt,
>                                 const char *license)
>               {
>                   union bpf_attr attr = {
>                       .prog_type = prog_type,
>                       .insns = insns,
>                       .insn_cnt = insn_cnt,
>                       .license = license,
>                       .log_buf = bpf_log_buf,
>                       .log_size = LOG_BUF_SIZE,
>                       .log_level = 1,
>                   };
>
>                   return bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
>               }
>               prog_type one of the available program types:
>               enum bpf_prog_type {
>                       BPF_PROG_TYPE_UNSPEC,
>                       BPF_PROG_TYPE_SOCKET_FILTER,
>                       BPF_PROG_TYPE_TRACING_FILTER,
>               };

Why does the type matter?



>        {
>            static struct bpf_insn prog[] = {
>                BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
>                BPF_LD_ABS(BPF_B, 14 + 9 /* R0 = ip->proto */),
>                BPF_STX_MEM(BPF_W, BPF_REG_10, BPF_REG_0, -4), /* *(u32 *)(fp - 4) = r0 */
>                BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
>                BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4), /* r2 = fp - 4 */
>                BPF_LD_MAP_FD(BPF_REG_1, 0),
>                BPF_CALL_FUNC(BPF_FUNC_map_lookup_elem),
>                BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
>                BPF_MOV64_IMM(BPF_REG_1, 1), /* r1 = 1 */
>                BPF_XADD(BPF_DW, BPF_REG_0, BPF_REG_1, 0, 0), /* xadd r0 += r1 */
>                BPF_MOV64_IMM(BPF_REG_0, 0), /* r0 = 0 */
>                BPF_EXIT_INSN(),
>            };
>            int sock, map_fd, prog_fd, key;
>            long long value = 0, tcp_cnt, udp_cnt;
>
>            map_fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value), 2);
>            if (map_fd < 0) {
>                printf("failed to create map '%s'\n", strerror(errno));
>                /* likely not run as root */
>                return 1;
>            }
>
>            key = 6; /* tcp */
>            assert(bpf_update_elem(map_fd, &key, &value) == 0);
>
>            key = 17; /* udp */
>            assert(bpf_update_elem(map_fd, &key, &value) == 0);
>
>            prog[5].imm = map_fd;

This (the .imm thing) is sufficiently weird that I think it needs to
be mentioned in the main docs, not just in an example.  It's
especially odd since AFAIK essentially every other object format in
the world uses a separate relocation table instead of inline magic
opcodes like this.

>
>        All other commands
>               Zero.

Shouldn't delete return different values depending on whether anything
was deleted?

>
>        ENOENT For  BPF_MAP_LOOKUP_ELEM  or BPF_MAP_DELETE_ELEM, indicates that
>               element with given key was not found.

Ah, here it is.  Please document this with the ops.

>
>        E2BIG  program is too large.
>
> NOTES
>        These commands may be used only by a privileged process (one having the
>        CAP_SYS_ADMIN capability).

I hope this goes away :)

I can't shake the feeling that the whole syscall map API is wrong and
that, instead, there should be a more general concept of objects
provided by the eBPF runtime.  Those objects could have methods that
are callable by the syscall and callable from eBPF code.

--Andy
