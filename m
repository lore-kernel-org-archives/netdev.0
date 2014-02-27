From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] mlx4: Use GFP_NOFS calls during the ipoib TX path when
 creating the QP
Date: Thu, 27 Feb 2014 11:42:30 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1402271123410.21399@pobox.suse.cz>
References: <CAJZOPZKLcFC5Wqv7VS7AyovaeHw3PYSWEz9t9sZ4AMhG+dS1+A@mail.gmail.com> <alpine.LNX.2.00.1402271042240.21399@pobox.suse.cz> <530F0C4F.9030200@mellanox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Roland Dreier <roland@kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <530F0C4F.9030200@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Feb 2014, Or Gerlitz wrote:

> ipoib is coded over the verbs API (include/rdma/ib_verbs.h)  --- so tracking
> the path from ipoib through the verbs api into mlx4 should be similar exercise
> as doing so for mlx5, but let's 1st treat the higher level elements involved
> with this patch.
> 
> Can you shed some light why the problem happens only for NFS, and not for
> example with other IP/TCP storage protocols?
>
> For example, do you expect it to happen with iSCSI/TCP too? the Linux 
> iSCSI initiator 1st open a TCP socket from user space to the target, 
> next they do login exchange over this socket and later provide the 
> socket to the kernel iscsi code to use as the back-end of a SCSI block 
> device registered with the SCSI midlayer

Frankly, no idea. There was a problem with swapping over NFS, as writeback 
was deadlocked with memory reclaim (memory needs to be allocated so that 
swap could be accessed to reclaim memory). That's fixed by allocating the 
buffers from PF_MEMALLOC reserve, introduced by Mel's and Peter's patchset 
back in 3.9 or so. Oh, and the same has been done for swapping over NBD, 
btw. Maybe iSCSI needs similar treatment, maybe it has it already, I 
haven't checked. We haven't seen a bugreport for that though.

> > I don't think we have, and it indeed should be rather easy to add. The 
> > more challenging part of the problem is where (and based on which 
> > data) the flag would actually be set up on the netdevice so that it's 
> > not horrible layering violation.
> 
> I assume that in the same manner netdevices advertize features to the 
> networking core, the core can provide them operating directives after 
> they register themselves.

Whatever suits you best. To sum it up:

- mlx4 is confirmed to have this problem, and we know how that problem 
  happens -- see the paragraph in the changelog explaining the dependency 
  between memory reclaim and allocation of TX ring

- we have a work around which requires human interaction in order 
  to provide the information whether GFP_NOFS should be used or not

- I can very well understand why Mellanox would see that as a hack, but if 
  more comprehensive fix is necessary, I'd expect those who understand 
  the code the best to come up with a solution/proposal. I'd assume that 
  you don't  want to keep the code with known and easily triggerable 
  deadlock out there unfixed.

- where I see the potential for layering violation in any 'general' 
  solution is that it's the filesystem that has to be "talking" to the 
  underlying netdevice, i.e. you'll have to make filesystem 
  netdevice-aware, right?

Thanks,

-- 
Jiri Kosina
SUSE Labs
