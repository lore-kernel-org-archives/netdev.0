From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [RESEND PATCH net-next 00/13] Enhance stmmac driver to support GMAC4.x IP
Date: Fri, 1 Apr 2016 11:37:24 +0200
Message-ID: <1459503457-22569-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lars Persson <lars.persson@axis.com>
To: <netdev@vger.kernel.org>, <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:43884 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752935AbcDAJhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 05:37:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a subset of patch to enhance current stmmac driver to support
new GMAC4.x chips. New set of callbacks is defined to support this new
family: descriptors, dma, core.

One of main changes of GMAC 4.xx IP is descriptors management.
 -descriptors are only used in ring mode.
 -A descriptor is composed of 4 32bits registers (no more extended
  descriptors)
 -descriptor mechanism (Tx for example, but it is exactly the same for =
RX):
 -useful registers:
  -DMA_CH#_TxDesc_Ring_Len: length of transmit descriptor ring
  -DMA_CH#_TxDesc_List_Address: start address of the ring
  -DMA_CH#_TxDesc_Tail_Pointer: address of the last descriptor to send =
+ 1.
  -DMA_CH#_TxDesc_Current_App_TxDesc: address of the current descriptor
   =20
 -The descriptor Tail Pointer register contains the pointer to the
  descriptor address (N). The base address and the current
  descriptor decide the address of the current descriptor that the
  DMA can process. The descriptors up to one location less than the
  one indicated by the descriptor tail pointer (N-1) are owned by
  the DMA. The DMA continues to process the descriptors until the
  following condition occurs:
  "current descriptor pointer =3D=3D Descriptor Tail pointer"

  Then the DMA goes into suspend mode. The application must perform
  a write to descriptor tail pointer register and update the tail
  pointer to have the following condition and to start a new transfer:
  "current descriptor pointer < Descriptor tail pointer"
   =20
  The DMA automatically wraps around the base address when the end
  of ring is reached.
 =20
New features are available on IP:
 -TSO (TCP Segmentation Offload) for TX only
 -Split header: to have header and payload in 2 different buffers (not =
yet implemented)

Below some throughput figures obtained on some boxes:

                        iperf (mbps)=20
--------------------------------------
                       tcp     udp   =20
                    tx   rx   tx  rx =20
                     -----------------
    GMAC4.x         935  930  750 800=20

Note: There is a change in 4.10a databook on bitfield mapping of DMA_CH=
ANx_INTR_ENA register.=20
This requires to have =E9 diffrent set of callbacks between IP 4.00a an=
d 4.10a.

Best regards

Alex

I'm resending this series because first sending was badly done during m=
erge
window.

Alexandre TORGUE (13):
  stmmac: rework get_hw_feature function
  stmmac: rework the routines to show the ring status
  stmmac: rework synopsys id read, moved to dwmac setup
  stmmac: add descriptors function for GMAC 4.xx
  stmmac: add GMAC4 DMA/CORE Header File
  stmmac: add DMA support for GMAC 4.xx
  stmmac: add GMAC4 core support
  stmmac: enhance mmc counter management
  stmmac: add new DT platform entries for GMAC4
  stmmac: support new GMAC4
  Documentation: networking: update stmmac
  stmmac: update version to Jan_2016
  stmmac: update MAINTAINERS

 Documentation/devicetree/bindings/net/stmmac.txt   |   2 +
 Documentation/networking/stmmac.txt                |  44 +-
 MAINTAINERS                                        |   1 +
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   3 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |  64 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |   7 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |  35 +-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |   5 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       | 255 ++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 407 +++++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c | 396 +++++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h | 129 +++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c   | 354 ++++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h   | 202 +++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c   | 225 +++++++
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |  21 +
 drivers/net/ethernet/stmicro/stmmac/mmc.h          |   4 +
 drivers/net/ethernet/stmicro/stmmac/mmc_core.c     | 349 +++++------
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |  21 +
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   7 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   7 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 643 +++++++++++++=
++------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   7 +
 include/linux/stmmac.h                             |   2 +
 24 files changed, 2821 insertions(+), 369 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac4.h
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c

--=20
1.9.1
