From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmalloc: respect the GFP_NOIO and GFP_NOFS flags
Date: Fri, 30 Jun 2017 22:41:00 +0200
Message-ID: <20170630204059.GA17255@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1706292221250.21823@file01.intranet.prod.int.rdu2.redhat.com>
 <20170630081245.GA22917@dhcp22.suse.cz>
 <alpine.LRH.2.02.1706301410160.8272@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Vlastimil Babka <vbabka@suse.cz>,
        Andreas Dilger <adilger@dilger.ca>,
        John Hubbard <jhubbard@nvidia.com>,
        David Miller <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        netdev@vger.kernel.org
To: Mikulas Patocka <mpatocka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1706301410160.8272@file01.intranet.prod.int.rdu2.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri 30-06-17 14:11:57, Mikulas Patocka wrote:
> 
> 
> On Fri, 30 Jun 2017, Michal Hocko wrote:
> 
> > On Thu 29-06-17 22:25:09, Mikulas Patocka wrote:
> > > The __vmalloc function has a parameter gfp_mask with the allocation flags,
> > > however it doesn't fully respect the GFP_NOIO and GFP_NOFS flags. The
> > > pages are allocated with the specified gfp flags, but the pagetables are
> > > always allocated with GFP_KERNEL. This allocation can cause unexpected
> > > recursion into the filesystem or I/O subsystem.
> > > 
> > > It is not practical to extend page table allocation routines with gfp
> > > flags because it would require modification of architecture-specific code
> > > in all architecturs. However, the process can temporarily request that all
> > > allocations are done with GFP_NOFS or GFP_NOIO with with the functions
> > > memalloc_nofs_save and memalloc_noio_save.
> > > 
> > > This patch makes the vmalloc code use memalloc_nofs_save or
> > > memalloc_noio_save if the supplied gfp flags do not contain __GFP_FS or
> > > __GFP_IO. It fixes some possible deadlocks in drivers/mtd/ubi/io.c,
> > > fs/gfs2/, fs/btrfs/free-space-tree.c, fs/ubifs/,
> > > fs/nfs/blocklayout/extent_tree.c where __vmalloc is used with the GFP_NOFS
> > > flag.
> > 
> > I strongly believe this is a step in the _wrong_ direction. Why? Because
> 
> What do you think __vmalloc with GFP_NOIO should do? Print a warning? 
> Silently ignore the GFP_NOIO flag?

I think noio users are not that much different from nofs users. Simply
use the scope API at the place where the scope starts and document why
it is needed. vmalloc calls do not have to be any special then and they
do not even have to think about proper gfp flags and they can use
whatever is the default.
-- 
Michal Hocko
SUSE Labs
