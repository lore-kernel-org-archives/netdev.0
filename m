From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 05/31] [SK_BUFF] ipv6: Use skb_network_offset in some more places
Date: Tue, 20 Mar 2007 19:54:39 -0300
Message-ID: <20070320225439.GR17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:25953 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbXCTWyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 18:54:44 -0400
Received: by wx-out-0506.google.com with SMTP id h31so60697wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 15:54:43 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

So that we reduce the number of direct accesses to skb->data.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/ipv6/netfilter/ip6_tables.c         |    2 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c |    5 +++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index caf9e37..b97aedc 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1448,7 +1448,7 @@ static void __exit ip6_tables_fini(void)
 int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 		  int target, unsigned short *fragoff)
 {
-	unsigned int start = (u8 *)(ipv6_hdr(skb) + 1) - skb->data;
+	unsigned int start = skb_network_offset(skb) + sizeof(struct ipv6hdr);
 	u8 nexthdr = ipv6_hdr(skb)->nexthdr;
 	unsigned int len = skb->len - start;
 
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index b7889ce..721f02d 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -707,8 +707,9 @@ static int
 find_prev_fhdr(struct sk_buff *skb, u8 *prevhdrp, int *prevhoff, int *fhoff)
 {
 	u8 nexthdr = ipv6_hdr(skb)->nexthdr;
-	u8 prev_nhoff = (u8 *)&ipv6_hdr(skb)->nexthdr - skb->data;
-	int start = (u8 *)(ipv6_hdr(skb) + 1) - skb->data;
+	const int netoff = skb_network_offset(skb);
+	u8 prev_nhoff = netoff + offsetof(struct ipv6hdr, nexthdr);
+	int start = netoff + sizeof(struct ipv6hdr);
 	int len = skb->len - start;
 	u8 prevhdr = NEXTHDR_IPV6;
 
-- 
1.5.0.3

