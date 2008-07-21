From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 09:49:49 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0807210942310.31863@woody.linux-foundation.org>
References: <20080720.181440.122144107.davem@davemloft.net> <20080721024056.GA4800@martell.zuzino.mipt.ru> <20080720.194856.92564555.davem@davemloft.net> <20080720.221106.201055562.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: adobriyan@gmail.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42976 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751899AbYGUQtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 12:49:53 -0400
In-Reply-To: <20080720.221106.201055562.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sun, 20 Jul 2008, David Miller wrote:
>
> Alexey, please try this patch:
> 
> atl1: Do not wake queue before queue has been started.

David, can we please make this all a bit less fragile?

There are _millions_ of network drivers, and these changes seem to have 
broken not just common drivers, but also drivers that "work" seem to now 
have broken suspend/resume.

There's at least one report of suspend apparently oopsing now, and I 
assume it's basically the same thing - it was bisected down to that same 
37437bb2e1ae8af470dfcd5b4ff454110894ccaf commit ("pkt_sched: Schedule 
qdiscs instead of netdev_queue.")

Why is it so unnecessarily fragile to begin with? Especially for stuff 
that happens at bootup or suspend, doing a BUG_ON() is _particularly_ 
painful, because a dead machine means that you cannot get any logs or 
anything else.

So wouldn't it be *much* better to do something like the appended, and at 
least try to limp on, and maybe have a system that people can get logs 
out of?

			Linus

---
 net/core/dev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 2eed17b..43ab4f5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1325,7 +1325,8 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 
 void __netif_schedule(struct Qdisc *q)
 {
-	BUG_ON(q == &noop_qdisc);
+	if (WARN_ON_ONCE(q == &noop_qdisc))
+		return;
 
 	if (!test_and_set_bit(__QDISC_STATE_SCHED, &q->state)) {
 		struct softnet_data *sd;
---
