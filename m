From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv4 net-next 00/15] BPF hardware offload (cls_bpf for now)
Date: Thu, 15 Sep 2016 20:12:20 +0100
Message-ID: <1473966755-30106-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:33691 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751627AbcIOTOH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 15:14:07 -0400
Received: by mail-wm0-f42.google.com with SMTP id b187so4474809wme.0
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 12:14:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Dave, this set depends on bitfield.h which is sitting in the
pull request from Kalle.  I'm expecting buildbot to complain
about patch 8, please pull wireless-drivers-next before applying.

v4:
 - rename parser -> analyzer;
 - reorganize the analyzer patches a bit;
 - use bitfield.h directly.

--- merge blurb:
In the last year a lot of progress have been made on offloading
simpler TC classifiers.  There is also growing interest in using
BPF for generic high-speed packet processing in the kernel.
It seems beneficial to tie those two trends together and think
about hardware offloads of BPF programs.  This patch set presents
such offload to Netronome smart NICs.  cls_bpf is extended with
hardware offload capabilities and NFP driver gets a JIT translator
which in presence of capable firmware can be used to offload
the BPF program onto the card.

BPF JIT implementation is not 100% complete (e.g. missing instructions)
but it is functional.  Encouragingly it should be possible to
offload most (if not all) advanced BPF features onto the NIC - 
including packet modification, maps, tunnel encap/decap etc.

Example of basic tests I used:
  __section_cls_entry
  int cls_entry(struct __sk_buff *skb)
  {
	if (load_byte(skb, 0) != 0x0)
		return 0;

	if (load_byte(skb, 4) != 0x1)
		return 0;

	skb->mark = 0xcafe;

	if (load_byte(skb, 50) != 0xff)
		return 0;

	return ~0U;
  }

Above code can be compiled with Clang and loaded like this:
# ethtool -K p1p1 hw-tc-offload on
# tc qdisc add dev p1p1 ingress
# tc filter add dev p1p1 parent ffff:  bpf obj prog.o action drop

This set implements the basic transparent offload, the skip_{sw,hw}
flags and reporting statistics for cls_bpf.

Jakub Kicinski (15):
  net: cls_bpf: add hardware offload
  net: cls_bpf: limit hardware offload by software-only flag
  net: cls_bpf: add support for marking filters as hardware-only
  bpf: don't (ab)use instructions to store state
  bpf: expose internal verfier structures
  bpf: enable non-core use of the verfier
  bpf: recognize 64bit immediate loads as consts
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
 .../net/ethernet/netronome/nfp/nfp_bpf_verifier.c  |  160 ++
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   47 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  134 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |   51 +-
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |   12 +
 .../net/ethernet/netronome/nfp/nfp_net_offload.c   |  291 ++++
 .../net/ethernet/netronome/nfp/nfp_netvf_main.c    |    2 +-
 include/linux/bpf_verifier.h                       |   89 +
 include/linux/netdevice.h                          |    2 +
 include/net/pkt_cls.h                              |   16 +
 include/uapi/linux/pkt_cls.h                       |    1 +
 kernel/bpf/verifier.c                              |  384 +++--
 net/sched/act_mirred.c                             |    8 +
 net/sched/cls_bpf.c                                |  117 +-
 18 files changed, 3376 insertions(+), 206 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_asm.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_bpf.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_bpf_verifier.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
 create mode 100644 include/linux/bpf_verifier.h

-- 
1.9.1
