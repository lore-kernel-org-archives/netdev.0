From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [patch v2 04/11] nf_conntrack_netlink: pass nf_conntrack_netlink
 module to netlink_dump_start
Date: Wed, 26 Sep 2012 17:42:31 +0800
Message-ID: <5062CE07.1080704@cn.fujitsu.com>
References: <1348648888-24943-1-git-send-email-gaofeng@cn.fujitsu.com> <1348648888-24943-4-git-send-email-gaofeng@cn.fujitsu.com> <20120926092632.GA21589@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	steffen.klassert@secunet.com, netfilter-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org, stephen.hemminger@vyatta.com,
	jengelh@inai.de
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20120926092632.GA21589@1984>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo:

=E4=BA=8E 2012=E5=B9=B409=E6=9C=8826=E6=97=A5 17:26, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Wed, Sep 26, 2012 at 04:41:21PM +0800, Gao feng wrote:
>> use proper netlink_dump_control.done and .module to avoid panic.
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> ---
>>  net/netfilter/nf_conntrack_netlink.c |    8 ++++++++
>>  1 files changed, 8 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf=
_conntrack_netlink.c
>> index 9807f32..509a257 100644
>> --- a/net/netfilter/nf_conntrack_netlink.c
>> +++ b/net/netfilter/nf_conntrack_netlink.c
>> @@ -706,6 +706,7 @@ static int ctnetlink_done(struct netlink_callbac=
k *cb)
>>  		nf_ct_put((struct nf_conn *)cb->args[1]);
>>  	if (cb->data)
>>  		kfree(cb->data);
>> +	netlink_dump_done(cb);
>=20
> I think you can call netlink_dump_done from af_netlink.c:
>=20
> static int netlink_dump(struct sock *sk)=20
>         ...
>         if (cb->done) {
>                 cb->done(cb);
>                 netlink_dump_done(...);
>         }
>=20
> Thus, you don't need to change netlink_dump_control in every netlink
> subsystem.

because cb->done is called by netlink_sock_destruct too,it's very usefu=
lly
when userspace program only send dump request to kernel without reading
data from kernel.

>=20
>>  	return 0;
>>  }
>> =20
>> @@ -1022,6 +1023,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, str=
uct sk_buff *skb,
>>  		struct netlink_dump_control c =3D {
>>  			.dump =3D ctnetlink_dump_table,
>>  			.done =3D ctnetlink_done,
>> +			.module =3D THIS_MODULE,
>=20
> You can do something similar to:
>=20
> 9f00d97 netlink: hide struct module parameter in netlink_kernel_creat=
e
>=20
> by definiting netlink_dump_start as static inline and using
> THIS_MODULE from there.
>=20
> If I'm not missing anything, with those two changes, you will not nee=
d
> to modify any caller and it will result one single patch.
>=20

You can see the patch [11/11], THIS_MODULE in infiniband/core/cma.c
means module rdma_cm,but we call netlink_dump_start in infiniband/core/=
netlink.c

we should make sure the cb.moudle point to the module which cb.dump bel=
ongs to.
we can call netlink_dump_start to set cb->dump everywhere, so I think w=
e still
need to pass struct module to the netlink_callback.

thanks for your comments!
