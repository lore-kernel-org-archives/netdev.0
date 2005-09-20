From: Dan Aloni <da-x@monatomic.org>
Subject: Re: workaround large MTU and N-order allocation failures
Date: Tue, 20 Sep 2005 17:34:26 +0300
Message-ID: <20050920143426.GB26617@localdomain>
References: <20050918143526.GA24181@localdomain> <1127111462.5272.7.camel@npiggin-nld.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932768AbVITObM@vger.kernel.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Content-Disposition: inline
In-Reply-To: <1127111462.5272.7.camel@npiggin-nld.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 19, 2005 at 04:31:02PM +1000, Nick Piggin wrote:
> On Sun, 2005-09-18 at 17:35 +0300, Dan Aloni wrote:
> > Hello,
> > 
> > Is there currently a workaround available for handling large MTU 
> > (larger than 1 page, even 2-order) in the Linux network stack?
> > 
> > The problem with large MTU is external memory fragmentation in
> > the buddy system following high workload, causing alloc_skb() to 
> > fail.
> > 
> > I'm interested in patches for both 2.4 and 2.6 kernels.
> > 
> 
> Yes there is currently a workaround. That is to keep increasing
> /proc/sys/vm/min_free_kbytes until your allocation failures stop.

We have developed a much more reliable workaround which works on both
the 2.4 and 2.6 trees. 

Our development is called 'Pre-allocated Big Buffers', basically prebb 
provides fixed-sized pools of fixed-size blocks that are allocated during
boot time using the bootmem allocator (thus are disconnected from the 
slab cache completely). block size need not to be page aligned. It is 
possible to allocate these blocks at O(1) efficiency at any context.

Each pool has a minimum and maximum object size (where allocations 
should strive to be the maximum for memory usage efficiency). Currently 
we use prebb to ensure no fragmentation and fine-tuned memory usage.

(Of course a few changes inside net/core/skbuff.c were needed for 
skb buffers to allocate from prebb instead of slab).

-- 
Dan Aloni
da-x@monatomic.org, da-x@colinux.org, da-x@gmx.net
