From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/2] net: neighbor timer power saving
Date: Tue, 18 Dec 2007 18:18:45 -0800
Message-ID: <20071218181845.2f1b539a@shemminger-laptop>
References: <Pine.LNX.4.64.0712181956180.3616@mini.warudkars.net>
 <20071218174120.4b0ef6dd@shemminger-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: parag.warudkar@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44141 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752986AbXLSCTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 21:19:06 -0500
In-Reply-To: <20071218174120.4b0ef6dd@shemminger-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The neighbor GC timer runs once a second, but it doesn't need to wake
up the machine.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/neighbour.c	2007-12-18 07:46:07.000000000 -0800
+++ b/net/core/neighbour.c	2007-12-18 07:47:36.000000000 -0800
@@ -270,7 +270,7 @@ static struct neighbour *neigh_alloc(str
 	n->nud_state	  = NUD_NONE;
 	n->output	  = neigh_blackhole;
 	n->parms	  = neigh_parms_clone(&tbl->parms);
-	init_timer(&n->timer);
+	init_timer_deferrable(&n->timer);
 	n->timer.function = neigh_timer_handler;
 	n->timer.data	  = (unsigned long)n;
 
@@ -740,7 +740,7 @@ static void neigh_timer_handler(unsigned
 
 	state = neigh->nud_state;
 	now = jiffies;
-	next = now + HZ;
+	next = round_jiffies(now + HZ);
 
 	if (!(state & NUD_IN_TIMER)) {
 #ifndef CONFIG_SMP
@@ -1372,7 +1372,7 @@ void neigh_table_init_no_netlink(struct 
 	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
 
 	rwlock_init(&tbl->lock);
-	init_timer(&tbl->gc_timer);
+	init_timer_deferrable(&tbl->gc_timer);
 	tbl->gc_timer.data     = (unsigned long)tbl;
 	tbl->gc_timer.function = neigh_periodic_timer;
 	tbl->gc_timer.expires  = now + 1;
