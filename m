From: Roland Dreier <roland@kernel.org>
Subject: [PATCH/RFC] ipv6: fib: Drop cached routes with dead neighbours on fib GC
Date: Wed,  9 Jan 2013 09:44:19 -0800
Message-ID: <1357753459-12872-1-git-send-email-roland@kernel.org>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog103.obsmtp.com ([74.125.245.74]:51610 "HELO
	na3sys010aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932233Ab3AIRo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 12:44:27 -0500
Received: by mail-pa0-f72.google.com with SMTP id fb10so1807613pad.3
        for <netdev@vger.kernel.org>; Wed, 09 Jan 2013 09:44:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@purestorage.com>

This patch is as much bug report as it is a proposal to merge this
specific patch.  The problem is definitely real; we hit it in a
situation where we have two systems connected back-to-back with two
bonded links between them, one system reboots, and the other system
gets NETDEV_CHANGEADDR.  This patch definitely fixes that case for us,
but I'm not sure it's the right place to fix this, or if it covers all
the cases where this could happen.  Anyway...

------------ 8< ------------

When a bonding interface changes slaves (or goes from no active slaves
to having a slave with link), the bonding driver generates a
NETDEV_CHANGEADDR notification.  In this case, the ipv6 neighbour
discovery code calls neigh_changeaddr(), which basically just calls
neigh_flush_dev().

Now, neigh_flush_dev() just goes through the neighbour hash table and
tries to free every neighbour from the device being flushed.  However,
if someone else has an additional reference on the neighbour, we hit

			if (atomic_read(&n->refcnt) != 1) {
				/* The most unpleasant situation.
				   We must destroy neighbour entry,
				   but someone still uses it.

				   The destroy will be delayed until
				   the last user releases us, but
				   we must kill timers etc. and move
				   it to safe state.
				 */
				skb_queue_purge(&n->arp_queue);
				n->arp_queue_len_bytes = 0;
				n->output = neigh_blackhole;
				if (n->nud_state & NUD_VALID)
					n->nud_state = NUD_NOARP;
				else
					n->nud_state = NUD_NONE;
				NEIGH_PRINTK2("neigh %p is stray.\n", n);
			}

which leaves the final freeing of the "stray" neighbour until the last
reference is dropped; in the meantime the output function is set to
neigh_blackhole, which does nothing but free the skb and return ENETDOWN.

All of this is fine, unless we have something like a TCP over IPv6 to
a system directly reachable via the bonding interface.  In that case,
we'll have a cached route for the flow.  The route will hold a
reference on a neighbour pointing to the destination, so the neighbour
will become "stray" and won't be freed.  The TCP socket will hold a
reference on the route, so it won't be GCed after the aging interval.
Since every packet we send via the "stray" neighbour will be dropped,
a TCP connection can stay in the ESTABLISHED (or FIN-WAIT-1) state for
a *long* time before it finally gives up.

This leads to a situation where even new connections to or from that
destination fail, because we just drop every packet we try to send
(including things like neighbour discovery advertisements in response
to the remote system trying to find us).  One symptom of having the
cached route with a "stray" neighbour around is that ping6 to the
unreachable system up will fail with:

    # ping6 fe80::202:c903:f:185b%bond0
    PING fe80::202:c903:f:185b%bond0(fe80::202:c903:f:185b) 56 data bytes
    ping: sendmsg: Network is down
    ping: sendmsg: Network is down

("sendmsg: Network is down" == ENETDOWN returned from neigh_blackhole())

A solution is much simpler than the problem's description: the ipv6
ndisc code calls fib6_run_gc() right after it calls neigh_changeaddr(),
and we can add one line to fib6_age() to drop cached routes with a
"stray" neighbour.  This forcibly kills the routes that hold a reference
to the "stray" neighbour so it can be freed without waiting.

Signed-off-by: Roland Dreier <roland@purestorage.com>
---
 net/ipv6/ip6_fib.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 710cafd..5895b1c 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1602,8 +1602,9 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 		}
 		gc_args.more++;
 	} else if (rt->rt6i_flags & RTF_CACHE) {
-		if (atomic_read(&rt->dst.__refcnt) == 0 &&
-		    time_after_eq(now, rt->dst.lastuse + gc_args.timeout)) {
+		if ((rt->n && rt->n->dead) ||
+		    (atomic_read(&rt->dst.__refcnt) == 0 &&
+		     time_after_eq(now, rt->dst.lastuse + gc_args.timeout))) {
 			RT6_TRACE("aging clone %p\n", rt);
 			return -1;
 		} else if (rt->rt6i_flags & RTF_GATEWAY) {
-- 
1.8.0
