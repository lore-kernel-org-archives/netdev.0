From: canqun zhang <canqunzhang@gmail.com>
Subject: Re: [PATCH 01/19] netfilter: move nf_conntrack initialize out of
 pernet operations
Date: Fri, 28 Dec 2012 13:32:29 +0800
Message-ID: <CAFFEFTU8kxXV2pQ3B_goRs2Y7p2ecZ1YuSKSjfYF_58eD1tDqw@mail.gmail.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
	<CAFFEFTXT_fkF2pPSxDEEgic80NVWLqBWtFuvs6W9uDUW2aCnqw@mail.gmail.com>
	<87ip7mlr2r.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gao feng <gaofeng@cn.fujitsu.com>, netfilter-devel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, pablo@netfilter.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87ip7mlr2r.fsf@xmission.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

yes=A3=ACNetwork namespaces in general can be cleaned up in any order=A3=
=ACbut
when doing /etc/ini.d/iptables restart, the system need cleaning up
all net namespace,and init_net should be cleanup lastly.init_net is
the first namespace,other net namespace is copied for it ,and it is
diuty for Initializing resources,so It in itself is special.

2012/12/28 Eric W. Biederman <ebiederm@xmission.com>:
> canqun zhang <canqunzhang@gmail.com> writes:
>
>> Hi all
>> As discussed above,if the host machine create several linux
>> containers, there will be several  net namespaces.Resources with "nf
>> conntrack" are registered or unregistered on the first net
>> namespace(init_net),But init_net is not unregistered lastly,so
>> cleanuping other net namespaces  will triger painic.
>> If net namespaces are created  with the order of 1,2,...n,they shoul=
d
>> be cleaned with the order of n,...2,1,so in this case init_net will =
be
>> unregistered lastly.
>
> No.  Network namespaces in general can be cleaned up in any order.
>
> In particular you should never ever expect to see the order
> n,n-1,n-2,...,2,1.
>
> It may make sense to special case init_net in the cleanup order
> but I would really rather not.
>
> Now init_net is special and really should never be cleaned up
> for non-modular code.  So it almost makes sense to special
> case init_net.
>
> Does anyone know why Alexy decided to do this only for init_net?
>
> My inclination is that Gao Feng is on the rigt path by just removing
> the strange init_net special case and performing the work once
> per module load, and once per module unload.
>
>> I fixed it up (see below). I have taken a lot of test!
>
> Thank you.
>
> It is nice to see that we have exposed this mis-assumption.
>
> I am inclined to leave the order of this list as is so that
> other assumptions of network namespace unregistration order
> are exposed.
>
> Unless there is a truly good reason to perform magic on init_net.
>
> Eric
>
>> diff -r 6a1a258923f5 -r 2667e89e6f50 net/core/net_namespace.c
>> --- a/net/core/net_namespace.c  Fri Dec 28 11:01:17 2012 +0800
>> +++ b/net/core/net_namespace.c  Fri Dec 28 11:05:12 2012 +0800
>> @@ -450,7 +450,7 @@
>>
>>         list_del(&ops->list);
>>         for_each_net(net)
>> -               list_add_tail(&net->exit_list, &net_exit_list);
>> +              list_add(&net->exit_list, &net_exit_list);
>>         ops_exit_list(ops, &net_exit_list);
>>         ops_free_list(ops, &net_exit_lis
>>
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
