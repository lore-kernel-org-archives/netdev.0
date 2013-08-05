From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v2 0/4] USB & USBNET: loose SG check and support usbnet DMA SG
Date: Mon,  5 Aug 2013 16:46:59 +0800
Message-ID: <1375692423-9497-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:63048 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754780Ab3HEIra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 04:47:30 -0400
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

V2:
	- add missed kfree(urb->sg) in 3/4
	- rename no_sg_limit as no_sg_constraint as suggested by Alan

V1:
        - introduce and apply usb_device_no_sg_limit() helper as suggested by Greg
        - simplify patch 4/4 against Eric Dumazet's patch(ax88179_178a: avoid copy of tx tcp packets)
        - don't pass usbnet header as sg buffer

 drivers/net/usb/ax88179_178a.c |   12 ++++++++++++
 drivers/net/usb/usbnet.c       |   39 +++++++++++++++++++++++++++++++++++++--
 drivers/usb/core/urb.c         |    3 ++-
 drivers/usb/host/xhci.c        |    4 ++++
 include/linux/usb.h            |   11 ++++++++++-
 include/linux/usb/usbnet.h     |    1 +
 6 files changed, 66 insertions(+), 4 deletions(-)


Thanks,
--
Ming Lei
