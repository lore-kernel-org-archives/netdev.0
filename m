From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 1/3] vxlan: fix populating tclass in vxlan6_get_route
Date: Fri, 18 Mar 2016 18:37:57 +0100
Message-ID: <1abd39f0386cae939dc3377af46e9b074888f44b.1458320940.git.daniel@iogearbox.net>
References: <cover.1458320940.git.daniel@iogearbox.net>
Cc: jbenc@redhat.com, linville@tuxdriver.com, jesse@kernel.org,
	dsa@cumulusnetworks.com, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53381 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757537AbcCRRiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 13:38:18 -0400
In-Reply-To: <cover.1458320940.git.daniel@iogearbox.net>
In-Reply-To: <cover.1458320940.git.daniel@iogearbox.net>
References: <cover.1458320940.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri mentioned that flowi6_tos of struct flowi6 is never used/read
anywhere. In fact, rest of the kernel uses the flowi6's flowlabel,
where the traffic class _and_ the flowlabel (aka flowinfo) is encoded.

For example, for policy routing, fib6_rule_match() uses ip6_tclass()
that is applied on the flowlabel member for matching on tclass. Similar
fix is needed for geneve, where flowi6_tos is set as well. Installing
a v6 blackhole rule that f.e. matches on tos is now working with vxlan.

Fixes: 1400615d64cf ("vxlan: allow setting ipv6 traffic class")
Reported-by: Jiri Benc <jbenc@redhat.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/vxlan.c | 3 +--
 include/net/ipv6.h  | 6 ++++++
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 800106a7..7bfcb9a62a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1810,10 +1810,9 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_oif = oif;
-	fl6.flowi6_tos = RT_TOS(tos);
 	fl6.daddr = *daddr;
 	fl6.saddr = vxlan->cfg.saddr.sin6.sin6_addr;
-	fl6.flowlabel = label;
+	fl6.flowlabel = ip6_make_flowinfo(RT_TOS(tos), label);
 	fl6.flowi6_mark = skb->mark;
 	fl6.flowi6_proto = IPPROTO_UDP;
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index f3c9857..d0aeb97 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -835,6 +835,12 @@ static inline u8 ip6_tclass(__be32 flowinfo)
 {
 	return ntohl(flowinfo & IPV6_TCLASS_MASK) >> IPV6_TCLASS_SHIFT;
 }
+
+static inline __be32 ip6_make_flowinfo(unsigned int tclass, __be32 flowlabel)
+{
+	return htonl(tclass << IPV6_TCLASS_SHIFT) | flowlabel;
+}
+
 /*
  *	Prototypes exported by ipv6
  */
-- 
1.9.3
