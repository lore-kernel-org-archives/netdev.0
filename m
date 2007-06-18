From: James Morris <jmorris@namei.org>
Subject: [PATCH] Allow group ownership of TUN/TAP devices (fwd)
Date: Mon, 18 Jun 2007 12:16:31 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0706181216230.8746@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:58573 "EHLO
	mail2.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758362AbXFRQQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 12:16:34 -0400
Received: from dsl092-066-197.bos1.dsl.speakeasy.net (HELO d.namei) ([66.92.66.197])
          (envelope-sender <jmorris@namei.org>)
          by mail2.sea5.speakeasy.net (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 18 Jun 2007 16:16:33 -0000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

---------- Forwarded message ----------
Date: Mon, 18 Jun 2007 12:05:49 -0400
From: Jeff Dike <jdike@addtoit.com>
To: maxk@qualcomm.com
Cc: Guido Guenther <agx@sigxcpu.org>, LKML <linux-kernel@vger.kernel.org>,
    vtun@office.satix.net
Subject: [PATCH] Allow group ownership of TUN/TAP devices

I recieved from Guido Guenther the patch below to the TUN/TAP driver
which allows group ownerships to be effective.

It seems reasonable to me.

> the attached patches allow tun ownership by group. We found this useful
> since we can then spawn tapX devices on system boot (via
> /etc/network/interfaces) which logged on users can then use for their
> virtual machines.
>   
> The first patch is for the kernel, the second one for the tunctl. They
> shouldn't change existing behaviour and we introduced a new syscall for
> the group setting. The user now is allowed to send packages if either
> his euid or his egid matches the one specified via tunctl (via -u or -g
> respecitvely). If both gid and uid are set via tunctl, both have to
> match. In case you find these useful, please apply.

-- 
Work email - jdike at linux dot intel dot com

From: Guido Guenther <agx@sigxcpu.org>
Date: Fri, 25 May 2007 11:10:27 +0200
Subject: [PATCH] allow tun ownership by group

---
 drivers/net/tun.c      |   15 +++++++++++++--
 include/linux/if_tun.h |    2 ++
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index a2c6caa..62b2b30 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -432,6 +432,7 @@ static void tun_setup(struct net_device *dev)
 	init_waitqueue_head(&tun->read_wait);
 
 	tun->owner = -1;
+	tun->group = -1;
 
 	SET_MODULE_OWNER(dev);
 	dev->open = tun_net_open;
@@ -467,8 +468,11 @@ static int tun_set_iff(struct file *file, struct ifreq *ifr)
 			return -EBUSY;
 
 		/* Check permissions */
-		if (tun->owner != -1 &&
-		    current->euid != tun->owner && !capable(CAP_NET_ADMIN))
+		if (((tun->owner != -1 &&
+		      current->euid != tun->owner) ||
+		     (tun->group != -1 &&
+		      current->egid != tun->group)) &&
+		     !capable(CAP_NET_ADMIN))
 			return -EPERM;
 	}
 	else if (__dev_get_by_name(ifr->ifr_name))
@@ -610,6 +614,13 @@ static int tun_chr_ioctl(struct inode *inode, struct file *file,
 		DBG(KERN_INFO "%s: owner set to %d\n", tun->dev->name, tun->owner);
 		break;
 
+	case TUNSETGROUP:
+		/* Set group of the device */
+		tun->group= (gid_t) arg;
+
+		DBG(KERN_INFO "%s: group set to %d\n", tun->dev->name, tun->group);
+		break;
+
 	case TUNSETLINK:
 		/* Only allow setting the type when the interface is down */
 		if (tun->dev->flags & IFF_UP) {
diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
index 88aef7b..42eb694 100644
--- a/include/linux/if_tun.h
+++ b/include/linux/if_tun.h
@@ -36,6 +36,7 @@ struct tun_struct {
 	unsigned long 		flags;
 	int			attached;
 	uid_t			owner;
+	gid_t			group;
 
 	wait_queue_head_t	read_wait;
 	struct sk_buff_head	readq;
@@ -78,6 +79,7 @@ struct tun_struct {
 #define TUNSETPERSIST _IOW('T', 203, int) 
 #define TUNSETOWNER   _IOW('T', 204, int)
 #define TUNSETLINK    _IOW('T', 205, int)
+#define TUNSETGROUP   _IOW('T', 206, int)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
-- 
1.5.1.4

-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
