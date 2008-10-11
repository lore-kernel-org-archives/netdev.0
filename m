From: Jarek Poplawski <jarkao2@gmail.com>
Subject: pkt_sched: cls_u32: Fix locking in u32_delete()
Date: Sat, 11 Oct 2008 13:17:11 +0200
Message-ID: <20081011111711.GA2808@ami.dom.local>
References: <20080916091508.a0cd830e.akpm@linux-foundation.org> <20080917193832.GA2623@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	m0sia@plotinka.ru, Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:37728 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862AbYJKLRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 07:17:00 -0400
Received: by ey-out-2122.google.com with SMTP id 6so360463eyi.37
        for <netdev@vger.kernel.org>; Sat, 11 Oct 2008 04:16:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080917193832.GA2623@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pkt_sched: cls_u32: Fix locking in u32_delete()

While looking for a possible reason of bugzilla [Bug 11571]
"u32_classify Kernel Panic" reported by m0sia@plotinka.ru I found that
tcf_tree_lock() is missing in u32_delete() during u32_destroy_hnode()
call. Other paths calling this function use this lock. It haven't been
acknowledged this fixes the bug, but I think this patch is needed here
anyway.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/sched/cls_u32.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 246f906..9912ad5 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -433,7 +433,9 @@ static int u32_delete(struct tcf_proto *tp, unsigned long arg)
 
 	if (ht->refcnt == 1) {
 		ht->refcnt--;
+		tcf_tree_lock(tp);
 		u32_destroy_hnode(tp, ht);
+		tcf_tree_unlock(tp);
 	} else {
 		return -EBUSY;
 	}
