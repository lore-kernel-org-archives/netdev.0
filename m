From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v11 net-next 00/12] eBPF syscall, verifier, testsuite
Date: Tue,  9 Sep 2014 22:09:56 -0700
Message-ID: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

I've managed to reduce this set to 12:
Patches 1-4 establish BPF syscall shell for maps and programs.
Patches 5-10 add verifier step by step
Patch 11 exposes existing instruction macros to user space
Patch 12 adds test stubs and verifier testsuite from user space

I don't know how to reduce it further. Drop verifier and
have programs loaded without verification? Sounds wrong.
If anyone has other ideas, I'll gladly reduce it further.

Note that patches 1,3,4,7 add commands and attributes to the syscall
while being backwards compatible from each other, which should demonstrate
how other commands can be added in the future.

Daniel,
bpf_common.h patch (that we discussed earlier) I didn't include here
to reduce the number of patches. It can come next.

For those who have looked at the last set of 28 patches, the difference is:
- moved attaching to tracing and sockets to future patches
- moved hash table map type implementation to future
- split verifier further and moved LD_ABS checks and state prunning to future
- instead of running verifier testsuite on real tracing programs added
  test_stub.c with fake maps, context and helper functions to test verifier only
- rebased

Note, after this set the programs can be loaded for testing only. They cannot
be attached to any events. This will come in the next set.

As requested by Andy and others, here is the man page:

BPF(2)                     Linux Programmer's Manual                    BPF(2)



NAME
       bpf - perform a command on eBPF map or program

SYNOPSIS
       #include <linux/bpf.h>

       int bpf(int cmd, union bpf_attr *attr, unsigned int size);


DESCRIPTION
       bpf()  syscall  is a multiplexor for a range of different operations on
       eBPF  which  can  be  characterized  as  "universal  in-kernel  virtual
       machine". eBPF is similar to original Berkeley Packet Filter (or "clas-
       sic BPF") used to filter network packets. Both statically  analyze  the
       programs  before  loading  them into the kernel to ensure that programs
       cannot harm the running system.

       eBPF extends classic BPF in multiple ways including ability to call in-
       kernel  helper  functions  and  access shared data structures like eBPF
       maps.  The programs can be written in a restricted C that  is  compiled
       into  eBPF  bytecode  and executed on the eBPF virtual machine or JITed
       into native instruction set.

   eBPF Design/Architecture
       eBPF maps is a generic storage of different types.   User  process  can
       create  multiple  maps  (with key/value being opaque bytes of data) and
       access them via file descriptor. In parallel eBPF programs  can  access
       maps  from inside the kernel.  It's up to user process and eBPF program
       to decide what they store inside maps.

       eBPF programs are similar to kernel modules. They  are  loaded  by  the
       user  process  and automatically unloaded when process exits. Each eBPF
       program is a safe run-to-completion set of instructions. eBPF  verifier
       statically  determines  that the program terminates and is safe to exe-
       cute. During verification the program takes a  hold  of  maps  that  it
       intends to use, so selected maps cannot be removed until the program is
       unloaded. The program can be attached to different events. These events
       can  be packets, tracepoint events and other types in the future. A new
       event triggers execution of the program  which  may  store  information
       about the event in the maps.  Beyond storing data the programs may call
       into in-kernel helper functions which may, for example, dump stack,  do
       trace_printk  or other forms of live kernel debugging. The same program
       can be attached to multiple events. Different programs can  access  the
       same map:
         tracepoint  tracepoint  tracepoint    sk_buff    sk_buff
          event A     event B     event C      on eth0    on eth1
           |             |          |            |          |
           |             |          |            |          |
           --> tracing <--      tracing       socket      socket
                prog_1           prog_2       prog_3      prog_4
                |  |               |            |
             |---  -----|  |-------|           map_3
           map_1       map_2

   Syscall Arguments
       bpf()  syscall  operation  is determined by cmd which can be one of the
       following:

       BPF_MAP_CREATE
              Create a map with given type and attributes and return map FD

       BPF_MAP_LOOKUP_ELEM
              Lookup element by key in a given map and return its value

       BPF_MAP_UPDATE_ELEM
              Create or update element (key/value pair) in a given map

       BPF_MAP_DELETE_ELEM
              Lookup and delete element by key in a given map

       BPF_MAP_GET_NEXT_KEY
              Lookup element by key in a given map and return key of next ele-
              ment

       BPF_PROG_LOAD
              Verify and load eBPF program

       attr   is a pointer to a union of type bpf_attr as defined below.

       size   is the size of the union.

       union bpf_attr {
           struct { /* anonymous struct used by BPF_MAP_CREATE command */
               enum bpf_map_type map_type;
               __u32             key_size;    /* size of key in bytes */
               __u32             value_size;  /* size of value in bytes */
               __u32             max_entries; /* max number of entries in a map */
           };

           struct { /* anonymous struct used by BPF_MAP_*_ELEM commands */
               int map_fd;
               void *key;
               union {
                   void *value;
                   void *next_key;
               };
           };

           struct { /* anonymous struct used by BPF_PROG_LOAD command */
               enum bpf_prog_type    prog_type;
               __u32                 insn_cnt;
               const struct bpf_insn *insns;
               const char            *license;
               __u32                 log_level; /* verbosity level of eBPF verifier */
               __u32                 log_size;  /* size of user buffer */
               void                  *log_buf;  /* user supplied buffer */
           };
       };

   eBPF maps
       maps  is  a generic storage of different types for sharing data between
       kernel and userspace.

       Any map type has the following attributes:
         . type
         . max number of elements
         . key size in bytes
         . value size in bytes

       The following wrapper functions demonstrate how  this  syscall  can  be
       used  to  access the maps. The functions use the cmd argument to invoke
       different operations.

       BPF_MAP_CREATE
              int bpf_create_map(enum bpf_map_type map_type, int key_size,
                                 int value_size, int max_entries)
              {
                  union bpf_attr attr = {
                      .map_type = map_type,
                      .key_size = key_size,
                      .value_size = value_size,
                      .max_entries = max_entries
                  };

                  return bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
              }
              bpf()  syscall  creates  a  map  of  map_type  type  and   given
              attributes  key_size,  value_size,  max_entries.   On success it
              returns process-local file descriptor or negative  error  other-
              wise.

       BPF_MAP_LOOKUP_ELEM
              int bpf_lookup_elem(int fd, void *key, void *value)
              {
                  union bpf_attr attr = {
                      .map_fd = fd,
                      .key = key,
                      .value = value,
                  };

                  return bpf(BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
              }
              bpf()  syscall  looks  up an element with given key in a map fd.
              If element is found it returns zero and stores  element's  value
              into value.  Otherwise negative error is returned.

       BPF_MAP_UPDATE_ELEM
              int bpf_update_elem(int fd, void *key, void *value)
              {
                  union bpf_attr attr = {
                      .map_fd = fd,
                      .key = key,
                      .value = value,
                  };

                  return bpf(BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
              }
              The  call  creates  or updates element with given key/value in a
              map fd.  On success it returns zero or negative error otherwise.

       BPF_MAP_DELETE_ELEM
              int bpf_delete_elem(int fd, void *key)
              {
                  union bpf_attr attr = {
                      .map_fd = fd,
                      .key = key,
                  };

                  return bpf(BPF_MAP_DELETE_ELEM, &attr, sizeof(attr));
              }
              The call deletes an element in a map fd with given key.

       BPF_MAP_GET_NEXT_KEY
              int bpf_get_next_key(int fd, void *key, void *next_key)
              {
                  union bpf_attr attr = {
                      .map_fd = fd,
                      .key = key,
                      .next_key = next_key,
                  };

                  return bpf(BPF_MAP_GET_NEXT_KEY, &attr, sizeof(attr));
              }
              The call looks up an element by  key  in  a  given  map  fd  and
              returns key of next element into next_key pointer. On success it
              returns zero or negative error otherwise.  This  method  can  be
              used to iterate over all elements of the map.

       close(map_fd)
              will  delete  the  map  map_fd.  Exiting process will delete all
              maps automatically.

       In the future maps can have different types: hash, array, bloom filter,
       radix-tree, but currently only hash type is supported:
       enum bpf_map_type {
          BPF_MAP_TYPE_UNSPEC,
          BPF_MAP_TYPE_HASH,
       };

   eBPF programs
       BPF_PROG_LOAD
              This cmd is used to load eBPF program into the kernel.

              char bpf_log_buf[LOG_BUF_SIZE];

              int bpf_prog_load(enum bpf_prog_type prog_type,
                                const struct bpf_insn *insns, int insn_cnt,
                                const char *license)
              {
                  union bpf_attr attr = {
                      .prog_type = prog_type,
                      .insns = insns,
                      .insn_cnt = insn_cnt,
                      .license = license,
                      .log_buf = bpf_log_buf,
                      .log_size = LOG_BUF_SIZE,
                      .log_level = 1,
                  };

                  return bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
              }
              prog_type one of the available program types:
              enum bpf_prog_type {
                      BPF_PROG_TYPE_UNSPEC,
                      BPF_PROG_TYPE_SOCKET_FILTER,
                      BPF_PROG_TYPE_TRACING_FILTER,
              };
              insns array of "struct bpf_insn" instructions

              insn_cnt number of instructions in the program

              license  license  string,  which  must be GPL compatible to call
              helper functions marked gpl_only

              log_buf user supplied buffer that in-kernel verifier is using to
              store verification log

              log_size size of user buffer

              log_level  verbosity level of eBPF verifier, where zero means no
              logs provided

       close(prog_fd)
              will unload eBPF program

       The maps  are  accesible  from  programs  and  generally  tie  the  two
       together.   Programs  process  various events (like tracepoint, kprobe,
       packets) and store the data into maps. User  space  fetches  data  from
       maps.   Either the same or a different map may be used by user space as
       configuration space to alter program behavior on the fly.

   Events
       Once an eBPF program is loaded, it can be attached to an event. Various
       kernel subsystems have different ways to do so. For example:

       setsockopt(sock, SOL_SOCKET, SO_ATTACH_BPF, &prog_fd, sizeof(prog_fd));
       will  attach  the  program prog_fd to socket sock which was received by
       prior call to socket().

       ioctl(event_fd, PERF_EVENT_IOC_SET_BPF, prog_fd);
       will attach the program  prog_fd  to  perf  event  event_fd  which  was
       received by prior call to perf_event_open().

       Another way to attach the program to a tracing event is:
       event_fd = open("/sys/kernel/debug/tracing/events/skb/kfree_skb/filter");
       write(event_fd, "bpf-123"); /* where 123 is eBPF program FD */
       /* here program is attached and will be triggered by events */
       close(event_fd); /* to detach from event */

EXAMPLES
       /* eBPF+sockets example:
        * 1. create map with maximum of 2 elements
        * 2. set map[6] = 0 and map[17] = 0
        * 3. load eBPF program that counts number of TCP and UDP packets received
        *    via map[skb->ip->proto]++
        * 4. attach prog_fd to raw socket via setsockopt()
        * 5. print number of received TCP/UDP packets every second
        */
       int main(int ac, char **av)
       {
           static struct bpf_insn prog[] = {
               BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
               BPF_LD_ABS(BPF_B, 14 + 9 /* R0 = ip->proto */),
               BPF_STX_MEM(BPF_W, BPF_REG_10, BPF_REG_0, -4), /* *(u32 *)(fp - 4) = r0 */
               BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
               BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4), /* r2 = fp - 4 */
               BPF_LD_MAP_FD(BPF_REG_1, 0),
               BPF_CALL_FUNC(BPF_FUNC_map_lookup_elem),
               BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
               BPF_MOV64_IMM(BPF_REG_1, 1), /* r1 = 1 */
               BPF_XADD(BPF_DW, BPF_REG_0, BPF_REG_1, 0, 0), /* xadd r0 += r1 */
               BPF_MOV64_IMM(BPF_REG_0, 0), /* r0 = 0 */
               BPF_EXIT_INSN(),
           };
           int sock, map_fd, prog_fd, key;
           long long value = 0, tcp_cnt, udp_cnt;

           map_fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value), 2);
           if (map_fd < 0) {
               printf("failed to create map '%s'\n", strerror(errno));
               /* likely not run as root */
               return 1;
           }

           key = 6; /* tcp */
           assert(bpf_update_elem(map_fd, &key, &value) == 0);

           key = 17; /* udp */
           assert(bpf_update_elem(map_fd, &key, &value) == 0);

           prog[5].imm = map_fd;
           prog_fd = bpf_prog_load(BPF_PROG_TYPE_SOCKET_FILTER, prog, sizeof(prog),
                                   "GPL");
           assert(prog_fd >= 0);

           sock = open_raw_sock("lo");

           assert(setsockopt(sock, SOL_SOCKET, SO_ATTACH_BPF, &prog_fd,
                             sizeof(prog_fd)) == 0);

           for (;;) {
               key = 6;
               assert(bpf_lookup_elem(map_fd, &key, &tcp_cnt) == 0);
               key = 17;
               assert(bpf_lookup_elem(map_fd, &key, &udp_cnt) == 0);
               printf("TCP %lld UDP %lld packets0, tcp_cnt, udp_cnt);
               sleep(1);
           }

           return 0;
       }

RETURN VALUE
       For a successful call, the return value depends on the operation:

       BPF_MAP_CREATE
              The new file descriptor associated with eBPF map.

       BPF_PROG_LOAD
              The new file descriptor associated with eBPF program.

       All other commands
              Zero.

       On error, -1 is returned, and errno is set appropriately.

ERRORS
       EPERM  bpf() syscall was made without sufficient privilege (without the
              CAP_SYS_ADMIN capability).

       ENOMEM Cannot allocate sufficient memory.

       EBADF  fd is not an open file descriptor

       EFAULT One of the pointers ( key or value or log_buf or insns ) is out-
              side accessible address space.

       EINVAL The value specified in cmd is not recognized by this kernel.

       EINVAL For BPF_MAP_CREATE, either map_type or attributes are invalid.

       EINVAL For  BPF_MAP_*_ELEM  commands,  some  of  the  fields  of "union
              bpf_attr" unused by this command are not set to zero.

       EINVAL For BPF_PROG_LOAD, attempt to load invalid program (unrecognized
              instruction  or  uses  reserved  fields or jumps out of range or
              loop detected or calls unknown function).

       EACCES For BPF_PROG_LOAD, though program has valid instructions, it was
              rejected, since it was deemed unsafe (may access disallowed mem-
              ory region or  uninitialized  stack/register  or  function  con-
              straints don't match actual types or misaligned access). In such
              case it is recommended to call bpf() again with  log_level  =  1
              and examine log_buf for specific reason provided by verifier.

       ENOENT For  BPF_MAP_LOOKUP_ELEM  or BPF_MAP_DELETE_ELEM, indicates that
              element with given key was not found.

       E2BIG  program is too large.

NOTES
       These commands may be used only by a privileged process (one having the
       CAP_SYS_ADMIN capability).

SEE ALSO
       eBPF  architecture  and  instruction  set  is  explained  in Documenta-
       tion/networking/filter.txt



Linux                             2014-09-01                            BPF(2)
