From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [RFC PATCH 2/3] netpoll: store local and remote ip in net-endian
Date: Sat, 28 Mar 2009 18:38:31 -0700
Message-ID: <1238290711.3492.9.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:38495 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751668AbZC2Bip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 21:38:45 -0400
Received: by wf-out-1314.google.com with SMTP id 29so1991043wff.4
        for <netdev@vger.kernel.org>; Sat, 28 Mar 2009 18:38:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allows for the removal of byteswapping in some places and
the removal of HIPQUAD (replaced by %pI4).

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Feel free to delay this for 2.6.31 as I missed the merge window.

 drivers/net/netconsole.c |   10 ++++------
 include/linux/netpoll.h  |    2 +-
 net/core/netpoll.c       |   31 +++++++++++++++----------------
 3 files changed, 20 insertions(+), 23 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index d304d38..eceadf7 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -294,14 +294,12 @@ static ssize_t show_remote_port(struct netconsole_target *nt, char *buf)
 
 static ssize_t show_local_ip(struct netconsole_target *nt, char *buf)
 {
-	return snprintf(buf, PAGE_SIZE, "%d.%d.%d.%d\n",
-			HIPQUAD(nt->np.local_ip));
+	return snprintf(buf, PAGE_SIZE, "%pI4\n", &nt->np.local_ip);
 }
 
 static ssize_t show_remote_ip(struct netconsole_target *nt, char *buf)
 {
-	return snprintf(buf, PAGE_SIZE, "%d.%d.%d.%d\n",
-			HIPQUAD(nt->np.remote_ip));
+	return snprintf(buf, PAGE_SIZE, "%pI4\n", &nt->np.remote_ip);
 }
 
 static ssize_t show_local_mac(struct netconsole_target *nt, char *buf)
@@ -438,7 +436,7 @@ static ssize_t store_local_ip(struct netconsole_target *nt,
 		return -EINVAL;
 	}
 
-	nt->np.local_ip = ntohl(in_aton(buf));
+	nt->np.local_ip = in_aton(buf);
 
 	return strnlen(buf, count);
 }
@@ -454,7 +452,7 @@ static ssize_t store_remote_ip(struct netconsole_target *nt,
 		return -EINVAL;
 	}
 
-	nt->np.remote_ip = ntohl(in_aton(buf));
+	nt->np.remote_ip = in_aton(buf);
 
 	return strnlen(buf, count);
 }
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index de99025..2524267 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -18,7 +18,7 @@ struct netpoll {
 	const char *name;
 	void (*rx_hook)(struct netpoll *, int, char *, int);
 
-	u32 local_ip, remote_ip;
+	__be32 local_ip, remote_ip;
 	u16 local_port, remote_port;
 	u8 remote_mac[ETH_ALEN];
 };
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 755414c..b5873bd 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -345,8 +345,8 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 	udph->dest = htons(np->remote_port);
 	udph->len = htons(udp_len);
 	udph->check = 0;
-	udph->check = csum_tcpudp_magic(htonl(np->local_ip),
-					htonl(np->remote_ip),
+	udph->check = csum_tcpudp_magic(np->local_ip,
+					np->remote_ip,
 					udp_len, IPPROTO_UDP,
 					csum_partial(udph, udp_len, 0));
 	if (udph->check == 0)
@@ -365,8 +365,8 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 	iph->ttl      = 64;
 	iph->protocol = IPPROTO_UDP;
 	iph->check    = 0;
-	put_unaligned(htonl(np->local_ip), &(iph->saddr));
-	put_unaligned(htonl(np->remote_ip), &(iph->daddr));
+	put_unaligned(np->local_ip, &(iph->saddr));
+	put_unaligned(np->remote_ip, &(iph->daddr));
 	iph->check    = ip_fast_csum((unsigned char *)iph, iph->ihl);
 
 	eth = (struct ethhdr *) skb_push(skb, ETH_HLEN);
@@ -424,7 +424,7 @@ static void arp_reply(struct sk_buff *skb)
 	memcpy(&tip, arp_ptr, 4);
 
 	/* Should we ignore arp? */
-	if (tip != htonl(np->local_ip) ||
+	if (tip != np->local_ip ||
 	    ipv4_is_loopback(tip) || ipv4_is_multicast(tip))
 		return;
 
@@ -533,9 +533,9 @@ int __netpoll_rx(struct sk_buff *skb)
 		goto out;
 	if (checksum_udp(skb, uh, ulen, iph->saddr, iph->daddr))
 		goto out;
-	if (np->local_ip && np->local_ip != ntohl(iph->daddr))
+	if (np->local_ip && np->local_ip != iph->daddr)
 		goto out;
-	if (np->remote_ip && np->remote_ip != ntohl(iph->saddr))
+	if (np->remote_ip && np->remote_ip != iph->saddr)
 		goto out;
 	if (np->local_port && np->local_port != ntohs(uh->dest))
 		goto out;
@@ -560,14 +560,14 @@ void netpoll_print_options(struct netpoll *np)
 {
 	printk(KERN_INFO "%s: local port %d\n",
 			 np->name, np->local_port);
-	printk(KERN_INFO "%s: local IP %d.%d.%d.%d\n",
-			 np->name, HIPQUAD(np->local_ip));
+	printk(KERN_INFO "%s: local IP %pI4\n",
+			 np->name, &np->local_ip);
 	printk(KERN_INFO "%s: interface %s\n",
 			 np->name, np->dev_name);
 	printk(KERN_INFO "%s: remote port %d\n",
 			 np->name, np->remote_port);
-	printk(KERN_INFO "%s: remote IP %d.%d.%d.%d\n",
-			 np->name, HIPQUAD(np->remote_ip));
+	printk(KERN_INFO "%s: remote IP %pI4\n",
+			 np->name, &np->remote_ip);
 	printk(KERN_INFO "%s: remote ethernet address %pM\n",
 	                 np->name, np->remote_mac);
 }
@@ -589,7 +589,7 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 		if ((delim = strchr(cur, '/')) == NULL)
 			goto parse_failed;
 		*delim = 0;
-		np->local_ip = ntohl(in_aton(cur));
+		np->local_ip = in_aton(cur);
 		cur = delim;
 	}
 	cur++;
@@ -618,7 +618,7 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 	if ((delim = strchr(cur, '/')) == NULL)
 		goto parse_failed;
 	*delim = 0;
-	np->remote_ip = ntohl(in_aton(cur));
+	np->remote_ip = in_aton(cur);
 	cur = delim + 1;
 
 	if (*cur != 0) {
@@ -759,10 +759,9 @@ int netpoll_setup(struct netpoll *np)
 			goto release;
 		}
 
-		np->local_ip = ntohl(in_dev->ifa_list->ifa_local);
+		np->local_ip = in_dev->ifa_list->ifa_local;
 		rcu_read_unlock();
-		printk(KERN_INFO "%s: local IP %d.%d.%d.%d\n",
-		       np->name, HIPQUAD(np->local_ip));
+		printk(KERN_INFO "%s: local IP %pI4\n", np->name, &np->local_ip);
 	}
 
 	if (np->rx_hook) {
-- 
1.6.2.1.507.g0e68d


