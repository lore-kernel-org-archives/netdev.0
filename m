From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH 1/3] IPV6: clean-up DAD vs tentative address
Date: Fri, 06 Feb 2004 18:10:03 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040206.181003.68972716.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

[PATCH 1/3] IPV6: clean-up DAD vs tentative address

D: clean-up NS (including DAD) vs tentative address

Thanks.

===== net/ipv6/ndisc.c 1.67 vs edited =====
--- 1.67/net/ipv6/ndisc.c	Wed Feb  4 02:13:51 2004
+++ edited/net/ipv6/ndisc.c	Fri Feb  6 15:10:20 2004
@@ -764,23 +764,24 @@
 			   does DAD, otherwise we ignore solicitations
 			   until DAD timer expires.
 			 */
-			if (addr_type == IPV6_ADDR_ANY) {
-				if (dev->type == ARPHRD_IEEE802_TR) { 
-					unsigned char *sadr = skb->mac.raw ;
-					if (((sadr[8] &0x7f) != (dev->dev_addr[0] & 0x7f)) ||
-					(sadr[9] != dev->dev_addr[1]) ||
-					(sadr[10] != dev->dev_addr[2]) ||
-					(sadr[11] != dev->dev_addr[3]) ||
-					(sadr[12] != dev->dev_addr[4]) ||
-					(sadr[13] != dev->dev_addr[5])) 
-					{
-						addrconf_dad_failure(ifp) ; 
-					}
-				} else {
-					addrconf_dad_failure(ifp);
-				}
-			} else
+			if (addr_type != IPV6_ADDR_ANY) {
 				in6_ifa_put(ifp);
+				return;
+			}
+			if (dev->type == ARPHRD_IEEE802_TR) {
+				unsigned char *sadr = skb->mac.raw;
+				if (((sadr[8] ^ dev->dev_addr[0]) & 0x7f) == 0 &&
+				    sadr[9] == dev->dev_addr[1] &&
+				    sadr[10] == dev->dev_addr[2] &&
+				    sadr[11] == dev->dev_addr[3] &&
+				    sadr[12] == dev->dev_addr[4] &&
+				    sadr[13] == dev->dev_addr[5]) {
+					/* looped-back to us */
+					in6_ifa_put(ifp);
+					return;
+				}
+			}
+			addrconf_dad_failure(ifp); 
 			return;
 		}
 	

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
