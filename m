From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Wed, 07 Sep 2011 04:35:12 +0200
Message-ID: <1315362912.3400.51.camel@edumazet-laptop>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315335019.2576.3048.camel@schen9-DESK>
	 <1315335660.3400.7.camel@edumazet-laptop>
	 <1315337580.2576.3066.camel@schen9-DESK>
	 <1315338186.3400.20.camel@edumazet-laptop>
	 <1315339157.2576.3079.camel@schen9-DESK>
	 <1315340388.3400.28.camel@edumazet-laptop>
	 <1315346920.2576.3089.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yan, Zheng" <zheng.z.yan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>, alex.shi@intel.com
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55502 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189Ab1IGCfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 22:35:22 -0400
Received: by wwf5 with SMTP id 5so6942526wwf.1
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2011 19:35:21 -0700 (PDT)
In-Reply-To: <1315346920.2576.3089.camel@schen9-DESK>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 septembre 2011 =C3=A0 15:08 -0700, Tim Chen a =C3=A9crit :
> On Tue, 2011-09-06 at 22:19 +0200, Eric Dumazet wrote:
>=20
> >=20
> > unless scm_ref really means scm_noref ?
> >=20
> > I really hate this patch. I mean it.=20
> >=20
> > I read it 10 times, spent 2 hours and still dont understand it.
> >=20
>=20
> Eric,
>=20
> I've tried another patch to fix my original one.  I've used a boolean
> ref_avail to indicate if there is an outstanding ref to scm not yet
> encoded into the skb.  Hopefully the logic is clearer in this new pat=
ch.
>=20
> >=20
> > As I said, we should revert the buggy patch, and rewrite a performa=
nce
> > fix from scratch, with not a single get_pid()/put_pid() in fast pat=
h.
> >=20
> > read()/write() on AF_UNIX sockets should not use a single
> > get_pid()/put_pid().
> >=20
> > This is a serious regression we should fix at 100%, not 50% or even=
 75%,
> > adding serious bugs.
>=20
> That will be ideal if there is another way to fix it 100%, other than=
 reverting
> commit 7361c36c.  Probably if there is some way we know beforehand th=
at=20
> both sender and receiver share the same pid, which is quite common, a
> lot of these pid code can be bypassed.=20
>=20

Let me restate : Its should be obvious to fix the performance hit for
good.

If namespaces are not used (CONFIG_PID_NS is not set), we can use the
old code, prior to commit 7361c36c : store pid/uid/gid in skb->cb[]

But more generally, when a write() is done on AF_UNIX socket, we pass a
NULL siocb->scm to unix_{dgram|stream}_sendmsg()

if (NULL =3D=3D siocb->scm)
	siocb->scm =3D &tmp_scm;

There is no need in this case to copy in each skb->cb, pointers to
struct pid and struct cred with their atomic reference being changed in
the sender and receiver.

We try to remove _all_ atomic ops on refcounts not only because atomic
ops are expensive by themselves, but also because of the cache line pin=
g
pongs.=20


> Tim
>=20
>=20
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> ---
>=20

When a patch is wrong, you can admit it and ask for a revert, instead o=
f
obfuscating the code so much that even a netdev guy like me doesnt
understand it anymore.

We speak of a very recent patch in net-next, not yet published to Linus
tree. There is no shame to revert it right now and work on a new patch.

I want to be able to track future bugs on this code, and your patch and
their fixes made functions too hard to read.

If you dont want to work on it, I'll do it myself.
