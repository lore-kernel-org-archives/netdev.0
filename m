From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH 0/3] URGENT for 3.9: net: fec: revert NAPI introduction
Date: Fri, 19 Apr 2013 16:36:01 +0200
Message-ID: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
Cc: David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Fabio Estevam <festevam@gmail.com>,
	Lucas Stach <l.stach@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60795 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030551Ab3DSOhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 10:37:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Those patches introduce instability to the point of kernel OOPSes with
NULL-ptr dereferences.

The patches drop locks from the code without justifying why this would
be safe at all. In fact it isn't safe as now the controller restart can
happily free the RX and TX ring buffers while the NAPI poll function is
still accessing them. So with a heavily loaded but slightly instable
link we regularly end up with OOPSes because link change restarts
the FEC and bombs away buffers still in use.

Also the NAPI enabled interrupt handler ACKs the INT and only later
masks it, this way introducing a window where new interrupts could sneak
in while we are already in polling mode.

As it's way too late in the cycle to try and fix this up just revert the
relevant patches for now.

Lucas Stach (3):
  Revert "net: fec: fix missing napi_disable call"
  Revert "net: fec: put tx to napi poll function to fix dead lock"
  Revert "net: fec: add napi support to improve proformance"

 drivers/net/ethernet/freescale/fec.c | 126 ++++++++++++++---------------------
 drivers/net/ethernet/freescale/fec.h |   5 +-
 2 files changed, 53 insertions(+), 78 deletions(-)

-- 
1.8.2.rc2
