From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v5 00/17] net: qualcomm: add QCA7000 UART driver
Date: Wed, 10 May 2017 10:53:11 +0200
Message-ID: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com>
Cc: Mark Rutland <mark.rutland@arm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Qualcomm QCA7000 HomePlug GreenPHY supports two interfaces:
UART and SPI. This patch series adds the missing support for UART.

This driver based on the Qualcomm code [1], but contains some changes:
* use random MAC address per default
* use net_device_stats from device
* share frame decoding between SPI and UART driver
* improve error handling
* reimplement tty_wakeup with work queue (based on slcan)
* use new serial device bus instead of ldisc

The patches 1 - 3 are just for clean up and are not related to
the UART support. Patches 4 - 15 prepare the existing QCA7000
code for UART support. Patch 16 is a improvement for serial device
bus. Patch 17 contains the new driver.

Cherry picking of the dt-bindings and serdev patch is okay. The
UART driver functionally (not compile) depends on this unmerged
patch [2].

The code itself has been tested on a Freescale i.MX28 board and
a Raspberry Pi Zero.

Changes in v5:
  * rebase to current linux-next
  * fix alignment issues in rx path
  * fix buffer overrun with big ethernet frames
  * fix init of UART decoding fsm
  * add device UART settings to Kconfig help
  * add current-speed to slave-device binding
  * merge SPI and UART binding document
  * rename qca_common to qca_7k_common
  * drop patch for retrieving UART settings
  * several cleanups

Changes in v4:
  * rebase to current linux-next
  * use parameter -M for git format-patch
  * change order of local variables where possible
  * implement basic serdev support (without hardware flow control)

Changes in v3:
  * rebase to current net-next

Changes in v2:
  * fix build issue by using netif_trans_update() and dev_trans_start()

[1] - https://github.com/IoE/qca7000
[2] - http://marc.info/?l=linux-serial&m=149338017301309&w=2

Stefan Wahren (17):
  net: qualcomm: remove unnecessary includes
  net: qca_framing: use u16 for frame offset
  net: qca_7k: Use BIT macro
  net: qualcomm: use net_device_ops instead of direct call
  net: qualcomm: Improve readability of length defines
  net: qca_spi: remove QCASPI_MTU
  net: qualcomm: move qcaspi_tx_cmd to qca_spi.c
  net: qca_spi: Clarify MODULE_DESCRIPTION
  net: qualcomm: rename qca_framing.c to qca_7k_common.c
  net: qualcomm: prepare frame decoding for UART driver
  net: qualcomm: make qca_7k_common a separate kernel module
  dt-bindings: qca7000-spi: Rework binding
  dt-bindings: qca7000: rename binding
  dt-bindings: slave-device: add current-speed property
  dt-bindings: qca7000: append UART interface to binding
  tty: serdev-ttyport: return actual baudrate from ttyport_set_baudrate
  net: qualcomm: add QCA7000 UART driver

 .../devicetree/bindings/net/qca-qca7000-spi.txt    |  47 ---
 .../devicetree/bindings/net/qca-qca7000.txt        |  88 +++++
 .../devicetree/bindings/serial/slave-device.txt    |   9 +
 drivers/net/ethernet/qualcomm/Kconfig              |  24 +-
 drivers/net/ethernet/qualcomm/Makefile             |   7 +-
 drivers/net/ethernet/qualcomm/qca_7k.c             |  28 --
 drivers/net/ethernet/qualcomm/qca_7k.h             |  15 +-
 .../qualcomm/{qca_framing.c => qca_7k_common.c}    |  26 +-
 .../qualcomm/{qca_framing.h => qca_7k_common.h}    |  24 +-
 drivers/net/ethernet/qualcomm/qca_debug.c          |   5 +-
 drivers/net/ethernet/qualcomm/qca_spi.c            |  47 ++-
 drivers/net/ethernet/qualcomm/qca_spi.h            |   5 +-
 drivers/net/ethernet/qualcomm/qca_uart.c           | 423 +++++++++++++++++++++
 drivers/tty/serdev/serdev-ttyport.c                |   2 +-
 14 files changed, 630 insertions(+), 120 deletions(-)
 delete mode 100644 Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
 create mode 100644 Documentation/devicetree/bindings/net/qca-qca7000.txt
 rename drivers/net/ethernet/qualcomm/{qca_framing.c => qca_7k_common.c} (85%)
 rename drivers/net/ethernet/qualcomm/{qca_framing.h => qca_7k_common.h} (86%)
 create mode 100644 drivers/net/ethernet/qualcomm/qca_uart.c

-- 
2.1.4
