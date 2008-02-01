From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] rtnetlink.c: remove no longer used functions
Date: Fri, 1 Feb 2008 18:19:04 +0200
Message-ID: <20080201161904.GA12176@cs181133002.pp.htv.fi>
References: <20080130200257.GD29368@does.not.exist> <47A0D851.9050408@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:39606 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753516AbYBAQSY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 11:18:24 -0500
Content-Disposition: inline
In-Reply-To: <47A0D851.9050408@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 30, 2008 at 09:04:33PM +0100, Patrick McHardy wrote:
> Adrian Bunk wrote:
>> This patch #if 0's the following no longer used functions:
>> - rtattr_parse()
>> - rtattr_strlcpy()
>> - __rtattr_parse_nested_compat()
>>   
>
> Please remove them instead.

Updated patch below.

cu
Adrian


<--  snip  -->


This patch removes the following no longer used functions:
- rtattr_parse()
- rtattr_strlcpy()
- __rtattr_parse_nested_compat()

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 include/linux/rtnetlink.h |   12 ----------
 net/core/rtnetlink.c      |   44 --------------------------------------
 2 files changed, 56 deletions(-)

dcfe6b63a05c4944afcfc22fd4f2d2b495dc04c6 
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index b014f6b..b9e1740 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -602,24 +602,12 @@ struct tcamsg
 
 #include <linux/mutex.h>
 
-extern size_t rtattr_strlcpy(char *dest, const struct rtattr *rta, size_t size);
 static __inline__ int rtattr_strcmp(const struct rtattr *rta, const char *str)
 {
 	int len = strlen(str) + 1;
 	return len > rta->rta_len || memcmp(RTA_DATA(rta), str, len);
 }
 
-extern int rtattr_parse(struct rtattr *tb[], int maxattr, struct rtattr *rta, int len);
-extern int __rtattr_parse_nested_compat(struct rtattr *tb[], int maxattr,
-				        struct rtattr *rta, int len);
-
-#define rtattr_parse_nested(tb, max, rta) \
-	rtattr_parse((tb), (max), RTA_DATA((rta)), RTA_PAYLOAD((rta)))
-
-#define rtattr_parse_nested_compat(tb, max, rta, data, len) \
-({	data = RTA_PAYLOAD(rta) >= len ? RTA_DATA(rta) : NULL; \
-	__rtattr_parse_nested_compat(tb, max, rta, len); })
-
 extern int rtnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, u32 group, int echo);
 extern int rtnl_unicast(struct sk_buff *skb, struct net *net, u32 pid);
 extern int rtnl_notify(struct sk_buff *skb, struct net *net, u32 pid, u32 group,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index ddbdde8..61ac8d0 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -82,32 +82,6 @@ int rtnl_trylock(void)
 	return mutex_trylock(&rtnl_mutex);
 }
 
-int rtattr_parse(struct rtattr *tb[], int maxattr, struct rtattr *rta, int len)
-{
-	memset(tb, 0, sizeof(struct rtattr*)*maxattr);
-
-	while (RTA_OK(rta, len)) {
-		unsigned flavor = rta->rta_type;
-		if (flavor && flavor <= maxattr)
-			tb[flavor-1] = rta;
-		rta = RTA_NEXT(rta, len);
-	}
-	return 0;
-}
-
-int __rtattr_parse_nested_compat(struct rtattr *tb[], int maxattr,
-				 struct rtattr *rta, int len)
-{
-	if (RTA_PAYLOAD(rta) < len)
-		return -1;
-	if (RTA_PAYLOAD(rta) >= RTA_ALIGN(len) + sizeof(struct rtattr)) {
-		rta = RTA_DATA(rta) + RTA_ALIGN(len);
-		return rtattr_parse_nested(tb, maxattr, rta);
-	}
-	memset(tb, 0, sizeof(struct rtattr *) * maxattr);
-	return 0;
-}
-
 static struct rtnl_link *rtnl_msg_handlers[NPROTO];
 
 static inline int rtm_msgindex(int msgtype)
@@ -442,21 +416,6 @@ void __rta_fill(struct sk_buff *skb, int attrtype, int attrlen, const void *data
 	memset(RTA_DATA(rta) + attrlen, 0, RTA_ALIGN(size) - size);
 }
 
-size_t rtattr_strlcpy(char *dest, const struct rtattr *rta, size_t size)
-{
-	size_t ret = RTA_PAYLOAD(rta);
-	char *src = RTA_DATA(rta);
-
-	if (ret > 0 && src[ret - 1] == '\0')
-		ret--;
-	if (size > 0) {
-		size_t len = (ret >= size) ? size - 1 : ret;
-		memset(dest, 0, size);
-		memcpy(dest, src, len);
-	}
-	return ret;
-}
-
 int rtnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, unsigned group, int echo)
 {
 	struct sock *rtnl = net->rtnl;
@@ -1411,9 +1370,6 @@ void __init rtnetlink_init(void)
 }
 
 EXPORT_SYMBOL(__rta_fill);
-EXPORT_SYMBOL(rtattr_strlcpy);
-EXPORT_SYMBOL(rtattr_parse);
-EXPORT_SYMBOL(__rtattr_parse_nested_compat);
 EXPORT_SYMBOL(rtnetlink_put_metrics);
 EXPORT_SYMBOL(rtnl_lock);
 EXPORT_SYMBOL(rtnl_trylock);

