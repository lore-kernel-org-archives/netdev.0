From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v9 net-next 2/7] net: add low latency socket poll
Date: Wed, 05 Jun 2013 08:21:54 -0700
Message-ID: <1370445714.24311.268.camel@edumazet-glaptop>
References: <20130605103400.11172.49099.stgit@ladj378.jer.intel.com>
	 <20130605103421.11172.82925.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130605103421.11172.82925.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-06-05 at 13:34 +0300, Eliezer Tamir wrote:


This is probably too big to be inlined, and nonblock should be a bool


It would also make sense to give end_time as a parameter, so that the
polling() code could really give  a end_time for the whole duration of
poll().

(You then should test can_poll_ll(end_time) _before_ call to
ndo_ll_poll())


> +static inline bool sk_poll_ll(struct sock *sk, int nonblock)
> +{
> +	cycles_t end_time = ll_end_time();
> +	const struct net_device_ops *ops;
> +	struct napi_struct *napi;
> +	int rc = false;
> +
> +	/*
> +	 * rcu read lock for napi hash
> +	 * bh so we don't race with net_rx_action
> +	 */
> +	rcu_read_lock_bh();
> +
> +	napi = napi_by_id(sk->sk_napi_id);
> +	if (!napi)
> +		goto out;
> +
> +	ops = napi->dev->netdev_ops;
> +	if (!ops->ndo_ll_poll)
> +		goto out;
> +
> +	do {
> +
> +		rc = ops->ndo_ll_poll(napi);
> +
> +		if (rc == LL_FLUSH_FAILED)
> +			break; /* permanent failure */
> +
> +		if (rc > 0)
> +			/* local bh are disabled so it is ok to use _BH */
> +			NET_ADD_STATS_BH(sock_net(sk),
> +					 LINUX_MIB_LOWLATENCYRXPACKETS, rc);
> +
> +	} while (skb_queue_empty(&sk->sk_receive_queue)
> +			&& can_poll_ll(end_time) && !nonblock);
> +
> +	rc = !skb_queue_empty(&sk->sk_receive_queue);
> +out:
> +	rcu_read_unlock_bh();
> +	return rc;
> +}
