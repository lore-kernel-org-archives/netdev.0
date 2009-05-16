From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH v3 0/7] can: CAN network device driver interface and drivers
Date: Sat, 16 May 2009 11:39:26 +0200
Message-ID: <20090516093926.429574900@denx.de>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:60355 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754931AbZEPJj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2009 05:39:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

here comes v3 of this patch series.

The PF_CAN protocol family for the Controller Area Network is available
in the kernel since version 2.6.25 but drivers for real CAN devices are
still missing. This patch series adds a generic CAN network device
driver interface and, as a start, a few drivers. It is the result of the
on-going discussion and development of the Socket-CAN project hosted at
the BerliOS web-server (http://developer.berlios.de/projects/socketcan).
The patch series consists of the following patches:

 1/7) can: Documentation for the CAN device driver interface
 2/7) can: Update MAINTAINERS and CREDITS file
 3/7) can: CAN Network device driver and Netlink interface
 4/7) can: Driver for the SJA1000 CAN controller
 5/7) can: SJA1000 generic platform bus driver
 6/7) can: SJA1000 driver for EMS PCI cards
 7/7) can: SJA1000 driver for Kvaser PCI cards

Changes since v2:
  (see http://marc.info/?l=linux-netdev&m=124212048701347&w=4)

- Fix dead-lock with netif_tx_lock used in can_restart_now() pointed out
  by Andrew Morton. A restart via netlink interface is now only allowed
  in case of bus-off conditions, which does not require taking the
  netif_tx_lock. Actually no extra locking is required as the device is
  "quiet" and the restart delay can not longer be changed while the
  device is running.

- can_restart_now() now uses "goto out" to handle error conditions
  properly as suggested by Jonathan Corbet.

- Add member "irq_flags" to "struct sja1000_priv" which  will then be
  used by the request_irq() as suggested by Sascha Hauer. The driver
  must set it appropriately, including IRQF_SHARED. This also fixes the
  problem, that drivers used it unnecessarily.

- Fixes for drives/net/can/sja1000.c suggested by Jonathan Corbet:
  - call close_candev() to cleanup if the open function fails.
  - use negative return code if set_reset/normal_mode() fails.
  - call udelay() before the status is checked.

- Fixes for drives/net/can/sja1000_platform.c suggested by Jonathan
  Corbet and Sascha Hauer:
  - use resource_size() where appropriate.
  - call iounmap() before release_mem_region() in the exit path.

- Fixes for drives/net/can/kvasar_pci.c suggested by Jonathan Corbet:
  - dont use the name "tmp" to avoid  reviewers getting grumpy.
  - remove udelay(10) in the loop scanning the device on the card.
  - there is no need to check the return value of netdev_priv().
  - correct procedure of enabling and disabling PCI interrupts.
  - use proper exit label if pci_iomap() fails.
  - fix cleanup code under label failure_iounmap.

- More documentation of the "struct sja1000_priv" as suggested by
  Jonathan Corbet.

- Registration of the netlink interface and netdev devices corrected to
  fix an oops when unloading the driver.

Changes since v1:
  (see http://marc.info/?l=linux-netdev&m=123507025810612&w=4.)

- The SysFS interface has been replaced by the Netlink interface. See
  chapter 6.5 of "Documentation/networking/can.txt" and have a look to
  "include/linux/can/netdev.h" for further information. The patch for
  the "ip" program of the iproute2 utility suite will be provided
  separately.

- The restart function is now properly protected by "dev->tx_lock"
  using the "netif_tx_[lock|unlock]" functions.

- For the  restart, the device driver must now handle CAN_MODE_STOP as
  well, apart from CAN_MODE_START to avoid race conditions.

- The "irq_lock" member of "struct can_priv" has been removed. The CAN
  controller driver may should provide its own synchronization if
  necessary.

- The restart function is now protected by "dev->tx_lock" using the
  "netif_tx_lock/unlock" functions.

- Cleanup timer usage for the restart function.

- The unused do_set/get_ctrlmode member of "struct can_priv" have been
  removed.

- "const" has been added to "struct net_device" for some functions not
  allowed to touch that structure.

- The library functions "can_set_bittiming" and "can_close_cleanup" have
  been renamed to the more general names "open_candev" and
  "close_candev", respectively.

- Use "del_timer_sync" instead of "del_timer" for the  re-start timer.

- The macro "ND2D()" has been replaced by "dev->dev.parent" as it does
  not make the code more readable.

- Fix improper BTR setting for triple-sampling for the SJA1000 as
  pointed out by Oliver.

- Dont use __u8 but __u32 as before for some members of "struct
  can_bittiming[_const]" to avoid alignment trouble.

- Definitions shared with user-space applications have been moved to
  "include/linux/can/netlink.h".

- Various other minor correction suggested on the netdev ML.

- The MSCAN driver for the MPC5200 has been removed. It needs to be
  presented on the Linuxppc-dev and Devicetree-discuss ML as well,
  which will be done by a sub-sequent patch.

- Add more source code documentation, especially for the structures
  and functions related to bit-timing.

Please consider these patches for inclusion.

Thanks,

Wolfgang.


