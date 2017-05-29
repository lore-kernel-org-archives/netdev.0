From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v8 net-next 00/17] net: qualcomm: add QCA7000 UART driver
Date: Mon, 29 May 2017 13:57:08 +0200
Message-ID: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Jakub Kicinski <kubakici@wp.pl>, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
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
the UART support. Patch 4 adds SET_NETDEV_DEV() to qca_spi.
Patches 5 - 16 prepare the existing QCA7000 code for UART support.
The last patch contains the new driver.

The code itself has been tested on a Freescale i.MX28 board and
a Raspberry Pi Zero.

Changes in v8:
  * add necessary header includes to qca_7k.c in order to reflect
    dependencies

Changes in v7:
  * fix race between tx workqueue and device deregistration (reported by Lino)

Changes in v6:
  * rebase to current linux-next
  * use SET_NETDEV_DEV() for qca_spi and qca_uart
  * rename binding to qca,qca7000.txt
  * use qca,qca7000 compatible for both driver
  * handle error cases in qca_uart_probe properly
  * fix skb leak in error path of qcauart_netdev_init
  * use dev_kfree_skb_any instead of kfree_skb
  * take care of tx_work on close / remove
  * use devm_kmalloc for tx buffer
  * minor cleanups

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

Stefan Wahren (17):
  net: qualcomm: qca_7k: clean up header includes
  net: qca_framing: use u16 for frame offset
  net: qca_7k: Use BIT macro
  net: qca_spi: Use SET_NETDEV_DEV()
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
  net: qualcomm: add QCA7000 UART driver

 .../devicetree/bindings/net/qca,qca7000.txt        |  88 +++++
 .../devicetree/bindings/net/qca-qca7000-spi.txt    |  47 ---
 .../devicetree/bindings/serial/slave-device.txt    |   9 +
 drivers/net/ethernet/qualcomm/Kconfig              |  24 +-
 drivers/net/ethernet/qualcomm/Makefile             |   7 +-
 drivers/net/ethernet/qualcomm/qca_7k.c             |  30 +-
 drivers/net/ethernet/qualcomm/qca_7k.h             |  15 +-
 .../qualcomm/{qca_framing.c => qca_7k_common.c}    |  26 +-
 .../qualcomm/{qca_framing.h => qca_7k_common.h}    |  24 +-
 drivers/net/ethernet/qualcomm/qca_debug.c          |   5 +-
 drivers/net/ethernet/qualcomm/qca_spi.c            |  48 ++-
 drivers/net/ethernet/qualcomm/qca_spi.h            |   5 +-
 drivers/net/ethernet/qualcomm/qca_uart.c           | 423 +++++++++++++++++++++
 13 files changed, 632 insertions(+), 119 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/qca,qca7000.txt
 delete mode 100644 Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
 rename drivers/net/ethernet/qualcomm/{qca_framing.c => qca_7k_common.c} (85%)
 rename drivers/net/ethernet/qualcomm/{qca_framing.h => qca_7k_common.h} (86%)
 create mode 100644 drivers/net/ethernet/qualcomm/qca_uart.c

-- 
2.1.4
