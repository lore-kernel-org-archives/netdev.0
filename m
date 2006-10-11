From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: Dropping NETIF_F_SG since no checksum feature.
Date: Wed, 11 Oct 2006 17:01:03 +0200
Message-ID: <20061011150103.GF4888@mellanox.co.il>
References: <20061011090926.GA15393@fogou.chygwyn.com>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	openib-general@openib.org, rolandd@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dev.mellanox.co.il ([194.90.237.44]:50562 "EHLO
	dev.mellanox.co.il") by vger.kernel.org with ESMTP id S965184AbWJKPCJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Oct 2006 11:02:09 -0400
To: Steven Whitehouse <steve@chygwyn.com>
Content-Disposition: inline
In-Reply-To: <20061011090926.GA15393@fogou.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Steven Whitehouse <steve@chygwyn.com>:
> > ssize_t tcp_sendpage(struct socket *sock, struct page *page, int offset,
> >                      size_t size, int flags)
> > {
> >         ssize_t res;
> >         struct sock *sk = sock->sk;
> > 
> >         if (!(sk->sk_route_caps & NETIF_F_SG) ||
> >             !(sk->sk_route_caps & NETIF_F_ALL_CSUM))
> >                 return sock_no_sendpage(sock, page, offset, size, flags);
> > 
> > 
> > So, it seems that if I set NETIF_F_SG but clear NETIF_F_ALL_CSUM,
> > data will be copied over rather than sent directly.
> > So why does dev.c have to force set NETIF_F_SG to off then?
> >
> I agree with that analysis,

So, would you Ack something like the following then?

======================

Enabling NETIF_F_SG without NETIF_F_ALL_CSUM actually seems to work fine by
doing an old-fashioned data copy in tcp_sendpage.
And for devices that do not calculate IP checksum in hardware (e.g. InfiniBand)
calculating the checksum for all packets in network driver is worse than have
the CPU piggyback the checksum compitation with the copy process.
Finally, note that NETIF_F_SG is necessary to be able to allocate skbs >
PAGE_SIZE on busy systems.

So, let's allow that combination, again, for drivers that want it.

Signed-off-by: Michael S. Tsirkin <mst@mellanox.co.il>

---

diff --git a/net/core/dev.c b/net/core/dev.c
index d4a1ec3..2d731a0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2930,14 +2930,6 @@ #endif
 		}
  	}
 
-	/* Fix illegal SG+CSUM combinations. */
-	if ((dev->features & NETIF_F_SG) &&
-	    !(dev->features & NETIF_F_ALL_CSUM)) {
-		printk(KERN_NOTICE "%s: Dropping NETIF_F_SG since no checksum feature.\n",
-		       dev->name);
-		dev->features &= ~NETIF_F_SG;
-	}
-
 	/* TSO requires that SG is present as well. */
 	if ((dev->features & NETIF_F_TSO) &&
 	    !(dev->features & NETIF_F_SG)) {

-- 
MST
