From: James Morris <jmorris@redhat.com>
Subject: [PATCH] Fix checksum bug for multicast/broadcast packets on postrouting
 hook
Date: Sat, 14 Feb 2004 13:37:23 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0402141318490.6128-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Stephen Smalley <sds@epoch.ncsc.mil>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Harald Welte <laforge@netfilter.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch fixes a bug with with multicast/broadcast packets,
Netfilter, and NICs which do hardware checksums.

Outgoing multicast and broadcast packets are cloned prior to being fed
into the postrouting hook and looped back.  A problem is caused when the
shared packet data is modified by the netfilter core code when updating
the checksum, but the skb->ip_summed field in the header of the original
skb is not updated.  The NIC then tries to do a hardware checksum on an
already correct checksum, and we end up transmitting the wrong thing.

This bug stops things like DHCP from working, and was noted under SELinux
which uses the postrouting hook alone.

The proposed solution below is to copy the skb rather than clone it, to 
ensure that the original and looped back packets are independent.

Please review.

(A similar problem seems to exist in the IPv6 code, although not 
verified yet).


- James
-- 
James Morris
<jmorris@redhat.com>


diff -urN -X dontdiff linux-2.6.3-rc2-mm1.o/net/ipv4/ip_output.c linux-2.6.3-rc2-mm1.w2/net/ipv4/ip_output.c
--- linux-2.6.3-rc2-mm1.o/net/ipv4/ip_output.c	2004-02-03 22:45:00.000000000 -0500
+++ linux-2.6.3-rc2-mm1.w2/net/ipv4/ip_output.c	2004-02-14 13:04:20.880941816 -0500
@@ -254,7 +254,7 @@
 		    && ((rt->rt_flags&RTCF_LOCAL) || !(IPCB(skb)->flags&IPSKB_FORWARDED))
 #endif
 		) {
-			struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
+			struct sk_buff *newskb = skb_copy(skb, GFP_ATOMIC);
 			if (newskb)
 				NF_HOOK(PF_INET, NF_IP_POST_ROUTING, newskb, NULL,
 					newskb->dev, 
@@ -270,7 +270,7 @@
 	}
 
 	if (rt->rt_flags&RTCF_BROADCAST) {
-		struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
+		struct sk_buff *newskb = skb_copy(skb, GFP_ATOMIC);
 		if (newskb)
 			NF_HOOK(PF_INET, NF_IP_POST_ROUTING, newskb, NULL,
 				newskb->dev, ip_dev_loopback_xmit);
