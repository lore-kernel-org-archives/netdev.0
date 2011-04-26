From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 1/7] sctp: fix sctp to work with ipv6 source
 address routing
Date: Tue, 26 Apr 2011 11:45:26 +0800
Message-ID: <4DB63FD6.8010206@cn.fujitsu.com>
References: <4DB63F85.2090609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50984 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757979Ab1DZDpk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2011 23:45:40 -0400
In-Reply-To: <4DB63F85.2090609@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weixing Shi <Weixing.Shi@windriver.com>

in the below test case, using the source address routing,
sctp can not work.
Node-A
1)ifconfig eth0 inet6 add 2001:1::1/64
2)ip -6 rule add from 2001:1::1 table 100 pref 100
3)ip -6 route add 2001:2::1 dev eth0 table 100
4)sctp_darn -H 2001:1::1 -P 250 -l &
Node-B
1)ifconfig eth0 inet6 add 2001:2::1/64
2)ip -6 rule add from 2001:2::1 table 100 pref 100
3)ip -6 route add 2001:1::1 dev eth0 table 100
4)sctp_darn -H 2001:2::1 -P 250 -h 2001:1::1 -p 250 -s

root cause:
Node-A and Node-B use the source address routing, and
at begining, source address will be NULL,sctp will
search the  routing table by the destination address,
because using the source address routing table, and
the result dst_entry will be NULL.

solution:
walk through the bind address list to get the source
address and then lookup the routing table again to get
the correct dst_entry.

Signed-off-by: Weixing Shi <Weixing.Shi@windriver.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/ipv6.c |   47 +++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 321f175..5adf585 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -80,6 +80,9 @@
 
 #include <asm/uaccess.h>
 
+static inline int sctp_v6_addr_match_len(union sctp_addr *s1,
+					 union sctp_addr *s2);
+
 /* Event handler for inet6 address addition/deletion events.
  * The sctp_local_addr_list needs to be protocted by a spin lock since
  * multiple notifiers (say IPv4 and IPv6) may be running at the same
@@ -244,8 +247,14 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 					 union sctp_addr *daddr,
 					 union sctp_addr *saddr)
 {
-	struct dst_entry *dst;
+	struct dst_entry *dst = NULL;
 	struct flowi6 fl6;
+	struct sctp_bind_addr *bp;
+	struct sctp_sockaddr_entry *laddr;
+	union sctp_addr *baddr = NULL;
+	__u8 matchlen = 0;
+	__u8 bmatchlen;
+	sctp_scope_t scope;
 
 	memset(&fl6, 0, sizeof(fl6));
 	ipv6_addr_copy(&fl6.daddr, &daddr->v6.sin6_addr);
@@ -261,6 +270,39 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 	}
 
 	dst = ip6_route_output(&init_net, NULL, &fl6);
+	if (!asoc || saddr)
+		goto out;
+
+	if (dst->error) {
+		dst_release(dst);
+		dst = NULL;
+		bp = &asoc->base.bind_addr;
+		scope = sctp_scope(daddr);
+		/* Walk through the bind address list and try to get a dst that
+		 * matches a bind address as the source address.
+		 */
+		rcu_read_lock();
+		list_for_each_entry_rcu(laddr, &bp->address_list, list) {
+			if (!laddr->valid)
+				continue;
+			if ((laddr->state == SCTP_ADDR_SRC) &&
+			    (laddr->a.sa.sa_family == AF_INET6) &&
+			    (scope <= sctp_scope(&laddr->a))) {
+				bmatchlen = sctp_v6_addr_match_len(daddr,
+								   &laddr->a);
+				if (!baddr || (matchlen < bmatchlen)) {
+					baddr = &laddr->a;
+					matchlen = bmatchlen;
+				}
+			}
+		}
+		rcu_read_unlock();
+		if (baddr) {
+			ipv6_addr_copy(&fl6.saddr, &baddr->v6.sin6_addr);
+			dst = ip6_route_output(&init_net, NULL, &fl6);
+		}
+	}
+out:
 	if (!dst->error) {
 		struct rt6_info *rt;
 		rt = (struct rt6_info *)dst;
@@ -269,7 +311,8 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 		return dst;
 	}
 	SCTP_DEBUG_PRINTK("NO ROUTE\n");
-	dst_release(dst);
+	if (dst)
+		dst_release(dst);
 	return NULL;
 }
 
-- 
1.6.5.2


