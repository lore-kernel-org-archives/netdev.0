From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH 3/3] IPV6: use cheaper ipv6_addr_any() where appropriate
Date: Fri, 06 Feb 2004 18:10:14 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040206.181014.40584753.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

[PATCH 3/3] IPV6: use cheaper ipv6_addr_any() where appropriate

D: Use cheaper ipv6_addr_any() where appropriate.

Thanks.

--- linux26-recv_ns/net/ipv6/ndisc.c	Fri Feb  6 16:38:44 2004
+++ linux26-ipv6_addr_any/net/ipv6/ndisc.c	Fri Feb  6 16:58:37 2004
@@ -709,7 +709,7 @@ static void ndisc_recv_ns(struct sk_buff
 	struct inet6_ifaddr *ifp;
 	struct inet6_dev *idev = NULL;
 	struct neighbour *neigh;
-	int addr_type = ipv6_addr_type(saddr);
+	int dad = ipv6_addr_any(saddr);
 	int inc;
 
 	if (ipv6_addr_is_multicast(&msg->target)) {
@@ -722,7 +722,7 @@ static void ndisc_recv_ns(struct sk_buff
 	 * RFC2461 7.1.1:
 	 * DAD has to be destined for solicited node multicast address.
 	 */
-	if (addr_type == IPV6_ADDR_ANY &&
+	if (dad &&
 	    !(daddr->s6_addr32[0] == htonl(0xff020000) &&
 	      daddr->s6_addr32[1] == htonl(0x00000000) &&
 	      daddr->s6_addr32[2] == htonl(0x00000001) &&
@@ -752,7 +752,7 @@ static void ndisc_recv_ns(struct sk_buff
 		 *	there MUST NOT be source link-layer address option 
 		 *	in the message.
 		 */
-		if (addr_type == IPV6_ADDR_ANY) {
+		if (dad) {
 			if (net_ratelimit())
 				printk(KERN_WARNING "ICMP6 NS: bad DAD packet (link-layer address option)\n");
 			return;
@@ -768,10 +768,8 @@ static void ndisc_recv_ns(struct sk_buff
 			   does DAD, otherwise we ignore solicitations
 			   until DAD timer expires.
 			 */
-			if (addr_type != IPV6_ADDR_ANY) {
-				in6_ifa_put(ifp);
-				return;
-			}
+			if (!dad)
+				goto out;
 			if (dev->type == ARPHRD_IEEE802_TR) {
 				unsigned char *sadr = skb->mac.raw;
 				if (((sadr[8] ^ dev->dev_addr[0]) & 0x7f) == 0 &&
@@ -781,8 +779,7 @@ static void ndisc_recv_ns(struct sk_buff
 				    sadr[12] == dev->dev_addr[4] &&
 				    sadr[13] == dev->dev_addr[5]) {
 					/* looped-back to us */
-					in6_ifa_put(ifp);
-					return;
+					goto out;
 				}
 			}
 			addrconf_dad_failure(ifp); 
@@ -820,7 +817,7 @@ static void ndisc_recv_ns(struct sk_buff
 			goto out;
 	}
 
-	if (addr_type == IPV6_ADDR_ANY) {
+	if (dad) {
 		struct in6_addr maddr;
 
 		ipv6_addr_all_nodes(&maddr);


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
