From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] netlink: move nla_put_{u8,u16,u32} out of line
Date: Wed,  8 Feb 2017 22:18:26 +0100
Message-ID: <20170208211843.2822208-1-arnd@arndb.de>
Cc: David Laight <David.Laight@aculab.com>, netdev@vger.kernel.org,
        johannes.berg@intel.com, Arnd Bergmann <arnd@arndb.de>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Graf <tgraf@suug.ch>,
        Eric Dumazet <edumazet@google.com>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.75]:53820 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751338AbdBHV2I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 16:28:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_KASAN is enabled, the "--param asan-stack=1" causes rather large
stack frames in some functions. This goes unnoticed normally because
CONFIG_FRAME_WARN is disabled with CONFIG_KASAN by default as of commit
3f181b4d8652 ("lib/Kconfig.debug: disable -Wframe-larger-than warnings with
KASAN=y").

The kernelci.org build bot however has the warning enabled and that led
me to investigate it a little further, as every build produces these warnings:

net/wireless/nl80211.c:4389:1: warning: the frame size of 2240 bytes is larger than 2048 bytes [-Wframe-larger-than=]
net/wireless/nl80211.c:1895:1: warning: the frame size of 3776 bytes is larger than 2048 bytes [-Wframe-larger-than=]
net/wireless/nl80211.c:1410:1: warning: the frame size of 2208 bytes is larger than 2048 bytes [-Wframe-larger-than=]
net/bridge/br_netlink.c:1282:1: warning: the frame size of 2544 bytes is larger than 2048 bytes [-Wframe-larger-than=]

It turns out that there is a relatively simple workaround for the netlink
users that currently use a local variable in order to do the type conversion:
Moving the three functions (for each of the typical sizes) to lib/nlattr.c
avoids using local variables in the caller, which drastically reduces the
stack usage for nl80211 and br_netlink.

It would be good if we could enable the frame size check after that again,
but that should be a separate patch and it requires some more testing
to see which the largest acceptable frame size should be.

Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: kasan-dev@googlegroups.com
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/net/netlink.h | 23 +++++++----------------
 lib/nlattr.c          | 18 ++++++++++++++++++
 2 files changed, 25 insertions(+), 16 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index b239fcd33d80..48b117e80509 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -755,10 +755,7 @@ static inline int nla_parse_nested(struct nlattr *tb[], int maxtype,
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_u8(struct sk_buff *skb, int attrtype, u8 value)
-{
-	return nla_put(skb, attrtype, sizeof(u8), &value);
-}
+extern int nla_put_u8(struct sk_buff *skb, int attrtype, u8 value);
 
 /**
  * nla_put_u16 - Add a u16 netlink attribute to a socket buffer
@@ -766,10 +763,7 @@ static inline int nla_put_u8(struct sk_buff *skb, int attrtype, u8 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_u16(struct sk_buff *skb, int attrtype, u16 value)
-{
-	return nla_put(skb, attrtype, sizeof(u16), &value);
-}
+extern int nla_put_u16(struct sk_buff *skb, int attrtype, u16 value);
 
 /**
  * nla_put_be16 - Add a __be16 netlink attribute to a socket buffer
@@ -779,7 +773,7 @@ static inline int nla_put_u16(struct sk_buff *skb, int attrtype, u16 value)
  */
 static inline int nla_put_be16(struct sk_buff *skb, int attrtype, __be16 value)
 {
-	return nla_put(skb, attrtype, sizeof(__be16), &value);
+	return nla_put_u16(skb, attrtype, (u16 __force)value);
 }
 
 /**
@@ -801,7 +795,7 @@ static inline int nla_put_net16(struct sk_buff *skb, int attrtype, __be16 value)
  */
 static inline int nla_put_le16(struct sk_buff *skb, int attrtype, __le16 value)
 {
-	return nla_put(skb, attrtype, sizeof(__le16), &value);
+	return nla_put_u16(skb, attrtype, (u16 __force)value);
 }
 
 /**
@@ -810,10 +804,7 @@ static inline int nla_put_le16(struct sk_buff *skb, int attrtype, __le16 value)
  * @attrtype: attribute type
  * @value: numeric value
  */
-static inline int nla_put_u32(struct sk_buff *skb, int attrtype, u32 value)
-{
-	return nla_put(skb, attrtype, sizeof(u32), &value);
-}
+int nla_put_u32(struct sk_buff *skb, int attrtype, u32 value);
 
 /**
  * nla_put_be32 - Add a __be32 netlink attribute to a socket buffer
@@ -823,7 +814,7 @@ static inline int nla_put_u32(struct sk_buff *skb, int attrtype, u32 value)
  */
 static inline int nla_put_be32(struct sk_buff *skb, int attrtype, __be32 value)
 {
-	return nla_put(skb, attrtype, sizeof(__be32), &value);
+	return nla_put_u32(skb, attrtype, (u32 __force)value);
 }
 
 /**
@@ -845,7 +836,7 @@ static inline int nla_put_net32(struct sk_buff *skb, int attrtype, __be32 value)
  */
 static inline int nla_put_le32(struct sk_buff *skb, int attrtype, __le32 value)
 {
-	return nla_put(skb, attrtype, sizeof(__le32), &value);
+	return nla_put_u32(skb, attrtype, (u32 __force)value);
 }
 
 /**
diff --git a/lib/nlattr.c b/lib/nlattr.c
index b42b8577fc23..2988b08a7e4d 100644
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
-- 
2.9.0
