From: Emmanuel Thierry <ml@sekil.fr>
Subject: Re: [RFC PATCH] xfrm: fix handling of XFRM policies mark and mask.
Date: Thu, 7 Feb 2013 12:16:49 +0100
Message-ID: <6153E16D-D021-4D09-B416-ACBE503928FF@sekil.fr>
References: <9E57ADA1-5770-47A8-8EBF-7FC262EEF1C7@ipflavors.com> <20130205081232.GF23291@secunet.com> <51125744.3030905@gmail.com> <D4563759-CEC5-4F33-BF0A-9FA10716F8DF@telecom-bretagne.eu> <20130207104908.GA17794@secunet.com> <2BEAF521-7218-415B-98ED-EC0812903479@telecom-bretagne.eu>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <j.hadi123@gmail.com>, Romain KUNTZ <r.kuntz@ipflavors.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	Jamal Hadi Salim <hadi@cyberus.ca>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2BEAF521-7218-415B-98ED-EC0812903479@telecom-bretagne.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Le 7 f=E9vr. 2013 =E0 12:08, Emmanuel Thierry <emmanuel.thierry@telecom=
-bretagne.eu> a =E9crit :

> Hello,
>=20
> Le 7 f=E9vr. 2013 =E0 11:49, Steffen Klassert <steffen.klassert@secun=
et.com> a =E9crit :
>=20
>> On Wed, Feb 06, 2013 at 02:53:48PM +0100, Emmanuel Thierry wrote:
>>>=20
>>> Le 6 f=E9vr. 2013 =E0 14:14, jamal a =E9crit :
>>>=20
>>>>=20
>>>> On 13-02-05 03:12 AM, Steffen Klassert wrote:
>>>>>> For example, executing the below commands in that order succeed:
>>>>>> ip -6 xfrm policy flush
>>>>>> ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out ma=
rk 1 mask 0xffffffff
>>>>>> ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out
>>>>> The policy with mark 1 is the first we find. The policy passes th=
e
>>>>> mark check and if the flow matches the selectors, we use this pol=
icy.
>>>>>=20
>>>>>> But it fails in the reverse order:
>>>>>> ip -6 xfrm policy flush
>>>>>> ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out
>>>>>> ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out ma=
rk 1 mask 0xffffffff
>>>>>> RTNETLINK answers: File exists
>>>>> With this scenario, we would find the policy with mark and mask 0=
 first.
>>>>> This policy passes the mark check too. So we would use this polic=
y if the
>>>>> flow matches the selectors, but the flow asked for a policy with =
mark 1.
>>>>=20
>>>> I think the intent Romain is expressing is reasonable and should r=
esolved at
>>>> insertion time(xfrm_policy_insert()).
>>>> i.e even though the policy (such as mark=3D1) is inserted afterwar=
ds, at
>>>> insertion time if it proves it is more specific and not duplicate,=
 it should be
>>>> inserted ahead of the mark=3D0.
>>>> The runtime check will work then.
>>>=20
>>> Actually, we didn't think about this problem since we work with pri=
orities, putting the default policy (without a mark) at a minor priorit=
y than the marked one.
>>> Your remark makes clearer the ideas behind the design of XFRM, but =
this leads to an interesting concern. If on policy insertion, the polic=
y were inserted depending on the accuracy of the mark (the more the mas=
k is specific, the more the mark must be put at the beginning of the li=
st), how would we decide which is the more specific between these ones =
?
>>>=20
>>> ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out mark =
0x00000001 mask 0x00000005
>>>=20
>>> ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out mark =
0x00000001 mask 0x00000003
>>>=20
>>=20
>> We can't decide on the order of these two policies, so we should not
>> allow to insert both. At least not if the have the same priority,
>> but we could insert both if they have different priorities.
>>=20
>> Would the patch below meet your requirements?
>>=20
>> ---
>> net/xfrm/xfrm_policy.c |   18 ++++++++++++++++--
>> 1 files changed, 16 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
>> index 6c9aa64..b169a69 100644
>> --- a/net/xfrm/xfrm_policy.c
>> +++ b/net/xfrm/xfrm_policy.c
>> @@ -562,6 +562,21 @@ static inline int selector_cmp(struct xfrm_sele=
ctor *s1, struct xfrm_selector *s
>> 	return 0;
>> }
>>=20
>> +static bool xfrm_mark_match(struct xfrm_policy *policy,
>> +			    struct xfrm_policy *pol)
>> +{
>> +	u32 mark =3D policy->mark.v & policy->mark.m;
>> +
>> +	if (policy->mark.v =3D=3D pol->mark.v && policy->mark.m =3D=3D pol=
->mark.m)
>> +		return true;
>> +
>> +	if ((mark & pol->mark.m) =3D=3D pol->mark.v &&
>> +	    policy->priority =3D=3D pol->priority)
>> +		return true;
>> +
>> +	return false;
>> +}
>> +
>> int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl=
)
>> {
>> 	struct net *net =3D xp_net(policy);
>> @@ -569,7 +584,6 @@ int xfrm_policy_insert(int dir, struct xfrm_poli=
cy *policy, int excl)
>> 	struct xfrm_policy *delpol;
>> 	struct hlist_head *chain;
>> 	struct hlist_node *entry, *newpos;
>> -	u32 mark =3D policy->mark.v & policy->mark.m;
>>=20
>> 	write_lock_bh(&xfrm_policy_lock);
>> 	chain =3D policy_hash_bysel(net, &policy->selector, policy->family,=
 dir);
>> @@ -578,7 +592,7 @@ int xfrm_policy_insert(int dir, struct xfrm_poli=
cy *policy, int excl)
>> 	hlist_for_each_entry(pol, entry, chain, bydst) {
>> 		if (pol->type =3D=3D policy->type &&
>> 		    !selector_cmp(&pol->selector, &policy->selector) &&
>> -		    (mark & pol->mark.m) =3D=3D pol->mark.v &&
>> +		    xfrm_mark_match(policy, pol) &&
>> 		    xfrm_sec_ctx_match(pol->security, policy->security) &&
>> 		    !WARN_ON(delpol)) {
>> 			if (excl) {
>> --=20
>> 1.7.2.5
>>=20
>=20
> This is a nice idea, however you keep the insertion asymmetric. The u=
sage of xfrm marks in non-conflicting cases will be made possible, but =
it stays disturbing for a user as the initial example will still have t=
he same behavior:
> * Inserting the marked one then the unmarked will succeed
> * Inserting the unmarked then the marked one will fail
> This gives to the user the feeling of an indeterministic behavior of =
the xfrm module.
>=20
> On the base of your patch, i'd propose to make it symmetric (handmade=
 patch below).
>=20
> Best regards
> Emmanuel Thierry


Excuse the problem of logic, i sent it too quickly, here is the correct=
 proposal:


--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c

 static bool xfrm_mark_match(struct xfrm_policy *policy,
 			    struct xfrm_policy *pol)
 {
 	u32 mark =3D policy->mark.v & policy->mark.m;
+	u32 mark2 =3D pol->mark.v & pol->mark.m;
=20
 	if (policy->mark.v =3D=3D pol->mark.v && policy->mark.m =3D=3D pol->m=
ark.m)
 		return true;
=20
-	if ((mark & pol->mark.m) =3D=3D pol->mark.v &&
+	if (((mark & pol->mark.m) =3D=3D pol->mark.v ||
+	    (mark2 & policy->mark.m) =3D=3D policy->mark.v) &&
 	    policy->priority =3D=3D pol->priority)
 		return true;
=20
 	return false;
 }
