From: David Miller <davem@davemloft.net>
Subject: all this business about ->sk_sleep
Date: Tue, 17 Jun 2008 02:54:46 -0700 (PDT)
Message-ID: <20080617.025446.180013373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55342
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754608AbYFQJyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 05:54:46 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B89FDC8C18D
	for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 02:54:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


So you're probably wondering why I tidied up all of those code paths
setting sk_sleep inappropriately or not using sock_graft().

If you grep the net-next-2.6 tree now there are only 6 assignments to
sk->sk_sleep:

include/net/sock.h:	sk->sk_sleep  = NULL;
include/net/sock.h:	sk->sk_sleep = &parent->wait;
net/core/sock.c:		newsk->sk_sleep	 = NULL;
net/core/sock.c:		sk->sk_sleep	=	&sock->wait;
net/core/sock.c:		sk->sk_sleep	=	NULL;
net/unix/af_unix.c:	newsk->sk_sleep		= &newu->peer_wait;

The only thing that uses something other than &sk->sk_socket->wait
for sk->sk_sleep is AF_UNIX.  So that's a useful discovery and
we may be able to get rid of sk->sk_sleep somehow.  I'll try to
launch a full investiation into how and why AF_UNIX uses a special
wait queue.

But the original impetus for this consolidation is that I might
move struct socket freeing over to RCU in order to facilitate the
removal of sk->sk_callback_lock.  And if so it's tidier if there
are only a handful of rcu_assign_pointer() calls to add.
