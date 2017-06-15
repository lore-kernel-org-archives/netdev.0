From: Lawrence Brakmo <brakmo@fb.com>
Subject: [RFC PATCH net-next v2 00/15] bpf: BPF support for socket ops
Date: Thu, 15 Jun 2017 13:08:29 -0700
Message-ID: <20170615200844.2752485-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58441 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751926AbdFOUIv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 16:08:51 -0400
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5FK3qwJ005143
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 13:08:50 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b3v6g126w-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 13:08:50 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 720792c6520611e7a31e0002c9931860-6f378f0 for <netdev@vger.kernel.org>; Thu,
 15 Jun 2017 13:08:49 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Created a new BPF program type, BPF_PROG_TYPE_SOCKET_OPS, and a corresponding
struct that allows BPF programs of this type to access some of the
socket's fields (such as IP addresses, ports, etc.) and setting
connection parameters such as buffer sizes, initial window, SYN/SYN-ACK
RTOs, etc.

Unlike current BPF program types that expect to be called at a particular
place in the network stack code, SOCKET_OPS program can be called at
different places and use an "op" field to indicate the context. There
are currently two types of operations, those whose effect is through
their return value and those whose effect is through the new
bpf_setsocketop BPF helper function.

Example operands of the first type are:
  BPF_SOCKET_OPS_TIMEOUT_INIT
  BPF_SOCKET_OPS_RWND_INIT
  BPF_SOCKET_OPS_NEEDS_ECN

Example operands of the secont type are:
  BPF_SOCKET_OPS_TCP_CONNECT_CB
  BPF_SOCKET_OPS_ACTIVE_ESTABLISHED_CB
  BPF_SOCKET_OPS_PASSIVE_ESTABLISHED_CB

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

Currently there is functionality to load one global BPF program of this
type but I plan to add support for loading per cgroup socket ops BPF
programs in the near future. When that is done, the global program could
be called when a cgroup has no program associated with it.

One question is whether I should add this functionality into David Ahern's
BPF_PROG_TYPE_CGROUP_SOCK or create a new cgroup bpf type. Whereas the
current cgroup_sock type expects to be called only once during a connection's
lifetime, the new socket_ops type could be called multipe times. My preference
is to define a new cgroup BPF program type (BPF_PROG_TYPE_CGROUP_SOCKET_OPS)

This patche also includes sample BPF programs to demostrate the differnet
features.

v2: Formatting changes, rebased to latest net-next

Consists of the following patches:

[RFC PATCH net-next v2 01/15] bpf: BPF support for socket ops
[RFC PATCH net-next v2 02/15] bpf: program to load socketops BPF
[RFC PATCH net-next v2 03/15] bpf: Support for per connection 
[RFC PATCH net-next v2 04/15] bpf: Sample bpf program to set
[RFC PATCH net-next v2 05/15] bpf: Support for setting initial
[RFC PATCH net-next v2 06/15] bpf: Sample bpf program to set initial
[RFC PATCH net-next v2 07/15] bpf: Add setsockopt helper function to
[RFC PATCH net-next v2 08/15] bpf: Add TCP connection BPF callbacks
[RFC PATCH net-next v2 09/15] bpf: Sample BPF program to set buffer
[RFC PATCH net-next v2 10/15] bpf: Add support for changing
[RFC PATCH net-next v2 11/15] bpf: Sample BPF program to set
[RFC PATCH net-next v2 12/15] bpf: Adds support for setting initial
[RFC PATCH net-next v2 13/15] bpf: Sample BPF program to set initial
[RFC PATCH net-next v2 14/15] bpf: Adds support for setting sndcwnd
[RFC PATCH net-next v2 15/15] bpf: Sample bpf program to set sndcwnd

 include/linux/bpf.h           |   6 ++
 include/linux/bpf_types.h     |   1 +
 include/linux/filter.h        |  10 ++
 include/net/tcp.h             |  57 ++++++++++-
 include/uapi/linux/bpf.h      |  66 ++++++++++++-
 kernel/bpf/syscall.c          |   2 +
 net/core/Makefile             |   3 +-
 net/core/filter.c             | 258 ++++++++++++++++++++++++++++++++++++++++++++++++++
 net/core/sock_bpfops.c        |  67 +++++++++++++
 net/ipv4/tcp.c                |   2 +-
 net/ipv4/tcp_cong.c           |  15 ++-
 net/ipv4/tcp_fastopen.c       |   1 +
 net/ipv4/tcp_input.c          |  10 +-
 net/ipv4/tcp_minisocks.c      |   9 +-
 net/ipv4/tcp_output.c         |  18 +++-
 samples/bpf/Makefile          |   9 ++
 samples/bpf/bpf_helpers.h     |   3 +
 samples/bpf/bpf_load.c        |  13 ++-
 samples/bpf/tcp_bpf.c         |  81 ++++++++++++++++
 samples/bpf/tcp_bufs_kern.c   |  71 ++++++++++++++
 samples/bpf/tcp_clamp_kern.c  |  88 +++++++++++++++++
 samples/bpf/tcp_cong_kern.c   |  68 +++++++++++++
 samples/bpf/tcp_iw_kern.c     |  73 ++++++++++++++
 samples/bpf/tcp_rwnd_kern.c   |  55 +++++++++++
 samples/bpf/tcp_synrto_kern.c |  54 +++++++++++
 25 files changed, 1019 insertions(+), 21 deletions(-)
