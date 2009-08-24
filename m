From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: bridge: refcount fix
Date: Mon, 24 Aug 2009 19:32:20 +0200
Message-ID: <4A92CEA4.6020604@gmail.com>
References: <4A92CB67.1080401@gmail.com> <4A92CC71.2000300@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Bart De Schuymer <bdschuym@pandora.be>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48813 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752989AbZHXRcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 13:32:21 -0400
In-Reply-To: <4A92CC71.2000300@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> Hi David
>>
>> I found following by code review only, I am not sure it is critical =
enough for net-2.6
>>
>> This is a stable candidate, bug is more than 2 years old.
>>
>> Thanks
>>
>> commit f216f082b2b37c4943f1e7c393e2786648d48f6f
>> ([NETFILTER]: bridge netfilter: deal with martians correctly)
>> added a refcount leak on in_dev.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
>> index 4fde742..c62eca3 100644
>> --- a/net/bridge/br_netfilter.c
>> +++ b/net/bridge/br_netfilter.c
>> @@ -386,6 +386,7 @@ static int br_nf_pre_routing_finish(struct sk_bu=
ff *skb)
>>  				dst_release((struct dst_entry *)rt);
>>  			}
>>  free_skb:
>> +			in_dev_put(in_dev);
>>  			kfree_skb(skb);
>>  			return 0;
>=20
> I guess we could simply use __in_dev_get_rcu() here since all
> netfilter hooks are running under rcu_read_lock() anyways.

Ah very good point, Thanks Patrick.

[PATCH] netfilter: bridge: refcount fix

commit f216f082b2b37c4943f1e7c393e2786648d48f6f
([NETFILTER]: bridge netfilter: deal with martians correctly)
added a refcount leak on in_dev.

Instead of using in_dev_get(), we can use __in_dev_get_rcu(),
as netfilter hooks are running under rcu_read_lock(), as pointed
by Patrick.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 4fde742..907a82e 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -359,7 +359,7 @@ static int br_nf_pre_routing_finish(struct sk_buff =
*skb)
 				},
 				.proto =3D 0,
 			};
-			struct in_device *in_dev =3D in_dev_get(dev);
+			struct in_device *in_dev =3D __in_dev_get_rcu(dev);
=20
 			/* If err equals -EHOSTUNREACH the error is due to a
 			 * martian destination or due to the fact that
