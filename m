From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFCv2 00/16] BPF hardware offload (cls_bpf for now)
Date: Fri, 26 Aug 2016 19:05:59 +0100
Message-ID: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38503 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754010AbcHZSM4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 14:12:56 -0400
Received: by mail-wm0-f47.google.com with SMTP id o80so3454352wme.1
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 11:12:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This is an updated version of BPF offload set.

Biggest change from the previous version is reusing the verifier
to check the exit codes and pointer types.  The change to the
verifier is not very invasive and my gut feeling is that adding
simple hooks to the core verifier is cleaner than reimplementing
parsing in every advanced translator.  It may also open a path
to some clever re-interpretation of programs for XDP to adapt 
to hardware metadata details.

Item number two on the feature list is redirect to port from
which packet came (which will be needed for XDP soon).

Last but not least direct action support.  The set of return
codes is limited.  One thing to note there is that we can't
trivially support TC_ACT_OK now because there is no way
to tell TC whether packet passed the filter because of OK or
UNSPEC.  Perhaps there are ways of implementing this, it's
definitely a topic for netdev 1.2 discussion.

I decided to keep legacy mode just because it's easy and I find
it useful for testing things :)

Another item on the todo list is to think about the interface
stats.  Should the dropped/redirected packets appear there?
I am providing TC stats only today but interface stats are not
incremented.  I'll rework the stats once Jiri's SW/HW stat set
lands.

I'm still posting as an RFC because I'm waiting for patch 1
to be merged via wireless-drivers-next - which will also make
this set 15 patches long :)


Jakub Kicinski (16):
  add basic register-field manipulation macros
  net: cls_bpf: add hardware offload
  net: cls_bpf: limit hardware offload by software-only flag
  net: cls_bpf: add support for marking filters as hardware-only
  bpf: recognize 64bit immediate loads as consts
  bpf: verifier: recognize rN ^ rN as load of 0
  bpf: enable non-core use of the verfier
  bpf: export bpf_prog_clone functions
  nfp: add BPF to NFP code translator
  nfp: bpf: add hardware bpf offload
  net: cls_bpf: allow offloaded filters to update stats
  net: bpf: allow offloaded filters to update stats
  nfp: bpf: add packet marking support
  net: act_mirred: allow statistic updates from offloaded actions
  nfp: bpf: add support for legacy redirect action
  nfp: bpf: add offload of TC direct action mode

 drivers/net/ethernet/netronome/nfp/Makefile        |    7 +
 drivers/net/ethernet/netronome/nfp/nfp_asm.h       |  233 +++
 drivers/net/ethernet/netronome/nfp/nfp_bpf.h       |  212 +++
 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c   | 1816 ++++++++++++++++++++
 .../net/ethernet/netronome/nfp/nfp_bpf_verifier.c  |  166 ++
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   49 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |   81 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |   53 +-
 .../net/ethernet/netronome/nfp/nfp_net_offload.c   |  291 ++++
 include/linux/bitfield.h                           |   93 +
 include/linux/bpf.h                                |    4 +
 include/linux/bpf_parser.h                         |   84 +
 include/linux/bug.h                                |    3 +
 include/linux/netdevice.h                          |    2 +
 include/net/pkt_cls.h                              |   16 +
 include/uapi/linux/pkt_cls.h                       |    1 +
 kernel/bpf/core.c                                  |    8 +-
 kernel/bpf/verifier.c                              |  135 +-
 net/sched/act_mirred.c                             |    8 +
 net/sched/cls_bpf.c                                |  116 +-
 20 files changed, 3299 insertions(+), 79 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_asm.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_bpf.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_bpf_verifier.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
 create mode 100644 include/linux/bitfield.h
 create mode 100644 include/linux/bpf_parser.h

-- 
1.9.1
