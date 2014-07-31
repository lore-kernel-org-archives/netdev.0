From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v4 net-next 0/5] net: filter: split sk_filter into socket and bpf, cleanup names
Date: Wed, 30 Jul 2014 20:34:11 -0700
Message-ID: <1406777656-27755-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The main goal of the series is to split 'struct sk_filter' into socket and
bpf parts and cleanup names in the following way:
- everything that deals with sockets keeps 'sk_*' prefix
- everything that is pure BPF is changed to 'bpf_*' prefix

split 'struct sk_filter' into
struct sk_filter {
	atomic_t        refcnt;
	struct rcu_head rcu;
	struct bpf_prog *prog;
};
and
struct bpf_prog {
        u32                     jited:1,
                                len:31;
        struct sock_fprog_kern  *orig_prog;
        unsigned int            (*bpf_func)(const struct sk_buff *skb,
                                            const struct bpf_insn *filter);
        union {
                struct sock_filter      insns[0];
                struct bpf_insn         insnsi[0];
                struct work_struct      work;
        };
};
so that 'struct bpf_prog' can be used independent of sockets and cleans up
'unattached' bpf use cases:
isdn, ppp, team, seccomp, ptp, xt_bpf, cls_bpf, test_bpf
which don't need refcnt/rcu fields.

It's a follow up to the rcu cleanup started by Pablo in
commit 34c5bd66e5 ("net: filter: don't release unattached filter through call_rcu()")

Patch 1 - cleans up socket memory charging and makes it possible for functions
  sk(bpf)_migrate_filter(), sk(bpf)_prepare_filter() to be socket independent
Patches 2-4 - trivial renames
Patch 5 - sk_filter split and renames of related sk_*() functions

Alexei Starovoitov (5):
  net: filter: simplify socket charging
  net: filter: rename sk_filter_proglen -> bpf_classic_proglen
  net: filter: rename sk_chk_filter() -> bpf_check_classic()
  net: filter: rename sk_convert_filter() -> bpf_convert_filter()
  net: filter: split 'struct sk_filter' into socket and bpf parts

 Documentation/networking/filter.txt      |   12 +-
 arch/arm/net/bpf_jit_32.c                |    8 +-
 arch/mips/net/bpf_jit.c                  |    8 +-
 arch/powerpc/net/bpf_jit_comp.c          |    8 +-
 arch/s390/net/bpf_jit_comp.c             |    4 +-
 arch/sparc/net/bpf_jit_comp.c            |    4 +-
 arch/x86/net/bpf_jit_comp.c              |   14 +--
 drivers/isdn/i4l/isdn_ppp.c              |   26 ++---
 drivers/net/ppp/ppp_generic.c            |   28 ++---
 drivers/net/team/team_mode_loadbalance.c |   14 +--
 include/linux/filter.h                   |   51 +++++----
 include/linux/isdn_ppp.h                 |    4 +-
 include/uapi/linux/netfilter/xt_bpf.h    |    4 +-
 kernel/bpf/core.c                        |   34 +++---
 kernel/seccomp.c                         |   18 +--
 lib/test_bpf.c                           |   24 ++--
 net/core/filter.c                        |  183 +++++++++++++++---------------
 net/core/ptp_classifier.c                |    6 +-
 net/core/sock.c                          |    9 +-
 net/core/sock_diag.c                     |    4 +-
 net/netfilter/xt_bpf.c                   |    6 +-
 net/sched/cls_bpf.c                      |   12 +-
 22 files changed, 243 insertions(+), 238 deletions(-)

-- 
1.7.9.5
