From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [RFC PATCH net-next 0/2] BPF and OVS extensions
Date: Wed, 11 Sep 2013 20:12:40 -0700
Message-ID: <1378955562-3825-1-git-send-email-ast@plumgrid.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:64073 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052Ab3ILDMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 23:12:53 -0400
Received: by mail-pd0-f170.google.com with SMTP id x10so10113979pdj.15
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 20:12:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today OVS is a cache engine. Userspace controller simulates traversal of
network topology and establishes a flow (cached result of the traversal).
Suffering upcall penalty, flow explosion, flow invalidation on topology
changes, difficulties in keeping inner topology stats, etc. This patch
enhances OVS by moving simple cases of topology traversal next to the packet.
On a flow miss the chain of BPF programs executes the network topology.
If packet requires userspace processing it can be pushed up by BPF program.
BPF program that represent a bridge just needs to forward packets.
MAC learning can be done either by BPF program or via userpsace upcall.
Such bridge/router/nat can be programmed in BPF.
To achieve that BPF was extended to allow easier programability in restricted C
or in dataplane language.

Patch 1/2: generic BPF extension
Original A and X 32-bit BPF registers are replaced with ten 64-bit registers.
bpf opcode encoding kept the same. load/store were generalized to access stack,
bpf_tables and bpf_context.
BPF program interfaces to outside world via tables that it can read and write,
and via bpf_context which is in/out blob of data.
Other kernel components can provide callbacks to tailor BPF to specific needs.

Patch 2/2: extends OVS with network functions that use BPF as execution engine

BPF backend for GCC is available at:
https://github.com/iovisor/bpf_gcc

Distributed bridge demo written in BPF:
https://github.com/iovisor/iovisor

Alexei Starovoitov (2):
  extended BPF
  extend OVS to use BPF programs on flow miss

 arch/x86/net/Makefile            |    2 +-
 arch/x86/net/bpf2_jit_comp.c     |  610 +++++++++++++++++++
 arch/x86/net/bpf_jit_comp.c      |   41 +-
 arch/x86/net/bpf_jit_comp.h      |   36 ++
 include/linux/filter.h           |   79 +++
 include/uapi/linux/filter.h      |  125 +++-
 include/uapi/linux/openvswitch.h |  140 +++++
 net/core/Makefile                |    2 +-
 net/core/bpf_check.c             | 1043 ++++++++++++++++++++++++++++++++
 net/core/bpf_run.c               |  412 +++++++++++++
 net/openvswitch/Makefile         |    7 +-
 net/openvswitch/bpf_callbacks.c  |  295 +++++++++
 net/openvswitch/bpf_plum.c       |  923 ++++++++++++++++++++++++++++
 net/openvswitch/bpf_replicator.c |  155 +++++
 net/openvswitch/bpf_table.c      |  500 ++++++++++++++++
 net/openvswitch/datapath.c       |  102 +++-
 net/openvswitch/datapath.h       |    5 +
 net/openvswitch/dp_bpf.c         | 1221 ++++++++++++++++++++++++++++++++++++++
 net/openvswitch/dp_bpf.h         |  160 +++++
 net/openvswitch/dp_notify.c      |    7 +
 net/openvswitch/vport-gre.c      |   10 -
 net/openvswitch/vport-netdev.c   |   15 +-
 net/openvswitch/vport-netdev.h   |    1 +
 net/openvswitch/vport.h          |   10 +
 24 files changed, 5839 insertions(+), 62 deletions(-)
 create mode 100644 arch/x86/net/bpf2_jit_comp.c
 create mode 100644 arch/x86/net/bpf_jit_comp.h
 create mode 100644 net/core/bpf_check.c
 create mode 100644 net/core/bpf_run.c
 create mode 100644 net/openvswitch/bpf_callbacks.c
 create mode 100644 net/openvswitch/bpf_plum.c
 create mode 100644 net/openvswitch/bpf_replicator.c
 create mode 100644 net/openvswitch/bpf_table.c
 create mode 100644 net/openvswitch/dp_bpf.c
 create mode 100644 net/openvswitch/dp_bpf.h

-- 
1.7.9.5
