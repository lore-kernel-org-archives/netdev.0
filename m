From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables --
 proto.sockets_allocated
Date: Fri, 27 Jan 2006 15:16:35 -0800
Message-ID: <20060127151635.3a149fe2.akpm@osdl.org>
References: <20060126185649.GB3651@localhost.localdomain>
	<20060126190357.GE3651@localhost.localdomain>
	<43D9DFA1.9070802@cosmosbay.com>
	<20060127195227.GA3565@localhost.localdomain>
	<20060127121602.18bc3f25.akpm@osdl.org>
	<20060127224433.GB3565@localhost.localdomain>
	<43DAA586.5050609@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kiran@scalex86.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shai@scalex86.org,
	netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932508AbWA0XOx@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <43DAA586.5050609@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <dada1@cosmosbay.com> wrote:
>
> Ravikiran G Thirumalai a =E9crit :
> > On Fri, Jan 27, 2006 at 12:16:02PM -0800, Andrew Morton wrote:
> >> Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
> >>> which can be assumed as not frequent. =20
> >>> At sk_stream_mem_schedule(), read_sockets_allocated() is invoked =
only=20
> >>> certain conditions, under memory pressure -- on a large CPU count=
 machine,=20
> >>> you'd have large memory, and I don't think read_sockets_allocated=
 would get=20
> >>> called often.  It did not atleast on our 8cpu/16G box.  So this s=
hould be OK=20
> >>> I think.
> >> That being said, the percpu_counters aren't a terribly successful =
concept
> >> and probably do need a revisit due to the high inaccuracy at high =
CPU
> >> counts.  It might be better to do some generic version of vm_acct_=
memory()
> >> instead.
> >=20
> > AFAICS vm_acct_memory is no better.  The deviation on large cpu cou=
nts is the=20
> > same as percpu_counters -- (NR_CPUS * NR_CPUS * 2) ...
>=20
> Ah... yes you are right, I read min(16, NR_CPUS*2)

So did I ;)

> I wonder if it is not a typo... I mean, I understand the more cpus yo=
u have,=20
> the less updates on central atomic_t is desirable, but a quadratic of=
fset=20
> seems too much...

I'm not sure whether it was a mistake or if I intended it and didn't do=
 the
sums on accuracy :(

An advantage of retaining a spinlock in percpu_counter is that if accur=
acy
is needed at a low rate (say, /proc reading) we can take the lock and t=
hen
go spill each CPU's local count into the main one.  It would need to be=
 a
very low rate though.   Or we make the cpu-local counters atomic too.

Certainly it's sensible to delegate the tuning to the creator of the
percpu_counter, but it'll be a difficult thing to get right.
