From: Arnd Bergmann <arnd@arndb.de>
Subject: KASAN+netlink, was: [PATCH] [net-next?] hns: avoid stack overflow with CONFIG_KASAN
Date: Wed, 08 Feb 2017 13:03:59 +0100
Message-ID: <4910112.l20yySyWnA@wuerfel>
References: <20170203163607.3488037-1-arnd@arndb.de> <20170206.120318.1268240226202516488.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: stable@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andrey Ryabinin <a.ryabinin@samsung.com>,
        johannes.berg@intel.com, nikolay@cumulusnetworks.com,
        nicolas.dichtel@6wind.com, adobriyan@gmail.com
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.134]:57691 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932147AbdBHMEt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 07:04:49 -0500
In-Reply-To: <20170206.120318.1268240226202516488.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, February 6, 2017 12:03:18 PM CET David Miller wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Fri,  3 Feb 2017 17:35:46 +0100
> 
> > The use of ACCESS_ONCE() looks like a micro-optimization to force gcc to use
> > an indexed load for the register address, but it has an absolutely detrimental
> > effect on builds with gcc-5 and CONFIG_KASAN=y, leading to a very likely
> > kernel stack overflow aside from very complex object code:
>  ...
> > This does not seem to happen any more with gcc-7, but removing the ACCESS_ONCE
> > seems safe anyway and it avoids a serious issue for some people. I have verified
> > that with gcc-5.3.1, the object code we get is better in the new version
> > both with and without CONFIG_KASAN, as we no longer allocate a 1344 byte
> > stack frame for hns_dsaf_get_regs() but otherwise have practically identical
> > object code.
> > 
> > With gcc-7.0.0, removing ACCESS_ONCE has no effect, the object code is already
> > good either way.
> > 
> > This patch is probably not urgent to get into 4.11 as only KASAN=y builds
> > with certain compilers are affected, but I still think it makes sense to
> > backport into older kernels.
> > 
> > Cc: stable@vger.kernel.org
> > Fixes: 511e6bc ("net: add Hisilicon Network Subsystem DSAF support")
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> This is really terrible for the compiler to do, but what can we do about it.
> 
> I'll apply this to 'net' and queue it up for -stable, thanks.
> 

Thanks! On a related note, I ran into one other stack size warning with
KASAN (specifically asan-stack=1) on arm64, and this potentially impacts all
users of nla_put_*():

net/wireless/nl80211.c:4389:1: warning: the frame size of 2240 bytes is larger than 2048 bytes [-Wframe-larger-than=]
1	net/wireless/nl80211.c:1895:1: warning: the frame size of 3776 bytes is larger than 2048 bytes [-Wframe-larger-than=]
1	net/wireless/nl80211.c:1410:1: warning: the frame size of 2208 bytes is larger than 2048 bytes [-Wframe-larger-than=]
1	net/bridge/br_netlink.c:1282:1: warning: the frame size of 2544 bytes is larger than 2048 bytes [-Wframe-larger-than=]

I have an ugly prototype patch trying out different things, and it makes the
warnings go away as the stack size drops just below the default 2048 byte
warning level for 64-bit architectures, using gcc-7. However, without
asan-stack=1, none of these use an unusual amount of stack at all (mostly
around 200 bytes).

Things I've tried here are:

- Moving nla_put_{u8,u16,u32} out of line is probably uncontroversial and
  it helps enough with br_netlink.c, but nl820211 is worse and needs some
  additional fiddling.
- nla_put_typed_64bit() and nla_put_typed() macros that add a type check
  and directly copy the source argument without a local variable in an
  inline function. This doesn't work when the types don't match (as is
  often the case) and is rather ugly.
- new __nla_put_{u8,u16,be16,...) wrappers around that macro to make
  it less ugly. It still requires the correct types and I'm not happy
  about the name either.

	Arnd

 include/net/netlink.h  |  54 ++++++++++-----
 lib/nlattr.c           |  18 +++++
 net/wireless/nl80211.c | 183 +++++++++++++++++++++++++------------------------
 3 files changed, 151 insertions(+), 104 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index b239fcd..bb52ac3 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -749,16 +749,21 @@ static inline int nla_parse_nested(struct nlattr *tb[], int maxtype,
 	return nla_parse(tb, maxtype, nla_data(nla), nla_len(nla), policy);
 }
 
+#define nla_put_typed(skb, attrtype, type, value) \
+	nla_put((skb), (attrtype), sizeof(type), (&(value) - (type *)NULL + NULL))
+
+#define nla_put_typed_64bit(skb, attrtype, type, value, padattr) \
+        nla_put_64bit((skb), (attrtype), sizeof(type), (&(value) - (type *)NULL + NULL), (padattr))
+
+
 /**
  * nla_put_u8 - Add a u8 netlink attribute to a socket buffer
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_u8(struct sk_buff *skb, int attrtype, u8 value)
-{
-	return nla_put(skb, attrtype, sizeof(u8), &value);
-}
+extern int nla_put_u8(struct sk_buff *skb, int attrtype, u8 value);
+#define __nla_put_u8(skb, attrtype, value) nla_put_typed(skb, attrtype, u8, value)
 
 /**
  * nla_put_u16 - Add a u16 netlink attribute to a socket buffer
@@ -766,10 +771,8 @@ static inline int nla_put_u8(struct sk_buff *skb, int attrtype, u8 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_u16(struct sk_buff *skb, int attrtype, u16 value)
-{
-	return nla_put(skb, attrtype, sizeof(u16), &value);
-}
+extern int nla_put_u16(struct sk_buff *skb, int attrtype, u16 value);
+#define __nla_put_u16(skb, attrtype, value) nla_put_typed(skb, attrtype, u16, value)
 
 /**
  * nla_put_be16 - Add a __be16 netlink attribute to a socket buffer
@@ -779,8 +782,9 @@ static inline int nla_put_u16(struct sk_buff *skb, int attrtype, u16 value)
  */
 static inline int nla_put_be16(struct sk_buff *skb, int attrtype, __be16 value)
 {
-	return nla_put(skb, attrtype, sizeof(__be16), &value);
+	return nla_put_u16(skb, attrtype, (u16 __force)value);
 }
+#define __nla_put_be16(skb, attrtype, value) nla_put_typed(skb, attrtype, be16, value)
 
 /**
  * nla_put_net16 - Add 16-bit network byte order netlink attribute to a socket buffer
@@ -792,6 +796,7 @@ static inline int nla_put_net16(struct sk_buff *skb, int attrtype, __be16 value)
 {
 	return nla_put_be16(skb, attrtype | NLA_F_NET_BYTEORDER, value);
 }
+#define __nla_put_net16(skb, attrtype, value) nla_put_typed(skb, attrtype, net16, value)
 
 /**
  * nla_put_le16 - Add a __le16 netlink attribute to a socket buffer
@@ -801,8 +806,9 @@ static inline int nla_put_net16(struct sk_buff *skb, int attrtype, __be16 value)
  */
 static inline int nla_put_le16(struct sk_buff *skb, int attrtype, __le16 value)
 {
-	return nla_put(skb, attrtype, sizeof(__le16), &value);
+	return nla_put_u16(skb, attrtype, (u16 __force)value);
 }
+#define __nla_put_le16(skb, attrtype, value) nla_put_typed(skb, attrtype, le16, value)
 
 /**
  * nla_put_u32 - Add a u32 netlink attribute to a socket buffer
@@ -810,10 +816,8 @@ static inline int nla_put_le16(struct sk_buff *skb, int attrtype, __le16 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_u32(struct sk_buff *skb, int attrtype, u32 value)
-{
-	return nla_put(skb, attrtype, sizeof(u32), &value);
-}
+int nla_put_u32(struct sk_buff *skb, int attrtype, u32 value);
+#define __nla_put_u32(skb, attrtype, value) nla_put_typed(skb, attrtype, u32, value)
 
 /**
  * nla_put_be32 - Add a __be32 netlink attribute to a socket buffer
@@ -823,8 +827,9 @@ static inline int nla_put_u32(struct sk_buff *skb, int attrtype, u32 value)
  */
 static inline int nla_put_be32(struct sk_buff *skb, int attrtype, __be32 value)
 {
-	return nla_put(skb, attrtype, sizeof(__be32), &value);
+	return nla_put_u32(skb, attrtype, (u32 __force)value);
 }
+#define __nla_put_be32(skb, attrtype, value) nla_put_typed(skb, attrtype, be32, value)
 
 /**
  * nla_put_net32 - Add 32-bit network byte order netlink attribute to a socket buffer
@@ -836,6 +841,8 @@ static inline int nla_put_net32(struct sk_buff *skb, int attrtype, __be32 value)
 {
 	return nla_put_be32(skb, attrtype | NLA_F_NET_BYTEORDER, value);
 }
+#define __nla_put_net32(skb, attrtype, value) \
+	nla_put_typed(skb, (attrtype) | NLA_F_NET_BYTEORDER, net32, value)
 
 /**
  * nla_put_le32 - Add a __le32 netlink attribute to a socket buffer
@@ -845,8 +852,9 @@ static inline int nla_put_net32(struct sk_buff *skb, int attrtype, __be32 value)
  */
 static inline int nla_put_le32(struct sk_buff *skb, int attrtype, __le32 value)
 {
-	return nla_put(skb, attrtype, sizeof(__le32), &value);
+	return nla_put_u32(skb, attrtype, (u32 __force)value);
 }
+#define __nla_put_le32(skb, attrtype, value) nla_put_typed(skb, attrtype, le32, value)
 
 /**
  * nla_put_u64_64bit - Add a u64 netlink attribute to a skb and align it
@@ -860,6 +868,8 @@ static inline int nla_put_u64_64bit(struct sk_buff *skb, int attrtype,
 {
 	return nla_put_64bit(skb, attrtype, sizeof(u64), &value, padattr);
 }
+#define __nla_put_u64_64bit(skb, attrtype, value, padattr) \
+		nla_put_typed_64bit(skb, attrtype, u64, value, padattr)
 
 /**
  * nla_put_be64 - Add a __be64 netlink attribute to a socket buffer and align it
@@ -873,6 +883,8 @@ static inline int nla_put_be64(struct sk_buff *skb, int attrtype, __be64 value,
 {
 	return nla_put_64bit(skb, attrtype, sizeof(__be64), &value, padattr);
 }
+#define __nla_put_be64_64bit(skb, attrtype, value, padattr) \
+		nla_put_typed_64bit(skb, attrtype, be64, value, padattr)
 
 /**
  * nla_put_net64 - Add 64-bit network byte order nlattr to a skb and align it
@@ -887,6 +899,8 @@ static inline int nla_put_net64(struct sk_buff *skb, int attrtype, __be64 value,
 	return nla_put_be64(skb, attrtype | NLA_F_NET_BYTEORDER, value,
 			    padattr);
 }
+#define __nla_put_net64_64bit(skb, attrtype, value, padattr) \
+		nla_put_typed_64bit(skb, (attrtype) | NLA_F_NET_BYTEORDER, net64, value, padattr)
 
 /**
  * nla_put_le64 - Add a __le64 netlink attribute to a socket buffer and align it
@@ -900,6 +914,8 @@ static inline int nla_put_le64(struct sk_buff *skb, int attrtype, __le64 value,
 {
 	return nla_put_64bit(skb, attrtype, sizeof(__le64), &value, padattr);
 }
+#define __nla_put_le64_64bit(skb, attrtype, value, padattr) \
+		nla_put_typed_64bit(skb, attrtype, le64, value, padattr)
 
 /**
  * nla_put_s8 - Add a s8 netlink attribute to a socket buffer
@@ -911,6 +927,7 @@ static inline int nla_put_s8(struct sk_buff *skb, int attrtype, s8 value)
 {
 	return nla_put(skb, attrtype, sizeof(s8), &value);
 }
+#define __nla_put_s8(skb, attrtype, value) nla_put_typed(skb, attrtype, s8, value)
 
 /**
  * nla_put_s16 - Add a s16 netlink attribute to a socket buffer
@@ -922,6 +939,7 @@ static inline int nla_put_s16(struct sk_buff *skb, int attrtype, s16 value)
 {
 	return nla_put(skb, attrtype, sizeof(s16), &value);
 }
+#define __nla_put_s16(skb, attrtype, value) nla_put_typed(skb, attrtype, s16, value)
 
 /**
  * nla_put_s32 - Add a s32 netlink attribute to a socket buffer
@@ -933,6 +951,7 @@ static inline int nla_put_s32(struct sk_buff *skb, int attrtype, s32 value)
 {
 	return nla_put(skb, attrtype, sizeof(s32), &value);
 }
+#define __nla_put_s32(skb, attrtype, value) nla_put_typed(skb, attrtype, s32, value)
 
 /**
  * nla_put_s64 - Add a s64 netlink attribute to a socket buffer and align it
@@ -946,6 +965,8 @@ static inline int nla_put_s64(struct sk_buff *skb, int attrtype, s64 value,
 {
 	return nla_put_64bit(skb, attrtype, sizeof(s64), &value, padattr);
 }
+#define __nla_put_s64_64bit(skb, attrtype, value, padattr) \
+		nla_put_typed_64bit(skb, attrtype, s64, value, padattr)
 
 /**
  * nla_put_string - Add a string netlink attribute to a socket buffer
@@ -996,6 +1017,7 @@ static inline int nla_put_in_addr(struct sk_buff *skb, int attrtype,
 {
 	return nla_put_be32(skb, attrtype, addr);
 }
+#define __nla_put_in_addr(skb, attrtype, value) nla_put_typed(skb, attrtype, __be32, value)
 
 /**
  * nla_put_in6_addr - Add an IPv6 address netlink attribute to a socket
diff --git a/lib/nlattr.c b/lib/nlattr.c
index b42b857..2988b08 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -548,6 +548,24 @@ int nla_put(struct sk_buff *skb, int attrtype, int attrlen, const void *data)
 }
 EXPORT_SYMBOL(nla_put);
 
+int nla_put_u8(struct sk_buff *skb, int attrtype, u8 value)
+{
+	return nla_put(skb, attrtype, sizeof(u8), &value);
+}
+EXPORT_SYMBOL(nla_put_u8);
+
+int nla_put_u16(struct sk_buff *skb, int attrtype, u16 value)
+{
+	return nla_put(skb, attrtype, sizeof(u16), &value);
+}
+EXPORT_SYMBOL(nla_put_u16);
+
+int nla_put_u32(struct sk_buff *skb, int attrtype, u32 value)
+{
+	return nla_put(skb, attrtype, sizeof(u32), &value);
+}
+EXPORT_SYMBOL(nla_put_u32);
+
 /**
  * nla_put_64bit - Add a netlink attribute to a socket buffer and align it
  * @skb: socket buffer to add attribute to
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 3aee94b..57a2929 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -671,15 +671,15 @@ static int nl80211_msg_put_channel(struct sk_buff *msg,
 
 			time = elapsed_jiffies_msecs(chan->dfs_state_entered);
 
-			if (nla_put_u32(msg, NL80211_FREQUENCY_ATTR_DFS_STATE,
-					chan->dfs_state))
+			if (nla_put_typed(msg, NL80211_FREQUENCY_ATTR_DFS_STATE,
+					  u32, chan->dfs_state))
 				goto nla_put_failure;
-			if (nla_put_u32(msg, NL80211_FREQUENCY_ATTR_DFS_TIME,
-					time))
+			if (nla_put_typed(msg, NL80211_FREQUENCY_ATTR_DFS_TIME,
+					  u32, time))
 				goto nla_put_failure;
-			if (nla_put_u32(msg,
-					NL80211_FREQUENCY_ATTR_DFS_CAC_TIME,
-					chan->dfs_cac_ms))
+			if (nla_put_typed(msg,
+					  NL80211_FREQUENCY_ATTR_DFS_CAC_TIME,
+					  u32,chan->dfs_cac_ms))
 				goto nla_put_failure;
 		}
 	}
@@ -1327,9 +1327,10 @@ nl80211_send_mgmt_stypes(struct sk_buff *msg,
 
 #define CMD(op, n)							\
 	 do {								\
+		data = NL80211_CMD_ ## n;				\
 		if (rdev->ops->op) {					\
 			i++;						\
-			if (nla_put_u32(msg, i, NL80211_CMD_ ## n)) 	\
+			if (__nla_put_u32(msg, i, data)) 		\
 				goto nla_put_failure;			\
 		}							\
 	} while (0)
@@ -1338,6 +1339,7 @@ static int nl80211_add_commands_unsplit(struct cfg80211_registered_device *rdev,
 					struct sk_buff *msg)
 {
 	int i = 0;
+	u32 data;
 
 	/*
 	 * do *NOT* add anything into this function, new things need to be
@@ -1444,10 +1446,10 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 	if (WARN_ON(!state))
 		return -EINVAL;
 
-	if (nla_put_u32(msg, NL80211_ATTR_WIPHY, rdev->wiphy_idx) ||
+	if (__nla_put_s32(msg, NL80211_ATTR_WIPHY, rdev->wiphy_idx) ||
 	    nla_put_string(msg, NL80211_ATTR_WIPHY_NAME,
 			   wiphy_name(&rdev->wiphy)) ||
-	    nla_put_u32(msg, NL80211_ATTR_GENERATION,
+	    __nla_put_s32(msg, NL80211_ATTR_GENERATION,
 			cfg80211_rdev_list_generation))
 		goto nla_put_failure;
 
@@ -1456,32 +1458,32 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 
 	switch (state->split_start) {
 	case 0:
-		if (nla_put_u8(msg, NL80211_ATTR_WIPHY_RETRY_SHORT,
-			       rdev->wiphy.retry_short) ||
-		    nla_put_u8(msg, NL80211_ATTR_WIPHY_RETRY_LONG,
-			       rdev->wiphy.retry_long) ||
-		    nla_put_u32(msg, NL80211_ATTR_WIPHY_FRAG_THRESHOLD,
-				rdev->wiphy.frag_threshold) ||
-		    nla_put_u32(msg, NL80211_ATTR_WIPHY_RTS_THRESHOLD,
-				rdev->wiphy.rts_threshold) ||
-		    nla_put_u8(msg, NL80211_ATTR_WIPHY_COVERAGE_CLASS,
-			       rdev->wiphy.coverage_class) ||
-		    nla_put_u8(msg, NL80211_ATTR_MAX_NUM_SCAN_SSIDS,
-			       rdev->wiphy.max_scan_ssids) ||
-		    nla_put_u8(msg, NL80211_ATTR_MAX_NUM_SCHED_SCAN_SSIDS,
-			       rdev->wiphy.max_sched_scan_ssids) ||
-		    nla_put_u16(msg, NL80211_ATTR_MAX_SCAN_IE_LEN,
-				rdev->wiphy.max_scan_ie_len) ||
-		    nla_put_u16(msg, NL80211_ATTR_MAX_SCHED_SCAN_IE_LEN,
-				rdev->wiphy.max_sched_scan_ie_len) ||
-		    nla_put_u8(msg, NL80211_ATTR_MAX_MATCH_SETS,
-			       rdev->wiphy.max_match_sets) ||
-		    nla_put_u32(msg, NL80211_ATTR_MAX_NUM_SCHED_SCAN_PLANS,
-				rdev->wiphy.max_sched_scan_plans) ||
-		    nla_put_u32(msg, NL80211_ATTR_MAX_SCAN_PLAN_INTERVAL,
-				rdev->wiphy.max_sched_scan_plan_interval) ||
-		    nla_put_u32(msg, NL80211_ATTR_MAX_SCAN_PLAN_ITERATIONS,
-				rdev->wiphy.max_sched_scan_plan_iterations))
+		if (nla_put_typed(msg, NL80211_ATTR_WIPHY_RETRY_SHORT,
+				  u8, rdev->wiphy.retry_short) ||
+		    nla_put_typed(msg, NL80211_ATTR_WIPHY_RETRY_LONG,
+				  u8, rdev->wiphy.retry_long) ||
+		    nla_put_typed(msg, NL80211_ATTR_WIPHY_FRAG_THRESHOLD,
+				  u32, rdev->wiphy.frag_threshold) ||
+		    nla_put_typed(msg, NL80211_ATTR_WIPHY_RTS_THRESHOLD,
+				  u32, rdev->wiphy.rts_threshold) ||
+		    nla_put_typed(msg, NL80211_ATTR_WIPHY_COVERAGE_CLASS,
+				  u8, rdev->wiphy.coverage_class) ||
+		    nla_put_typed(msg, NL80211_ATTR_MAX_NUM_SCAN_SSIDS,
+				  u8, rdev->wiphy.max_scan_ssids) ||
+		    nla_put_typed(msg, NL80211_ATTR_MAX_NUM_SCHED_SCAN_SSIDS,
+				  u8, rdev->wiphy.max_sched_scan_ssids) ||
+		    nla_put_typed(msg, NL80211_ATTR_MAX_SCAN_IE_LEN,
+				  u16, rdev->wiphy.max_scan_ie_len) ||
+		    nla_put_typed(msg, NL80211_ATTR_MAX_SCHED_SCAN_IE_LEN,
+				  u16, rdev->wiphy.max_sched_scan_ie_len) ||
+		    nla_put_typed(msg, NL80211_ATTR_MAX_MATCH_SETS,
+				  u8, rdev->wiphy.max_match_sets) ||
+		    nla_put_typed(msg, NL80211_ATTR_MAX_NUM_SCHED_SCAN_PLANS,
+				  u32, rdev->wiphy.max_sched_scan_plans) ||
+		    nla_put_typed(msg, NL80211_ATTR_MAX_SCAN_PLAN_INTERVAL,
+				  u32, rdev->wiphy.max_sched_scan_plan_interval) ||
+		    nla_put_typed(msg, NL80211_ATTR_MAX_SCAN_PLAN_ITERATIONS,
+				  u32, rdev->wiphy.max_sched_scan_plan_iterations))
 			goto nla_put_failure;
 
 		if ((rdev->wiphy.flags & WIPHY_FLAG_IBSS_RSN) &&
@@ -1511,22 +1513,22 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 			    rdev->wiphy.cipher_suites))
 			goto nla_put_failure;
 
-		if (nla_put_u8(msg, NL80211_ATTR_MAX_NUM_PMKIDS,
-			       rdev->wiphy.max_num_pmkids))
+		if (nla_put_typed(msg, NL80211_ATTR_MAX_NUM_PMKIDS,
+				  u8, rdev->wiphy.max_num_pmkids))
 			goto nla_put_failure;
 
 		if ((rdev->wiphy.flags & WIPHY_FLAG_CONTROL_PORT_PROTOCOL) &&
 		    nla_put_flag(msg, NL80211_ATTR_CONTROL_PORT_ETHERTYPE))
 			goto nla_put_failure;
 
-		if (nla_put_u32(msg, NL80211_ATTR_WIPHY_ANTENNA_AVAIL_TX,
+		if (__nla_put_u32(msg, NL80211_ATTR_WIPHY_ANTENNA_AVAIL_TX,
 				rdev->wiphy.available_antennas_tx) ||
-		    nla_put_u32(msg, NL80211_ATTR_WIPHY_ANTENNA_AVAIL_RX,
+		    __nla_put_u32(msg, NL80211_ATTR_WIPHY_ANTENNA_AVAIL_RX,
 				rdev->wiphy.available_antennas_rx))
 			goto nla_put_failure;
 
 		if ((rdev->wiphy.flags & WIPHY_FLAG_AP_PROBE_RESP_OFFLOAD) &&
-		    nla_put_u32(msg, NL80211_ATTR_PROBE_RESP_OFFLOAD,
+		    __nla_put_u32(msg, NL80211_ATTR_PROBE_RESP_OFFLOAD,
 				rdev->wiphy.probe_resp_offload))
 			goto nla_put_failure;
 
@@ -1538,10 +1540,10 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 
 			res = rdev_get_antenna(rdev, &tx_ant, &rx_ant);
 			if (!res) {
-				if (nla_put_u32(msg,
+				if (__nla_put_u32(msg,
 						NL80211_ATTR_WIPHY_ANTENNA_TX,
 						tx_ant) ||
-				    nla_put_u32(msg,
+				    __nla_put_u32(msg,
 						NL80211_ATTR_WIPHY_ANTENNA_RX,
 						rx_ant))
 					goto nla_put_failure;
@@ -1645,6 +1647,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 		if (i < 0)
 			goto nla_put_failure;
 		if (state->split) {
+			u32 data;
 			CMD(crit_proto_start, CRIT_PROTOCOL_START);
 			CMD(crit_proto_stop, CRIT_PROTOCOL_STOP);
 			if (rdev->wiphy.flags & WIPHY_FLAG_HAS_CHANNEL_SWITCH)
@@ -1703,7 +1706,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 			break;
 	case 8:
 		if ((rdev->wiphy.flags & WIPHY_FLAG_HAVE_AP_SME) &&
-		    nla_put_u32(msg, NL80211_ATTR_DEVICE_AP_SME,
+		    __nla_put_u32(msg, NL80211_ATTR_DEVICE_AP_SME,
 				rdev->wiphy.ap_sme_capa))
 			goto nla_put_failure;
 
@@ -1715,7 +1718,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 		 */
 		if (state->split)
 			features |= NL80211_FEATURE_ADVERTISE_CHAN_LIMITS;
-		if (nla_put_u32(msg, NL80211_ATTR_FEATURE_FLAGS, features))
+		if (__nla_put_u32(msg, NL80211_ATTR_FEATURE_FLAGS, features))
 			goto nla_put_failure;
 
 		if (rdev->wiphy.ht_capa_mod_mask &&
@@ -1813,7 +1816,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 		break;
 	case 12:
 		if (rdev->wiphy.flags & WIPHY_FLAG_HAS_CHANNEL_SWITCH &&
-		    nla_put_u8(msg, NL80211_ATTR_MAX_CSA_COUNTERS,
+		    __nla_put_u8(msg, NL80211_ATTR_MAX_CSA_COUNTERS,
 			       rdev->wiphy.max_num_csa_counters))
 			goto nla_put_failure;
 
@@ -1865,7 +1868,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 
 				nested_ext_capab = nla_nest_start(msg, i);
 				if (!nested_ext_capab ||
-				    nla_put_u32(msg, NL80211_ATTR_IFTYPE,
+				    __nla_put_u32(msg, NL80211_ATTR_IFTYPE,
 						capab->iftype) ||
 				    nla_put(msg, NL80211_ATTR_EXT_CAPA,
 					    capab->extended_capabilities_len,
@@ -2521,12 +2524,12 @@ static int nl80211_send_chandef(struct sk_buff *msg,
 	default:
 		break;
 	}
-	if (nla_put_u32(msg, NL80211_ATTR_CHANNEL_WIDTH, chandef->width))
+	if (__nla_put_u32(msg, NL80211_ATTR_CHANNEL_WIDTH, chandef->width))
 		return -ENOBUFS;
-	if (nla_put_u32(msg, NL80211_ATTR_CENTER_FREQ1, chandef->center_freq1))
+	if (__nla_put_u32(msg, NL80211_ATTR_CENTER_FREQ1, chandef->center_freq1))
 		return -ENOBUFS;
 	if (chandef->center_freq2 &&
-	    nla_put_u32(msg, NL80211_ATTR_CENTER_FREQ2, chandef->center_freq2))
+	    __nla_put_u32(msg, NL80211_ATTR_CENTER_FREQ2, chandef->center_freq2))
 		return -ENOBUFS;
 	return 0;
 }
@@ -2547,12 +2550,12 @@ static int nl80211_send_iface(struct sk_buff *msg, u32 portid, u32 seq, int flag
 		return -1;
 
 	if (dev &&
-	    (nla_put_u32(msg, NL80211_ATTR_IFINDEX, dev->ifindex) ||
+	    (__nla_put_s32(msg, NL80211_ATTR_IFINDEX, dev->ifindex) ||
 	     nla_put_string(msg, NL80211_ATTR_IFNAME, dev->name)))
 		goto nla_put_failure;
 
-	if (nla_put_u32(msg, NL80211_ATTR_WIPHY, rdev->wiphy_idx) ||
-	    nla_put_u32(msg, NL80211_ATTR_IFTYPE, wdev->iftype) ||
+	if (__nla_put_s32(msg, NL80211_ATTR_WIPHY, rdev->wiphy_idx) ||
+	    __nla_put_u32(msg, NL80211_ATTR_IFTYPE, wdev->iftype) ||
 	    nla_put_u64_64bit(msg, NL80211_ATTR_WDEV, wdev_id(wdev),
 			      NL80211_ATTR_PAD) ||
 	    nla_put(msg, NL80211_ATTR_MAC, ETH_ALEN, wdev_address(wdev)) ||
@@ -4231,13 +4234,13 @@ static int nl80211_send_station(struct sk_buff *msg, u32 cmd, u32 portid,
 #define PUT_SINFO(attr, memb, type) do {				\
 	BUILD_BUG_ON(sizeof(type) == sizeof(u64));			\
 	if (sinfo->filled & (1ULL << NL80211_STA_INFO_ ## attr) &&	\
-	    nla_put_ ## type(msg, NL80211_STA_INFO_ ## attr,		\
+	    __nla_put_ ## type(msg, NL80211_STA_INFO_ ## attr,		\
 			     sinfo->memb))				\
 		goto nla_put_failure;					\
 	} while (0)
-#define PUT_SINFO_U64(attr, memb) do {					\
+#define PUT_SINFO_64(attr, memb, type) do {				\
 	if (sinfo->filled & (1ULL << NL80211_STA_INFO_ ## attr) &&	\
-	    nla_put_u64_64bit(msg, NL80211_STA_INFO_ ## attr,		\
+	    __nla_put_ ## type ## _64bit(msg, NL80211_STA_INFO_ ## attr,\
 			      sinfo->memb, NL80211_STA_INFO_PAD))	\
 		goto nla_put_failure;					\
 	} while (0)
@@ -4257,17 +4260,17 @@ static int nl80211_send_station(struct sk_buff *msg, u32 cmd, u32 portid,
 			(u32)sinfo->tx_bytes))
 		goto nla_put_failure;
 
-	PUT_SINFO_U64(RX_BYTES64, rx_bytes);
-	PUT_SINFO_U64(TX_BYTES64, tx_bytes);
+	PUT_SINFO_64(RX_BYTES64, rx_bytes, u64);
+	PUT_SINFO_64(TX_BYTES64, tx_bytes, u64);
 	PUT_SINFO(LLID, llid, u16);
 	PUT_SINFO(PLID, plid, u16);
 	PUT_SINFO(PLINK_STATE, plink_state, u8);
-	PUT_SINFO_U64(RX_DURATION, rx_duration);
+	PUT_SINFO_64(RX_DURATION, rx_duration, u64);
 
 	switch (rdev->wiphy.signal_type) {
 	case CFG80211_SIGNAL_TYPE_MBM:
-		PUT_SINFO(SIGNAL, signal, u8);
-		PUT_SINFO(SIGNAL_AVG, signal_avg, u8);
+		PUT_SINFO(SIGNAL, signal, s8);
+		PUT_SINFO(SIGNAL_AVG, signal_avg, s8);
 		break;
 	default:
 		break;
@@ -4330,9 +4333,13 @@ static int nl80211_send_station(struct sk_buff *msg, u32 cmd, u32 portid,
 		    &sinfo->sta_flags))
 		goto nla_put_failure;
 
-	PUT_SINFO_U64(T_OFFSET, t_offset);
-	PUT_SINFO_U64(RX_DROP_MISC, rx_dropped_misc);
-	PUT_SINFO_U64(BEACON_RX, rx_beacon);
+	PUT_SINFO_64(T_OFFSET, t_offset, s64);
+	if (sinfo->filled & (1ULL << NL80211_STA_INFO_RX_DROP_MISC) &&
+	    nla_put_u64_64bit(msg, NL80211_STA_INFO_RX_DROP_MISC,
+			      sinfo->rx_dropped_misc, NL80211_STA_INFO_PAD))
+		goto nla_put_failure;
+
+	PUT_SINFO_64(BEACON_RX, rx_beacon, u64);
 	PUT_SINFO(BEACON_SIGNAL_AVG, rx_beacon_signal_avg, u8);
 
 #undef PUT_SINFO
@@ -5624,42 +5631,42 @@ static int nl80211_get_mesh_config(struct sk_buff *skb,
 	pinfoattr = nla_nest_start(msg, NL80211_ATTR_MESH_CONFIG);
 	if (!pinfoattr)
 		goto nla_put_failure;
-	if (nla_put_u32(msg, NL80211_ATTR_IFINDEX, dev->ifindex) ||
-	    nla_put_u16(msg, NL80211_MESHCONF_RETRY_TIMEOUT,
+	if (nla_put_typed(msg, NL80211_ATTR_IFINDEX, int, dev->ifindex) ||
+	    nla_put_typed(msg, NL80211_MESHCONF_RETRY_TIMEOUT, u16,
 			cur_params.dot11MeshRetryTimeout) ||
-	    nla_put_u16(msg, NL80211_MESHCONF_CONFIRM_TIMEOUT,
+	    nla_put_typed(msg, NL80211_MESHCONF_CONFIRM_TIMEOUT, u16,
 			cur_params.dot11MeshConfirmTimeout) ||
-	    nla_put_u16(msg, NL80211_MESHCONF_HOLDING_TIMEOUT,
+	    nla_put_typed(msg, NL80211_MESHCONF_HOLDING_TIMEOUT, u16,
 			cur_params.dot11MeshHoldingTimeout) ||
-	    nla_put_u16(msg, NL80211_MESHCONF_MAX_PEER_LINKS,
+	    nla_put_typed(msg, NL80211_MESHCONF_MAX_PEER_LINKS, u16,
 			cur_params.dot11MeshMaxPeerLinks) ||
-	    nla_put_u8(msg, NL80211_MESHCONF_MAX_RETRIES,
+	    nla_put_typed(msg, NL80211_MESHCONF_MAX_RETRIES, u8,
 		       cur_params.dot11MeshMaxRetries) ||
-	    nla_put_u8(msg, NL80211_MESHCONF_TTL,
+	    nla_put_typed(msg, NL80211_MESHCONF_TTL, u8,
 		       cur_params.dot11MeshTTL) ||
-	    nla_put_u8(msg, NL80211_MESHCONF_ELEMENT_TTL,
+	    nla_put_typed(msg, NL80211_MESHCONF_ELEMENT_TTL, u8,
 		       cur_params.element_ttl) ||
 	    nla_put_u8(msg, NL80211_MESHCONF_AUTO_OPEN_PLINKS,
 		       cur_params.auto_open_plinks) ||
-	    nla_put_u32(msg, NL80211_MESHCONF_SYNC_OFFSET_MAX_NEIGHBOR,
+	    nla_put_typed(msg, NL80211_MESHCONF_SYNC_OFFSET_MAX_NEIGHBOR, u32,
 			cur_params.dot11MeshNbrOffsetMaxNeighbor) ||
-	    nla_put_u8(msg, NL80211_MESHCONF_HWMP_MAX_PREQ_RETRIES,
+	    nla_put_typed(msg, NL80211_MESHCONF_HWMP_MAX_PREQ_RETRIES, u8,
 		       cur_params.dot11MeshHWMPmaxPREQretries) ||
-	    nla_put_u32(msg, NL80211_MESHCONF_PATH_REFRESH_TIME,
+	    nla_put_typed(msg, NL80211_MESHCONF_PATH_REFRESH_TIME, u32,
 			cur_params.path_refresh_time) ||
-	    nla_put_u16(msg, NL80211_MESHCONF_MIN_DISCOVERY_TIMEOUT,
+	    nla_put_typed(msg, NL80211_MESHCONF_MIN_DISCOVERY_TIMEOUT, u16,
 			cur_params.min_discovery_timeout) ||
-	    nla_put_u32(msg, NL80211_MESHCONF_HWMP_ACTIVE_PATH_TIMEOUT,
+	    nla_put_typed(msg, NL80211_MESHCONF_HWMP_ACTIVE_PATH_TIMEOUT, u32,
 			cur_params.dot11MeshHWMPactivePathTimeout) ||
-	    nla_put_u16(msg, NL80211_MESHCONF_HWMP_PREQ_MIN_INTERVAL,
+	    nla_put_typed(msg, NL80211_MESHCONF_HWMP_PREQ_MIN_INTERVAL, u16,
 			cur_params.dot11MeshHWMPpreqMinInterval) ||
-	    nla_put_u16(msg, NL80211_MESHCONF_HWMP_PERR_MIN_INTERVAL,
+	    nla_put_typed(msg, NL80211_MESHCONF_HWMP_PERR_MIN_INTERVAL, u16,
 			cur_params.dot11MeshHWMPperrMinInterval) ||
-	    nla_put_u16(msg, NL80211_MESHCONF_HWMP_NET_DIAM_TRVS_TIME,
+	    nla_put_typed(msg, NL80211_MESHCONF_HWMP_NET_DIAM_TRVS_TIME, u16,
 			cur_params.dot11MeshHWMPnetDiameterTraversalTime) ||
-	    nla_put_u8(msg, NL80211_MESHCONF_HWMP_ROOTMODE,
+	    nla_put_typed(msg, NL80211_MESHCONF_HWMP_ROOTMODE, u8,
 		       cur_params.dot11MeshHWMPRootMode) ||
-	    nla_put_u16(msg, NL80211_MESHCONF_HWMP_RANN_INTERVAL,
+	    nla_put_typed(msg, NL80211_MESHCONF_HWMP_RANN_INTERVAL, u16,
 			cur_params.dot11MeshHWMPRannInterval) ||
 	    nla_put_u8(msg, NL80211_MESHCONF_GATE_ANNOUNCEMENTS,
 		       cur_params.dot11MeshGateAnnouncementProtocol) ||
@@ -5669,17 +5676,17 @@ static int nl80211_get_mesh_config(struct sk_buff *skb,
 			cur_params.rssi_threshold) ||
 	    nla_put_u32(msg, NL80211_MESHCONF_HT_OPMODE,
 			cur_params.ht_opmode) ||
-	    nla_put_u32(msg, NL80211_MESHCONF_HWMP_PATH_TO_ROOT_TIMEOUT,
+	    nla_put_typed(msg, NL80211_MESHCONF_HWMP_PATH_TO_ROOT_TIMEOUT, u32,
 			cur_params.dot11MeshHWMPactivePathToRootTimeout) ||
-	    nla_put_u16(msg, NL80211_MESHCONF_HWMP_ROOT_INTERVAL,
+	    nla_put_typed(msg, NL80211_MESHCONF_HWMP_ROOT_INTERVAL, u16,
 			cur_params.dot11MeshHWMProotInterval) ||
-	    nla_put_u16(msg, NL80211_MESHCONF_HWMP_CONFIRMATION_INTERVAL,
+	    nla_put_typed(msg, NL80211_MESHCONF_HWMP_CONFIRMATION_INTERVAL, u16,
 			cur_params.dot11MeshHWMPconfirmationInterval) ||
-	    nla_put_u32(msg, NL80211_MESHCONF_POWER_MODE,
+	    nla_put_typed(msg, NL80211_MESHCONF_POWER_MODE, u32,
 			cur_params.power_mode) ||
-	    nla_put_u16(msg, NL80211_MESHCONF_AWAKE_WINDOW,
+	    nla_put_typed(msg, NL80211_MESHCONF_AWAKE_WINDOW, u16,
 			cur_params.dot11MeshAwakeWindowDuration) ||
-	    nla_put_u32(msg, NL80211_MESHCONF_PLINK_TIMEOUT,
+	    nla_put_typed(msg, NL80211_MESHCONF_PLINK_TIMEOUT, u32,
 			cur_params.plink_timeout))
 		goto nla_put_failure;
 	nla_nest_end(msg, pinfoattr);
