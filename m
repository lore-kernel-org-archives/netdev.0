From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 04/13] netfilter: regard users as refcount for l4proto's
 per-net data
Date: Wed, 27 Jun 2012 09:34:01 +0800
Message-ID: <4FEA6309.5060305@cn.fujitsu.com>
References: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com> <1340289410-17642-4-git-send-email-gaofeng@cn.fujitsu.com> <20120625112029.GB4607@1984> <4FE93375.1080803@cn.fujitsu.com> <20120626144708.GB11165@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120626144708.GB11165@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B406=E6=9C=8826=E6=97=A5 22:47, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Tue, Jun 26, 2012 at 11:58:45AM +0800, Gao feng wrote:
>> Hi Pablo:
>> =E4=BA=8E 2012=E5=B9=B406=E6=9C=8825=E6=97=A5 19:20, Pablo Neira Ayu=
so =E5=86=99=E9=81=93:
>>> On Thu, Jun 21, 2012 at 10:36:41PM +0800, Gao feng wrote:
>>>> Now, nf_proto_net's users is confusing.
>>>> we should regard it as the refcount for l4proto's per-net data,
>>>> because maybe there are two l4protos use the same per-net data.
>>>>
>>>> so increment pn->users when nf_conntrack_l4proto_register
>>>> success, and decrement it for nf_conntrack_l4_unregister case.
>>>>
>>>> because nf_conntrack_l3proto_ipv[4|6] don't use the same per-net
>>>> data,so we don't need to add a refcnt for their per-net data.
>>>>
>>>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>>>> ---
>>>>  net/netfilter/nf_conntrack_proto.c |   76 ++++++++++++++++++++++-=
-------------
>>>>  1 files changed, 46 insertions(+), 30 deletions(-)
>>>>
>>>> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf=
_conntrack_proto.c
>>>> index 9d6b6ab..63612e6 100644
>>>> --- a/net/netfilter/nf_conntrack_proto.c
>>>> +++ b/net/netfilter/nf_conntrack_proto.c
>>> [...]
>>>> @@ -458,23 +446,32 @@ int nf_conntrack_l4proto_register(struct net=
 *net,
>>>>  				  struct nf_conntrack_l4proto *l4proto)
>>>>  {
>>>>  	int ret =3D 0;
>>>> +	struct nf_proto_net *pn =3D NULL;
>>>> =20
>>>>  	if (l4proto->init_net) {
>>>>  		ret =3D l4proto->init_net(net, l4proto->l3proto);
>>>>  		if (ret < 0)
>>>> -			return ret;
>>>> +			goto out;
>>>>  	}
>>>> =20
>>>> -	ret =3D nf_ct_l4proto_register_sysctl(net, l4proto);
>>>> +	pn =3D nf_ct_l4proto_net(net, l4proto);
>>>> +	if (pn =3D=3D NULL)
>>>> +		goto out;
>>>
>>> Same thing here, we're leaking memory allocated by l4proto->init_ne=
t.
>>
>> if pn is NULL,init_net can't allocate memory for pn->ctl_table.
>> So I think it's not memory leak here.
>=20
> Sorry, I meant to say the line below. But we've already clarified
> this in patch 1/1.
>=20
>>>> +	ret =3D nf_ct_l4proto_register_sysctl(net, pn, l4proto);
>>>>  	if (ret < 0)
>>>> -		return ret;
>>>> +		goto out;
>>>> =20
>>>>  	if (net =3D=3D &init_net) {
>>>>  		ret =3D nf_conntrack_l4proto_register_net(l4proto);
>>>> -		if (ret < 0)
>>>> -			nf_ct_l4proto_unregister_sysctl(net, l4proto);
>>>> +		if (ret < 0) {
>>>> +			nf_ct_l4proto_unregister_sysctl(net, pn, l4proto);
>>>> +			goto out;
>>>
>>> Better replace the two lines above by:
>>>
>>> goto out_register_net;
>>>
>>> and then...
>>>
>>>> +		}
>>>>  	}
>>>> =20
>>>> +	pn->users++;
>>>
>>> out_register_net:
>>>         nf_ct_l4proto_unregister_sysctl(net, pn, l4proto);
>>>
>>>> +out:
>>>>  	return ret;
>>>
>>> I think that this change is similar to patch 1/1, I think you shoul=
d
>>> send it as a separated patch.
>>>
>>
>> Yes, It looks better.
>> should I change this and rebase whole patchset or
>> maybe you just apply this patchset and then I send a cleanup patch t=
o do this?
>=20
> This patch includes changes that are not included in the description,
> so you have two choices:
>=20
> 1) You resend me this patch with appropriate description (including
> the fact that you're fixing the same thing that patch 1/1 does). This
> option still I don't like too much, since making two different things
> in one single patch is nasty, but well if you push me...

Sorry, I don't know which the same thing I fixed in this patch and 1/13=
 patch.
the 1/13 patch only change the proto's registration order. and this pat=
ch doesn't
change the registration order.

This patch is used to try to make variable "users" clear.

>=20
> 2) you split the patch in two, with the appropriate descriptions each
> and you'll make me happy.
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-d=
evel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
