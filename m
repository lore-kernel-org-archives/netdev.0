From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 03/11] netpoll: no need to store local_mac
Date: Sat, 03 Nov 2007 11:43:17 -0700
Message-ID: <20071103184338.581312051@linux-foundation.org>
References: <20071103184314.216145305@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33513 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757817AbXKCXgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2007 19:36:36 -0400
Content-Disposition: inline; filename=netpoll-local-mac.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The local_mac is managed by the network device, no need to
keep a spare copy and all the management problems that could
cause.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/include/linux/netpoll.h	2007-11-03 09:12:48.000000000 -0700
+++ b/include/linux/netpoll.h	2007-11-03 09:18:34.000000000 -0700
@@ -20,7 +20,7 @@ struct netpoll {
 
 	u32 local_ip, remote_ip;
 	u16 local_port, remote_port;
- 	u8 local_mac[ETH_ALEN], remote_mac[ETH_ALEN];
+ 	u8 remote_mac[ETH_ALEN];
 };
 
 struct netpoll_info {
--- a/net/core/netpoll.c	2007-11-03 09:18:30.000000000 -0700
+++ b/net/core/netpoll.c	2007-11-03 09:19:34.000000000 -0700
@@ -360,8 +360,8 @@ void netpoll_send_udp(struct netpoll *np
 	eth = (struct ethhdr *) skb_push(skb, ETH_HLEN);
 	skb_reset_mac_header(skb);
 	skb->protocol = eth->h_proto = htons(ETH_P_IP);
-	memcpy(eth->h_source, np->local_mac, 6);
-	memcpy(eth->h_dest, np->remote_mac, 6);
+	memcpy(eth->h_source, np->dev->dev_addr, ETH_ALEN);
+	memcpy(eth->h_dest, np->remote_mac, ETH_ALEN);
 
 	skb->dev = np->dev;
 
@@ -431,7 +431,7 @@ static void arp_reply(struct sk_buff *sk
 
 	/* Fill the device header for the ARP frame */
 	if (dev_hard_header(send_skb, skb->dev, ptype,
-			    sha, np->local_mac,
+			    sha, np->dev->dev_addr,
 			    send_skb->len) < 0) {
 		kfree_skb(send_skb);
 		return;
@@ -737,9 +737,6 @@ int netpoll_setup(struct netpoll *np)
 		}
 	}
 
-	if (is_zero_ether_addr(np->local_mac) && ndev->dev_addr)
-		memcpy(np->local_mac, ndev->dev_addr, 6);
-
 	if (!np->local_ip) {
 		rcu_read_lock();
 		in_dev = __in_dev_get_rcu(ndev);
--- a/drivers/net/netconsole.c	2007-10-17 15:25:31.000000000 -0700
+++ b/drivers/net/netconsole.c	2007-11-03 09:26:27.000000000 -0700
@@ -306,9 +306,11 @@ static ssize_t show_remote_ip(struct net
 
 static ssize_t show_local_mac(struct netconsole_target *nt, char *buf)
 {
+	struct net_device *dev = nt->np.dev;
+
 	DECLARE_MAC_BUF(mac);
 	return snprintf(buf, PAGE_SIZE, "%s\n",
-			print_mac(mac, nt->np.local_mac));
+			print_mac(mac, dev->dev_addr));
 }
 
 static ssize_t show_remote_mac(struct netconsole_target *nt, char *buf)
@@ -667,7 +669,7 @@ static int netconsole_netdev_event(struc
 	struct netconsole_target *nt;
 	struct net_device *dev = ptr;
 
-	if (!(event == NETDEV_CHANGEADDR || event == NETDEV_CHANGENAME))
+	if (!(event == NETDEV_CHANGENAME))
 		goto done;
 
 	spin_lock_irqsave(&target_list_lock, flags);
@@ -675,10 +677,6 @@ static int netconsole_netdev_event(struc
 		netconsole_target_get(nt);
 		if (nt->np.dev == dev) {
 			switch (event) {
-			case NETDEV_CHANGEADDR:
-				memcpy(nt->np.local_mac, dev->dev_addr, ETH_ALEN);
-				break;
-
 			case NETDEV_CHANGENAME:
 				strlcpy(nt->np.dev_name, dev->name, IFNAMSIZ);
 				break;

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

