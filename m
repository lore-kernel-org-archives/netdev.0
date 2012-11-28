From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: move inet_dport/inet_num in sock_common
Date: Wed, 28 Nov 2012 03:27:41 -0800
Message-ID: <1354102061.14302.84.camel@edumazet-glaptop>
References: <1354028815.14302.35.camel@edumazet-glaptop>
	 <1354037000.2116.19.camel@joe-AO722>
	 <1354051475.14302.42.camel@edumazet-glaptop>
	 <1354069414.8918.13.camel@joe-AO722>
	 <1354075918.14302.77.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ling Ma <ling.ma.program@gmail.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:60450 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754110Ab2K1L1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 06:27:45 -0500
Received: by mail-ie0-f174.google.com with SMTP id k11so9861583iea.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 03:27:45 -0800 (PST)
In-Reply-To: <1354075918.14302.77.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-27 at 20:12 -0800, Eric Dumazet wrote:

> The point of having the cond jump on sk_hash/hash was that in one
> compare, we catch the yes/no status with 99.999999 % success rate.
> 
> All the following compares are predicted by the cpu and essentially are
> free. Adding the AND or OR will basically have the same cpu cost.
> 
> If we wanted to do a full test of all tuple fields and a single
> conditional jump, we would not have to include hash test at all.
> 
> (If the 4-tuple matches, then sk_hash/hash value _must_ be the same by
> definition)

What I am going to do is to remove the hash compare from the macros so
that we can use likely()/unlikely() to explicitly give hints to the
compiler.

The hash compare can be omitted in the validation done after the
atomic_inc_not_zero() [ done to make sure keys didnt change ]

begin:
        sk_nulls_for_each_rcu(sk, node, &head->chain) {
                if (sk->sk_hash != hash)
                        continue;
                if (likely(INET_MATCH(sk, net, acookie,
                                      saddr, daddr, ports, dif))) {
                        if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt)))
                                goto begintw;
                        if (unlikely(!INET_MATCH(sk, net, acookie,
                                                 saddr, daddr, ports, dif))) {
                                sock_put(sk);
                                goto begin;
                        }
                        goto out;
                }
        }
 
