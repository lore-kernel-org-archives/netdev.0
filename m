From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH 4/4] Add loopback address type inline
Date: Thu, 05 Apr 2007 23:21:33 -0400
Message-ID: <4615BCBD.2030607@hp.com>
References: <11758281863002-git-send-email-brian.haley@hp.com> <117582818660-git-send-email-brian.haley@hp.com> <11758281864173-git-send-email-brian.haley@hp.com> <11758281872074-git-send-email-brian.haley@hp.com>,	<151538c13022864224f5ff440e1147f884abb492.1175794415.git.brian.haley@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:34154 "EHLO mailhub.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767296AbXDFDmU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 23:42:20 -0400
In-Reply-To: <151538c13022864224f5ff440e1147f884abb492.1175794415.git.brian.haley@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add loopback address type inline to avoid calls to ipv6_addr_type().

Signed-off-by: Brian Haley <brian.haley@hp.com>
---
  include/net/ipv6.h    |    7 +++++++
  net/ipv6/ip6_output.c |    5 +++--
  net/ipv6/route.c      |    8 +++-----
  3 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index f3e13db..d87f421 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -388,6 +388,13 @@ static inline int ipv6_addr_any(const struct in6_addr *a)
  		 a->s6_addr32[2] | a->s6_addr32[3] ) == 0);
  }

+static inline int ipv6_addr_loopback(const struct in6_addr *a)
+{
+	return ((a->s6_addr32[0] | a->s6_addr32[1] |
+		 a->s6_addr32[2] ) == 0 &&
+		 a->s6_addr32[3] == htonl(0x00000001));
+}
+
  /*
   * find the first different bit between two addresses
   * length of address must be a multiple of 32bits
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index f6aa338..7f1aabe 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -455,8 +455,9 @@ int ip6_forward(struct sk_buff *skb)
  		 */
  		if (xrlim_allow(dst, 1*HZ))
  			ndisc_send_redirect(skb, n, target);
-	} else if (ipv6_addr_type(&hdr->saddr)&(IPV6_ADDR_MULTICAST|IPV6_ADDR_LOOPBACK
-						|IPV6_ADDR_LINKLOCAL)) {
+	} else if (ipv6_addr_type_multicast(&hdr->saddr) ||
+		   ipv6_addr_loopback(&hdr->saddr) ||
+		   ipv6_addr_scope_linklocal(&hdr->saddr)) {
  		/* This check is security critical. */
  		goto error;
  	}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 32c6398..06ee92d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1067,7 +1067,6 @@ int ip6_route_add(struct fib6_config *cfg)
  	struct net_device *dev = NULL;
  	struct inet6_dev *idev = NULL;
  	struct fib6_table *table;
-	int addr_type;

  	if (cfg->fc_dst_len > 128 || cfg->fc_src_len > 128)
  		return -EINVAL;
@@ -1108,9 +1107,7 @@ int ip6_route_add(struct fib6_config *cfg)
  		cfg->fc_protocol = RTPROT_BOOT;
  	rt->rt6i_protocol = cfg->fc_protocol;

-	addr_type = ipv6_addr_type(&cfg->fc_dst);
-
-	if (addr_type & IPV6_ADDR_MULTICAST)
+	if (ipv6_addr_type_multicast(&cfg->fc_dst))
  		rt->u.dst.input = ip6_mc_input;
  	else
  		rt->u.dst.input = ip6_forward;
@@ -1133,7 +1130,8 @@ int ip6_route_add(struct fib6_config *cfg)
  	   they would result in kernel looping; promote them to reject routes
  	 */
  	if ((cfg->fc_flags & RTF_REJECT) ||
-	    (dev && (dev->flags&IFF_LOOPBACK) && !(addr_type&IPV6_ADDR_LOOPBACK))) {
+	    (dev && (dev->flags&IFF_LOOPBACK) &&
+	     !ipv6_addr_loopback(&cfg->fc_dst))) {
  		/* hold loopback dev/idev if we haven't done so. */
  		if (dev != &loopback_dev) {
  			if (dev) {
-- 
1.5.0.3

