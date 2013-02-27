From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net/sctp: Validate parameter size for
 SCTP_GET_ASSOC_STATS control message
Date: Wed, 27 Feb 2013 15:43:36 -0500
Message-ID: <20130227204336.GC7993@hmsreliant.think-freely.org>
References: <1361994231-5355-1-git-send-email-linux@roeck-us.net>
 <20130227200931.GB7993@hmsreliant.think-freely.org>
 <20130227202255.GA31830@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56742 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005Ab3B0Unn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 15:43:43 -0500
Content-Disposition: inline
In-Reply-To: <20130227202255.GA31830@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 27, 2013 at 12:22:55PM -0800, Guenter Roeck wrote:
> On Wed, Feb 27, 2013 at 03:09:31PM -0500, Neil Horman wrote:
> > On Wed, Feb 27, 2013 at 11:43:51AM -0800, Guenter Roeck wrote:
> > > Building sctp may fail with:
> > >=20
> > > In function =E2=80=98copy_from_user=E2=80=99,
> > >     inlined from =E2=80=98sctp_getsockopt_assoc_stats=E2=80=99 at
> > >     net/sctp/socket.c:5656:20:
> > > arch/x86/include/asm/uaccess_32.h:211:26: error: call to
> > >     =E2=80=98copy_from_user_overflow=E2=80=99 declared with attri=
bute error: copy_from_user()
> > >     buffer size is not provably correct
> > >=20
> > > if built with W=3D1 due to a missing parameter size validation.
> > >=20
> > > Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> > > ---
> > >  net/sctp/socket.c |    2 ++
> > >  1 file changed, 2 insertions(+)
> > >=20
> > > diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> > > index cedd9bf..0a5f2bf 100644
> > > --- a/net/sctp/socket.c
> > > +++ b/net/sctp/socket.c
> > > @@ -5652,6 +5652,8 @@ static int sctp_getsockopt_assoc_stats(stru=
ct sock *sk, int len,
> > >  	/* User must provide at least the assoc id */
> > >  	if (len < sizeof(sctp_assoc_t))
> > >  		return -EINVAL;
> > > +	if (len > sizeof(struct sctp_assoc_stats))
> > > +		len =3D sizeof(struct sctp_assoc_stats);
> > > =20
> > >  	if (copy_from_user(&sas, optval, len))
> > >  		return -EFAULT;
> > > --=20
> > > 1.7.9.7
> > >=20
> > >=20
> >=20
> > Theres more than that going on here.  This will fix the warning, bu=
t the
> > function is written such that, if you pass in a size that is greate=
r than the
> > size of a struct sctp_association, but less than a struct sctp_asso=
c_stats.  I'm
> > not sure that a partial stat struct is really that useful to people=
=2E  What if
> > you were to check for max(struct sctp_association, struct sctp_asso=
c_stats) as
> > your minimum length check, then just did a copy_from_user of that l=
ength.  It
> > would save you having to compute two lengths separately, since you =
could then
> > just do a copy_to_user(...,sizeof(struct sctp_assoc_stats), at the =
bottom of
> > that function.
> >=20
> Yes, but that would require input from someone who knows the code. Al=
l I am trying
> to accomplish is to ensure that copy_from_user does not overwrite the=
 stack.
>=20
Not really, its pretty straightforward.  Although, its kind of moot, af=
ter Daves
note I looked again, and if the size of the stats structure is less tha=
n the
association structure, everything works fine, but if the association is=
 smaller
than the association, we'll get an EFAULT on the copy to user.  So it a=
ll works
out

Acked-by: Neil Horman <nhorman@tuxdriver.com>


Dave
> Thanks,
> Guenter
>=20
