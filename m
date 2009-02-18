From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFT 3/4] Use mod_timer_noact to remove nf_conntrack_lock
Date: Tue, 17 Feb 2009 21:19:09 -0800
Message-ID: <20090218052747.555811553@vyatta.com>
References: <20090218051906.174295181@vyatta.com>
Cc: netdev@vger.kernel.org, tglx@linutronix.de,
	netfilter-devel@vger.kernel.org,
	Martin Josefsson <gandalf@wlug.westbo.se>
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:37155 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751848AbZBRFej (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2009 00:34:39 -0500
Content-Disposition: inline; filename=nf_ct_refresh_acct-locking.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we are using mod_timer_noact() for timer updates there's no need to
hold the global lock during the timer update since the actual timeout update
is now protected by the timer locking.

Signed-off-by: Martin Josefsson <gandalf@wlug.westbo.se>

---
 net/netfilter/nf_conntrack_core.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

--- a/net/netfilter/nf_conntrack_core.c	2009-02-17 10:55:33.370882059 -0800
+++ b/net/netfilter/nf_conntrack_core.c	2009-02-17 13:48:25.080060712 -0800
@@ -793,13 +793,12 @@ void __nf_ct_refresh_acct(struct nf_conn
 	NF_CT_ASSERT(ct->timeout.data == (unsigned long)ct);
 	NF_CT_ASSERT(skb);
 
-	spin_lock_bh(&nf_conntrack_lock);
-
 	/* Only update if this is not a fixed timeout */
 	if (test_bit(IPS_FIXED_TIMEOUT_BIT, &ct->status))
 		goto acct;
 
-	/* If not in hash table, timer will not be active yet */
+	/* If not in hash table, timer will not be active yet,
+	   we are the only one able to see it. */
 	if (!nf_ct_is_confirmed(ct)) {
 		ct->timeout.expires = extra_jiffies;
 		event = IPCT_REFRESH;
@@ -821,16 +820,16 @@ acct:
 	if (do_acct) {
 		struct nf_conn_counter *acct;
 
+		spin_lock_bh(&nf_conntrack_lock);
 		acct = nf_conn_acct_find(ct);
 		if (acct) {
 			acct[CTINFO2DIR(ctinfo)].packets++;
 			acct[CTINFO2DIR(ctinfo)].bytes +=
 				skb->len - skb_network_offset(skb);
 		}
+		spin_unlock_bh(&nf_conntrack_lock);
 	}
 
-	spin_unlock_bh(&nf_conntrack_lock);
-
 	/* must be unlocked when calling event cache */
 	if (event)
 		nf_conntrack_event_cache(event, ct);

-- 

