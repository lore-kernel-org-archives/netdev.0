From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RCU PATCH 06/14] net: sched: fw use RCU
Date: Wed, 12 Mar 2014 09:41:35 -0700
Message-ID: <53208E3F.5090401@gmail.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>  <20140310170546.3011.82918.stgit@nitbit.x32> <1394473279.3607.46.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:53665 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755197AbaCLQl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 12:41:59 -0400
Received: by mail-ob0-f169.google.com with SMTP id va2so10173011obc.14
        for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 09:41:59 -0700 (PDT)
In-Reply-To: <1394473279.3607.46.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/2014 10:41 AM, Eric Dumazet wrote:
> On Mon, 2014-03-10 at 10:05 -0700, John Fastabend wrote:
>> RCU'ify fw classifier.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>   net/sched/cls_fw.c |  110 ++++++++++++++++++++++++++++++++++++----=
------------
>>   1 file changed, 76 insertions(+), 34 deletions(-)
>>
>> diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
>> index a366537..ff392f1 100644
>> --- a/net/sched/cls_fw.c
>> +++ b/net/sched/cls_fw.c
>> @@ -32,18 +32,21 @@
>>   #define HTSIZE (PAGE_SIZE/sizeof(struct fw_filter *))
>>
>>   struct fw_head {
>> -	struct fw_filter *ht[HTSIZE];
>> +	struct rcu_head	rcu;
>
> Try to put 'rcu' at the end of structures, we do not need it in fast
> path.
>
>> +	struct fw_filter __rcu *ht[HTSIZE];
>>   	u32 mask;
>>   };
>>
>>   struct fw_filter {
>> -	struct fw_filter	*next;
>> +	struct fw_filter __rcu	*next;
>> +	struct rcu_head		rcu;
>
> same remark
>

[...]

>>
>> @@ -150,29 +159,32 @@ static void fw_destroy(struct tcf_proto *tp)
>>   		return;
>>
>>   	for (h =3D 0; h < HTSIZE; h++) {
>> -		while ((f =3D head->ht[h]) !=3D NULL) {
>> -			head->ht[h] =3D f->next;
>> -			fw_delete_filter(tp, f);
>> +		while ((f =3D rtnl_dereference(head->ht[h])) !=3D NULL) {
>> +			rcu_assign_pointer(head->ht[h],
>> +					   rtnl_dereference(f->next));
>> +			call_rcu(&f->rcu, fw_delete_filter);
>>   		}
>>   	}
>> -	kfree(head);
>> +	rcu_assign_pointer(tp->root, NULL);
>
> RCU_INIT_POINTER
>
>> +	kfree_rcu(head, rcu);

Rearranging the rcu_head placement above results in this error:

net/sched/cls_fw.c: In function =E2=80=98fw_destroy=E2=80=99:
net/sched/cls_fw.c:169:279: error: call to =E2=80=98__compiletime_asser=
t_169=E2=80=99=20
declared with attribute error: BUILD_BUG_ON failed:=20
!__is_kfree_rcu_offset(__builtin_offsetof(typeof(*(head)),rcu))


However it seems best to have the rcu_head at the end of the struct
so I'll just convert the kfree_rcu() to call_rcu().

Thanks,
John

--=20
John Fastabend         Intel Corporation
