From: Tom Lendacky <toml@us.ibm.com>
Subject: [PATCH] IPSec: IPv6 UDP policy checking
Date: 24 Mar 2003 16:31:29 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1048545094.1530.25.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, toml@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


After getting racoon to be able to listen on an IPv6 address, it wasn't
receiving any of the IKE messages being sent to it.  The following
patch fixes the problem and is consistent with when and how the IPv4
UDP code invokes xfrm_policy_check.

Please review to be sure this is acceptable.

Thanks,
Tom

--- linux-2.5.65-orig/net/ipv6/udp.c	2003-03-17 15:44:41.000000000 -0600
+++ linux-2.5.65/net/ipv6/udp.c	2003-03-24 16:28:02.000000000 -0600
@@ -652,9 +652,6 @@
 	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
 		goto short_packet;
 
-	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
-                goto discard;
-
 	saddr = &skb->nh.ipv6h->saddr;
 	daddr = &skb->nh.ipv6h->daddr;
 	uh = skb->h.uh;
@@ -712,6 +709,9 @@
 	sk = udp_v6_lookup(saddr, uh->source, daddr, uh->dest, dev->ifindex);
 
 	if (sk == NULL) {
+		if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
+			goto discard;
+
 		if (skb->ip_summed != CHECKSUM_UNNECESSARY &&
 		    (unsigned short)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum)))
 			goto discard;
