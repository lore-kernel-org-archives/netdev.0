From: Ingo Molnar <mingo@elte.hu>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user
	with the same regression
Date: Sat, 23 Aug 2008 17:03:58 +0200
Message-ID: <20080823150358.GA8579@elte.hu>
References: <825188.80277.qm@web82105.mail.mud.yahoo.com> <20080823133643.GA23766@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yinghai Lu <yhlu.kernel@gmail.com>,
	Vivek Goyal <vgoyal@redhat.com>,
	Bill Fink <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: David Witbrodt <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:52322 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751264AbYHWPEe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Aug 2008 11:04:34 -0400
Content-Disposition: inline
In-Reply-To: <20080823133643.GA23766@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> could you try the debug patch below ontop of latest tip/master:

please use the replacement debug patch below. (the previous one was 
buggy, it would likely lock up because it iterated incorrectly.)

[ and i'd also like to stress that this isnt a solution, this is a debug
  hack that can lead to a solution. ]

	Ingo

-------------->
>From dc1c9cafd20edacb14e902c5ee72547f14c12545 Mon Sep 17 00:00:00 2001
From: Ingo Molnar <mingo@elte.hu>
Date: Sat, 23 Aug 2008 15:33:51 +0200
Subject: [PATCH] debug: ignore resource conflicts

---
 kernel/resource.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/kernel/resource.c b/kernel/resource.c
index f5b518e..45877ec 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -156,15 +156,19 @@ static struct resource * __request_resource(struct resource *root, struct resour
 	for (;;) {
 		tmp = *p;
 		if (!tmp || tmp->start > end) {
+insert:
 			new->sibling = tmp;
 			*p = new;
 			new->parent = root;
 			return NULL;
 		}
-		p = &tmp->sibling;
-		if (tmp->end < start)
+		if (tmp->end < start) {
+			p = &tmp->sibling;
 			continue;
-		return tmp;
+		}
+		printk("ignoring resource conflict between %s/{%p..%p} and %s/{%p..%p}\n", new->name, (void *)new->start, (void *)new->end, tmp->name, (void *)tmp->start, (void *)tmp->end);
+		WARN_ON(1);
+		goto insert;
 	}
 }
 
