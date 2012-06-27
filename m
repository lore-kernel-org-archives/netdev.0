From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 7/7] netlink: Get rid of obsolete rtnetlink macros
Date: Wed, 27 Jun 2012 11:36:16 +0200
Message-ID: <a10752bf3eb27e13e61b817664d58a69f9179fc9.1340788373.git.tgraf@suug.ch>
References: <cover.1340788373.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39646 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756729Ab2F0Jg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 05:36:28 -0400
In-Reply-To: <cover.1340788373.git.tgraf@suug.ch>
In-Reply-To: <cover.1340788373.git.tgraf@suug.ch>
References: <cover.1340788373.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removes all RTA_GET*() and RTA_PUT*() variations, as well as the
the unused rtattr_strcmp(). Get rid of rtm_get_table() by moving
it to its only user decnet.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rtnetlink.h |  129 ---------------------------------------------
 net/core/rtnetlink.c      |   13 -----
 net/decnet/dn_fib.c       |    8 +++
 3 files changed, 8 insertions(+), 142 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 2c1de89..ea60b08 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -612,12 +612,6 @@ struct tcamsg {
 #include <linux/mutex.h>
 #include <linux/netdevice.h>
 
-static __inline__ int rtattr_strcmp(const struct rtattr *rta, const char *str)
-{
-	int len = strlen(str) + 1;
-	return len > rta->rta_len || memcmp(RTA_DATA(rta), str, len);
-}
-
 extern int rtnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, u32 group, int echo);
 extern int rtnl_unicast(struct sk_buff *skb, struct net *net, u32 pid);
 extern void rtnl_notify(struct sk_buff *skb, struct net *net, u32 pid,
@@ -628,122 +622,6 @@ extern int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst,
 			      u32 id, u32 ts, u32 tsage, long expires,
 			      u32 error);
 
-extern void __rta_fill(struct sk_buff *skb, int attrtype, int attrlen, const void *data);
-
-#define RTA_PUT(skb, attrtype, attrlen, data) \
-({	if (unlikely(skb_tailroom(skb) < (int)RTA_SPACE(attrlen))) \
-		 goto rtattr_failure; \
-   	__rta_fill(skb, attrtype, attrlen, data); }) 
-
-#define RTA_APPEND(skb, attrlen, data) \
-({	if (unlikely(skb_tailroom(skb) < (int)(attrlen))) \
-		goto rtattr_failure; \
-	memcpy(skb_put(skb, attrlen), data, attrlen); })
-
-#define RTA_PUT_NOHDR(skb, attrlen, data) \
-({	RTA_APPEND(skb, RTA_ALIGN(attrlen), data); \
-	memset(skb_tail_pointer(skb) - (RTA_ALIGN(attrlen) - attrlen), 0, \
-	       RTA_ALIGN(attrlen) - attrlen); })
-
-#define RTA_PUT_U8(skb, attrtype, value) \
-({	u8 _tmp = (value); \
-	RTA_PUT(skb, attrtype, sizeof(u8), &_tmp); })
-
-#define RTA_PUT_U16(skb, attrtype, value) \
-({	u16 _tmp = (value); \
-	RTA_PUT(skb, attrtype, sizeof(u16), &_tmp); })
-
-#define RTA_PUT_U32(skb, attrtype, value) \
-({	u32 _tmp = (value); \
-	RTA_PUT(skb, attrtype, sizeof(u32), &_tmp); })
-
-#define RTA_PUT_U64(skb, attrtype, value) \
-({	u64 _tmp = (value); \
-	RTA_PUT(skb, attrtype, sizeof(u64), &_tmp); })
-
-#define RTA_PUT_SECS(skb, attrtype, value) \
-	RTA_PUT_U64(skb, attrtype, (value) / HZ)
-
-#define RTA_PUT_MSECS(skb, attrtype, value) \
-	RTA_PUT_U64(skb, attrtype, jiffies_to_msecs(value))
-
-#define RTA_PUT_STRING(skb, attrtype, value) \
-	RTA_PUT(skb, attrtype, strlen(value) + 1, value)
-
-#define RTA_PUT_FLAG(skb, attrtype) \
-	RTA_PUT(skb, attrtype, 0, NULL);
-
-#define RTA_NEST(skb, type) \
-({	struct rtattr *__start = (struct rtattr *)skb_tail_pointer(skb); \
-	RTA_PUT(skb, type, 0, NULL); \
-	__start;  })
-
-#define RTA_NEST_END(skb, start) \
-({	(start)->rta_len = skb_tail_pointer(skb) - (unsigned char *)(start); \
-	(skb)->len; })
-
-#define RTA_NEST_COMPAT(skb, type, attrlen, data) \
-({	struct rtattr *__start = (struct rtattr *)skb_tail_pointer(skb); \
-	RTA_PUT(skb, type, attrlen, data); \
-	RTA_NEST(skb, type); \
-	__start; })
-
-#define RTA_NEST_COMPAT_END(skb, start) \
-({	struct rtattr *__nest = (void *)(start) + NLMSG_ALIGN((start)->rta_len); \
-	(start)->rta_len = skb_tail_pointer(skb) - (unsigned char *)(start); \
-	RTA_NEST_END(skb, __nest); \
-	(skb)->len; })
-
-#define RTA_NEST_CANCEL(skb, start) \
-({	if (start) \
-		skb_trim(skb, (unsigned char *) (start) - (skb)->data); \
-	-1; })
-
-#define RTA_GET_U8(rta) \
-({	if (!rta || RTA_PAYLOAD(rta) < sizeof(u8)) \
-		goto rtattr_failure; \
-	*(u8 *) RTA_DATA(rta); })
-
-#define RTA_GET_U16(rta) \
-({	if (!rta || RTA_PAYLOAD(rta) < sizeof(u16)) \
-		goto rtattr_failure; \
-	*(u16 *) RTA_DATA(rta); })
-
-#define RTA_GET_U32(rta) \
-({	if (!rta || RTA_PAYLOAD(rta) < sizeof(u32)) \
-		goto rtattr_failure; \
-	*(u32 *) RTA_DATA(rta); })
-
-#define RTA_GET_U64(rta) \
-({	u64 _tmp; \
-	if (!rta || RTA_PAYLOAD(rta) < sizeof(u64)) \
-		goto rtattr_failure; \
-	memcpy(&_tmp, RTA_DATA(rta), sizeof(_tmp)); \
-	_tmp; })
-
-#define RTA_GET_FLAG(rta) (!!(rta))
-
-#define RTA_GET_SECS(rta) ((unsigned long) RTA_GET_U64(rta) * HZ)
-#define RTA_GET_MSECS(rta) (msecs_to_jiffies((unsigned long) RTA_GET_U64(rta)))
-		
-static inline struct rtattr *
-__rta_reserve(struct sk_buff *skb, int attrtype, int attrlen)
-{
-	struct rtattr *rta;
-	int size = RTA_LENGTH(attrlen);
-
-	rta = (struct rtattr*)skb_put(skb, RTA_ALIGN(size));
-	rta->rta_type = attrtype;
-	rta->rta_len = size;
-	memset(RTA_DATA(rta) + attrlen, 0, RTA_ALIGN(size) - size);
-	return rta;
-}
-
-#define __RTA_PUT(skb, attrtype, attrlen) \
-({ 	if (unlikely(skb_tailroom(skb) < (int)RTA_SPACE(attrlen))) \
-		goto rtattr_failure; \
-   	__rta_reserve(skb, attrtype, attrlen); })
-
 extern void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change);
 
 /* RTNL is used as a global lock for all changes to network configuration  */
@@ -794,13 +672,6 @@ extern void __rtnl_unlock(void);
 	} \
 } while(0)
 
-static inline u32 rtm_get_table(struct rtattr **rta, u8 table)
-{
-	return RTA_GET_U32(rta[RTA_TABLE-1]);
-rtattr_failure:
-	return table;
-}
-
 extern int ndo_dflt_fdb_dump(struct sk_buff *skb,
 			     struct netlink_callback *cb,
 			     struct net_device *dev,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 21318d1..bc8a1cd 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -541,19 +541,6 @@ static const int rta_max[RTM_NR_FAMILIES] =
 	[RTM_FAM(RTM_NEWACTION)]    = TCAA_MAX,
 };
 
-void __rta_fill(struct sk_buff *skb, int attrtype, int attrlen, const void *data)
-{
-	struct rtattr *rta;
-	int size = RTA_LENGTH(attrlen);
-
-	rta = (struct rtattr *)skb_put(skb, RTA_ALIGN(size));
-	rta->rta_type = attrtype;
-	rta->rta_len = size;
-	memcpy(RTA_DATA(rta), data, attrlen);
-	memset(RTA_DATA(rta) + attrlen, 0, RTA_ALIGN(size) - size);
-}
-EXPORT_SYMBOL(__rta_fill);
-
 int rtnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, unsigned int group, int echo)
 {
 	struct sock *rtnl = net->rtnl;
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index 7eaf987..102d610 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -505,6 +505,14 @@ static int dn_fib_check_attr(struct rtmsg *r, struct rtattr **rta)
 	return 0;
 }
 
+static inline u32 rtm_get_table(struct rtattr **rta, u8 table)
+{
+	if (rta[RTA_TABLE - 1])
+		table = nla_get_u32((struct nlattr *) rta[RTA_TABLE - 1]);
+
+	return table;
+}
+
 static int dn_fib_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
-- 
1.7.7.6
