From: Fenghua Yu <fenghua.yu@intel.com>
Subject: Re: [PATCH 1/3] Kernel interfaces for multiqueue aware socket
Date: Wed, 15 Dec 2010 17:14:25 -0800
Message-ID: <20101216011425.GA17446@linux-os.sc.intel.com>
References: <cover.1292405004.git.fenghua.yu@intel.com> <46a08278c2ba21737528eb4b77391a7e8bc88000.1292405004.git.fenghua.yu@intel.com> <1292446118.2603.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yu, Fenghua" <fenghua.yu@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"Tang, Xinan" <xinan.tang@intel.com>,
	Junchang Wang <junchangwang@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36708 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752641Ab0LPBO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 20:14:26 -0500
Content-Disposition: inline
In-Reply-To: <1292446118.2603.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 15, 2010 at 12:48:38PM -0800, Eric Dumazet wrote:
> Le mercredi 15 d=E9cembre 2010 =E0 12:02 -0800, Fenghua Yu a =E9crit =
:
> > From: Fenghua Yu <fenghua.yu@intel.com>
> >=20
> > Multiqueue and multicore provide packet parallel processing methodo=
logy.
> > Current kernel and network drivers place one queue on one core. But=
 the higher
> > level socket doesn't know multiqueue. Current socket only can recei=
ve or send
> > packets through one network interfaces. In some cases e.g. multi bp=
f filter
> > tcpdump and snort, a lot of contentions come from socket operations=
 like ring
> > buffer. Even if the application itself has been fully parallelized =
and run on
> > multi-core systems and NIC handlex tx/rx in multiqueue in parallel,=
 network layer
> > and NIC device driver assemble packets to a single, serialized queu=
e. Thus the
> > application cannot actually run in parallel in high speed.
> >=20
> > To break the serialized packets assembling bottleneck in kernel, on=
e way is to
> > allow socket to know multiqueue associated with a NIC interface. So=
 each socket
> > can handle tx/rx in one queue in parallel.
> >=20
> > Kernel provides several interfaces by which sockets can be bound to=
 rx/tx queues.
> > User applications can configure socket by providing several sockets=
 that each
> > bound to a single queue, applications can get data from kernel in p=
arallel. After
> > that, competitions mentioned above can be removed.
> >=20
> > With this patch, the user-space receiving speed on a Intel SR1690 s=
erver with
> > a single L5640 6-core processor and a single ixgbe-based NIC goes f=
rom 0.73Mpps
> > to 4.20Mpps, nearly a linear speedup. A Intel SR1625 server two E55=
30 4-core
> > processors and a single ixgbe-based NIC goes from 0.80Mpps to 4.6Mp=
ps. We noticed
> > the performance penalty comes from NUMA memory allocation.
> >=20
>=20
> ??? please elaborate on these NUMA memory allocations. This should be=
 OK
> after commit 564824b0c52c34692d (net: allocate skbs on local node)
>=20
> > This patch set provides kernel ioctl interfaces for user space. Use=
r space can
> > either directly call the interfaces or libpcap interfaces can be fu=
rther provided
> > on the top of the kernel ioctl interfaces.
>=20
> So, say we have 8 queues, you want libpcap opens 8 sockets, and bind
> them to each queue. Add a bpf filter to each one of them. This seems =
not
> generic way, because it wont work for an UDP socket for example.

This only works for AF_PACKET like this patch set shows.

> And you already can do this using SKF_AD_QUEUE (added in commit
> d19742fb)

SKF_AD_QUEUE doesn't know number of rx queues. Thus user application ca=
n't
specify right SKF_AD_QUEUE.

SKF_AD_QUEUE only works for rx. There is no queue bound interfaces for =
tx.

I can change the patch set to use SKF_AD_QUEUE by removing the set rx q=
ueue
interface and still keep interfaces of
#define SIOGNUMRXQUEUE 0x8939  /* Get number of rx queues. */
#define SIOGNUMTXQUEUE 0x893A  /* Get number of tx queues. */
#define SIOSTXQUEUEMAPPING     0x893C  /* Set tx queue mapping. */
#define SIOGRXQUEUEMAPPING     0x893D  /* Get rx queue mapping. */
#define SIOGTXQUEUEMAPPING     0x893E  /* Get tx queue mapping. */

>=20
> Also your AF_PACKET patch only address mmaped sockets.
>=20
The new patch set will use SKF_AD_QUEUE for rx. So it won't be limited =
to mmaped
sockets.

