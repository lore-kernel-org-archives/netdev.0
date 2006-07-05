From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: usb_clear_halt not allowed in IRQ context
Date: Wed,  5 Jul 2006 15:57:39 +0100 (BST)
Message-ID: <20060705145739.DF3148AFF50@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:55607 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S964896AbWGEO5h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 10:57:37 -0400
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We will reimplement halt-clearing later, when we have periodic
housekeeping routines in place. This will do as a temporary fix, the
EPIPE case has not yet been seen.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index ce1cb2c..72f9052 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -375,10 +375,8 @@ static void int_urb_complete(struct urb 
 	case -ENODEV:
 	case -ENOENT:
 	case -ECONNRESET:
-		goto kfree;
 	case -EPIPE:
-		usb_clear_halt(urb->dev, EP_INT_IN);
-		/* FALL-THROUGH */
+		goto kfree;
 	default:
 		goto resubmit;
 	}
@@ -580,10 +578,8 @@ static void rx_urb_complete(struct urb *
 	case -ENODEV:
 	case -ENOENT:
 	case -ECONNRESET:
-		return;
 	case -EPIPE:
-		usb_clear_halt(urb->dev, EP_DATA_IN);
-		/* FALL-THROUGH */
+		return;
 	default:
 		dev_dbg_f(urb_dev(urb), "urb %p error %d\n", urb, urb->status);
 		goto resubmit;
@@ -749,11 +745,9 @@ static void tx_urb_complete(struct urb *
 	case -ENODEV:
 	case -ENOENT:
 	case -ECONNRESET:
+	case -EPIPE:
 		dev_dbg_f(urb_dev(urb), "urb %p error %d\n", urb, urb->status);
 		break;
-	case -EPIPE:
-		usb_clear_halt(urb->dev, EP_DATA_OUT);
-		/* FALL-THROUGH */
 	default:
 		dev_dbg_f(urb_dev(urb), "urb %p error %d\n", urb, urb->status);
 		goto resubmit;
