From: =?UTF-8?Q?Aviv_Heller?= <aviv@avivh.com>
Subject: RE: [PATCH net-next 2/3] xfrm: Fix offload dev state addition to
 occur after insertion
Date: Wed, 25 Oct 2017 13:09:44 +0000
Message-ID: <0101015f53a726b1-d5731696-249f-449c-8c84-1d047cfaffb0-000000@us-west-2.amazonses.com>
References: <1508857831-55824-1-git-send-email-avivh@mellanox.com>
 <1508857831-55824-2-git-send-email-avivh@mellanox.com>
 <20171025072214.GP3323@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?Q?Herbert_Xu?= <herbert@gondor.apana.org.au>,
        =?UTF-8?Q?Boris_Pismenny?= <borisp@mellanox.com>,
        =?UTF-8?Q?Yossi_Kuperma?= =?UTF-8?Q?n?= <yossiku@mellanox.com>,
        =?UTF-8?Q?Yevgeny_Kliteynik?= <kliteyn@mellanox.com>,
        =?UTF-8?Q?netdev=40vger=2Ekernel=2Eorg?= <netdev@vger.kernel.org>
To: =?UTF-8?Q?Steffen_Klassert?= <steffen.klassert@secunet.com>,
        =?UTF-8?Q?netdev-owner=40vger=2Ekernel=2Eorg?=
        <netdev-owner@vger.kernel.org>,
        =?UTF-8?Q?avivh=40mellanox=2Ecom?= <avivh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a27-44.smtp-out.us-west-2.amazonses.com ([54.240.27.44]:58844
        "EHLO a27-44.smtp-out.us-west-2.amazonses.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751145AbdJYNJq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 09:09:46 -0400
In-Reply-To: <20171025072214.GP3323@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----Original message-----=0D=0A> From: Steffen Klassert=0D=0A> Sent: Wed=
nesday, October 25 2017, 10:22 am=0D=0A> To: avivh@mellanox.com=0D=0A> Cc=
: Herbert Xu; Boris Pismenny; Yossi Kuperman; Yevgeny Kliteynik; netdev@v=
ger.kernel.org=0D=0A> Subject: Re: [PATCH net-next 2/3] xfrm: Fix offload=
 dev state addition to occur after insertion=0D=0A>=20=0D=0A> On Tue, Oct=
 24, 2017 at 06:10:30PM +0300, avivh@mellanox.com wrote:=0D=0A> > From: A=
viv Heller <avivh@mellanox.com>=0D=0A> >=20=0D=0A> > Adding the state to =
the offload device prior to replay init in=0D=0A> > xfrm_state_construct(=
) will result in NULL dereference if a matching=0D=0A> > ESP packet is re=
ceived in between.=0D=0A> >=20=0D=0A> > Adding it after insertion also ha=
s the benefit of the driver not having=0D=0A> > to check whether a state =
with the same match criteria already exists,=0D=0A> > but forces us to us=
e an atomic type for the offload_handle, to make=0D=0A> > certain a stack=
-read/driver-write race won't result in reading corrupt=0D=0A> > data.=0D=
=0A>=20=0D=0A> No, this will add multiple atomic operations to the packet=
 path,=0D=0A> even in the non offloaded case.=0D=0A>=20=0D=0A> I think th=
e problem is that we set XFRM_STATE_VALID to early.=0D=0A> This was not a=
 problem before we had offloading because=0D=0A> it was not possible to l=
ookup this state before we inserted=0D=0A> it into the SADB. Now that the=
 driver holds a subset of states=0D=0A> too, we need to make sure the sta=
te is fully initialized=0D=0A> before we mark it as valid.=0D=0A>=20=0D=0A=
> The patch below should do it, in combination with your patch 1/3.=0D=0A=
>=20=0D=0A> Could you please test this=3F=0D=0A>=20=0D=0A> diff --git a/n=
et/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c=0D=0A> index b997f13..96eb263 =
100644=0D=0A> --- a/net/xfrm/xfrm_user.c=0D=0A> +++ b/net/xfrm/xfrm_user.=
c=0D=0A> @@ -587,10 +587,6 @@ static struct xfrm_state *xfrm_state_constr=
uct(struct net *net,=0D=0A>  =09if (attrs[XFRMA_OUTPUT_MARK])=0D=0A>  =09=
=09x->props.output_mark =3D nla_get_u32(attrs[XFRMA_OUTPUT_MARK]);=0D=0A>=
 =20=0D=0A> -=09err =3D __xfrm_init_state(x, false, attrs[XFRMA_OFFLOAD_D=
EV]);=0D=0A> -=09if (err)=0D=0A> -=09=09goto error;=0D=0A> -=0D=0A>  =09i=
f (attrs[XFRMA_SEC_CTX]) {=0D=0A>  =09=09err =3D security_xfrm_state_allo=
c(x,=0D=0A>  =09=09=09=09=09=09nla_data(attrs[XFRMA_SEC_CTX]));=0D=0A> @@=
 -620,6 +616,10 @@ static struct xfrm_state *xfrm_state_construct(struct =
net *net,=0D=0A>  =09/* override default values from above */=0D=0A>  =09=
xfrm_update_ae_params(x, attrs, 0);=0D=0A> =20=0D=0A> +=09err =3D __xfrm_=
init_state(x, false, attrs[XFRMA_OFFLOAD_DEV]);=0D=0A> +=09if (err)=0D=0A=
> +=09=09goto error;=0D=0A> +=0D=0A>  =09return x;=0D=0A> =20=0D=0A>  err=
or:=0D=0A>=20=0D=0A=0D=0AHi Steffen,=0D=0A=0D=0AThis patch does not work,=
 due to:=0D=0A=09if (!x->type_offload)=0D=0A=09=09return -EINVAL;=0D=0A=0D=
=0Atest in xfrm_dev_state_add().=0D=0A=0D=0AI agree with your analysis, a=
nd that we take a little performance hit due to the atomics, but we get t=
he benefit of calling xfrm_dev_state_add() after the state is completely =
initialized, and passed the criteria for addition by xfrm_state_add().=0D=
=0A=0D=0AAnother approach I thought of is to insert the state with an inv=
alid km.state, and only after the HW state addition succeeds, we move km.=
state to valid.=0D=0AI did not go for this approach because here again we=
 need to use atomics (or not=3F), and since state testing is done in quit=
e a few places, was afraid of unexpected consequences.=0D=0A=0D=0AWhat do=
 you think=3F=0D=0A=0D=0AThanks,=0D=0AAviv=0D=0A=0D=0A=0D=0A
