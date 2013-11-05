From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2 2/4] ipv6: enable IPV6_FLOWLABEL_MGR for getsockopt
Date: Tue, 5 Nov 2013 17:08:38 +0100
Message-ID: <20131105160838.GH8832@order.stressinduktion.org>
References: <1383661738-6083-1-git-send-email-florent.fourcot@enst-bretagne.fr> <1383661738-6083-2-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51045 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263Ab3KEQIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 11:08:39 -0500
Content-Disposition: inline
In-Reply-To: <1383661738-6083-2-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 05, 2013 at 03:28:56PM +0100, Florent Fourcot wrote:
> +	spin_lock_bh(&ip6_fl_lock);
> +	rcu_read_lock_bh();
> +
> +	for_each_sk_fl_rcu(np, sfl) {
> +		if (sfl->fl->label == (np->flow_label & IPV6_FLOWLABEL_MASK)) {

The iteration is protected by rcu, so need to take the ip6_fl_lock. We should
lock the smallest region which needs to be protected. This is only the body of
the if.

Using fl->label without lock is fine, because it is immutable after interning.

> +			freq->flr_label = sfl->fl->label;
> +			freq->flr_dst = sfl->fl->dst;
> +			freq->flr_share = sfl->fl->share;
> +			freq->flr_expires = (sfl->fl->expires - jiffies) / HZ;
> +			freq->flr_linger = sfl->fl->linger / HZ;
> +
> +			rcu_read_unlock_bh();
> +			spin_unlock_bh(&ip6_fl_lock);

Please reverse these two lines then.

Could you take a look at your patch regarding fl6_renew, too? Can we
push locking into the function there, too?

Greetings,

  Hannes
