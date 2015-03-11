From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 3/6] tcp_metrics: Add a field tcpm_net and verify it matches on lookup
Date: Tue, 10 Mar 2015 19:58:14 -0500
Message-ID: <87twxsgxjt.fsf@x220.int.ebiederm.org>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	<87d25hrv9m.fsf@x220.int.ebiederm.org>
	<20150219.144929.1003473344851168804.davem@davemloft.net>
	<87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	<87oao2yqh1.fsf_-_@x220.int.ebiederm.org>
	<alpine.LFD.2.11.1503092210150.1846@ja.home.ssi.bg>
	<87pp8hnxqz.fsf@x220.int.ebiederm.org>
	<alpine.LFD.2.11.1503100945270.1682@ja.home.ssi.bg>
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
Received: from out02.mta.xmission.com ([166.70.13.232]:33178 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356AbbCKBB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 21:01:56 -0400
In-Reply-To: <alpine.LFD.2.11.1503100945270.1682@ja.home.ssi.bg> (Julian
	Anastasov's message of "Tue, 10 Mar 2015 10:23:12 +0200 (EET)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Anastasov <ja@ssi.bg> writes:

> 	Hello,
>
> On Tue, 10 Mar 2015, Eric W. Biederman wrote:
>
>> Julian Anastasov <ja@ssi.bg> writes:
>> 
>> >>  struct tcp_metrics_block {
>> >>  	struct tcp_metrics_block __rcu	*tcpm_next;
>> >> +	struct net			*tcpm_net;
>> >
>> > 	Is it better if we have this field under
>> > #ifef CONFIG_NET_NS ? read_pnet and write_pnet do not
>> > care when first argument is not declared for the
>> > !CONFIG_NET_NS case.
>> 
>> I don't actually believe there are many people compiling out network
>> namespaces but there is no point in making it unnecessarily bad for them.
>
> 	Small routers. Also, we can move tcpm_net after
> tcpm_daddr to help machines with 32-byte cache line.
> It would be good if fields and access is in this order:
> tcpm_next, tcpm_daddr, tcpm_saddr and finally tcpm_net.
> tcpm_daddr is the leading key, it was tcpm_addr originally.
> If such change is not suitable for this patchset I can try it
> later after your changes.

I think optimizing the order of the fields and their alignment for
machines with a 32-byte cache line is beyond the scope of my patchset.

My gut says if you are a small router you might want to just turn this
off, because you would not be using many tcp sockets.

For a small machine doing tcp and benefitting from this cache I think
figuring out rhashtables for this data structure has merit.   I don't
know if rhashtables are ready for general use yet.

For machines with 64-byte cache lines placing saddr, daddr, net and next
all in the first 4 fields should be sufficient.

For machines with 32-byte cache lines you are in trouble because even
without struct net in their you need two cache lines as saddr and daddr
are both 20 bytes long.  It is just a mess.

>> That said.  If we actually really care about struct net going away it
>> would be much better to globally replace struct net with a typedef that
>> looks something like:
>> 
>> #ifdef CONFIG_NET_NS
>> struct net_ref {
>>        struct net *;
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
> 	Not sure. Only macros help to avoid ifdefs here
> and there in the code...
>
>> In this specific case an extra member of tcp_metrics_block isn't going
>> to hurt so I don't think write_pnet and read_pnet are particularly
>> interesting.   net_eq definitely seems worthwhile.
>
> 	Lets use them, even neighbour.c uses them.
> Your patchset shows the direction we go, net field to be
> part of the structures and using common tables.
> Macros like write_pnet and read_pnet look the only
> way to save memory on small systems. And net_eq should
> be optimized by compilers too.

net_eq definitely will.  And I have figured out how to have
write_pnet and read_pnet be palatiable to me.

I wish I could force the use of net_eq when the network namespace
field might be compiled out but that seems one step too far for now.

Eric
