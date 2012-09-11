From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 0/8 (V4)] stmmac: remove dead code for STMMAC_TIMER and add new mitigation schema
Date: Tue, 11 Sep 2012 08:55:06 +0200
Message-ID: <1347346514-23411-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:50286 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751483Ab2IKGz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 02:55:27 -0400
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
UDP-RX 395.5065 95       20.89   |499.9552  23        0.00
UDP-TX 499.5578 100     0.08915  |500.0152  100       0.00
TCP-RX 499.9221 77               |499.9217  27
TCP-TX 389.5719 99               |499.9171  80
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

V2: these patches add the ethtool support to get/set coalesce parameters
and totally remove the sysFS support added in the first patches.

V3: added several fixes: for example NAPI and RX-watchdog work together
while in the previous implementation the HW  RX-watchdog disabled NAPI.
On the tx side, erroneously the tx coalesce frame parameter was limited
to the ring size and the driver didn't take care of the segment numbers
when enable/disable the IC bit in the TDES.

V4: reject not supported coalesce settings in ethtool.

Giuseppe Cavallaro (8):
  stmmac: remove dead code for TIMER
  stmmac: manage tx clean out of rx_poll
  stmmac: add the initial tx coalesce schema
  stmmac: add Rx watchdog support to mitigate the DMA irqs
  stmmac: get/set coalesce parameters via ethtool
  stmmac: fix and review the rx irq path after adding new mitigation
  stmmac: update the doc with new IRQ mitigation
  stmmac: update the driver version to Sept_2012

 Documentation/networking/stmmac.txt                |   28 ++-
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   25 --
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    1 -
 drivers/net/ethernet/stmicro/stmmac/common.h       |   42 +++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    3 -
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |   10 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |    4 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    7 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |   28 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   14 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |  103 ++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  240 ++++++++------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c |  134 -----------
 drivers/net/ethernet/stmicro/stmmac/stmmac_timer.h |   46 ----
 include/linux/stmmac.h                             |    1 +
 15 files changed, 280 insertions(+), 406 deletions(-)
 delete mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c
 delete mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_timer.h

-- 
1.7.4.4
