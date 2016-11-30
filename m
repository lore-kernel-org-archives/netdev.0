From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v6 0/6] net: Add bpf support for sockets
Date: Wed, 30 Nov 2016 10:16:44 -0800
Message-ID: <1480529810-25850-1-git-send-email-dsa@cumulusnetworks.com>
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34317 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753834AbcK3SRW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 13:17:22 -0500
Received: by mail-pf0-f179.google.com with SMTP id c4so40398501pfb.1
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 10:16:56 -0800 (PST)
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

This patchset also exports the socket family, type and protocol as
read-only allowing bpf filters to deny a process in a cgroup the ability
to open specific types of AF_INET or AF_INET6 sockets.

v6
- add export of socket family, type and protocol

David Ahern (6):
  bpf: Refactor cgroups code in prep for new type
  bpf: Add new cgroup attach type to enable sock modifications
  samples: bpf: add userspace example for modifying sk_bound_dev_if
  bpf: Add support for reading socket family, type, protocol
  samples/bpf: Update bpf loader for cgroup section names
  samples/bpf: add userspace example for prohibiting sockets

 include/linux/bpf-cgroup.h      |  60 ++++++++++++++---------
 include/net/sock.h              |  15 ++++++
 include/uapi/linux/bpf.h        |   9 ++++
 kernel/bpf/cgroup.c             |  43 +++++++++++++++--
 kernel/bpf/syscall.c            |  33 +++++++------
 net/core/filter.c               | 104 ++++++++++++++++++++++++++++++++++++++++
 net/ipv4/af_inet.c              |  12 ++++-
 net/ipv6/af_inet6.c             |   8 ++++
 samples/bpf/Makefile            |   6 +++
 samples/bpf/bpf_load.c          |  14 ++++--
 samples/bpf/bpf_load.h          |   1 +
 samples/bpf/sock_flags_kern.c   |  37 ++++++++++++++
 samples/bpf/test_cgrp2_sock.c   |  83 ++++++++++++++++++++++++++++++++
 samples/bpf/test_cgrp2_sock.sh  |  47 ++++++++++++++++++
 samples/bpf/test_cgrp2_sock2.c  |  66 +++++++++++++++++++++++++
 samples/bpf/test_cgrp2_sock2.sh |  81 +++++++++++++++++++++++++++++++
 16 files changed, 573 insertions(+), 46 deletions(-)
 create mode 100644 samples/bpf/sock_flags_kern.c
 create mode 100644 samples/bpf/test_cgrp2_sock.c
 create mode 100755 samples/bpf/test_cgrp2_sock.sh
 create mode 100644 samples/bpf/test_cgrp2_sock2.c
 create mode 100755 samples/bpf/test_cgrp2_sock2.sh

-- 
2.1.4
