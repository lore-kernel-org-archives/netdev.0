From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv3 net-next 00/14] nfp: MTU fixes for net
Date: Thu, 18 Feb 2016 20:38:15 +0000
Message-ID: <1455827909-26443-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37016 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1948099AbcBRUif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 15:38:35 -0500
Received: by mail-wm0-f48.google.com with SMTP id g62so42992633wme.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 12:38:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave!

This is the second part of MTU reconfiguration fixes, targeted
at net-next.

Patches 1-8 refactor open/stop paths to look like this:
 - alloc;
 - dev/FW init;
 - stack init/start.
stop:
 - stack quiescence/stop;
 - dev/FW down;
 - free.
That's a quite a bit of code churn I did my best to split
it up but probably still not much fun to review.

Patch 9 splits the open/stop into chunks I can call later.

Patch 10 makes sure that FW start/stop operations are
reflected in SW state (which was not needed earlier since
we always did full down/up).

[Patches 11 and 13 are trivial, split for readability.]

Patch 12 does what you requested for MTU change:
 - alloc new resources;
 - stop dev;
 - try to start dev with new config;
 - if failed try with old config;
 - if failed die loudly.

Patch 14 does the same thing for ring resize.

I tested this with various error injection hacks and it 
seems quite solid.

This is on top of the first series, merge of net into
net-next will be required for this to apply.

Thanks!


Jakub Kicinski (14):
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
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 898 ++++++++++++++-------
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  30 +-
 3 files changed, 615 insertions(+), 323 deletions(-)

-- 
1.9.1
