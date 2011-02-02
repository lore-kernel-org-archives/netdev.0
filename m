From: kaber@trash.net
Subject: [PATCH 4/4] netfilter: ecache: always set events bits, filter them later
Date: Thu,  3 Feb 2011 00:45:30 +0100
Message-ID: <1296690330-9887-5-git-send-email-kaber@trash.net>
References: <1296690330-9887-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1296690330-9887-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

For the following rule:

iptables -I PREROUTING -t raw -j CT --ctevents assured

The event delivered looks like the following:

 [UPDATE] tcp      6 src=192.168.0.2 dst=192.168.1.2 sport=37041 dport=80 src=192.168.1.2 dst=192.168.1.100 sport=80 dport=37041 [ASSURED]

Note that the TCP protocol state is not included. For that reason
the CT event filtering is not very useful for conntrackd.

To resolve this issue, instead of conditionally setting the CT events
bits based on the ctmask, we always set them and perform the filtering
in the late stage, just before the delivery.

Thus, the event delivered looks like the following:

 [UPDATE] tcp      6 432000 ESTABLISHED src=192.168.0.2 dst=192.168.1.2 sport=37041 dport=80 src=192.168.1.2 dst=192.168.1.100 sport=80 dport=37041 [ASSURED]

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_conntrack_ecache.h |    3 ---
 net/netfilter/nf_conntrack_ecache.c         |    3 +++
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index 96ba5f7..349cefe 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -77,9 +77,6 @@ nf_conntrack_event_cache(enum ip_conntrack_events event, struct nf_conn *ct)
 	if (e == NULL)
 		return;
 
-	if (!(e->ctmask & (1 << event)))
-		return;
-
 	set_bit(event, &e->cache);
 }
 
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index 5702de3..63a1b91 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -63,6 +63,9 @@ void nf_ct_deliver_cached_events(struct nf_conn *ct)
 		 * this does not harm and it happens very rarely. */
 		unsigned long missed = e->missed;
 
+		if (!((events | missed) & e->ctmask))
+			goto out_unlock;
+
 		ret = notify->fcn(events | missed, &item);
 		if (unlikely(ret < 0 || missed)) {
 			spin_lock_bh(&ct->lock);
-- 
1.7.2.3

