From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 00/10] net: expand time stamping, batch #1
Date: Fri, 10 Jun 2011 17:06:58 +0200
Message-ID: <cover.1307717675.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57323 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756753Ab1FJPHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 11:07:14 -0400
Received: by bwz15 with SMTP id 15so2260711bwz.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 08:07:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series represents the start of an effort to get better
coverage of the SO_TIMESTAMPING socket API in the Ethernet drivers.
Adding time stamping support to a given driver solves two separate
issues, namely software transmit time stamping and hardware time
stamping in PHY devices.

The SO_TIMESTAMPING socket API has been around since 2.6.30, but it
turned out that getting software transmit time stamps could not be
done in one central place in the stack. Instead, a work around was
introduced whereby each MAC driver must call a skb_tx_timestamp() hook
in order to support SW Tx time stamps.

Full PTP Hardware Clock (PHC) support has been merged for Linux 3.0,
including a driver for a PHY that does HW stamping. In the receive
path, the PHY based time stamping is handled by the stack for NAPI
based MAC drivers. But for transmit time stamps, support is needed in
the Ethernet MAC driver by calling the skb_tx_timestamp() hook.

For non-NAPI drivers, PHY based receive time stamping is currently not
possible. This patch series adds yet another hook (a wrapper around
netif_rx) for such drivers.

The first two patches make minor changes in the stack in support of
MAC/PHY time stamping. The next three patches enable PHY time stamping
for two MACs which have been paired with a PHC PHY on real life
boards.

The remaining patches are for MACs that I chose because they (1) use
phylib and (2) compile for x86. However, I only compiled these, not
tested, since I do not have the hardware.

The larger goal is to eventually get the skb_tx_timestamp hook into
each and every Ethernet MAC driver, so that SO_TIMESTAMPING using SW
time stamps will be supported across the board. I have started by
picking those drivers in which adding the hook will bring the greatest
benefit, namely those using phylib, since adding hooks provides both
SW and PHY HW time stamping.

If people approve of this effort, I will follow with another patch
series adding SW Tx time stamping to yet more MACs. Adding SW Tx
support is just a single line, but still, perhaps compile testing only
is too risky. I would appreciate feedback on this issue.


Richard Cochran (10):
  net: introduce time stamping wrapper for netif_rx.
  fec: enable transmit and receive time stamping.
  davinci_emac: pass ioctls through to phy device.
  davinci_emac: enable transmit time stamping.
  tg3: enable transmit time stamping.
  dnet: enable transmit time stamping.
  ethoc: enable transmit time stamping.
  r6040: enable transmit time stamping.
  stmmac: enable transmit time stamping.
  smsc9420: enable transmit time stamping.

 drivers/net/davinci_emac.c       |    5 +++--
 drivers/net/dnet.c               |    2 ++
 drivers/net/ethoc.c              |    1 +
 drivers/net/fec.c                |    4 +++-
 drivers/net/r6040.c              |    2 ++
 drivers/net/smsc9420.c           |    2 ++
 drivers/net/stmmac/stmmac_main.c |    2 ++
 drivers/net/tg3.c                |    2 ++
 include/linux/netdevice.h        |   21 +++++++++++++++++++++
 9 files changed, 38 insertions(+), 3 deletions(-)

