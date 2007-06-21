From: Jeff Dike <jdike@addtoit.com>
Subject: Re: [PATCH] Allow group ownership of TUN/TAP devices (fwd)
Date: Thu, 21 Jun 2007 10:59:11 -0400
Message-ID: <20070621145911.GA5874@c2.user-mode-linux.org>
References: <Line.LNX.4.64.0706181216230.8746@localhost.localdomain> <20070618.223654.14957392.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmorris@namei.org, netdev@vger.kernel.org,
	Guido Guenther <agx@sigxcpu.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.99.130.12] ([198.99.130.12]:34080 "EHLO
	saraswathi.solana.com" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752973AbXFUPZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 11:25:29 -0400
Content-Disposition: inline
In-Reply-To: <20070618.223654.14957392.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 18, 2007 at 10:36:54PM -0700, David Miller wrote:
> This patch looks fine.
> 
> I'd like it resubmitted with a proper changelog and signoff, and once
> I have that I will thus queue it up for the 2.6.23 merge window.

Introduce a new syscall TUNSETGROUP for group ownership setting of tap
devices. The user now is allowed to send packages if either his euid or
his egid matches the one specified via tunctl (via -u or -g
respecitvely). If both, gid and uid, are set via tunctl, both have to
match.

Signed-Off-By: Guido Guenther <agx@sigxcpu.org>
Signed-Off-By: Jeff Dike <jdike@linux.intel.com>

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
