From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][2.4][ATM] cleanup atm_dev_ioctl a bit (from mitch@sfgoth.com)
Date: Tue, 16 Sep 2003 08:02:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309161202.h8GC2ASa012603@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1131  -> 1.1132 
#	 net/atm/resources.c	1.7     -> 1.8    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/14	chas@relax.cmf.nrl.navy.mil	1.1132
# resources.c:
#   [ATM]: cleanup atm_dev_ioctl a bit (from mitch@sfgoth.com)
# --------------------------------------------
#
diff -Nru a/net/atm/resources.c b/net/atm/resources.c
--- a/net/atm/resources.c	Mon Sep 15 16:17:02 2003
+++ b/net/atm/resources.c	Mon Sep 15 16:17:02 2003
@@ -214,42 +214,42 @@
 int atm_dev_ioctl(unsigned int cmd, unsigned long arg)
 {
 	void *buf;
-	int error, len, number, size = 0;
+	int error = 0, len, number, size = 0;
 	struct atm_dev *dev;
-	struct list_head *p;
-	int *tmp_buf, *tmp_p;
 
-	switch (cmd) {
-		case ATM_GETNAMES:
-			if (get_user(buf, &((struct atm_iobuf *) arg)->buffer))
-				return -EFAULT;
-			if (get_user(len, &((struct atm_iobuf *) arg)->length))
-				return -EFAULT;
-			spin_lock(&atm_dev_lock);
-			list_for_each(p, &atm_devs)
-				size += sizeof(int);
-			if (size > len) {
-				spin_unlock(&atm_dev_lock);
-				return -E2BIG;
-			}
-			tmp_buf = kmalloc(size, GFP_ATOMIC);
-			if (!tmp_buf) {
-				spin_unlock(&atm_dev_lock);
-				return -ENOMEM;
-			}
-			tmp_p = tmp_buf;
-			list_for_each(p, &atm_devs) {
-				dev = list_entry(p, struct atm_dev, dev_list);
-				*tmp_p++ = dev->number;
-			}
+	if (cmd == ATM_GETNAMES) {
+		int *tmp_buf, *tmp_bufp;
+		struct list_head *p;
+		/*
+		 * ATM_GETNAMES is a special case: it doesn't require a
+		 * device number argument
+		 */
+		if (get_user(buf, &((struct atm_iobuf *) arg)->buffer))
+			return -EFAULT;
+		if (get_user(len, &((struct atm_iobuf *) arg)->length))
+			return -EFAULT;
+		spin_lock(&atm_dev_lock);
+		list_for_each(p, &atm_devs)
+			size += sizeof(int);
+		if (size > len) {
 			spin_unlock(&atm_dev_lock);
-		        error = ((copy_to_user(buf, tmp_buf, size)) ||
-					put_user(size, &((struct atm_iobuf *) arg)->length))
-						? -EFAULT : 0;
-			kfree(tmp_buf);
-			return error;
-		default:
-			break;
+			return -E2BIG;
+		}
+		tmp_buf = tmp_bufp = kmalloc(size, GFP_ATOMIC);
+		if (!tmp_buf) {
+			spin_unlock(&atm_dev_lock);
+			return -ENOMEM;
+		}
+		list_for_each(p, &atm_devs) {
+			dev = list_entry(p, struct atm_dev, dev_list);
+			*tmp_bufp++ = dev->number;
+		}
+		spin_unlock(&atm_dev_lock);
+	        error = (copy_to_user(buf, tmp_buf, size) ||
+				put_user(size, &((struct atm_iobuf *) arg)->length))
+					? -EFAULT : 0;
+		kfree(tmp_buf);
+		return error;
 	}
 
 	if (get_user(buf, &((struct atmif_sioc *) arg)->arg))
@@ -361,11 +361,8 @@
 			if (error < 0)
 				goto done;
 			size = error;
-			/* may return 0, but later on size == 0 means "don't
-			   write the length" */
-			error = put_user(size, &((struct atmif_sioc *) arg)->length)
-				? -EFAULT : 0;
-			goto done;
+			/* write back size even if it's zero */
+			goto write_size;
 		case ATM_SETLOOP:
 			if (__ATM_LM_XTRMT((int) (long) buf) &&
 			    __ATM_LM_XTLOC((int) (long) buf) >
@@ -396,11 +393,12 @@
 			}
 	}
 	
-	if (size)
-		error = put_user(size, &((struct atmif_sioc *) arg)->length)
-			? -EFAULT : 0;
-	else
-		error = 0;
+	if (size) {
+write_size:
+		error = put_user(size,
+			  &((struct atmif_sioc *) arg)->length)
+			  ? -EFAULT : 0;
+	}
 done:
 	atm_dev_release(dev);
 	return error;
