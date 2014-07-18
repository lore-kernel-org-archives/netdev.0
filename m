From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net_sched: avoid generating same handle for u32 filters
Date: Thu, 17 Jul 2014 17:34:53 -0700
Message-ID: <1405643693-4880-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <cwang@twopensource.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:60170 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758455AbaGRAfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 20:35:00 -0400
Received: by mail-pd0-f171.google.com with SMTP id z10so4020778pdj.30
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 17:34:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

When kernel generates a handle for a u32 filter, it tries to start
from the max in the bucket. So when we have a filter with the max (fff)
handle, it will cause kernel always generates the same handle for new
filters. This can be shown by the following command:

	tc qdisc add dev eth0 ingress
	tc filter add dev eth0 parent ffff: protocol ip pref 770 handle 800::fff u32 match ip protocol 1 0xff
	tc filter add dev eth0 parent ffff: protocol ip pref 770 u32 match ip protocol 1 0xff
	...

we will get some u32 filters with same handle:

 # tc filter show dev eth0 parent ffff:
filter protocol ip pref 770 u32 
filter protocol ip pref 770 u32 fh 800: ht divisor 1 
filter protocol ip pref 770 u32 fh 800::fff order 4095 key ht 800 bkt 0 
  match 00010000/00ff0000 at 8
filter protocol ip pref 770 u32 fh 800::fff order 4095 key ht 800 bkt 0 
  match 00010000/00ff0000 at 8
filter protocol ip pref 770 u32 fh 800::fff order 4095 key ht 800 bkt 0 
  match 00010000/00ff0000 at 8
filter protocol ip pref 770 u32 fh 800::fff order 4095 key ht 800 bkt 0 
  match 00010000/00ff0000 at 8

handles should be unique. This patch fixes it by looking up a bitmap,
so that can guarantee the handle is as unique as possible. For compatibility,
we still start from 0x800.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index c39b583..70c0be8 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -38,6 +38,7 @@
 #include <linux/errno.h>
 #include <linux/rtnetlink.h>
 #include <linux/skbuff.h>
+#include <linux/bitmap.h>
 #include <net/netlink.h>
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
@@ -460,17 +461,25 @@ static int u32_delete(struct tcf_proto *tp, unsigned long arg)
 	return 0;
 }
 
+#define NR_U32_NODE (1<<12)
 static u32 gen_new_kid(struct tc_u_hnode *ht, u32 handle)
 {
 	struct tc_u_knode *n;
-	unsigned int i = 0x7FF;
+	unsigned long i;
+	unsigned long *bitmap = kzalloc(BITS_TO_LONGS(NR_U32_NODE) * sizeof(unsigned long),
+					GFP_KERNEL);
+	if (!bitmap)
+		return handle | 0xFFF;
 
 	for (n = ht->ht[TC_U32_HASH(handle)]; n; n = n->next)
-		if (i < TC_U32_NODE(n->handle))
-			i = TC_U32_NODE(n->handle);
-	i++;
+		set_bit(TC_U32_NODE(n->handle), bitmap);
 
-	return handle | (i > 0xFFF ? 0xFFF : i);
+	i = find_next_zero_bit(bitmap, NR_U32_NODE, 0x800);
+	if (i >= NR_U32_NODE)
+		i = find_next_zero_bit(bitmap, NR_U32_NODE, 1);
+
+	kfree(bitmap);
+	return handle | (i >= NR_U32_NODE ? 0xFFF : i);
 }
 
 static const struct nla_policy u32_policy[TCA_U32_MAX + 1] = {
