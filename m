From: Shanker Wang <miao.wang@tuna.tsinghua.edu.cn>
Subject: Re: [PATCH] net:ppp: replace too strict capability restriction on opening /dev/ppp
Date: Sat, 16 Jul 2016 17:41:56 +0800
Message-ID: <EEC1556F-60C8-483E-A410-0248D9D54CC9@tuna.tsinghua.edu.cn>
References: <15AED149-BC4D-4B8F-B173-3F652A46FA35@tuna.tsinghua.edu.cn> <5766704C.6060309@nod.at> <C708B373-7946-458A-A4C2-BB63A2413FB6@tuna.tsinghua.edu.cn> <576676B1.8010206@nod.at>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Richard Weinberger <richard@nod.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:34118 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbcGPJmD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 05:42:03 -0400
Received: by mail-pa0-f65.google.com with SMTP id hh10so7558761pac.1
        for <netdev@vger.kernel.org>; Sat, 16 Jul 2016 02:42:02 -0700 (PDT)
In-Reply-To: <576676B1.8010206@nod.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard,

Sorry for the late reply after dealing with my personal issues.

After reading the code, I find out that when /dev/ppp is opened,=20
the instance is in =A1=B0unattached=A1=B1 state and `file->private_data=
`
is null correspondingly. After creating a new instance, attaching
to a instance or attaching to a channel using ioctl=20
(ppp_unattached_ioctl), the state is changed to =A1=B0attached=A1=B1 an=
d=20
`file->private_data` becomes valid. My opinion is that only=20
checking capability in `current->nsproxy->net_ns->user_ns` is=20
enough. The reason is that to create a ppp interface or control a
 ppp interface (in short, to =A1=B0modify=A1=B1 the network configurati=
on),
we should always first create a new instance by opening `/dev/ppp`=20
and attach it to a unit or so.=20

As you mentioned, =A1=B0an user can create a new user_ns followed by=20
a new net_ns and has CAP_NET_ADMIN=A1=B1. However, in that case, he can=
=20
create new units by `ioctl PPPIOCNEWUNIT` but cannot attach to=20
units existing in other net_ns by `ioctl PPPIOCATTACH`, because=20
`ppp_find_unit` can only find unit in the current net_ns.

In spite of that, I have to admit that there is risk that lots=20
of ppp devices are created filling all kernel memory. I think this
can be avoided by some other methods.

You have mentioned in another reply that =A1=B0the use of nsproxy has
to be removed=A1=B1 but I don=A1=AFt understand the reason. In comparis=
on,
I found similar usage of nsproxy in `tun.c`. So could you please
give a more detailed explanation? Thanks!


> =D4=DA 2016=C4=EA6=D4=C219=C8=D5=A3=AC18:40=A3=ACRichard Weinberger <=
richard@nod.at> =D0=B4=B5=C0=A3=BA
>=20
> Am 19.06.2016 um 12:36 schrieb Shanker Wang:
>>=20
>>> =D4=DA 2016=C4=EA6=D4=C219=C8=D5=A3=AC12:13=A3=ACRichard Weinberger=
 <richard@nod.at> =D0=B4=B5=C0=A3=BA
>>>=20
>>> Am 19.06.2016 um 07:21 schrieb Shanker Wang:
>>>> This patch removes the check for CAP_NET_ADMIN in the initial name=
space
>>>> when opening /dev/open. Instead, CAP_NET_ADMIN is checked in the u=
ser
>>>> namespace the net namespace was created so that /dev/ppp cat get o=
pened
>>>> in a unprivileged container.
>>>>=20
>>>> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>>> Cc: Richard Weinberger <richard.weinberger@gmail.com>
>>>> Cc: Guillaume Nault <g.nault@alphalink.fr>
>>>> Cc: Miao Wang <shankerwangmiao@gmail.com>
>>>> Signed-off-by: Miao Wang <miao.wang@tuna.tsinghua.edu.cn>
>>>> ---
>>>> drivers/net/ppp/ppp_generic.c | 2 +-
>>>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>>>=20
>>>> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_g=
eneric.c
>>>> index f572b31..4b3b2b5 100644
>>>> --- a/drivers/net/ppp/ppp_generic.c
>>>> +++ b/drivers/net/ppp/ppp_generic.c
>>>> @@ -380,7 +380,7 @@ static int ppp_open(struct inode *inode, struc=
t file *file)
>>>> 	/*
>>>> 	 * This could (should?) be enforced by the permissions on /dev/pp=
p.
>>>> 	 */
>>>> -	if (!capable(CAP_NET_ADMIN))
>>>> +	if (!ns_capable(current->nsproxy->net_ns->user_ns, CAP_NET_ADMIN=
))
>>>> 		return -EPERM;
>>>=20
>>> Shouldn't this be a ns_capable(net->user_ns, =A1=AD?
>>> Otherwise an user can create a new user_ns followed by a new net_ns=
 and has
>>> CAP_NET_ADMIN. We need to check whether he is allowed in the user_n=
s of the
>>> net_ns which belongs to the ppp net device which you want to open.
>> You are totally right. However, I wonder how can i get the =A1=B0net=
=A1=B1 struct when=20
>> opening /dev/ppp
>=20
> I'm sure you can get it somehow via file->private_data.
>=20
> Thanks,
> //richard
