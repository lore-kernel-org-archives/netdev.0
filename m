From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 3/6] tcp_metrics: Add a field tcpm_net and verify it matches on lookup
Date: Tue, 10 Mar 2015 01:59:48 -0500
Message-ID: <87pp8hnxqz.fsf@x220.int.ebiederm.org>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	<87d25hrv9m.fsf@x220.int.ebiederm.org>
	<20150219.144929.1003473344851168804.davem@davemloft.net>
	<87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	<87oao2yqh1.fsf_-_@x220.int.ebiederm.org>
	<alpine.LFD.2.11.1503092210150.1846@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	netdev@vger.kernel.org, stephen@networkplumber.org,
	nicolas.dichtel@6wind.com, roopa@cumulusnetworks.com,
	hannes@stressinduktion.org, ddutt@cumulusnetworks.com,
	vipin@cumulusnetworks.com, shmulik.ladkani@gmail.com,
	dsahern@gmail.com
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60599 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbbCJHD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 03:03:29 -0400
In-Reply-To: <alpine.LFD.2.11.1503092210150.1846@ja.home.ssi.bg> (Julian
	Anastasov's message of "Mon, 9 Mar 2015 22:25:11 +0200 (EET)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Anastasov <ja@ssi.bg> writes:

> 	Hello,
>
> On Mon, 9 Mar 2015, Eric W. Biederman wrote:
>
>> diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
>> index 70196c3c16a1..4ec02d6cab5b 100644
>> --- a/net/ipv4/tcp_metrics.c
>> +++ b/net/ipv4/tcp_metrics.c
>> @@ -40,6 +40,7 @@ struct tcp_fastopen_metrics {
>>  
>>  struct tcp_metrics_block {
>>  	struct tcp_metrics_block __rcu	*tcpm_next;
>> +	struct net			*tcpm_net;
>
> 	Is it better if we have this field under
> #ifef CONFIG_NET_NS ? read_pnet and write_pnet do not
> care when first argument is not declared for the
> !CONFIG_NET_NS case.

I don't actually believe there are many people compiling out network
namespaces but there is no point in making it unnecessarily bad for them.

That said.  If we actually really care about struct net going away it
would be much better to globally replace struct net with a typedef that
looks something like:

#ifdef CONFIG_NET_NS
struct net_ref {
       struct net *;
};
#else
struct net_ref {
};
#endif
typedef struct net_ref net_t;

That would remove the need for write_pnet and read_pnet, make it
impossible to forget net_eq and make network namespace arguments to
functions also boil away at compile time if the network namespace code
was not enabled.

That was the original design and I forget why we didn't do that with
struct net.  But we did not.

In this specific case an extra member of tcp_metrics_block isn't going
to hurt so I don't think write_pnet and read_pnet are particularly
interesting.   net_eq definitely seems worthwhile.

>>  	struct inetpeer_addr		tcpm_saddr;
>>  	struct inetpeer_addr		tcpm_daddr;
>>  	unsigned long			tcpm_stamp;
>> @@ -183,6 +184,7 @@ static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
>>  		if (!tm)
>>  			goto out_unlock;
>>  	}
>> +	tm->tcpm_net = net;
>
> 	write_pnet(&tm->tcpm_net, net);
>
>>  	tm->tcpm_saddr = *saddr;
>>  	tm->tcpm_daddr = *daddr;
>>  
>> @@ -216,7 +218,8 @@ static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *s
>>  
>>  	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
>>  	     tm = rcu_dereference(tm->tcpm_next)) {
>> -		if (addr_same(&tm->tcpm_saddr, saddr) &&
>> +		if ((tm->tcpm_net == net) &&
>> +		    addr_same(&tm->tcpm_saddr, saddr) &&
>>  		    addr_same(&tm->tcpm_daddr, daddr))
>
> 	net_eq(read_pnet(), net) can be checked last,
> better to match the addresses first?

Not hugely better but failing faster is always a good idea if you get
stuck with a long hash chain.

Eric
