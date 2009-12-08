From: Joe Perches <joe@perches.com>
Subject: [PATCH 17/20] net/atm/resources.c: checkpatch cleanups
Date: Mon,  7 Dec 2009 21:57:13 -0800
Message-ID: <bc508b257d72562e0cfeccd2f3390de07d044c90.1260251570.git.joe@perches.com>
References: <cover.1260251570.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1048 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932682AbZLHF5P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 00:57:15 -0500
In-Reply-To: <cover.1260251570.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Includes some or all of these:

Mostly 80 column wrapped.
printk->pr_info and pr_cont
Use print_hex_dump
Use __func__ for embedded print strings
Move embedded assigns out of tests
Move trailing statements to new lines
switch/case cleanups
    removed breaks after returns
Removed paren around returns
Use %pM
Moved leading continuation logical tests to end of previous line

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/resources.c |  390 +++++++++++++++++++++++++--------------------------
 1 files changed, 192 insertions(+), 198 deletions(-)

diff --git a/net/atm/resources.c b/net/atm/resources.c
index 0d4c0ee..447ed89 100644
--- a/net/atm/resources.c
+++ b/net/atm/resources.c
@@ -71,7 +71,7 @@ struct atm_dev *atm_dev_lookup(int number)
 	mutex_unlock(&atm_dev_mutex);
 	return dev;
 }
-
+EXPORT_SYMBOL(atm_dev_lookup);
 
 struct atm_dev *atm_dev_register(const char *type, const struct atmdev_ops *ops,
 				 int number, unsigned long *flags)
@@ -85,7 +85,8 @@ struct atm_dev *atm_dev_register(const char *type, const struct atmdev_ops *ops,
 	}
 	mutex_lock(&atm_dev_mutex);
 	if (number != -1) {
-		if ((inuse = __atm_dev_lookup(number))) {
+		inuse = __atm_dev_lookup(number);
+		if (inuse) {
 			atm_dev_put(inuse);
 			mutex_unlock(&atm_dev_mutex);
 			kfree(dev);
@@ -130,7 +131,7 @@ out_fail:
 	dev = NULL;
 	goto out;
 }
-
+EXPORT_SYMBOL(atm_dev_register);
 
 void atm_dev_deregister(struct atm_dev *dev)
 {
@@ -152,7 +153,7 @@ void atm_dev_deregister(struct atm_dev *dev)
 
 	atm_dev_put(dev);
 }
-
+EXPORT_SYMBOL(atm_dev_deregister);
 
 static void copy_aal_stats(struct k_atm_aal_stats *from,
     struct atm_aal_stats *to)
@@ -162,7 +163,6 @@ static void copy_aal_stats(struct k_atm_aal_stats *from,
 #undef __HANDLE_ITEM
 }
 
-
 static void subtract_aal_stats(struct k_atm_aal_stats *from,
     struct atm_aal_stats *to)
 {
@@ -171,8 +171,8 @@ static void subtract_aal_stats(struct k_atm_aal_stats *from,
 #undef __HANDLE_ITEM
 }
 
-
-static int fetch_stats(struct atm_dev *dev, struct atm_dev_stats __user *arg, int zero)
+static int fetch_stats(struct atm_dev *dev, struct atm_dev_stats __user *arg,
+		       int zero)
 {
 	struct atm_dev_stats tmp;
 	int error = 0;
@@ -190,7 +190,6 @@ static int fetch_stats(struct atm_dev *dev, struct atm_dev_stats __user *arg, in
 	return error ? -EFAULT : 0;
 }
 
-
 int atm_dev_ioctl(unsigned int cmd, void __user *arg, int compat)
 {
 	void __user *buf;
@@ -206,50 +205,49 @@ int atm_dev_ioctl(unsigned int cmd, void __user *arg, int compat)
 #endif
 
 	switch (cmd) {
-		case ATM_GETNAMES:
-
-			if (compat) {
+	case ATM_GETNAMES:
+		if (compat) {
 #ifdef CONFIG_COMPAT
-				struct compat_atm_iobuf __user *ciobuf = arg;
-				compat_uptr_t cbuf;
-				iobuf_len = &ciobuf->length;
-				if (get_user(cbuf, &ciobuf->buffer))
-					return -EFAULT;
-				buf = compat_ptr(cbuf);
+			struct compat_atm_iobuf __user *ciobuf = arg;
+			compat_uptr_t cbuf;
+			iobuf_len = &ciobuf->length;
+			if (get_user(cbuf, &ciobuf->buffer))
+				return -EFAULT;
+			buf = compat_ptr(cbuf);
 #endif
-			} else {
-				struct atm_iobuf __user *iobuf = arg;
-				iobuf_len = &iobuf->length;
-				if (get_user(buf, &iobuf->buffer))
-					return -EFAULT;
-			}
-			if (get_user(len, iobuf_len))
+		} else {
+			struct atm_iobuf __user *iobuf = arg;
+			iobuf_len = &iobuf->length;
+			if (get_user(buf, &iobuf->buffer))
 				return -EFAULT;
-			mutex_lock(&atm_dev_mutex);
-			list_for_each(p, &atm_devs)
-				size += sizeof(int);
-			if (size > len) {
-				mutex_unlock(&atm_dev_mutex);
-				return -E2BIG;
-			}
-			tmp_buf = kmalloc(size, GFP_ATOMIC);
-			if (!tmp_buf) {
-				mutex_unlock(&atm_dev_mutex);
-				return -ENOMEM;
-			}
-			tmp_p = tmp_buf;
-			list_for_each(p, &atm_devs) {
-				dev = list_entry(p, struct atm_dev, dev_list);
-				*tmp_p++ = dev->number;
-			}
+		}
+		if (get_user(len, iobuf_len))
+			return -EFAULT;
+		mutex_lock(&atm_dev_mutex);
+		list_for_each(p, &atm_devs)
+			size += sizeof(int);
+		if (size > len) {
 			mutex_unlock(&atm_dev_mutex);
-			error = ((copy_to_user(buf, tmp_buf, size)) ||
-					put_user(size, iobuf_len))
-						? -EFAULT : 0;
-			kfree(tmp_buf);
-			return error;
-		default:
-			break;
+			return -E2BIG;
+		}
+		tmp_buf = kmalloc(size, GFP_ATOMIC);
+		if (!tmp_buf) {
+			mutex_unlock(&atm_dev_mutex);
+			return -ENOMEM;
+		}
+		tmp_p = tmp_buf;
+		list_for_each(p, &atm_devs) {
+			dev = list_entry(p, struct atm_dev, dev_list);
+			*tmp_p++ = dev->number;
+		}
+		mutex_unlock(&atm_dev_mutex);
+		error = ((copy_to_user(buf, tmp_buf, size)) ||
+			 put_user(size, iobuf_len))
+			? -EFAULT : 0;
+		kfree(tmp_buf);
+		return error;
+	default:
+		break;
 	}
 
 	if (compat) {
@@ -278,166 +276,167 @@ int atm_dev_ioctl(unsigned int cmd, void __user *arg, int compat)
 		if (get_user(number, &sioc->number))
 			return -EFAULT;
 	}
-	if (!(dev = try_then_request_module(atm_dev_lookup(number),
-					    "atm-device-%d", number)))
+
+	dev = try_then_request_module(atm_dev_lookup(number), "atm-device-%d",
+				      number);
+	if (!dev)
 		return -ENODEV;
 
 	switch (cmd) {
-		case ATM_GETTYPE:
-			size = strlen(dev->type) + 1;
-			if (copy_to_user(buf, dev->type, size)) {
-				error = -EFAULT;
-				goto done;
-			}
-			break;
-		case ATM_GETESI:
-			size = ESI_LEN;
-			if (copy_to_user(buf, dev->esi, size)) {
-				error = -EFAULT;
-				goto done;
-			}
-			break;
-		case ATM_SETESI:
-			{
-				int i;
-
-				for (i = 0; i < ESI_LEN; i++)
-					if (dev->esi[i]) {
-						error = -EEXIST;
-						goto done;
-					}
-			}
-			/* fall through */
-		case ATM_SETESIF:
-			{
-				unsigned char esi[ESI_LEN];
-
-				if (!capable(CAP_NET_ADMIN)) {
-					error = -EPERM;
-					goto done;
-				}
-				if (copy_from_user(esi, buf, ESI_LEN)) {
-					error = -EFAULT;
-					goto done;
-				}
-				memcpy(dev->esi, esi, ESI_LEN);
-				error =  ESI_LEN;
-				goto done;
-			}
-		case ATM_GETSTATZ:
-			if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-			/* fall through */
-		case ATM_GETSTAT:
-			size = sizeof(struct atm_dev_stats);
-			error = fetch_stats(dev, buf, cmd == ATM_GETSTATZ);
-			if (error)
-				goto done;
-			break;
-		case ATM_GETCIRANGE:
-			size = sizeof(struct atm_cirange);
-			if (copy_to_user(buf, &dev->ci_range, size)) {
-				error = -EFAULT;
-				goto done;
-			}
-			break;
-		case ATM_GETLINKRATE:
-			size = sizeof(int);
-			if (copy_to_user(buf, &dev->link_rate, size)) {
-				error = -EFAULT;
-				goto done;
-			}
-			break;
-		case ATM_RSTADDR:
-			if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-			atm_reset_addr(dev, ATM_ADDR_LOCAL);
-			break;
-		case ATM_ADDADDR:
-		case ATM_DELADDR:
-		case ATM_ADDLECSADDR:
-		case ATM_DELLECSADDR:
-			if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-			{
-				struct sockaddr_atmsvc addr;
-
-				if (copy_from_user(&addr, buf, sizeof(addr))) {
-					error = -EFAULT;
-					goto done;
-				}
-				if (cmd == ATM_ADDADDR || cmd == ATM_ADDLECSADDR)
-					error = atm_add_addr(dev, &addr,
-							     (cmd == ATM_ADDADDR ?
-							      ATM_ADDR_LOCAL : ATM_ADDR_LECS));
-				else
-					error = atm_del_addr(dev, &addr,
-							     (cmd == ATM_DELADDR ?
-							      ATM_ADDR_LOCAL : ATM_ADDR_LECS));
+	case ATM_GETTYPE:
+		size = strlen(dev->type) + 1;
+		if (copy_to_user(buf, dev->type, size)) {
+			error = -EFAULT;
+			goto done;
+		}
+		break;
+	case ATM_GETESI:
+		size = ESI_LEN;
+		if (copy_to_user(buf, dev->esi, size)) {
+			error = -EFAULT;
+			goto done;
+		}
+		break;
+	case ATM_SETESI:
+	{
+		int i;
+
+		for (i = 0; i < ESI_LEN; i++)
+			if (dev->esi[i]) {
+				error = -EEXIST;
 				goto done;
 			}
-		case ATM_GETADDR:
-		case ATM_GETLECSADDR:
-			error = atm_get_addr(dev, buf, len,
-					     (cmd == ATM_GETADDR ?
+	}
+	/* fall through */
+	case ATM_SETESIF:
+	{
+		unsigned char esi[ESI_LEN];
+
+		if (!capable(CAP_NET_ADMIN)) {
+			error = -EPERM;
+			goto done;
+		}
+		if (copy_from_user(esi, buf, ESI_LEN)) {
+			error = -EFAULT;
+			goto done;
+		}
+		memcpy(dev->esi, esi, ESI_LEN);
+		error =  ESI_LEN;
+		goto done;
+	}
+	case ATM_GETSTATZ:
+		if (!capable(CAP_NET_ADMIN)) {
+			error = -EPERM;
+			goto done;
+		}
+		/* fall through */
+	case ATM_GETSTAT:
+		size = sizeof(struct atm_dev_stats);
+		error = fetch_stats(dev, buf, cmd == ATM_GETSTATZ);
+		if (error)
+			goto done;
+		break;
+	case ATM_GETCIRANGE:
+		size = sizeof(struct atm_cirange);
+		if (copy_to_user(buf, &dev->ci_range, size)) {
+			error = -EFAULT;
+			goto done;
+		}
+		break;
+	case ATM_GETLINKRATE:
+		size = sizeof(int);
+		if (copy_to_user(buf, &dev->link_rate, size)) {
+			error = -EFAULT;
+			goto done;
+		}
+		break;
+	case ATM_RSTADDR:
+		if (!capable(CAP_NET_ADMIN)) {
+			error = -EPERM;
+			goto done;
+		}
+		atm_reset_addr(dev, ATM_ADDR_LOCAL);
+		break;
+	case ATM_ADDADDR:
+	case ATM_DELADDR:
+	case ATM_ADDLECSADDR:
+	case ATM_DELLECSADDR:
+	{
+		struct sockaddr_atmsvc addr;
+
+		if (!capable(CAP_NET_ADMIN)) {
+			error = -EPERM;
+			goto done;
+		}
+
+		if (copy_from_user(&addr, buf, sizeof(addr))) {
+			error = -EFAULT;
+			goto done;
+		}
+		if (cmd == ATM_ADDADDR || cmd == ATM_ADDLECSADDR)
+			error = atm_add_addr(dev, &addr,
+					     (cmd == ATM_ADDADDR ?
 					      ATM_ADDR_LOCAL : ATM_ADDR_LECS));
-			if (error < 0)
-				goto done;
-			size = error;
-			/* may return 0, but later on size == 0 means "don't
-			   write the length" */
-			error = put_user(size, sioc_len)
-				? -EFAULT : 0;
+		else
+			error = atm_del_addr(dev, &addr,
+					     (cmd == ATM_DELADDR ?
+					      ATM_ADDR_LOCAL : ATM_ADDR_LECS));
+		goto done;
+	}
+	case ATM_GETADDR:
+	case ATM_GETLECSADDR:
+		error = atm_get_addr(dev, buf, len,
+				     (cmd == ATM_GETADDR ?
+				      ATM_ADDR_LOCAL : ATM_ADDR_LECS));
+		if (error < 0)
+			goto done;
+		size = error;
+		/* may return 0, but later on size == 0 means "don't
+		   write the length" */
+		error = put_user(size, sioc_len) ? -EFAULT : 0;
+		goto done;
+	case ATM_SETLOOP:
+		if (__ATM_LM_XTRMT((int) (unsigned long) buf) &&
+		    __ATM_LM_XTLOC((int) (unsigned long) buf) >
+		    __ATM_LM_XTRMT((int) (unsigned long) buf)) {
+			error = -EINVAL;
 			goto done;
-		case ATM_SETLOOP:
-			if (__ATM_LM_XTRMT((int) (unsigned long) buf) &&
-			    __ATM_LM_XTLOC((int) (unsigned long) buf) >
-			    __ATM_LM_XTRMT((int) (unsigned long) buf)) {
+		}
+		/* fall through */
+	case ATM_SETCIRANGE:
+	case SONET_GETSTATZ:
+	case SONET_SETDIAG:
+	case SONET_CLRDIAG:
+	case SONET_SETFRAMING:
+		if (!capable(CAP_NET_ADMIN)) {
+			error = -EPERM;
+			goto done;
+		}
+		/* fall through */
+	default:
+		if (compat) {
+#ifdef CONFIG_COMPAT
+			if (!dev->ops->compat_ioctl) {
 				error = -EINVAL;
 				goto done;
 			}
-			/* fall through */
-		case ATM_SETCIRANGE:
-		case SONET_GETSTATZ:
-		case SONET_SETDIAG:
-		case SONET_CLRDIAG:
-		case SONET_SETFRAMING:
-			if (!capable(CAP_NET_ADMIN)) {
-				error = -EPERM;
-				goto done;
-			}
-			/* fall through */
-		default:
-			if (compat) {
-#ifdef CONFIG_COMPAT
-				if (!dev->ops->compat_ioctl) {
-					error = -EINVAL;
-					goto done;
-				}
-				size = dev->ops->compat_ioctl(dev, cmd, buf);
+			size = dev->ops->compat_ioctl(dev, cmd, buf);
 #endif
-			} else {
-				if (!dev->ops->ioctl) {
-					error = -EINVAL;
-					goto done;
-				}
-				size = dev->ops->ioctl(dev, cmd, buf);
-			}
-			if (size < 0) {
-				error = (size == -ENOIOCTLCMD ? -EINVAL : size);
+		} else {
+			if (!dev->ops->ioctl) {
+				error = -EINVAL;
 				goto done;
 			}
+			size = dev->ops->ioctl(dev, cmd, buf);
+		}
+		if (size < 0) {
+			error = (size == -ENOIOCTLCMD ? -EINVAL : size);
+			goto done;
+		}
 	}
 
 	if (size)
-		error = put_user(size, sioc_len)
-			? -EFAULT : 0;
+		error = put_user(size, sioc_len) ? -EFAULT : 0;
 	else
 		error = 0;
 done:
@@ -445,7 +444,7 @@ done:
 	return error;
 }
 
-static __inline__ void *dev_get_idx(loff_t left)
+static inline void *dev_get_idx(loff_t left)
 {
 	struct list_head *p;
 
@@ -474,8 +473,3 @@ void *atm_dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 		? atm_devs.next : ((struct list_head *)v)->next;
 	return (v == &atm_devs) ? NULL : v;
 }
-
-
-EXPORT_SYMBOL(atm_dev_register);
-EXPORT_SYMBOL(atm_dev_deregister);
-EXPORT_SYMBOL(atm_dev_lookup);
-- 
1.6.6.rc0.57.gad7a

