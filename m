From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 00/16] nfp: ctrl vNIC
Date: Mon,  5 Jun 2017 17:01:41 -0700
Message-ID: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33264 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751192AbdFFACP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 20:02:15 -0400
Received: by mail-pf0-f174.google.com with SMTP id 83so32350952pfr.0
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 17:02:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series adds the ability to use one vNIC as a control channel
for passing messages to and from the application firmware.  The
implementation restructures the existing netdev vNIC code to be able
to deal with nfp_nets with netdev pointer set to NULL.  Control vNICs
are not visible to userspace (other than for dumping ring state), and
since they don't have netdevs we use a tasklet for RX and simple skb 
list for TX queuing.

Due to special status of the control vNIC we have to reshuffle the
init code a bit to make sure control vNIC will be fully brought up
(and therefore communication with app FW can happen) before any netdev
or port is visible to user space.

FW will designate which vNIC is supposed to be used as control one
by setting _pf%u_net_ctrl_bar symbol.  Some FWs depend on metadata
being prepended to control message, some prefer to look at queue ID
to decide that something is a control message.  Our implementation
can cater to both.

First two users of this code will be eBPF maps and flower offloads.

Jakub Kicinski (16):
  nfp: reorder open and close functions
  nfp: split out the allocation part of open
  nfp: reuse ring free code on close
  nfp: move nfp_net_vecs_init()
  nfp: prepare print macros for use without netdev
  nfp: make sure debug accesses don't depend on netdevs
  nfp: allow allocation and initialization of netdev-less vNICs
  nfp: prepare config and enable for working without netdevs
  nfp: add control vNIC datapath
  nfp: make vNIC ctrl memory mapping function reusable
  nfp: map all queue controllers at once
  nfp: don't clutter init code passing fw_ver around
  nfp: slice the netdev spawning function
  nfp: allow non-equal distribution of IRQs
  nfp: create control vNICs and wire up rx/tx
  nfp: advertise support for NFD ABI 0.5

 drivers/net/ethernet/netronome/nfp/nfp_app.c       |  18 +
 drivers/net/ethernet/netronome/nfp/nfp_app.h       |  55 ++
 drivers/net/ethernet/netronome/nfp/nfp_main.h      |  13 +-
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  64 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 709 +++++++++++++++------
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |   3 +
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |   9 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  | 365 ++++++-----
 .../net/ethernet/netronome/nfp/nfp_netvf_main.c    |   4 +-
 9 files changed, 872 insertions(+), 368 deletions(-)

-- 
2.11.0
