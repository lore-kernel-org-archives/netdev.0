From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2/2] netlink: kill eff_cap from struct netlink_skb_parms
Date: Thu, 03 Mar 2011 10:38:08 +0100
Message-ID: <4D6F6180.5030903@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080700080301090103000800"
Cc: "David S. Miller" <davem@davemloft.net>,
	Chris Wright <chrisw@sous-sol.org>,
	"linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>, drbd-dev@lists.linbit.com
To: NetDev <netdev@vger.kernel.org>, dm-devel@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52755 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931Ab1CCJiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 04:38:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080700080301090103000800
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------080700080301090103000800
Content-Type: text/plain;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="02.diff"

commit 8ff259625f0ab295fa085b0718eed13093813fbc
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Mar 3 10:17:31 2011 +0100

    netlink: kill eff_cap from struct netlink_skb_parms
    
    Netlink message processing in the kernel is synchronous these days,
    capabilities can be checked directly in security_netlink_recv() from
    the current process.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/block/drbd/drbd_nl.c b/drivers/block/drbd/drbd_nl.c
index 8cbfaa6..fe81c85 100644
--- a/drivers/block/drbd/drbd_nl.c
+++ b/drivers/block/drbd/drbd_nl.c
@@ -2177,7 +2177,7 @@ static void drbd_connector_callback(struct cn_msg *req, struct netlink_skb_parms
 		return;
 	}
 
-	if (!cap_raised(nsp->eff_cap, CAP_SYS_ADMIN)) {
+	if (!cap_raised(current_cap(), CAP_SYS_ADMIN)) {
 		retcode = ERR_PERM;
 		goto fail;
 	}
diff --git a/drivers/md/dm-log-userspace-transfer.c b/drivers/md/dm-log-userspace-transfer.c
index 049eaf1..1f23e04 100644
--- a/drivers/md/dm-log-userspace-transfer.c
+++ b/drivers/md/dm-log-userspace-transfer.c
@@ -134,7 +134,7 @@ static void cn_ulog_callback(struct cn_msg *msg, struct netlink_skb_parms *nsp)
 {
 	struct dm_ulog_request *tfr = (struct dm_ulog_request *)(msg + 1);
 
-	if (!cap_raised(nsp->eff_cap, CAP_SYS_ADMIN))
+	if (!cap_raised(current_cap(), CAP_SYS_ADMIN))
 		return;
 
 	spin_lock(&receiving_list_lock);
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 66823b8..4c4ac3f 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -160,7 +160,6 @@ struct netlink_skb_parms {
 	struct ucred		creds;		/* Skb credentials	*/
 	__u32			pid;
 	__u32			dst_group;
-	kernel_cap_t		eff_cap;
 };
 
 #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 97ecd92..a808fb1 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1364,12 +1364,6 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	NETLINK_CB(skb).dst_group = dst_group;
 	memcpy(NETLINK_CREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
 
-	/* What can I do? Netlink is asynchronous, so that
-	   we will have to save current capabilities to
-	   check them, when this message will be delivered
-	   to corresponding kernel module.   --ANK (980802)
-	 */
-
 	err = -EFAULT;
 	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
 		kfree_skb(skb);
diff --git a/security/commoncap.c b/security/commoncap.c
index 64c2ed9..a83e607 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -52,13 +52,12 @@ static void warn_setuid_and_fcaps_mixed(const char *fname)
 
 int cap_netlink_send(struct sock *sk, struct sk_buff *skb)
 {
-	NETLINK_CB(skb).eff_cap = current_cap();
 	return 0;
 }
 
 int cap_netlink_recv(struct sk_buff *skb, int cap)
 {
-	if (!cap_raised(NETLINK_CB(skb).eff_cap, cap))
+	if (!cap_raised(current_cap(), cap))
 		return -EPERM;
 	return 0;
 }

--------------080700080301090103000800--
