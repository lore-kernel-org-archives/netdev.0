From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 0/7] stmmac: remove dead code for STMMAC_TIMER and add new mitigation schema.
Date: Mon,  3 Sep 2012 09:46:55 +0200
Message-ID: <1346658422-1925-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:35834 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753016Ab2ICHrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 03:47:12 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 577B21E3
	for <netdev@vger.kernel.org>; Mon,  3 Sep 2012 07:47:07 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D241A2B9C
	for <netdev@vger.kernel.org>; Mon,  3 Sep 2012 07:47:07 +0000 (GMT)
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
  set via sysFS. Next step will be to tune it via ethtool.

o On Tx-side, the mitigation schema is based on a SW timer
  that calls the tx function (stmmac_tx) to reclaim the resource after
  transmitting the frames.
  Also there is another parameter (a threshold) used to program
  the descriptors avoiding to set the interrupt on completion bit in
  when the frame is sent (xmit). This means that the stmmac_tx can be
  called by the ISR too. Also this parameter can be tuned via sysFs and
  not yet via ethtool.

Note1: there is a patch that updates the driver to August 2012.
I hope to also release the PTP support and update the driver in the next weeks.

Note2: next step will be to tune coalesce params via ethtool. I'll do that.

peppe

Giuseppe Cavallaro (7):
  stmmac: remove dead code for TIMER
  stmmac: manage tx clean out of rx_poll
  stmmac: add the initial tx coalesce schema
  stmmac: add Rx watchdog optimization to mitigate the DMA irqs
  stmmac: add sysFs support
  stmmac: add mitigation and sysfs info in the doc
  stmmac: update the driver version to August_2012

 Documentation/networking/stmmac.txt                |   34 ++-
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   25 --
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    3 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   30 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    3 -
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |    6 +
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    3 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |    7 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac-sysfs.c |  157 +++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   15 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    9 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  282 +++++++++-----------
 drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c |  134 ---------
 drivers/net/ethernet/stmicro/stmmac/stmmac_timer.h |   46 ----
 14 files changed, 354 insertions(+), 400 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac-sysfs.c
 delete mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c
 delete mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_timer.h

-- 
1.7.4.4
