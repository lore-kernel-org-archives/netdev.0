From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] IPV4 : Move ip route cache flush (secret_rebuild) from
 softirq to workqueue
Date: Sat, 17 Nov 2007 17:18:35 +0100
Message-ID: <473F145B.5090303@cosmosbay.com>
References: <20071116174027.726e6eca.dada1@cosmosbay.com> <20071116.165445.172804063.davem@davemloft.net> <473EB75B.7000607@cosmosbay.com> <20071117143622.GA20813@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:43422 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbXKQQTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 11:19:06 -0500
In-Reply-To: <20071117143622.GA20813@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu a =E9crit :
> On Sat, Nov 17, 2007 at 09:41:47AM +0000, Eric Dumazet wrote:
>> [PATCH] IPV4 : Move ip route cache flush (secret_rebuild) from softi=
rq to=20
>> workqueue
>=20
> Thanks for your work on this Eric! It's very much needed.

Thanks :)

>=20
>> @@ -667,7 +697,7 @@ void rt_cache_flush(int delay)
>> =20
>>  	if (delay <=3D 0) {
>>  		spin_unlock_bh(&rt_flush_lock);
>> -		rt_run_flush(0);
>> +		rt_run_flush(user_mode);
>>  		return;
>>  	}
>=20
> This seems to be the only potentially softirq caller of rt_run_flush.
> However, I just checked the callers of it and most of them seem to
> hold the RTNL which would indicate that they're in process context.
>=20
> So do you know if you we have any real softirq callers left?
> If we do perhaps we can look at either moving them out or see
> if they can cope with the flush occuring after the call returns.
>=20
> If not we can get rid of the softirq special case.
>=20

Unfortunatly we have softirq callers left. But my goal is to move every=
thing=20
to process context yes. I choose small patches, so that they can be mor=
e=20
easyly reviewed and accepted.

The most common case is triggered by "ip route flush cache"
Since it's arming a 2 second timer (ip_rt_min_delay) . When this
timer is fired (softirq), it is flushing the table.

Then, every calls to rt_cache_flush(-1) are asking the same thing, whil=
e=20
rt_cache_flush(0) are synchronous (immediate flushing unless a flush al=
ready=20
is in flight)

net/decnet/dn_table.c:621:                      dn_rt_cache_flush(-1);
net/decnet/dn_table.c:625:              dn_rt_cache_flush(-1);
net/decnet/dn_table.c:700:                              dn_rt_cache_flu=
sh(-1);
net/decnet/dn_table.c:707:                              dn_rt_cache_flu=
sh(-1);
net/decnet/dn_table.c:876:              dn_rt_cache_flush(-1);
net/decnet/dn_rules.c:234:      dn_rt_cache_flush(-1);
net/decnet/dn_fib.c:632:        dn_rt_cache_flush(0);
net/decnet/dn_fib.c:644:                        dn_rt_cache_flush(-1);
net/decnet/dn_fib.c:651:                                dn_rt_cache_flu=
sh(-1);
net/decnet/dn_route.c:339:void dn_rt_cache_flush(int delay)
net/ipv4/devinet.c:1344:        rt_cache_flush(0);
net/ipv4/devinet.c:1359:                        rt_cache_flush(0);
net/ipv4/devinet.c:1374:                rt_cache_flush(0);
net/ipv4/devinet.c:1387:                rt_cache_flush(0);
net/ipv4/fib_frontend.c:126:            rt_cache_flush(-1);
net/ipv4/fib_frontend.c:833:    rt_cache_flush(0);
net/ipv4/fib_frontend.c:847:            rt_cache_flush(-1);
net/ipv4/fib_frontend.c:857:                    rt_cache_flush(-1);
net/ipv4/fib_frontend.c:888:            rt_cache_flush(-1);
net/ipv4/fib_frontend.c:895:            rt_cache_flush(0);
net/ipv4/fib_rules.c:274:       rt_cache_flush(-1);
net/ipv4/fib_trie.c:1235:                               rt_cache_flush(=
-1);
net/ipv4/fib_trie.c:1288:       rt_cache_flush(-1);
net/ipv4/fib_trie.c:1654:               rt_cache_flush(-1);
net/ipv4/route.c:671:void rt_cache_flush(int delay)
net/ipv4/route.c:2688:  rt_cache_flush(0);
net/ipv4/route.c:2700:          rt_cache_flush(flush_delay);
net/ipv4/route.c:2720:  rt_cache_flush(delay);
net/ipv4/arp.c:1215:            rt_cache_flush(0);
net/ipv4/fib_hash.c:459:                                rt_cache_flush(=
-1);
net/ipv4/fib_hash.c:526:        rt_cache_flush(-1);
net/ipv4/fib_hash.c:608:                        rt_cache_flush(-1);

