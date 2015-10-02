From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: [PATCH v1 0/5] Improve ASIX RX memory allocation error handling
Date: Fri, 2 Oct 2015 14:39:39 +0100
Message-ID: <1443793179-3895-1-git-send-email-Dean_Jenkins@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-usb@vger.kernel.org>, <ben.hutchings@codethink.co.uk>,
	<davem@davemloft.net>, <bjorn@mork.no>, <linux@davidrobins.net>,
	Mark Craske <Mark_Craske@mentor.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:49195 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033AbbJBNm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 09:42:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Craske <Mark_Craske@mentor.com>

Please ignore the cover letter PATCH v2 as sent in error.
Patches are all v1, (there are no v2 patches yet)

The ASIX RX handler algorithm is weak on error handling.
There is a design flaw in the ASIX RX handler algorithm because the
implementation for handling RX Ethernet frames for the DUB-E100 C1 can
have Ethernet frames spanning multiple URBs. This means that payload data
from more than 1 URB is sometimes needed to fill the socket buffer with a
complete Ethernet frame. When the URB with the start of an Ethernet frame
is received then an attempt is made to allocate a socket buffer. If the
memory allocation fails then the algorithm sets the buffer pointer member
to NULL and the function exits (no crash yet). Subsequently, the RX hander
is called again to process the next URB which assumes there is a socket
buffer available and the kernel crashes when there is no buffer.

This patchset implements an improvement to the RX handling algorithm to
avoid a crash when no memory is available for the socket buffer.

The patchset will apply cleanly to the net-next master branch but the
created kernel has not been tested. The driver was tested on ARM kernels
v3.8 and v3.14 for a commercial product.

Dean Jenkins (5):
  asix: Rename remaining and size for clarity
  asix: Tidy-up 32-bit header word synchronisation
  asix: Simplify asix_rx_fixup_internal() netdev alloc
  asix: On RX avoid creating bad Ethernet frames
  asix: Continue processing URB if no RX netdev buffer

 drivers/net/usb/asix.h        |    2 +-
 drivers/net/usb/asix_common.c |  114 ++++++++++++++++++++++++++---------------
 2 files changed, 74 insertions(+), 42 deletions(-)

-- 
1.7.9.5
