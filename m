From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 0/6] bpf: inline bpf_map_lookup_elem()
Date: Wed, 15 Mar 2017 18:26:38 -0700
Message-ID: <1489627604-2288703-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Fengguang Wu <fengguang.wu@intel.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40403 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751069AbdCPB06 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 21:26:58 -0400
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2G1J1wx003790
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:26:56 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 297e3ngmyf-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:26:56 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 9da10fa009e711e78ea90002c9dfb610-b94f19a0 for <netdev@vger.kernel.org>;        Wed,
 15 Mar 2017 18:26:44 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bpf_map_lookup_elem() is one of the most frequently used helper functions.
Improve JITed program performance by inlining this helper.

bpf_map_type	before  after
hash		58M	74M
array		174M	280M

The values are number of lookups per second in ideal conditions
measured by micro-benchmark in patch 6.

The 'perf report' for HASH map type:
before:
    54.23%  map_perf_test  [kernel.kallsyms]  [k] __htab_map_lookup_elem
    14.24%  map_perf_test  [kernel.kallsyms]  [k] lookup_elem_raw
     8.84%  map_perf_test  [kernel.kallsyms]  [k] htab_map_lookup_elem
     5.93%  map_perf_test  [kernel.kallsyms]  [k] bpf_map_lookup_elem
     2.30%  map_perf_test  [kernel.kallsyms]  [k] bpf_prog_da4fc6a3f41761a2
     1.49%  map_perf_test  [kernel.kallsyms]  [k] kprobe_ftrace_handler

after:
    60.03%  map_perf_test  [kernel.kallsyms]  [k] __htab_map_lookup_elem
    18.07%  map_perf_test  [kernel.kallsyms]  [k] lookup_elem_raw
     2.91%  map_perf_test  [kernel.kallsyms]  [k] bpf_prog_da4fc6a3f41761a2
     1.94%  map_perf_test  [kernel.kallsyms]  [k] _einittext
     1.90%  map_perf_test  [kernel.kallsyms]  [k] __audit_syscall_exit
     1.72%  map_perf_test  [kernel.kallsyms]  [k] kprobe_ftrace_handler

so the cost of htab_map_lookup_elem() and bpf_map_lookup_elem()
is gone after inlining.

'per-cpu' and 'lru' map types can be optimized similarly in the future.

Note the sparse will complain that bpf is addictive ;)
kernel/bpf/hashtab.c:438:19: sparse: subtraction of functions? Share your drugs
kernel/bpf/verifier.c:3342:38: sparse: subtraction of functions? Share your drugs
it's not a new warning, just in new places.

Alexei Starovoitov (6):
  bpf: move fixup_bpf_calls() function
  bpf: refactor fixup_bpf_calls()
  bpf: adjust insn_aux_data when patching insns
  bpf: add helper inlining infra and optimize map_array lookup
  bpf: inline htab_map_lookup_elem()
  samples/bpf: add map_lookup microbenchmark

 include/linux/bpf.h              |   1 +
 include/linux/bpf_verifier.h     |   5 +-
 include/linux/filter.h           |  10 +++
 kernel/bpf/arraymap.c            |  29 +++++++++
 kernel/bpf/hashtab.c             |  31 +++++++++-
 kernel/bpf/syscall.c             |  56 -----------------
 kernel/bpf/verifier.c            | 129 ++++++++++++++++++++++++++++++++++++---
 samples/bpf/map_perf_test_kern.c |  33 ++++++++++
 samples/bpf/map_perf_test_user.c |  32 ++++++++++
 9 files changed, 261 insertions(+), 65 deletions(-)

-- 
2.8.0
