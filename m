From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v11 net-next 00/12] eBPF syscall, verifier, testsuite
Date: Fri, 12 Sep 2014 15:40:59 -0700
Message-ID: <20140912224058.GA34627@ITs-MacBook-Pro.local>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
 <541013CE.6020307@redhat.com>
 <CAMEtUuwrHX4ENK9cZ0C+XVB=wkMz1=wLphX_GVLvd8pyJKMXeQ@mail.gmail.com>
 <5411FC42.3070505@redhat.com>
 <CAMEtUuziPptHxtw_7fkOdR-paB+8BatNmRPoo3txP8wOp9D6Tw@mail.gmail.com>
 <CALCETrWCEwscbbfX7wAW-A+VQ5Y92igD36BmTXqFra04Qdwk0Q@mail.gmail.com>
 <CAMEtUuyzOgCZutgsAXs60BO0=0WJGpVAeTYN2hf0Bh1sZ5PMVg@mail.gmail.com>
 <CALCETrXqwd=dp31fckMPruQMwVw+UAjaf=SSWp8wr_Cdz_tQdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linuxfoundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
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
	LKML <linux-kernel@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrXqwd=dp31fckMPruQMwVw+UAjaf=SSWp8wr_Cdz_tQdw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

the list of things I fixed so far from V11:
- dropped patch 11 and copied few macros to libbpf.h (suggested by Daniel)
- replaced 'enum bpf_prog_type' with u32 to be safe in compat (.. Andy)
- implemented and tested compat support (.. Daniel)
- changed 'void *log_buf' to 'char *' (.. Daniel)
- combined struct bpf_work_struct and bpf_prog_info (.. Daniel)
- added better return value explanation to manpage (.. Andy)
- added log_buf/log_size explanation to manpage (.. Andy & Daniel)
- added a lot more info about prog_type and map_type and
  they relation to verifier (.. Andy)

anything else I missed from the discussion we had?

Here is updated manpage. Please take a look.

BPF(2)                     Linux Programmer's Manual                    BPF(2)



NAME
       bpf - perform a command on eBPF map or program

SYNOPSIS
       #include <linux/bpf.h>

       int bpf(int cmd, union bpf_attr *attr, unsigned int size);


DESCRIPTION
       bpf()  syscall  is a multiplexor for a range of different operations on
       eBPF  which  can  be  characterized  as  "universal  in-kernel  virtual
       machine".  eBPF  is  similar  to  original  Berkeley  Packet Filter (or
       "classic BPF") used to filter network packets. Both statically  analyze
       the  programs  before  loading  them  into  the  kernel  to ensure that
       programs cannot harm the running system.

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
       statically  determines  that  the  program  terminates  and  is safe to
       execute. During verification the program takes a hold of maps  that  it
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
              Lookup element by key in a given map  and  return  key  of  next
              element

       BPF_PROG_LOAD
              Verify and load eBPF program

       attr   is a pointer to a union of type bpf_attr as defined below.

       size   is the size of the union.

       union bpf_attr {
           struct { /* anonymous struct used by BPF_MAP_CREATE command */
               __u32             map_type;
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
               __u32                 prog_type;
               __u32                 insn_cnt;
               const struct bpf_insn *insns;
               const char            *license;
               __u32                 log_level; /* verbosity level of eBPF verifier */
               __u32                 log_size;  /* size of user buffer */
               char                  *log_buf;  /* user supplied buffer */
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
              returns process-local file descriptor. On error, -1 is  returned
              and errno is set to EINVAL or EPERM or ENOMEM.

              The  attributes key_size and value_size will be used by verifier
              during  program  loading  to  check  that  program  is   calling
              bpf_map_*_elem() helper functions with correctly initialized key
              and  that  program  doesn't  access  map  element  value  beyond
              specified  value_size.   For  example,  when map is created with
              key_size = 8 and program does:
              bpf_map_lookup_elem(map_fd, fp - 4)
              such program will be rejected, since in-kernel  helper  function
              bpf_map_lookup_elem(map_fd,  void  *key) expects to read 8 bytes
              from 'key' pointer, but 'fp - 4' starting address will cause out
              of bounds stack access.

              Similarly,  when  map is created with value_size = 1 and program
              does:
              value = bpf_map_lookup_elem(...);
              *(u32 *)value = 1;
              such program will be rejected, since it accesses  value  pointer
              beyond specified 1 byte value_size limit.

              Currently only hash table map_type is supported:
              enum bpf_map_type {
                 BPF_MAP_TYPE_UNSPEC,
                 BPF_MAP_TYPE_HASH,
              };
              map_type  selects  one  of  the available map implementations in
              kernel. Regardless of type eBPF program accesses maps  with  the
              same      bpf_map_lookup_elem()/bpf_map_update_elem()     helper
              functions.

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
              bpf() syscall looks up an element with given key in  a  map  fd.
              If  element  is found it returns zero and stores element's value
              into value.  If element is not found  it  returns  -1  and  sets
              errno to ENOENT.

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
              map fd.  On success it returns zero.  On error, -1  is  returned
              and  errno  is set to EINVAL or EPERM or ENOMEM or E2BIG.  E2BIG
              indicates that number of elements in the map reached max_entries
              limit specified at map creation time.

       BPF_MAP_DELETE_ELEM
              int bpf_delete_elem(int fd, void *key)
              {
                  union bpf_attr attr = {
                      .map_fd = fd,
                      .key = key,
                  };

                  return bpf(BPF_MAP_DELETE_ELEM, &attr, sizeof(attr));
              }
              The call deletes an element in a map fd with given key.  Returns
              zero on success. If element is not found it returns -1 and  sets
              errno to ENOENT.

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
              The  call  looks  up  an  element  by  key in a given map fd and
              returns key of the next element into next_key pointer. If key is
              not  found,  it return zero and returns key of the first element
              into next_key. If key is the last element,  it  returns  -1  and
              sets  errno  to  ENOENT. Other possible errno values are ENOMEM,
              EFAULT, EPERM, EINVAL.  This method can be used to iterate  over
              all elements of the map.

       close(map_fd)
              will  delete  the  map  map_fd.  Exiting process will delete all
              maps automatically.

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
              prog_type is one of the available program types:
              enum bpf_prog_type {
                      BPF_PROG_TYPE_UNSPEC,
                      BPF_PROG_TYPE_SOCKET,
                      BPF_PROG_TYPE_TRACING,
              };
              By picking prog_type program author  selects  a  set  of  helper
              functions callable from eBPF program and corresponding format of
              struct bpf_context (which is  the  data  blob  passed  into  the
              program  as  the  first  argument).   For  example, the programs
              loaded with  prog_type  =  TYPE_TRACING  may  call  bpf_printk()
              helper,  whereas  TYPE_SOCKET  programs  may  not.   The  set of
              functions  available  to  the  programs  under  given  type  may
              increase in the future.

              Currently the set of functions for TYPE_TRACING is:
              bpf_map_lookup_elem(map_fd, void *key)              // lookup key in a map_fd
              bpf_map_update_elem(map_fd, void *key, void *value) // update key/value
              bpf_map_delete_elem(map_fd, void *key)              // delete key in a map_fd
              bpf_ktime_get_ns(void)                              // returns current ktime
              bpf_printk(char *fmt, int fmt_size, ...)            // prints into trace buffer
              bpf_get_current(void)                               // return current task pointer
              bpf_memcmp(void *ptr1, void *ptr2, int size)        // non-faulting memcmp
              bpf_fetch_ptr(void *ptr)    // non-faulting load pointer from any address
              bpf_fetch_u8(void *ptr)     // non-faulting 1 byte load
              bpf_fetch_u16(void *ptr)    // other non-faulting loads
              bpf_fetch_u32(void *ptr)
              bpf_fetch_u64(void *ptr)

              and bpf_context is defined as:
              struct bpf_context {
                  /* argN fields match one to one to arguments passed to trace events */
                  u64 arg1, arg2, arg3, arg4, arg5, arg6;
                  /* return value from kretprobe event or from syscall_exit event */
                  u64 ret;
              };

              The set of helper functions for TYPE_SOCKET is TBD.

              More   program   types   may   be  added  in  the  future.  Like
              BPF_PROG_TYPE_USER_TRACING for unprivileged programs.

              insns array of "struct bpf_insn" instructions

              insn_cnt number of instructions in the program

              license license string, which must be  GPL  compatible  to  call
              helper functions marked gpl_only

              log_buf user supplied buffer that in-kernel verifier is using to
              store verification log. Log is a multi-line string  that  should
              be  used  by  program  author to understand how verifier came to
              conclusion that program is unsafe. The format of the output  can
              change at any time as verifier evolves.

              log_size size of user buffer. If size of the buffer is not large
              enough to store all verifier messages, -1 is returned and  errno
              is set to ENOSPC.

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
           int sock, map_fd, prog_fd, key;
           long long value = 0, tcp_cnt, udp_cnt;

           map_fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value), 2);
           if (map_fd < 0) {
               printf("failed to create map '%s'\n", strerror(errno));
               /* likely not run as root */
               return 1;
           }

           key = 6; /* ip->proto == tcp */
           assert(bpf_update_elem(map_fd, &key, &value) == 0);

           key = 17; /* ip->proto == udp */
           assert(bpf_update_elem(map_fd, &key, &value) == 0);

           struct bpf_insn prog[] = {
               BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),          /* r6 = r1 */
               BPF_LD_ABS(BPF_B, 14 + 9),                    /* r0 = ip->proto */
               BPF_STX_MEM(BPF_W, BPF_REG_10, BPF_REG_0, -4),/* *(u32 *)(fp - 4) = r0 */
               BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),         /* r2 = fp */
               BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4),        /* r2 = r2 - 4 */
               BPF_LD_MAP_FD(BPF_REG_1, map_fd),             /* r1 = map_fd */
               BPF_CALL_FUNC(BPF_FUNC_map_lookup_elem),      /* r0 = map_lookup(r1, r2) */
               BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),        /* if (r0 == 0) goto pc+2 */
               BPF_MOV64_IMM(BPF_REG_1, 1),                  /* r1 = 1 */
               BPF_XADD(BPF_DW, BPF_REG_0, BPF_REG_1, 0, 0), /* lock *(u64 *)r0 += r1 */
               BPF_MOV64_IMM(BPF_REG_0, 0),                  /* r0 = 0 */
               BPF_EXIT_INSN(),                              /* return r0 */
           };
           prog_fd = bpf_prog_load(BPF_PROG_TYPE_SOCKET, prog, sizeof(prog), "GPL");
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

       EFAULT One of the pointers ( key or value or  log_buf  or  insns  )  is
              outside accessible address space.

       EINVAL The value specified in cmd is not recognized by this kernel.

       EINVAL For BPF_MAP_CREATE, either map_type or attributes are invalid.

       EINVAL For  BPF_MAP_*_ELEM  commands,  some  of  the  fields  of "union
              bpf_attr" unused by this command are not set to zero.

       EINVAL For BPF_PROG_LOAD, attempt to load invalid program (unrecognized
              instruction  or  uses  reserved  fields or jumps out of range or
              loop detected or calls unknown function).

       EACCES For BPF_PROG_LOAD, though program has valid instructions, it was
              rejected,  since  it  was  deemed  unsafe (may access disallowed
              memory  region  or  uninitialized  stack/register  or   function
              constraints  don't  match actual types or misaligned access). In
              such case it is recommended to call bpf() again with log_level =
              1 and examine log_buf for specific reason provided by verifier.

       ENOENT For  BPF_MAP_LOOKUP_ELEM  or BPF_MAP_DELETE_ELEM, indicates that
              element with given key was not found.

       E2BIG  program is too large or a map  reached  max_entries  limit  (max
              number of elements).

NOTES
       These commands may be used only by a privileged process (one having the
       CAP_SYS_ADMIN capability).

SEE ALSO
       eBPF   architecture   and   instruction    set    is    explained    in
       Documentation/networking/filter.txt



Linux                             2014-09-12                            BPF(2)
