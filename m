From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-2.6.25 17/19] [NETNS] Pass namespace through ip_rt_ioctl.
Date: Wed, 19 Dec 2007 18:24:47 +0300
Message-ID: <1198077889-10693-18-git-send-email-den@openvz.org>
References: <4769370F.5020303@openvz.org>
Cc: benjamin.thery@bull.net, dlezcano@fr.ibm.com, devel@openvz.org,
	containers@lists.osdl.org, netdev@vger.kernel.org, xemul@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:62023 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755240AbXLSPXC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2007 10:23:02 -0500
In-Reply-To: <4769370F.5020303@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

... up to rtentry_to_fib_config

Acked-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/route.h     |    2 +-
 net/ipv4/af_inet.c      |    2 +-
 net/ipv4/fib_frontend.c |    8 ++++----
 net/ipv4/ipconfig.c     |    2 +-
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index b777000..5847e6f 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -120,7 +120,7 @@ extern void		ip_rt_send_redirect(struct sk_buff *skb);
 extern unsigned		inet_addr_type(struct net *net, __be32 addr);
 extern unsigned		inet_dev_addr_type(struct net *net, const struct net_device *dev, __be32 addr);
 extern void		ip_rt_multicast_event(struct in_device *);
-extern int		ip_rt_ioctl(unsigned int cmd, void __user *arg);
+extern int		ip_rt_ioctl(struct net *, unsigned int cmd, void __user *arg);
 extern void		ip_rt_get_source(u8 *src, struct rtable *rt);
 extern int		ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb);
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 6fac905..f0968a1 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -793,7 +793,7 @@ int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		case SIOCADDRT:
 		case SIOCDELRT:
 		case SIOCRTMSG:
-			err = ip_rt_ioctl(cmd, (void __user *)arg);
+			err = ip_rt_ioctl(sk->sk_net, cmd, (void __user *)arg);
 			break;
 		case SIOCDARP:
 		case SIOCGARP:
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index cecb660..a5c47fc 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -437,7 +437,7 @@ static int rtentry_to_fib_config(struct net *net, int cmd, struct rtentry *rt,
  *	Handle IP routing ioctl calls. These are used to manipulate the routing tables
  */
 
-int ip_rt_ioctl(unsigned int cmd, void __user *arg)
+int ip_rt_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 {
 	struct fib_config cfg;
 	struct rtentry rt;
@@ -453,18 +453,18 @@ int ip_rt_ioctl(unsigned int cmd, void __user *arg)
 			return -EFAULT;
 
 		rtnl_lock();
-		err = rtentry_to_fib_config(&init_net, cmd, &rt, &cfg);
+		err = rtentry_to_fib_config(net, cmd, &rt, &cfg);
 		if (err == 0) {
 			struct fib_table *tb;
 
 			if (cmd == SIOCDELRT) {
-				tb = fib_get_table(&init_net, cfg.fc_table);
+				tb = fib_get_table(net, cfg.fc_table);
 				if (tb)
 					err = tb->tb_delete(tb, &cfg);
 				else
 					err = -ESRCH;
 			} else {
-				tb = fib_new_table(&init_net, cfg.fc_table);
+				tb = fib_new_table(net, cfg.fc_table);
 				if (tb)
 					err = tb->tb_insert(tb, &cfg);
 				else
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 7288adb..7a89247 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -302,7 +302,7 @@ static int __init ic_route_ioctl(unsigned int cmd, struct rtentry *arg)
 
 	mm_segment_t oldfs = get_fs();
 	set_fs(get_ds());
-	res = ip_rt_ioctl(cmd, (void __user *) arg);
+	res = ip_rt_ioctl(&init_net, cmd, (void __user *) arg);
 	set_fs(oldfs);
 	return res;
 }
-- 
1.5.3.rc5

