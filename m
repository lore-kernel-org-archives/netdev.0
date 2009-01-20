From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 02/10] tun: Fix races in tun_set_iff
Date: Tue, 20 Jan 2009 12:57:48 -0800
Message-ID: <m1mydllmpf.fsf_-_@fess.ebiederm.org>
References: <m1y6x5lmvy.fsf@fess.ebiederm.org>
	<m1skndlmrv.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Max Krasnyansky <maxk@qualcomm.com>,
	Pavel Emelyanov <xemul@openvz.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52471 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755306AbZAUCpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 21:45:15 -0500
Received: from mx04.mta.xmission.com ([166.70.13.214])
	by out01.mta.xmission.com with esmtp (Exim 4.62)
	(envelope-from <ebiederm@xmission.com>)
	id 1LPT5p-0007YD-Nc
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 19:45:25 -0700
Received: from c-24-130-11-59.hsd1.ca.comcast.net ([24.130.11.59] helo=fess.ebiederm.org)
	by mx04.mta.xmission.com with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <ebiederm@xmission.com>)
	id 1LPT5e-00054F-IT
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 19:45:15 -0700
Received: from fess.ebiederm.org (localhost [127.0.0.1])
	by fess.ebiederm.org (8.14.3/8.14.3/Debian-4) with ESMTP id n0L2jG69029101
	for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 18:45:16 -0800
Received: (from eric@localhost)
	by fess.ebiederm.org (8.14.3/8.14.3/Submit) id n0L2jFh3029100
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 18:45:15 -0800
In-Reply-To: <m1skndlmrv.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Tue\, 20 Jan 2009 12\:56\:20 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is possible for two different tasks with access to the same file
descriptor to call tun_set_iff on it at the same time and race to
attach to a tap device.  Prevent this by placing all of the logic to
attach to a file descriptor in one function and testing the file
descriptor to be certain it is not already attached to another tun
device.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/tun.c |   48 ++++++++++++++++++++++++++++++++----------------
 1 files changed, 32 insertions(+), 16 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 17923a5..20ef14d 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -106,6 +106,31 @@ struct tun_struct {
 #endif
 };
 
+static int tun_attach(struct tun_struct *tun, struct file *file)
+{
+	const struct cred *cred = current_cred();
+
+	ASSERT_RTNL();
+
+	if (file->private_data)
+		return -EINVAL;
+
+	if (tun->attached)
+		return -EBUSY;
+
+	/* Check permissions */
+	if (((tun->owner != -1 && cred->euid != tun->owner) ||
+	     (tun->group != -1 && cred->egid != tun->group)) &&
+		!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	file->private_data = tun;
+	tun->attached = 1;
+	get_net(dev_net(tun->dev));
+
+	return 0;
+}
+
 /* TAP filterting */
 static void addr_hash_set(u32 *mask, const u8 *addr)
 {
@@ -695,7 +720,6 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 {
 	struct tun_struct *tun;
 	struct net_device *dev;
-	const struct cred *cred = current_cred();
 	int err;
 
 	dev = __dev_get_by_name(net, ifr->ifr_name);
@@ -707,17 +731,9 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		else
 			return -EINVAL;
 
-		if (tun->attached)
-			return -EBUSY;
-
-		/* Check permissions */
-		if (((tun->owner != -1 &&
-		      cred->euid != tun->owner) ||
-		     (tun->group != -1 &&
-		      cred->egid != tun->group)) &&
-		    !capable(CAP_NET_ADMIN)) {
-			return -EPERM;
-		}
+		err = tun_attach(tun, file);
+		if (err < 0)
+			return err;
 	}
 	else {
 		char *name;
@@ -766,6 +782,10 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		err = register_netdevice(tun->dev);
 		if (err < 0)
 			goto err_free_dev;
+
+		err = tun_attach(tun, file);
+		if (err < 0)
+			goto err_free_dev;
 	}
 
 	DBG(KERN_INFO "%s: tun_set_iff\n", tun->dev->name);
@@ -785,10 +805,6 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	else
 		tun->flags &= ~TUN_VNET_HDR;
 
-	file->private_data = tun;
-	tun->attached = 1;
-	get_net(dev_net(tun->dev));
-
 	/* Make sure persistent devices do not get stuck in
 	 * xoff state.
 	 */
-- 
1.5.6.3
