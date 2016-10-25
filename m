From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 0/3] Add bpf support to set sk_bound_dev_if
Date: Tue, 25 Oct 2016 15:30:10 -0700
Message-ID: <1477434613-3169-1-git-send-email-dsa@cumulusnetworks.com>
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35447 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933623AbcJYWbZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 18:31:25 -0400
Received: by mail-pf0-f172.google.com with SMTP id s8so126536524pfj.2
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 15:31:25 -0700 (PDT)
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

David Ahern (3):
  bpf: Refactor cgroups code in prep for new type
  bpf: Add new cgroups prog type to enable sock modifications
  samples: bpf: add userspace example for modifying sk_bound_dev_if

 include/linux/filter.h        |  2 +-
 include/uapi/linux/bpf.h      | 15 +++++++
 kernel/bpf/cgroup.c           | 36 ++++++++++++++---
 kernel/bpf/syscall.c          | 32 +++++++++------
 net/core/filter.c             | 92 +++++++++++++++++++++++++++++++++++++++++++
 net/core/sock.c               |  7 ++++
 samples/bpf/Makefile          |  2 +
 samples/bpf/bpf_helpers.h     |  2 +
 samples/bpf/test_cgrp2_sock.c | 84 +++++++++++++++++++++++++++++++++++++++
 9 files changed, 253 insertions(+), 19 deletions(-)
 create mode 100644 samples/bpf/test_cgrp2_sock.c

-- 
2.1.4
