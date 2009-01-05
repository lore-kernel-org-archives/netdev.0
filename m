From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] Re: [Bugme-new] [Bug 11571] New: u32_classify Kernel Panic
Date: Mon, 5 Jan 2009 13:52:45 +0000
Message-ID: <20090105135245.GC4460@ff.dom.local>
References: <20080917193832.GA2623@ami.dom.local> <48D1FDB8.4040805@plotinka.ru> <20080918075351.GA4633@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:38998 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057AbZAENwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 08:52:54 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1461134ugf.37
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2009 05:52:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080918075351.GA4633@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Thu, Sep 18, 2008 at 01:05:28PM +0600, m0sia wrote:
> ...
> >>>> http://bugzilla.kernel.org/show_bug.cgi?id=11571
...
(take 2)

It seems there could be a problem with testing if this patch fixes
this bug, but IMHO it's quite probable, and needed anyway.

Jarek P.

----------------->
pkt_sched: cls_u32: Fix locking in u32_change()

New nodes are inserted in u32_change() under rtnl_lock() with wmb(),
so without tcf_tree_lock() like in other classifiers (e.g. cls_fw).
This isn't enough without rmb() on the read side, but on the other
hand adding such barriers doesn't give any savings, so the lock is
added instead.

Reported-by: m0sia <m0sia@plotinka.ru>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/cls_u32.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 05d1780..07372f6 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -638,8 +638,9 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 				break;
 
 		n->next = *ins;
-		wmb();
+		tcf_tree_lock(tp);
 		*ins = n;
+		tcf_tree_unlock(tp);
 
 		*arg = (unsigned long)n;
 		return 0;
