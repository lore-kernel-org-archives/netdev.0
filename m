From: Christoph Lameter <cl@linux.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
Date: Tue, 13 Dec 2016 10:36:55 -0600 (CST)
Message-ID: <alpine.DEB.2.20.1612131030310.32350@east.gentwo.org>
References: <20161205153132.283fcb0e@redhat.com> <20161212083812.GA19987@rapoport-lnx> <20161212104042.0a011212@redhat.com> <20161212141433.GB19987@rapoport-lnx> <584EB8DF.8000308@gmail.com> <20161212181344.3ddfa9c3@redhat.com> <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
 <20161213171028.24dbf519@redhat.com>
Content-Type: multipart/mixed; BOUNDARY="8323329-637687599-1481647015=:32350"
Cc: John Fastabend <john.fastabend@gmail.com>,
    Mike Rapoport <rppt@linux.vnet.ibm.com>,
    "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
    linux-mm <linux-mm@kvack.org>,
    Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
    =?ISO-8859-15?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>,
    "Karlsson, Magnus" <magnus.karlsson@intel.com>,
    Alexander Duyck <alexander.duyck@gmail.com>,
    Mel Gorman <mgorman@techsingularity.net>,
    Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>,
    Tariq Toukan <tariqt@mellanox.com>, Saeed Mahameed <saeedm@mellanox.com>,
    Jesse Brandeburg <jesse.brandeburg@intel.com>,
    Kalman Meth <METH@il.ibm.com>, Vladislav Yasevich <vyasevich@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20161213171028.24dbf519@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-637687599-1481647015=:32350
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Tue, 13 Dec 2016, Jesper Dangaard Brouer wrote:

> This is the early demux problem.  With the push-mode of registering
> memory, you need hardware steering support, for zero-copy support, as
> the software step happens after DMA engine have written into the memory.

Right. But we could fall back to software. Transfer to a kernel buffer and
then move stuff over. Not much of an improvment but it will make things
work.

> > The discussion here is a bit amusing since these issues have been
> > resolved a long time ago with the design of the RDMA subsystem. Zero
> > copy is already in wide use. Memory registration is used to pin down
> > memory areas. Work requests can be filed with the RDMA subsystem that
> > then send and receive packets from the registered memory regions.
> > This is not strictly remote memory access but this is a basic mode of
> > operations supported  by the RDMA subsystem. The mlx5 driver quoted
> > here supports all of that.
>
> I hear what you are saying.  I will look into a push-model, as it might
> be a better solution.
>  I will read up on RDMA + verbs and learn more about their API model.  I
> even plan to write a small sample program to get a feeling for the API,
> and maybe we can use that as a baseline for the performance target we
> can obtain on the same HW. (Thanks to Björn for already giving me some
> pointer here)

Great.

> > What is bad about RDMA is that it is a separate kernel subsystem.
> > What I would like to see is a deeper integration with the network
> > stack so that memory regions can be registred with a network socket
> > and work requests then can be submitted and processed that directly
> > read and write in these regions. The network stack should provide the
> > services that the hardware of the NIC does not suppport as usual.
>
> Interesting.  So you even imagine sockets registering memory regions
> with the NIC.  If we had a proper NIC HW filter API across the drivers,
> to register the steering rule (like ibv_create_flow), this would be
> doable, but we don't (DPDK actually have an interesting proposal[1])

Well doing this would mean adding some features and that also would at
best allow general support for zero copy direct to user space with a
fallback to software if the hardware is missing some feature.

> > The RX/TX ring in user space should be an additional mode of
> > operation of the socket layer. Once that is in place the "Remote
> > memory acces" can be trivially implemented on top of that and the
> > ugly RDMA sidecar subsystem can go away.
>
> I cannot follow that 100%, but I guess you are saying we also need a
> more efficient mode of handing over pages/packet to userspace (than
> going through the normal socket API calls).

A work request contains the user space address of the data to be sent
and/or received. The address must be in a registered memory region. This
is different from copying the packet into kernel data structures.

I think this can easily be generalized. We need support for registering
memory regions, submissions of work request and the processing of
completion requets. QP (queue-pair) processing is probably the basis for
the whole scheme that is used in multiple context these days.

--8323329-637687599-1481647015=:32350--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
