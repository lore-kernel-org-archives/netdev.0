From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 0/6] allow eBPF programs to be attached to sockets
Date: Mon,  1 Dec 2014 15:06:33 -0800
Message-ID: <1417475199-15950-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

V1->V2:

fixed comments in sample code to state clearly that packet data is accessed
with LD_ABS instructions and not internal skb fields.
Also replaced constants in:
BPF_LD_ABS(BPF_B, 14 + 9 /* R0 = ip->proto */),
with:
BPF_LD_ABS(BPF_B, ETH_HLEN + offsetof(struct iphdr, protocol) /* R0 = ip->proto */),

V1 cover:

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
 samples/bpf/sock_example.c             |  101 +++++++++++++++
 samples/bpf/sockex1_kern.c             |   25 ++++
 samples/bpf/sockex1_user.c             |   49 ++++++++
 samples/bpf/sockex2_kern.c             |  215 ++++++++++++++++++++++++++++++++
 samples/bpf/sockex2_user.c             |   44 +++++++
 31 files changed, 987 insertions(+), 5 deletions(-)
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
