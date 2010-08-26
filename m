From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [ROSE] rose node number was never decreased
Date: Thu, 26 Aug 2010 16:09:57 -0700 (PDT)
Message-ID: <20100826.160957.212699485.davem@davemloft.net>
References: <4C76E765.9020201@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, bpidoux@free.fr
To: f6bvp@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50910
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753148Ab0HZXJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 19:09:41 -0400
In-Reply-To: <4C76E765.9020201@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernard F6BVP <f6bvp@free.fr>
Date: Fri, 27 Aug 2010 00:15:01 +0200

> When a ROSE node was deleted, node number was not
> decremented and addr kept going up when a new node
> was added.
> 
> /proc/net/rose_neigh
> addr  callsign  dev  count use mode restart  t0  tf digipeaters
> 00007 F5KBW-9   ax0      1   0  DTE      no   0   0
> 00006 F6BVP-11  ax0      2   0  DTE      no   0   0
> 00005 F6BVP-9   ax0      2   0  DTE      no   0   0
> 00001 RSLOOP-0  ???      0   0  DCE     yes   0   0
> 
> With this patch, rose node number is correctly decreased
> when nodes are deleted and new ones added :
> 
> /proc/net/rose_neigh
> addr  callsign  dev  count use mode restart  t0  tf digipeaters
> 00004 F5KBW-9   ax0      1   0  DTE      no   0   0
> 00003 F6BVP-11  ax0      2   0  DTE      no   0   0
> 00002 F6BVP-9   ax0      2   0  DTE      no   0   0
> 00001 RSLOOP-0  ???      0   0  DCE     yes   0   0
> 
> Signed-off-by: Bernard Pidoux <f6bvp@free.fr>

I don't see how this patch is correct.

The whole point of the rose_neigh_no seems to be to make sure
that unique numbers are given to the neighbours.

But with your patch, we can end up easily with neighbours assigned the
same number.  Consider adding 3 nodes, and let's say they get
rose_neigh_no 1, 2, and 3

A: neigh_no 1
B: neigh_no 2
C: neigh_no 3

Delete B, now rose_neigh_no with your patch applied will be '3'.
Next, add D, which will get neigh_no of '3' which is the same
as what C has.

This can't be right.

What the code wants is an allocation of unique IDs and a simple
bitmap along with find_next_zero_bit(), set_bit(), and clear_bit()
ought to do the trick.

