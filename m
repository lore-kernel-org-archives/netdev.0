From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/08: xt_recent: fix buffer overflow
Date: Wed, 24 Feb 2010 18:49:30 +0100 (MET)
Message-ID: <20100224174930.16391.80414.sendpatchset@x2.localnet>
References: <20100224174927.16391.59798.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100224174927.16391.59798.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 2c08522e5d2f0af2d6f05be558946dcbf8173683
Author: Tim Gardner <tim.gardner@canonical.com>
Date:   Tue Feb 23 14:55:21 2010 +0100

    netfilter: xt_recent: fix buffer overflow
    
    e->index overflows e->stamps[] every ip_pkt_list_tot packets.
    
    Consider the case when ip_pkt_list_tot==1; the first packet received is stored
    in e->stamps[0] and e->index is initialized to 1. The next received packet
    timestamp is then stored at e->stamps[1] in recent_entry_update(),
    a buffer overflow because the maximum e->stamps[] index is 0.
    
    Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
    Cc: stable@kernel.org
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 132cfaa..1278f0a 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -177,10 +177,10 @@ recent_entry_init(struct recent_table *t, const union nf_inet_addr *addr,
 
 static void recent_entry_update(struct recent_table *t, struct recent_entry *e)
 {
+	e->index %= ip_pkt_list_tot;
 	e->stamps[e->index++] = jiffies;
 	if (e->index > e->nstamps)
 		e->nstamps = e->index;
-	e->index %= ip_pkt_list_tot;
 	list_move_tail(&e->lru_list, &t->lru_list);
 }
 
