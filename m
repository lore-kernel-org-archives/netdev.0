From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/2] tcp: add generic netlink support for tcp_metrics
Date: Mon, 03 Sep 2012 02:45:44 +0200
Message-ID: <1346633144.2563.97.camel@edumazet-glaptop>
References: <1346564178-1794-1-git-send-email-ja@ssi.bg>
	 <1346564178-1794-2-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:50550 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755028Ab2ICApr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2012 20:45:47 -0400
Received: by weyx8 with SMTP id x8so2664447wey.19
        for <netdev@vger.kernel.org>; Sun, 02 Sep 2012 17:45:46 -0700 (PDT)
In-Reply-To: <1346564178-1794-2-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-09-02 at 08:36 +0300, Julian Anastasov wrote:
> +
> +static int tcp_metrics_flush_all(struct net *net)
> +{
> +	unsigned int max_rows = 1U << net->ipv4.tcp_metrics_hash_log;
> +	struct tcpm_hash_bucket *hb = net->ipv4.tcp_metrics_hash;
> +	struct tcp_metrics_block *tm;
> +	unsigned int sync_count = 0;
> +	unsigned int row;
> +
> +	for (row = 0; row < max_rows; row++, hb++) {
> +		spin_lock_bh(&tcp_metrics_lock);
> +		tm = deref_locked_genl(hb->chain);
> +		if (tm)
> +			hb->chain = NULL;
> +		spin_unlock_bh(&tcp_metrics_lock);
> +		while (tm) {
> +			struct tcp_metrics_block *next;
> +
> +			next = deref_genl(tm->tcpm_next);
> +			kfree_rcu(tm, rcu_head);
> +			if (!((++sync_count) & 2047))
> +				synchronize_rcu();
> +			tm = next;
> +		}
> +	}
> +	return 0;
> +}

It looks like the synchronize_rcu() call is not exactly what you wanted,
but then net/ipv4/fib_trie.c has the same mistake.

What we want here is to force pending call_rcu() calls to complete, so
that we dont consume too much memory. So it would probably better to
call rcu_barrier() instead.

If other cpus are idle or outside of rcu read lock sections,
synchronize_rcu() should basically do nothing at all.

But I am not sure its worth the trouble ?

Commit c3059477fce2d956a0bb3e04357324780c5d8eeb (ipv4: Use
synchronize_rcu() during trie_rebalance()) was needed because FIB TRIE
can really use huge amounts of memory, thats hardly the case with
tcp_metrics.
