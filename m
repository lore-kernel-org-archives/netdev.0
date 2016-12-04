From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] tcp: warn on bogus MSS and try to amend it
Date: Sat, 03 Dec 2016 23:37:03 -0500 (EST)
Message-ID: <20161203.233703.784557738334949173.davem@davemloft.net>
References: <83a3345f2fae904fa59794d59703d86851cda7d5.1480718620.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmaxwell37@gmail.com,
        alexandre.sidorenko@hpe.com, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        tlfalcon@linux.vnet.ibm.com, brking@linux.vnet.ibm.com,
        eric.dumazet@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42172 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752128AbcLDEhF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 23:37:05 -0500
In-Reply-To: <83a3345f2fae904fa59794d59703d86851cda7d5.1480718620.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri,  2 Dec 2016 20:51:51 -0200

> @@ -144,7 +144,21 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
>  	 */
>  	len = skb_shinfo(skb)->gso_size ? : skb->len;
>  	if (len >= icsk->icsk_ack.rcv_mss) {
> -		icsk->icsk_ack.rcv_mss = len;
> +		static bool __once __read_mostly;
> +
> +		icsk->icsk_ack.rcv_mss = min_t(unsigned int, len,
> +					       tcp_sk(sk)->advmss);
> +		if (icsk->icsk_ack.rcv_mss != len && !__once) {
> +			struct net_device *dev;
> +
> +			__once = true;
> +
> +			rcu_read_lock();
> +			dev = dev_get_by_index_rcu(sock_net(sk), skb->skb_iif);
> +			pr_warn_once("%s: Driver has suspect GRO implementation, TCP performance may be compromised.\n",
> +				     dev ? dev->name : "Unknown driver");
> +			rcu_read_unlock();
> +		}

This is almost ready to go.

Since you are doing the 'once' logic by hand, using pr_warn_once() is
redundant.  And while you're at it, why not split this into a helper
function:

static void tcp_gro_dev_warn(struct sock *sk, const struct sk_buff *skb)
{
	static bool __once __read_mostly;

	if (!__once) {
		__once = true;

		rcu_read_lock();
		dev = dev_get_by_index_rcu(sock_net(sk), skb->skb_iif);
		pr_warn("%s: Driver has suspect GRO implementation, TCP performance may be compromised.\n",
			dev ? dev->name : "Unknown driver");
		rcu_read_unlock();
	}
}

And then call that when icsk->icsk_ack.rcv_mss != len, you can even
put an unlikely() around the condition as well.
