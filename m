From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [irda-users] [PATCH 5/7] [IrDA] IrDA monitor mode
Date: Sun, 22 Apr 2007 14:29:07 +0300
Message-ID: <20070422112906.GA4588@sortiz.org>
References: <20070418214751.455457680@sortiz.org> <20070420.221143.132446079.davem@davemloft.net> <20070421114239.GA4337@sortiz.org> <20070421.104600.30183443.davem@davemloft.net>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp21.orange.fr ([80.12.242.46]:28770 "EHLO smtp21.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754171AbXDVL2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Apr 2007 07:28:51 -0400
Content-Disposition: inline
In-Reply-To: <20070421.104600.30183443.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 21, 2007 at 10:46:00AM -0700, David Miller wrote:
> From: Samuel Ortiz <samuel@sortiz.org>
> Date: Sat, 21 Apr 2007 14:42:40 +0300
> 
> > I actually asked for your advice about it some time ago:
> > http://marc.info/?l=linux-netdev&m=117590341703544&w=2
> > But by looking at the flow of emails on netdev sent to you (and that's only
> > netdev...), I can easily see how you could have missed it :-)
> > 
> > Regarding this patch, I came up with this ioctl because I thought
> > implementing an IrDA netlink layer would be an overkill for just one single
> > command.
> > What I propose is that you revert this patch before we introduce a new ioctl
> > upstream while I start implementing a netlink IrDA layer. Would that be ok
> > with you, or can we let this new ioctl in and have it coexisting with a future
> > netlink layer ?
> 
> The only concern is that once we add the ioctl, we can't get rid of
> it, it's there forever.  Please consider this very carefully.
> 
> You might discover that once you create the IRDA netlink
> layer, you will find it convenient to make it support
> all the IRDA stack configuration not just this one thing
> :-)
Fair enough, let's revert, and I'll come back to you with an IrDA netlink
layer:

---
This reverts commit 8eb943bbb8d2b59a5dccfed691da2e3797ef7e8e.

Let's not introduce yet another ioctl. The IrDA monitoring feature will be
implemented through the addition of an IrDA netlink layer.

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 include/linux/irda.h     |    7 -----
 include/net/irda/irlap.h |    2 -
 net/irda/af_irda.c       |   58 +---------------------------------------------
 net/irda/irlap_frame.c   |    8 ------
 4 files changed, 1 insertions(+), 74 deletions(-)

diff --git a/include/linux/irda.h b/include/linux/irda.h
index 1050f98..09d8f10 100644
--- a/include/linux/irda.h
+++ b/include/linux/irda.h
@@ -172,12 +172,6 @@ struct irda_ias_set {
 #define SIOCSDTRRTS    (SIOCDEVPRIVATE + 8)
 #define SIOCGQOS       (SIOCDEVPRIVATE + 9)
 
-/* Protocol private ioctls */
-#define SIOCIRDASETMODE (SIOCPROTOPRIVATE + 0)
-#define SIOCIRDAGETMODE (SIOCPROTOPRIVATE + 1)
-
-#define IRDA_MODE_MONITOR   0x1
-
 /* No reason to include <linux/if.h> just because of this one ;-) */
 #define IRNAMSIZ 16 
 
@@ -215,7 +209,6 @@ struct if_irda_req {
 	} ifr_ifru;
 };
 
-#define ifr_name      ifr_ifrn.ifrn_name
 #define ifr_baudrate  ifr_ifru.ifru_qos.baudrate
 #define ifr_receiving ifr_ifru.ifru_receiving 
 #define ifr_dongle    ifr_ifru.ifru_dongle
diff --git a/include/net/irda/irlap.h b/include/net/irda/irlap.h
index 02b08d2..e77eb88 100644
--- a/include/net/irda/irlap.h
+++ b/include/net/irda/irlap.h
@@ -208,8 +208,6 @@ struct irlap_cb {
 	int    xbofs_delay;   /* Nr of XBOF's used to MTT */
 	int    bofs_count;    /* Negotiated extra BOFs */
 	int    next_bofs;     /* Negotiated extra BOFs after next frame */
-
-	int    mode;     /* 1 is for monitor mode (TX disabled) */
 };
 
 /* 
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index b1aa951..06c97c6 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -49,6 +49,7 @@
 #include <linux/sockios.h>
 #include <linux/init.h>
 #include <linux/net.h>
+#include <linux/irda.h>
 #include <linux/poll.h>
 
 #include <asm/ioctls.h>		/* TIOCOUTQ, TIOCINQ */
@@ -1743,7 +1744,6 @@ static unsigned int irda_poll(struct file * file, struct socket *sock,
 static int irda_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
-	void __user *argp = (void __user *)arg;
 
 	IRDA_DEBUG(4, "%s(), cmd=%#x\n", __FUNCTION__, cmd);
 
@@ -1785,62 +1785,6 @@ static int irda_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	case SIOCGIFMETRIC:
 	case SIOCSIFMETRIC:
 		return -EINVAL;
-
-	case SIOCIRDASETMODE: {
-		struct if_irda_req if_irda;
-		struct net_device * dev;
-		struct irlap_cb * irlap;
-
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-
-		if (copy_from_user(&if_irda, argp, sizeof(struct if_irda_req)))
-			return -EFAULT;
-
-		dev = dev_get_by_name(if_irda.ifr_name);
-		if (!dev)
-			return -ENODEV;
-
-		irlap = (struct irlap_cb *)dev->atalk_ptr;
-		if (!irlap)
-			return -ENODEV;
-
-		IRDA_DEBUG(4, "%s(): Setting %s to 0x%x\n", __FUNCTION__,
-			   dev->name, if_irda.ifr_mode);
-
-		irlap->mode = if_irda.ifr_mode;
-
-		dev_put(dev);
-
-		break;
-	}
-	case SIOCIRDAGETMODE: {
-		struct if_irda_req if_irda;
-		struct net_device * dev;
-		struct irlap_cb * irlap;
-
-		if (copy_from_user(&if_irda, argp, sizeof(struct if_irda_req)))
-			return -EFAULT;
-
-		dev = dev_get_by_name(if_irda.ifr_name);
-		if (!dev)
-			return -ENODEV;
-
-		irlap = (struct irlap_cb *)dev->atalk_ptr;
-		if (!irlap)
-			return -ENODEV;
-
-		if_irda.ifr_mode = irlap->mode;
-
-		dev_put(dev);
-
-		IRDA_DEBUG(4, "%s(): %s mode is 0x%x\n", __FUNCTION__,
-			   dev->name, if_irda.ifr_mode);
-
-		if (copy_to_user(argp, &if_irda, sizeof(struct if_irda_req)))
-			return -EFAULT;
-	}
-		break;
 	default:
 		IRDA_DEBUG(1, "%s(), doing device ioctl!\n", __FUNCTION__);
 		return -ENOIOCTLCMD;
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index 8acc356..3c5a68e 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -101,14 +101,6 @@ void irlap_queue_xmit(struct irlap_cb *self, struct sk_buff *skb)
 
 	irlap_insert_info(self, skb);
 
-	if (unlikely(self->mode & IRDA_MODE_MONITOR)) {
-		IRDA_DEBUG(3, "%s(): %s is in monitor mode\n", __FUNCTION__,
-			   self->netdev->name);
-		dev_kfree_skb(skb);
-		return;
-	}
-
-
 	dev_queue_xmit(skb);
 }
 
-- 
1.5.1.1


