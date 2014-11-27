From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 0/6] allow eBPF programs to be attached to sockets
Date: Wed, 26 Nov 2014 21:42:25 -0800
Message-ID: <1417066951-1999-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Introduce BPF_PROG_TYPE_SOCKET_FILTER type of eBPF programs that can be
attached to sockets with setsockopt().
Allow such programs to access maps via lookup/update/delete helpers.

This feature was previewed by bpf manpage in commit b4fc1a460f30("Merge branch 'bpf-next'")
Now it can actually run.

1st patch adds LD_ABS/LD_IND instruction verification and
2nd patch adds new setsockopt() flag.
Patches 3-6 are examples in assembler and in C.

Though native eBPF programs are way more powerful than classic filters
(attachable through similar setsockopt() call), they don't have skb field
accessors yet. Like skb->pkt_type, skb->dev->ifindex are not accessible.
There are sevaral ways to achieve that. That will be in the next set of patches.
So in this set native eBPF programs can only read data from packet and
access maps.

The most powerful example is sockex2_kern.c from patch 6 where ~200 lines of C
are compiled into ~300 of eBPF instructions.
It shows how quite complex packet parsing can be done.

LLVM used to build examples is at https://github.com/iovisor/llvm
which is fork of llvm trunk that I'm cleaning up for upstreaming.

Alexei Starovoitov (6):
  bpf: verifier: add checks for BPF_ABS | BPF_IND instructions
  net: sock: allow eBPF programs to be attached to sockets
  samples: bpf: example of stateful socket filtering
  samples: bpf: elf_bpf file loader
  samples: bpf: trivial eBPF program in C
  samples: bpf: large eBPF program in C

 arch/alpha/include/uapi/asm/socket.h   |    3 +
 arch/avr32/include/uapi/asm/socket.h   |    3 +
 arch/cris/include/uapi/asm/socket.h    |    3 +
 arch/frv/include/uapi/asm/socket.h     |    3 +
 arch/ia64/include/uapi/asm/socket.h    |    3 +
 arch/m32r/include/uapi/asm/socket.h    |    3 +
 arch/mips/include/uapi/asm/socket.h    |    3 +
 arch/mn10300/include/uapi/asm/socket.h |    3 +
 arch/parisc/include/uapi/asm/socket.h  |    3 +
 arch/powerpc/include/uapi/asm/socket.h |    3 +
 arch/s390/include/uapi/asm/socket.h    |    3 +
 arch/sparc/include/uapi/asm/socket.h   |    3 +
 arch/xtensa/include/uapi/asm/socket.h  |    3 +
 include/linux/bpf.h                    |    4 +
 include/linux/filter.h                 |    1 +
 include/uapi/asm-generic/socket.h      |    3 +
 include/uapi/linux/bpf.h               |    1 +
 kernel/bpf/verifier.c                  |   70 ++++++++++-
 net/core/filter.c                      |   97 +++++++++++++-
 net/core/sock.c                        |   13 ++
 samples/bpf/Makefile                   |   20 +++
 samples/bpf/bpf_helpers.h              |   40 ++++++
 samples/bpf/bpf_load.c                 |  203 ++++++++++++++++++++++++++++++
 samples/bpf/bpf_load.h                 |   24 ++++
 samples/bpf/libbpf.c                   |   28 +++++
 samples/bpf/libbpf.h                   |   15 ++-
 samples/bpf/sock_example.c             |   97 ++++++++++++++
 samples/bpf/sockex1_kern.c             |   23 ++++
 samples/bpf/sockex1_user.c             |   49 ++++++++
 samples/bpf/sockex2_kern.c             |  215 ++++++++++++++++++++++++++++++++
 samples/bpf/sockex2_user.c             |   44 +++++++
 31 files changed, 981 insertions(+), 5 deletions(-)
 create mode 100644 samples/bpf/bpf_helpers.h
 create mode 100644 samples/bpf/bpf_load.c
 create mode 100644 samples/bpf/bpf_load.h
 create mode 100644 samples/bpf/sock_example.c
 create mode 100644 samples/bpf/sockex1_kern.c
 create mode 100644 samples/bpf/sockex1_user.c
 create mode 100644 samples/bpf/sockex2_kern.c
 create mode 100644 samples/bpf/sockex2_user.c

-- 
1.7.9.5
