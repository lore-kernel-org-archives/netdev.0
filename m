From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Limit mtu to 65572 bytes
Date: Thu, 10 Apr 2014 20:20:27 -0700
Message-ID: <1397186427.16584.86.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5345A2B3.7040602@gmail.com>
		 <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com>
		 <20140409223546.GH27255@order.stressinduktion.org>
		 <1397090170.16584.21.camel@edumazet-glaptop2.roam.corp.google.com>
		 <20140410235459.GK27255@order.stressinduktion.org>
		 <1397176824.16584.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1397180530.16584.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <534753D4.6070600@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	Francois WELLENREITER <f.wellenreiter@gmail.com>,
	netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:45122 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbaDKDU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 23:20:28 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so4694704pdi.16
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2014 20:20:28 -0700 (PDT)
In-Reply-To: <534753D4.6070600@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Francois reported that setting big mtu on loopback device could prevent
tcp sessions making progress.

We do not support (yet ?) IPv6 Jumbograms and cook corrupted packets.

We must limit the IPv6 MTU to (65535 + 40) bytes in theory.

Tested:

ifconfig lo mtu 70000
netperf -H ::1

Before patch : Throughput :   0.05 Mbits

After patch : Throughput : 35484 Mbits

Reported-by: Francois WELLENREITER <f.wellenreiter@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
v2: set the max limit, not round-down it.

 include/net/ip6_route.h |    5 +++++
 net/ipv6/route.c        |    5 +++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 3c3bb184eb8f..6c4f5eac98e7 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -32,6 +32,11 @@ struct route_info {
 #define RT6_LOOKUP_F_SRCPREF_PUBLIC	0x00000010
 #define RT6_LOOKUP_F_SRCPREF_COA	0x00000020
 
+/* We do not (yet ?) support IPv6 jumbograms (RFC 2675)
+ * Unlike IPv4, hdr->seg_len doesn't include the IPv6 header
+ */
+#define IP6_MAX_MTU (0xFFFF + sizeof(struct ipv6hdr))
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
