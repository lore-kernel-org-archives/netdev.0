From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] lib: cpu_rmap: CPU affinity reverse-mapping
Date: Tue, 04 Jan 2011 22:04:50 +0000
Message-ID: <1294178690.3636.49.camel@bwh-desktop>
References: <1294169842.3636.31.camel@bwh-desktop>
	 <1294169967.3636.34.camel@bwh-desktop>
	 <1294175823.3420.7.camel@edumazet-laptop>
	 <1294176216.3636.38.camel@bwh-desktop>
	 <1294177548.3420.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294177548.3420.11.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-01-04 at 22:45 +0100, Eric Dumazet wrote:
> Le mardi 04 janvier 2011 =C3=A0 21:23 +0000, Ben Hutchings a =C3=A9cr=
it :
> > On Tue, 2011-01-04 at 22:17 +0100, Eric Dumazet wrote:
> > > Le mardi 04 janvier 2011 =C3=A0 19:39 +0000, Ben Hutchings a =C3=A9=
crit :
> > > > When initiating I/O on a multiqueue and multi-IRQ device, we ma=
y want
> > > > to select a queue for which the response will be handled on the=
 same
> > > > or a nearby CPU.  This requires a reverse-map of IRQ affinity. =
 Add
> > > > library functions to support a generic reverse-mapping from CPU=
s to
> > > > objects with affinity and the specific case where the objects a=
re
> > > > IRQs.
> > [...]
> > > > +/**
> > > > + * struct cpu_rmap - CPU affinity reverse-map
> > > > + * @near: For each CPU, the index and distance to the nearest =
object,
> > > > + *      based on affinity masks
> > > > + * @size: Number of objects to be reverse-mapped
> > > > + * @used: Number of objects added
> > > > + * @obj: Array of object pointers
> > > > + */
> > > > +struct cpu_rmap {
> > > > +	struct {
> > > > +		u16     index;
> > > > +		u16     dist;
> > > > +	} near[NR_CPUS];
> > >=20
> > > This [NR_CPUS] is highly suspect.
> > >=20
> > > Are you sure you cant use a per_cpu allocation here ?
> >=20
> > I think that would be a waste of space in shared caches, as this is
> > read-mostly.
>=20
> This is slow path, unless I dont understood the intent.

get_rps_cpu() will need to read from an arbitrary entry in cpu_rmap (no=
t
the current CPU's entry) for each new flow and for each flow that went
idle for a while.  That's not fast path but it is part of the data path=
,
not the control path.

> Cache lines dont matter. I was not concerned about speed but memory
> needs.
>=20
> NR_CPUS can be 4096 on some distros, that means a 32Kbyte allocation.
>=20
> Really, you'll have to have very strong arguments to introduce an
> [NR_CPUS] array in the kernel today.

I could replace this with a pointer to an array of size
num_possible_cpus().  But I think per_cpu is wrong here.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
