From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Saner thash_entries default with much memory
Date: Tue, 30 Oct 2007 00:57:58 -0700 (PDT)
Message-ID: <20071030.005758.184980120.davem@davemloft.net>
References: <200710261721.32019.jdelvare@suse.de>
	<20071026153416.GA23491@bingen.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdelvare@suse.de, netdev@vger.kernel.org
To: ak@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40387
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751905AbXJ3H6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 03:58:20 -0400
In-Reply-To: <20071026153416.GA23491@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Fri, 26 Oct 2007 17:34:17 +0200

> On Fri, Oct 26, 2007 at 05:21:31PM +0200, Jean Delvare wrote:
> > I propose 2 millions of entries as the arbitrary high limit. This
> 
> It's probably still far too large.

I agree.  Perhaps a better number is something on the order of
(512 * 1024) so I think I'll check in a variant of Jean's patch
with just the limit decreased like that.

Using just some back of the envelope calculations, on UP 64-bit
systems each socket uses about 2424 bytes minimum of memory (this is
the sum of tcp_sock, inode, dentry, socket, and file on sparc64 UP).
This is an underestimate because it does not even consider things like
allocator overhead.

Next, machines that service that many sockets typically have them
mostly with full transmit queues talking to a very slow receiver at
the other end.  So let's estimate that on average each socket consumes
about 64K of retransmit queue data.

I think this is an extremely conservative estimate beause it doesn't
even consider overhead coming from struct sk_buff and related state.

So for (512 * 1024) of established sockets we consume roughly 35GB of
memory, this is '((2424 + (64 * 1024)) * (512 * 1024))'.

So to me (512 * 1024) is a very reasonable limit and (with lockdep
and spinlock debugging disabled) this makes the EHASH table consume
8MB on UP 64-bit and ~12MB on SMP 64-bit systems.

Thanks.
