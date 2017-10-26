From: =?UTF-8?Q?Aviv_Heller?= <aviv@avivh.com>
Subject: RE: [PATCH net-next 2/3] xfrm: Fix offload dev state addition to
 occur after insertion
Date: Thu, 26 Oct 2017 14:55:22 +0000
Message-ID: <0101015f592e37fc-52b058e2-34f2-489a-98d4-a71d7d934fe5-000000@us-west-2.amazonses.com>
References: <1508857831-55824-1-git-send-email-avivh@mellanox.com>
 <1508857831-55824-2-git-send-email-avivh@mellanox.com>
 <20171025072214.GP3323@secunet.com>
 <0101015f53a726b1-d5731696-249f-449c-8c84-1d047cfaffb0-000000@us-west-2.amazonses.com>
 <20171026061610.GR3323@secunet.com>
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
To: =?UTF-8?Q?Steffen_Klassert?= <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a27-41.smtp-out.us-west-2.amazonses.com ([54.240.27.41]:44538
        "EHLO a27-41.smtp-out.us-west-2.amazonses.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932291AbdJZOzX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 10:55:23 -0400
In-Reply-To: <20171026061610.GR3323@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----Original message-----=0D=0A> From: Steffen Klassert=0D=0A> Sent: Thu=
rsday, October 26 2017, 9:16 am=0D=0A> To: Aviv Heller=0D=0A> Cc: netdev-=
owner@vger.kernel.org; avivh@mellanox.com; Herbert Xu; Boris Pismenny; Yo=
ssi Kuperman; Yevgeny Kliteynik; netdev@vger.kernel.org=0D=0A> Subject: R=
e: [PATCH net-next 2/3] xfrm: Fix offload dev state addition to occur aft=
er insertion=0D=0A>=20=0D=0A> On Wed, Oct 25, 2017 at 01:09:44PM +0000, A=
viv Heller wrote:=0D=0A> > -----Original message-----=0D=0A> > > From: St=
effen Klassert=0D=0A> > > Sent: Wednesday, October 25 2017, 10:22 am=0D=0A=
> > > To: avivh@mellanox.com=0D=0A> > > Cc: Herbert Xu; Boris Pismenny; Y=
ossi Kuperman; Yevgeny Kliteynik; netdev@vger.kernel.org=0D=0A> > > Subje=
ct: Re: [PATCH net-next 2/3] xfrm: Fix offload dev state addition to occu=
r after insertion=0D=0A> > >=20=0D=0A> > > On Tue, Oct 24, 2017 at 06:10:=
30PM +0300, avivh@mellanox.com wrote:=0D=0A> > > > From: Aviv Heller <avi=
vh@mellanox.com>=0D=0A> > > >=20=0D=0A> > > > Adding the state to the off=
load device prior to replay init in=0D=0A> > > > xfrm_state_construct() w=
ill result in NULL dereference if a matching=0D=0A> > > > ESP packet is r=
eceived in between.=0D=0A> > > >=20=0D=0A> > > > Adding it after insertio=
n also has the benefit of the driver not having=0D=0A> > > > to check whe=
ther a state with the same match criteria already exists,=0D=0A> > > > bu=
t forces us to use an atomic type for the offload_handle, to make=0D=0A> =
> > > certain a stack-read/driver-write race won't result in reading corr=
upt=0D=0A> > > > data.=0D=0A> > >=20=0D=0A> > > No, this will add multipl=
e atomic operations to the packet path,=0D=0A> > > even in the non offloa=
ded case.=0D=0A> > >=20=0D=0A> > > I think the problem is that we set XFR=
M_STATE_VALID to early.=0D=0A> > > This was not a problem before we had o=
ffloading because=0D=0A> > > it was not possible to lookup this state bef=
ore we inserted=0D=0A> > > it into the SADB. Now that the driver holds a =
subset of states=0D=0A> > > too, we need to make sure the state is fully =
initialized=0D=0A> > > before we mark it as valid.=0D=0A> > >=20=0D=0A> >=
 > The patch below should do it, in combination with your patch 1/3.=0D=0A=
> > >=20=0D=0A> > > Could you please test this=3F=0D=0A> > >=20=0D=0A> > =
> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c=0D=0A> > > ind=
ex b997f13..96eb263 100644=0D=0A> > > --- a/net/xfrm/xfrm_user.c=0D=0A> >=
 > +++ b/net/xfrm/xfrm_user.c=0D=0A> > > @@ -587,10 +587,6 @@ static stru=
ct xfrm_state *xfrm_state_construct(struct net *net,=0D=0A> > >  =09if (a=
ttrs[XFRMA_OUTPUT_MARK])=0D=0A> > >  =09=09x->props.output_mark =3D nla_g=
et_u32(attrs[XFRMA_OUTPUT_MARK]);=0D=0A> > > =20=0D=0A> > > -=09err =3D _=
_xfrm_init_state(x, false, attrs[XFRMA_OFFLOAD_DEV]);=0D=0A> > > -=09if (=
err)=0D=0A> > > -=09=09goto error;=0D=0A> > > -=0D=0A> > >  =09if (attrs[=
XFRMA_SEC_CTX]) {=0D=0A> > >  =09=09err =3D security_xfrm_state_alloc(x,=0D=
=0A> > >  =09=09=09=09=09=09nla_data(attrs[XFRMA_SEC_CTX]));=0D=0A> > > @=
@ -620,6 +616,10 @@ static struct xfrm_state *xfrm_state_construct(struct=
 net *net,=0D=0A> > >  =09/* override default values from above */=0D=0A>=
 > >  =09xfrm_update_ae_params(x, attrs, 0);=0D=0A> > > =20=0D=0A> > > +=09=
err =3D __xfrm_init_state(x, false, attrs[XFRMA_OFFLOAD_DEV]);=0D=0A> > >=
 +=09if (err)=0D=0A> > > +=09=09goto error;=0D=0A> > > +=0D=0A> > >  =09r=
eturn x;=0D=0A> > > =20=0D=0A> > >  error:=0D=0A> > >=20=0D=0A> >=20=0D=0A=
> > Hi Steffen,=0D=0A> >=20=0D=0A> > This patch does not work, due to:=0D=
=0A> > =09if (!x->type_offload)=0D=0A> > =09=09return -EINVAL;=0D=0A> >=20=
=0D=0A> > test in xfrm_dev_state_add().=0D=0A>=20=0D=0A> There is certain=
ly a way arround that :)=0D=0A> The easiest I can think of would be to pr=
opagate XFRM_STATE_VALID=0D=0A> only after the state is inserted into the=
 SADBs. I.e. move the=0D=0A> setting of XFRM_STATE_VALID out of __xfrm_in=
it_state() and let the=0D=0A> callers do it.=0D=0A=0D=0AThis does seem li=
ke the easiest solution, if we don't move state addition to occur after i=
nsertion.=0D=0AI'm waiting for our regression results (probably on Monday=
) for the patch below, and would appreciate your comments:=0D=0A=0D=0AFro=
m 4da5c12abb59113428668afffc42eb51c48fa894 Mon Sep 17 00:00:00 2001=0D=0A=
From: Aviv Heller <avivh@mellanox.com>=0D=0ADate: Thu, 26 Oct 2017 16:30:=
41 +0300=0D=0ASubject: [PATCH] Temp=0D=0A=0D=0ASigned-off-by: Aviv Heller=
 <avivh@mellanox.com>=0D=0A---=0D=0A net/ipv4/ipcomp.c     |  1 +=0D=0A n=
et/ipv6/ipcomp6.c    |  1 +=0D=0A net/key/af_key.c      |  1 +=0D=0A net/=
xfrm/xfrm_state.c |  6 +++---=0D=0A net/xfrm/xfrm_user.c  | 16 +++++++++-=
------=0D=0A 5 files changed, 15 insertions(+), 10 deletions(-)=0D=0A=0D=0A=
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c=0D=0Aindex d97f4f2..00=
16162 100644=0D=0A--- a/net/ipv4/ipcomp.c=0D=0A+++ b/net/ipv4/ipcomp.c=0D=
=0A@@ -80,6 +80,7 @@ static struct xfrm_state *ipcomp_tunnel_create(struc=
t xfrm_state *x)=0D=0A =09if (xfrm_init_state(t))=0D=0A =09=09goto error;=
=0D=0A=20=0D=0A+=09t->km.state =3D XFRM_STATE_VALID;=0D=0A =09atomic_set(=
&t->tunnel_users, 1);=0D=0A out:=0D=0A =09return t;=0D=0Adiff --git a/net=
/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c=0D=0Aindex 54d165b..95b67f3 100644=0D=
=0A--- a/net/ipv6/ipcomp6.c=0D=0A+++ b/net/ipv6/ipcomp6.c=0D=0A@@ -107,6 =
+107,7 @@ static struct xfrm_state *ipcomp6_tunnel_create(struct xfrm_sta=
te *x)=0D=0A =09if (xfrm_init_state(t))=0D=0A =09=09goto error;=0D=0A=20=0D=
=0A+=09t->km.state =3D XFRM_STATE_VALID;=0D=0A =09atomic_set(&t->tunnel_u=
sers, 1);=0D=0A=20=0D=0A out:=0D=0Adiff --git a/net/key/af_key.c b/net/ke=
y/af_key.c=0D=0Aindex 10d7133..d1d43f7 100644=0D=0A--- a/net/key/af_key.c=
=0D=0A+++ b/net/key/af_key.c=0D=0A@@ -1276,6 +1276,7 @@ static struct xfr=
m_state * pfkey_msg2xfrm_state(struct net *net,=0D=0A =09=09goto out;=0D=0A=
=20=0D=0A =09x->km.seq =3D hdr->sadb_msg_seq;=0D=0A+=09x->km.state =3D XF=
RM_STATE_VALID;=0D=0A =09return x;=0D=0A=20=0D=0A out:=0D=0Adiff --git a/=
net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c=0D=0Aindex a41e2ef..38b90fd=
 100644=0D=0A--- a/net/xfrm/xfrm_state.c=0D=0A+++ b/net/xfrm/xfrm_state.c=
=0D=0A@@ -1401,10 +1401,12 @@ static struct xfrm_state *xfrm_state_clone(=
struct xfrm_state *orig,=0D=0A =09x->km.seq =3D orig->km.seq;=0D=0A =09x-=
>replay =3D orig->replay;=0D=0A =09x->preplay =3D orig->preplay;=0D=0A+=09=
x->km.state =3D XFRM_STATE_VALID;=0D=0A=20=0D=0A =09return x;=0D=0A=20=0D=
=0A- error:=0D=0A+error:=0D=0A+=09x->km.state =3D XFRM_STATE_DEAD;=0D=0A =
=09xfrm_state_put(x);=0D=0A out:=0D=0A =09return NULL;=0D=0A@@ -2256,8 +2=
258,6 @@ int __xfrm_init_state(struct xfrm_state *x, bool init_replay, bo=
ol offload)=0D=0A =09=09=09goto error;=0D=0A =09}=0D=0A=20=0D=0A-=09x->km=
=2Estate =3D XFRM_STATE_VALID;=0D=0A-=0D=0A error:=0D=0A =09return err;=0D=
=0A }=0D=0Adiff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c=0D=0A=
index ffe8d5e..df304c2 100644=0D=0A--- a/net/xfrm/xfrm_user.c=0D=0A+++ b/=
net/xfrm/xfrm_user.c=0D=0A@@ -595,13 +595,6 @@ static struct xfrm_state *=
xfrm_state_construct(struct net *net,=0D=0A =09=09=09goto error;=0D=0A =09=
}=0D=0A=20=0D=0A-=09if (attrs[XFRMA_OFFLOAD_DEV]) {=0D=0A-=09=09err =3D x=
frm_dev_state_add(net, x,=0D=0A-=09=09=09=09=09 nla_data(attrs[XFRMA_OFFL=
OAD_DEV]));=0D=0A-=09=09if (err)=0D=0A-=09=09=09goto error;=0D=0A-=09}=0D=
=0A-=0D=0A =09if ((err =3D xfrm_alloc_replay_state_esn(&x->replay_esn, &x=
->preplay_esn,=0D=0A =09=09=09=09=09       attrs[XFRMA_REPLAY_ESN_VAL])))=
=0D=0A =09=09goto error;=0D=0A@@ -617,6 +610,15 @@ static struct xfrm_sta=
te *xfrm_state_construct(struct net *net,=0D=0A =09/* override default va=
lues from above */=0D=0A =09xfrm_update_ae_params(x, attrs, 0);=0D=0A=20=0D=
=0A+=09x->km.state =3D XFRM_STATE_VALID;=0D=0A+=0D=0A+=09if (attrs[XFRMA_=
OFFLOAD_DEV]) {=0D=0A+=09=09err =3D xfrm_dev_state_add(net, x,=0D=0A+=09=09=
=09=09=09 nla_data(attrs[XFRMA_OFFLOAD_DEV]));=0D=0A+=09=09if (err)=0D=0A=
+=09=09=09goto error;=0D=0A+=09}=0D=0A+=0D=0A =09return x;=0D=0A=20=0D=0A=
 error:=0D=0A--=20=0D=0A1.8.3.1=0D=0A
