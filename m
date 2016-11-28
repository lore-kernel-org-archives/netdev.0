From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v3 0/3] net: Add bpf support to set sk_bound_dev_if
Date: Mon, 28 Nov 2016 07:48:47 -0800
Message-ID: <1480348130-31354-1-git-send-email-dsa@cumulusnetworks.com>
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:32939 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754473AbcK1Ps5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 10:48:57 -0500
Received: by mail-pg0-f53.google.com with SMTP id 3so58317560pgd.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 07:48:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recently added VRF support in Linux leverages the bind-to-device
API for programs to specify an L3 domain for a socket. While
SO_BINDTODEVICE has been around for ages, not every ipv4/ipv6 capable
program has support for it. Even for those programs that do support it,
the API requires processes to be started as root (CAP_NET_RAW) which
is not desirable from a general security perspective.

This patch set leverages Daniel Mack's work to attach bpf programs to
a cgroup to provide a capability to set sk_bound_dev_if for all
AF_INET{6} sockets opened by a process in a cgroup when the sockets
are allocated.

For example:
 1. configure vrf (e.g., using ifupdown2)
        auto eth0
        iface eth0 inet dhcp
            vrf mgmt

        auto mgmt
        iface mgmt
            vrf-table auto

 2. configure cgroup
        mount -t cgroup2 none /tmp/cgroupv2
        mkdir /tmp/cgroupv2/mgmt
        test_cgrp2_sock /tmp/cgroupv2/mgmt 15

 3. set shell into cgroup (e.g., can be done at login using pam)
        echo $$ >> /tmp/cgroupv2/mgmt/cgroup.procs

At this point all commands run in the shell (e.g, apt) have sockets
automatically bound to the VRF (see output of ss -ap 'dev == <vrf>'),
including processes not running as root.

This capability enables running any program in a VRF context and is key
to deploying Management VRF, a fundamental configuration for networking
gear, with any Linux OS installation.

David Ahern (3):
  bpf: Refactor cgroups code in prep for new type
  bpf: Add new cgroup attach type to enable sock modifications
  samples: bpf: add userspace example for modifying sk_bound_dev_if

 include/linux/bpf-cgroup.h    | 11 ++++++
 include/linux/filter.h        |  2 +-
 include/uapi/linux/bpf.h      |  6 ++++
 kernel/bpf/cgroup.c           | 36 ++++++++++++++++---
 kernel/bpf/syscall.c          | 33 +++++++++--------
 net/core/filter.c             | 65 +++++++++++++++++++++++++++++++++
 net/ipv4/af_inet.c            | 12 ++++++-
 net/ipv6/af_inet6.c           |  8 +++++
 samples/bpf/Makefile          |  2 ++
 samples/bpf/test_cgrp2_sock.c | 83 +++++++++++++++++++++++++++++++++++++++++++
 10 files changed, 237 insertions(+), 21 deletions(-)
 create mode 100644 samples/bpf/test_cgrp2_sock.c

-- 
2.1.4
