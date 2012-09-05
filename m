From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 0/7 (V2)] stmmac: remove dead code for STMMAC_TIMER and add new mitigation schema.
Date: Wed,  5 Sep 2012 17:03:45 +0200
Message-ID: <1346857432-24657-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:51437 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751515Ab2IEPFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 11:05:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patch series remove the STMMAC_TIMER option no longer updated
and never used and add a new mitigation schema.
Having removed the Timer opt, this has made the driver slim.
On top of this work, it has been easier to introduce the new
mitigation schema based on HW RX-watchdog (available in new cores).
In fact, 3.50 and newer cores have an HW RX-Watchdog that can be used for 
mitigating the Rx-interrupts and first results look promising.

Running n-u-t-t-c-p with the following parameters:

 Throughput: 500Mbps
 UDP Buffer size: 1328bytes
 TCP Buffer size: 65536bytes

for example, I got on ST box (arm-based) these improvements:

--------------------------------------------------------------------
      Original                   |     With New Mitigation patch
--------------------------------------------------------------------
 Test        CPU usage  pkt/loss |        CPU usage     pkt/loss
 Type  Mbps        %         %   |Mbps      %              %
--------------------------------------------------------------------
UDP-RX 395.5065 95       20.89   |499.9966  25        0.00%
UDP-TX 499.5578 100     0.08915  |499.7156  100       0.06029%
TCP-RX 499.9221 77               |499.8648  41
TCP-TX 389.5719 99               |499.2802  79
--------------------------------------------------------------------

 ... no regression on ST boxes (SH based) I always test.

This is a brief explanation of the new mitigation schema although there
is a patch that updates the driver's documentation.

o On Rx-side I have:
  New GMACs will use the RX-watchdog timer; old ones will continue to
  use NAPI to mitigate the RX DMA interrupts.
  For the RX-watchdog, there is a parameter that is the RI Watchdog 
  Timer count. It indicates the number of system clock cycles and can be
  set via *ethtool*.

o On Tx-side, the mitigation schema is based on a SW timer
  that calls the tx function (stmmac_tx) to reclaim the resource after
  transmitting the frames.
  Also there is another parameter (a threshold) used to program
  the descriptors avoiding to set the interrupt on completion bit in
  when the frame is sent (xmit). This means that the stmmac_tx can be
  called by the ISR too. Also this parameter can be tuned via ethtool.

V2: the new version of the patches add the ethtool support to get/set
coalesce parameters and totally removed the sysFS support.

Giuseppe Cavallaro (7):
  stmmac: remove dead code for TIMER
  stmmac: manage tx clean out of rx_poll
  stmmac: add the initial tx coalesce schema
  stmmac: add Rx watchdog optimization to mitigate the DMA irqs
  stmmac: get/set coalesce parameters via ethtool
  stmmac: update the doc with new IRQ mitigation
  stmmac: update the driver version to Sept_2012

 Documentation/networking/stmmac.txt                |   28 ++-
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   25 --
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    1 -
 drivers/net/ethernet/stmicro/stmmac/common.h       |   30 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    3 -
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |    6 +
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    3 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |    7 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   14 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   83 +++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  245 ++++++++------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c |  134 -----------
 drivers/net/ethernet/stmicro/stmmac/stmmac_timer.h |   46 ----
 include/linux/stmmac.h                             |    1 +
 14 files changed, 239 insertions(+), 387 deletions(-)
 delete mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c
 delete mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_timer.h

-- 
1.7.4.4
