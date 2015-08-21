From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] route: fix breakage after moving lwtunnel state
Date: Fri, 21 Aug 2015 12:41:14 +0200
Message-ID: <a80cafb781c91314f90613c3e7d2ed4268eb4f06.1440153500.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44773 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753440AbbHUKlb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2015 06:41:31 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id BC75AA89
	for <netdev@vger.kernel.org>; Fri, 21 Aug 2015 10:41:31 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-116-73.ams2.redhat.com [10.36.116.73])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t7LAfUHh003469
	for <netdev@vger.kernel.org>; Fri, 21 Aug 2015 06:41:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__recnt and related fields need to be in its own cacheline for performance
reasons. Commit 61adedf3e3f1 ("route: move lwtunnel state to dst_entry")
broke that on 32bit archs, causing BUILD_BUG_ON in dst_hold to be triggered.

This patch fixes the breakage by moving the lwtunnel state to the end of
dst_entry on 32bit archs. Unfortunately, this makes it share the cacheline
with __refcnt and may affect performance, thus further patches may be
needed.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Fixes: 61adedf3e3f1 ("route: move lwtunnel state to dst_entry")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
I'm working on this, I'm going to grab performance numbers with this patch
applied and work on follow up patches as necessary. Until then, this patch
at least fixes the 32bit build.

I'm very sorry for the breakage. I tried to build the patchset with various
configs (IPv6 off, lwtunnel off, etc.) but obviously did not test on 32bit.
I have no excuse for this, I should have tested it, the #ifdef was very
obvious.
---
 include/net/dst.h | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 0a9a723f6c19..ef8f1d43a203 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -44,7 +44,6 @@ struct dst_entry {
 #else
 	void			*__pad1;
 #endif
-	struct lwtunnel_state   *lwtstate;
 	int			(*input)(struct sk_buff *);
 	int			(*output)(struct sock *sk, struct sk_buff *skb);
 
@@ -85,11 +84,12 @@ struct dst_entry {
 	__u32			__pad2;
 #endif
 
+#ifdef CONFIG_64BIT
+	struct lwtunnel_state   *lwtstate;
 	/*
 	 * Align __refcnt to a 64 bytes alignment
 	 * (L1_CACHE_SIZE would be too much)
 	 */
-#ifdef CONFIG_64BIT
 	long			__pad_to_align_refcnt[1];
 #endif
 	/*
@@ -99,6 +99,9 @@ struct dst_entry {
 	atomic_t		__refcnt;	/* client references	*/
 	int			__use;
 	unsigned long		lastuse;
+#ifndef CONFIG_64BIT
+	struct lwtunnel_state   *lwtstate;
+#endif
 	union {
 		struct dst_entry	*next;
 		struct rtable __rcu	*rt_next;
-- 
1.8.3.1
