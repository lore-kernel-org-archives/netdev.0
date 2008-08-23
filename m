From: Ingo Molnar <mingo@elte.hu>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user
	with the same regression
Date: Sat, 23 Aug 2008 15:36:43 +0200
Message-ID: <20080823133643.GA23766@elte.hu>
References: <825188.80277.qm@web82105.mail.mud.yahoo.com>
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
Received: from mx2.mail.elte.hu ([157.181.151.9]:51366 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751057AbYHWNhl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Aug 2008 09:37:41 -0400
Content-Disposition: inline
In-Reply-To: <825188.80277.qm@web82105.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David,

could you try the debug patch below ontop of latest tip/master:

  http://people.redhat.com/mingo/tip.git/README

the patch forcibly ignores resource conflicts and reports them. This 
will likely break some system - but if your hpet troubles are due to 
resource conflicts then this patch would make the kernel boot up fine on 
your system by default, with a working hpet.

You should also be getting a printout and a warning in the dmesg in that 
case.

	Ingo

------------>
>From 092990e259a462d39f1d8e9cd542898632b95fde Mon Sep 17 00:00:00 2001
From: Ingo Molnar <mingo@elte.hu>
Date: Sat, 23 Aug 2008 15:33:51 +0200
Subject: [PATCH] debug hack: ignore resource conflicts

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 kernel/resource.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/kernel/resource.c b/kernel/resource.c
index f5b518e..8419d56 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -156,6 +156,7 @@ static struct resource * __request_resource(struct resource *root, struct resour
 	for (;;) {
 		tmp = *p;
 		if (!tmp || tmp->start > end) {
+insert:
 			new->sibling = tmp;
 			*p = new;
 			new->parent = root;
@@ -164,7 +165,9 @@ static struct resource * __request_resource(struct resource *root, struct resour
 		p = &tmp->sibling;
 		if (tmp->end < start)
 			continue;
-		return tmp;
+		printk("ignoring resource conflict between %s/{%p..%p} and %s/{%p..%p}\n", new->name, (void *)new->start, (void *)new->end, tmp->name, (void *)tmp->start, (void *)tmp->end);
+		WARN_ON(1);
+		goto insert;
 	}
 }
 
