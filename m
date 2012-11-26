From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 0/6 (V5)] stmmac: remove dead code for STMMAC_TIMER and add new mitigation schema
Date: Mon, 26 Nov 2012 10:10:40 +0100
Message-ID: <1353921046-5121-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:45975 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753537Ab2KZJLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 04:11:33 -0500
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
UDP-RX 395.5065 95       20.89   |499.8811  23        0.00
UDP-TX 499.5578 100     0.08915  |499.1340  99        0.00
TCP-RX 499.9221 77               |499.8776  26
TCP-TX 389.5719 99               |499.9771  79
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
  when the frame is sent (xmit). 

V2: these patches add the ethtool support to get/set coalesce parameters
and totally remove the sysFS support added in the first patches.

V3: added several fixes: for example NAPI and RX-watchdog work together
while in the previous implementation the HW  RX-watchdog disabled NAPI.
On the tx side, erroneously the tx coalesce frame parameter was limited
to the ring size and the driver didn't take care of the segment numbers
when enable/disable the IC bit in the TDES.

V4: reject not supported coalesce settings in ethtool.

V5: in these new patch series, I am releasing two patches that
add the mitigation for tx and rx where I collected the feedback received
from the mailing list.  Concerning the tx, I've also reworked and
fixed the spinlock irqsave and restore as D. Miller had suggested (thx).

Giuseppe Cavallaro (6):
  stmmac: remove dead code for STMMAC_TIMER support
  stmmac: add the initial tx coalesce schema
  stmmac: add Rx watchdog support to mitigate the DMA irqs
  stmmac: get/set coalesce parameters via ethtool
  stmmac: update the doc with new IRQ mitigation
  stmmac: update the driver version to Nov_2012

 Documentation/networking/stmmac.txt                |   28 ++-
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   25 --
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    1 -
 drivers/net/ethernet/stmicro/stmmac/common.h       |   39 +++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    3 -
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |    6 +
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    5 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |   20 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   14 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |  100 +++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  261 ++++++++------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c |  134 ----------
 drivers/net/ethernet/stmicro/stmmac/stmmac_timer.h |   46 ----
 include/linux/stmmac.h                             |    1 +
 14 files changed, 281 insertions(+), 402 deletions(-)
 delete mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c
 delete mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_timer.h

-- 
1.7.4.4
