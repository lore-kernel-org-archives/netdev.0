From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Thu, 20 Apr 2006 17:27:42 -0700 (PDT)
Message-ID: <20060420.172742.132879746.davem@davemloft.net>
References: <Pine.LNX.4.44.0604201329300.22544-100000@isotope.jf.intel.com>
	<20060420213305.GK26746@pb15.lixom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew.grover@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:42216
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932177AbWDUA1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 20:27:45 -0400
To: olof@lixom.net
In-Reply-To: <20060420213305.GK26746@pb15.lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olof Johansson <olof@lixom.net>
Date: Thu, 20 Apr 2006 16:33:05 -0500

> From the wiki:
> 
> >    3. Data copied by I/OAT is not cached
> 
> This is a I/OAT device limitation and not a global statement of the
> DMA infrastructure. Other platforms might be able to prime caches
> with the DMA traffic. Hint flags should be added on either the channel
> allocation calls, or per-operation calls, depending on where it makes
> sense driver/client wise.

This sidesteps the whole question of _which_ cache to warm.  And if
you choose wrongly, then what?

Besides the control overhead of the DMA engines, the biggest thing
lost in my opinion is the perfect cache warming that a cpu based copy
does from the kernel socket buffer into userspace.

The first thing an application is going to do is touch that data.  So
I think it's very important to prewarm the caches and the only
straightforward way I know of to always warm up the correct cpu's
caches is copy_to_user().

Unfortunately, many benchmarks just do raw bandwidth tests sending to
a receiver that just doesn't even look at the data.  They just return
from recvmsg() and loop back into it.  This is not what applications
using networking actually do, so it's important to make sure we look
intelligently at any benchmarks done and do not fall into the trap of
saying "even without cache warming it made things faster" when in fact
the tested receiver did not touch the data at all so was a false test.
