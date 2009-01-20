From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 06/10] tun: Make tun_net_xmit atomic wrt tun_attach && tun_detach
Date: Tue, 20 Jan 2009 13:02:28 -0800
Message-ID: <m11vuxlmhn.fsf_-_@fess.ebiederm.org>
References: <m1y6x5lmvy.fsf@fess.ebiederm.org>
	<m1skndlmrv.fsf@fess.ebiederm.org>
	<m1mydllmpf.fsf_-_@fess.ebiederm.org>
	<m1hc3tlmna.fsf_-_@fess.ebiederm.org>
	<m1bpu1lmkn.fsf_-_@fess.ebiederm.org>
	<m17i4plmir.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Max Krasnyansky <maxk@qualcomm.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52475 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755478AbZAUCpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 21:45:17 -0500
Received: from mx04.mta.xmission.com ([166.70.13.214])
	by out01.mta.xmission.com with esmtp (Exim 4.62)
	(envelope-from <ebiederm@xmission.com>)
	id 1LPT5r-0007YP-14
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 19:45:27 -0700
Received: from c-24-130-11-59.hsd1.ca.comcast.net ([24.130.11.59] helo=fess.ebiederm.org)
	by mx04.mta.xmission.com with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <ebiederm@xmission.com>)
	id 1LPT5g-00054T-6D
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 19:45:16 -0700
Received: from fess.ebiederm.org (localhost [127.0.0.1])
	by fess.ebiederm.org (8.14.3/8.14.3/Debian-4) with ESMTP id n0L2jHVE029117
	for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 18:45:17 -0800
Received: (from eric@localhost)
	by fess.ebiederm.org (8.14.3/8.14.3/Submit) id n0L2jHBC029116
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 18:45:17 -0800
In-Reply-To: <m17i4plmir.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's message of "Tue\, 20 Jan 2009 13\:01\:48 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Currently this small race allows for a packet to be received when we
detach from an tun device and still be enqueued.  Not especially
important but not what the code is trying to do.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/tun.c |   24 +++++++++++++++++-------
 1 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index dfbf586..fa93160 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -115,25 +115,33 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 {
 	struct tun_file *tfile = file->private_data;
 	const struct cred *cred = current_cred();
+	int err;
 
 	ASSERT_RTNL();
 
-	if (tfile->tun)
-		return -EINVAL;
-
-	if (tun->tfile)
-		return -EBUSY;
-
 	/* Check permissions */
 	if (((tun->owner != -1 && cred->euid != tun->owner) ||
 	     (tun->group != -1 && cred->egid != tun->group)) &&
 		!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
+	netif_tx_lock_bh(tun->dev);
+
+	err = -EINVAL;
+	if (tfile->tun)
+		goto out;
+
+	err = -EBUSY;
+	if (tun->tfile)
+		goto out;
+
+	err = 0;
 	tfile->tun = tun;
 	tun->tfile = tfile;
 
-	return 0;
+out:
+	netif_tx_unlock_bh(tun->dev);
+	return err;
 }
 
 static void __tun_detach(struct tun_struct *tun)
@@ -141,8 +149,10 @@ static void __tun_detach(struct tun_struct *tun)
 	struct tun_file *tfile = tun->tfile;
 
 	/* Detach from net device */
+	netif_tx_lock_bh(tun->dev);
 	tfile->tun = NULL;
 	tun->tfile = NULL;
+	netif_tx_unlock_bh(tun->dev);
 
 	/* Drop read queue */
 	skb_queue_purge(&tun->readq);
-- 
1.5.6.3
