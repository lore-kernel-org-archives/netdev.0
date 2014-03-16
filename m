From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: sched: use no more than one page in struct
 fw_head
Date: Sun, 16 Mar 2014 09:06:30 -0700
Message-ID: <1394985990.9668.26.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53208E3F.5090401@gmail.com>
	 <1394643673.21721.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140313202245.GK21124@linux.vnet.ibm.com>
	 <1394744203.21721.53.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140313211509.GP21124@linux.vnet.ibm.com> <53229704.1040808@gmail.com>
	 <20140314132834.GS21124@linux.vnet.ibm.com>
	 <1394804798.21721.64.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140314153810.GX21124@linux.vnet.ibm.com>
	 <20140314185005.GA17041@linux.vnet.ibm.com>
	 <20140314185917.GA18933@linux.vnet.ibm.com>
	 <1394826958.9668.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:41394 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833AbaCPQGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Mar 2014 12:06:32 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so4537014pdj.41
        for <netdev@vger.kernel.org>; Sun, 16 Mar 2014 09:06:32 -0700 (PDT)
In-Reply-To: <1394826958.9668.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit b4e9b520ca5d ("[NET_SCHED]: Add mask support to fwmark
classifier") Patrick added an u32 field in fw_head, making it slightly
bigger than one page.

Change the layout of this structure and let compiler emit a reciprocal
divide for fw_hash(), as this makes the core more readable and
more efficient those days.

This brings back the memory usage to a single page, and permits John
to add a rcu_head later without any worry.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: John Fastabend <john.fastabend@gmail.com>
---
 net/sched/cls_fw.c |   38 ++++++++++----------------------------
 1 file changed, 10 insertions(+), 28 deletions(-)

diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index a366537f82c6..e054adafe836 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -29,13 +29,16 @@
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
 
-#define HTSIZE (PAGE_SIZE/sizeof(struct fw_filter *))
-
 struct fw_head {
-	struct fw_filter *ht[HTSIZE];
-	u32 mask;
+	u32			mask;
+	struct fw_filter	*ht[0];
 };
 
+#define FW_HEAD_SIZE PAGE_SIZE
+
+#define HTSIZE ((FW_HEAD_SIZE - sizeof(struct fw_head)) /	\
+		sizeof(struct fw_filter *))
+
 struct fw_filter {
 	struct fw_filter	*next;
 	u32			id;
@@ -46,30 +49,9 @@ struct fw_filter {
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
+	return handle % HTSIZE;
 }
 
 static int fw_classify(struct sk_buff *skb, const struct tcf_proto *tp,
@@ -266,7 +248,7 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 		if (tb[TCA_FW_MASK])
 			mask = nla_get_u32(tb[TCA_FW_MASK]);
 
-		head = kzalloc(sizeof(struct fw_head), GFP_KERNEL);
+		head = kzalloc(FW_HEAD_SIZE, GFP_KERNEL);
 		if (head == NULL)
 			return -ENOBUFS;
 		head->mask = mask;
