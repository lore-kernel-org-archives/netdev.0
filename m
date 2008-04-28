From: David Miller <davem@davemloft.net>
Subject: Re: useless tcp maybe-bug report
Date: Mon, 28 Apr 2008 02:01:23 -0700 (PDT)
Message-ID: <20080428.020123.07945936.davem@davemloft.net>
References: <20080428014049.eee1a533.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52706
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752350AbYD1JBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 05:01:23 -0400
In-Reply-To: <20080428014049.eee1a533.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 28 Apr 2008 01:40:49 -0700

> I just fired up latest mainline plus the 300-odd patches which I'm about to
> send Linuswards on a mac g5.
> 
> I use that g5 as a distcc server.  I'm now seeing this:
> 
> distcc[13554] (dcc_writex) ERROR: failed to write: Connection reset by peer
> distcc[13554] (dcc_writex) ERROR: failed to write: Broken pipe
> distcc[13554] Warning: failed to distribute net/atm/clip.mod.c to g5/32, running locally instead
> 
> about once per allmodconfig build.  The client kernel is 2.6.24.3-34.fc8
> and has never changed.
> 
> Thing is, these messages are unusual.  I suspect that Something Is Up with
> that g5, perhaps its networking.
> 
> There are no signs of problems in the g5's dmesg.

I bet your fc8 kernel has the bug that needs this patch below.

The bug causes timewait sockets to reset erroneously and matches your
symptoms precisely.

commit 7951f0b03a63d657c72c7d54d306ef3357e7e604
Author: Daniel Lezcano <dlezcano@fr.ibm.com>
Date:   Thu Apr 10 20:53:10 2008 -0700

    [NETNS][IPV6] tcp - assign the netns for timewait sockets
    
    Copy the network namespace from the socket to the timewait socket.
    
    Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
    Acked-by: Mark Lord <mlord@pobox.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 876169f..717c411 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -124,6 +124,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 		tw->tw_hash	    = sk->sk_hash;
 		tw->tw_ipv6only	    = 0;
 		tw->tw_prot	    = sk->sk_prot_creator;
+		tw->tw_net          = sk->sk_net;
 		atomic_set(&tw->tw_refcnt, 1);
 		inet_twsk_dead_node_init(tw);
 		__module_get(tw->tw_prot->owner);
