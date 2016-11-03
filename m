From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next resend 00/13] ring reconfiguration and XDP support
Date: Thu,  3 Nov 2016 17:11:56 +0000
Message-ID: <1478193129-23476-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36081 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758684AbcKCRMW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 13:12:22 -0400
Received: by mail-wm0-f53.google.com with SMTP id p190so347002433wmp.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 10:12:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This set adds support for ethtool channel API and XDP.

I kick off with ethtool get_channels() implementation.  
set_channels() needs some preparations to get right.  I follow
the prepare/commit paradigm and allocate all resources before
stopping the device.  It has already been done for ndo_change_mtu
and ethtool set_ringparam(), it makes sense now to consolidate all
the required logic in one place.

XDP support requires splitting TX rings into two classes - 
for the stack and for XDP.  The ring structures are identical.
The differences are in how they are connected to IRQ vector
structs and how the completion/cleanup works.  When XDP is enabled
I switch from the frag allocator to page-per-packet and map buffers
BIDIRECTIONALly.

Last but not least XDP offload is added (the patch just takes
care of the small formal differences between cls_bpf and XDP).

There is a tiny & trivial DebugFS patch in the mix, I hope it can
be taken via net-next provided we have the right Acks.

Resending with improved commit message and CCing more people on patch 10.

Jakub Kicinski (13):
  nfp: add support for ethtool .get_channels
  nfp: centralize runtime reconfiguration logic
  nfp: rename ring allocation helpers
  nfp: reuse ring helpers on .ndo_open() path
  nfp: loosen relation between rings and IRQs vectors
  nfp: add helper to reassign rings to IRQ vectors
  nfp: move RSS indirection table init into a separate function
  nfp: add support for ethtool .set_channels
  nfp: reorganize nfp_net_rx() to get packet offsets early
  debugfs: constify argument to debugfs_real_fops()
  nfp: add XDP support in the driver
  nfp: remove unnecessary parameters from nfp_net_bpf_offload()
  nfp: add support for offload of XDP programs

 drivers/net/ethernet/netronome/nfp/nfp_bpf.h       |   1 +
 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c   |  92 ++-
 .../net/ethernet/netronome/nfp/nfp_bpf_verifier.c  |   3 +
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  30 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 892 ++++++++++++++-------
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |  41 +-
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  94 +++
 .../net/ethernet/netronome/nfp/nfp_net_offload.c   |   7 +-
 include/linux/debugfs.h                            |   3 +-
 9 files changed, 869 insertions(+), 294 deletions(-)

-- 
1.9.1
