From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] sysctl: fix min/max handling in
 __do_proc_doulongvec_minmax()
Date: Mon, 4 Oct 2010 18:35:45 +0800
Message-ID: <20101004103545.GJ5189@cr0.nay.redhat.com>
References: <1286025469.2582.1806.camel@edumazet-laptop>
 <20101004085913.GR14068@sgi.com>
 <1286183058.18293.26.camel@edumazet-laptop>
 <20101004093439.GG5189@cr0.nay.redhat.com>
 <1286187030.18293.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	Robin Holt <holt@sgi.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1286187030.18293.33.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 04, 2010 at 12:10:30PM +0200, Eric Dumazet wrote:
>Le lundi 04 octobre 2010 =C3=A0 17:34 +0800, Am=C3=A9rico Wang a =C3=A9=
crit :
>> On Mon, Oct 04, 2010 at 11:04:18AM +0200, Eric Dumazet wrote:
>> >Le lundi 04 octobre 2010 =C3=A0 03:59 -0500, Robin Holt a =C3=A9cri=
t :
>> >> On Sat, Oct 02, 2010 at 03:17:49PM +0200, Eric Dumazet wrote:
>> >> > When proc_doulongvec_minmax() is used with an array of longs,
>> >> > and no min/max check requested (.extra1 or .extra2 being NULL),=
 we
>> >> > dereference a NULL pointer for the second element of the array.
>> >> >=20
>> >> > Noticed while doing some changes in network stack for the "16TB=
 problem"
>> >> >=20
>> >> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> >> > ---
>> >> >  kernel/sysctl.c |    3 ++-
>> >> >  1 file changed, 2 insertions(+), 1 deletion(-)
>> >> >=20
>> >> > diff --git a/kernel/sysctl.c b/kernel/sysctl.c
>> >> > index f88552c..4fba86d 100644
>> >> > --- a/kernel/sysctl.c
>> >> > +++ b/kernel/sysctl.c
>> >> > @@ -2500,7 +2500,8 @@ static int __do_proc_doulongvec_minmax(vo=
id *data, struct ctl_table *table, int
>> >> >  				break;
>> >> >  			if (neg)
>> >> >  				continue;
>> >> > -			if ((min && val < *min) || (max && val > *max))
>> >> > +			if ((table->extra1 && val < *min) ||
>> >> > +			    (table->extra2 && val > *max))
>> >>=20
>> >> How about changing:
>> >>         for (; left && vleft--; i++, min++, max++, first=3D0) {
>> >> into:
>> >>         for (; left && vleft--; i++, min =3D min ? min + 1 : NULL=
, max =3D max ? max + 1: NULL, first=3D0) {
>> >>=20
>> >> That would make min and max correct and reduce the chances somebo=
dy in
>> >> the future overlooks the fact they are currently filled with garb=
age.
>> >
>> >I prefer my solution, because the check is done only in the 'write'
>> >case, while its done also for 'read' in your solution, not counting=
 the
>> >for (;;) is really ugly...
>> >
>>=20
>> Sorry, I still don't get the point here, min and max
>> are pointers, they are already checked before dereferenced.
>> After your patch, min and max will be still increased, while
>> you are still checking ->extra{1,2} which is wrong.
>>=20
>> I see no problem with the original code, or I must have missed somet=
hing?
>
>Please re-read again. I had crashes, so original code is bugyy.
>
>Say you call __do_proc_doulongvec_minmax() with an array of three
>elements. And .extra1 =3D NULL, .extra2 =3D NULL (no range checks, thi=
s is a
>valid use case)
>
>First element, min =3D NULL OK. no problem so far.
>
>Second element, min =3D (long *)(NULL + sizeof(long))   -> BUG=20
>
>Third element, min =3D (long *)(NULL + 2*sizeof(long)) -> BUG=20
>
>After my patch, min/max increases normally (they are only pointers aft=
er
>all)
>
>But they are _dereferenced_ only if they were _not_ NULL at the
>beginning (extra1 not NULL for *min, extra2 not NULL for *max)
>

Hmm, I see, thanks for explanation.

Your patch does fix the problem, but seems not a good solution,
we should skip all min/max checking if ->extra(1|2) is NULL,
instead of checking it every time within the loop.

Thanks.
