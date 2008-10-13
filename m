From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] negative dev use in /proc/net/rose_neigh
Date: Mon, 13 Oct 2008 00:30:09 -0700 (PDT)
Message-ID: <20081013.003009.241543234.davem@davemloft.net>
References: <200809282156.39466.bpidoux@free.fr>
	<20080930.073213.60770455.davem@davemloft.net>
	<48E29DD7.803@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bpidoux@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42285
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753202AbYJMHad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 03:30:33 -0400
In-Reply-To: <48E29DD7.803@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernard Pidoux <bpidoux@free.fr>
Date: Tue, 30 Sep 2008 23:44:55 +0200

> I suspect that the bug was unravelled when we added more than one
> neighbour per route. The protocole accepts three, but this was not
> much used during the early days since the density of radio stations
> on the network was not big (only one node station per destination
> address usually). The network is now denser with Internet links.
>
> However, I don't understand why the test
> 
> if (rose->neighbour == neigh)
> 
> does not work, for
> rose->neighbour = NULL;
> should prevent next comparison to be valid and thus instruction
> rose->neighbour->use--; not executed.
>
> I have seen that a problem with sk_for_each() macro was identified a
> while ago into ax25 code. The problem here could be similar ?

I took a look at this some more.

That neighbour case loop you mention does set ->neighbour to NULL.

But other paths do not.  Just look for all of the pieces of code
that do "rose->neighbour->use--;" and you'll find a few that do not
NULL it out.

One such example is rose_kill_by_device().

That would cause a problem because, while rose_disconnect() marks
the socket DEAD, it doesn't actually remove it from "rose_list".
That happens later when the user actually closes the socket or
some other similar event occurs.

Therefore if rose_kill_by_neigh() happens next, the ->neighbour could
match and we'll decrement again.

But I have no idea how safe it is to NULL out this ->neighbour
unconditionally.  Lots of code seems to deref the thing unconditionally.
For example the ROSE_STATE_2 handling in rose_release().

I guess since rose_disconnect() sets sk->sk_state to TCP_CLOSE, we'll
be OK here.

Can you try this patch?

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index a7f1ce1..41dd630 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -197,6 +197,7 @@ static void rose_kill_by_device(struct net_device *dev)
 		if (rose->device == dev) {
 			rose_disconnect(s, ENETUNREACH, ROSE_OUT_OF_ORDER, 0);
 			rose->neighbour->use--;
+			rose->neighbour = NULL;
 			rose->device = NULL;
 		}
 	}
@@ -625,6 +626,7 @@ static int rose_release(struct socket *sock)
 
 	case ROSE_STATE_2:
 		rose->neighbour->use--;
+		rose->neighbour = NULL;
 		release_sock(sk);
 		rose_disconnect(sk, 0, -1, -1);
 		lock_sock(sk);
