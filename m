From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH] mlx4: Use GFP_NOFS calls during the ipoib TX path when
 creating the QP
Date: Tue, 11 Mar 2014 15:53:20 +0200
Message-ID: <531F1550.3080401@mellanox.com>
References: <CAJZOPZKLcFC5Wqv7VS7AyovaeHw3PYSWEz9t9sZ4AMhG+dS1+A@mail.gmail.com> <alpine.LNX.2.00.1402271042240.21399@pobox.suse.cz> <530F0C4F.9030200@mellanox.com> <alpine.LNX.2.00.1402271123410.21399@pobox.suse.cz> <CAG4TOxMw4siOqtjXrgUDaw8yWqYgSG4d8PqGuJ62AZBrC2O2AA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sagi Grimberg <sagig@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Roland Dreier <roland@kernel.org>, Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG4TOxMw4siOqtjXrgUDaw8yWqYgSG4d8PqGuJ62AZBrC2O2AA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/03/2014 21:25, Roland Dreier wrote:
> It's quite clear that this is a general problem with IPoIB connected
> mode on any IB device.  In connected mode, a packet send can trigger
> establishing a new connection, which will allocate a new QP, which in
> particular will allocate memory for the QP in the low-level IB device
> driver.  Currently I'm positive that every driver will do GFP_KERNEL
> allocations when allocating a QP (ehca does both a GFP_KERNEL
> kmem_cache allocation and vmalloc in internal_create_qp(), mlx5 and
> mthca are similar to mlx4 and qib does vmalloc() in qib_create_qp()).
> So this patch needs to be extended to the other 4 IB device drivers in
> the tree.
>
> Also, I don't think GFP_NOFS is enough -- it seems we need GFP_NOIO,
> since we could be swapping to a block device over iSCSI over IPoIB-CM,
> so even non-FS stuff could deadlock.
>
> I don't think it makes any sense to have a "do_not_deadlock" module
> parameter, especially one that defaults to "false."  If this is the
> right thing to do, then we should just unconditionally do it.
>
> It does seem that only using GFP_NOIO when we really need to would be
> a very difficult problem--how can we carry information about whether a
> particular packet is involved in freeing memory through all the layers
> of, say, NFS, TCP, IPSEC, bonding, &c?

Agree with all the above... next,

If we don't have away to nicely overcome the layer violations here, 
let's change IPoIB so they always ask the
IB driver to allocate QPs used for Connected Mode in a GFP_NOIO manner, 
to be practical I suggest the following:

1. Add new QP creation flag IB_QP_CREATE_USE_GFP to the existing 
creation flags of struct ib_qp_init_attr
and a new "gfp_t gfp" field to that structure too

2. in the IPoIB CM code, do the vzalloc allocation for new connection in 
GFP_NOIO manner and issue
the call to create QP with setting the IB_QP_CREATE_USE_GFP flag and 
GFO_NOIO to the gfp field

3. If the QP creation fails, with -EINVAL, issue a warning and retry the 
QP creation attempt without the GFP setting

4. implement in the mlx4 driver the support for GFP directives on QP 
creation

5. for the rest of the IB drivers, return -EINVAL if 
IB_QP_CREATE_USE_GFP is set

This will allow to provide working solution for mlx4 users and gradually 
add support for the rest of the IB drivers.

as for proper patch planning

patch #1 / items 1 and 5
patch #2 / item 4
patch #3 / item 3

Re item 5 -- I made a check and the ehca, ipath and mthca driver already 
return -EINVAL if provided with any creation flag, so you only need to 
patch the qib driver in qib_create_qp() to do that as well which is trivial.

As for the rest of the code, you practically have it all by now, just 
need to port the mlx4 changes you did to the suggested framework, remove 
the module param (which you don't like either) and add the new gfp_t 
field to ib_qp_init_attr

So sounds like a plan that makes sense?

Or.
