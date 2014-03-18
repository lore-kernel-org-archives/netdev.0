From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] net: sched: use no more than one page in struct
 fw_head
Date: Mon, 17 Mar 2014 20:20:49 -0700
Message-ID: <1395112849.9114.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140314185917.GA18933@linux.vnet.ibm.com>
	 <1394826958.9668.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1394985990.9668.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140317.223151.719003141867577870.davem@davemloft.net>
	 <1395111761.9114.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:34437 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144AbaCRDUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 23:20:52 -0400
Received: by mail-pb0-f53.google.com with SMTP id rp16so6548608pbb.26
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 20:20:51 -0700 (PDT)
In-Reply-To: <1395111761.9114.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit b4e9b520ca5d ("[NET_SCHED]: Add mask support to fwmark
classifier") Patrick added an u32 field in fw_head, making it slightly
bigger than one page.

Lets use 256 slots to make fw_hash() more straight forward, and move
@mask to the beginning of the structure as we often use a small number
of skb->mark. @mask and first hash buckets share the same cache line.

This brings back the memory usage to less than 4000 bytes, and permits
John to add a rcu_head at the end of the structure later without any
worry.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: John Fastabend <john.fastabend@gmail.com>
---
 net/sched/cls_fw.c |   33 +++++++--------------------------
 1 file changed, 7 insertions(+), 26 deletions(-)

diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index a366537f82c6..63a3ce75c02e 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -29,11 +29,11 @@
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
 
-#define HTSIZE (PAGE_SIZE/sizeof(struct fw_filter *))
+#define HTSIZE 256
 
 struct fw_head {
-	struct fw_filter *ht[HTSIZE];
-	u32 mask;
+	u32			mask;
+	struct fw_filter	*ht[HTSIZE];
 };
 
 struct fw_filter {
@@ -46,30 +46,11 @@ struct fw_filter {
 	struct tcf_exts		exts;
 };
 
-static inline int fw_hash(u32 handle)
+static u32 fw_hash(u32 handle)
 {
-	if (HTSIZE == 4096)
-		return ((handle >> 24) & 0xFFF) ^
-		       ((handle >> 12) & 0xFFF) ^
-		       (handle & 0xFFF);
-	else if (HTSIZE == 2048)
-		return ((handle >> 22) & 0x7FF) ^
-		       ((handle >> 11) & 0x7FF) ^
-		       (handle & 0x7FF);
-	else if (HTSIZE == 1024)
-		return ((handle >> 20) & 0x3FF) ^
-		       ((handle >> 10) & 0x3FF) ^
-		       (handle & 0x3FF);
-	else if (HTSIZE == 512)
-		return (handle >> 27) ^
-		       ((handle >> 18) & 0x1FF) ^
-		       ((handle >> 9) & 0x1FF) ^
-		       (handle & 0x1FF);
-	else if (HTSIZE == 256) {
-		u8 *t = (u8 *) &handle;
-		return t[0] ^ t[1] ^ t[2] ^ t[3];
-	} else
-		return handle & (HTSIZE - 1);
+	handle ^= (handle >> 16);
+	handle ^= (handle >> 8);
+	return handle % HTSIZE;
 }
 
 static int fw_classify(struct sk_buff *skb, const struct tcf_proto *tp,
