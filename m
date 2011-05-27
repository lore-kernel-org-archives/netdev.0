From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 1/1] net: convert %p usage to %pK
Date: Fri, 27 May 2011 08:37:06 +0200
Message-ID: <20110527063706.GC9260@elte.hu>
References: <20110525232921.GD19633@outflux.net>
 <20110525.215040.47969627064310792.davem@davemloft.net>
 <20110527001449.GS19633@outflux.net>
 <20110526.224427.433160775431725543.davem@davemloft.net>
 <1306465841.2543.52.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kees.cook@canonical.com,
	joe@perches.com, akpm@linux-foundation.org, netdev@vger.kernel.org,
	drosenberg@vsecurity.com, a.p.zijlstra@chello.nl,
	eparis@parisplace.org, eugeneteo@kernel.org, jmorris@namei.org,
	tgraf@infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:39332 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751525Ab1E0GhX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2011 02:37:23 -0400
Content-Disposition: inline
In-Reply-To: <1306465841.2543.52.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 26 mai 2011 =E0 22:44 -0400, David Miller a =E9crit :
> > From: Kees Cook <kees.cook@canonical.com>
> > Date: Thu, 26 May 2011 17:14:49 -0700
> > >=20
> > > We got this dropped from the /proc view; why can't we do the same=
 for
> > > this netlink interface?
> >=20
> > Because it's not only an opaque "output" blob, it's also an input k=
ey
> > for lookups which the user can trigger.
>=20
> Yes, we wan add a layer to obfuscate the real pointers. We dont=20
> trust values given by user, only match them.
>=20
> Either we use a XOR with a boot time random value (but let the NULL=20
> cookie being the NULL one), or we generate an unique 64bit socket=20
> id for the cookie (and keep a 64bit cookie in all sockets,=20
> increasing ram usage)

=46YI, Dan Rosenberg is currently working on a kernel image=20
randomization feature, see this lkml thread:

   [RFC][PATCH] Randomize kernel base address on boot

That will come with an easy vsprintf method to 'unrandomize' IPs.=20

( this will be used to display a real-looking /proc/kallsyms and all=20
  IPs that the kernel passes to user-space (via perf, etc.) will be=20
  unrandomized as well, protecting the randomization seed. )

Once that code goes upstream the networking code could rather simply=20
use it to 'randomize' these real data pointers as well. (Assuming you=20
never ever pass in zero, that would expose the secret seed.)

The only worry would be statistical analysis performed by local=20
attackers: by creating and closing enough sockets on a busy system=20
you can over time cover almost all ranges of RAM, so if you can=20
observe a pattern of 'over the address space limit' addresses at the=20
top or the bottom of the address space you can estimate the random=20
seed to within 4-5 bits realistically, maybe even more.

The upper and lower limit of the address space (big holes are useful=20
too) can be calculated rather precisely based on RAM size, the=20
identity of the system and the kernel version.

So maybe networking real-pointer randomization should be separate=20
from kernel IP randomization after all.

Thanks,

	Ingo
