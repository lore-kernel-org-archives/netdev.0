From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 1/2] tcp: add generic netlink support for
 tcp_metrics
Date: Thu, 23 Aug 2012 18:19:14 +0200
Message-ID: <1345738754.5904.1267.camel@edumazet-glaptop>
References: <1345734105-28328-1-git-send-email-ja@ssi.bg>
	 <1345734105-28328-2-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43068 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041Ab2HWQTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 12:19:19 -0400
Received: by bkwj10 with SMTP id j10so310550bkw.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 09:19:18 -0700 (PDT)
In-Reply-To: <1345734105-28328-2-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-23 at 18:01 +0300, Julian Anastasov wrote:
> 	Add support for genl "tcp_metrics". No locking
> is changed, only that now we can unlink and delete
> entries after grace period. We implement get/del for
> single entry and dump to support show/flush filtering
> in user space.
> 

Very nice, thanks !

> +static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
> +{
> +	struct tcpm_hash_bucket *hb;
> +	struct tcp_metrics_block *tm;
> +	struct tcp_metrics_block __rcu **pp;
> +	struct inetpeer_addr addr;
> +	unsigned int hash;
> +	struct net *net = genl_info_net(info);
> +	int ret;
> +
> +	ret = parse_nl_addr(info, &addr, &hash, 1);
> +	if (ret < 0)
> +		return ret;
> +	/* Flush all ? */
> +	if (ret > 0) {
> +		unsigned int max_rows = 1U << net->ipv4.tcp_metrics_hash_log;
> +		unsigned int sync_count = 0;
> +		unsigned int row;
> +
> +		hb = net->ipv4.tcp_metrics_hash;
> +		for (row = 0; row < max_rows; row++, hb++) {
> +			spin_lock_bh(&tcp_metrics_lock);
> +			tm = deref_locked_genl(hb->chain);
> +			if (tm)
> +				rcu_assign_pointer(hb->chain, NULL);
> +			spin_unlock_bh(&tcp_metrics_lock);
> +			while (tm) {
> +				struct tcp_metrics_block *next;
> +
> +				next = deref_genl(tm->tcpm_next);
> +				kfree_rcu(tm, rcu_head);
> +				if (!((++sync_count) & 2047))
> +					synchronize_rcu();
> +				tm = next;
> +			}
> +		}
> +		return 0;
> +	}
> +
> +	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
> +	hb = net->ipv4.tcp_metrics_hash + hash;
> +	pp = &hb->chain;
> +	spin_lock_bh(&tcp_metrics_lock);
> +	for (tm = deref_locked_genl(*pp); tm;
> +	     pp = &tm->tcpm_next, tm = deref_locked_genl(*pp)) {
> +		if (addr_same(&tm->tcpm_addr, &addr)) {
> +			rcu_assign_pointer(*pp, tm->tcpm_next);

Hmm, try "make C=2 net/ipv4/tcp_metrics.o"

with :

CONFIG_SPARSE_RCU_POINTER=y


I guess you can use plain " *pp = tm->tcpm_next;"

> +			break;
> +		}
> +	}
> +	spin_unlock_bh(&tcp_metrics_lock);
> +	if (!tm)
> +		return -ESRCH;
> +	kfree_rcu(tm, rcu_head);
> +	return 0;
> +}
> +

Could you split this in two functions, adding tcp_metrics_flush_all() ?
