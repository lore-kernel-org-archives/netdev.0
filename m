From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: force dst_default_metrics to const section
Date: Tue, 07 Aug 2012 22:55:45 +0200
Message-ID: <1344372945.28967.165.camel@edumazet-glaptop>
References: <1344355878.28967.113.camel@edumazet-glaptop>
	 <1344370527.2688.61.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:54530 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754808Ab2HGUzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 16:55:51 -0400
Received: by wibhr14 with SMTP id hr14so43409wib.1
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 13:55:50 -0700 (PDT)
In-Reply-To: <1344370527.2688.61.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>


> Some day the compiler may be smart enough to ignore the different
> between explicit and implicit zero-initialisation, and put it back in
> BSS.  Declaring this __cache_aligned_in_smp might be a better option.

__cache_aligned_in_smp aligns start of the structure, but can be
followed by another var in same cache line. Yes, this is bad.

By the way we dont care of cache alignment on this structure, only it
should be const. Its a soft requirement, machine wont crash if it is not
the case.

If compiler is smart one day as you say (it should first be non buggy
IMHO), then we can add a non zero field like this :

Thanks

[PATCH v2] net: force dst_default_metrics to const section

While investigating on network performance problems, I found this little
gem :

$ nm -v vmlinux | grep -1 dst_default_metrics
ffffffff82736540 b busy.46605 
ffffffff82736560 B dst_default_metrics
ffffffff82736598 b dst_busy_list

Apparently, declaring a const array without initializer put it in
(writeable) bss section, in middle of possibly often dirtied cache
lines.

Since we really want dst_default_metrics be const to avoid any possible
false sharing and catch any buggy writes, I force a null initializer.

ffffffff818a4c20 R dst_default_metrics

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
---
 include/net/dst.h |    2 +-
 net/core/dst.c    |   10 +++++++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index baf5978..621e351 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -110,7 +110,7 @@ struct dst_entry {
 };
 
 extern u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old);
-extern const u32 dst_default_metrics[RTAX_MAX];
+extern const u32 dst_default_metrics[];
 
 #define DST_METRICS_READ_ONLY	0x1UL
 #define __DST_METRICS_PTR(Y)	\
diff --git a/net/core/dst.c b/net/core/dst.c
index 069d51d..56d6361 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -149,7 +149,15 @@ int dst_discard(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(dst_discard);
 
-const u32 dst_default_metrics[RTAX_MAX];
+const u32 dst_default_metrics[RTAX_MAX + 1] = {
+	/* This initializer is needed to force linker to place this variable
+	 * into const section. Otherwise it might end into bss section.
+	 * We really want to avoid false sharing on this variable, and catch
+	 * any writes on it.
+	 */
+	[RTAX_MAX] = 0xdeadbeef,
+};
+
 
 void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
 		int initial_ref, int initial_obsolete, unsigned short flags)
