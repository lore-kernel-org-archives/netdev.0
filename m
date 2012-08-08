From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [RFC net-next 0/4] gianfar: Use separate NAPI for Tx confirmation processing
Date: Wed, 8 Aug 2012 15:26:46 +0300
Message-ID: <1344428810-29923-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:28026
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753375Ab2HHM1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 08:27:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
This set of patches basically splits the existing napi poll routine into
two separate napi functions, one for Rx processing (triggered by frame
receive interrupts only) and one for the Tx confirmation path processing
(triggerred by Tx confirmation interrupts only). The polling algorithm
behind remains much the same.

Important throughput improvements have been noted on low power boards with
this set of changes.
For instance, for the following netperf test:
netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
yields a throughput gain from oscilating ~500-~700 Mbps to steady ~940 Mbps,
(if the Rx/Tx paths are processed on different cores), w/ no increase in CPU%,
on a p1020rdb - 2 core machine featuring etsec2.0 (Multi-Queue Multi-Group
driver mode).

Also, this change, which should ballance Rx and Tx processing, proves to
be effective against Rx busy interrupt occurrences.

Thanks for your review.
Claudiu


Claudiu Manoil (4):
  gianfar: Remove redundant programming of [rt]xic registers
  gianfar: Clear ievent from interrupt handler for [RT]x int
  gianfar: Separate out the Rx and Tx coalescing functions
  gianfar: Use separate NAPIs for Tx and Rx processing

 drivers/net/ethernet/freescale/gianfar.c |  220 +++++++++++++++++++++--------
 drivers/net/ethernet/freescale/gianfar.h |   16 ++-
 2 files changed, 171 insertions(+), 65 deletions(-)
