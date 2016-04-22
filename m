From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 9/9] taskstats: use the libnl API to align nlattr on 64-bit
Date: Fri, 22 Apr 2016 17:31:24 +0200
Message-ID: <1461339084-3849-10-git-send-email-nicolas.dichtel@6wind.com>
References: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	linux-wpan@vger.kernel.org, aar@pengutronix.de,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	pshelar@nicira.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, netfilter-devel@vger.kernel.org,
	dev@openvswitch.org, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, bsingharora@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:53605 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753488AbcDVPcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 11:32:06 -0400
In-Reply-To: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Goal of this patch is to use the new libnl API to align netlink attribute
when needed.
The layout of the netlink message will be a bit different after the patch,
because the padattr (TASKSTATS_TYPE_STATS) will be inside the nested
attribute instead of before it.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 kernel/taskstats.c | 37 +++++--------------------------------
 1 file changed, 5 insertions(+), 32 deletions(-)

diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index 21f82c29c914..b3f05ee20d18 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -357,10 +357,6 @@ static int parse(struct nlattr *na, struct cpumask *mask)
 	return ret;
 }
 
-#if defined(CONFIG_64BIT) && !defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
-#define TASKSTATS_NEEDS_PADDING 1
-#endif
-
 static struct taskstats *mk_reply(struct sk_buff *skb, int type, u32 pid)
 {
 	struct nlattr *na, *ret;
@@ -370,29 +366,6 @@ static struct taskstats *mk_reply(struct sk_buff *skb, int type, u32 pid)
 			? TASKSTATS_TYPE_AGGR_PID
 			: TASKSTATS_TYPE_AGGR_TGID;
 
-	/*
-	 * The taskstats structure is internally aligned on 8 byte
-	 * boundaries but the layout of the aggregrate reply, with
-	 * two NLA headers and the pid (each 4 bytes), actually
-	 * force the entire structure to be unaligned. This causes
-	 * the kernel to issue unaligned access warnings on some
-	 * architectures like ia64. Unfortunately, some software out there
-	 * doesn't properly unroll the NLA packet and assumes that the start
-	 * of the taskstats structure will always be 20 bytes from the start
-	 * of the netlink payload. Aligning the start of the taskstats
-	 * structure breaks this software, which we don't want. So, for now
-	 * the alignment only happens on architectures that require it
-	 * and those users will have to update to fixed versions of those
-	 * packages. Space is reserved in the packet only when needed.
-	 * This ifdef should be removed in several years e.g. 2012 once
-	 * we can be confident that fixed versions are installed on most
-	 * systems. We add the padding before the aggregate since the
-	 * aggregate is already a defined type.
-	 */
-#ifdef TASKSTATS_NEEDS_PADDING
-	if (nla_put(skb, TASKSTATS_TYPE_NULL, 0, NULL) < 0)
-		goto err;
-#endif
 	na = nla_nest_start(skb, aggr);
 	if (!na)
 		goto err;
@@ -401,7 +374,8 @@ static struct taskstats *mk_reply(struct sk_buff *skb, int type, u32 pid)
 		nla_nest_cancel(skb, na);
 		goto err;
 	}
-	ret = nla_reserve(skb, TASKSTATS_TYPE_STATS, sizeof(struct taskstats));
+	ret = nla_reserve_64bit(skb, TASKSTATS_TYPE_STATS,
+				sizeof(struct taskstats), TASKSTATS_TYPE_NULL);
 	if (!ret) {
 		nla_nest_cancel(skb, na);
 		goto err;
@@ -500,10 +474,9 @@ static size_t taskstats_packet_size(void)
 	size_t size;
 
 	size = nla_total_size(sizeof(u32)) +
-		nla_total_size(sizeof(struct taskstats)) + nla_total_size(0);
-#ifdef TASKSTATS_NEEDS_PADDING
-	size += nla_total_size(0); /* Padding for alignment */
-#endif
+		nla_total_size_64bit(sizeof(struct taskstats)) +
+		nla_total_size(0);
+
 	return size;
 }
 
-- 
2.8.1
