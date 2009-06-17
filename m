From: Patrick McHardy <kaber@trash.net>
Subject: Re: [bug] __nf_ct_refresh_acct(): WARNING: at lib/list_debug.c:30
 __list_add+0x7d/0xad()
Date: Wed, 17 Jun 2009 13:51:45 +0200
Message-ID: <4A38D8D1.6060004@trash.net>
References: <20090615.050449.144947903.davem@davemloft.net> <20090616091538.GA4184@elte.hu> <20090616.034752.226811527.davem@davemloft.net> <20090616105304.GA3579@elte.hu> <20090616122415.GA16630@elte.hu> <20090617092152.GA17449@elte.hu> <4A38C2F3.3000009@gmail.com> <4A38D5BD.2040502@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050408050902070403010807"
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64930 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756772AbZFQLvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 07:51:45 -0400
In-Reply-To: <4A38D5BD.2040502@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050408050902070403010807
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Eric Dumazet wrote:
>> IPS_CONFIRMED_BIT is set under nf_conntrack_lock (in 
>> __nf_conntrack_confirm()),
>> we probably want to add a synchronisation under ct->lock as well,
>> or __nf_ct_refresh_acct() could set ct->timeout.expires to extra_jiffies,
>> while a different cpu could confirm the conntrack.
> 
> Before the conntrack is confirmed, it is exclusively handled by a
> single CPU. I agree that we need to make sure the IPS_CONFIRMED_BIT
> is visible before we add the conntrack to the hash table since the
> lookup is lockless, but simply moving the set_bit before the hash
> insertion should be fine I think.
> 

A slightly changed version which moves hash insertion to the end
and adds a comment about ordering. This make sure the timer is
actually running before the conntrack can be found be other CPUs.



--------------050408050902070403010807
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 5f72b94..e2cc707 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -425,7 +425,6 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	/* Remove from unconfirmed list */
 	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
 
-	__nf_conntrack_hash_insert(ct, hash, repl_hash);
 	/* Timer relative to confirmation time, not original
 	   setting time, otherwise we'd get timer wrap in
 	   weird delay cases. */
@@ -433,8 +432,15 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	add_timer(&ct->timeout);
 	atomic_inc(&ct->ct_general.use);
 	set_bit(IPS_CONFIRMED_BIT, &ct->status);
+
+	/* Since the lookup is lockless, hash insertion must be after starting the
+	 * timer and setting the CONFIRMED bit. The RCU barriers guarantee that no
+	 * other CPU can find the conntrack before the above stores are visible.
+	 */
+	__nf_conntrack_hash_insert(ct, hash, repl_hash);
 	NF_CT_STAT_INC(net, insert);
 	spin_unlock_bh(&nf_conntrack_lock);
+
 	help = nfct_help(ct);
 	if (help && help->helper)
 		nf_conntrack_event_cache(IPCT_HELPER, ct);

--------------050408050902070403010807--
