From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [WEXT 4/12]: Extract private call iw_point handling into seperate
 functions.
Date: Fri, 21 Dec 2007 20:54:29 -0800 (PST)
Message-ID: <20071221.205429.175484002.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


[WEXT]: Extract private call iw_point handling into seperate functions.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 net/wireless/wext.c |  141 +++++++++++++++++++++++++++------------------------
 1 files changed, 74 insertions(+), 67 deletions(-)

diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index a6369f3..9c3d83f 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -922,25 +922,22 @@ static int ioctl_standard_call(struct net_device *	dev,
  * a iw_handler but process it in your ioctl handler (i.e. use the
  * old driver API).
  */
-static int ioctl_private_call(struct net_device *dev, struct ifreq *ifr,
-			      unsigned int cmd, iw_handler handler)
+static int get_priv_descr_and_size(struct net_device *dev, unsigned int cmd,
+				   const struct iw_priv_args **descrp)
 {
-	struct iwreq *			iwr = (struct iwreq *) ifr;
-	const struct iw_priv_args *	descr = NULL;
-	struct iw_request_info		info;
-	int				extra_size = 0;
-	int				i;
-	int				ret = -EINVAL;
+	const struct iw_priv_args *descr;
+	int i, extra_size;
 
-	/* Get the description of the IOCTL */
-	for (i = 0; i < dev->wireless_handlers->num_private_args; i++)
+	descr = NULL;
+	for (i = 0; i < dev->wireless_handlers->num_private_args; i++) {
 		if (cmd == dev->wireless_handlers->private_args[i].cmd) {
-			descr = &(dev->wireless_handlers->private_args[i]);
+			descr = &dev->wireless_handlers->private_args[i];
 			break;
 		}
+	}
 
-	/* Compute the size of the set/get arguments */
-	if (descr != NULL) {
+	extra_size = 0;
+	if (descr) {
 		if (IW_IS_SET(cmd)) {
 			int	offset = 0;	/* For sub-ioctls */
 			/* Check for sub-ioctl handler */
@@ -965,72 +962,82 @@ static int ioctl_private_call(struct net_device *dev, struct ifreq *ifr,
 				extra_size = 0;
 		}
 	}
+	*descrp = descr;
+	return extra_size;
+}
 
-	/* Prepare the call */
-	info.cmd = cmd;
-	info.flags = 0;
+static int ioctl_private_iw_point(struct iw_point *iwp, unsigned int cmd,
+				  const struct iw_priv_args *descr,
+				  iw_handler handler, struct net_device *dev,
+				  struct iw_request_info *info, int extra_size)
+{
+	char *extra;
+	int err;
 
-	/* Check if we have a pointer to user space data or not. */
-	if (extra_size == 0) {
-		/* No extra arguments. Trivial to handle */
-		ret = handler(dev, &info, &(iwr->u), (char *) &(iwr->u));
-	} else {
-		char *	extra;
-		int	err;
+	/* Check what user space is giving us */
+	if (IW_IS_SET(cmd)) {
+		if (!iwp->pointer && iwp->length != 0)
+			return -EFAULT;
 
-		/* Check what user space is giving us */
-		if (IW_IS_SET(cmd)) {
-			/* Check NULL pointer */
-			if ((iwr->u.data.pointer == NULL) &&
-			   (iwr->u.data.length != 0))
-				return -EFAULT;
+		if (iwp->length > (descr->set_args & IW_PRIV_SIZE_MASK))
+			return -E2BIG;
+	} else if (!iwp->pointer)
+		return -EFAULT;
 
-			/* Does it fits within bounds ? */
-			if (iwr->u.data.length > (descr->set_args &
-						 IW_PRIV_SIZE_MASK))
-				return -E2BIG;
-		} else if (iwr->u.data.pointer == NULL)
-			return -EFAULT;
+	extra = kmalloc(extra_size, GFP_KERNEL);
+	if (!extra)
+		return -ENOMEM;
 
-		/* Always allocate for max space. Easier, and won't last
-		 * long... */
-		extra = kmalloc(extra_size, GFP_KERNEL);
-		if (extra == NULL)
-			return -ENOMEM;
-
-		/* If it is a SET, get all the extra data in here */
-		if (IW_IS_SET(cmd) && (iwr->u.data.length != 0)) {
-			err = copy_from_user(extra, iwr->u.data.pointer,
-					     extra_size);
-			if (err) {
-				kfree(extra);
-				return -EFAULT;
-			}
+	/* If it is a SET, get all the extra data in here */
+	if (IW_IS_SET(cmd) && (iwp->length != 0)) {
+		if (copy_from_user(extra, iwp->pointer, extra_size)) {
+			err = -EFAULT;
+			goto out;
 		}
+	}
 
-		/* Call the handler */
-		ret = handler(dev, &info, &(iwr->u), extra);
+	/* Call the handler */
+	err = handler(dev, info, (union iwreq_data *) iwp, extra);
 
-		/* If we have something to return to the user */
-		if (!ret && IW_IS_GET(cmd)) {
+	/* If we have something to return to the user */
+	if (!err && IW_IS_GET(cmd)) {
+		/* Adjust for the actual length if it's variable,
+		 * avoid leaking kernel bits outside.
+		 */
+		if (!(descr->get_args & IW_PRIV_SIZE_FIXED))
+			extra_size = adjust_priv_size(descr->get_args, iwp);
 
-			/* Adjust for the actual length if it's variable,
-			 * avoid leaking kernel bits outside. */
-			if (!(descr->get_args & IW_PRIV_SIZE_FIXED)) {
-				extra_size = adjust_priv_size(descr->get_args,
-							      &(iwr->u.data));
-			}
+		if (copy_to_user(iwp->pointer, extra, extra_size))
+			err =  -EFAULT;
+	}
 
-			err = copy_to_user(iwr->u.data.pointer, extra,
-					   extra_size);
-			if (err)
-				ret =  -EFAULT;
-		}
+out:
+	kfree(extra);
+	return err;
+}
 
-		/* Cleanup - I told you it wasn't that long ;-) */
-		kfree(extra);
-	}
+static int ioctl_private_call(struct net_device *dev, struct ifreq *ifr,
+			      unsigned int cmd, iw_handler handler)
+{
+	struct iwreq *iwr = (struct iwreq *) ifr;
+	int extra_size = 0, ret = -EINVAL;
+	const struct iw_priv_args *descr;
+	struct iw_request_info info;
+
+	extra_size = get_priv_descr_and_size(dev, cmd, &descr);
+
+	/* Prepare the call */
+	info.cmd = cmd;
+	info.flags = 0;
 
+	/* Check if we have a pointer to user space data or not. */
+	if (extra_size == 0) {
+		/* No extra arguments. Trivial to handle */
+		ret = handler(dev, &info, &(iwr->u), (char *) &(iwr->u));
+	} else {
+		ret = ioctl_private_iw_point(&iwr->u.data, cmd, descr,
+					     handler, dev, &info, extra_size);
+	}
 
 	/* Call commit handler if needed and defined */
 	if (ret == -EIWCOMMIT)
-- 
1.5.4.rc1
