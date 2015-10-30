From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/5] xfrm: Let the flowcache handle its size by default.
Date: Fri, 30 Oct 2015 07:16:26 +0100
Message-ID: <1446185790-24214-2-git-send-email-steffen.klassert@secunet.com>
References: <1446185790-24214-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39772 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758134AbbJ3GQl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2015 02:16:41 -0400
In-Reply-To: <1446185790-24214-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The xfrm flowcache size is limited by the flowcache limit
(4096 * number of online cpus) and the xfrm garbage collector
threshold (2 * 32768), whatever is reached first. This means
that we can hit the garbage collector limit only on systems
with more than 16 cpus. On such systems we simply refuse
new allocations if we reach the limit, so new flows are dropped.
On syslems with 16 or less cpus, we hit the flowcache limit.
In this case, we shrink the flow cache instead of refusing new
flows.

We increase the xfrm garbage collector threshold to INT_MAX
to get the same behaviour, independent of the number of cpus.

The xfrm garbage collector threshold can still be set below
the flowcache limit to reduce the memory usage of the flowcache.

Tested-by: Dan Streetman <dan.streetman@canonical.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 Documentation/networking/ip-sysctl.txt | 6 ++++--
 net/ipv4/xfrm4_policy.c                | 2 +-
 net/ipv6/xfrm6_policy.c                | 2 +-
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ebe94f2..260f30b 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1199,7 +1199,8 @@ tag - INTEGER
 xfrm4_gc_thresh - INTEGER
 	The threshold at which we will start garbage collecting for IPv4
 	destination cache entries.  At twice this value the system will
-	refuse new allocations.
+	refuse new allocations. The value must be set below the flowcache
+	limit (4096 * number of online cpus) to take effect.
 
 igmp_link_local_mcast_reports - BOOLEAN
 	Enable IGMP reports for link local multicast groups in the
@@ -1645,7 +1646,8 @@ ratelimit - INTEGER
 xfrm6_gc_thresh - INTEGER
 	The threshold at which we will start garbage collecting for IPv6
 	destination cache entries.  At twice this value the system will
-	refuse new allocations.
+	refuse new allocations. The value must be set below the flowcache
+	limit (4096 * number of online cpus) to take effect.
 
 
 IPv6 Update by:
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 0304d16..75e8d48 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -246,7 +246,7 @@ static struct dst_ops xfrm4_dst_ops = {
 	.destroy =		xfrm4_dst_destroy,
 	.ifdown =		xfrm4_dst_ifdown,
 	.local_out =		__ip_local_out,
-	.gc_thresh =		32768,
+	.gc_thresh =		INT_MAX,
 };
 
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 30caa28..2fad593 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -287,7 +287,7 @@ static struct dst_ops xfrm6_dst_ops = {
 	.destroy =		xfrm6_dst_destroy,
 	.ifdown =		xfrm6_dst_ifdown,
 	.local_out =		__ip6_local_out,
-	.gc_thresh =		32768,
+	.gc_thresh =		INT_MAX,
 };
 
 static struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
-- 
1.9.1
