From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Thu, 20 Apr 2006 20:42:00 -0700 (PDT)
Message-ID: <20060420.204200.103377406.davem@davemloft.net>
References: <20060420213305.GK26746@pb15.lixom.net>
	<20060420.172742.132879746.davem@davemloft.net>
	<20060421030426.GM26746@pb15.lixom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew.grover@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:64668
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932166AbWDUDmC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 23:42:02 -0400
To: olof@lixom.net
In-Reply-To: <20060421030426.GM26746@pb15.lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olof Johansson <olof@lixom.net>
Date: Thu, 20 Apr 2006 22:04:26 -0500

> On Thu, Apr 20, 2006 at 05:27:42PM -0700, David S. Miller wrote:
> > Besides the control overhead of the DMA engines, the biggest thing
> > lost in my opinion is the perfect cache warming that a cpu based copy
> > does from the kernel socket buffer into userspace.
> 
> It's definitely the easiest way to always make sure the right caches
> are warm for the app, that I agree with.
> 
> But, when warming those caches by copying, the data is pulled in through
> a potentially cold cache in the first place. So the cache misses are
> just moved from the copy loop to userspace with dma offload. Or am I
> missing something?

Yes, and it means that the memory bandwidth costs are equivalent
between I/O AT and cpu copy.

In the cpu copy case you eat the read cache miss, but on the write
side you'll prewarm the cache properly.  In the I/O AT case you
eat the same read cost, but the cache will not be prewarmed, so you'll
eat the read cache miss in the application.  It's moving the same
exact cost from one place to another.

The time it takes to get the app to make forward progress (meaning
returned from the recvmsg() system call and back in userspace) must by
definition take at least as long with I/O AT as it does with cpu
copies.  Yet in the I/O AT case, the application must wait that long
and also then take in the delays of the cache misses when it tries to
read the data that the I/O AT engine copied.  Instead of eating the
cache miss cost in the kernel, we eat it in the app because in the I/O
AT case the cpu won't have the user data fresh and loaded into the cpu
cache.

And I say I/O AT must take "at least as long" as cpu copies because
the same memory copy cost is there, and on top of that I/O AT has to
program the DMA controller and touch a _lot_ of other state to get
things going and then wake the task up.  We're talking non-trivial
overheads like grabbing the page mappings out of the page tables using
get_user_pages().  Evgivny has posted some very nice performance graphs
showing how poorly that function scales.

This is basically why none of the performance gains add up to me.  I
am thus very concerned that the current non-cache-warming
implmentation may fall flat performance wise.
