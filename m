From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET]: fix multicast list when cloning sockets
Date: Mon, 30 Jul 2007 19:01:44 -0700 (PDT)
Message-ID: <20070730.190144.26963470.davem@davemloft.net>
References: <20070730160448.GA4002@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, acme@ghostprotocols.net,
	netdev@vger.kernel.org
To: fleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54625
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758281AbXGaCBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 22:01:45 -0400
In-Reply-To: <20070730160448.GA4002@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Flavio Leitner <fleitner@redhat.com>
Date: Mon, 30 Jul 2007 13:04:48 -0300

> 
> The sock_copy() function uses memcpy() to clone the socket
> including the struct ip_mc_socklist *mc_list pointer.
> 
> The ip_mc_drop_socket() function is called when socket is closed
> to free these objects leaving the other sockets cloned from the
> same master socket with invalid pointers.
> 
> This patch sets mc_list of cloned socket to NULL.
> 
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>

Allowing non-datagram sockets to end up with a non-NULL inet->mc_list
in the first place is a bug.

Multicast subscriptions cannot even be used with TCP and DCCP, which
are the only two users of these connection oriented socket functions.

The first thing that TCP and DCCP do, in fact, for input packet
processing is drop the packet if it is not unicast.

Therefore the fix really is for the inet layer to reject multicast
subscription requests on sockets for which that absolutely does not
make sense.  There is no reason these functions in
inet_connection_sock.c should need to be mindful of multicast
state. :-)

