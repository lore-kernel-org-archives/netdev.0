From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v3] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 10:00:37 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1206200937040.1912@ja.ssi.bg>
References: <20120619.214957.1282277480138040899.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:43682 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873Ab2FTHDH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 03:03:07 -0400
In-Reply-To: <20120619.214957.1282277480138040899.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 19 Jun 2012, David Miller wrote:

> +		if (sk->sk_state != TCP_TIME_WAIT) {
> +			struct dst_entry *dst = sk->sk_rx_dst;
> +			if (dst)
> +				dst = dst_check(dst, 0);

	What about checking rp_filter here or before dst_check:

			rcu_read_lock();
			in_dev = __in_dev_get_rcu(dst->dev);
			if (skb->dev != dst->dev &&
			    (!in_dev || IN_DEV_RPFILTER(in_dev)))
				dst = NULL;
			rcu_read_unlock();

	But may be it is a bad idea to return cached dst
that is with different dev. May be it is better a simple
check instead:

			if (skb->dev != dst->dev)
				dst = NULL;

	It will work for the common case of traffic using
same dev.

> +			if (dst) {
> +				skb_dst_set_noref(skb, dst);
> +				err = 0;
> +			}

	Also, is it a good idea to hide such optimizations
in a bit mask:

sysctl_net_optimizations & 1: optimize for end host
sysctl_net_optimizations & 2: optimize for router
...

Regards

--
Julian Anastasov <ja@ssi.bg>
