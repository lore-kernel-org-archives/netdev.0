From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPv6: Source Address of MLD Message
Date: Fri, 18 Oct 2002 12:52:15 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021018.125215.922751890.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

draft-ietf-magma-mld-source-02.txt clarifies that the source address of
MLD Report / Done Message MUST be unspecified address when a link-local
address is not available.  This patch follows this clarification.

This patch is against 2.4.20-pre10.

Thanks in advance.

-------------------------------------------------------------------
Patch-Name: Source Address of MLD Message
Patch-Id: FIX_2_4_20_pre10_MLD_SADDR-20021017
Patch-Author: YOSHIFUJI Hideaki / USAGI Project <yoshfuji@linux-ipv6.org>
Credit: YOSHIFUJI Hideaki / USAGI Project <yoshfuji@linux-ipv6.org>
Reference: draft-ietf-magma-mld-source-02.txt
-------------------------------------------------------------------
Index: net/ipv6/mcast.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux24/net/ipv6/mcast.c,v
retrieving revision 1.1.1.1
retrieving revision 1.1.1.1.30.2
diff -u -r1.1.1.1 -r1.1.1.1.30.2
--- net/ipv6/mcast.c	2002/08/20 09:47:02	1.1.1.1
+++ net/ipv6/mcast.c	2002/10/17 17:33:19	1.1.1.1.30.2
@@ -18,6 +18,9 @@
 /* Changes:
  *
  *	yoshfuji	: fix format of router-alert option
+ *	YOSHIFUJI Hideaki @USAGI:
+ *		Fixed source address for MLD message based on
+ *		<draft-ietf-magma-mld-source-02.txt>.
  */
 
 #define __NO_VERSION__
@@ -451,6 +454,7 @@
 	struct in6_addr *addrp;
 	struct inet6_dev *idev;
 	struct icmp6hdr *hdr;
+	int addr_type;
 
 	/* Our own report looped back. Ignore it. */
 	if (skb->pkt_type == PACKET_LOOPBACK)
@@ -462,7 +466,9 @@
 	hdr = (struct icmp6hdr*) skb->h.raw;
 
 	/* Drop reports with not link local source */
-	if (!(ipv6_addr_type(&skb->nh.ipv6h->saddr)&IPV6_ADDR_LINKLOCAL))
+	addr_type = ipv6_addr_type(&skb->nh.ipv6h->saddr);
+	if (addr_type != IPV6_ADDR_ANY && 
+	    !(addr_type&IPV6_ADDR_LINKLOCAL))
 		return -EINVAL;
 
 	addrp = (struct in6_addr *) (hdr + 1);
@@ -529,11 +535,11 @@
 	}
 
 	if (ipv6_get_lladdr(dev, &addr_buf)) {
-#if MCAST_DEBUG >= 1
-		printk(KERN_DEBUG "igmp6: %s no linklocal address\n",
-		       dev->name);
-#endif
-		goto out;
+		/* <draft-ietf-magma-mld-source-02.txt>:
+		 * use unspecified address as the source address 
+		 * when a valid link-local address is not available.
+		 */
+		memset(&addr_buf, 0, sizeof(addr_buf));
 	}
 
 	ip6_nd_hdr(sk, skb, dev, &addr_buf, snd_addr, NEXTHDR_HOP, payload_len);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
