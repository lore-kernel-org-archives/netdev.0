From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V3 3/3] net: Add GRO support for vxlan traffic
Date: Thu, 9 Jan 2014 08:32:24 +0200
Message-ID: <52CE4278.6050505@mellanox.com>
References: <1389213278-2200-1-git-send-email-ogerlitz@mellanox.com>	 <1389213278-2200-4-git-send-email-ogerlitz@mellanox.com> <1389219101.31367.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <hkchu@google.com>, <edumazet@google.com>,
	<herbert@gondor.apana.org.au>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <yanb@mellanox.com>, <shlomop@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog122.obsmtp.com ([207.126.144.153]:53702 "EHLO
	eu1sys200aog122.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751201AbaAIGce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 01:32:34 -0500
In-Reply-To: <1389219101.31367.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2014 00:11, Eric Dumazet wrote:
> On Wed, 2014-01-08 at 22:34 +0200, Or Gerlitz wrote:
>
>> +
>>   /* Notify netdevs that UDP port started listening */
>> -static void vxlan_notify_add_rx_port(struct sock *sk)
>> +static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
>>   {
>>   	struct net_device *dev;
>> +	struct sock *sk = vs->sock->sk;
>>   	struct net *net = sock_net(sk);
>>   	sa_family_t sa_family = sk->sk_family;
>>   	__be16 port = inet_sk(sk)->inet_sport;
>> @@ -569,12 +671,16 @@ static void vxlan_notify_add_rx_port(struct sock *sk)
>>   							    port);
>>   	}
>>   	rcu_read_unlock();
>> +
>> +	if (sa_family == AF_INET)
>> +		call_rcu(&vs->rcu, vxlan_add_udp_offload);
> Why waiting RCU grace period here?

Basically the add operation can be done right away, however, since the 
delete operation can't be done
instantly when we want it, I wanted to protect against a series of 
add/del/add in times T1 < T2 < T3

T1 add(X)
T2 del(X)
T3 add(X)

where the delete is deferred and as a result the 2nd add is done before 
the delete and @ the end offload X is not added in the 2nd time.From 
your other comment below I conclude that I probably miss something about 
the rcu usage here, so will give it further thought.



>
>>   }
>>   
>>   /* Notify netdevs that UDP port is no more listening */
>> -static void vxlan_notify_del_rx_port(struct sock *sk)
>> +static void vxlan_notify_del_rx_port(struct vxlan_sock *vs)
>>   {
>>   	struct net_device *dev;
>> +	struct sock *sk = vs->sock->sk;
>>   	struct net *net = sock_net(sk);
>>   	sa_family_t sa_family = sk->sk_family;
>>   	__be16 port = inet_sk(sk)->inet_sport;
>> @@ -586,6 +692,9 @@ static void vxlan_notify_del_rx_port(struct sock *sk)
>>   							    port);
>>   	}
>>   	rcu_read_unlock();
>> +
>> +	if (sa_family == AF_INET)
>> +		call_rcu(&vs->rcu, vxlan_del_udp_offload);
>>   }
> This looks buggy.
>
> You need to :
>
> 1) remove the offload structure from list
> 2) Then wait rcu grace period, and finally free the memory
>
>
>
