From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RTNETLINK]: Add nested compat attribute
Date: Tue, 26 Jun 2007 12:04:21 +0200
Message-ID: <4680E4A5.2020702@trash.net>
References: <20070625.143248.73361950.davem@davemloft.net>	<D5C1322C3E673F459512FB59E0DDC329031B5835@orsmsx414.amr.corp.intel.com> <20070625.171504.13046835.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050907040409050305060203"
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59454 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725AbXFZKEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 06:04:35 -0400
In-Reply-To: <20070625.171504.13046835.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050907040409050305060203
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

David Miller wrote:
> Meanwhile, Patrick please clear up the situation :-)


Attached is both an incremental patch and a complete replacement,
please take whichever you like better :)



--------------050907040409050305060203
Content-Type: text/x-diff;
 name="complete.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="complete.diff"

[RTNETLINK]: Add nested compat attribute

Add a nested compat attribute type that can be used to convert
attributes that contain a structure to nested attributes in a
backwards compatible way.

The attribute looks like this:

struct {
        [ compat contents ]
        struct rtattr {
                .rta_len        = total size,
                .rta_type       = type,
        } rta;
        struct old_structure struct;

        [ nested top-level attribute ]
        struct rtattr {
                .rta_len        = nest size,
                .rta_type       = type,
        } nest_attr;

        [ optional 0 .. n nested attributes ]
        struct rtattr {
                .rta_len        = private attribute len,
                .rta_type       = private attribute typ,
        } nested_attr;
        struct nested_data data;
};

Since both userspace and kernel deal correctly with attributes that are
larger than expected old versions will just parse the compat part and
ignore the rest.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 1e16b5e521172515c53ce96a0bc3cf0e2d77c001
tree c9880c58391e2df77ecab3d9b6a6849947714eb3
parent c4edf5d552b1450d903a7e7e2d846f2169087e10
author Patrick McHardy <kaber@gw.localnet> Fri, 22 Jun 2007 19:06:54 +0200
committer Patrick McHardy <kaber@gw.localnet> Fri, 22 Jun 2007 19:06:54 +0200

 include/linux/rtnetlink.h |   18 ++++++++++++++++++
 net/core/rtnetlink.c      |   14 ++++++++++++++
 2 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 6127858..d40b0c9 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -570,10 +570,16 @@ static __inline__ int rtattr_strcmp(cons
 }
 
 extern int rtattr_parse(struct rtattr *tb[], int maxattr, struct rtattr *rta, int len);
+extern int __rtattr_parse_nested_compat(struct rtattr *tb[], int maxattr,
+				        struct rtattr *rta, int len);
 
 #define rtattr_parse_nested(tb, max, rta) \
 	rtattr_parse((tb), (max), RTA_DATA((rta)), RTA_PAYLOAD((rta)))
 
+#define rtattr_parse_nested_compat(tb, max, rta, data, len) \
+({	data = RTA_PAYLOAD(rta) >= len ? RTA_DATA(rta) : NULL; \
+	__rtattr_parse_nested_compat(tb, max, rta, len); })
+
 extern int rtnetlink_send(struct sk_buff *skb, u32 pid, u32 group, int echo);
 extern int rtnl_unicast(struct sk_buff *skb, u32 pid);
 extern int rtnl_notify(struct sk_buff *skb, u32 pid, u32 group,
@@ -638,6 +644,18 @@ #define RTA_NEST_END(skb, start) \
 ({	(start)->rta_len = skb_tail_pointer(skb) - (unsigned char *)(start); \
 	(skb)->len; })
 
+#define RTA_NEST_COMPAT(skb, type, attrlen, data) \
+({	struct rtattr *__start = (struct rtattr *)skb_tail_pointer(skb); \
+	RTA_PUT(skb, type, attrlen, data); \
+	RTA_NEST(skb, type); \
+	__start; })
+
+#define RTA_NEST_COMPAT_END(skb, start) \
+({	struct rtattr *__nest = (void *)(start) + NLMSG_ALIGN((start)->rta_len); \
+	(start)->rta_len = skb_tail_pointer(skb) - (unsigned char *)(start); \
+	RTA_NEST_END(skb, __nest); \
+	(skb)->len; })
+
 #define RTA_NEST_CANCEL(skb, start) \
 ({	if (start) \
 		skb_trim(skb, (unsigned char *) (start) - (skb)->data); \
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 06c0c5a..54c17e4 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -97,6 +97,19 @@ int rtattr_parse(struct rtattr *tb[], in
 	return 0;
 }
 
+int __rtattr_parse_nested_compat(struct rtattr *tb[], int maxattr,
+			         struct rtattr *rta, int len)
+{
+	if (RTA_PAYLOAD(rta) < len)
+		return -1;
+	if (RTA_PAYLOAD(rta) >= RTA_ALIGN(len) + sizeof(struct rtattr)) {
+		rta = RTA_DATA(rta) + RTA_ALIGN(len);
+		return rtattr_parse_nested(tb, maxattr, rta);
+	}
+	memset(tb, 0, sizeof(struct rtattr *) * maxattr);
+	return 0;
+}
+
 static struct rtnl_link *rtnl_msg_handlers[NPROTO];
 
 static inline int rtm_msgindex(int msgtype)
@@ -1297,6 +1310,7 @@ void __init rtnetlink_init(void)
 EXPORT_SYMBOL(__rta_fill);
 EXPORT_SYMBOL(rtattr_strlcpy);
 EXPORT_SYMBOL(rtattr_parse);
+EXPORT_SYMBOL(__rtattr_parse_nested_compat);
 EXPORT_SYMBOL(rtnetlink_put_metrics);
 EXPORT_SYMBOL(rtnl_lock);
 EXPORT_SYMBOL(rtnl_trylock);

--------------050907040409050305060203
Content-Type: text/x-diff;
 name="incremental.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="incremental.diff"

[RTNETLINK]: Fix rtnetlink compat attribute patch

Sent the wrong patch previously.

Signed-off-by: Patrick McHardy <kaber@trash.net>
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 5852921..a37be6a 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -570,12 +570,16 @@ static __inline__ int rtattr_strcmp(const struct rtattr *rta, const char *str)
 }
 
 extern int rtattr_parse(struct rtattr *tb[], int maxattr, struct rtattr *rta, int len);
-extern int rtattr_parse_nested_compat(struct rtattr *tb[], int maxattr,
-				      struct rtattr *rta, void **data, int len);
+extern int __rtattr_parse_nested_compat(struct rtattr *tb[], int maxattr,
+				        struct rtattr *rta, int len);
 
 #define rtattr_parse_nested(tb, max, rta) \
 	rtattr_parse((tb), (max), RTA_DATA((rta)), RTA_PAYLOAD((rta)))
 
+#define rtattr_parse_nested_compat(tb, max, rta, data, len) \
+({	data = RTA_PAYLOAD(rta) >= len ? RTA_DATA(rta) : NULL; \
+	__rtattr_parse_nested_compat(tb, max, rta, len); })
+
 extern int rtnetlink_send(struct sk_buff *skb, u32 pid, u32 group, int echo);
 extern int rtnl_unicast(struct sk_buff *skb, u32 pid);
 extern int rtnl_notify(struct sk_buff *skb, u32 pid, u32 group,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 012363b..0c4be06 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -97,13 +97,11 @@ int rtattr_parse(struct rtattr *tb[], int maxattr, struct rtattr *rta, int len)
 	return 0;
 }
 
-int rtattr_parse_nested_compat(struct rtattr *tb[], int maxattr,
-			       struct rtattr *rta, void **data, int len)
+int __rtattr_parse_nested_compat(struct rtattr *tb[], int maxattr,
+			         struct rtattr *rta, int len)
 {
 	if (RTA_PAYLOAD(rta) < len)
 		return -1;
-	*data = RTA_DATA(rta);
-
 	if (RTA_PAYLOAD(rta) >= RTA_ALIGN(len) + sizeof(struct rtattr)) {
 		rta = RTA_DATA(rta) + RTA_ALIGN(len);
 		return rtattr_parse_nested(tb, maxattr, rta);
@@ -975,7 +973,7 @@ void __init rtnetlink_init(void)
 EXPORT_SYMBOL(__rta_fill);
 EXPORT_SYMBOL(rtattr_strlcpy);
 EXPORT_SYMBOL(rtattr_parse);
-EXPORT_SYMBOL(rtattr_parse_nested_compat);
+EXPORT_SYMBOL(__rtattr_parse_nested_compat);
 EXPORT_SYMBOL(rtnetlink_put_metrics);
 EXPORT_SYMBOL(rtnl_lock);
 EXPORT_SYMBOL(rtnl_trylock);

--------------050907040409050305060203--
