From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH] net namespace: wrap for_each_net with rtnl_lock
Date: Thu, 4 Jul 2013 15:57:14 +0800
Message-ID: <51D52ADA.5020905@windriver.com>
References: <1372918855-3815-1-git-send-email-fan.du@windriver.com> <87txkaolfo.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <serge.hallyn@canonical.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:43212 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755420Ab3GDH5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 03:57:22 -0400
In-Reply-To: <87txkaolfo.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Eric

Thanks for your reply!

On 2013=E5=B9=B407=E6=9C=8804=E6=97=A5 15:04, Eric W. Biederman wrote:
> Fan Du<fan.du@windriver.com>  writes:
>
>> The read access to net_namespace_list with for_each_net should alway=
s
>> be protected with rtnl_lock agiast any adding/removing operation fro=
m
>> the list.
>
> That is not correct.  The rtnl_lock does not protect the
> net_namespace_list.  The net_mutex provides that protection.
>
> Modifications to the net_namespace_list are under both the rtnl_lock
> and the net_mutex which removes the need of grabbing the net_mutex wh=
en
> you just need to traverse the list of network namespaces.  This avoid=
s a
> lock ordering problem as most places it is desirable to traverse the
> net namespace list the rtnl_lock is already held.


By my understanding, net_mutex protects operations on pernet_list, and =
rtln_lock
protects net_namespace_list. net_mutex has side effects on net_namespac=
e_list,
because we try to hold rtnl_lock to modify net_namespace_list after alr=
eady holding
net_mutex(copy_net_ns). Sorry, I cann't understand the necessity by doi=
ng so.

(1)
         mutex_lock(&net_mutex);
         rv =3D setup_net(net, user_ns);
         if (rv =3D=3D 0) {
                 rtnl_lock();
                 list_add_tail_rcu(&net->list, &net_namespace_list);
                 rtnl_unlock();
         }
         mutex_unlock(&net_mutex);

why could we do it separately as below?

(2)
         mutex_lock(&net_mutex);
         rv =3D setup_net(net, user_ns);
         mutex_unlock(&net_mutex);
         if (rv =3D=3D 0) {
                 rtnl_lock();
                 list_add_tail_rcu(&net->list, &net_namespace_list);
                 rtnl_unlock();
         }


>
> In general the init methods will deadlock if you call them with the
> rtnl_lock held, as they grab the rtnl_lock when creating network devi=
ces
> etc.

Yes, I understand. This is reason why we do it in (1) style.


> The methods you change are protected by the net_mutex so I don't see =
any
> problems here.
> Was this patch inspired by code review or was there an actual problem
> that inspired it?

It's code review, no real alarm :)

>> Signed-off-by: Fan Du<fan.du@windriver.com>
>> ---
>>   net/core/net_namespace.c |    4 ++++
>>   1 files changed, 4 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
>> index f976520..f3808ff 100644
>> --- a/net/core/net_namespace.c
>> +++ b/net/core/net_namespace.c
>> @@ -445,12 +445,14 @@ static int __register_pernet_operations(struct=
 list_head *list,
>>
>>   	list_add_tail(&ops->list, list);
>>   	if (ops->init || (ops->id&&  ops->size)) {
>> +		rtnl_lock();
>>   		for_each_net(net) {
>>   			error =3D ops_init(ops, net);
>>   			if (error)
>>   				goto out_undo;
>>   			list_add_tail(&net->exit_list,&net_exit_list);
>>   		}
>> +		rtnl_unlock();
>>   	}
>>   	return 0;
>>
>> @@ -468,8 +470,10 @@ static void __unregister_pernet_operations(stru=
ct pernet_operations *ops)
>>   	LIST_HEAD(net_exit_list);
>>
>>   	list_del(&ops->list);
>> +	rtnl_lock();
>>   	for_each_net(net)
>>   		list_add_tail(&net->exit_list,&net_exit_list);
>> +	rtnl_unlock();
>>   	ops_exit_list(ops,&net_exit_list);
>>   	ops_free_list(ops,&net_exit_list);
>>   }
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
