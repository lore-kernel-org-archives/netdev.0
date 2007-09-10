From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Mon, 10 Sep 2007 15:38:23 +0100
Message-ID: <200709101538.25132.vda.linux@googlemail.com>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <200709101156.30010.vda.linux@googlemail.com> <20070910155156.2c1453fc@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Nick Piggin <piggin@cyberone.com.au>,
	Satyam Sharma <satyam@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.231]:6744 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759108AbXIJOig convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 10:38:36 -0400
Received: by qb-out-0506.google.com with SMTP id e11so1112385qbe
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 07:38:35 -0700 (PDT)
In-Reply-To: <20070910155156.2c1453fc@laptopd505.fenrus.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 10 September 2007 15:51, Arjan van de Ven wrote:
> On Mon, 10 Sep 2007 11:56:29 +0100
> Denys Vlasenko <vda.linux@googlemail.com> wrote:
>=20
> >=20
> > Well, if you insist on having it again:
> >=20
> > Waiting for atomic value to be zero:
> >=20
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0while (atomic_read(=
&x))
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0continue;
> >=20
>=20
> and this I would say is buggy code all the way.
>
> Not from a pure C level semantics, but from a "busy waiting is buggy"
> semantics level and a "I'm inventing my own locking" semantics level.

After inspecting arch/*, I cannot agree with you.
Otherwise almost all major architectures use
"conceptually buggy busy-waiting":

arch/alpha
arch/i386
arch/ia64
arch/m32r
arch/mips
arch/parisc
arch/powerpc
arch/sh
arch/sparc64
arch/um
arch/x86_64

All of the above contain busy-waiting on atomic_read.

Including these loops without barriers:

arch/mips/kernel/smtc.c
			while (atomic_read(&idle_hook_initialized) < 1000)
				;
arch/mips/sgi-ip27/ip27-nmi.c
	while (atomic_read(&nmied_cpus) !=3D num_online_cpus());

[Well maybe num_online_cpus() is a barrier, I didn't check]

arch/sh/kernel/smp.c
	if (wait)
		while (atomic_read(&smp_fn_call.finished) !=3D (nr_cpus - 1));

Bugs?
--
vda
