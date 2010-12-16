From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/3] Kernel interfaces for multiqueue aware socket
Date: Wed, 15 Dec 2010 17:23:58 -0800
Message-ID: <20101215172358.64a611c8@nehalam>
References: <cover.1292405004.git.fenghua.yu@intel.com>
	<46a08278c2ba21737528eb4b77391a7e8bc88000.1292405004.git.fenghua.yu@intel.com>
	<1292446118.2603.11.camel@edumazet-laptop>
	<20101216011425.GA17446@linux-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"Tang, Xinan" <xinan.tang@intel.com>,
	Junchang Wang <junchangwang@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Fenghua Yu <fenghua.yu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101216011425.GA17446@linux-os.sc.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 15 Dec 2010 17:14:25 -0800
=46enghua Yu <fenghua.yu@intel.com> wrote:

> On Wed, Dec 15, 2010 at 12:48:38PM -0800, Eric Dumazet wrote:
> > Le mercredi 15 d=E9cembre 2010 =E0 12:02 -0800, Fenghua Yu a =E9cri=
t :
> > > From: Fenghua Yu <fenghua.yu@intel.com>
> > >=20
> > > Multiqueue and multicore provide packet parallel processing metho=
dology.
> > > Current kernel and network drivers place one queue on one core. B=
ut the higher
> > > level socket doesn't know multiqueue. Current socket only can rec=
eive or send
> > > packets through one network interfaces. In some cases e.g. multi =
bpf filter
> > > tcpdump and snort, a lot of contentions come from socket operatio=
ns like ring
> > > buffer. Even if the application itself has been fully parallelize=
d and run on
> > > multi-core systems and NIC handlex tx/rx in multiqueue in paralle=
l, network layer
> > > and NIC device driver assemble packets to a single, serialized qu=
eue. Thus the
> > > application cannot actually run in parallel in high speed.
> > >=20
> > > To break the serialized packets assembling bottleneck in kernel, =
one way is to
> > > allow socket to know multiqueue associated with a NIC interface. =
So each socket
> > > can handle tx/rx in one queue in parallel.
> > >=20
> > > Kernel provides several interfaces by which sockets can be bound =
to rx/tx queues.
> > > User applications can configure socket by providing several socke=
ts that each
> > > bound to a single queue, applications can get data from kernel in=
 parallel. After
> > > that, competitions mentioned above can be removed.
> > >=20
> > > With this patch, the user-space receiving speed on a Intel SR1690=
 server with
> > > a single L5640 6-core processor and a single ixgbe-based NIC goes=
 from 0.73Mpps
> > > to 4.20Mpps, nearly a linear speedup. A Intel SR1625 server two E=
5530 4-core
> > > processors and a single ixgbe-based NIC goes from 0.80Mpps to 4.6=
Mpps. We noticed
> > > the performance penalty comes from NUMA memory allocation.
> > >=20
> >=20
> > ??? please elaborate on these NUMA memory allocations. This should =
be OK
> > after commit 564824b0c52c34692d (net: allocate skbs on local node)
> >=20
> > > This patch set provides kernel ioctl interfaces for user space. U=
ser space can
> > > either directly call the interfaces or libpcap interfaces can be =
further provided
> > > on the top of the kernel ioctl interfaces.
> >=20
> > So, say we have 8 queues, you want libpcap opens 8 sockets, and bin=
d
> > them to each queue. Add a bpf filter to each one of them. This seem=
s not
> > generic way, because it wont work for an UDP socket for example.
>=20
> This only works for AF_PACKET like this patch set shows.
>=20
> > And you already can do this using SKF_AD_QUEUE (added in commit
> > d19742fb)
>=20
> SKF_AD_QUEUE doesn't know number of rx queues. Thus user application =
can't
> specify right SKF_AD_QUEUE.
>=20
> SKF_AD_QUEUE only works for rx. There is no queue bound interfaces fo=
r tx.
>=20
> I can change the patch set to use SKF_AD_QUEUE by removing the set rx=
 queue
> interface and still keep interfaces of
> #define SIOGNUMRXQUEUE 0x8939  /* Get number of rx queues. */
> #define SIOGNUMTXQUEUE 0x893A  /* Get number of tx queues. */
> #define SIOSTXQUEUEMAPPING     0x893C  /* Set tx queue mapping. */
> #define SIOGRXQUEUEMAPPING     0x893D  /* Get rx queue mapping. */
> #define SIOGTXQUEUEMAPPING     0x893E  /* Get tx queue mapping. */
>=20
> >=20
> > Also your AF_PACKET patch only address mmaped sockets.
> >=20
> The new patch set will use SKF_AD_QUEUE for rx. So it won't be limite=
d to mmaped
> sockets.

Do we really want to expose this kind of internals to userspace?
The problem is once exposed, it becomes a kernel ABI and can not ever
change.=20
--=20
