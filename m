From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 0/9] bpf: stack depth tracking
Date: Tue, 30 May 2017 13:31:26 -0700
Message-ID: <20170530203135.3642768-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:55376 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750913AbdE3Ubi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 16:31:38 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4UKS51w012371
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:31:37 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2as8hwsg4m-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:31:37 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 fa0d0aee457611e7913b0002c99331b0-949338f0 for <netdev@vger.kernel.org>;        Tue,
 30 May 2017 13:31:36 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce tracking of bpf program stack depth in the verifier and use that
info to reduce bpf program stack consumption in the interpreter and x64 JIT.
Other JITs can take advantage of it as well in the future.
Most of the programs consume very little stack, so it's good optimization
in general and it's the first step toward bpf to bpf function calls.

Also use internal opcode for bpf_tail_call() marking to make clear
that jmp|call|x opcode is not uapi and may be used for actual
indirect call opcode in the future.

Alexei Starovoitov (9):
  bpf: free up BPF_JMP | BPF_CALL | BPF_X opcode
  bpf: split bpf core interpreter
  bpf: teach verifier to track stack depth
  bpf: reconcile bpf_tail_call and stack_depth
  bpf: track stack depth of classic bpf programs
  bpf: fix stack_depth usage by test_bpf.ko
  bpf: use different interpreter depending on required stack size
  bpf: change x86 JITed program stack layout
  bpf: take advantage of stack_depth tracking in x64 JIT

 arch/arm64/net/bpf_jit_comp.c     |  2 +-
 arch/powerpc/net/bpf_jit_comp64.c |  2 +-
 arch/s390/net/bpf_jit_comp.c      |  2 +-
 arch/sparc/net/bpf_jit_comp_64.c  |  2 +-
 arch/x86/net/bpf_jit.S            | 20 ++++++------
 arch/x86/net/bpf_jit_comp.c       | 65 +++++++++++++++++++++------------------
 include/linux/bpf.h               |  1 +
 include/linux/filter.h            |  3 ++
 kernel/bpf/core.c                 | 47 ++++++++++++++++++++++------
 kernel/bpf/verifier.c             | 13 ++++++--
 lib/test_bpf.c                    | 25 ++++++++++++++-
 net/core/filter.c                 | 36 +++++++++++++---------
 12 files changed, 147 insertions(+), 71 deletions(-)

-- 
2.9.3
