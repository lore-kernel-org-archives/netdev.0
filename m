From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 2/8] orinoco: Change orinoco_translate_scan() to return
 error code on error.
Date: Thu, 01 Sep 2005 20:02:50 -0400
Message-ID: <1125619370.24497.13.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

diff-tree 8fc038ec51acf5f777fade80c5e38112b766aeee (from ca955293cdfd3139e150d3b4fed3922a7eb651fb)
Author: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Date:   Thu Sep 1 19:10:12 2005 -0400

    Change orinoco_translate_scan() to return error code on error.
    Adjust the caller to check for errors and clean up if needed.

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -4023,11 +4023,12 @@ static int orinoco_ioctl_setscan(struct 
 	orinoco_unlock(priv, &flags);
 	return err;
 }
 
 /* Translate scan data returned from the card to a card independant
- * format that the Wireless Tools will understand - Jean II */
+ * format that the Wireless Tools will understand - Jean II
+ * Return message length or -errno for fatal errors */
 static inline int orinoco_translate_scan(struct net_device *dev,
 					 char *buffer,
 					 char *scan,
 					 int scan_len)
 {
@@ -4063,25 +4064,31 @@ static inline int orinoco_translate_scan
 			atom_len = 68;
 		offset = 0;
 		break;
 	case FIRMWARE_TYPE_INTERSIL:
 		offset = 4;
-		if (priv->has_hostscan)
-			atom_len = scan[0] + (scan[1] << 8);
-		else
+		if (priv->has_hostscan) {
+			atom_len = le16_to_cpup((u16 *)scan);
+			/* Sanity check for atom_len */
+			if (atom_len < sizeof(struct prism2_scan_apinfo)) {
+				printk(KERN_ERR "%s: Invalid atom_len in scan data: %d\n",
+				dev->name, atom_len);
+				return -EIO;
+			}
+		} else
 			atom_len = offsetof(struct prism2_scan_apinfo, atim);
 		break;
 	default:
-		return 0;
+		return -EOPNOTSUPP;
 	}
 
 	/* Check that we got an whole number of atoms */
 	if ((scan_len - offset) % atom_len) {
 		printk(KERN_ERR "%s: Unexpected scan data length %d, "
 		       "atom_len %d, offset %d\n", dev->name, scan_len,
 		       atom_len, offset);
-		return 0;
+		return -EIO;
 	}
 
 	/* Read the entries one by one */
 	for (; offset + atom_len <= scan_len; offset += atom_len) {
 		/* Get next atom */
@@ -4212,37 +4219,45 @@ static int orinoco_ioctl_getscan(struct 
 			err = -ENODATA;
 	} else {
 		/* We have some results to push back to user space */
 
 		/* Translate to WE format */
-		srq->length = orinoco_translate_scan(dev, extra,
-						     priv->scan_result,
-						     priv->scan_len);
-
-		/* Return flags */
-		srq->flags = (__u16) priv->scan_mode;
-
-		/* Results are here, so scan no longer in progress */
-		priv->scan_inprogress = 0;
-
-		/* In any case, Scan results will be cleaned up in the
-		 * reset function and when exiting the driver.
-		 * The person triggering the scanning may never come to
-		 * pick the results, so we need to do it in those places.
-		 * Jean II */
+		int ret = orinoco_translate_scan(dev, extra,
+						 priv->scan_result,
+						 priv->scan_len);
+
+		if (ret < 0) {
+			err = ret;
+			kfree(priv->scan_result);
+			priv->scan_result = NULL;
+		} else {
+			srq->length = ret;
+
+			/* Return flags */
+			srq->flags = (__u16) priv->scan_mode;
+
+			/* In any case, Scan results will be cleaned up in the
+			 * reset function and when exiting the driver.
+			 * The person triggering the scanning may never come to
+			 * pick the results, so we need to do it in those places.
+			 * Jean II */
 
 #ifdef SCAN_SINGLE_READ
-		/* If you enable this option, only one client (the first
-		 * one) will be able to read the result (and only one
-		 * time). If there is multiple concurent clients that
-		 * want to read scan results, this behavior is not
-		 * advisable - Jean II */
-		kfree(priv->scan_result);
-		priv->scan_result = NULL;
+			/* If you enable this option, only one client (the first
+			 * one) will be able to read the result (and only one
+			 * time). If there is multiple concurent clients that
+			 * want to read scan results, this behavior is not
+			 * advisable - Jean II */
+			kfree(priv->scan_result);
+			priv->scan_result = NULL;
 #endif /* SCAN_SINGLE_READ */
-		/* Here, if too much time has elapsed since last scan,
-		 * we may want to clean up scan results... - Jean II */
+			/* Here, if too much time has elapsed since last scan,
+			 * we may want to clean up scan results... - Jean II */
+		}
+
+		/* Scan is no longer in progress */
+		priv->scan_inprogress = 0;
 	}
 	  
 	orinoco_unlock(priv, &flags);
 	return err;
 }


-- 
Regards,
Pavel Roskin



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
