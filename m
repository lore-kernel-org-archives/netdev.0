From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 00/12] nfp: add flower app with representors
Date: Tue, 20 Jun 2017 07:51:38 +0200
Message-ID: <1497937910-32059-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:36008 "EHLO
        mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750884AbdFTFwL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 01:52:11 -0400
Received: by mail-qk0-f174.google.com with SMTP id g83so49637942qkb.3
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 22:52:10 -0700 (PDT)
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
recieved from the firmware and forwards the skb to the representor after
removing the metadata.

Control queues are used to send and receive control messages which are
used to communicate configuration information with the firmware. These
are in separate vNIC to the queues belonging to the PF netdev. The control
queues are not exposed to use-space via a netdev or any other means.

As the name implies this app is targeted at providing offload of TC flower.
That will be added by follow-up work. This patchset focuses on adding phys
port and VF representor netdevs to which flower classifiers may be attached.

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
 drivers/net/ethernet/netronome/nfp/flower/main.c   | 376 +++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_app.c       |  26 +-
 drivers/net/ethernet/netronome/nfp/nfp_app.h       |  58 +++-
 drivers/net/ethernet/netronome/nfp/nfp_app_nic.c   |  25 +-
 drivers/net/ethernet/netronome/nfp/nfp_devlink.c   |  18 +
 drivers/net/ethernet/netronome/nfp/nfp_main.c      |  42 ++-
 drivers/net/ethernet/netronome/nfp/nfp_main.h      |  11 +-
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   1 +
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  57 +++-
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  | 141 +++++---
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c  | 352 +++++++++++++++++++
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
 24 files changed, 1574 insertions(+), 93 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/cmsg.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/cmsg.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/main.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_repr.h

-- 
2.1.4
