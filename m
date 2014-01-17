From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 3/3] reciprocal_divide: correction/update of
 the algorithm
Date: Thu, 16 Jan 2014 18:33:37 -0800
Message-ID: <1389926017.31367.464.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389918519-23779-1-git-send-email-hannes@stressinduktion.org>
	 <1389918519-23779-4-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Austin S Hemmelgarn <ahferroin7@gmail.com>,
	linux-kernel@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Matt Mackall <mpm@selenic.com>,
	Pekka Enberg <penberg@kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>,
	Daniel Borkmann <dborkman@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f181.google.com ([209.85.161.181]:53744 "EHLO
	mail-gg0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584AbaAQCdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 21:33:42 -0500
In-Reply-To: <1389918519-23779-4-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-17 at 01:28 +0100, Hannes Frederic Sowa wrote:
> Jakub Zawadzki noticed that some divisions by reciprocal_divide()
> were not correct [1][2], which he could also show with BPF code after
> divisions are transformed into reciprocal_value() for runtime invaria=
nt
> which can be passed to reciprocal_divide() later on; reverse in BPF d=
ump
> ended up with a different, off-by-one K.
>=20
> This has been fixed by Eric Dumazet in commit aee636c4809fa5 ("bpf: d=
o not
> use reciprocal divide"). This follow-up patch improves reciprocal_val=
ue()
> and reciprocal_divide() to work in all cases, so future use is safe.
>=20
> Known problems with the old implementation were that division by 1 al=
ways
> returned 0 and some off-by-ones when the dividend and divisor where
> very large.  This seemed to not be problematic with its current users
> in networking, mm/slab.c and lib/flex_array.c, but future users would
> need to check for this specifically and it might not be obvious at fi=
rst.
>=20
> In order to fix that, we propose an extension from the original
> implementation from commit 6a2d7a955d8d resp. [3][4], by using
> the algorithm proposed in "Division by Invariant Integers Using
> Multiplication" [5], Torbj=C3=B6rn Granlund and Peter L. Montgomery, =
that is,
> pseudocode for q =3D n/d where q,n,d is in u32 universe:
>=20
> 1) Initialization:
>=20
>   int l =3D ceil(log_2 d)
>   uword m' =3D floor((1<<32)*((1<<l)-d)/d)+1
>   int sh_1 =3D min(l,1)
>   int sh_2 =3D max(l-1,0)
>=20
> 2) For q =3D n/d, all uword:
>=20
>   uword t =3D (n*m')>>32
>   q =3D (t+((n-t)>>sh_1))>>sh_2
>=20
> The assembler implementation from Agner Fog [6] also helped a lot
> while implementing. We have tested the implementation on x86_64,
> ppc64, i686, s390x; on x86_64/haswell we're still half the latency
> compared to normal divide.
>=20
> Joint work with Daniel Borkmann.
>=20
>   [1] http://www.wireshark.org/~darkjames/reciprocal-buggy.c
>   [2] http://www.wireshark.org/~darkjames/set-and-dump-filter-k-bug.c
>   [3] https://gmplib.org/~tege/division-paper.pdf
>   [4] http://homepage.cs.uiowa.edu/~jones/bcd/divide.html
>   [5] http://citeseerx.ist.psu.edu/viewdoc/summary?doi=3D10.1.1.1.255=
6
>   [6] http://www.agner.org/optimize/asmlib.zip
>=20
> Fixes: 6a2d7a955d8d ("SLAB: use a multiply instead of a divide in obj=
_to_index()")


I already demonstrated this slab patch was fine.

The current algo works well (no off-by-one error) when the dividend is
a multiple of the divisor.

You are adding extra overhead, while we know its not necessary.

By using "Fixes: ... " you are asking a backport to stable branches,
which seems really silly in this case, especially with this monolithic
patch changing 12 files in different subsystems.

If you believe flex_array has a problem, please fix flex_array only,
by a small patch (Maybe a revert ?)

Then, introduce your new helpers if we really think they are needed.
