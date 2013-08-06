From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/2] ip_tunnel: embed hash list head
Date: Mon, 5 Aug 2013 22:51:37 -0700
Message-ID: <20130805225137.6c934d7f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:57854 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652Ab3HFFyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 01:54:07 -0400
Received: by mail-pd0-f177.google.com with SMTP id u10so4118274pdi.36
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 22:54:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IP tunnel hash heads can be embedded in the per-net structure
since it is a fixed size. Reduce the size so that the total structure
fits in a page size. The original size was overly large, even NETDEV_HASHBITS
is only 8 bits!

Also, add some white space for readability.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/ipv4/ip_tunnel.c	2013-07-20 10:25:11.207494774 -0700
+++ b/net/ipv4/ip_tunnel.c	2013-07-24 08:40:11.025668961 -0700
@@ -838,15 +838,16 @@ int ip_tunnel_init_net(struct net *net,
 {
 	struct ip_tunnel_net *itn = net_generic(net, ip_tnl_net_id);
 	struct ip_tunnel_parm parms;
+	unsigned int i;
 
-	itn->tunnels = kzalloc(IP_TNL_HASH_SIZE * sizeof(struct hlist_head), GFP_KERNEL);
-	if (!itn->tunnels)
-		return -ENOMEM;
+	for (i = 0; i < IP_TNL_HASH_SIZE; i++)
+		INIT_HLIST_HEAD(&itn->tunnels[i]);
 
 	if (!ops) {
 		itn->fb_tunnel_dev = NULL;
 		return 0;
 	}
+
 	memset(&parms, 0, sizeof(parms));
 	if (devname)
 		strlcpy(parms.name, devname, IFNAMSIZ);
@@ -854,10 +855,9 @@ int ip_tunnel_init_net(struct net *net,
 	rtnl_lock();
 	itn->fb_tunnel_dev = __ip_tunnel_create(net, ops, &parms);
 	rtnl_unlock();
-	if (IS_ERR(itn->fb_tunnel_dev)) {
-		kfree(itn->tunnels);
+
+	if (IS_ERR(itn->fb_tunnel_dev))
 		return PTR_ERR(itn->fb_tunnel_dev);
-	}
 
 	return 0;
 }
@@ -887,7 +887,6 @@ void ip_tunnel_delete_net(struct ip_tunn
 	ip_tunnel_destroy(itn, &list);
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
-	kfree(itn->tunnels);
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_delete_net);
 
--- a/include/net/ip_tunnels.h	2013-06-28 08:16:54.093005290 -0700
+++ b/include/net/ip_tunnels.h	2013-07-24 08:39:20.822260842 -0700
@@ -86,12 +86,12 @@ struct tnl_ptk_info {
 #define PACKET_RCVD	0
 #define PACKET_REJECT	1
 
-#define IP_TNL_HASH_BITS   10
+#define IP_TNL_HASH_BITS   7
 #define IP_TNL_HASH_SIZE   (1 << IP_TNL_HASH_BITS)
 
 struct ip_tunnel_net {
-	struct hlist_head *tunnels;
 	struct net_device *fb_tunnel_dev;
+	struct hlist_head tunnels[IP_TNL_HASH_SIZE];
 };
 
 #ifdef CONFIG_INET
