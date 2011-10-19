From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] route:ip_rt_frag_needed always return unzero
Date: Wed, 19 Oct 2011 09:34:33 +0800
Message-ID: <4E9E2929.7070701@cn.fujitsu.com>
References: <1318921469-25599-1-git-send-email-gaofeng@cn.fujitsu.com> <1318929797.2657.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50455 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752105Ab1JSBeK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 21:34:10 -0400
In-Reply-To: <1318929797.2657.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011.10.18 17:23, Eric Dumazet wrote:
> Le mardi 18 octobre 2011 =C3=A0 15:04 +0800, Gao feng a =C3=A9crit :
>> int function ip_rt_frag_need,if peer is null,
>> there is no need to do ipprot->err_handler.
>> I am right?
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> ---
>>  net/ipv4/route.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>> index 075212e..6cde0fa 100644
>> --- a/net/ipv4/route.c
>> +++ b/net/ipv4/route.c
>> @@ -1574,7 +1574,7 @@ unsigned short ip_rt_frag_needed(struct net *n=
et, const struct iphdr *iph,
>> =20
>>  		atomic_inc(&__rt_peer_genid);
>>  	}
>> -	return est_mtu ? : new_mtu;
>> +	return est_mtu;
>>  }
>> =20
>>  static void check_peer_pmtu(struct dst_entry *dst, struct inet_peer=
 *peer)
>=20
> No idea why you want this, your changelog is a bit cryptic :)
>=20
> Wont this bypass the raw_icmp_error(skb, protocol, info);
> call in icmp_unreach() as well ?
>=20
>=20

thanks Eric!

I mean that the pmtu is update by inet_peer->pmtu_learned as I know.
so in function ip_rt_frag_needed,
if inet_peer is null or someting else make the setting of inet_peer->pm=
tu_learned failed.
there is no need to call function tcp_v4_err.

the call stack is
icmp_unreach
  |
  |--->ip_rt_frag_needed(fill inet_peer)
  |
  |--->raw_icmp_error()
  |
  |--->ipprot->err_handler(tcp_v4_err or something else)
	|
	|--->tcp_v4_err(frag need icmp is triggered by tcp packet)
		|
		|--->do_pmtu_discovery
		(in this function both __sk_dst_check or dst->ops->update_pmtu
		need struct inet_peer to update pmtu)

so,I think when set inet_peer->pmtu_learned failed,
in func icmp_unreach we should goto out immediately.

And it's confuse me that why func ping_err and udp_err not update the p=
mtu?
What I miss?
