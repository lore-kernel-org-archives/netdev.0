From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] USB: kaweth.c: use GFP_ATOMIC under spin_lock
Date: Fri, 27 Jul 2012 14:46:51 +0300
Message-ID: <20120727114651.GA15492@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:22911 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432Ab2G0LrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 07:47:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem is that we call this with a spin lock held.  The call tree
is:
	kaweth_start_xmit() holds kaweth->device_lock.
	-> kaweth_async_set_rx_mode()
	   -> kaweth_control()
	      -> kaweth_internal_control_msg()

The kaweth_internal_control_msg() function is only called from
kaweth_control() which used GFP_ATOMIC for its allocations.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Applies to Linus's tree.

diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index d8ad552..c3d0349 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -1314,7 +1314,7 @@ static int kaweth_internal_control_msg(struct usb_device *usb_dev,
         int retv;
         int length = 0; /* shut up GCC */
 
-        urb = usb_alloc_urb(0, GFP_NOIO);
+	urb = usb_alloc_urb(0, GFP_ATOMIC);
         if (!urb)
                 return -ENOMEM;
 
