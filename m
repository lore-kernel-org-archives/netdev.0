From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: Re: [PATCH 4/4 V2] net,rcu: don't assume the size of struct rcu_head
Date: Wed, 02 Mar 2011 10:46:30 +0800
Message-ID: <4D6DAF86.2000407@cn.fujitsu.com>
References: <4D6CA860.3020409@cn.fujitsu.com>	 <20110301.001638.104075130.davem@davemloft.net>	 <4D6CB414.8050107@cn.fujitsu.com> <1298971213.3284.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mingo@elte.hu,
	paulmck@linux.vnet.ibm.com, cl@linux-foundation.org,
	penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298971213.3284.4.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/01/2011 05:20 PM, Eric Dumazet wrote:
> Le mardi 01 mars 2011 =C3=A0 16:53 +0800, Lai Jiangshan a =C3=A9crit =
:
>> On 03/01/2011 04:16 PM, David Miller wrote:
>>> From: Lai Jiangshan <laijs@cn.fujitsu.com>
>>> Date: Tue, 01 Mar 2011 16:03:44 +0800
>>>
>>>>
>>>> struct dst_entry assumes the size of struct rcu_head as 2 * sizeof=
(long)
>>>> and manually adds pads for aligning for "__refcnt".
>>>>
>>>> When the size of struct rcu_head is changed, these manual padding
>>>> is wrong. Use __attribute__((aligned (64))) instead.
>>>>
>>>> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
>>>
>>> We don't want to use the align if it's going to waste lots of space=
=2E
>>>
>>> Instead we want to rearrange the structure so that the alignment co=
mes
>>> more cheaply.
>>
>> Subject: [PATCH 4/4 V2] net,rcu: don't assume the size of struct rcu=
_head
>>
>> struct dst_entry assumes the size of struct rcu_head as 2 * sizeof(l=
ong)
>> and manually adds pads for aligning for "__refcnt".
>>
>> When the size of struct rcu_head is changed, these manual padding
>> are hardly suit for the changes. So we rearrange the structure,
>> and move the seldom access rcu_head to the end of the structure.
>>
>> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
>> ---
>>
>> diff --git a/include/net/dst.h b/include/net/dst.h
>> index 93b0310..d8c5296 100644
>> --- a/include/net/dst.h
>> +++ b/include/net/dst.h
>> @@ -37,7 +37,6 @@
>>  struct sk_buff;
>> =20
>>  struct dst_entry {
>> -	struct rcu_head		rcu_head;
>>  	struct dst_entry	*child;
>>  	struct net_device       *dev;
>>  	short			error;
>> @@ -78,6 +77,13 @@ struct dst_entry {
>>  	__u32			__pad2;
>>  #endif
>> =20
>> +	unsigned long		lastuse;
>> +	union {
>> +		struct dst_entry	*next;
>> +		struct rtable __rcu	*rt_next;
>> +		struct rt6_info		*rt6_next;
>> +		struct dn_route __rcu	*dn_next;
>> +	};
>> =20
>>  	/*
>>  	 * Align __refcnt to a 64 bytes alignment
>> @@ -92,13 +98,7 @@ struct dst_entry {
>>  	 */
>>  	atomic_t		__refcnt;	/* client references	*/
>>  	int			__use;
>> -	unsigned long		lastuse;
>> -	union {
>> -		struct dst_entry	*next;
>> -		struct rtable __rcu	*rt_next;
>> -		struct rt6_info		*rt6_next;
>> -		struct dn_route __rcu	*dn_next;
>> -	};
>> +	struct rcu_head		rcu_head;
>>  };
>> =20
>>  #ifdef __KERNEL__
>=20
> Nope...
>=20
> "lastuse" and "next" must be in this place, or this introduce false
> sharing we wanted to avoid in the past.
>=20
> I suggest you leave this code as is, we will address the problem when
> rcu_head changes (assuming we can test a CONFIG_RCU_HEAD_DEBUG or
> something)
>=20
> First part of "struct dst_entry" is mostly read, while part beginning
> after refcnt is often written.
>=20

Is it the cause of false sharing? I thought that all are rare write(exc=
ept __refcnt)
since it is protected by RCU.

Do you allow me just move the seldom access rcu_head to the end of the =
structure
and add pads before __refcnt? I guess it increases about 3% the size of=
 dst_entry.

I accept that I leave this code as is, when I change rcu_head I will no=
tify you.

Thanks,
Lai
