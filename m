From: Petko Manolov <petkan@mip-labs.com>
Subject: [PATCH v2 0/2] pegasus: correct buffer sizes
Date: Wed, 27 Apr 2016 10:35:23 +0300
Message-ID: <1461742525-2748-1-git-send-email-petkan@mip-labs.com>
Cc: davem@davemloft.net, a1291762@gmail.com,
	Petko Manolov <petkan@mip-labs.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:42416 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752621AbcD0Hff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 03:35:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As noticed by Lincoln Ramsay <a1291762@gmail.com> some old (usb 1.1) Pegasus 
based devices may actually return more bytes than the specified in the datasheet 
amount.  That would not be a problem if the allocated space for the SKB was 
equal to the parameter passed to usb_fill_bulk_urb().  Some poor bugger (i 
really hope it was not me, but 'git blame' is useless in this case, so anyway) 
decided to add '+ 8' to the buffer length parameter.  Sometimes the usb transfer 
overflows and corrupts the socket structure, leading to kernel panic.

The above doesn't seem to happen for newer (Pegasus2 based) devices which did 
help this bug to hide for so long.

Nearly all Pegasus devices may append the RX status to the end of the received 
packet.  It is the default setup for the driver.  The actual ethernet packet is 
4 bytes shorter.  Why and when 'pkt_len -= 4' became 'pkt_len -= 8' is again 
hidden in the mists of time.  There might have been a good reason to do so, but 
multiple reads of the datasheet did not point me to any.

The patch is against v4.6-rc5 and was tested on ADM8515 device by transferring 
multiple gigabytes of data over a couple of days without any complaints from the 
kernel.

Changes since v1:

 - split the patch in two parts;
 - corrected the subject lines;

Petko Manolov (2):
  pegasus: fixes URB buffer allocation size;
  pegasus: fixes reported packet length

 drivers/net/usb/pegasus.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

-- 
2.8.0.rc3
