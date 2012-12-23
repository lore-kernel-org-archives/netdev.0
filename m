From: Philippe De Muyter <phdm@macqel.be>
Subject: [PATCH] ipconfig: Fix displaying of the address of the BOOTP/DHCP server.
Date: Sun, 23 Dec 2012 14:13:38 +0100
Message-ID: <1356268418-7376-1-git-send-email-phdm@macqel.be>
Cc: Philippe De Muyter <phdm@macqel.be>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.macqel.be ([194.78.208.39]:16714 "EHLO smtp2.macqel.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750947Ab2LWNXd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Dec 2012 08:23:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Up to now, the debug or info messages from the ipconfig subsytem
displayed the IP address of the bootserver instead of the address
of the address server.  Fix that.

Signed-off-by: Philippe De Muyter <phdm@macqel.be>
---
 net/ipv4/ipconfig.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 798358b..57e8151 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -136,6 +136,8 @@ __be32 ic_myaddr = NONE;		/* My IP address */
 static __be32 ic_netmask = NONE;	/* Netmask for local subnet */
 __be32 ic_gateway = NONE;	/* Gateway IP address */
 
+__be32 ic_addrservaddr = NONE;	/* IP Address of the IP addresses'server */
+
 __be32 ic_servaddr = NONE;	/* Boot server IP address */
 
 __be32 root_server_addr = NONE;	/* Address of NFS server */
@@ -558,6 +560,7 @@ ic_rarp_recv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	if (ic_myaddr == NONE)
 		ic_myaddr = tip;
 	ic_servaddr = sip;
+	ic_addrservaddr = sip;
 	ic_got_reply = IC_RARP;
 
 drop_unlock:
@@ -1068,7 +1071,7 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 				ic_servaddr = server_id;
 #ifdef IPCONFIG_DEBUG
 				printk("DHCP: Offered address %pI4 by server %pI4\n",
-				       &ic_myaddr, &ic_servaddr);
+				       &ic_myaddr, &b->iph.saddr);
 #endif
 				/* The DHCP indicated server address takes
 				 * precedence over the bootp header one if
@@ -1113,6 +1116,7 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 	ic_dev = dev;
 	ic_myaddr = b->your_ip;
 	ic_servaddr = b->server_ip;
+	ic_addrservaddr = b->iph.saddr;
 	if (ic_gateway == NONE && b->relay_ip)
 		ic_gateway = b->relay_ip;
 	if (ic_nameservers[0] == NONE)
@@ -1268,7 +1272,7 @@ static int __init ic_dynamic(void)
 	printk("IP-Config: Got %s answer from %pI4, ",
 		((ic_got_reply & IC_RARP) ? "RARP"
 		 : (ic_proto_enabled & IC_USE_DHCP) ? "DHCP" : "BOOTP"),
-	       &ic_servaddr);
+	       &ic_addrservaddr);
 	pr_cont("my address is %pI4\n", &ic_myaddr);
 
 	return 0;
-- 
1.7.1
