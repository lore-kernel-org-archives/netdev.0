From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [patch v2 04/11] nf_conntrack_netlink: pass nf_conntrack_netlink
 module to netlink_dump_start
Date: Wed, 26 Sep 2012 20:35:53 +0800
Message-ID: <5062F6A9.7020309@cn.fujitsu.com>
References: <1348648888-24943-1-git-send-email-gaofeng@cn.fujitsu.com> <1348648888-24943-4-git-send-email-gaofeng@cn.fujitsu.com> <20120926092632.GA21589@1984> <5062CE07.1080704@cn.fujitsu.com> <20120926095837.GA23815@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	steffen.klassert@secunet.com, netfilter-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org, stephen.hemminger@vyatta.com,
	jengelh@inai.de
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120926095837.GA23815@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B409=E6=9C=8826=E6=97=A5 17:58, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Wed, Sep 26, 2012 at 05:42:31PM +0800, Gao feng wrote:
>> Hi Pablo:
>>
>> =E4=BA=8E 2012=E5=B9=B409=E6=9C=8826=E6=97=A5 17:26, Pablo Neira Ayu=
so =E5=86=99=E9=81=93:
>>> On Wed, Sep 26, 2012 at 04:41:21PM +0800, Gao feng wrote:
>>>> use proper netlink_dump_control.done and .module to avoid panic.
>>>>
>>>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>>>> ---
>>>>  net/netfilter/nf_conntrack_netlink.c |    8 ++++++++
>>>>  1 files changed, 8 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/=
nf_conntrack_netlink.c
>>>> index 9807f32..509a257 100644
>>>> --- a/net/netfilter/nf_conntrack_netlink.c
>>>> +++ b/net/netfilter/nf_conntrack_netlink.c
>>>> @@ -706,6 +706,7 @@ static int ctnetlink_done(struct netlink_callb=
ack *cb)
>>>>  		nf_ct_put((struct nf_conn *)cb->args[1]);
>>>>  	if (cb->data)
>>>>  		kfree(cb->data);
>>>> +	netlink_dump_done(cb);
>>>
>>> I think you can call netlink_dump_done from af_netlink.c:
>>>
>>> static int netlink_dump(struct sock *sk)=20
>>>         ...
>>>         if (cb->done) {
>>>                 cb->done(cb);
>>>                 netlink_dump_done(...);
>>>         }
>>>
>>> Thus, you don't need to change netlink_dump_control in every netlin=
k
>>> subsystem.
>>
>> because cb->done is called by netlink_sock_destruct too,it's very us=
efully
>> when userspace program only send dump request to kernel without read=
ing
>> data from kernel.
>=20
> Then add that to netlink_sock_destruct as well. If possible, I prefer
> if this remains in the netlink core to avoid leaking module refcount
> if you forget to call netlink_dump_done.

make sense,I will update it in next version.
Thanks!

>=20
>>>
>>>>  	return 0;
>>>>  }
>>>> =20
>>>> @@ -1022,6 +1023,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, s=
truct sk_buff *skb,
>>>>  		struct netlink_dump_control c =3D {
>>>>  			.dump =3D ctnetlink_dump_table,
>>>>  			.done =3D ctnetlink_done,
>>>> +			.module =3D THIS_MODULE,
>>>
>>> You can do something similar to:
>>>
>>> 9f00d97 netlink: hide struct module parameter in netlink_kernel_cre=
ate
>>>
>>> by definiting netlink_dump_start as static inline and using
>>> THIS_MODULE from there.
>>>
>>> If I'm not missing anything, with those two changes, you will not n=
eed
>>> to modify any caller and it will result one single patch.
>>>
>>
>> You can see the patch [11/11], THIS_MODULE in infiniband/core/cma.c
>> means module rdma_cm,but we call netlink_dump_start in infiniband/co=
re/netlink.c
>=20
> You can still use __netlink_dump_start for that case, which allows yo=
u
> to specify a custom struct module * parameter. But for most cases,
> netlink_dump_start (which hides THIS_MODULE) should be fine.
>=20

I don't know how to deal with module_put in this way.
and I think my  way is simple enough.

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
