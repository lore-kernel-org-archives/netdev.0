From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 05/10] tun: Grab the netns in open.
Date: Tue, 20 Jan 2009 13:01:48 -0800
Message-ID: <m17i4plmir.fsf_-_@fess.ebiederm.org>
References: <m1y6x5lmvy.fsf@fess.ebiederm.org>
	<m1skndlmrv.fsf@fess.ebiederm.org>
	<m1mydllmpf.fsf_-_@fess.ebiederm.org>
	<m1hc3tlmna.fsf_-_@fess.ebiederm.org>
	<m1bpu1lmkn.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Max Krasnyansky <maxk@qualcomm.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52473 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755088AbZAUCpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 21:45:16 -0500
Received: from mx04.mta.xmission.com ([166.70.13.214])
	by out01.mta.xmission.com with esmtp (Exim 4.62)
	(envelope-from <ebiederm@xmission.com>)
	id 1LPT5q-0007YJ-Kx
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 19:45:26 -0700
Received: from c-24-130-11-59.hsd1.ca.comcast.net ([24.130.11.59] helo=fess.ebiederm.org)
	by mx04.mta.xmission.com with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <ebiederm@xmission.com>)
	id 1LPT5f-00054R-Pq
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 19:45:16 -0700
Received: from fess.ebiederm.org (localhost [127.0.0.1])
	by fess.ebiederm.org (8.14.3/8.14.3/Debian-4) with ESMTP id n0L2jHEa029113
	for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 18:45:17 -0800
Received: (from eric@localhost)
	by fess.ebiederm.org (8.14.3/8.14.3/Submit) id n0L2jHaU029112
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 18:45:17 -0800
In-Reply-To: <m1bpu1lmkn.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's message of "Tue\, 20 Jan 2009 13\:00\:40 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Grabbing namespaces in open, and putting them in close always seems to
be the cleanest approach with the fewest surprises.

So now that we have tun_file so we have somepleace to put the network
namespace, let's grab the network namespace on file open and put on
file close.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/tun.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index d3a665d..dfbf586 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -89,6 +89,7 @@ struct tap_filter {
 
 struct tun_file {
 	struct tun_struct *tun;
+	struct net *net;
 };
 
 struct tun_struct {
@@ -131,7 +132,6 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 
 	tfile->tun = tun;
 	tun->tfile = tfile;
-	get_net(dev_net(tun->dev));
 
 	return 0;
 }
@@ -143,7 +143,6 @@ static void __tun_detach(struct tun_struct *tun)
 	/* Detach from net device */
 	tfile->tun = NULL;
 	tun->tfile = NULL;
-	put_net(dev_net(tun->dev));
 
 	/* Drop read queue */
 	skb_queue_purge(&tun->readq);
@@ -936,6 +935,7 @@ static int set_offload(struct net_device *dev, unsigned long arg)
 static int tun_chr_ioctl(struct inode *inode, struct file *file,
 			 unsigned int cmd, unsigned long arg)
 {
+	struct tun_file *tfile = file->private_data;
 	struct tun_struct *tun;
 	void __user* argp = (void __user*)arg;
 	struct ifreq ifr;
@@ -954,14 +954,14 @@ static int tun_chr_ioctl(struct inode *inode, struct file *file,
 				(unsigned int __user*)argp);
 	}
 
-	tun = tun_get(file);
+	tun = __tun_get(tfile);
 	if (cmd == TUNSETIFF && !tun) {
 		int err;
 
 		ifr.ifr_name[IFNAMSIZ-1] = '\0';
 
 		rtnl_lock();
-		err = tun_set_iff(current->nsproxy->net_ns, file, &ifr);
+		err = tun_set_iff(tfile->net, file, &ifr);
 		rtnl_unlock();
 
 		if (err)
@@ -1125,6 +1125,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 	if (!tfile)
 		return -ENOMEM;
 	tfile->tun = NULL;
+	tfile->net = get_net(current->nsproxy->net_ns);
 	file->private_data = tfile;
 	return 0;
 }
@@ -1148,6 +1149,7 @@ static int tun_chr_close(struct inode *inode, struct file *file)
 		rtnl_unlock();
 	}
 
+	put_net(tfile->net);
 	kfree(tfile);
 
 	return 0;
-- 
1.5.6.3
