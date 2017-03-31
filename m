From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 0/6] bpf: program testing framework
Date: Thu, 30 Mar 2017 18:31:51 -0700
Message-ID: <20170331013157.3298003-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41515 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934642AbdCaBcB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 21:32:01 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2V1ECfv002109
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 18:32:00 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 29h7d1s7mg-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 18:32:00 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.222.219.45) with ESMTP id
 d4bce1e615b111e7a20624be05904660-eaffa9a0 for <netdev@vger.kernel.org>;        Thu,
 30 Mar 2017 18:31:58 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Development and testing of networking bpf programs is quite cumbersome.
Especially tricky are XDP programs that attach to real netdevices and
program development feels like working on the car engine while
the car is in motion.
Another problem is ongoing changes to upstream llvm core
that can introduce an optimization that verifier will not
recognize. llvm bpf backend tests have no ability to run the programs.
To improve this situation introduce BPF_PROG_TEST_RUN command
to test and performance benchmark bpf programs.
It achieves several goals:
- development of xdp and skb based bpf programs can be done
in a canned environment with unit tests
- program performance optimizations can be benchmarked outside of
networking core (without driver and skb costs)
- continuous testing of upstream changes is finally practical

Patches 3,5,6 add C based test cases of various complexity
to cover some sched_cls and xdp features. More tests will
be added in the future. The tests were run on centos7 only.

For now the framework supports only skb and xdp programs. In the future
it can be extended to socket_filter and tracing program types.

More details are in individual patches.

Alexei Starovoitov (6):
  bpf: introduce BPF_PROG_TEST_RUN command
  tools/lib/bpf: add support for BPF_PROG_TEST_RUN command
  selftests/bpf: add a test for overlapping packet range checks
  tools/lib/bpf: expose bpf_program__set_type()
  selftests/bpf: add a test for basic XDP functionality
  selftests/bpf: add l4 load balancer test based on sched_cls

 include/linux/bpf.h                                |   7 +
 include/uapi/linux/bpf.h                           |  12 +
 kernel/bpf/syscall.c                               |  27 +-
 net/Makefile                                       |   2 +-
 net/bpf/Makefile                                   |   1 +
 net/bpf/test_run.c                                 | 172 ++++++++
 net/core/filter.c                                  |   5 +
 tools/include/uapi/linux/bpf.h                     |  24 ++
 tools/lib/bpf/bpf.c                                |  24 ++
 tools/lib/bpf/bpf.h                                |   4 +-
 tools/lib/bpf/libbpf.c                             |   3 +-
 tools/lib/bpf/libbpf.h                             |   1 +
 tools/testing/selftests/bpf/Makefile               |  18 +-
 tools/testing/selftests/bpf/test_iptunnel_common.h |  37 ++
 tools/testing/selftests/bpf/test_l4lb.c            | 474 +++++++++++++++++++++
 tools/testing/selftests/bpf/test_pkt_access.c      |  64 +++
 tools/testing/selftests/bpf/test_progs.c           | 284 ++++++++++++
 tools/testing/selftests/bpf/test_xdp.c             | 236 ++++++++++
 18 files changed, 1385 insertions(+), 10 deletions(-)
 create mode 100644 net/bpf/Makefile
 create mode 100644 net/bpf/test_run.c
 create mode 100644 tools/testing/selftests/bpf/test_iptunnel_common.h
 create mode 100644 tools/testing/selftests/bpf/test_l4lb.c
 create mode 100644 tools/testing/selftests/bpf/test_pkt_access.c
 create mode 100644 tools/testing/selftests/bpf/test_progs.c
 create mode 100644 tools/testing/selftests/bpf/test_xdp.c

-- 
2.9.3
