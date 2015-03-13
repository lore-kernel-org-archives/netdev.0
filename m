From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 0/2] bpf: allow extended BPF programs access skb fields
Date: Thu, 12 Mar 2015 19:21:09 -0700
Message-ID: <1426213271-8363-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi All,

classic BPF has a way to access skb fields, whereas extended BPF didn't.
This patch introduces this ability.

Classic BPF can access fields via negative SKF_AD_OFF offset.
Positive bpf_ld_abs N is treated as load from packet, whereas
bpf_ld_abs -0x1000 + N is treated as skb fields access.
Many offsets were hard coded over years: SKF_AD_PROTOCOL, SKF_AD_PKTTYPE, etc.
The problem with this approach was that for every new field classic bpf
assembler had to be tweaked.

I've considered doing the same for extended, but for every new field LLVM
compiler would have to be modifed. Since it would need to add a new intrinsic.
It could be done with single intrinsic and magic offset or use of inline
assembler, but neither are clean from compiler backend point of view, since
they look like calls but shouldn't scratch caller-saved registers.

Another approach was to introduce a new helper functions like bpf_get_pkt_type()
for every field that we want to access, but that is equally ugly for kernel
and slow, since helpers are calls and they are slower then just loads.
In theory helper calls can be 'inlined' inside kernel into direct loads, but
since they were calls for user space, compiler would have to spill registers
around such calls anyway. Teaching compiler to treat such helpers differently
is even uglier.

They were few other ideas considered. At the end the best seems to be to
introduce a user accessible mirror of in-kernel sk_buff structure:

struct __sk_buff {
    __u32 len;
    __u32 pkt_type;
    __u32 mark;
    __u32 ifindex;
    __u32 queue_mapping;
};

bpf programs will do:

int bpf_prog1(struct __sk_buff *skb)
{
    __u32 var = skb->pkt_type;

which will be compiled to bpf assembler as:

dst_reg = *(u32 *)(src_reg + 4) // 4 == offsetof(struct __sk_buff, pkt_type)

bpf verifier will check validity of access and will convert it to:

dst_reg = *(u8 *)(src_reg + offsetof(struct sk_buff, __pkt_type_offset))
dst_reg &= 7

since 'pkt_type' is a bitfield.

llvm doesn't need to be modified at all, JITs don't change either and
verifier already knows when it accesses 'ctx' pointer.
The only thing needed was to convert user visible offset within __sk_buff
to kernel internal offset within sk_buff.
For 'len' and other fields conversion is trivial.
Converting 'pkt_type' takes 2 or 3 instructions depending on endianness.
More fields can be exposed by adding to the end of the 'struct __sk_buff'.
Like vlan_tci and others can be added later.

When pkt_type field is moved around, goes into different structure, removed or
its size changes, the function sk_filter_convert_ctx_access() would need to be
updated. Just like the function convert_bpf_extensions() in case of classic bpf.

Patch 2 updates examples to demonstrates how fields are accessed and
adds new tests for verifier, since it needs to detect a corner case when
attacker is using single bpf instruction in two branches with different
register types.

The 5 fields of __sk_buff are already exposed to user space via classic bpf and
I believe they're useful to access from extended.
I don't think we need to expose skb->protocol or skb->dev->type, but that's
a seprate discussion.

Daniel,
patch 1 includes a bit of code that does prog_realloc and branch adjustment
to make room for new instructions. I think you'd need the same for your
'constant blinding' work. If indeed that would be the case, we'll make it
into a helper function.

Since sk_filter_ops are shared between BPF_PROG_TYPE_SOCKET_FILTER and
BPF_PROG_TYPE_SCHED_CLS types, cls_bpf will be able to see packet length :)

Alexei Starovoitov (2):
  bpf: allow extended BPF programs access skb fields
  samples: bpf: add skb->field examples and tests

 include/linux/bpf.h         |    5 +-
 include/uapi/linux/bpf.h    |    8 +++
 kernel/bpf/syscall.c        |    2 +-
 kernel/bpf/verifier.c       |  152 ++++++++++++++++++++++++++++++++++++++-----
 net/core/filter.c           |   58 ++++++++++++++++-
 samples/bpf/sockex1_kern.c  |    8 ++-
 samples/bpf/sockex1_user.c  |    2 +-
 samples/bpf/sockex2_kern.c  |   26 +++++---
 samples/bpf/sockex2_user.c  |   11 +++-
 samples/bpf/test_verifier.c |   73 +++++++++++++++++++++
 10 files changed, 309 insertions(+), 36 deletions(-)

-- 
1.7.9.5
