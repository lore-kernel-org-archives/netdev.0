From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v4 0/4] USB & USBNET: loose SG check and support usbnet DMA SG
Date: Thu,  8 Aug 2013 21:48:21 +0800
Message-ID: <1375969705-24877-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:47008 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965162Ab3HHNsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 09:48:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset allows drivers to pass sg buffers which size can't be divided
by max packet size of endpoint if the host controllers(such ax xHCI) support
this kind of sg buffers.

Previously we added check[1] on the situation and don't allow these sg buffers
passed to USB HCD, looks the check is too strict to make use of new feature of
new hardware(xHCI) for some applications(such as network stack) which can't
provide this kind of sg buffers to usbnet driver, so the patch looses the check
in case that the host controller supports it.

Patch 3/4 implements DMA SG on usbnet driver, and patch 4/4 uses it on ax88179_178a
USB3 NIC for supporting TSO, so both CPU utilization and tx throughput can be
improved with TSO and DMA SG in case of the USB NIC is attached to xHCI controller.

This patchset depends on both net-next and usb-next tree, so hope David and Greg
to figure out one elegent way to merge it.

[1], http://git.kernel.org/cgit/linux/kernel/git/gregkh/usb.git/commit/?h=usb-next&id=10e232c597ac757e7f8600649f7e872e86de190f

V4:
	- don't set NETIF_F_SG | NETIF_F_TSO in reset() callback
	as pointed out by Eric(only 4/4 changed)

V3:
        - save 3 lines code for usb_device_no_sg_constraint() as suggested by Alan
        - fix urb->sg leak in xmit failure path

V2:
        - add missed kfree(urb->sg) in 3/4
        - rename no_sg_limit as no_sg_constraint as suggested by Alan

V1:
        - introduce and apply usb_device_no_sg_limit() helper as suggested by Greg
        - simplify patch 4/4 against Eric Dumazet's patch(ax88179_178a: avoid copy of tx tcp packets)
        - don't pass usbnet header as sg buffer

 drivers/net/usb/ax88179_178a.c |    8 +++++++
 drivers/net/usb/usbnet.c       |   45 +++++++++++++++++++++++++++++++++++++---
 drivers/usb/core/urb.c         |    3 ++-
 drivers/usb/host/xhci.c        |    4 ++++
 include/linux/usb.h            |    8 ++++++-
 include/linux/usb/usbnet.h     |    1 +
 6 files changed, 64 insertions(+), 5 deletions(-)



Thanks,
--
Ming Lei
