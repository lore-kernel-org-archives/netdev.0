From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [RFC PATCH v2 net-next 0/2] BPF and OVS extensions
Date: Mon, 16 Sep 2013 19:48:37 -0700
Message-ID: <1379386119-4157-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Xi Wang <xi.wang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

while net-next is closed, collecting feedback...

V2:
No changes to BPF engine
No changes to uapi
Add static branch prediction markings, remove unnecessary safety checks,
fix crash where packets were enqueued to a BPF program while program
was being unloaded

V1:
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
 net/openvswitch/bpf_plum.c       |  931 +++++++++++++++++++++++++++++
 net/openvswitch/bpf_replicator.c |  155 +++++
 net/openvswitch/bpf_table.c      |  500 ++++++++++++++++
 net/openvswitch/datapath.c       |  102 +++-
 net/openvswitch/datapath.h       |    5 +
 net/openvswitch/dp_bpf.c         | 1228 ++++++++++++++++++++++++++++++++++++++
 net/openvswitch/dp_bpf.h         |  160 +++++
 net/openvswitch/dp_notify.c      |    7 +
 net/openvswitch/vport-gre.c      |   10 -
 net/openvswitch/vport-netdev.c   |   15 +-
 net/openvswitch/vport-netdev.h   |    1 +
 net/openvswitch/vport.h          |   10 +
 24 files changed, 5854 insertions(+), 62 deletions(-)
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
