From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/2] include/uapi/linux/xfrm.h: Pack struct
 xfrm_usersa_info
Date: Thu, 9 Jan 2014 18:58:58 +0000
Message-ID: <1389293938.2025.17.camel@bwh-desktop.uk.level5networks.com>
References: <1389077339-12814-1-git-send-email-fan.du@windriver.com>
		 <1389077339-12814-3-git-send-email-fan.du@windriver.com>
	 <1389213183.1644.31.camel@bwh-desktop.uk.level5networks.com>
	 <52CE5CBA.9000200@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<stephen@networkplumber.org>, <dev@lists.strongswan.org>,
	<netdev@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:57920 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754979AbaAIS7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 13:59:03 -0500
In-Reply-To: <52CE5CBA.9000200@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-09 at 16:24 +0800, Fan Du wrote:
>=20
> On 2014=E5=B9=B401=E6=9C=8809=E6=97=A5 04:33, Ben Hutchings wrote:
> > On Tue, 2014-01-07 at 14:48 +0800, Fan Du wrote:
> >> Otherwise 64bits kernel has sizeof(struct xfrm_usersa_info) 224 by=
tes,
> >> while 32bits compiled iproute2 see the same structure as 220 bytes=
, which
> >> leading deficit xfrm sa, in turn broken IPsec connectivity.
> >>
> >> Fix this by packing the structure.
> >>
> >> Signed-off-by: Fan Du<fan.du@windriver.com>
> >> ---
> >>   include/uapi/linux/xfrm.h |    2 +-
> >>   1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
> >> index 470bfae..61460c4 100644
> >> --- a/include/uapi/linux/xfrm.h
> >> +++ b/include/uapi/linux/xfrm.h
> >> @@ -366,7 +366,7 @@ struct xfrm_usersa_info {
> >>   #define XFRM_STATE_AF_UNSPEC	32
> >>   #define XFRM_STATE_ALIGN4	64
> >>   #define XFRM_STATE_ESN		128
> >> -};
> >> +} __attribute__((packed));
> >>
> >>   #define XFRM_SA_XFLAG_DONT_ENCAP_DSCP	1
> >>
> >
> > That change will make access to the structure very slow on some
> > architectures, and I suspect it will cause other compatibility prob=
lems.
> >
> > I think the right thing to do is to reduce the minimum length of th=
e
> > structure in the netlink policy so that padding at the end is not
> > required.
>=20
> Could you please be more specific about this? Thanks.
[...]

Each netlink message and attribute has a specified minimum size, and
messages are rejected if the size provided by the sender is too small.
The minimum size is normally the same as the structure size, but doesn'=
t
have to be.

Something like this might work:

--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2266,8 +2266,15 @@ static int xfrm_send_migrate(const struct xfrm_s=
elector *sel, u8 dir, u8 type,
=20
 #define XMSGSIZE(type) sizeof(struct type)
=20
+/* Padding at the end of struct xfrm_usersa_info differs between
+ * architectures so for 32/64-bit compat we don't require padding
+ */
+#define XMSGSIZE_XFRM_USERSA_INFO				\
+	(offsetof(struct xfrm_usersa_info, flags) +		\
+	 sizeof(((struct xfrm_usersa_info *)NULL)->flags))
+
 static const int xfrm_msg_min[XFRM_NR_MSGTYPES] =3D {
-	[XFRM_MSG_NEWSA       - XFRM_MSG_BASE] =3D XMSGSIZE(xfrm_usersa_info)=
,
+	[XFRM_MSG_NEWSA       - XFRM_MSG_BASE] =3D XMSGSIZE_XFRM_USERSA_INFO,
 	[XFRM_MSG_DELSA       - XFRM_MSG_BASE] =3D XMSGSIZE(xfrm_usersa_id),
 	[XFRM_MSG_GETSA       - XFRM_MSG_BASE] =3D XMSGSIZE(xfrm_usersa_id),
 	[XFRM_MSG_NEWPOLICY   - XFRM_MSG_BASE] =3D XMSGSIZE(xfrm_userpolicy_i=
nfo),
@@ -2277,7 +2284,7 @@ static const int xfrm_msg_min[XFRM_NR_MSGTYPES] =3D=
 {
 	[XFRM_MSG_ACQUIRE     - XFRM_MSG_BASE] =3D XMSGSIZE(xfrm_user_acquire=
),
 	[XFRM_MSG_EXPIRE      - XFRM_MSG_BASE] =3D XMSGSIZE(xfrm_user_expire)=
,
 	[XFRM_MSG_UPDPOLICY   - XFRM_MSG_BASE] =3D XMSGSIZE(xfrm_userpolicy_i=
nfo),
-	[XFRM_MSG_UPDSA       - XFRM_MSG_BASE] =3D XMSGSIZE(xfrm_usersa_info)=
,
+	[XFRM_MSG_UPDSA       - XFRM_MSG_BASE] =3D XMSGSIZE_XFRM_USERSA_INFO,
 	[XFRM_MSG_POLEXPIRE   - XFRM_MSG_BASE] =3D XMSGSIZE(xfrm_user_polexpi=
re),
 	[XFRM_MSG_FLUSHSA     - XFRM_MSG_BASE] =3D XMSGSIZE(xfrm_usersa_flush=
),
 	[XFRM_MSG_FLUSHPOLICY - XFRM_MSG_BASE] =3D 0,
@@ -2292,7 +2299,7 @@ static const int xfrm_msg_min[XFRM_NR_MSGTYPES] =3D=
 {
 #undef XMSGSIZE
=20
 static const struct nla_policy xfrma_policy[XFRMA_MAX+1] =3D {
-	[XFRMA_SA]		=3D { .len =3D sizeof(struct xfrm_usersa_info)},
+	[XFRMA_SA]		=3D { .len =3D XMSGSIZE_XFRM_USERSA_INFO },
 	[XFRMA_POLICY]		=3D { .len =3D sizeof(struct xfrm_userpolicy_info)},
 	[XFRMA_LASTUSED]	=3D { .type =3D NLA_U64},
 	[XFRMA_ALG_AUTH_TRUNC]	=3D { .len =3D sizeof(struct xfrm_algo_auth)},
---

But beware that if the structure is copied in and then copied back out
to userland then the padding will need to be explicitly cleared.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
