From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: Limit mtu to 65572 bytes
Date: Thu, 10 Apr 2014 18:42:10 -0700
Message-ID: <1397180530.16584.69.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5345A2B3.7040602@gmail.com>
	 <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140409223546.GH27255@order.stressinduktion.org>
	 <1397090170.16584.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140410235459.GK27255@order.stressinduktion.org>
	 <1397176824.16584.52.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francois WELLENREITER <f.wellenreiter@gmail.com>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35942 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753874AbaDKBmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 21:42:12 -0400
Received: by mail-pd0-f180.google.com with SMTP id v10so4641726pde.11
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2014 18:42:12 -0700 (PDT)
In-Reply-To: <1397176824.16584.52.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Francois reported that setting big mtu on loopback device could prevent
tcp sessions making progress.

We do not support (yet ?) IPv6 Jumbograms and cook corrupted packets.

We must limit the IPv6 MTU to (65535 + 40) bytes in theory.

In practice, its better to align to a multiple of 4 for optimal TCP
performance.

Tested:

ifconfig lo mtu 70000
netperf -H ::1

Before patch :

-> Throughput :   0.05 Mbits

After patch :

-> Throughput : 36624.24 Mbits

Reported-by: Francois WELLENREITER <f.wellenreiter@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip6_route.h |    7 +++++++
 net/ipv6/route.c        |    5 +++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 3c3bb184eb8f..8510a0c14b1d 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -32,6 +32,13 @@ struct route_info {
 #define RT6_LOOKUP_F_SRCPREF_PUBLIC	0x00000010
 #define RT6_LOOKUP_F_SRCPREF_COA	0x00000020
 
+/* We do not (yet ?) support IPv6 jumbograms (RFC 2675)
+ * Unlike IPv4, hdr->seg_len doesn't include the IPv6 header
+ * In theory, limit is 0xFFFF + 40, but we round-down to a multiple
+ * of 4 for better TCP performance.
+ */
+#define IP6_MAX_MTU (0xFFFC + sizeof(struct ipv6hdr))
+
 /*
  * rt6_srcprefs2flags() and rt6_flags2srcprefs() translate
  * between IPV6_ADDR_PREFERENCES socket option values
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5015c50a5ba7..5ea462eacd9f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1338,7 +1338,7 @@ static unsigned int ip6_mtu(const struct dst_entry *dst)
 	unsigned int mtu = dst_metric_raw(dst, RTAX_MTU);
 
 	if (mtu)
-		return mtu;
+		goto out;
 
 	mtu = IPV6_MIN_MTU;
 
@@ -1348,7 +1348,8 @@ static unsigned int ip6_mtu(const struct dst_entry *dst)
 		mtu = idev->cnf.mtu6;
 	rcu_read_unlock();
 
-	return mtu;
+out:
+	return min_t(unsigned int, mtu, IP6_MAX_MTU);
 }
 
 static struct dst_entry *icmp6_dst_gc_list;
