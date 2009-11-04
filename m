From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/5 09/12] wimax/i2400m: handle USB stalls
Date: Wed,  4 Nov 2009 13:40:14 -0800
Message-ID: <faf57162e462eafe87458e21bf641f9d138f8171.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:28863 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932799AbZKDVmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:20 -0500
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the device stalls, clear it and retry; if it keeps failing too
often, reset the device.

This specially happens when running on virtual machines; the real
hardware doesn't seem to trip on stalls too much, except for a few
reports in the mailing list (still to be confirmed this is the cause,
although it seems likely.

NOTE: it is not clear if the URB has to be resubmitted fully or start
only at the offset of the first transaction sent. Can't find
documentation to clarify one end or the other.

Tests that just resubmit the whole URB seemed to work in my
environment.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/usb-fw.c |   22 ++++++++++++++
 drivers/net/wimax/i2400m/usb-rx.c |   21 +++++++++++++
 drivers/net/wimax/i2400m/usb-tx.c |   22 ++++++++++++++
 drivers/net/wimax/i2400m/usb.c    |   57 +++++++++++++++++++++++++++++++++----
 4 files changed, 116 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wimax/i2400m/usb-fw.c b/drivers/net/wimax/i2400m/usb-fw.c
index 8ec8b6d..d8f6ce2 100644
--- a/drivers/net/wimax/i2400m/usb-fw.c
+++ b/drivers/net/wimax/i2400m/usb-fw.c
@@ -113,6 +113,28 @@ retry:
 		}
 		result = len;
 		break;
+	case -EPIPE:
+		/*
+		 * Stall -- maybe the device is choking with our
+		 * requests. Clear it and give it some time. If they
+		 * happen to often, it might be another symptom, so we
+		 * reset.
+		 *
+		 * No error handling for usb_clear_halt(0; if it
+		 * works, the retry works; if it fails, this switch
+		 * does the error handling for us.
+		 */
+		if (edc_inc(&i2400mu->urb_edc,
+			    10 * EDC_MAX_ERRORS, EDC_ERROR_TIMEFRAME)) {
+			dev_err(dev, "BM-CMD: too many stalls in "
+				"URB; resetting device\n");
+			usb_queue_reset_device(i2400mu->usb_iface);
+			/* fallthrough */
+		} else {
+			usb_clear_halt(i2400mu->usb_dev, pipe);
+			msleep(10);	/* give the device some time */
+			goto retry;
+		}
 	case -EINVAL:			/* while removing driver */
 	case -ENODEV:			/* dev disconnect ... */
 	case -ENOENT:			/* just ignore it */
diff --git a/drivers/net/wimax/i2400m/usb-rx.c b/drivers/net/wimax/i2400m/usb-rx.c
index 22d127b..ba1b023 100644
--- a/drivers/net/wimax/i2400m/usb-rx.c
+++ b/drivers/net/wimax/i2400m/usb-rx.c
@@ -222,6 +222,26 @@ retry:
 			goto retry;	/* ZLP, just resubmit */
 		skb_put(rx_skb, read_size);
 		break;
+	case -EPIPE:
+		/*
+		 * Stall -- maybe the device is choking with our
+		 * requests. Clear it and give it some time. If they
+		 * happen to often, it might be another symptom, so we
+		 * reset.
+		 *
+		 * No error handling for usb_clear_halt(0; if it
+		 * works, the retry works; if it fails, this switch
+		 * does the error handling for us.
+		 */
+		if (edc_inc(&i2400mu->urb_edc,
+			    10 * EDC_MAX_ERRORS, EDC_ERROR_TIMEFRAME)) {
+			dev_err(dev, "BM-CMD: too many stalls in "
+				"URB; resetting device\n");
+			goto do_reset;
+		}
+		usb_clear_halt(i2400mu->usb_dev, usb_pipe);
+		msleep(10);	/* give the device some time */
+		goto retry;
 	case -EINVAL:			/* while removing driver */
 	case -ENODEV:			/* dev disconnect ... */
 	case -ENOENT:			/* just ignore it */
@@ -283,6 +303,7 @@ out:
 error_reset:
 	dev_err(dev, "RX: maximum errors in URB exceeded; "
 		"resetting device\n");
+do_reset:
 	usb_queue_reset_device(i2400mu->usb_iface);
 	rx_skb = ERR_PTR(result);
 	goto out;
diff --git a/drivers/net/wimax/i2400m/usb-tx.c b/drivers/net/wimax/i2400m/usb-tx.c
index 6cdf003..c65b997 100644
--- a/drivers/net/wimax/i2400m/usb-tx.c
+++ b/drivers/net/wimax/i2400m/usb-tx.c
@@ -115,6 +115,28 @@ retry:
 			result = -EIO;
 		}
 		break;
+	case -EPIPE:
+		/*
+		 * Stall -- maybe the device is choking with our
+		 * requests. Clear it and give it some time. If they
+		 * happen to often, it might be another symptom, so we
+		 * reset.
+		 *
+		 * No error handling for usb_clear_halt(0; if it
+		 * works, the retry works; if it fails, this switch
+		 * does the error handling for us.
+		 */
+		if (edc_inc(&i2400mu->urb_edc,
+			    10 * EDC_MAX_ERRORS, EDC_ERROR_TIMEFRAME)) {
+			dev_err(dev, "BM-CMD: too many stalls in "
+				"URB; resetting device\n");
+			usb_queue_reset_device(i2400mu->usb_iface);
+			/* fallthrough */
+		} else {
+			usb_clear_halt(i2400mu->usb_dev, usb_pipe);
+			msleep(10);	/* give the device some time */
+			goto retry;
+		}
 	case -EINVAL:			/* while removing driver */
 	case -ENODEV:			/* dev disconnect ... */
 	case -ENOENT:			/* just ignore it */
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 34df090..47e84ef 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -172,14 +172,59 @@ int __i2400mu_send_barker(struct i2400mu *i2400mu,
 	epd = usb_get_epd(i2400mu->usb_iface, endpoint);
 	pipe = usb_sndbulkpipe(i2400mu->usb_dev, epd->bEndpointAddress);
 	memcpy(buffer, barker, barker_size);
+retry:
 	ret = usb_bulk_msg(i2400mu->usb_dev, pipe, buffer, barker_size,
 			   &actual_len, 200);
-	if (ret < 0) {
-		if (ret != -EINVAL)
-			dev_err(dev, "E: barker error: %d\n", ret);
-	} else if (actual_len != barker_size) {
-		dev_err(dev, "E: only %d bytes transmitted\n", actual_len);
-		ret = -EIO;
+	switch (ret) {
+	case 0:
+		if (actual_len != barker_size) {	/* Too short? drop it */
+			dev_err(dev, "E: %s: short write (%d B vs %zu "
+				"expected)\n",
+				__func__, actual_len, barker_size);
+			ret = -EIO;
+		}
+		break;
+	case -EPIPE:
+		/*
+		 * Stall -- maybe the device is choking with our
+		 * requests. Clear it and give it some time. If they
+		 * happen to often, it might be another symptom, so we
+		 * reset.
+		 *
+		 * No error handling for usb_clear_halt(0; if it
+		 * works, the retry works; if it fails, this switch
+		 * does the error handling for us.
+		 */
+		if (edc_inc(&i2400mu->urb_edc,
+			    10 * EDC_MAX_ERRORS, EDC_ERROR_TIMEFRAME)) {
+			dev_err(dev, "E: %s: too many stalls in "
+				"URB; resetting device\n", __func__);
+			usb_queue_reset_device(i2400mu->usb_iface);
+			/* fallthrough */
+		} else {
+			usb_clear_halt(i2400mu->usb_dev, pipe);
+			msleep(10);	/* give the device some time */
+			goto retry;
+		}
+	case -EINVAL:			/* while removing driver */
+	case -ENODEV:			/* dev disconnect ... */
+	case -ENOENT:			/* just ignore it */
+	case -ESHUTDOWN:		/* and exit */
+	case -ECONNRESET:
+		ret = -ESHUTDOWN;
+		break;
+	default:			/* Some error? */
+		if (edc_inc(&i2400mu->urb_edc,
+			    EDC_MAX_ERRORS, EDC_ERROR_TIMEFRAME)) {
+			dev_err(dev, "E: %s: maximum errors in URB "
+				"exceeded; resetting device\n",
+				__func__);
+			usb_queue_reset_device(i2400mu->usb_iface);
+		} else {
+			dev_warn(dev, "W: %s: cannot send URB: %d\n",
+				 __func__, ret);
+			goto retry;
+		}
 	}
 	kfree(buffer);
 error_kzalloc:
-- 
1.6.2.5

