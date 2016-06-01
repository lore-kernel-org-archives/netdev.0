From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 00/12] BPF hardware offload via cls_bpf
Date: Wed,  1 Jun 2016 17:50:02 +0100
Message-ID: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34421 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157AbcFAQvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 12:51:43 -0400
Received: by mail-wm0-f42.google.com with SMTP id z87so29624003wmh.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 09:51:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

In recent months a lot of progress have been made on offloading
simpler TC classifiers.  There is also growing interest in using
BPF for generic high-speed packet processing in the kernel.
It seems beneficial to tie those two trends together and think
about hardware offloads of BPF programs.  This patch set presents
such offload to Netronome smart NICs.  cls_bpf is extended with
hardware offload capabilities and NFP driver gets a JIT translator
which in presence of capable firmware can be used to offload
the BPF program onto the card.

BPF JIT implementation is not 100% complete (e.g. missing instructions)
but it is functional - in fact I implemented only bits which clang/cBPF
used in my test programs.  Encouragingly it should be possible to
offload most (if not all) advanced BPF features onto the NIC - 
including packet modification, maps, tunnel encap/decap etc.

Examples of tests I used:

Basic eBPF/C/clang apps:
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

tcpdump generated filters, for instance:
  dst 10.1.255.255 and \
  tcp and \
  (port 90 or port 91) and \
  tcp[tcpflags] & tcp-syn != 0


First patch is not really related but others depend on it, I hope to
post it separately soon.


Jakub Kicinski (12):
  add basic register-field manipulation macros
  net: cls_bpf: add hardware offload
  net: cls_bpf: limit hardware offload by software-only flag
  net: cls_bpf: add support for marking filters as hardware-only
  nfp: add BPF to NFP code translator
  nfp: add hardware cls_bpf offload
  nfp: add skb mark support to the bpf offload
  net: cls_bpf: allow offloaded filters to update stats
  nfp: report statistics of offloaded filters
  nfp: bpf: optimize register init
  nfp: bpf: add register rename
  nfp: bpf: add denser mode of execution

 drivers/net/ethernet/netronome/nfp/Makefile        |    4 +-
 drivers/net/ethernet/netronome/nfp/nfp_asm.h       |  191 ++++
 drivers/net/ethernet/netronome/nfp/nfp_bpf.h       |  136 +++
 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c   | 1027 ++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   34 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |   41 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |   21 +-
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |    3 +
 .../net/ethernet/netronome/nfp/nfp_net_offload.c   |  256 +++++
 include/linux/bitfield.h                           |   89 ++
 include/linux/netdevice.h                          |    2 +
 include/net/pkt_cls.h                              |   16 +
 include/uapi/linux/pkt_cls.h                       |    1 +
 net/sched/cls_bpf.c                                |  115 ++-
 14 files changed, 1928 insertions(+), 8 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_asm.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_bpf.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
 create mode 100644 include/linux/bitfield.h

-- 
1.9.1
