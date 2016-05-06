From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 0/7] bpf: introduce direct packet access
Date: Thu, 5 May 2016 19:49:08 -0700
Message-ID: <1462502955-1731797-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:55958 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756016AbcEFCtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 22:49:19 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u462k6lX001676
	for <netdev@vger.kernel.org>; Thu, 5 May 2016 19:49:18 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 22r650p24w-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 05 May 2016 19:49:18 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 1f784016133511e6b5310002c95209d8-9baf4c50 for <netdev@vger.kernel.org>;	Thu,
 05 May 2016 19:49:16 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches introduce 'direct packet access' from
cls_bpf and act_bpf programs (which are root only).

Current bpf programs use LD_ABS, LD_INS instructions which have
to do 'if (off < skb_headlen)' for every packet access.
It's ok for socket filters, but too slow for XDP, since single
LD_ABS insn consumes 3% of cpu. Therefore we have to amortize the cost
of length check over multiple packet accesses via direct access
to skb->data, data_end pointers.

The existing packet parser typically look like:
  if (load_half(skb, offsetof(struct ethhdr, h_proto)) != ETH_P_IP)
     return 0;
  if (load_byte(skb, ETH_HLEN + offsetof(struct iphdr, protocol)) != IPPROTO_UDP ||
      load_byte(skb, ETH_HLEN) != 0x45)
     return 0;
  ...
with 'direct packet access' the bpf program becomes:
   void *data = (void *)(long)skb->data;
   void *data_end = (void *)(long)skb->data_end;
   struct eth_hdr *eth = data;
   struct iphdr *iph = data + sizeof(*eth);

   if (data + sizeof(*eth) + sizeof(*iph) + sizeof(*udp) > data_end)
      return 0;
   if (eth->h_proto != htons(ETH_P_IP))
      return 0;
   if (iph->protocol != IPPROTO_UDP || iph->ihl != 5)
      return 0;
   ...
which is more natural to write and significantly faster.
See patch 6 for performance tests:
21Mpps(old) vs 24Mpps(new) with just 5 loads.
For more complex parsers the performance gain is higher.

The other approach implemented in [1] was adding two new instructions
to interpreter and JITs and was too hard to use from llvm side.
The approach presented here doesn't need any instruction changes,
but the verifier has to work harder to check safety of the packet access.

Patch 1 prepares the code and Patch 2 adds new checks for direct
packet access and all of them are gated with 'env->allow_ptr_leaks'
which is true for root only.
Patch 3 improves search pruning for large programs.
Patch 4 wires in verifier's changes with net/core/filter side.
Patch 5 updates docs
Patches 6 and 7 add tests.

[1] https://git.kernel.org/cgit/linux/kernel/git/ast/bpf.git/?h=ld_abs_dw
 
Alexei Starovoitov (7):
  bpf: cleanup verifier code
  bpf: direct packet access
  bpf: improve verifier state equivalence
  bpf: wire in data and data_end for cls_act_bpf
  bpf: add documentation for 'direct packet access'
  samples/bpf: add 'pointer to packet' tests
  samples/bpf: add verifier tests

 Documentation/networking/filter.txt |  85 +++++-
 include/linux/filter.h              |  16 +
 include/uapi/linux/bpf.h            |   2 +
 kernel/bpf/core.c                   |   5 +
 kernel/bpf/verifier.c               | 562 +++++++++++++++++++++++++++++++-----
 net/core/filter.c                   |  51 +++-
 net/sched/act_bpf.c                 |   2 +
 net/sched/cls_bpf.c                 |   2 +
 samples/bpf/Makefile                |   2 +
 samples/bpf/parse_ldabs.c           |  41 +++
 samples/bpf/parse_simple.c          |  48 +++
 samples/bpf/parse_varlen.c          | 153 ++++++++++
 samples/bpf/test_cls_bpf.sh         |  37 +++
 samples/bpf/test_verifier.c         |  80 +++++
 14 files changed, 1004 insertions(+), 82 deletions(-)
 create mode 100644 samples/bpf/parse_ldabs.c
 create mode 100644 samples/bpf/parse_simple.c
 create mode 100644 samples/bpf/parse_varlen.c
 create mode 100755 samples/bpf/test_cls_bpf.sh

-- 
2.8.0
