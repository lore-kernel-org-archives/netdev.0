From: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Subject: Re: [PATCH v3 6/7] fs: struct file move from call_rcu() to SLAB_DESTROY_BY_RCU
Date: Wed, 17 Dec 2008 21:25:20 +0100
Message-ID: <49496030.9080409@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <493100B0.6090104@cosmosbay.com> <494196DD.5070600@cosmosbay.com> <200707241113.46834.nickpiggin@yahoo.com.au> <4941EC65.5040903@cosmosbay.com> <494295C6.2020906@cosmosbay.com> <Pine.LNX.4.64.0812121958470.15781@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Nick Piggin <nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org >> Kernel Testers List"
	<kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
To: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0812121958470.15781-dRBSpnHQED8AvxtiuMwx3w@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Christoph Lameter a =E9crit :
> On Fri, 12 Dec 2008, Eric Dumazet wrote:
>=20
>>> a truly allocated file. At this point the file is
>>> a truly allocated file but not anymore ours.
>=20
> Its a valid file. Does ownership matter here?
>=20
>> Reading again this mail I realise we call put_filp(file), while this=
 should
>> be fput(file) or put_filp(file), we dont know.
>>
>> Damned, this patch is wrong as is.
>>
>> Christoph, Paul, do you see the problem ?
>=20
> Yes.
>=20
>> In fget()/fget_light() we dont know if the other thread (the one who=
 re-allocated the file,
>> and tried to close it while we got a reference on file) had to call =
put_filp() or fput()
>> to release its own reference. So we call atomic_long_dec_and_test() =
and cannot
>> take the appropriate action (calling the full __fput() version or th=
e small one,
>> that some systems use to 'close' an not really opened file.
>=20
> The difference is mainly that fput() does full processing whereas
> put_filp() is used when we know that the file was not fully operation=
al.
> If the checks in __fput are able to handle the put_filp() situation b=
y not
> releasing resources that were not allocated then we should be fine.
>=20
>> I believe put_filp() is only called on slowpath (error cases).
>=20
> Looks like it. It seems to assume that no dentry is associated.
>=20
>> Should we just zap it and always call fput() ?
>=20
> Only if fput() can handle partially setup files.

It can do that if we add a check for NULL dentry in __fput(), so put_fi=
lp() can disappear.

But there is a remaining point where we do an atomic_long_dec_and_test(=
&...->f_count),
in fs/aio.c, function __aio_put_req(). This one is tricky :(
