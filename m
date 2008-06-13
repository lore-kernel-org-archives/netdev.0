From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [RFC PATCH net-2.6] ipv6 sit: Avoid extra need for compat layer in
 PRL management.
Date: Fri, 13 Jun 2008 10:01:14 +0900 (JST)
Message-ID: <20080613.100114.97370932.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59330 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760904AbYFMBAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 21:00:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We've introduced extra need of compat layer for ip_tunnel_prl{}
for PRL (Potential Router List) management.  Though compat_ioctl
is still missing in ipv4/ipv6, let's make the interface more
straight-forward and eliminate extra need for nasty compat layer
anyway since the interface is new for 2.6.26.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/if_tunnel.h |    2 +-
 net/ipv6/sit.c            |   44 ++++++++++++++++++++++++--------------------
 2 files changed, 25 insertions(+), 21 deletions(-)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index f1fbe9c..d4efe40 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -41,7 +41,7 @@ struct ip_tunnel_prl {
 	__u16			__reserved;
 	__u32			datalen;
 	__u32			__reserved2;
-	void __user		*data;
+	/* data follows */
 };
 
 /* PRL flags */
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 3de6ffd..32e871a 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -222,15 +222,18 @@ __ipip6_tunnel_locate_prl(struct ip_tunnel *t, __be32 addr)
 
 }
 
-static int ipip6_tunnel_get_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a)
+static int ipip6_tunnel_get_prl(struct ip_tunnel *t,
+				struct ip_tunnel_prl __user *a)
 {
-	struct ip_tunnel_prl *kp;
+	struct ip_tunnel_prl kprl, *kp;
 	struct ip_tunnel_prl_entry *prl;
 	unsigned int cmax, c = 0, ca, len;
 	int ret = 0;
 
-	cmax = a->datalen / sizeof(*a);
-	if (cmax > 1 && a->addr != htonl(INADDR_ANY))
+	if (copy_from_user(&kprl, a, sizeof(kprl)))
+		return -EFAULT;
+	cmax = kprl.datalen / sizeof(kprl);
+	if (cmax > 1 && kprl.addr != htonl(INADDR_ANY))
 		cmax = 1;
 
 	/* For simple GET or for root users,
@@ -261,26 +264,25 @@ static int ipip6_tunnel_get_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a)
 	for (prl = t->prl; prl; prl = prl->next) {
 		if (c > cmax)
 			break;
-		if (a->addr != htonl(INADDR_ANY) && prl->addr != a->addr)
+		if (kprl.addr != htonl(INADDR_ANY) && prl->addr != kprl.addr)
 			continue;
 		kp[c].addr = prl->addr;
 		kp[c].flags = prl->flags;
 		c++;
-		if (a->addr != htonl(INADDR_ANY))
+		if (kprl.addr != htonl(INADDR_ANY))
 			break;
 	}
 out:
 	read_unlock(&ipip6_lock);
 
 	len = sizeof(*kp) * c;
-	ret = len ? copy_to_user(a->data, kp, len) : 0;
+	ret = 0;
+	if ((len && copy_to_user(a + 1, kp, len)) || put_user(len, &a->datalen))
+		ret = -EFAULT;
 
 	kfree(kp);
-	if (ret)
-		return -EFAULT;
 
-	a->datalen = len;
-	return 0;
+	return ret;
 }
 
 static int
@@ -873,11 +875,20 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		break;
 
 	case SIOCGETPRL:
+		err = -EINVAL;
+		if (dev == sitn->fb_tunnel_dev)
+			goto done;
+		err = -ENOENT;
+		if (!(t = netdev_priv(dev)))
+			goto done;
+		err = ipip6_tunnel_get_prl(t, ifr->ifr_ifru.ifru_data);
+		break;
+
 	case SIOCADDPRL:
 	case SIOCDELPRL:
 	case SIOCCHGPRL:
 		err = -EPERM;
-		if (cmd != SIOCGETPRL && !capable(CAP_NET_ADMIN))
+		if (!capable(CAP_NET_ADMIN))
 			goto done;
 		err = -EINVAL;
 		if (dev == sitn->fb_tunnel_dev)
@@ -890,12 +901,6 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 			goto done;
 
 		switch (cmd) {
-		case SIOCGETPRL:
-			err = ipip6_tunnel_get_prl(t, &prl);
-			if (!err && copy_to_user(ifr->ifr_ifru.ifru_data,
-						 &prl, sizeof(prl)))
-				err = -EFAULT;
-			break;
 		case SIOCDELPRL:
 			err = ipip6_tunnel_del_prl(t, &prl);
 			break;
@@ -904,8 +909,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 			err = ipip6_tunnel_add_prl(t, &prl, cmd == SIOCCHGPRL);
 			break;
 		}
-		if (cmd != SIOCGETPRL)
-			netdev_state_change(dev);
+		netdev_state_change(dev);
 		break;
 
 	default:
-- 
1.4.4.4

