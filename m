From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: [PATCH 0/4] asix: Fix support for C1 DUB-E100
Date: Wed, 11 Dec 2013 10:50:24 +0000
Message-ID: <1386759028-3534-1-git-send-email-Dean_Jenkins@mentor.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway05.m3-connect.de ([88.79.237.15]:46569 "EHLO
	mail.mentor.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751508Ab3LKK7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 05:59:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A simple ping test shows that support for the C1 DUB-E100 is broken.

ping -c 200 -s 1965 -f 172.17.0.10

The -s 1965 forces the USB Ethernet adaptor to use a worse case 2049 octet
bulk transfer due to the transfer containing 2 Ethernet frames. Unfortunately
the URB buffer is 2048 bytes long so the last byte of the 2nd Ethernet frame
is lost.

The missing byte causes a "Bad Header" error message to be generated during 
the processing of the next socket buffer. However, the truncated frame has 1
byte erroneously appended from the next socket buffer and this now corrupted
RX frame is passed up to the network layer. Worse, the next socket buffer is
discarded with the probable loss of a good Ethernet frame.

The patchset consists of the following 4 patches which should apply cleanly
to the net-next git repo baseline at 5824d2d:

Dean Jenkins (4):
      asix: Rename remaining and size for clarity
      asix: Tidy-up asix_rx_fixup_internal() logic
      asix: On RX avoid creating bad Ethernet frames
      asix: C1 DUB-E100 double rx_urb_size to 4096

 drivers/net/usb/asix.h         |    2 +-
 drivers/net/usb/asix_common.c  |  104 ++++++++++++++++++++++++----------------
 drivers/net/usb/asix_devices.c |    5 +-
 3 files changed, 69 insertions(+), 42 deletions(-)

Summary of patches:

1. asix: Rename remaining and size for clarity

This patch effectively swaps the variables "remaining" and "size" to make the
code more understandable. A new local variable "copy_length" is added as the
transfer length from the socket buffer to the netdev buffer.

2. asix: Tidy-up asix_rx_fixup_internal() logic

This patch does a tidy-up of the asix_rx_fixup_internal() logic to remove
redundant logic. The tidy-up improves the implementation of the logic but
does not "fix" a logic flaw. In other words, the original code has redundant
logic.

3. asix: On RX avoid creating bad Ethernet frames

This patch prevents creation of a bad Ethernet frame in the netdev buffer
when the "Bad Header" error handling is triggered. The netdev buffer is
discarded to prevent consumption of the bad Ethernet frame. Also the current
socket buffer is not discarded so the next Ethernet frame can be processed.

Add a new error message to indicate a loss of synchronisation of the 32-bit
Data header word.

4. asix: C1 DUB-E100 double rx_urb_size to 4096

This patch prevents the truncation of the URB when the bulk transfer
contains 2 Ethernet frames by using a 4096 byte RX URB. In other words,
the 2048 URB size was too small.
