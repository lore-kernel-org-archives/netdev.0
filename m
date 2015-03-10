From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 3/6] tcp_metrics: Add a field tcpm_net and verify it matches on lookup
Date: Tue, 10 Mar 2015 12:06:32 -0500
Message-ID: <87fv9clr3b.fsf@x220.int.ebiederm.org>
References: <87oao2yqh1.fsf_-_@x220.int.ebiederm.org>
	<alpine.LFD.2.11.1503092210150.1846@ja.home.ssi.bg>
	<87pp8hnxqz.fsf@x220.int.ebiederm.org>
	<20150310.123642.2054908032137423526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ja@ssi.bg, edumazet@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, hannes@stressinduktion.org,
	ddutt@cumulusnetworks.com, vipin@cumulusnetworks.com,
	shmulik.ladkani@gmail.com, dsahern@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:46348 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749AbbCJRKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 13:10:14 -0400
In-Reply-To: <20150310.123642.2054908032137423526.davem@davemloft.net> (David
	Miller's message of "Tue, 10 Mar 2015 12:36:42 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 10 Mar 2015 01:59:48 -0500
>
>> If we actually really care about struct net going away it would be
>> much better to globally replace struct net with a typedef that looks
>> something like:
>> 
>> #ifdef CONFIG_NET_NS
>> struct net_ref {
>>        struct net *net;
>> };
>> #else
>> struct net_ref {
>> };
>> #endif
>> typedef struct net_ref net_t;
>> 
>> That would remove the need for write_pnet and read_pnet, make it
>> impossible to forget net_eq and make network namespace arguments to
>> functions also boil away at compile time if the network namespace code
>> was not enabled.
>> 
>> That was the original design and I forget why we didn't do that with
>> struct net.  But we did not.
>
> This keeps the ifdefs out of foo.c code, so I like it.

Alright.  It does wind up requiring things like:

static inline struct net *to_struct_net(net_t net)
{
#ifdef CONFIG_NET_NS
        return net.net;
#else
        return &init_net;
#endif        
}

static inline net_t to_net_t(struct net *net)
{
	net_t result;
#ifdef CONFIG_NET_NS
	result.net = net;
#endif        
	return result;
}

static inline struct struct net *ipv4_net(net_t net)
{
        return &to_struct_net(net)->ipv4;
}

But we are used to those from dealing with network devices,
so it should be no big deal.

I will start playing with it to see how much work that is to implement.

Any suggestions on a better name for to_struct_net()? Perhaps
global_net()?  Although arguably anything that to_struct_net feels
awkward for should it's own xxx_net type.

Eric
