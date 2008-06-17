From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/12]: wext: Extract standard call iw_point handling into
 seperate function.
Date: Tue, 17 Jun 2008 00:53:27 -0700 (PDT)
Message-ID: <20080617.005327.160757413.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mokuno@sm.sony.co.jp, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56464
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752440AbYFQHx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 03:53:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


wext: Extract standard call iw_point handling into seperate function.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/wireless/wext.c |  258 ++++++++++++++++++++++++++------------------------
 1 files changed, 134 insertions(+), 124 deletions(-)

diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index cd2cf9f..d17c0f4 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -694,6 +694,138 @@ void wext_proc_exit(struct net *net)
  */
 
 /* ---------------------------------------------------------------- */
+static int ioctl_standard_iw_point(struct iw_point *iwp, unsigned int cmd,
+				   const struct iw_ioctl_description *descr,
+				   iw_handler handler, struct net_device *dev,
+				   struct iw_request_info *info)
+{
+	int err, extra_size, user_length = 0, essid_compat = 0;
+	char *extra;
+
+	/* Calculate space needed by arguments. Always allocate
+	 * for max space.
+	 */
+	extra_size = descr->max_tokens * descr->token_size;
+
+	/* Check need for ESSID compatibility for WE < 21 */
+	switch (cmd) {
+	case SIOCSIWESSID:
+	case SIOCGIWESSID:
+	case SIOCSIWNICKN:
+	case SIOCGIWNICKN:
+		if (iwp->length == descr->max_tokens + 1)
+			essid_compat = 1;
+		else if (IW_IS_SET(cmd) && (iwp->length != 0)) {
+			char essid[IW_ESSID_MAX_SIZE + 1];
+
+			err = copy_from_user(essid, iwp->pointer,
+					     iwp->length *
+					     descr->token_size);
+			if (err)
+				return -EFAULT;
+
+			if (essid[iwp->length - 1] == '\0')
+				essid_compat = 1;
+		}
+		break;
+	default:
+		break;
+	}
+
+	iwp->length -= essid_compat;
+
+	/* Check what user space is giving us */
+	if (IW_IS_SET(cmd)) {
+		/* Check NULL pointer */
+		if (!iwp->pointer && iwp->length != 0)
+			return -EFAULT;
+		/* Check if number of token fits within bounds */
+		if (iwp->length > descr->max_tokens)
+			return -E2BIG;
+		if (iwp->length < descr->min_tokens)
+			return -EINVAL;
+	} else {
+		/* Check NULL pointer */
+		if (!iwp->pointer)
+			return -EFAULT;
+		/* Save user space buffer size for checking */
+		user_length = iwp->length;
+
+		/* Don't check if user_length > max to allow forward
+		 * compatibility. The test user_length < min is
+		 * implied by the test at the end.
+		 */
+
+		/* Support for very large requests */
+		if ((descr->flags & IW_DESCR_FLAG_NOMAX) &&
+		    (user_length > descr->max_tokens)) {
+			/* Allow userspace to GET more than max so
+			 * we can support any size GET requests.
+			 * There is still a limit : -ENOMEM.
+			 */
+			extra_size = user_length * descr->token_size;
+
+			/* Note : user_length is originally a __u16,
+			 * and token_size is controlled by us,
+			 * so extra_size won't get negative and
+			 * won't overflow...
+			 */
+		}
+	}
+
+	/* kzalloc() ensures NULL-termination for essid_compat. */
+	extra = kzalloc(extra_size, GFP_KERNEL);
+	if (!extra)
+		return -ENOMEM;
+
+	/* If it is a SET, get all the extra data in here */
+	if (IW_IS_SET(cmd) && (iwp->length != 0)) {
+		if (copy_from_user(extra, iwp->pointer,
+				   iwp->length *
+				   descr->token_size)) {
+			err = -EFAULT;
+			goto out;
+		}
+	}
+
+	err = handler(dev, info, (union iwreq_data *) iwp, extra);
+
+	iwp->length += essid_compat;
+
+	/* If we have something to return to the user */
+	if (!err && IW_IS_GET(cmd)) {
+		/* Check if there is enough buffer up there */
+		if (user_length < iwp->length) {
+			err = -E2BIG;
+			goto out;
+		}
+
+		if (copy_to_user(iwp->pointer, extra,
+				 iwp->length *
+				 descr->token_size)) {
+			err = -EFAULT;
+			goto out;
+		}
+	}
+
+	/* Generate an event to notify listeners of the change */
+	if ((descr->flags & IW_DESCR_FLAG_EVENT) && err == -EIWCOMMIT) {
+		union iwreq_data *data = (union iwreq_data *) iwp;
+
+		if (descr->flags & IW_DESCR_FLAG_RESTRICT)
+			/* If the event is restricted, don't
+			 * export the payload.
+			 */
+			wireless_send_event(dev, cmd, data, NULL);
+		else
+			wireless_send_event(dev, cmd, data, extra);
+	}
+
+out:
+	kfree(extra);
+	return err;
+}
+
 /*
  * Wrapper to call a standard Wireless Extension handler.
  * We do various checks and also take care of moving data between
@@ -729,130 +861,8 @@ static int ioctl_standard_call(struct net_device *	dev,
 		   ((ret == 0) || (ret == -EIWCOMMIT)))
 			wireless_send_event(dev, cmd, &(iwr->u), NULL);
 	} else {
-		char *	extra;
-		int	extra_size;
-		int	user_length = 0;
-		int	err;
-		int	essid_compat = 0;
-
-		/* Calculate space needed by arguments. Always allocate
-		 * for max space. Easier, and won't last long... */
-		extra_size = descr->max_tokens * descr->token_size;
-
-		/* Check need for ESSID compatibility for WE < 21 */
-		switch (cmd) {
-		case SIOCSIWESSID:
-		case SIOCGIWESSID:
-		case SIOCSIWNICKN:
-		case SIOCGIWNICKN:
-			if (iwr->u.data.length == descr->max_tokens + 1)
-				essid_compat = 1;
-			else if (IW_IS_SET(cmd) && (iwr->u.data.length != 0)) {
-				char essid[IW_ESSID_MAX_SIZE + 1];
-
-				err = copy_from_user(essid, iwr->u.data.pointer,
-						     iwr->u.data.length *
-						     descr->token_size);
-				if (err)
-					return -EFAULT;
-
-				if (essid[iwr->u.data.length - 1] == '\0')
-					essid_compat = 1;
-			}
-			break;
-		default:
-			break;
-		}
-
-		iwr->u.data.length -= essid_compat;
-
-		/* Check what user space is giving us */
-		if (IW_IS_SET(cmd)) {
-			/* Check NULL pointer */
-			if ((iwr->u.data.pointer == NULL) &&
-			   (iwr->u.data.length != 0))
-				return -EFAULT;
-			/* Check if number of token fits within bounds */
-			if (iwr->u.data.length > descr->max_tokens)
-				return -E2BIG;
-			if (iwr->u.data.length < descr->min_tokens)
-				return -EINVAL;
-		} else {
-			/* Check NULL pointer */
-			if (iwr->u.data.pointer == NULL)
-				return -EFAULT;
-			/* Save user space buffer size for checking */
-			user_length = iwr->u.data.length;
-
-			/* Don't check if user_length > max to allow forward
-			 * compatibility. The test user_length < min is
-			 * implied by the test at the end. */
-
-			/* Support for very large requests */
-			if ((descr->flags & IW_DESCR_FLAG_NOMAX) &&
-			   (user_length > descr->max_tokens)) {
-				/* Allow userspace to GET more than max so
-				 * we can support any size GET requests.
-				 * There is still a limit : -ENOMEM. */
-				extra_size = user_length * descr->token_size;
-				/* Note : user_length is originally a __u16,
-				 * and token_size is controlled by us,
-				 * so extra_size won't get negative and
-				 * won't overflow... */
-			}
-		}
-
-		/* Create the kernel buffer */
-		/*    kzalloc ensures NULL-termination for essid_compat */
-		extra = kzalloc(extra_size, GFP_KERNEL);
-		if (extra == NULL)
-			return -ENOMEM;
-
-		/* If it is a SET, get all the extra data in here */
-		if (IW_IS_SET(cmd) && (iwr->u.data.length != 0)) {
-			err = copy_from_user(extra, iwr->u.data.pointer,
-					     iwr->u.data.length *
-					     descr->token_size);
-			if (err) {
-				kfree(extra);
-				return -EFAULT;
-			}
-		}
-
-		/* Call the handler */
-		ret = handler(dev, &info, &(iwr->u), extra);
-
-		iwr->u.data.length += essid_compat;
-
-		/* If we have something to return to the user */
-		if (!ret && IW_IS_GET(cmd)) {
-			/* Check if there is enough buffer up there */
-			if (user_length < iwr->u.data.length) {
-				kfree(extra);
-				return -E2BIG;
-			}
-
-			err = copy_to_user(iwr->u.data.pointer, extra,
-					   iwr->u.data.length *
-					   descr->token_size);
-			if (err)
-				ret =  -EFAULT;
-		}
-
-		/* Generate an event to notify listeners of the change */
-		if ((descr->flags & IW_DESCR_FLAG_EVENT) &&
-		   ((ret == 0) || (ret == -EIWCOMMIT))) {
-			if (descr->flags & IW_DESCR_FLAG_RESTRICT)
-				/* If the event is restricted, don't
-				 * export the payload */
-				wireless_send_event(dev, cmd, &(iwr->u), NULL);
-			else
-				wireless_send_event(dev, cmd, &(iwr->u),
-						    extra);
-		}
-
-		/* Cleanup - I told you it wasn't that long ;-) */
-		kfree(extra);
+		ret = ioctl_standard_iw_point(&iwr->u.data, cmd, descr,
+					      handler, dev, &info);
 	}
 
 	/* Call commit handler if needed and defined */
-- 
1.5.5.1.308.g1fbb5

