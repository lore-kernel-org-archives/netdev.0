From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Sun, 23 Aug 2015 20:33:25 -0700 (PDT)
Message-ID: <20150823.203325.2208394271706147325.davem@davemloft.net>
References: <20150824132111.534ddea7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jbenc@redhat.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150824132111.534ddea7@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 24 Aug 2015 13:21:11 +1000

> After merging the net-next tree, today's linux-next build (arm
> multi_v7_defconfig) failed like this:

Fixed by:

====================
[PATCH] route: fix breakage after moving lwtunnel state

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
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 0a9a723..ef8f1d4 100644
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
2.1.0
