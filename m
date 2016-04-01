From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH v4 net-next 00/15] MTU/buffer reconfig changes
Date: Fri,  1 Apr 2016 22:06:36 +0100
Message-ID: <1459544811-24879-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38332 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbcDAVHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 17:07:01 -0400
Received: by mail-wm0-f51.google.com with SMTP id 20so5297731wmh.1
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 14:07:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Sorry it takes me so long to iterate this.

Previous series included some not entirely related patches,
this one is cut down.  Main issue I'm trying to solve here
is that .ndo_change_mtu() in nfpvf driver is doing full
close/open to reallocate buffers - which if open fails
can result in device being basically closed even though
the interface is started.  As suggested by you I try to move
towards a paradigm where the resources are allocated first
and the MTU change is only done once I'm certain (almost)
nothing can fail.  Almost because I need to communicate 
with FW and that can always time out.

Patch 1 fixes small issue.  Next 10 patches reorganize things
so that I can easily allocate new rings and sets of buffers
while the device is running.  Patches 13 and 15 reshape the
.ndo_change_mtu() and ethtool's ring-resize operation into
desired form.


Jakub Kicinski (15):
  nfp: correct RX buffer length calculation
  nfp: move link state interrupt request/free calls
  nfp: break up nfp_net_{alloc|free}_rings
  nfp: make *x_ring_init do all the init
  nfp: allocate ring SW structs dynamically
  nfp: cleanup tx ring flush and rename to reset
  nfp: reorganize initial filling of RX rings
  nfp: preallocate RX buffers early in .ndo_open
  nfp: move filling ring information to FW config
  nfp: slice .ndo_open() and .ndo_stop() up
  nfp: sync ring state during FW reconfiguration
  nfp: propagate list buffer size in struct rx_ring
  nfp: convert .ndo_change_mtu() to prepare/commit paradigm
  nfp: pass ring count as function parameter
  nfp: allow ring size reconfiguration at runtime

 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  10 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 905 ++++++++++++++-------
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  30 +-
 3 files changed, 617 insertions(+), 328 deletions(-)

-- 
1.9.1
