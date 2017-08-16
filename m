From: Julian Anastasov <ja@ssi.bg>
Subject: Re: 100% CPU load when generating traffic to destination network
 that nexthop is not reachable
Date: Wed, 16 Aug 2017 10:42:04 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1708161026280.1778@ja.home.ssi.bg>
References: <177465a0-aaba-4063-e451-ebbf46728b77@itcare.pl>          <1502816253.4936.85.camel@edumazet-glaptop3.roam.corp.google.com>          <baa1807d-cc00-0182-4b34-4d986d62ebcb@itcare.pl>  <1502824260.4936.86.camel@edumazet-glaptop3.roam.corp.google.com>
  <alpine.LFD.2.20.1708152236360.1666@ja.home.ssi.bg> <1502831185.4936.87.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:37312 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751082AbdHPHmP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 03:42:15 -0400
In-Reply-To: <1502831185.4936.87.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 15 Aug 2017, Eric Dumazet wrote:

> It must be possible to add a fast path without locks.
> 
> (say if jiffies has not changed before last state change)

	New day - new idea. Something like this? But it
has bug: without checking neigh->dead under lock we don't
have the right to access neigh->parms, it can be destroyed
immediately by neigh_release->neigh_destroy->neigh_parms_put->
neigh_parms_destroy->kfree. Not sure, may be kfree_rcu can help
for this...

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 9816df2..f52763c 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -428,10 +428,10 @@ static inline int neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 {
 	unsigned long now = jiffies;
 	
-	if (neigh->used != now)
-		neigh->used = now;
 	if (!(neigh->nud_state&(NUD_CONNECTED|NUD_DELAY|NUD_PROBE)))
 		return __neigh_event_send(neigh, skb);
+	if (neigh->used != now)
+		neigh->used = now;
 	return 0;
 }
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 16a1a4c..52a8718 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -991,8 +991,18 @@ static void neigh_timer_handler(unsigned long arg)
 
 int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 {
-	int rc;
 	bool immediate_probe = false;
+	unsigned long now = jiffies;
+	int rc;
+
+	if (neigh->used != now) {
+		neigh->used = now;
+	} else if (neigh->nud_state == NUD_INCOMPLETE &&
+		   (!skb || neigh->arp_queue_len_bytes + skb->truesize >
+		    NEIGH_VAR(neigh->parms, QUEUE_LEN_BYTES))) {
+		kfree_skb(skb);
+		return 1;
+	}
 
 	write_lock_bh(&neigh->lock);
 
@@ -1005,7 +1015,7 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 	if (!(neigh->nud_state & (NUD_STALE | NUD_INCOMPLETE))) {
 		if (NEIGH_VAR(neigh->parms, MCAST_PROBES) +
 		    NEIGH_VAR(neigh->parms, APP_PROBES)) {
-			unsigned long next, now = jiffies;
+			unsigned long next;
 
 			atomic_set(&neigh->probes,
 				   NEIGH_VAR(neigh->parms, UCAST_PROBES));

Regards
