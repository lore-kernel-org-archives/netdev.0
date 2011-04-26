From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 3/7] sctp: make sctp over IPv6 work with IPsec
Date: Tue, 26 Apr 2011 11:47:05 +0800
Message-ID: <4DB64039.20008@cn.fujitsu.com>
References: <4DB63F85.2090609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49719 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758098Ab1DZDrS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2011 23:47:18 -0400
In-Reply-To: <4DB63F85.2090609@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>

SCTP never called xfrm_output after it's v6 route lookups so
that never really worked with ipsec.  Additioanlly, we never
passed port nubmers in the flowi, so any port based policies were
never applied as well.  Now that we can fixed ipv6 routing lookup
code, we can add xfrm_output calls and pass port numbers.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/ipv6.c |   34 ++++++++++++++++++++++++++++++++--
 1 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index cc9ea37..74fe28c 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -244,6 +244,30 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
 	return ip6_xmit(sk, skb, &fl6, np->opt);
 }
 
+/* Small helper function that combines route and XFRM lookups.  This is
+ * done since we might be looping through route lookups.
+ */
+static int sctp_v6_dst_lookup(struct sock *sk, struct dst_entry **dst,
+				struct flowi6 *fl6)
+{
+	int err;
+
+	err = ip6_dst_lookup(sk, dst, fl6);
+	if (err)
+		goto done;
+
+	err = xfrm_lookup(sock_net(sk), *dst, flowi6_to_flowi(fl6), sk, 0);
+	if (err)
+		goto done;
+
+	return 0;
+
+done:
+	dst_release(*dst);
+	*dst = NULL;
+	return err;
+}
+
 /* Returns the dst cache entry for the given source and destination ip
  * addresses.
  */
@@ -266,18 +290,23 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 
 	memset(fl6, 0, sizeof(struct flowi6));
 	ipv6_addr_copy(&fl6->daddr, &daddr->v6.sin6_addr);
+	fl6->fl6_dport = daddr->v6.sin6_port;
 	if (ipv6_addr_type(&daddr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
 		fl6->flowi6_oif = daddr->v6.sin6_scope_id;
 
 
 	SCTP_DEBUG_PRINTK("%s: DST=%pI6 ", __func__, &fl6->daddr);
 
+	if (asoc)
+		fl6->fl6_sport = htons(asoc->base.bind_addr.port);
+
 	if (saddr) {
 		ipv6_addr_copy(&fl6->saddr, &saddr->v6.sin6_addr);
+		fl6->fl6_sport = saddr->v6.sin6_port;
 		SCTP_DEBUG_PRINTK("SRC=%pI6 - ", &fl6->saddr);
 	}
 
-	err = ip6_dst_lookup(sk, &dst, fl6);
+	err = sctp_v6_dst_lookup(sk, &dst, fl6);
 	if (!asoc || saddr)
 		goto out;
 
@@ -331,7 +360,8 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 	rcu_read_unlock();
 	if (baddr) {
 		ipv6_addr_copy(&fl6->saddr, &baddr->v6.sin6_addr);
-		err = ip6_dst_lookup(sk, &dst, fl6);
+		fl6->fl6_sport = baddr->v6.sin6_port;
+		err = sctp_v6_dst_lookup(sk, &dst, fl6);
 	}
 
 out:
-- 
1.6.5.2


