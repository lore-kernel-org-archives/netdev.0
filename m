From: Patrick McHardy <kaber@trash.net>
Subject: [RTNETLINK]: Add nested compat attribute
Date: Fri, 22 Jun 2007 18:18:39 +0200
Message-ID: <467BF65F.4000803@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050003050701040408020308"
Cc: netdev@vger.kernel.org,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33935 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753082AbXFVQSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 12:18:51 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050003050701040408020308
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds a new attribute type that can be used
to replace non-nested attributes that contain structures
by nested ones in a compatible way.

This can be used in cases like Peter's who is trying to
extend sch_prio, which currently uses a fixed structure
without any holes.

Switching to nested attributes makes sure that the next
person won't run into the same problem.



--------------050003050701040408020308
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

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
commit dece87e23c7cfa1159d3be0ea5b0db89a0fc5872
tree c14be602de94b258e0343816b6c1809233a2ff5f
parent c4edf5d552b1450d903a7e7e2d846f2169087e10
author Patrick McHardy <kaber@gw.localnet> Fri, 22 Jun 2007 17:52:21 +0200
committer Patrick McHardy <kaber@gw.localnet> Fri, 22 Jun 2007 17:52:21 +0200

 include/linux/rtnetlink.h |   14 ++++++++++++++
 net/core/rtnetlink.c      |   16 ++++++++++++++++
 2 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 6127858..6731e7f 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -570,6 +570,8 @@ static __inline__ int rtattr_strcmp(cons
 }
 
 extern int rtattr_parse(struct rtattr *tb[], int maxattr, struct rtattr *rta, int len);
+extern int rtattr_parse_nested_compat(struct rtattr *tb[], int maxattr,
+				      struct rtattr *rta, void **data, int len);
 
 #define rtattr_parse_nested(tb, max, rta) \
 	rtattr_parse((tb), (max), RTA_DATA((rta)), RTA_PAYLOAD((rta)))
@@ -638,6 +640,18 @@ #define RTA_NEST_END(skb, start) \
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
index 06c0c5a..c25d23b 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -97,6 +97,21 @@ int rtattr_parse(struct rtattr *tb[], in
 	return 0;
 }
 
+int rtattr_parse_nested_compat(struct rtattr *tb[], int maxattr,
+			       struct rtattr *rta, void **data, int len)
+{
+	if (RTA_PAYLOAD(rta) < len)
+		return -1;
+	*data = RTA_DATA(rta);
+
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
@@ -1297,6 +1312,7 @@ void __init rtnetlink_init(void)
 EXPORT_SYMBOL(__rta_fill);
 EXPORT_SYMBOL(rtattr_strlcpy);
 EXPORT_SYMBOL(rtattr_parse);
+EXPORT_SYMBOL(rtattr_parse_nested_compat);
 EXPORT_SYMBOL(rtnetlink_put_metrics);
 EXPORT_SYMBOL(rtnl_lock);
 EXPORT_SYMBOL(rtnl_trylock);

--------------050003050701040408020308--
