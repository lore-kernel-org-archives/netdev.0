From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC (v3) 00/19] MTU changes and other fixes
Date: Wed,  3 Feb 2016 11:45:06 +0000
Message-ID: <1454499925-16359-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38619 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932537AbcBCLph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 06:45:37 -0500
Received: by mail-wm0-f51.google.com with SMTP id p63so66122172wmp.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 03:45:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I'm posting this as RFC because I think +625/-339 of mostly
code refactoring is not good for net, my intention is to
show you I did the homework and then repost this as two parts
- for net and for net-next.  In retrospect I could've just
asked you right away where you intend this series to go...

First four patches are what you already seen - those plus
number 5 I would be glad to see in net.

Patches 6-13 refactor open/stop paths to follow this:
 - alloc;
 - dev/FW init;
 - stack init/start.
stop:
 - stack stop;
 - dev/FW down;
 - free.
That's a quite a bit of code churn I did my best to split
it up but probably still not much fun to review.

Patch 14 splits the open/stop into chunks I can call later.

Patch 15 makes sure that FW start/stop operations are
reflected in SW state (which was not needed earlier since
we always did full down/up).

Patches 16 and 18 are trivial, split for readability.

Patch 17 does what you requested for MTU change:
 - alloc new resources;
 - stop dev;
 - try to start dev with new config;
 - if failed try with old config;
 - if failed die loudly.

Patch 19 does the same thing for ring resize.

I tested this with various error injection hacks and it 
seems quite solid.

Please let me know if 1-5/6-19 split makes sense to you or if
you prefer to take them all into one tree (and I should squash
#1 and #2 into proper rework (#17)).

Thanks!


Jakub Kicinski (19):
  nfp: return error if MTU change fails
  nfp: free buffers before changing MTU
  nfp: correct RX buffer length calculation
  nfp: fix RX buffer length validation
  nfp: don't trust netif_running() in debug code
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
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 920 ++++++++++++++-------
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |   4 +-
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  30 +-
 4 files changed, 625 insertions(+), 339 deletions(-)

-- 
1.9.1
