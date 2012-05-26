From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 04/17] netfilter: add namespace support for l4proto_generic
Date: Sat, 26 May 2012 10:36:36 +0800
Message-ID: <4FC041B4.6080501@cn.fujitsu.com>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com> <1336985547-31960-5-git-send-email-gaofeng@cn.fujitsu.com> <20120523103232.GD2836@1984> <4FBD8B40.4020303@cn.fujitsu.com> <20120524095222.GA13091@1984> <4FBE1678.7050903@cn.fujitsu.com> <20120524144038.GB15898@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120524144038.GB15898@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B405=E6=9C=8824=E6=97=A5 22:40, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Thu, May 24, 2012 at 07:07:36PM +0800, Gao feng wrote:
>> =E4=BA=8E 2012=E5=B9=B405=E6=9C=8824=E6=97=A5 17:52, Pablo Neira Ayu=
so =E5=86=99=E9=81=93:
>>> On Thu, May 24, 2012 at 09:13:36AM +0800, Gao feng wrote:
>>>> =E4=BA=8E 2012=E5=B9=B405=E6=9C=8823=E6=97=A5 18:32, Pablo Neira A=
yuso =E5=86=99=E9=81=93:
>>>>> On Mon, May 14, 2012 at 04:52:14PM +0800, Gao feng wrote:
>>>>>> implement and export nf_conntrack_proto_generic_[init,fini],
>>>>>> nf_conntrack_[init,cleanup]_net call them to register or unregis=
ter
>>>>>> the sysctl of generic proto.
>>>>>>
>>>>>> implement generic_net_init,it's used to initial the pernet
>>>>>> data for generic proto.
>>>>>>
>>>>>> and use nf_generic_net.timeout to replace nf_ct_generic_timeout =
in
>>>>>> get_timeouts function.
>>>>>>
>>>>>> Acked-by: Eric W. Biederman <ebiederm@xmission.com>
>>>>>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>>>>>> ---
>>>>>>  include/net/netfilter/nf_conntrack_l4proto.h |    2 +
>>>>>>  include/net/netns/conntrack.h                |    6 +++
>>>>>>  net/netfilter/nf_conntrack_core.c            |    8 +++-
>>>>>>  net/netfilter/nf_conntrack_proto.c           |   21 +++++-----
>>>>>>  net/netfilter/nf_conntrack_proto_generic.c   |   55 +++++++++++=
+++++++++++++-
>>>>>>  5 files changed, 76 insertions(+), 16 deletions(-)
>>>>>>
>>>>>> diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/incl=
ude/net/netfilter/nf_conntrack_l4proto.h
>>>>>> index a93dcd5..0d329b9 100644
>>>>>> --- a/include/net/netfilter/nf_conntrack_l4proto.h
>>>>>> +++ b/include/net/netfilter/nf_conntrack_l4proto.h
>>>>>> @@ -118,6 +118,8 @@ struct nf_conntrack_l4proto {
>>>>>> =20
>>>>>>  /* Existing built-in generic protocol */
>>>>>>  extern struct nf_conntrack_l4proto nf_conntrack_l4proto_generic=
;
>>>>>> +extern int nf_conntrack_proto_generic_init(struct net *net);
>>>>>> +extern void nf_conntrack_proto_generic_fini(struct net *net);
>>>>>> =20
>>>>>>  #define MAX_NF_CT_PROTO 256
>>>>>> =20
>>>>>> diff --git a/include/net/netns/conntrack.h b/include/net/netns/c=
onntrack.h
>>>>>> index 94992e9..3381b80 100644
>>>>>> --- a/include/net/netns/conntrack.h
>>>>>> +++ b/include/net/netns/conntrack.h
>>>>>> @@ -20,7 +20,13 @@ struct nf_proto_net {
>>>>>>  	unsigned int		users;
>>>>>>  };
>>>>>> =20
>>>>>> +struct nf_generic_net {
>>>>>> +	struct nf_proto_net pn;
>>>>>> +	unsigned int timeout;
>>>>>> +};
>>>>>> +
>>>>>>  struct nf_ip_net {
>>>>>> +	struct nf_generic_net   generic;
>>>>>>  #if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_=
COMPAT)
>>>>>>  	struct ctl_table_header *ctl_table_header;
>>>>>>  	struct ctl_table	*ctl_table;
>>>>>> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/n=
f_conntrack_core.c
>>>>>> index 32c5909..fd33e91 100644
>>>>>> --- a/net/netfilter/nf_conntrack_core.c
>>>>>> +++ b/net/netfilter/nf_conntrack_core.c
>>>>>> @@ -1353,6 +1353,7 @@ static void nf_conntrack_cleanup_net(struc=
t net *net)
>>>>>>  	}
>>>>>> =20
>>>>>>  	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
>>>>>> +	nf_conntrack_proto_generic_fini(net);
>>>>>>  	nf_conntrack_helper_fini(net);
>>>>>>  	nf_conntrack_timeout_fini(net);
>>>>>>  	nf_conntrack_ecache_fini(net);
>>>>>> @@ -1586,9 +1587,12 @@ static int nf_conntrack_init_net(struct n=
et *net)
>>>>>>  	ret =3D nf_conntrack_helper_init(net);
>>>>>>  	if (ret < 0)
>>>>>>  		goto err_helper;
>>>>>> -
>>>>>> +	ret =3D nf_conntrack_proto_generic_init(net);
>>>>>> +	if (ret < 0)
>>>>>> +		goto err_generic;
>>>>>>  	return 0;
>>>>>> -
>>>>>> +err_generic:
>>>>>> +	nf_conntrack_helper_fini(net);
>>>>>>  err_helper:
>>>>>>  	nf_conntrack_timeout_fini(net);
>>>>>>  err_timeout:
>>>>>> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/=
nf_conntrack_proto.c
>>>>>> index 7ee6653..9b4bf6d 100644
>>>>>> --- a/net/netfilter/nf_conntrack_proto.c
>>>>>> +++ b/net/netfilter/nf_conntrack_proto.c
>>>>>> @@ -287,10 +287,16 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unr=
egister);
>>>>>>  static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
>>>>>>  					      struct nf_conntrack_l4proto *l4proto)
>>>>>>  {
>>>>>> -	if (l4proto->net_id)
>>>>>> -		return net_generic(net, *l4proto->net_id);
>>>>>> -	else
>>>>>> -		return NULL;
>>>>>> +	switch (l4proto->l4proto) {
>>>>>> +	case 255: /* l4proto_generic */
>>>>>> +		return (struct nf_proto_net *)&net->ct.proto.generic;
>>>>>> +	default:
>>>>>> +		if (l4proto->net_id)
>>>>>> +			return net_generic(net, *l4proto->net_id);
>>>>>> +		else
>>>>>> +			return NULL;
>>>>>> +	}
>>>>>> +	return NULL;
>>>>>>  }
>>>>>> =20
>>>>>>  int nf_ct_l4proto_register_sysctl(struct net *net,
>>>>>> @@ -457,11 +463,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unre=
gister);
>>>>>>  int nf_conntrack_proto_init(void)
>>>>>>  {
>>>>>>  	unsigned int i;
>>>>>> -	int err;
>>>>>> -
>>>>>> -	err =3D nf_ct_l4proto_register_sysctl(&init_net, &nf_conntrack=
_l4proto_generic);
>>>>>> -	if (err < 0)
>>>>>> -		return err;
>>>>>
>>>>> I like that all protocols sysctl are registered by
>>>>> nf_conntrack_proto_init. Can you keep using that?
>>>>
>>>> you mean per-net's generic_proto sysctl are registered by
>>>> nf_conntrack_proto_init?
>>>>
>>>> such as
>>>>
>>>> int nf_conntrack_proto_init(struct net *net)
>>>> {
>>>> 	...
>>>> 	err =3D nf_ct_l4proto_register_sysctl(net, &nf_conntrack_l4proto_=
generic);
>>>
>>> Yes, all protocol trackers included in nf_conntrack_proto_init:
>>>
>>>         err =3D nf_conntrack_proto_generic_init(net);
>>>         ...
>>>         err =3D nf_conntrack_proto_tcp_init(net);
>>>         ...
>>>
>>> and so on.
>>
>> sounds good,but the l4protos except l4proto_generic are enabled by
>> insmod modules(such as nf_conntrack_ipv4,nf_conntrack_proto_udplite)=
=2E
>>
>> So I think it makes no sense to init all protocol here, unless we de=
cide
>> to put those protos into module nf_conntrack.
>=20
> Sorry, I meant to say all protocols that are built-in.
>=20
> So, just put there those that are built-in, like TCP, UDP and generic

AFAIK l4proto_generic is registered when install module nf_conntrack,
BUT l4proto_tcp,l4proto_udp,l4proto_icmp are registered when install mo=
dule nf_conntrack_ipv4.

So we can only register generic proto here.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
