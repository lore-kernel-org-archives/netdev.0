From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: DAD must not have source link-layer option
Date: Thu, 26 Jun 2003 04:35:20 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030626.043520.18011582.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Check if DAD does not have source link-layer address option;
RFC2461 7.1.1.

Patch depends on "[PATCH] IPV6: DAD has to be destined to 
solicited node mulitcast address" patch.

Thanks.

--- linux25+patch/net/ipv6/ndisc.c.orig	Thu Jun 26 04:07:15 2003
+++ linux25+patch/net/ipv6/ndisc.c	Thu Jun 26 04:27:50 2003
@@ -749,15 +749,19 @@ void ndisc_recv_ns(struct sk_buff *skb)
 				printk(KERN_WARNING "ICMP NS: bad lladdr length.\n");
 			return;
 		}
+
+		/* XXX: RFC2461 7.1.1:
+	 	 *	If the IP source address is the unspecified address, 
+		 *	there MUST NOT be source link-layer address option 
+		 *	in the message.
+		 */
+		if (addr_type == IPV6_ADDR_ANY) {
+			if (net_ratelimit())
+				printk(KERN_WARNING "ICMP6 NS: bad DAD packet (link-layer address option)\n");
+			return;
+		}
 	}
 
-	/* XXX: RFC2461 7.1.1:
-	 * 	If the IP source address is the unspecified address, there
-	 *	MUST NOT be source link-layer address option in the message.
-	 *
-	 *	NOTE! Linux kernel < 2.4.4 broke this rule.
-	 */
-		 	
 	if ((ifp = ipv6_get_ifaddr(&msg->target, dev)) != NULL) {
 		if (ifp->flags & IFA_F_TENTATIVE) {
 			/* Address is tentative. If the source

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
