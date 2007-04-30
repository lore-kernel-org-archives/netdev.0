From: David Miller <davem@davemloft.net>
Subject: Re: garbage of TCP sock mem in sockstat?
Date: Mon, 30 Apr 2007 00:38:42 -0700 (PDT)
Message-ID: <20070430.003842.26533021.davem@davemloft.net>
References: <46185FFC.8020104@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kumiko@cs.columbia.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37374
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423114AbXD3Hip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 03:38:45 -0400
In-Reply-To: <46185FFC.8020104@cs.columbia.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kumiko Ono <kumiko@cs.columbia.edu>
Date: Sat, 07 Apr 2007 23:22:36 -0400

> Could anybody tell me why the garbage in the memory for TCP socket 
> buffers remains? Is this a problem on deallocation of socket buffers, or 
> just on sockstat?  Or I'm missing something?

It is not garbage, it is simply holding on to the receive buffer
allocation in anticipation of future packet receives for that
socket.

The values in the global pool, which you saw via sockstat, are
allocated from on a per-socket basis into a per-socket allocation
quota.  Packets attached to that socket have to take from this
quota.

The idea is that once you get a per-socket allocation, you use
that until you need more.  When you release, you keep the
per-socket allocation unless we are under global memory
pressure.

This prevents having to go to allocate from the global pool
too often which is very expensive especially on SMP since
it is a shared datastructure and requires locking.
