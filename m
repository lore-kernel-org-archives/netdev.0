From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 3/6] tcp_metrics: Add a field tcpm_net and verify
 it matches on lookup
Date: Mon, 9 Mar 2015 22:25:11 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1503092210150.1846@ja.home.ssi.bg>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org> <CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com> <87d25hrv9m.fsf@x220.int.ebiederm.org> <20150219.144929.1003473344851168804.davem@davemloft.net> <87h9tu114z.fsf_-_@x220.int.ebiederm.org>
 <87oao2yqh1.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	netdev@vger.kernel.org, stephen@networkplumber.org,
	nicolas.dichtel@6wind.com, roopa@cumulusnetworks.com,
	hannes@stressinduktion.org, ddutt@cumulusnetworks.com,
	vipin@cumulusnetworks.com, shmulik.ladkani@gmail.com,
	dsahern@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:39739 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752199AbbCIUZc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 16:25:32 -0400
In-Reply-To: <87oao2yqh1.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 9 Mar 2015, Eric W. Biederman wrote:

> diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
> index 70196c3c16a1..4ec02d6cab5b 100644
> --- a/net/ipv4/tcp_metrics.c
> +++ b/net/ipv4/tcp_metrics.c
> @@ -40,6 +40,7 @@ struct tcp_fastopen_metrics {
>  
>  struct tcp_metrics_block {
>  	struct tcp_metrics_block __rcu	*tcpm_next;
> +	struct net			*tcpm_net;

	Is it better if we have this field under
#ifef CONFIG_NET_NS ? read_pnet and write_pnet do not
care when first argument is not declared for the
!CONFIG_NET_NS case.

>  	struct inetpeer_addr		tcpm_saddr;
>  	struct inetpeer_addr		tcpm_daddr;
>  	unsigned long			tcpm_stamp;
> @@ -183,6 +184,7 @@ static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
>  		if (!tm)
>  			goto out_unlock;
>  	}
> +	tm->tcpm_net = net;

	write_pnet(&tm->tcpm_net, net);

>  	tm->tcpm_saddr = *saddr;
>  	tm->tcpm_daddr = *daddr;
>  
> @@ -216,7 +218,8 @@ static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *s
>  
>  	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
>  	     tm = rcu_dereference(tm->tcpm_next)) {
> -		if (addr_same(&tm->tcpm_saddr, saddr) &&
> +		if ((tm->tcpm_net == net) &&
> +		    addr_same(&tm->tcpm_saddr, saddr) &&
>  		    addr_same(&tm->tcpm_daddr, daddr))

	net_eq(read_pnet(), net) can be checked last,
better to match the addresses first?

Regards

--
Julian Anastasov <ja@ssi.bg>
