From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sysctl: fix min/max handling in
 __do_proc_doulongvec_minmax()
Date: Mon, 04 Oct 2010 11:04:18 +0200
Message-ID: <1286183058.18293.26.camel@edumazet-laptop>
References: <1286025469.2582.1806.camel@edumazet-laptop>
	 <20101004085913.GR14068@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Robin Holt <holt@sgi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101004085913.GR14068@sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 04 octobre 2010 =C3=A0 03:59 -0500, Robin Holt a =C3=A9crit :
> On Sat, Oct 02, 2010 at 03:17:49PM +0200, Eric Dumazet wrote:
> > When proc_doulongvec_minmax() is used with an array of longs,
> > and no min/max check requested (.extra1 or .extra2 being NULL), we
> > dereference a NULL pointer for the second element of the array.
> >=20
> > Noticed while doing some changes in network stack for the "16TB pro=
blem"
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> >  kernel/sysctl.c |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> > index f88552c..4fba86d 100644
> > --- a/kernel/sysctl.c
> > +++ b/kernel/sysctl.c
> > @@ -2500,7 +2500,8 @@ static int __do_proc_doulongvec_minmax(void *=
data, struct ctl_table *table, int
> >  				break;
> >  			if (neg)
> >  				continue;
> > -			if ((min && val < *min) || (max && val > *max))
> > +			if ((table->extra1 && val < *min) ||
> > +			    (table->extra2 && val > *max))
>=20
> How about changing:
>         for (; left && vleft--; i++, min++, max++, first=3D0) {
> into:
>         for (; left && vleft--; i++, min =3D min ? min + 1 : NULL, ma=
x =3D max ? max + 1: NULL, first=3D0) {
>=20
> That would make min and max correct and reduce the chances somebody i=
n
> the future overlooks the fact they are currently filled with garbage.

I prefer my solution, because the check is done only in the 'write'
case, while its done also for 'read' in your solution, not counting the
for (;;) is really ugly...
