From: Jens Rosenboom <me@jayr.de>
Subject: [RFC] net/core: Delay neighbor only if it has been used after
 confirmed
Date: Wed, 02 Sep 2009 11:17:59 +0200
Message-ID: <1251883079.5813.18.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Linux Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from leia.mcbone.net ([194.97.104.42]:36170 "EHLO leia.mcbone.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750985AbZIBJSJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 05:18:09 -0400
Received: from fnki-ws00028.freenet-ag.de ([194.97.6.48])
	by leia.mcbone.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <me@jayr.de>)
	id 1Milyf-0003rx-Sb
	for netdev@vger.kernel.org; Wed, 02 Sep 2009 09:18:05 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When doing some IPv6 testing with the router advertising a small (e.g. 5
seconds) reachable time, I noticed that after the traffic has stopped,
hosts continue to exchange ND packets every 10 seconds. This is due to
neigh_timer_handler() only checking neigh->used and puts a neighbor into
NUD_DELAY state even if neigh->confirmed may be >= neigh->used.

The following patch for net-next-2.6 fixes this behaviour for my IPv6
setup, however I would like to hear some opinion on whether this might
have some negative influence on other protocols that use this code.

I also think that it would make more sense to compute the time for the
delay timer starting from neigh->used instead of using now (second part
of the patch).

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 5bc4ad5..ca20162 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -820,12 +820,13 @@ static void neigh_timer_handler(unsigned long arg)
 			NEIGH_PRINTK2("neigh %p is still alive.\n", neigh);
 			next = neigh->confirmed + neigh->parms->reachable_time;
 		} else if (time_before_eq(now,
-					  neigh->used + neigh->parms->delay_probe_time)) {
+					  neigh->used + neigh->parms->delay_probe_time) &&
+			   time_after(neigh->confirmed, neigh->used)) {
 			NEIGH_PRINTK2("neigh %p is delayed.\n", neigh);
 			neigh->nud_state = NUD_DELAY;
 			neigh->updated = jiffies;
 			neigh_suspect(neigh);
-			next = now + neigh->parms->delay_probe_time;
+			next = neigh->used + neigh->parms->delay_probe_time;
 		} else {
 			NEIGH_PRINTK2("neigh %p is suspected.\n", neigh);
 			neigh->nud_state = NUD_STALE;





