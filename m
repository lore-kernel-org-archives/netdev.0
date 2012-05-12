From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v4 0/13] basic ieee802.15.4 mac support
Date: Sat, 12 May 2012 17:59:12 +0400
Message-ID: <1336831165-23944-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:47024 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730Ab2ELOAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 10:00:10 -0400
Received: by wibhj8 with SMTP id hj8so359000wib.1
        for <netdev@vger.kernel.org>; Sat, 12 May 2012 07:00:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This is the 4-th version of patch series for IEEE 802.15.4 Medium Access
Control layer support. Originally the code was provided by linux-zigbee
sourceforge project.

There is no significant changes in the source code (just added extra headers
to include and fix some typos).

The open question was workqueue usage in RX/TX datapaths. I suspect that at
that time I didn't describe the logic in details, so doing it right now.

RX data path:
=============

The IEEE 802.15.4 Linux stack contains 3 main levels:
 - ieee802154 - 802.15.4 address family, netlink interface, datagrams etc...
 - mac802154 - 802.15.4 MAC layer
 - physical - device drivers

And the first layer registers packet_type struct and works with Linux network
queue.

Regarding mac802154 layer, the IEEE 802.15.4 standard defines 4 MAC packet
types:
 - beacon frame
 - MAC command frame
 - acknowledgement frame
 - data frame

and only the data frame should be pushed to the upper layers. Others must be
managed by MAC layer only. And only if the frame represents a data burst, MAC
layer calls netif_rx and sends packet to the network queue (which is handled
by the ieee802154 layer).

So that's the reason why workqueue was designed as a middle "medium" between
drivers and MAC layer - to communicate MAC-specific information. And the
overall conception is completely based on mac80211 code in the kernel.

TX data path:
=============

There are several drivers for some IEEE 802.15.4 transceivers available in
our project. And their HW specifications describe frame transmit procedure
in a similar way:
 - frame buffer write access
 - write command TX_START
 - wait for the completion of the transaction which is indicated by IRQ

So, during the xmitting a driver may sleep and workqueue is used for these
tasks.


With best regards,
Alex

--
The IEEE 802.15.4 Working Group focuses on the standardization of the
bottom two layers of ISO/OSI protocol stack: Physical (PHY) and MAC.
The MAC layer provides access control to a shared channel and reliable
data delivery.

This series provide only basic features:
 - interface for drivers registration
 - RX/TX datapaths
 - reduced mlme operations
 - monitor device type support (used by network sniffers, e.g.
   Wireshark)
 - IEEE 802.15.4 loopback driver
 - documentation update

8<--

Alexander Smirnov (13):
  mac802154: basic ieee802.15.4 device structures
  mac802154: allocation of ieee802154 device
  mac802154: RX data path
  mac802154: TX data path
  mac802154: define reduced mlme operations
  mac802154: slave interfaces definition
  mac802154: declare reduced mlme operations
  mac802154: basic mib support
  ieee802154: interface type to be added
  mac802154: slaves manipulation routine
  mac802154: monitor device support
  drivers/ieee802154: IEEE 802.15.4 loopback driver
  Documentation/networking/ieee802154: update MAC chapter

 Documentation/networking/ieee802154.txt |   75 ++++++--
 drivers/ieee802154/Kconfig              |    8 +
 drivers/ieee802154/Makefile             |    1 +
 drivers/ieee802154/fakelb.c             |  294 +++++++++++++++++++++++++++++++
 include/linux/if_arp.h                  |    1 +
 include/linux/nl802154.h                |   22 +++
 include/net/ieee802154_netdev.h         |   26 +++-
 include/net/mac802154.h                 |  141 +++++++++++++++
 include/net/wpan-phy.h                  |    5 +-
 net/Kconfig                             |    1 +
 net/Makefile                            |    1 +
 net/ieee802154/nl-phy.c                 |    9 +-
 net/mac802154/Kconfig                   |   16 ++
 net/mac802154/Makefile                  |    2 +
 net/mac802154/ieee802154_dev.c          |  291 ++++++++++++++++++++++++++++++
 net/mac802154/mac802154.h               |  105 +++++++++++
 net/mac802154/mac_cmd.c                 |   44 +++++
 net/mac802154/mib.c                     |   97 ++++++++++
 net/mac802154/monitor.c                 |  116 ++++++++++++
 net/mac802154/rx.c                      |  110 ++++++++++++
 net/mac802154/tx.c                      |  113 ++++++++++++
 21 files changed, 1456 insertions(+), 22 deletions(-)
 create mode 100644 drivers/ieee802154/fakelb.c
 create mode 100644 include/net/mac802154.h
 create mode 100644 net/mac802154/Kconfig
 create mode 100644 net/mac802154/Makefile
 create mode 100644 net/mac802154/ieee802154_dev.c
 create mode 100644 net/mac802154/mac802154.h
 create mode 100644 net/mac802154/mac_cmd.c
 create mode 100644 net/mac802154/mib.c
 create mode 100644 net/mac802154/monitor.c
 create mode 100644 net/mac802154/rx.c
 create mode 100644 net/mac802154/tx.c

-- 
1.7.2.3
