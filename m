From: Roland Dreier <roland@kernel.org>
Subject: Re: [PATCH] mlx4: Use GFP_NOFS calls during the ipoib TX path when
 creating the QP
Date: Wed, 5 Mar 2014 11:25:34 -0800
Message-ID: <CAG4TOxMw4siOqtjXrgUDaw8yWqYgSG4d8PqGuJ62AZBrC2O2AA@mail.gmail.com>
References: <CAJZOPZKLcFC5Wqv7VS7AyovaeHw3PYSWEz9t9sZ4AMhG+dS1+A@mail.gmail.com>
 <alpine.LNX.2.00.1402271042240.21399@pobox.suse.cz> <530F0C4F.9030200@mellanox.com>
 <alpine.LNX.2.00.1402271123410.21399@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1402271123410.21399@pobox.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 27, 2014 at 2:42 AM, Jiri Kosina <jkosina@suse.cz> wrote:
> Whatever suits you best. To sum it up:
>
> - mlx4 is confirmed to have this problem, and we know how that problem
>   happens -- see the paragraph in the changelog explaining the dependency
>   between memory reclaim and allocation of TX ring
>
> - we have a work around which requires human interaction in order
>   to provide the information whether GFP_NOFS should be used or not
>
> - I can very well understand why Mellanox would see that as a hack, but if
>   more comprehensive fix is necessary, I'd expect those who understand
>   the code the best to come up with a solution/proposal. I'd assume that
>   you don't  want to keep the code with known and easily triggerable
>   deadlock out there unfixed.
>
> - where I see the potential for layering violation in any 'general'
>   solution is that it's the filesystem that has to be "talking" to the
>   underlying netdevice, i.e. you'll have to make filesystem
>   netdevice-aware, right?

It's quite clear that this is a general problem with IPoIB connected
mode on any IB device.  In connected mode, a packet send can trigger
establishing a new connection, which will allocate a new QP, which in
particular will allocate memory for the QP in the low-level IB device
driver.  Currently I'm positive that every driver will do GFP_KERNEL
allocations when allocating a QP (ehca does both a GFP_KERNEL
kmem_cache allocation and vmalloc in internal_create_qp(), mlx5 and
mthca are similar to mlx4 and qib does vmalloc() in qib_create_qp()).
So this patch needs to be extended to the other 4 IB device drivers in
the tree.

Also, I don't think GFP_NOFS is enough -- it seems we need GFP_NOIO,
since we could be swapping to a block device over iSCSI over IPoIB-CM,
so even non-FS stuff could deadlock.

I don't think it makes any sense to have a "do_not_deadlock" module
parameter, especially one that defaults to "false."  If this is the
right thing to do, then we should just unconditionally do it.

It does seem that only using GFP_NOIO when we really need to would be
a very difficult problem--how can we carry information about whether a
particular packet is involved in freeing memory through all the layers
of, say, NFS, TCP, IPSEC, bonding, &c?
