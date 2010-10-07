From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] sysctl: fix min/max handling in __do_proc_doulongvec_minmax()
Date: Thu, 07 Oct 2010 09:37:32 -0700
Message-ID: <m1iq1e3qnn.fsf@fess.ebiederm.org>
References: <1286025469.2582.1806.camel@edumazet-laptop>
	<20101004085913.GR14068@sgi.com>
	<1286183058.18293.26.camel@edumazet-laptop>
	<20101004093439.GG5189@cr0.nay.redhat.com>
	<1286187030.18293.33.camel@edumazet-laptop>
	<20101004103545.GJ5189@cr0.nay.redhat.com>
	<1286188701.18293.57.camel@edumazet-laptop>
	<20101005130117.GK5170@cr0.nay.redhat.com>
	<20101007071859.GD5471@cr0.nay.redhat.com>
	<20101007092538.GE5471@cr0.nay.redhat.com>
	<1286445081.2912.15.camel@edumazet-laptop>
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
	"Pekka Savola \(ipv6\)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1286445081.2912.15.camel@edumazet-laptop> (Eric Dumazet's
	message of "Thu, 07 Oct 2010 11:51:21 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Le jeudi 07 octobre 2010 =C3=A0 17:25 +0800, Am=C3=A9rico Wang a =C3=A9=
crit :
>> >>
>> >
>> >Here is the final one.
>>=20
>> Oops, that one is not correct. Hopefully this one
>> is correct.
>>=20
>> --------------->
>>=20
>> Eric D. noticed that we may trigger an OOPS if we leave ->extra{1,2}
>> to NULL when we use proc_doulongvec_minmax().
>>=20
>> Actually, we don't need to store min/max values in a vector,
>> because all the elements in the vector should share the same min/max
>> value, like what proc_dointvec_minmax() does.
>>=20
>
> If we assert same min/max limits are to be applied to all elements,
> a much simpler fix than yours would be :
>
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index f88552c..8e45451 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -2485,7 +2485,7 @@ static int __do_proc_doulongvec_minmax(void *da=
ta, struct ctl_table *table, int
>  		kbuf[left] =3D 0;
>  	}
> =20
> -	for (; left && vleft--; i++, min++, max++, first=3D0) {
> +	for (; left && vleft--; i++, first=3D0) {
>  		unsigned long val;
> =20
>  		if (write) {
>
>
> Please dont send huge patches like this to 'fix' a bug,
> especially on slow path.
>
> First we fix the bug, _then_ we can try to make code more=20
> efficient or more pretty or shorter.
>
> So the _real_ question is :
>
> Should the min/max limits should be a single pair,
> shared by all elements, or a vector of limits.

The difference between long handling and int handling is a
usability issue.  I don't expect we will be exporting new
vectors via sysctl, so the conversion of a handful of vectors
from int to long is where this is most likely to be used.

I skimmed through all of what I presume are the current users
aka linux-2.6.36-rcX and there don't appear to be any users
of proc_dounlongvec_minmax that use it's vector properties there.

Which doubly tells me that incrementing the min and max pointers
is not what we want to do.

Eric
