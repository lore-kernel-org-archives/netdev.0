From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/2] net: original ingress device index in PKTINFO
Date: Fri,  6 May 2016 18:49:41 -0700
Message-ID: <1462585781-9146-3-git-send-email-dsa@cumulusnetworks.com>
References: <1462585781-9146-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34583 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759103AbcEGBty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 21:49:54 -0400
Received: by mail-pf0-f175.google.com with SMTP id y69so54870016pfb.1
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 18:49:53 -0700 (PDT)
In-Reply-To: <1462585781-9146-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applications such as OSPF and BFD need the original ingress device not
the VRF device; the latter can be derived from the former. To that end
add the skb_iif to inet_skb_parm and set it in ipv4 code after clearing
the skb control buffer similar to IPv6. From there the pktinfo can just
pull it from cb with the PKTINFO_SKB_CB cast.

The previous patch moving the skb->dev change to L3 means nothing else
is needed for IPv6; it just works.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/ip.h       | 1 +
 net/ipv4/ip_input.c    | 1 +
 net/ipv4/ip_sockglue.c | 7 ++++++-
 3 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 247ac82e9cf2..37165fba3741 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -36,6 +36,7 @@
 struct sock;
 
 struct inet_skb_parm {
+	int			iif;
 	struct ip_options	opt;		/* Compiled IP options		*/
 	unsigned char		flags;
 
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 37375eedeef9..4b351af3e67b 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -478,6 +478,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 
 	/* Remove any debris in the socket control block */
 	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+	IPCB(skb)->iif = skb->skb_iif;
 
 	/* Must drop socket now because of tproxy. */
 	skb_orphan(skb);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index bdb222c0c6a2..5805762d7fc7 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1193,7 +1193,12 @@ void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb)
 		       ipv6_sk_rxinfo(sk);
 
 	if (prepare && skb_rtable(skb)) {
-		pktinfo->ipi_ifindex = inet_iif(skb);
+		/* skb->cb is overloaded: prior to this point it is IP{6}CB
+		 * which has interface index (iif) as the first member of the
+		 * underlying inet{6}_skb_parm struct. This code then overlays
+		 * PKTINFO_SKB_CB and in_pktinfo also has iif as the first
+		 * element so the iif is picked up from the prior IPCB
+		 */
 		pktinfo->ipi_spec_dst.s_addr = fib_compute_spec_dst(skb);
 	} else {
 		pktinfo->ipi_ifindex = 0;
-- 
2.1.4
