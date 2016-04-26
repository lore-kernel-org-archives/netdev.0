From: Petko Manolov <petkan@mip-labs.com>
Subject: [PATCH] Fixes buffer allocation size and the actual packet length;
Date: Tue, 26 Apr 2016 21:50:23 +0300
Message-ID: <1461696624-5373-1-git-send-email-petkan@mip-labs.com>
Cc: davem@davemloft.net, petkan@mip-labs.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:42246 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752347AbcDZSuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 14:50:39 -0400
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
multiple gigabytes of data over a couple of days without any complains from the 
kernel.

Petko Manolov (1):
  Fixes buffer allocation size and the actual packet length;

 drivers/net/usb/pegasus.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

-- 
2.8.0.rc3
