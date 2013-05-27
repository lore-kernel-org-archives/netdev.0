From: Roman Gushchin <klamm@yandex-team.ru>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Mon, 27 May 2013 15:34:31 +0400
Message-ID: <51A344C7.9040402@yandex-team.ru>
References: <519B8908.9080007@yandex-team.ru> <1369150693.3301.233.camel@edumazet-glaptop> <519BB90B.6080706@yandex-team.ru> <1369188080.3301.268.camel@edumazet-glaptop> <1369201765.3301.299.camel@edumazet-glaptop> <519CB2D8.103@yandex-team.ru> <1369225837.3301.324.camel@edumazet-glaptop> <519CC2FB.2010006@yandex-team.ru> <20130522174532.GC3431@linux.vnet.ibm.com> <519D19DA.50400@yandex-team.ru> <20130525113715.GA3795@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dipankar Sarma <dipankar@in.ibm.com>, zhmurov@yandex-team.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: paulmck@linux.vnet.ibm.com, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1f.mail.yandex.net ([95.108.130.40]:36934 "EHLO
	forward-corp1f.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757380Ab3E0Len (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 07:34:43 -0400
In-Reply-To: <20130525113715.GA3795@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25.05.2013 15:37, Paul E. McKenney wrote:
>> 2) A problem occurs when restart_condition is true and we jump to the begin label.
>> We do not recalculate (head + offsetof(head, first)) address, we just dereference
>> again the OLD (head->first) pointer. So, we get a node, that WAS the first node in a
>> previous time instead of current first node. That node can be dead, or, for instance,
>> can be a head of another chain.
>
> OK, this is what I was referring to when I said that the RCU list macros
> assume that the list header is static (or equivalently, appropriately
> protected).
>
> With some_func() as written above, you would need to return some sort
> of failure indication from some_func(), and have the caller refetch head.
> Otherwise, as far as gcc is concerned, the value of the parameter head
> is constant throughout some_func().

Personally I have nothing against this approach, but I'm not sure, if
networking maintainers will adopt corresponding patch. I'll try to find it out.

>
>> It is correct from gcc's point of view, since it doesn't expect the head pointer
>> to change, and this address is just (head + constant offset).
>
> Agreed.
>
> How does the caller calculate the value to pass in through the argument "head"?

struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
		__be16 sport, __be32 daddr, __be16 dport,
		int dif, struct udp_table *udptable)
{
	...
	unsigned int hash2, slot2, slot = udp_hashfn(net, hnum, udptable->mask);
	struct udp_hslot *hslot2, *hslot = &udptable->hash[slot];
	int score, badness;

	rcu_read_lock();
	if (hslot->count > 10) {
		hash2 = udp4_portaddr_hash(net, daddr, hnum);
		slot2 = hash2 & udptable->mask;
		hslot2 = &udptable->hash2[slot2];
		...
		result = udp4_lib_lookup2(net, saddr, sport,
					  daddr, hnum, dif,
					  hslot2, slot2);
	...
}

static struct sock *udp4_lib_lookup2(struct net *net,
		__be32 saddr, __be16 sport,
		__be32 daddr, unsigned int hnum, int dif,
		struct udp_hslot *hslot2, unsigned int slot2)
{
	...
	udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {
		...

Thank you!

Regards,
Roman
