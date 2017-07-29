From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v1 2/5] tcp: Implemented the timing-based operations
Date: Fri, 28 Jul 2017 18:46:27 -0700 (PDT)
Message-ID: <20170728.184627.1491806886507775884.davem@davemloft.net>
References: <20170728195919.10099-1-natale.patriciello@gmail.com>
        <20170728195919.10099-3-natale.patriciello@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org, ahmed.said@uniroma2.it,
        zampognaro@ing.uniroma2.it, roseti@ing.uniroma2.it
To: natale.patriciello@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57488 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752860AbdG2Bqa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 21:46:30 -0400
In-Reply-To: <20170728195919.10099-3-natale.patriciello@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Natale Patriciello <natale.patriciello@gmail.com>
Date: Fri, 28 Jul 2017 21:59:16 +0200

> @@ -369,6 +369,9 @@ struct tcp_sock {
>  	 */
>  	struct request_sock *fastopen_rsk;
>  	u32	*saved_syn;
> +
> +/* TCP send timer */
> +	struct timer_list send_timer;
>  };
>  
>  enum tsq_enum {

If this is congestion control specific it should go into the congestion
control algorithm metadata.  If not, then it's OK to be here I guess :)

> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 4858e190f6ac..357b9cd5019e 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2187,6 +2187,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
>  			   int push_one, gfp_t gfp)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
> +	const struct tcp_congestion_ops *ca_ops;
>  	struct sk_buff *skb;
>  	unsigned int tso_segs, sent_pkts;
>  	int cwnd_quota;

Please maintain the reverse christmas tree (longest to shortest) line ordering
of all local variable declarations.

> +	if (timer_pending(&tp->send_timer) == 0) {
> +		/* Timer is not running, push data out */
> +		int ret;
> +		const struct tcp_congestion_ops *ca_ops;

Likewise.
