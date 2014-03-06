From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH] mlx4: Use GFP_NOFS calls during the ipoib TX path when
 creating the QP
Date: Thu, 6 Mar 2014 15:31:07 +0200
Message-ID: <5318789B.1040402@mellanox.com>
References: <alpine.LNX.2.00.1402211450410.1192@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland@kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Sagi Grimberg <sagig@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1402211450410.1192@pobox.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21/02/2014 23:53, Jiri Kosina wrote:
> This was originally a patch from Matthew Finlay<matt@mellanox.com>  that
> addressed a problem whereby NFS writes would enter uninterruptible sleep
> forever.  The issue happened when using NFS over IPoIB. This is not a
> recommended configuration as RDMA is preferred but it is still a valid
> configuration and is important to have in situations where the NFS server
> does not support RDMA. The problem encountered was described as follows:
>
> 	It's not memory reclamation that is the problem as such. There is
> 	an indirect dependency between network filesystems writing back
> 	pages and ipoib_cm_tx_init() due to how a kworker is used. Page
> 	reclaim cannot make forward progress until ipoib_cm_tx_init()
> 	succeeds and it is stuck in page reclaim itself waiting for network
> 	transmission. Ordinarily this sitaution may be avoided by having
> 	the caller use GFP_NOFS but ipoib_cm_tx_init() does not have that information.
>

Hi Jiri,

Reading again (*) the problem description, the team here would be happy 
to clarify with you some details (possibly
few MM newbie questions, but it will help us):

1. just to make sure, the problem happen on the NFS client, not the NFS 
server, right? so writing-back means client
writing over the NFS mount --> network

2. you wrote "due to how a kworker is used", can you clarify if/why 
things go wrong b/c of the kworker usage, or this is matter of phrasing?

in earlier post over this thread you wrote "There was a problem with 
swapping over NFS, as writeback was deadlocked with memory reclaim 
(memory needs to be allocated so that > swap could be accessed to 
reclaim memory). That's fixed by allocating the buffers from PF_MEMALLOC 
reserve, introduced by Mel's and Peter's patchset back in 3.9 or so. Oh, 
and the same has been done for swapping over NBD, btw", in that respect:

3. you mentioned that the memory allocations in ipoib_cm_tx_init() and 
ib_create_qp() --> mlx4 driver requires
page reclaim and waits for network transmission, so this client node put 
their swap over that NFS partition?

4. Can you shed more light, why the problem hits also for kmalloc based 
allocations and not only for vmalloc
based allocation e.g not only b/c of the vzalloc call in 
ipoib_cm_tx_init but rather also b/c of misc kmalloc calls within
the HW (here mlx4) driver?

thanks,

Or.

(*) and sorry for my stupid question from yesterday, sometimes it's bad 
idea to ask questions on mailing lists when you are very tired
