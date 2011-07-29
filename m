From: Petar Bogdanovic <petar@smokva.net>
Subject: [PATCH] drivers/net/tun.c: test for CAP_NET_ADMIN before attaching
Date: Fri, 29 Jul 2011 16:28:08 +0200
Message-ID: <20110729142808.GA25695@pintail.smokva.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from morrison.andev.ch ([78.47.142.202]:65349 "EHLO
	morrison.andev.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092Ab1G2O2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 10:28:12 -0400
Received: from pintail.smokva.net (84-73-26-94.dclient.hispeed.ch [84.73.26.94])
	by morrison.andev.ch (Postfix) with ESMTP id 16E915DA90
	for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 16:28:19 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following change will test for CAP_NET_ADMIN before attaching, even
if both tun->owner and tun->group equal -1.  The latter scenario can be
reproduced with ip(8) from iproute2, when using `ip tuntap' without the
`user' and `group' option.


diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 55f3a3e..2ac2cbc 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -988,35 +988,35 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	struct net_device *dev;
 	int err;
 
 	dev = __dev_get_by_name(net, ifr->ifr_name);
 	if (dev) {
 		const struct cred *cred = current_cred();
 
 		if (ifr->ifr_flags & IFF_TUN_EXCL)
 			return -EBUSY;
 		if ((ifr->ifr_flags & IFF_TUN) && dev->netdev_ops == &tun_netdev_ops)
 			tun = netdev_priv(dev);
 		else if ((ifr->ifr_flags & IFF_TAP) && dev->netdev_ops == &tap_netdev_ops)
 			tun = netdev_priv(dev);
 		else
 			return -EINVAL;
 
-		if (((tun->owner != -1 && cred->euid != tun->owner) ||
-		     (tun->group != -1 && !in_egroup_p(tun->group))) &&
-		    !capable(CAP_NET_ADMIN))
+		if (!(tun->owner != -1 && cred->euid == tun->owner ||
+		      tun->group != -1 && in_egroup_p(tun->group) ||
+		      capable(CAP_NET_ADMIN)))
 			return -EPERM;
 		err = security_tun_dev_attach(tun->socket.sk);
 		if (err < 0)
 			return err;
 
 		err = tun_attach(tun, file);
 		if (err < 0)
 			return err;
 	}
 	else {
 		char *name;
 		unsigned long flags = 0;
 
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 		err = security_tun_dev_create();
