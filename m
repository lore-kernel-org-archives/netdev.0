From: Kevin Cernekee <cernekee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH RESEND] kaweth: Fix memory leak in kaweth_control()
Date: Sat, 19 Sep 2009 14:18:21 -0700
Message-ID: <3317a2830541b564fef54730a60f85dc@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

kaweth_control() never frees the buffer that it allocates for the USB
control message.  Test case:

while :; do ifconfig eth2 down ; ifconfig eth2 up ; done

This is a tiny buffer so it is a slow leak.  If you want to speed up the
process, you can change the allocation size to e.g. 16384 bytes, and it
will consume several megabytes within a few minutes.

Signed-off-by: Kevin Cernekee <cernekee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Acked-by: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
---
 drivers/net/usb/kaweth.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index e2a39b9..e391ef9 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -263,6 +263,7 @@ static int kaweth_control(struct kaweth_device *kaweth,
 			  int timeout)
 {
 	struct usb_ctrlrequest *dr;
+	int retval;
 
 	dbg("kaweth_control()");
 
@@ -278,18 +279,21 @@ static int kaweth_control(struct kaweth_device *kaweth,
 		return -ENOMEM;
 	}
 
-	dr->bRequestType= requesttype;
+	dr->bRequestType = requesttype;
 	dr->bRequest = request;
 	dr->wValue = cpu_to_le16(value);
 	dr->wIndex = cpu_to_le16(index);
 	dr->wLength = cpu_to_le16(size);
 
-	return kaweth_internal_control_msg(kaweth->dev,
-					pipe,
-					dr,
-					data,
-					size,
-					timeout);
+	retval = kaweth_internal_control_msg(kaweth->dev,
+					     pipe,
+					     dr,
+					     data,
+					     size,
+					     timeout);
+
+	kfree(dr);
+	return retval;
 }
 
 /****************************************************************
-- 
1.6.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
