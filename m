From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 00/12] Implement XDP bpf_redirect vairants
Date: Fri, 07 Jul 2017 10:34:17 -0700
Message-ID: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, john.fastabend@gmail.com, andy@greyhouse.net,
        daniel@iogearbox.net, ast@fb.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33421 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750726AbdGGRee (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 13:34:34 -0400
Received: by mail-pg0-f66.google.com with SMTP id u62so4806764pgb.0
        for <netdev@vger.kernel.org>; Fri, 07 Jul 2017 10:34:34 -0700 (PDT)
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

The devmap was designed with possible future work to support
multicast and broadcast as following patches.

To see, in more detail, how to leverage the new helpers and
map from the userspace side please review these two patches,

  xdp: sample program for new bpf_redirect helper
  xdp: bpf redirect with map sample program

I'm sending this as an RFC now because (a) the merge window
is closed so it seems like a good time to get feedback and
(b) I'm currently doing a last round of testing to ensure all
the features are still working after latest revisions as well
as doing a final review.

Any feedback would be welcome. Thanks to Jesper, Andy, and
Daniel for all their input, patches, fixes, testing, review, etc.
so far it is very much appreciated!

Thanks,
John

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
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   60 +++
 include/linux/bpf.h                           |    5 
 include/linux/bpf_types.h                     |    3 
 include/linux/filter.h                        |   14 +
 include/linux/netdevice.h                     |   11 +
 include/trace/events/xdp.h                    |   31 ++
 include/uapi/linux/bpf.h                      |   10 +
 kernel/bpf/Makefile                           |    3 
 kernel/bpf/devmap.c                           |  431 +++++++++++++++++++++++++
 kernel/bpf/verifier.c                         |   14 +
 net/core/dev.c                                |  226 ++++++++-----
 net/core/filter.c                             |  172 ++++++++++
 samples/bpf/Makefile                          |    8 
 samples/bpf/bpf_helpers.h                     |    2 
 samples/bpf/xdp_redirect_kern.c               |   81 +++++
 samples/bpf/xdp_redirect_map_kern.c           |   83 +++++
 samples/bpf/xdp_redirect_map_user.c           |  105 ++++++
 samples/bpf/xdp_redirect_user.c               |  102 ++++++
 tools/testing/selftests/bpf/test_maps.c       |   15 +
 20 files changed, 1283 insertions(+), 101 deletions(-)
 create mode 100644 kernel/bpf/devmap.c
 create mode 100644 samples/bpf/xdp_redirect_kern.c
 create mode 100644 samples/bpf/xdp_redirect_map_kern.c
 create mode 100644 samples/bpf/xdp_redirect_map_user.c
 create mode 100644 samples/bpf/xdp_redirect_user.c
