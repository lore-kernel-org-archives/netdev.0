From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next v6 00/16] bpf: Adds support for sock_ops
Date: Fri, 30 Jun 2017 20:02:39 -0700
Message-ID: <20170701030255.1931076-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33602 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751710AbdGADDC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 23:03:02 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v6132tlM027878
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 20:03:01 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2be2p2r44t-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 20:03:01 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:003b:0000) with ESMTP       id
 c93c6d8c5e0911e7ac9909cabd64a484-9b5358f0 for <netdev@vger.kernel.org>;        Fri,
 30 Jun 2017 20:02:58 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Created a new BPF program type, BPF_PROG_TYPE_SOCK_OPS, and a corresponding
struct that allows BPF programs of this type to access some of the
socket's fields (such as IP addresses, ports, etc.) and setting
connection parameters such as buffer sizes, initial window, SYN/SYN-ACK
RTOs, etc.

Unlike current BPF program types that expect to be called at a particular
place in the network stack code, SOCK_OPS program can be called at
different places and use an "op" field to indicate the context. There
are currently two types of operations, those whose effect is through
their return value and those whose effect is through the new
bpf_setsocketop BPF helper function.

Example operands of the first type are:
  BPF_SOCK_OPS_TIMEOUT_INIT
  BPF_SOCK_OPS_RWND_INIT
  BPF_SOCK_OPS_NEEDS_ECN

Example operands of the secont type are:
  BPF_SOCK_OPS_TCP_CONNECT_CB   
  BPF_SOCK_OPS_ACTIVE_ESTABLISHED_CB
  BPF_SOCK_OPS_PASSIVE_ESTABLISHED_CB

Current operands are only called during connection establishment so
there should not be any BPF overheads after connection establishment. The
main idea is to use connection information form both hosts, such as IP
addresses and ports to allow setting of per connection parameters to
optimize the connection's peformance.

Alghough there are already 3 mechanisms to set parameters (sysctls,
route metrics and setsockopts), this new mechanism provides some
disticnt advantages. Unlike sysctls, it can set parameters per
connection. In contrast to route metrics, it can also use port numbers
and information provided by a user level program. In addition, it could
set parameters probabilistically for evaluation purposes (i.e. do
something different on 10% of the flows and compare results with the
other 90% of the flows). Also, in cases where IPv6 addresses contain
geographic information, the rules to make changes based on the distance
(or RTT) between the hosts are much easier than route metric rules and
can be global. Finally, unlike setsockopt, it does not require
application changes and it can be updated easily at any time.

It uses the existing bpf cgroups infrastructure so the programs can be
attached per cgroup with full inheritance support. Although the bpf cgroup
framework already contains a sock related program type (BPF_PROG_TYPE_CGROUP_SOCK),
I created the new type (BPF_PROG_TYPE_SOCK_OPS) beccause the existing type
expects to be called only once during the connections's lifetime. In contrast,
the new program type will be called multiple times from different places in the
network stack code.  For example, before sending SYN and SYN-ACKs to set
an appropriate timeout, when the connection is established to set congestion
control, etc. As a result it has "op" field to specify the type of operation
requested.

This patch set also includes sample BPF programs to demostrate the differnet
features.

v2: Formatting changes, rebased to latest net-next

v3: Fixed build issues, changed socket_ops to sock_ops throught,
    fixed formatting issues, removed the syscall to load sock_ops
    program and added functionality to use existing bpf attach and
    bpf detach system calls, removed reader/writer locks in
    sock_bpfops.c (used when saving sock_ops global program)
    and fixed missing module refcount increment.

v4: Removed global sock_ops program and instead used existing cgroup bpf
    infrastructure to support a new BPF_CGROUP_ATTCH type.

v5: fixed kbuild warning happening in bpf-cgroup.h
    removed automatic converstion to host byte order from some sock_ops
      fields (ipv4 and ipv6 addresses, remote port)
    Added conversion to host byte order in some of the sample programs
    Added to sample BPF program comments about using load_sock_ops to load
    Removed is_req_sock field from bpf_sock_ops_kern and related places,
      using sk_fullsock() instead.

v6: fixes to BPF helper function setsockopt (possible NULL deferencing, etc.)

Consists of the following patches:


 include/linux/bpf-cgroup.h     |  18 +++
 include/linux/bpf_types.h      |   1 +
 include/linux/filter.h         |   9 ++
 include/net/tcp.h              |  66 ++++++++++-
 include/uapi/linux/bpf.h       |  68 +++++++++++-
 kernel/bpf/cgroup.c            |  37 ++++++
 kernel/bpf/syscall.c           |   5 +
 net/core/filter.c              | 284 +++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp.c                 |   2 +-
 net/ipv4/tcp_cong.c            |  32 ++++--
 net/ipv4/tcp_fastopen.c        |   1 +
 net/ipv4/tcp_input.c           |   9 +-
 net/ipv4/tcp_minisocks.c       |   9 +-
 net/ipv4/tcp_output.c          |  18 ++-
 samples/bpf/Makefile           |   9 ++
 samples/bpf/bpf_helpers.h      |   3 +
 samples/bpf/bpf_load.c         |  13 ++-
 samples/bpf/load_sock_ops.c    |  97 ++++++++++++++++                     
 samples/bpf/tcp_bufs_kern.c    |  86 ++++++++++++++
 samples/bpf/tcp_clamp_kern.c   | 102 +++++++++++++++++
 samples/bpf/tcp_cong_kern.c    |  83 ++++++++++++++
 samples/bpf/tcp_iw_kern.c      |  88 +++++++++++++++
 samples/bpf/tcp_rwnd_kern.c    |  69 ++++++++++++
 samples/bpf/tcp_synrto_kern.c  |  69 ++++++++++++
 tools/include/uapi/linux/bpf.h |  66 ++++++++++-
 25 files changed, 1218 insertions(+), 26 deletions(-)
