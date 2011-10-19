From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] route:ip_rt_frag_needed always return unzero
Date: Wed, 19 Oct 2011 10:33:00 +0800
Message-ID: <4E9E36DC.4050304@cn.fujitsu.com>
References: <1318921469-25599-1-git-send-email-gaofeng@cn.fujitsu.com> <1318929797.2657.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4E9E2929.7070701@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51859 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752385Ab1JSCch convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 22:32:37 -0400
In-Reply-To: <4E9E2929.7070701@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2011=E5=B9=B410=E6=9C=8819=E6=97=A5 09:34, Gao feng =E5=86=99=
=E9=81=93:
> 2011.10.18 17:23, Eric Dumazet wrote:
>> Le mardi 18 octobre 2011 =C3=A0 15:04 +0800, Gao feng a =C3=A9crit :
>>> int function ip_rt_frag_need,if peer is null,
>>> there is no need to do ipprot->err_handler.
>>> I am right?
>>>
>>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>>> ---
>>>  net/ipv4/route.c |    2 +-
>>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>>> index 075212e..6cde0fa 100644
>>> --- a/net/ipv4/route.c
>>> +++ b/net/ipv4/route.c
>>> @@ -1574,7 +1574,7 @@ unsigned short ip_rt_frag_needed(struct net *=
net, const struct iphdr *iph,
>>> =20
>>>  		atomic_inc(&__rt_peer_genid);
>>>  	}
>>> -	return est_mtu ? : new_mtu;
>>> +	return est_mtu;
>>>  }
>>> =20
>>>  static void check_peer_pmtu(struct dst_entry *dst, struct inet_pee=
r *peer)
>>
>> No idea why you want this, your changelog is a bit cryptic :)
>>
>> Wont this bypass the raw_icmp_error(skb, protocol, info);
>> call in icmp_unreach() as well ?
>>
>>
>=20
> thanks Eric!
>=20
> I mean that the pmtu is update by inet_peer->pmtu_learned as I know.
> so in function ip_rt_frag_needed,
> if inet_peer is null or someting else make the setting of inet_peer->=
pmtu_learned failed.
> there is no need to call function tcp_v4_err.
>=20
> the call stack is
> icmp_unreach
>   |
>   |--->ip_rt_frag_needed(fill inet_peer)
>   |
>   |--->raw_icmp_error()
>   |
>   |--->ipprot->err_handler(tcp_v4_err or something else)
> 	|
> 	|--->tcp_v4_err(frag need icmp is triggered by tcp packet)
> 		|
> 		|--->do_pmtu_discovery
> 		(in this function both __sk_dst_check or dst->ops->update_pmtu
> 		need struct inet_peer to update pmtu)
>=20
> so,I think when set inet_peer->pmtu_learned failed,
> in func icmp_unreach we should goto out immediately.
>=20
> And it's confuse me that why func ping_err and udp_err not update the=
 pmtu?
> What I miss?
> --

And move atomic_inc(&__rt_peer_genid) just like func ip_rt_update_pmtu?

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6cde0fa..3e1aa5c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1568,11 +1568,12 @@ unsigned short ip_rt_frag_needed(struct net *ne=
t, const
                        est_mtu =3D mtu;
                        peer->pmtu_learned =3D mtu;
                        peer->pmtu_expires =3D pmtu_expires;
+
+                       atomic_inc(&__rt_peer_genid);
                }

                inet_putpeer(peer);

-               atomic_inc(&__rt_peer_genid);
        }
        return est_mtu;
 }
