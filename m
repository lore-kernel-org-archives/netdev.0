From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 0/8] bpf: muli prog support for cgroup-bpf
Date: Mon, 2 Oct 2017 22:50:20 -0700
Message-ID: <20171003055028.1294791-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, Tejun Heo <tj@kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41131 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750767AbdJCFua (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 01:50:30 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v935nTgU008510
        for <netdev@vger.kernel.org>; Mon, 2 Oct 2017 22:50:30 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dbwmpabw5-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 22:50:30 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1->v2:
- fixed accidentally swapped two lines which caused static_key not going to zero
- addressed Martin's feedback and changed prog_query to be consistent
  with verifier output: return -enospc and fill supplied buffer instead
  of just returning -enospc when buffer is too small to fit all prog_ids

v1:
cgroup-bpf use cases are getting more advanced and running only
one program per cgroup is no longer enough. Therefore introduce
support for attaching multiple programs per cgroup and running
a set of effective programs.

These patches introduces BPF_F_ALLOW_MULTI flag for BPF_PROG_ATTACH cmd.
The default is still NONE and behavior of BPF_F_ALLOW_OVERRIDE flag
is unchanged.
The difference between three possible flags for BPF_PROG_ATTACH command:
- NONE(default): No further bpf programs allowed in the subtree.
- BPF_F_ALLOW_OVERRIDE: If a sub-cgroup installs some bpf program,
  the program in this cgroup yields to sub-cgroup program.
- BPF_F_ALLOW_MULTI: If a sub-cgroup installs some bpf program,
  that cgroup program gets run in addition to the program in this cgroup.

Most of the logic is in patch 1. Even when cgroup doesn't have
any programs attached its set of effective program can be non-empty.
To quickly execute them and avoid penalizing cgroups without
any effective programs introduce 'struct bpf_prog_array'
which has an optimization for cgroups with zero effective programs.

Patch 2 introduces BPF_PROG_QUERY command for introspection
Patch 3 makes verifier more strict for cgroup-bpf program types.
Patch 4+ are tests.

More details in individual patches

Alexei Starovoitov (8):
  bpf: multi program support for cgroup+bpf
  bpf: introduce BPF_PROG_QUERY command
  bpf: enforce return code for cgroup-bpf programs
  libbpf: introduce bpf_prog_detach2()
  samples/bpf: add multi-prog cgroup test case
  libbpf: sync bpf.h
  libbpf: add support for BPF_PROG_QUERY
  samples/bpf: use bpf_prog_query() interface

 include/linux/bpf-cgroup.h                  |  54 ++-
 include/linux/bpf.h                         |  35 ++
 include/linux/filter.h                      |   2 +-
 include/uapi/linux/bpf.h                    |  55 ++-
 kernel/bpf/cgroup.c                         | 513 +++++++++++++++++++++-------
 kernel/bpf/core.c                           |  69 ++++
 kernel/bpf/syscall.c                        |  71 +++-
 kernel/bpf/verifier.c                       |  40 +++
 kernel/cgroup/cgroup.c                      |  38 ++-
 samples/bpf/cgroup_helpers.c                |   4 +-
 samples/bpf/test_cgrp2_attach2.c            | 224 +++++++++++-
 tools/include/uapi/linux/bpf.h              |  55 ++-
 tools/lib/bpf/bpf.c                         |  32 ++
 tools/lib/bpf/bpf.h                         |   4 +-
 tools/testing/selftests/bpf/test_verifier.c |  72 ++++
 15 files changed, 1086 insertions(+), 182 deletions(-)

-- 
2.9.5
