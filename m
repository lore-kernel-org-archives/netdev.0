From: =?UTF-8?Q?Aviv_Heller?= <aviv@avivh.com>
Subject: RE: [PATCH net-next 2/3] xfrm: Fix offload dev state addition to
 occur after insertion
Date: Thu, 26 Oct 2017 15:47:18 +0000
Message-ID: <0101015f595dc570-9cae58d5-fe75-4457-9bfb-2420b9ed7c1d-000000@us-west-2.amazonses.com>
References: <1508857831-55824-1-git-send-email-avivh@mellanox.com>
 <1508857831-55824-2-git-send-email-avivh@mellanox.com>
 <20171025072214.GP3323@secunet.com>
 <0101015f53a726b1-d5731696-249f-449c-8c84-1d047cfaffb0-000000@us-west-2.amazonses.com>
 <20171026061610.GR3323@secunet.com>
 <mail.59f1f759.3bc0.5118b0751bd8f084@storage.wm.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?Q?netdev-owner=40vger=2Ekernel=2Eorg?=
        <netdev-owner@vger.kernel.org>,
        =?UTF-8?Q?avivh=40mellanox=2Ecom?= <avivh@mellanox.com>,
        =?UTF-8?Q?Herbert_Xu?= <herbert@gondor.apana.org.au>,
        =?UTF-8?Q?Boris_Pismenny?= <borisp@mellanox.com>,
        =?UTF-8?Q?Yossi_Kuperma?= =?UTF-8?Q?n?= <yossiku@mellanox.com>,
        =?UTF-8?Q?Yevgeny_Kliteynik?= <kliteyn@mellanox.com>,
        =?UTF-8?Q?netdev=40vger=2Ekernel=2Eorg?= <netdev@vger.kernel.org>
To: =?UTF-8?Q?Aviv_Heller?= <aviv@avivh.com>,
        =?UTF-8?Q?Steffen_Klassert?= <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a27-159.smtp-out.us-west-2.amazonses.com ([54.240.27.159]:46998
        "EHLO a27-159.smtp-out.us-west-2.amazonses.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932137AbdJZPrT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:47:19 -0400
In-Reply-To: <mail.59f1f759.3bc0.5118b0751bd8f084@storage.wm.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----Original message-----=0D=0A> From: Aviv Heller=0D=0A> Sent: Thursday=
, October 26 2017, 5:55 pm=0D=0A> To: Steffen Klassert=0D=0A> Cc: netdev-=
owner@vger.kernel.org; avivh@mellanox.com; Herbert Xu; Boris Pismenny; Yo=
ssi Kuperman; Yevgeny Kliteynik; netdev@vger.kernel.org=0D=0A> Subject: R=
E: [PATCH net-next 2/3] xfrm: Fix offload dev state addition to occur aft=
er insertion=0D=0A>=20=0D=0A> -----Original message-----=0D=0A> > From: S=
teffen Klassert=0D=0A> > Sent: Thursday, October 26 2017, 9:16 am=0D=0A> =
> To: Aviv Heller=0D=0A> > Cc: netdev-owner@vger.kernel.org; avivh@mellan=
ox.com; Herbert Xu; Boris Pismenny; Yossi Kuperman; Yevgeny Kliteynik; ne=
tdev@vger.kernel.org=0D=0A> > Subject: Re: [PATCH net-next 2/3] xfrm: Fix=
 offload dev state addition to occur after insertion=0D=0A> >=20=0D=0A> >=
 On Wed, Oct 25, 2017 at 01:09:44PM +0000, Aviv Heller wrote:=0D=0A> > > =
-----Original message-----=0D=0A> > > > From: Steffen Klassert=0D=0A> > >=
 > Sent: Wednesday, October 25 2017, 10:22 am=0D=0A> > > > To: avivh@mell=
anox.com=0D=0A> > > > Cc: Herbert Xu; Boris Pismenny; Yossi Kuperman; Yev=
geny Kliteynik; netdev@vger.kernel.org=0D=0A> > > > Subject: Re: [PATCH n=
et-next 2/3] xfrm: Fix offload dev state addition to occur after insertio=
n=0D=0A> > > >=20=0D=0A> > > > On Tue, Oct 24, 2017 at 06:10:30PM +0300, =
avivh@mellanox.com wrote:=0D=0A> > > > > From: Aviv Heller <avivh@mellano=
x.com>=0D=0A> > > > >=20=0D=0A> > > > > Adding the state to the offload d=
evice prior to replay init in=0D=0A> > > > > xfrm_state_construct() will =
result in NULL dereference if a matching=0D=0A> > > > > ESP packet is rec=
eived in between.=0D=0A> > > > >=20=0D=0A> > > > > Adding it after insert=
ion also has the benefit of the driver not having=0D=0A> > > > > to check=
 whether a state with the same match criteria already exists,=0D=0A> > > =
> > but forces us to use an atomic type for the offload_handle, to make=0D=
=0A> > > > > certain a stack-read/driver-write race won't result in readi=
ng corrupt=0D=0A> > > > > data.=0D=0A> > > >=20=0D=0A> > > > No, this wil=
l add multiple atomic operations to the packet path,=0D=0A> > > > even in=
 the non offloaded case.=0D=0A> > > >=20=0D=0A> > > > I think the problem=
 is that we set XFRM_STATE_VALID to early.=0D=0A> > > > This was not a pr=
oblem before we had offloading because=0D=0A> > > > it was not possible t=
o lookup this state before we inserted=0D=0A> > > > it into the SADB. Now=
 that the driver holds a subset of states=0D=0A> > > > too, we need to ma=
ke sure the state is fully initialized=0D=0A> > > > before we mark it as =
valid.=0D=0A> > > >=20=0D=0A> > > > The patch below should do it, in comb=
ination with your patch 1/3.=0D=0A> > > >=20=0D=0A> > > > Could you pleas=
e test this=3F=0D=0A> > > >=20=0D=0A> > > > diff --git a/net/xfrm/xfrm_us=
er.c b/net/xfrm/xfrm_user.c=0D=0A> > > > index b997f13..96eb263 100644=0D=
=0A> > > > --- a/net/xfrm/xfrm_user.c=0D=0A> > > > +++ b/net/xfrm/xfrm_us=
er.c=0D=0A> > > > @@ -587,10 +587,6 @@ static struct xfrm_state *xfrm_sta=
te_construct(struct net *net,=0D=0A> > > >  =09if (attrs[XFRMA_OUTPUT_MAR=
K])=0D=0A> > > >  =09=09x->props.output_mark =3D nla_get_u32(attrs[XFRMA_=
OUTPUT_MARK]);=0D=0A> > > > =20=0D=0A> > > > -=09err =3D __xfrm_init_stat=
e(x, false, attrs[XFRMA_OFFLOAD_DEV]);=0D=0A> > > > -=09if (err)=0D=0A> >=
 > > -=09=09goto error;=0D=0A> > > > -=0D=0A> > > >  =09if (attrs[XFRMA_S=
EC_CTX]) {=0D=0A> > > >  =09=09err =3D security_xfrm_state_alloc(x,=0D=0A=
> > > >  =09=09=09=09=09=09nla_data(attrs[XFRMA_SEC_CTX]));=0D=0A> > > > =
@@ -620,6 +616,10 @@ static struct xfrm_state *xfrm_state_construct(struc=
t net *net,=0D=0A> > > >  =09/* override default values from above */=0D=0A=
> > > >  =09xfrm_update_ae_params(x, attrs, 0);=0D=0A> > > > =20=0D=0A> >=
 > > +=09err =3D __xfrm_init_state(x, false, attrs[XFRMA_OFFLOAD_DEV]);=0D=
=0A> > > > +=09if (err)=0D=0A> > > > +=09=09goto error;=0D=0A> > > > +=0D=
=0A> > > >  =09return x;=0D=0A> > > > =20=0D=0A> > > >  error:=0D=0A> > >=
 >=20=0D=0A> > >=20=0D=0A> > > Hi Steffen,=0D=0A> > >=20=0D=0A> > > This =
patch does not work, due to:=0D=0A> > > =09if (!x->type_offload)=0D=0A> >=
 > =09=09return -EINVAL;=0D=0A> > >=20=0D=0A> > > test in xfrm_dev_state_=
add().=0D=0A> >=20=0D=0A> > There is certainly a way arround that :)=0D=0A=
> > The easiest I can think of would be to propagate XFRM_STATE_VALID=0D=0A=
> > only after the state is inserted into the SADBs. I.e. move the=0D=0A>=
 > setting of XFRM_STATE_VALID out of __xfrm_init_state() and let the=0D=0A=
> > callers do it.=0D=0A>=20=0D=0A> This does seem like the easiest solut=
ion, if we don't move state addition to occur after insertion.=0D=0A> I'm=
 waiting for our regression results (probably on Monday) for the patch be=
low, and would appreciate your comments:=0D=0A>=20=0D=0A=0D=0APlease igno=
re the last patch, I understood you wrong.=0D=0AWill reimplement and subm=
it.
