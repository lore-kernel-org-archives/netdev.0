From: fpavlic@de.ibm.com
Subject: [PATCH 2/9] s390: netiucv driver fixes
Date: Wed, 6 Sep 2006 17:05:14 +0200
Message-ID: <200609061705.14737.fpavlic@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev Mailinglist <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:24485 "EHLO
	mtagate2.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751286AbWIFPES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 11:04:18 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.7/8.13.7) with ESMTP id k86F4HBO049622
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 15:04:17 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k86F6N4u364680
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 16:06:23 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k86F4Gg1009176
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 16:04:17 +0100
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 2/9] s390: netiucv driver fixes

From: Frank Pavlic <fpavlic@de.ibm.com>
 - missing lock initialization added
        - avoid duplicate iucv-interfaces to the same peer
        - rw-lock added for manipulating the list of
          defined iucv connections

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 drivers/s390/net/netiucv.c |   80 
+++++++++++++++++++++++++++++++++++---------
 1 files changed, 64 insertions(+), 16 deletions(-)

05eebe4adf2ad6b442b3dc0bd34ccc5863299efb
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index 5d6e6cb..d7d1cc0 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -112,7 +112,12 @@ struct iucv_connection {
 /**
  * Linked list of all connection structs.
  */
-static struct iucv_connection *iucv_connections;
+struct iucv_connection_struct {
+ struct iucv_connection *iucv_connections;
+ rwlock_t iucv_rwlock;
+};
+
+static struct iucv_connection_struct iucv_conns;
 
 /**
  * Representation of event-data for the
@@ -1368,8 +1373,10 @@ user_write (struct device *dev, struct d
  struct net_device *ndev = priv->conn->netdev;
  char    *p;
  char    *tmp;
- char  username[10];
+ char  username[9];
  int  i;
+ struct iucv_connection **clist = &iucv_conns.iucv_connections;
+ unsigned long flags;
 
  IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
  if (count>9) {
@@ -1382,7 +1389,7 @@ user_write (struct device *dev, struct d
  tmp = strsep((char **) &buf, "\n");
  for (i=0, p=tmp; i<8 && *p; i++, p++) {
   if (isalnum(*p) || (*p == '$'))
-   username[i]= *p;
+   username[i]= toupper(*p);
   else if (*p == '\n') {
    /* trailing lf, grr */
    break;
@@ -1395,11 +1402,11 @@ user_write (struct device *dev, struct d
    return -EINVAL;
   }
  }
- while (i<9)
+ while (i<8)
   username[i++] = ' ';
- username[9] = '\0';
+ username[8] = '\0';
 
- if (memcmp(username, priv->conn->userid, 8)) {
+ if (memcmp(username, priv->conn->userid, 9)) {
   /* username changed */
   if (ndev->flags & (IFF_UP | IFF_RUNNING)) {
    PRINT_WARN(
@@ -1410,6 +1417,19 @@ user_write (struct device *dev, struct d
    return -EBUSY;
   }
  }
+ read_lock_irqsave(&iucv_conns.iucv_rwlock, flags);
+ while (*clist) {
+                if (!strncmp(username, (*clist)->userid, 9) ||
+      ((*clist)->netdev != ndev))
+                        break;
+                clist = &((*clist)->next);
+        }
+ read_unlock_irqrestore(&iucv_conns.iucv_rwlock, flags);
+        if (*clist) {
+                PRINT_WARN("netiucv: Connection to %s already exists\n",
+                        username);
+                return -EEXIST;
+        }
  memcpy(priv->conn->userid, username, 9);
 
  return count;
@@ -1781,13 +1801,15 @@ netiucv_unregister_device(struct device 
 static struct iucv_connection *
 netiucv_new_connection(struct net_device *dev, char *username)
 {
- struct iucv_connection **clist = &iucv_connections;
+ unsigned long flags;
+ struct iucv_connection **clist = &iucv_conns.iucv_connections;
  struct iucv_connection *conn =
   kzalloc(sizeof(struct iucv_connection), GFP_KERNEL);
 
  if (conn) {
   skb_queue_head_init(&conn->collect_queue);
   skb_queue_head_init(&conn->commit_queue);
+  spin_lock_init(&conn->collect_lock);
   conn->max_buffsize = NETIUCV_BUFSIZE_DEFAULT;
   conn->netdev = dev;
 
@@ -1822,8 +1844,10 @@ netiucv_new_connection(struct net_device
    fsm_newstate(conn->fsm, CONN_STATE_STOPPED);
   }
 
+  write_lock_irqsave(&iucv_conns.iucv_rwlock, flags);
   conn->next = *clist;
   *clist = conn;
+  write_unlock_irqrestore(&iucv_conns.iucv_rwlock, flags);
  }
  return conn;
 }
@@ -1835,14 +1859,17 @@ netiucv_new_connection(struct net_device
 static void
 netiucv_remove_connection(struct iucv_connection *conn)
 {
- struct iucv_connection **clist = &iucv_connections;
+ struct iucv_connection **clist = &iucv_conns.iucv_connections;
+ unsigned long flags;
 
  IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
  if (conn == NULL)
   return;
+ write_lock_irqsave(&iucv_conns.iucv_rwlock, flags);
  while (*clist) {
   if (*clist == conn) {
    *clist = conn->next;
+   write_unlock_irqrestore(&iucv_conns.iucv_rwlock, flags);
    if (conn->handle) {
     iucv_unregister_program(conn->handle);
     conn->handle = NULL;
@@ -1855,6 +1882,7 @@ netiucv_remove_connection(struct iucv_co
   }
   clist = &((*clist)->next);
  }
+ write_unlock_irqrestore(&iucv_conns.iucv_rwlock, flags);
 }
 
 /**
@@ -1947,9 +1975,11 @@ static ssize_t
 conn_write(struct device_driver *drv, const char *buf, size_t count)
 {
  char *p;
- char username[10];
+ char username[9];
  int i, ret;
  struct net_device *dev;
+ struct iucv_connection **clist = &iucv_conns.iucv_connections;
+ unsigned long flags;
 
  IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
  if (count>9) {
@@ -1960,7 +1990,7 @@ conn_write(struct device_driver *drv, co
 
  for (i=0, p=(char *)buf; i<8 && *p; i++, p++) {
   if (isalnum(*p) || (*p == '$'))
-   username[i]= *p;
+   username[i]= toupper(*p);
   else if (*p == '\n') {
    /* trailing lf, grr */
    break;
@@ -1971,9 +2001,22 @@ conn_write(struct device_driver *drv, co
    return -EINVAL;
   }
  }
- while (i<9)
+ while (i<8)
   username[i++] = ' ';
- username[9] = '\0';
+ username[8] = '\0';
+
+ read_lock_irqsave(&iucv_conns.iucv_rwlock, flags);
+ while (*clist) {
+  if (!strncmp(username, (*clist)->userid, 9))
+   break;
+  clist = &((*clist)->next);
+ }
+ read_unlock_irqrestore(&iucv_conns.iucv_rwlock, flags);
+ if (*clist) {
+  PRINT_WARN("netiucv: Connection to %s already exists\n",
+   username);
+  return -EEXIST;
+ }
  dev = netiucv_init_netdevice(username);
  if (!dev) {
   PRINT_WARN(
@@ -2015,7 +2058,8 @@ DRIVER_ATTR(connection, 0200, NULL, conn
 static ssize_t
 remove_write (struct device_driver *drv, const char *buf, size_t count)
 {
- struct iucv_connection **clist = &iucv_connections;
+ struct iucv_connection **clist = &iucv_conns.iucv_connections;
+ unsigned long flags;
         struct net_device *ndev;
         struct netiucv_priv *priv;
         struct device *dev;
@@ -2026,7 +2070,7 @@ remove_write (struct device_driver *drv,
         IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
 
         if (count >= IFNAMSIZ)
-                count = IFNAMSIZ-1;
+                count = IFNAMSIZ - 1;;
 
         for (i=0, p=(char *)buf; i<count && *p; i++, p++) {
                 if ((*p == '\n') || (*p == ' ')) {
@@ -2038,6 +2082,7 @@ remove_write (struct device_driver *drv,
         }
         name[i] = '\0';
 
+ read_lock_irqsave(&iucv_conns.iucv_rwlock, flags);
         while (*clist) {
                 ndev = (*clist)->netdev;
                 priv = (struct netiucv_priv*)ndev->priv;
@@ -2047,6 +2092,7 @@ remove_write (struct device_driver *drv,
                         clist = &((*clist)->next);
                         continue;
                 }
+  read_unlock_irqrestore(&iucv_conns.iucv_rwlock, flags);
                 if (ndev->flags & (IFF_UP | IFF_RUNNING)) {
                         PRINT_WARN(
                                 "netiucv: net device %s active with peer 
%s\n",
@@ -2060,6 +2106,7 @@ remove_write (struct device_driver *drv,
                 netiucv_unregister_device(dev);
                 return count;
         }
+ read_unlock_irqrestore(&iucv_conns.iucv_rwlock, flags);
         PRINT_WARN("netiucv: net device %s unknown\n", name);
  IUCV_DBF_TEXT(data, 2, "remove_write: unknown device\n");
         return -EINVAL;
@@ -2077,8 +2124,8 @@ static void __exit
 netiucv_exit(void)
 {
  IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
- while (iucv_connections) {
-  struct net_device *ndev = iucv_connections->netdev;
+ while (iucv_conns.iucv_connections) {
+  struct net_device *ndev = iucv_conns.iucv_connections->netdev;
   struct netiucv_priv *priv = (struct netiucv_priv*)ndev->priv;
   struct device *dev = priv->dev;
 
@@ -2120,6 +2167,7 @@ netiucv_init(void)
  if (!ret) {
   ret = driver_create_file(&netiucv_driver, &driver_attr_remove);
   netiucv_banner();
+  rwlock_init(&iucv_conns.iucv_rwlock);
  } else {
   PRINT_ERR("NETIUCV: failed to add driver attribute.\n");
   IUCV_DBF_TEXT_(setup, 2, "ret %d from driver_create_file\n", ret);
-- 
1.2.4

