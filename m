From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 1560/1566] include/linux/compiler.h:447:38:
 error: call to '__compiletime_assert_459' declared with attribute error:
 BUILD_BUG_ON failed: FLOW_KEYS_HASH_OFFSET % sizeof(u32)
Date: Tue, 01 Sep 2015 16:46:58 -0700 (PDT)
Message-ID: <20150901.164658.1707886923140066882.davem@davemloft.net>
References: <201509020744.JUqgE91v%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, kbuild-all@01.org, netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33243 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbbIAXrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 19:47:02 -0400
In-Reply-To: <201509020744.JUqgE91v%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Wed, 2 Sep 2015 07:19:48 +0800

>    In function 'flow_keys_hash_start',
>        inlined from 'flow_hash_from_keys' at net/core/flow_dissector.c:553:34:
>>> include/linux/compiler.h:447:38: error: call to '__compiletime_assert_459' declared with attribute error: BUILD_BUG_ON failed: FLOW_KEYS_HASH_OFFSET % sizeof(u32)
>      _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)

This is why I hate C bit-fields.

I'll fix this as follows, thanks:

====================
[PATCH] flow_dissector: Don't use bit fields.

Just have a flags member instead.

   In file included from include/linux/linkage.h:4:0,
                    from include/linux/kernel.h:6,
                    from net/core/flow_dissector.c:1:
   In function 'flow_keys_hash_start',
       inlined from 'flow_hash_from_keys' at net/core/flow_dissector.c:553:34:
>> include/linux/compiler.h:447:38: error: call to '__compiletime_assert_459' declared with attribute error: BUILD_BUG_ON failed: FLOW_KEYS_HASH_OFFSET % sizeof(u32)

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/flow_dissector.h |  8 +++++---
 net/core/flow_dissector.c    | 14 +++++++-------
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index bddd108..8c8548c 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -12,11 +12,13 @@
 struct flow_dissector_key_control {
 	u16	thoff;
 	u16	addr_type;
-	u32	is_fragment:1;
-	u32	first_frag:1;
-	u32	encapsulation:1;
+	u32	flags;
 };
 
+#define FLOW_DIS_IS_FRAGMENT	BIT(0)
+#define FLOW_DIS_FIRST_FRAG	BIT(1)
+#define FLOW_DIS_ENCAPSULATION	BIT(2)
+
 /**
  * struct flow_dissector_key_basic:
  * @thoff: Transport header offset
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index b5633394..8d32020 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -189,12 +189,12 @@ ip:
 		key_control->addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
 
 		if (ip_is_fragment(iph)) {
-			key_control->is_fragment = 1;
+			key_control->flags |= FLOW_DIS_IS_FRAGMENT;
 
 			if (iph->frag_off & htons(IP_OFFSET)) {
 				goto out_good;
 			} else {
-				key_control->first_frag = 1;
+				key_control->flags |= FLOW_DIS_FIRST_FRAG;
 				if (!(flags & FLOW_DISSECTOR_F_PARSE_1ST_FRAG))
 					goto out_good;
 			}
@@ -398,7 +398,7 @@ ip_proto_again:
 			nhoff += sizeof(*eth);
 		}
 
-		key_control->encapsulation = 1;
+		key_control->flags |= FLOW_DIS_ENCAPSULATION;
 		if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
 			goto out_good;
 
@@ -434,12 +434,12 @@ ip_proto_again:
 		if (!fh)
 			goto out_bad;
 
-		key_control->is_fragment = 1;
+		key_control->flags |= FLOW_DIS_IS_FRAGMENT;
 
 		nhoff += sizeof(_fh);
 
 		if (!(fh->frag_off & htons(IP6_OFFSET))) {
-			key_control->first_frag = 1;
+			key_control->flags |= FLOW_DIS_FIRST_FRAG;
 			if (flags & FLOW_DISSECTOR_F_PARSE_1ST_FRAG) {
 				ip_proto = fh->nexthdr;
 				goto ip_proto_again;
@@ -450,7 +450,7 @@ ip_proto_again:
 	case IPPROTO_IPIP:
 		proto = htons(ETH_P_IP);
 
-		key_control->encapsulation = 1;
+		key_control->flags |= FLOW_DIS_ENCAPSULATION;
 		if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
 			goto out_good;
 
@@ -458,7 +458,7 @@ ip_proto_again:
 	case IPPROTO_IPV6:
 		proto = htons(ETH_P_IPV6);
 
-		key_control->encapsulation = 1;
+		key_control->flags |= FLOW_DIS_ENCAPSULATION;
 		if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
 			goto out_good;
 
-- 
2.1.0
