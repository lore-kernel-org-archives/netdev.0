From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next v2 00/27] Allow passing of VLAN CFI bit through network stack
Date: Tue,  3 Jan 2017 21:52:33 +0100 (CET)
Message-ID: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:34670 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935889AbdACUwh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 15:52:37 -0500
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear NetDevs

This series removes an abuse of VLAN CFI bit in Linux networking stack.
Currently Linux always clears the bit on outgoing traffic and presents
it cleared to userspace (even via AF_PACKET/tcpdump when hw-accelerated).

This uses a new vlan_present bit in struct skbuff, and removes an assumption
that vlan_proto != 0 when VLAN tag is present.

As I can't test most of the driver changes, please look at them carefully.

The series is supposed to be bisect-friendly and that requires temporary
insertion of #define VLAN_TAG_PRESENT in BPF code to be able to split
JIT changes per architecture.

Best Regards,
Michał Mirosław

v2: rebase onto net-next

---


Michał Mirosław (27):
  net/vlan: introduce __vlan_hwaccel_clear_tag() helper
  net/vlan: introduce __vlan_hwaccel_copy_tag() helper
  ibmvnic: fix accelerated VLAN handling
  qlcnic: remove assumption that vlan_tci != 0
  i40iw: remove use of VLAN_TAG_PRESENT
  cnic: remove use of VLAN_TAG_PRESENT
  gianfar: remove use of VLAN_TAG_PRESENT
  net/hyperv: remove use of VLAN_TAG_PRESENT
  cxgb4: use __vlan_hwaccel helpers
  benet: use __vlan_hwaccel helpers
  sky2: use __vlan_hwaccel helpers
  net/core: use __vlan_hwaccel helpers
  bridge: use __vlan_hwaccel helpers
  8021q: use __vlan_hwaccel helpers
  ipv4/tunnel: use __vlan_hwaccel helpers
  nfnetlink/queue: use __vlan_hwaccel helpers
  OVS: remove use of VLAN_TAG_PRESENT
  net/skbuff: add macros for VLAN_PRESENT bit
  net/bpf_jit: ARM: split VLAN_PRESENT bit handling from VLAN_TCI
  net/bpf_jit: MIPS: split VLAN_PRESENT bit handling from VLAN_TCI
  net/bpf_jit: PPC: split VLAN_PRESENT bit handling from VLAN_TCI
  net/bpf_jit: SPARC: split VLAN_PRESENT bit handling from VLAN_TCI
  net/bpf: split VLAN_PRESENT bit handling from VLAN_TCI
  bpf_test: prepare for VLAN_TAG_PRESENT removal
  net: remove VLAN_TAG_PRESENT
  net/hyperv: enable passing of VLAN.CFI bit
  net/vlan: remove unused #define HAVE_VLAN_GET_TAG

 arch/arm/net/bpf_jit_32.c                        | 17 ++++++-----
 arch/mips/net/bpf_jit.c                          | 17 ++++++-----
 arch/powerpc/net/bpf_jit_comp.c                  | 14 ++++-----
 arch/sparc/net/bpf_jit_comp.c                    | 14 ++++-----
 drivers/infiniband/hw/cxgb4/cm.c                 |  2 +-
 drivers/infiniband/hw/i40iw/i40iw_cm.c           |  8 ++---
 drivers/net/ethernet/broadcom/cnic.c             |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c      |  4 +--
 drivers/net/ethernet/freescale/gianfar_ethtool.c |  8 ++---
 drivers/net/ethernet/ibm/ibmvnic.c               |  5 ++--
 drivers/net/ethernet/marvell/sky2.c              |  6 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c   |  8 +++--
 drivers/net/hyperv/hyperv_net.h                  |  2 +-
 drivers/net/hyperv/netvsc_drv.c                  | 14 ++++-----
 drivers/net/hyperv/rndis_filter.c                |  5 ++--
 include/linux/if_vlan.h                          | 37 +++++++++++++++++++-----
 include/linux/skbuff.h                           | 10 ++++++-
 lib/test_bpf.c                                   | 14 +++++----
 net/8021q/vlan_core.c                            |  2 +-
 net/bridge/br_netfilter_hooks.c                  | 15 ++++++----
 net/bridge/br_private.h                          |  2 +-
 net/bridge/br_vlan.c                             |  6 ++--
 net/core/dev.c                                   |  8 +++--
 net/core/filter.c                                | 17 ++++-------
 net/core/skbuff.c                                |  2 +-
 net/ipv4/ip_tunnel_core.c                        |  2 +-
 net/netfilter/nfnetlink_queue.c                  |  5 ++--
 net/openvswitch/actions.c                        | 13 ++++++---
 net/openvswitch/flow.c                           |  2 +-
 net/openvswitch/flow.h                           |  2 +-
 net/openvswitch/flow_netlink.c                   | 22 +++++++-------
 net/sched/act_vlan.c                             |  2 +-
 32 files changed, 163 insertions(+), 124 deletions(-)

-- 
2.11.0
