From: Erik Kline <ek@google.com>
Subject: [PATCH net-next] Better handling of transition to NUD_PROBE state
Date: Mon, 18 May 2015 19:44:41 +0900
Message-ID: <1431945881-14707-1-git-send-email-ek@google.com>
Cc: lorenzo@google.com, netdev@vger.kernel.org, davem@davemloft.net,
	Erik Kline <ek@google.com>
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:34322 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988AbbERKo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 06:44:58 -0400
Received: by pdbnk13 with SMTP id nk13so48941956pdb.1
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 03:44:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[1] When entering NUD_PROBE state via neigh_update(), perhaps received
    from userspace, correctly (re)initialize the probes count to zero.

    This is useful for forcing revalidation of a neighbor (for example
    if the host is attempting to do DNA [IPv4 4436, IPv6 6059]).

[2] Notify listeners when a neighbor goes into NUD_PROBE state.

    By sending notifications on entry to NUD_PROBE state listeners get
    more timely warnings of imminent connectivity issues.

    The current notifications on entry to NUD_STALE have somewhat
    limited usefulness: NUD_STALE is a perfectly normal state, as is
    NUD_DELAY, whereas notifications on entry to NUD_FAILURE come after
    a neighbor reachability problem has been confirmed (typically after
    three probes).

Signed-off-by: Erik Kline <ek@google.com>
---
 net/core/neighbour.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 3de6542..3a74df7 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -913,6 +913,7 @@ static void neigh_timer_handler(unsigned long arg)
 			neigh->nud_state = NUD_PROBE;
 			neigh->updated = jiffies;
 			atomic_set(&neigh->probes, 0);
+			notify = 1;
 			next = now + NEIGH_VAR(neigh->parms, RETRANS_TIME);
 		}
 	} else {
@@ -1144,6 +1145,8 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
 
 	if (new != old) {
 		neigh_del_timer(neigh);
+		if (new & NUD_PROBE)
+			atomic_set(&neigh->probes, 0);
 		if (new & NUD_IN_TIMER)
 			neigh_add_timer(neigh, (jiffies +
 						((new & NUD_REACHABLE) ?
-- 
2.2.0.rc0.207.ga3a616c
