From: sebek64@post.cz (Marcel Sebek)
Subject: ip6t_LOG doesn't log packets with HOPOPTS extheader correctly
Date: Fri, 21 May 2004 19:39:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040521173953.GA8425@penguin.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi.

I think there is a bug in ip6t_LOG. When packet contains IPPROTO_HOPOPTS
extended header, only 'PROTO=0' is printed out and iteration through the
headers stops. That's because return value from ip6_nexthdr indicating
no next header is the same as IPPROTO_HOPOPTS.

The following patch changes this value to IPPROTO_NONE.


--- ip6t_LOG.c.old	2004-05-21 18:31:12.000000000 +0200
+++ ip6t_LOG.c	2004-05-21 19:14:02.000000000 +0200
@@ -48,10 +48,10 @@
 
 /* takes in current header and pointer to the header */
 /* if another header exists, sets hdrptr to the next header
-   and returns the new header value, else returns 0 */
+   and returns the new header value, else returns IPPROTO_NONE */
 static u_int8_t ip6_nexthdr(u_int8_t currenthdr, u_int8_t **hdrptr)
 {
-	u_int8_t hdrlen, nexthdr = 0;
+	u_int8_t hdrlen, nexthdr = IPPROTO_NONE;
 
 	switch(currenthdr){
 		case IPPROTO_AH:
@@ -77,7 +77,6 @@
 			break;
 	}	
 	return nexthdr;
-
 }
 
 /* One level of recursion won't kill us */
@@ -101,7 +100,7 @@
 
 	fragment = 0;
 	hdrptr = (u_int8_t *)(ipv6h + 1);
-	while (currenthdr) {
+	while (currenthdr != IPPROTO_NONE) {
 		if ((currenthdr == IPPROTO_TCP) ||
 		    (currenthdr == IPPROTO_UDP) ||
 		    (currenthdr == IPPROTO_ICMPV6))
@@ -264,7 +263,11 @@
 		}
 		break;
 	}
-	/* Max length: 10 "PROTO 255 " */
+	/* Max length: 11 "PROTO=NONE " */
+	case IPPROTO_NONE:
+		printk("PROTO=NONE ");
+		break;
+	/* Max length: 10 "PROTO=255 " */
 	default:
 		printk("PROTO=%u ", currenthdr);
 	}


-- 
Marcel Sebek
jabber: sebek@jabber.cz                     ICQ: 279852819
linux user number: 307850                 GPG ID: 5F88735E
GPG FP: 0F01 BAB8 3148 94DB B95D  1FCA 8B63 CA06 5F88 735E
