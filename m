From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] net: unregister_netdevice as void
Date: Mon, 18 Dec 2006 21:05:11 -0800
Message-ID: <20061218210511.7064547c@localhost.localdomain>
References: <200612182256.kBIMuVio025766@fire-2.osdl.org>
	<20061218152111.868f9284.akpm@osdl.org>
	<20061218155057.1904f666@freekitty>
	<20061218.173745.08333482.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, benjamin.li@qlogic.com,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:39018 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752742AbWLSPkF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Dec 2006 10:40:05 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061218.173745.08333482.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There was no real useful information from the unregister_netdevice() return
code, the only error occurred in a situation that was a driver bug. So
change it to a void function.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 include/linux/netdevice.h |    2 +-
 net/core/dev.c            |   15 ++++++---------
 net/ipv4/ip_gre.c         |    3 ++-
 net/ipv4/ipip.c           |    3 ++-
 net/ipv6/ip6_tunnel.c     |    3 ++-
 net/ipv6/sit.c            |    3 ++-
 6 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6be767c..e16d66e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -588,7 +588,7 @@ extern int		dev_open(struct net_device *
 extern int		dev_close(struct net_device *dev);
 extern int		dev_queue_xmit(struct sk_buff *skb);
 extern int		register_netdevice(struct net_device *dev);
-extern int		unregister_netdevice(struct net_device *dev);
+extern void		unregister_netdevice(struct net_device *dev);
 extern void		free_netdev(struct net_device *dev);
 extern void		synchronize_net(void);
 extern int 		register_netdevice_notifier(struct notifier_block *nb);
diff --git a/net/core/dev.c b/net/core/dev.c
index e660cb5..4a8a7fd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3247,7 +3247,7 @@ void synchronize_net(void) 
  *	unregister_netdev() instead of this.
  */
 
-int unregister_netdevice(struct net_device *dev)
+void unregister_netdevice(struct net_device *dev)
 {
 	struct net_device *d, **dp;
 
@@ -3258,8 +3258,10 @@ int unregister_netdevice(struct net_devi
 	if (dev->reg_state == NETREG_UNINITIALIZED) {
 		printk(KERN_DEBUG "unregister_netdevice: device %s/%p never "
 				  "was registered\n", dev->name, dev);
-		return -ENODEV;
-	}
+		
+		WARN_ON(1);
+		return;
+	}		
 
 	BUG_ON(dev->reg_state != NETREG_REGISTERED);
 
@@ -3280,11 +3282,7 @@ int unregister_netdevice(struct net_devi
 			break;
 		}
 	}
-	if (!d) {
-		printk(KERN_ERR "unregister net_device: '%s' not found\n",
-		       dev->name);
-		return -ENODEV;
-	}
+	BUG_ON(!d);
 
 	dev->reg_state = NETREG_UNREGISTERING;
 
@@ -3316,7 +3314,6 @@ int unregister_netdevice(struct net_devi
 	synchronize_net();
 
 	dev_put(dev);
-	return 0;
 }
 
 /**
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 476cb60..51c8350 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1008,7 +1008,8 @@ ipgre_tunnel_ioctl (struct net_device *d
 				goto done;
 			dev = t->dev;
 		}
-		err = unregister_netdevice(dev);
+		unregister_netdevice(dev);
+		err = 0;
 		break;
 
 	default:
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 9d719d6..da8bbd2 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -754,7 +754,8 @@ ipip_tunnel_ioctl (struct net_device *de
 				goto done;
 			dev = t->dev;
 		}
-		err = unregister_netdevice(dev);
+		unregister_netdevice(dev);
+		err = 0;
 		break;
 
 	default:
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 8d91834..2b9e3bb 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -999,7 +999,8 @@ ip6ip6_tnl_ioctl(struct net_device *dev,
 				break;
 			dev = t->dev;
 		}
-		err = unregister_netdevice(dev);
+		err = 0;
+		unregister_netdevice(dev);
 		break;
 	default:
 		err = -EINVAL;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 77b7b09..47cfead 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -686,7 +686,8 @@ ipip6_tunnel_ioctl (struct net_device *d
 				goto done;
 			dev = t->dev;
 		}
-		err = unregister_netdevice(dev);
+		unregister_netdevice(dev);
+		err = 0;
 		break;
 
 	default:
-- 
1.4.2.4

