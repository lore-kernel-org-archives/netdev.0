From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net-next v4 1/6] bonding: simplify and use RCU protection
 for 3ad xmit path
Date: Sun, 08 Sep 2013 14:05:23 +0800
Message-ID: <522C13A3.9090206@gmail.com>
References: <52298407.9040103@huawei.com> <20130907142041.GA20237@redhat.com> <522B3BF1.2020208@redhat.com> <20130907150350.GF26163@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:46568 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987Ab3IHGOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Sep 2013 02:14:45 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so4842665pbc.11
        for <netdev@vger.kernel.org>; Sat, 07 Sep 2013 23:14:45 -0700 (PDT)
In-Reply-To: <20130907150350.GF26163@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/9/7 23:03, Veaceslav Falico =E5=86=99=E9=81=93:
> On Sat, Sep 07, 2013 at 04:45:05PM +0200, Nikolay Aleksandrov wrote:
>>
>> On 09/07/2013 04:20 PM, Veaceslav Falico wrote:
>>> On Fri, Sep 06, 2013 at 03:28:07PM +0800, Ding Tianhong wrote:
> ...snip...
>>> diff --git a/include/linux/rculist.h b/include/linux/rculist.h
>>> index f4b1001..37b49d1 100644
>>> --- a/include/linux/rculist.h
>>> +++ b/include/linux/rculist.h
>>> @@ -23,6 +23,7 @@
>>> * way, we must not access it directly
>>> */
>>> #define list_next_rcu(list) (*((struct list_head __rcu
>>> **)(&(list)->next)))
>>> +#define list_prev_rcu(list) (*((struct list_head __rcu
>>> **)(&(list)->prev)))
>>>
>>> /*
>>> * Insert a new entry between two known consecutive entries.
>>> @@ -271,6 +272,12 @@ static inline void list_splice_init_rcu(struct
>>> list_head *list,
>>> likely(__ptr !=3D __next) ? container_of(__next, type, member) : NU=
LL; \
>>> })
>>>
>>> +#define list_last_or_null_rcu(ptr, type, member) \
>>> + ({struct list_head *__ptr =3D (ptr); \
>>> + struct list_head __rcu *__last =3D list_prev_rcu(__ptr); \
>>> + likely(__ptr !=3D __last) ? container_of(__prev, type, member) :=20
>>> NULL; \
>>> + })
>>> +
>> Hi,
>> Actually I don't think you can dereference ->prev and use the standa=
rd
>> list_del_rcu because it guarantees only the ->next ptr will be valid=
 and
>> ->prev is set to LIST_POISON2.
>> IMO, you'll need something like this:=20
>> https://lkml.org/lkml/2012/7/25/193
>> with the bidir_del and all that.
>
> Yeah, right, my bad - we can rely only on the ->next pointer, indeed,
> missed that part. RCU is hard :).
>
> So it'll be a lot harder to implement bond_last_slave_rcu() in a
> 'straightforward' approach.
>
> I'd rather go in the opposite direction here - i.e. drop the 'reverse=
'
> traversal completely, and all the use cases for bond_last_slave_rcu()=
=2E=20
> I've
> got some patches already - http://patchwork.ozlabs.org/patch/272076/=20
> doing
> that, and hopefully will remove the whole 'backword' traversal comple=
tely
> in the future.
>

Although RCU is truely difficult to understand, but it is very=20
interesting and beautiful,
I will follow your footsteps and finish it.

>>
>> But in any case I complete agree with Veaceslav here. Read all the
>> documentation carefully :-)
>>
>> Cheers,
>> Nik
>>

good lession, read it complete and agreed, it is a hard work to do.
I need more time to review the Veaceslav's patchset and improve my
thought, thanks Nik and Veaceslav.

Best regards
Ding

>>> /**
>>> * list_for_each_entry_rcu - iterate over rcu list of given type
>>> * @pos: the type * to use as a loop cursor.
>>> ------- END OF PATCH ------
>>>
>>> Anyway, it's up to you.
>>>
>>> Hope that helps.
>>
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
>
