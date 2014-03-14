From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RCU PATCH 06/14] net: sched: fw use RCU
Date: Fri, 14 Mar 2014 12:55:58 -0700
Message-ID: <1394826958.9668.4.camel@edumazet-glaptop2.roam.corp.google.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:50305 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707AbaCNTz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 15:55:57 -0400
Received: by mail-pb0-f51.google.com with SMTP id uo5so3044420pbc.24
        for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 12:55:56 -0700 (PDT)
In-Reply-To: <20140314185917.GA18933@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-14 at 11:59 -0700, Paul E. McKenney wrote:

> Or I could find some other large area of memory that never contains
> functions, for example, the beginning of data or bss (if we still have
> those).  Then check for a range rather than a cutoff.

For the particular cls_fw.c case I think we should just use one page.

Not that I think extending kfree_rcu() range is not useful, do not be
fooled !

This fw_hash() is really complex, gcc can use a reciprocal divide and it
will be even faster...

If John adds a rcu_head, it will simply remove two slots in the hash
table, big deal....


diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index a366537f82c6..6b68f2da6860 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -29,11 +29,12 @@
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
 
-#define HTSIZE (PAGE_SIZE/sizeof(struct fw_filter *))
+
+#define HTSIZE ((PAGE_SIZE - sizeof(u32)) / sizeof(struct fw_filter *))
 
 struct fw_head {
-	struct fw_filter *ht[HTSIZE];
 	u32 mask;
+	struct fw_filter *ht[HTSIZE];
 };
 
 struct fw_filter {
@@ -48,28 +49,7 @@ struct fw_filter {
 
 static inline int fw_hash(u32 handle)
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
