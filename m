From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v3 00/12] nfp: add flower app with representors
Date: Fri, 23 Jun 2017 22:11:57 +0200
Message-ID: <1498248729-375-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f169.google.com ([209.85.128.169]:34192 "EHLO
        mail-wr0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754804AbdFWUMW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 16:12:22 -0400
Received: by mail-wr0-f169.google.com with SMTP id 77so79604002wrb.1
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2017 13:12:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this series adds a flower app to the NFP driver.
It initialises four types of netdevs:

* PF netdev - lower-device for communication of packets to device
* PF representor netdev
* VF representor netdevs
* Phys port representor netdevs

The PF netdev acts as a lower-device which sends and receives packets to
and from the firmware. The representors act as upper-devices. For TX
representors attach a metadata dst to the skb which is used by the PF
netdev to prepend metadata to the packet before forwarding the firmware. On
RX the PF netdev looks up the representor based on the prepended metadata
received from the firmware and forwards the skb to the representor after
removing the metadata.

Control queues are used to send and receive control messages which are
used to communicate configuration information with the firmware. These
are in separate vNIC to the queues belonging to the PF netdev. The control
queues are not exposed to use-space via a netdev or any other means.

The first 9 patches of this series provide app-independent infrastructure
to instantiate representors and the remaining 3 patches provide an app
which uses this infrastructure.

As the name implies this app is targeted at providing offload of TC flower.
Flower offload - allowing classifiers to be attached to representor netdevs
- is intended to be provided by follow-up patches at which point it will
become the dominant feature of the app.

Minor changes since v2 noted in changelogs of individual patches.
Review of v1 and v2 of this patchset have been addressed either
through discussion on-list or changes in this patchset.


Jakub Kicinski (3):
  net: store port/representator id in metadata_dst
  nfp: devlink add support for getting eswitch mode
  nfp: move physical port init into a helper

Simon Horman (9):
  nfp: map mac_stats and vf_cfg BARs
  nfp: general representor implementation
  nfp: add stats and xmit helpers for representors
  nfp: app callbacks for SRIOV
  nfp: provide nfp_port to of nfp_net_get_mac_addr()
  nfp: add support for tx/rx with metadata portid
  nfp: add support for control messages for flower app
  nfp: add flower app
  nfp: add VF and PF representors to flower app

 drivers/net/ethernet/netronome/nfp/Makefile        |   3 +
 drivers/net/ethernet/netronome/nfp/flower/cmsg.c   | 159 +++++++++
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h   | 116 +++++++
 drivers/net/ethernet/netronome/nfp/flower/main.c   | 375 +++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_app.c       |  26 +-
 drivers/net/ethernet/netronome/nfp/nfp_app.h       |  58 +++-
 drivers/net/ethernet/netronome/nfp/nfp_app_nic.c   |  25 +-
 drivers/net/ethernet/netronome/nfp/nfp_devlink.c   |  18 +
 drivers/net/ethernet/netronome/nfp/nfp_main.c      |  42 ++-
 drivers/net/ethernet/netronome/nfp/nfp_main.h      |  11 +-
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   1 +
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  57 +++-
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  | 147 +++++---
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c  | 353 +++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.h  | 120 +++++++
 drivers/net/ethernet/netronome/nfp/nfp_port.c      |  25 ++
 drivers/net/ethernet/netronome/nfp/nfp_port.h      |  63 ++++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h   |   2 +
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c   |   5 +-
 include/net/dst_metadata.h                         |  41 ++-
 net/core/dst.c                                     |  15 +-
 net/core/filter.c                                  |   1 +
 net/ipv4/ip_tunnel_core.c                          |   6 +-
 net/openvswitch/flow_netlink.c                     |   4 +-
 24 files changed, 1577 insertions(+), 96 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/cmsg.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/cmsg.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/main.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_repr.h

-- 
2.1.4
