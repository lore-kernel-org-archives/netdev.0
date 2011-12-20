From: frank.blaschka@de.ibm.com
Subject: [patch 08/10] [PATCH] netiucv: allow multiple interfaces to same peer
Date: Tue, 20 Dec 2011 09:56:34 +0100
Message-ID: <20111220085736.338500334@de.ibm.com>
References: <20111220085626.924756639@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:35216 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263Ab1LTI5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 03:57:41 -0500
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 20 Dec 2011 08:57:40 -0000
Content-Disposition: inline; filename=608-netiucv-multi-if-peer.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

The NETIUCV device driver allows to connect a Linux guest on z/VM to
another z/VM guest based on the z/VM communication facility IUCV.
Multiple output paths to different guests are possible, as well as
multiple input paths from different guests.
With this feature, you can configure multiple point-to-point NETIUCV
interfaces between your Linux on System z instance and another z/VM
guest.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/netiucv.c |  217 +++++++++++++++++++++++++++------------------
 1 file changed, 135 insertions(+), 82 deletions(-)

--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -63,6 +63,7 @@
 
 #include <asm/io.h>
 #include <asm/uaccess.h>
+#include <asm/ebcdic.h>
 
 #include <net/iucv/iucv.h>
 #include "fsm.h"
@@ -75,7 +76,7 @@ MODULE_DESCRIPTION ("Linux for S/390 IUC
  * Debug Facility stuff
  */
 #define IUCV_DBF_SETUP_NAME "iucv_setup"
-#define IUCV_DBF_SETUP_LEN 32
+#define IUCV_DBF_SETUP_LEN 64
 #define IUCV_DBF_SETUP_PAGES 2
 #define IUCV_DBF_SETUP_NR_AREAS 1
 #define IUCV_DBF_SETUP_LEVEL 3
@@ -226,6 +227,7 @@ struct iucv_connection {
 	struct net_device         *netdev;
 	struct connection_profile prof;
 	char                      userid[9];
+	char			  userdata[17];
 };
 
 /**
@@ -263,7 +265,7 @@ struct ll_header {
 };
 
 #define NETIUCV_HDRLEN		 (sizeof(struct ll_header))
-#define NETIUCV_BUFSIZE_MAX      32768
+#define NETIUCV_BUFSIZE_MAX	 65537
 #define NETIUCV_BUFSIZE_DEFAULT  NETIUCV_BUFSIZE_MAX
 #define NETIUCV_MTU_MAX          (NETIUCV_BUFSIZE_MAX - NETIUCV_HDRLEN)
 #define NETIUCV_MTU_DEFAULT      9216
@@ -288,7 +290,12 @@ static inline int netiucv_test_and_set_b
 	return test_and_set_bit(0, &priv->tbusy);
 }
 
-static u8 iucvMagic[16] = {
+static u8 iucvMagic_ascii[16] = {
+	0x30, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
+	0x30, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20
+};
+
+static u8 iucvMagic_ebcdic[16] = {
 	0xF0, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
 	0xF0, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
 };
@@ -301,18 +308,38 @@ static u8 iucvMagic[16] = {
  *
  * @returns The printable string (static data!!)
  */
-static char *netiucv_printname(char *name)
+static char *netiucv_printname(char *name, int len)
 {
-	static char tmp[9];
+	static char tmp[17];
 	char *p = tmp;
-	memcpy(tmp, name, 8);
-	tmp[8] = '\0';
-	while (*p && (!isspace(*p)))
+	memcpy(tmp, name, len);
+	tmp[len] = '\0';
+	while (*p && ((p - tmp) < len) && (!isspace(*p)))
 		p++;
 	*p = '\0';
 	return tmp;
 }
 
+static char *netiucv_printuser(struct iucv_connection *conn)
+{
+	static char tmp_uid[9];
+	static char tmp_udat[17];
+	static char buf[100];
+
+	if (memcmp(conn->userdata, iucvMagic_ebcdic, 16)) {
+		tmp_uid[8] = '\0';
+		tmp_udat[16] = '\0';
+		memcpy(tmp_uid, conn->userid, 8);
+		memcpy(tmp_uid, netiucv_printname(tmp_uid, 8), 8);
+		memcpy(tmp_udat, conn->userdata, 16);
+		EBCASC(tmp_udat, 16);
+		memcpy(tmp_udat, netiucv_printname(tmp_udat, 16), 16);
+		sprintf(buf, "%s.%s", tmp_uid, tmp_udat);
+		return buf;
+	} else
+		return netiucv_printname(conn->userid, 8);
+}
+
 /**
  * States of the interface statemachine.
  */
@@ -563,15 +590,18 @@ static int netiucv_callback_connreq(stru
 {
 	struct iucv_connection *conn = path->private;
 	struct iucv_event ev;
+	static char tmp_user[9];
+	static char tmp_udat[17];
 	int rc;
 
-	if (memcmp(iucvMagic, ipuser, 16))
-		/* ipuser must match iucvMagic. */
-		return -EINVAL;
 	rc = -EINVAL;
+	memcpy(tmp_user, netiucv_printname(ipvmid, 8), 8);
+	memcpy(tmp_udat, ipuser, 16);
+	EBCASC(tmp_udat, 16);
 	read_lock_bh(&iucv_connection_rwlock);
 	list_for_each_entry(conn, &iucv_connection_list, list) {
-		if (strncmp(ipvmid, conn->userid, 8))
+		if (strncmp(ipvmid, conn->userid, 8) ||
+		    strncmp(ipuser, conn->userdata, 16))
 			continue;
 		/* Found a matching connection for this path. */
 		conn->path = path;
@@ -580,6 +610,8 @@ static int netiucv_callback_connreq(stru
 		fsm_event(conn->fsm, CONN_EVENT_CONN_REQ, &ev);
 		rc = 0;
 	}
+	IUCV_DBF_TEXT_(setup, 2, "Connection requested for %s.%s\n",
+		       tmp_user, netiucv_printname(tmp_udat, 16));
 	read_unlock_bh(&iucv_connection_rwlock);
 	return rc;
 }
@@ -816,7 +848,7 @@ static void conn_action_connaccept(fsm_i
 	conn->path = path;
 	path->msglim = NETIUCV_QUEUELEN_DEFAULT;
 	path->flags = 0;
-	rc = iucv_path_accept(path, &netiucv_handler, NULL, conn);
+	rc = iucv_path_accept(path, &netiucv_handler, conn->userdata , conn);
 	if (rc) {
 		IUCV_DBF_TEXT_(setup, 2, "rc %d from iucv_accept", rc);
 		return;
@@ -854,7 +886,7 @@ static void conn_action_conntimsev(fsm_i
 
 	IUCV_DBF_TEXT(trace, 3, __func__);
 	fsm_deltimer(&conn->timer);
-	iucv_path_sever(conn->path, NULL);
+	iucv_path_sever(conn->path, conn->userdata);
 	fsm_newstate(fi, CONN_STATE_STARTWAIT);
 }
 
@@ -867,9 +899,9 @@ static void conn_action_connsever(fsm_in
 	IUCV_DBF_TEXT(trace, 3, __func__);
 
 	fsm_deltimer(&conn->timer);
-	iucv_path_sever(conn->path, NULL);
-	dev_info(privptr->dev, "The peer interface of the IUCV device"
-		" has closed the connection\n");
+	iucv_path_sever(conn->path, conn->userdata);
+	dev_info(privptr->dev, "The peer z/VM guest %s has closed the "
+			       "connection\n", netiucv_printuser(conn));
 	IUCV_DBF_TEXT(data, 2,
 		      "conn_action_connsever: Remote dropped connection\n");
 	fsm_newstate(fi, CONN_STATE_STARTWAIT);
@@ -886,8 +918,6 @@ static void conn_action_start(fsm_instan
 	IUCV_DBF_TEXT(trace, 3, __func__);
 
 	fsm_newstate(fi, CONN_STATE_STARTWAIT);
-	IUCV_DBF_TEXT_(setup, 2, "%s('%s'): connecting ...\n",
-		netdev->name, conn->userid);
 
 	/*
 	 * We must set the state before calling iucv_connect because the
@@ -897,8 +927,11 @@ static void conn_action_start(fsm_instan
 
 	fsm_newstate(fi, CONN_STATE_SETUPWAIT);
 	conn->path = iucv_path_alloc(NETIUCV_QUEUELEN_DEFAULT, 0, GFP_KERNEL);
+	IUCV_DBF_TEXT_(setup, 2, "%s: connecting to %s ...\n",
+		netdev->name, netiucv_printuser(conn));
+
 	rc = iucv_path_connect(conn->path, &netiucv_handler, conn->userid,
-			       NULL, iucvMagic, conn);
+			       NULL, conn->userdata, conn);
 	switch (rc) {
 	case 0:
 		netdev->tx_queue_len = conn->path->msglim;
@@ -908,13 +941,13 @@ static void conn_action_start(fsm_instan
 	case 11:
 		dev_warn(privptr->dev,
 			"The IUCV device failed to connect to z/VM guest %s\n",
-			netiucv_printname(conn->userid));
+			netiucv_printname(conn->userid, 8));
 		fsm_newstate(fi, CONN_STATE_STARTWAIT);
 		break;
 	case 12:
 		dev_warn(privptr->dev,
 			"The IUCV device failed to connect to the peer on z/VM"
-			" guest %s\n", netiucv_printname(conn->userid));
+			" guest %s\n", netiucv_printname(conn->userid, 8));
 		fsm_newstate(fi, CONN_STATE_STARTWAIT);
 		break;
 	case 13:
@@ -927,7 +960,7 @@ static void conn_action_start(fsm_instan
 		dev_err(privptr->dev,
 			"z/VM guest %s has too many IUCV connections"
 			" to connect with the IUCV device\n",
-			netiucv_printname(conn->userid));
+			netiucv_printname(conn->userid, 8));
 		fsm_newstate(fi, CONN_STATE_CONNERR);
 		break;
 	case 15:
@@ -972,7 +1005,7 @@ static void conn_action_stop(fsm_instanc
 	netiucv_purge_skb_queue(&conn->collect_queue);
 	if (conn->path) {
 		IUCV_DBF_TEXT(trace, 5, "calling iucv_path_sever\n");
-		iucv_path_sever(conn->path, iucvMagic);
+		iucv_path_sever(conn->path, conn->userdata);
 		kfree(conn->path);
 		conn->path = NULL;
 	}
@@ -1090,7 +1123,8 @@ dev_action_connup(fsm_instance *fi, int
 			fsm_newstate(fi, DEV_STATE_RUNNING);
 			dev_info(privptr->dev,
 				"The IUCV device has been connected"
-				" successfully to %s\n", privptr->conn->userid);
+				" successfully to %s\n",
+				netiucv_printuser(privptr->conn));
 			IUCV_DBF_TEXT(setup, 3,
 				"connection is up and running\n");
 			break;
@@ -1452,45 +1486,72 @@ static ssize_t user_show(struct device *
 	struct netiucv_priv *priv = dev_get_drvdata(dev);
 
 	IUCV_DBF_TEXT(trace, 5, __func__);
-	return sprintf(buf, "%s\n", netiucv_printname(priv->conn->userid));
+	return sprintf(buf, "%s\n", netiucv_printuser(priv->conn));
 }
 
-static ssize_t user_write(struct device *dev, struct device_attribute *attr,
-			  const char *buf, size_t count)
+static int netiucv_check_user(const char *buf, size_t count, char *username,
+			      char *userdata)
 {
-	struct netiucv_priv *priv = dev_get_drvdata(dev);
-	struct net_device *ndev = priv->conn->netdev;
-	char    *p;
-	char    *tmp;
-	char 	username[9];
-	int 	i;
-	struct iucv_connection *cp;
+	const char *p;
+	int i;
 
-	IUCV_DBF_TEXT(trace, 3, __func__);
-	if (count > 9) {
-		IUCV_DBF_TEXT_(setup, 2,
-			       "%d is length of username\n", (int) count);
+	p = strchr(buf, '.');
+	if ((p && ((count > 26) ||
+		   ((p - buf) > 8) ||
+		   (buf + count - p > 18))) ||
+	    (!p && (count > 9))) {
+		IUCV_DBF_TEXT(setup, 2, "conn_write: too long\n");
 		return -EINVAL;
 	}
 
-	tmp = strsep((char **) &buf, "\n");
-	for (i = 0, p = tmp; i < 8 && *p; i++, p++) {
-		if (isalnum(*p) || (*p == '$')) {
-			username[i]= toupper(*p);
+	for (i = 0, p = buf; i < 8 && *p && *p != '.'; i++, p++) {
+		if (isalnum(*p) || *p == '$') {
+			username[i] = toupper(*p);
 			continue;
 		}
-		if (*p == '\n') {
+		if (*p == '\n')
 			/* trailing lf, grr */
 			break;
-		}
 		IUCV_DBF_TEXT_(setup, 2,
-			       "username: invalid character %c\n", *p);
+			       "conn_write: invalid character %02x\n", *p);
 		return -EINVAL;
 	}
 	while (i < 8)
 		username[i++] = ' ';
 	username[8] = '\0';
 
+	if (*p == '.') {
+		p++;
+		for (i = 0; i < 16 && *p; i++, p++) {
+			if (*p == '\n')
+				break;
+			userdata[i] = toupper(*p);
+		}
+		while (i > 0 && i < 16)
+			userdata[i++] = ' ';
+	} else
+		memcpy(userdata, iucvMagic_ascii, 16);
+	userdata[16] = '\0';
+	ASCEBC(userdata, 16);
+
+	return 0;
+}
+
+static ssize_t user_write(struct device *dev, struct device_attribute *attr,
+			  const char *buf, size_t count)
+{
+	struct netiucv_priv *priv = dev_get_drvdata(dev);
+	struct net_device *ndev = priv->conn->netdev;
+	char	username[9];
+	char	userdata[17];
+	int	rc;
+	struct iucv_connection *cp;
+
+	IUCV_DBF_TEXT(trace, 3, __func__);
+	rc = netiucv_check_user(buf, count, username, userdata);
+	if (rc)
+		return rc;
+
 	if (memcmp(username, priv->conn->userid, 9) &&
 	    (ndev->flags & (IFF_UP | IFF_RUNNING))) {
 		/* username changed while the interface is active. */
@@ -1499,15 +1560,17 @@ static ssize_t user_write(struct device
 	}
 	read_lock_bh(&iucv_connection_rwlock);
 	list_for_each_entry(cp, &iucv_connection_list, list) {
-		if (!strncmp(username, cp->userid, 9) && cp->netdev != ndev) {
+		if (!strncmp(username, cp->userid, 9) &&
+		   !strncmp(userdata, cp->userdata, 17) && cp->netdev != ndev) {
 			read_unlock_bh(&iucv_connection_rwlock);
-			IUCV_DBF_TEXT_(setup, 2, "user_write: Connection "
-				"to %s already exists\n", username);
+			IUCV_DBF_TEXT_(setup, 2, "user_write: Connection to %s "
+				"already exists\n", netiucv_printuser(cp));
 			return -EEXIST;
 		}
 	}
 	read_unlock_bh(&iucv_connection_rwlock);
 	memcpy(priv->conn->userid, username, 9);
+	memcpy(priv->conn->userdata, userdata, 17);
 	return count;
 }
 
@@ -1537,7 +1600,8 @@ static ssize_t buffer_write (struct devi
 	bs1 = simple_strtoul(buf, &e, 0);
 
 	if (e && (!isspace(*e))) {
-		IUCV_DBF_TEXT_(setup, 2, "buffer_write: invalid char %c\n", *e);
+		IUCV_DBF_TEXT_(setup, 2, "buffer_write: invalid char %02x\n",
+			*e);
 		return -EINVAL;
 	}
 	if (bs1 > NETIUCV_BUFSIZE_MAX) {
@@ -1864,7 +1928,8 @@ static void netiucv_unregister_device(st
  * Add it to the list of netiucv connections;
  */
 static struct iucv_connection *netiucv_new_connection(struct net_device *dev,
-						      char *username)
+						      char *username,
+						      char *userdata)
 {
 	struct iucv_connection *conn;
 
@@ -1893,6 +1958,8 @@ static struct iucv_connection *netiucv_n
 	fsm_settimer(conn->fsm, &conn->timer);
 	fsm_newstate(conn->fsm, CONN_STATE_INVALID);
 
+	if (userdata)
+		memcpy(conn->userdata, userdata, 17);
 	if (username) {
 		memcpy(conn->userid, username, 9);
 		fsm_newstate(conn->fsm, CONN_STATE_STOPPED);
@@ -1919,6 +1986,7 @@ out:
  */
 static void netiucv_remove_connection(struct iucv_connection *conn)
 {
+
 	IUCV_DBF_TEXT(trace, 3, __func__);
 	write_lock_bh(&iucv_connection_rwlock);
 	list_del_init(&conn->list);
@@ -1926,7 +1994,7 @@ static void netiucv_remove_connection(st
 	fsm_deltimer(&conn->timer);
 	netiucv_purge_skb_queue(&conn->collect_queue);
 	if (conn->path) {
-		iucv_path_sever(conn->path, iucvMagic);
+		iucv_path_sever(conn->path, conn->userdata);
 		kfree(conn->path);
 		conn->path = NULL;
 	}
@@ -1985,7 +2053,7 @@ static void netiucv_setup_netdevice(stru
 /**
  * Allocate and initialize everything of a net device.
  */
-static struct net_device *netiucv_init_netdevice(char *username)
+static struct net_device *netiucv_init_netdevice(char *username, char *userdata)
 {
 	struct netiucv_priv *privptr;
 	struct net_device *dev;
@@ -2004,7 +2072,7 @@ static struct net_device *netiucv_init_n
 	if (!privptr->fsm)
 		goto out_netdev;
 
-	privptr->conn = netiucv_new_connection(dev, username);
+	privptr->conn = netiucv_new_connection(dev, username, userdata);
 	if (!privptr->conn) {
 		IUCV_DBF_TEXT(setup, 2, "NULL from netiucv_new_connection\n");
 		goto out_fsm;
@@ -2022,47 +2090,31 @@ out_netdev:
 static ssize_t conn_write(struct device_driver *drv,
 			  const char *buf, size_t count)
 {
-	const char *p;
 	char username[9];
-	int i, rc;
+	char userdata[17];
+	int rc;
 	struct net_device *dev;
 	struct netiucv_priv *priv;
 	struct iucv_connection *cp;
 
 	IUCV_DBF_TEXT(trace, 3, __func__);
-	if (count>9) {
-		IUCV_DBF_TEXT(setup, 2, "conn_write: too long\n");
-		return -EINVAL;
-	}
-
-	for (i = 0, p = buf; i < 8 && *p; i++, p++) {
-		if (isalnum(*p) || *p == '$') {
-			username[i] = toupper(*p);
-			continue;
-		}
-		if (*p == '\n')
-			/* trailing lf, grr */
-			break;
-		IUCV_DBF_TEXT_(setup, 2,
-			       "conn_write: invalid character %c\n", *p);
-		return -EINVAL;
-	}
-	while (i < 8)
-		username[i++] = ' ';
-	username[8] = '\0';
+	rc = netiucv_check_user(buf, count, username, userdata);
+	if (rc)
+		return rc;
 
 	read_lock_bh(&iucv_connection_rwlock);
 	list_for_each_entry(cp, &iucv_connection_list, list) {
-		if (!strncmp(username, cp->userid, 9)) {
+		if (!strncmp(username, cp->userid, 9) &&
+		    !strncmp(userdata, cp->userdata, 17)) {
 			read_unlock_bh(&iucv_connection_rwlock);
-			IUCV_DBF_TEXT_(setup, 2, "conn_write: Connection "
-				"to %s already exists\n", username);
+			IUCV_DBF_TEXT_(setup, 2, "conn_write: Connection to %s "
+				"already exists\n", netiucv_printuser(cp));
 			return -EEXIST;
 		}
 	}
 	read_unlock_bh(&iucv_connection_rwlock);
 
-	dev = netiucv_init_netdevice(username);
+	dev = netiucv_init_netdevice(username, userdata);
 	if (!dev) {
 		IUCV_DBF_TEXT(setup, 2, "NULL from netiucv_init_netdevice\n");
 		return -ENODEV;
@@ -2083,8 +2135,9 @@ static ssize_t conn_write(struct device_
 	if (rc)
 		goto out_unreg;
 
-	dev_info(priv->dev, "The IUCV interface to %s has been"
-		" established successfully\n", netiucv_printname(username));
+	dev_info(priv->dev, "The IUCV interface to %s has been established "
+			    "successfully\n",
+		netiucv_printuser(priv->conn));
 
 	return count;
 
