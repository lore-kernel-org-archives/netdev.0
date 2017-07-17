From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 00/12] Implement XDP bpf_redirect
Date: Mon, 17 Jul 2017 09:26:02 -0700
Message-ID: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@fb.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, brouer@redhat.com, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34875 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751293AbdGQQ0T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 12:26:19 -0400
Received: by mail-pf0-f196.google.com with SMTP id q85so20091251pfq.2
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 09:26:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds two new XDP helper routines bpf_redirect() and
bpf_redirect_map(). The first variant bpf_redirect() is meant
to be used the same way it is currently being used by the cls_bpf
classifier. An xdp packet will be redirected immediately when this
is called.

The other variant bpf_redirect_map(map, key, flags) uses a new
map type called devmap. A devmap uses integers as keys and
net_devices as values. The user provies key/ifindex pairs to
update the map with new net_devices. This provides two benefits
over the normal variant 'bpf_redirect()'. First the datapath
bpf program is abstracted away from using hard-coded ifindex
values. Allowing a single bpf program to be run any many different
environments. Second, and perhaps more important, the map enables 
batching packet transmits. The map plus small driver changes
allows for batching all send requests across a NAPI poll loop.
This allows driver writers to optimize the driver xmit path
and only call expensive operations once for a batch of xdp_buffs.

The devmap was designed to support possible future work for
multicast and broadcast as follow-up patches.

To see, in more detail, how to leverage the new helpers and
map from the userspace side please review these two patches,

  xdp: sample program for new bpf_redirect helper
  xdp: bpf redirect with map sample program

Performance numbers provided by Jesper are the following, tested
using the ixgbe driver with CPU E5-1650 v4 @ 3.60GHz:

13,939,674 pkt/s = XDP_DROP without touching memory
14,290,650 pkt/s = xdp1: XDP_DROP with reading packet data
13,221,812 pkt/s = xdp2: XDP_TX   with swap mac (writes into pkt)
 7,596,576 pkt/s = xdp_redirect:    XDP_REDIRECT with swap mac (like XDP_TX)
13,058,435 pkt/s = xdp_redirect_map:XDP_REDIRECT with swap mac + devmap

A big thanks to everyone who helped with this series. Jesper
provided fixes, debugging, code review, performance benchmarks!
Daniel provided lots of useful feedback and code review. And last
but not least Andy provided useful feedback related to supporting
additional drivers, generic xdp implementation, testing, etc. Any
other feedback is welcome but I believe at this point these are
ready to be merged!

Whats left... get the rest of the drivers developers to implement
this in all the drivers.

---

John Fastabend (12):
      ixgbe: NULL xdp_tx rings on resource cleanup
      net: xdp: support xdp generic on virtual devices
      xdp: add bpf_redirect helper function
      xdp: sample program for new bpf_redirect helper
      net: implement XDP_REDIRECT for xdp generic
      ixgbe: add initial support for xdp redirect
      xdp: add trace event for xdp redirect
      bpf: add devmap, a map for storing net device references
      bpf: add bpf_redirect_map helper routine
      xdp: Add batching support to redirect map
      net: add notifier hooks for devmap bpf map
      xdp: bpf redirect with map sample program


 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  |    8 
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   63 ++++
 include/linux/bpf.h                           |    5 
 include/linux/bpf_types.h                     |    3 
 include/linux/filter.h                        |   14 +
 include/linux/netdevice.h                     |   11 +
 include/trace/events/xdp.h                    |   31 ++
 include/uapi/linux/bpf.h                      |   10 +
 kernel/bpf/Makefile                           |    3 
 kernel/bpf/devmap.c                           |  431 +++++++++++++++++++++++++
 kernel/bpf/verifier.c                         |   12 +
 net/core/dev.c                                |  226 ++++++++-----
 net/core/filter.c                             |  170 ++++++++++
 samples/bpf/Makefile                          |    8 
 samples/bpf/xdp_redirect_kern.c               |   81 +++++
 samples/bpf/xdp_redirect_map_kern.c           |   83 +++++
 samples/bpf/xdp_redirect_map_user.c           |  105 ++++++
 samples/bpf/xdp_redirect_user.c               |  102 ++++++
 tools/testing/selftests/bpf/bpf_helpers.h     |    2 
 tools/testing/selftests/bpf/test_maps.c       |   15 +
 20 files changed, 1282 insertions(+), 101 deletions(-)
 create mode 100644 kernel/bpf/devmap.c
 create mode 100644 samples/bpf/xdp_redirect_kern.c
 create mode 100644 samples/bpf/xdp_redirect_map_kern.c
 create mode 100644 samples/bpf/xdp_redirect_map_user.c
 create mode 100644 samples/bpf/xdp_redirect_user.c
