From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 00/13] nfp: XDP adjust head support
Date: Fri, 10 Mar 2017 10:38:26 -0800
Message-ID: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36119 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755050AbdCJSjY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:39:24 -0500
Received: by mail-pf0-f182.google.com with SMTP id o126so44878137pfb.3
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 10:39:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series adds support for XDP adjust head.  Bulk of the code
is actually just paying technical debt.  On reconfiguration request
nfp was allocating new resources separately leaving device running
with the existing set of rings.  We used to manage the new resources
in special ring set structures.  This set is simply separating the
datapath part of the device structure from the control information
allowing the new datapath structure to be allocated with all new
memory and rings.  The swap operation is now greatly simplified.
We also save a lot of parameter passing this way.  Hopefully the churn
is worth the negative diffstat.

Support for XDP adjust head is done in a pretty standard way.  NFP
is a bit special because it prepends metadata before packet data
so we have to do a bit of memcpying in case XDP will run.  We also
luck out a little bit because the fact that we already have prepend
space allocated means that one byte is enough to store the extra XDP
space (256 of standard prepend space is a bit inconvenient since
it would normally require 16bits or boolean with additional shifts).

Jakub Kicinski (13):
  nfp: separate data path information from the reset of adapter
    structure
  nfp: move control BAR pointer into data path structure
  nfp: pass new data path to ring reconfig
  nfp: use dp to carry number of stack tx rings and vectors
  nfp: use dp to carry fl_bufsz at reconfig time
  nfp: use dp to carry mtu at reconfig time
  nfp: use dp to carry xdp_prog at reconfig time
  nfp: switch to using data path structures for reconfiguration
  nfp: store dma direction in data path structure
  nfp: validate rx offset from the BAR and size down it's field
  nfp: reorganize pkt_off variable
  nfp: prepare metadata handling for xdp_adjust_head()
  nfp: add support for xdp_adjust_head()

 drivers/net/ethernet/netronome/nfp/nfp_net.h       | 150 ++--
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 999 ++++++++++-----------
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |   4 +-
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   | 104 +--
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |  32 +-
 .../net/ethernet/netronome/nfp/nfp_net_offload.c   |  30 +-
 .../net/ethernet/netronome/nfp/nfp_netvf_main.c    |  19 +-
 7 files changed, 655 insertions(+), 683 deletions(-)

-- 
2.11.0
