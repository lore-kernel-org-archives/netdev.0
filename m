From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v2 net-next 0/5] Add bpf support to set sk_bound_dev_if
Date: Wed, 26 Oct 2016 17:58:37 -0700
Message-ID: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36802 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932388AbcJ0A6u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 20:58:50 -0400
Received: by mail-pf0-f182.google.com with SMTP id e6so6031866pfk.3
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 17:58:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recently added VRF support in Linux leverages the bind-to-device
API for programs to specify an L3 domain for a socket. While
SO_BINDTODEVICE has been around for ages, not every ipv4/ipv6 capable
program has support for it. Even for those programs that do support it,
the API requires processes to be started as root (CAP_NET_RAW) which
is not desirable from a general security perspective.

This patch set leverages Daniel Mack's work to attach bpf programs to
a cgroup:

    https://www.mail-archive.com/netdev@vger.kernel.org/msg134028.html

to provide a capability to set sk_bound_dev_if for all AF_INET{6}
sockets opened by a process in a cgroup when the sockets are allocated.

This capability enables running any program in a VRF context and is key
to deploying Management VRF, a fundamental configuration for networking
gear, with any Linux OS installation.

v2
- addressed Daniel's comments: dropped the bpf_sock_store_u32 helper
  and used bpf_prog_run_save_cb on the code move

- picked up Mickaël Salaün's subtype patch with a few small tweaks

- removed new prog type in favor of a subtype on the BPF_PROG_TYPE_CGROUP
  from Daniel Mack's patch set

- moved the filter hook from sk_alloc to inet{6}_create


David Ahern (5):
  bpf: Refactor cgroups code in prep for new type
  bpf: Add eBPF program subtype and is_valid_subtype() verifier
  bpf: Add new cgroup attach type to enable sock modifications
  samples: bpf: Add prog_subtype to bpf_prog_load
  samples: bpf: add userspace example for modifying sk_bound_dev_if

 include/linux/bpf.h             |   7 ++-
 include/linux/filter.h          |   3 +-
 include/uapi/linux/bpf.h        |  15 +++++-
 kernel/bpf/cgroup.c             |  36 +++++++++++--
 kernel/bpf/syscall.c            |  11 ++--
 kernel/bpf/verifier.c           |  10 +++-
 kernel/trace/bpf_trace.c        |  16 ++++--
 net/core/filter.c               | 115 +++++++++++++++++++++++++++++++++-------
 net/ipv4/af_inet.c              |   4 ++
 net/ipv6/af_inet6.c             |   3 ++
 samples/bpf/Makefile            |   2 +
 samples/bpf/bpf_load.c          |   2 +-
 samples/bpf/fds_example.c       |   2 +-
 samples/bpf/libbpf.c            |   5 +-
 samples/bpf/libbpf.h            |   3 +-
 samples/bpf/sock_example.c      |   2 +-
 samples/bpf/test_cgrp2_attach.c |   4 +-
 samples/bpf/test_cgrp2_sock.c   |  84 +++++++++++++++++++++++++++++
 18 files changed, 280 insertions(+), 44 deletions(-)
 create mode 100644 samples/bpf/test_cgrp2_sock.c

-- 
2.1.4
