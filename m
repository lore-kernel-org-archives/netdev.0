From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH] nf_conntrack: avoid kernel pointer value leak in slab name
Date: Sat, 14 May 2016 11:24:08 -0700 (PDT)
Message-ID: <alpine.LFD.2.20.1605141116100.24646@i7>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Willy Tarreau <w@1wt.eu>,
	Network Development List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36196 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506AbcENSYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 14:24:10 -0400
Received: by mail-pf0-f195.google.com with SMTP id g132so11918695pfb.3
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 11:24:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 14 May 2016 11:11:44 -0700
Subject: [PATCH] nf_conntrack: avoid kernel pointer value leak in slab name

The slab name ends up being visible in the directory structure under
/sys, and even if you don't have access rights to the file you can see
the filenames.

Just use a 64-bit counter instead of the pointer to the 'net' structure
to generate a unique name.

This code will go away in 4.7 when the conntrack code moves to a single
kmemcache, but this is the backportable simple solution to avoiding
leaking kernel pointers to user space.

Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: stable@vger.kernel.org
---

This would seem to be the minimal patch.

Eric - I marked you as "acking" this patch from the discussion. It's not 
actually any of the exact patches that were flying around, but close 
enough..

It's been "tested" by booting and looking at the end result. Seems to 
work, and it's not exactly complicated.

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 895d11dced3c..e27fd17c6743 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1778,6 +1778,7 @@ void nf_conntrack_init_end(void)
 
 int nf_conntrack_init_net(struct net *net)
 {
+	static atomic64_t unique_id;
 	int ret = -ENOMEM;
 	int cpu;
 
@@ -1800,7 +1801,8 @@ int nf_conntrack_init_net(struct net *net)
 	if (!net->ct.stat)
 		goto err_pcpu_lists;
 
-	net->ct.slabname = kasprintf(GFP_KERNEL, "nf_conntrack_%p", net);
+	net->ct.slabname = kasprintf(GFP_KERNEL, "nf_conntrack_%llu",
+				(u64)atomic64_inc_return(&unique_id));
 	if (!net->ct.slabname)
 		goto err_slabname;
 
