From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] sit: fix panic with route cache in ip tunnels
Date: Wed, 19 Feb 2014 17:50:06 +0100
Message-ID: <5304E0BE.3020900@6wind.com>
References: <1392826532-19282-1-git-send-email-nicolas.dichtel@6wind.com> <1392828209.18849.4.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:62296 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833AbaBSQuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 11:50:14 -0500
Received: by mail-wi0-f169.google.com with SMTP id e4so4745877wiv.4
        for <netdev@vger.kernel.org>; Wed, 19 Feb 2014 08:50:13 -0800 (PST)
In-Reply-To: <1392828209.18849.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 19/02/2014 17:43, Eric Dumazet a =C3=A9crit :
> On Wed, 2014-02-19 at 17:15 +0100, Nicolas Dichtel wrote:
>> Bug introduced by commit 7d442fab0a67 ("ipv4: Cache dst in tunnels")=
=2E
>>
>> Because sit code does not call ip_tunnel_init(), the dst_cache was n=
ot
>> initialized.
>>
>> CC: Tom Herbert <therbert@google.com>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>   net/ipv6/sit.c | 9 +++++++++
>>   1 file changed, 9 insertions(+)
>>
>> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
>> index 3dfbcf1dcb1c..5ff33d9bd5de 100644
>> --- a/net/ipv6/sit.c
>> +++ b/net/ipv6/sit.c
>> @@ -1326,6 +1326,9 @@ static const struct net_device_ops ipip6_netde=
v_ops =3D {
>>
>>   static void ipip6_dev_free(struct net_device *dev)
>>   {
>> +	struct ip_tunnel *tunnel =3D netdev_priv(dev);
>> +
>> +	free_percpu(tunnel->dst_cache);
>>   	free_percpu(dev->tstats);
>>   	free_netdev(dev);
>>   }
>> @@ -1375,6 +1378,12 @@ static int ipip6_tunnel_init(struct net_devic=
e *dev)
>>   		u64_stats_init(&ipip6_tunnel_stats->syncp);
>>   	}
>>
>> +	tunnel->dst_cache =3D alloc_percpu(struct ip_tunnel_dst);
>> +	if (!tunnel->dst_cache) {
>> +		free_percpu(dev->tstats);
>> +		return -ENOMEM;
>> +	}
>> +
>>   	return 0;
>>   }
>>
>
> I do not think this patch is complete.
>
> It seems to lack a tunnel_dst_reset_all() or something to properly
> release the dst.

Yes, it's why I ask David to drop it ;-)
