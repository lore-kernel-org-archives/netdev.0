From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 00/14] nfp: ethtool link settings
Date: Tue,  4 Apr 2017 16:12:21 -0700
Message-ID: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:36469 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753511AbdDDXMy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 19:12:54 -0400
Received: by mail-pg0-f53.google.com with SMTP id g2so162888628pge.3
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 16:12:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series adds support for getting and setting link settings
via the (moderately) new ethtool ksettings ops.

First patch introduces minimal speed and duplex reporting using
the information directly provided in PCI BAR0 memory.

Next few changes deal with the need to refresh port state read
from the service process and patch 6 finally uses that information
to provide link speed and duplex.  Patches 7 and 8 add auto 
negotiation and port type reporting.

Remaining changes provide the set support for speed and auto
negotiation.  An upcoming series will also add port splitting
support via devlink.

Quite a bit of churn in this series is caused by the fact that
currently port speed and split changes will usually require a
reboot to take effect.  Current service process code is not capable
of performing MAC reinitialization after chip has been passing
traffic.  To make sure user is aware of this limitation we refuse
the configuration unless netdev is down, print warning to the logs
and if configuration was performed but did take effect we unregister
the netdev.  Service process has a "reboot needed" sticky bit, so
reloading the driver will not bring the netdev back.

Note that there is a helper in patch 13 which is marked as
__always_inline, because the FIELD_* macros require the parameters
to be known at compilation time.  I hope that is OK.


Jakub Kicinski (14):
  nfp: add support for .get_link_ksettings()
  nfp: don't spawn netdevs for reconfigured ports
  nfp: add mutex protection for the port list
  nfp: track link state changes
  nfp: add port state refresh
  nfp: report link speed from NSP
  nfp: report auto-negotiation in ethtool
  nfp: report port type in ethtool
  nfp: separate high level and low level NSP headers
  nfp: allow multi-stage NSP configuration
  nfp: turn NSP port entry into a union
  nfp: add extended error messages
  nfp: NSP backend for link configuration operations
  nfp: add support for .set_link_ksettings()

 drivers/net/ethernet/netronome/nfp/nfp_main.c      |   5 +-
 drivers/net/ethernet/netronome/nfp/nfp_main.h      |  11 +-
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   7 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  16 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |  13 +
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   | 111 +++++++
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  | 187 ++++++++---
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h   |  20 +-
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c   |  85 ++++-
 .../nfp/nfpcore/{nfp_nsp_eth.h => nfp_nsp.h}       |  68 +++-
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c   | 359 +++++++++++++++++----
 11 files changed, 754 insertions(+), 128 deletions(-)
 rename drivers/net/ethernet/netronome/nfp/nfpcore/{nfp_nsp_eth.h => nfp_nsp.h} (62%)

-- 
2.11.0
