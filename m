From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 1/1] ax25: Fix segfault when receiving an iframe with
 net2kiss loaded
Date: Fri, 02 Dec 2016 11:05:10 -0500 (EST)
Message-ID: <20161202.110510.316320127082862142.davem@redhat.com>
References: <20161130111525.13f74728@brox.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jreuter@yaina.de, ralf@linux-mips.org, linux-hams@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        stable@vger.kernel.org, ed@wizkers.io, mcdermj@xenotropic.com
To: basil@pacabunga.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57290 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751290AbcLBQN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 11:13:59 -0500
In-Reply-To: <20161130111525.13f74728@brox.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Basil Gunn <basil@pacabunga.com>
Date: Wed, 30 Nov 2016 11:15:25 -0800

> AX.25 uses sock_queue_rcv_skb() to queue an iframe received packet.
> This routine writes NULL to the socket buffer device structure
> pointer. The socket buffer is subsequently serviced by
> __netif_receiv_skb_core() which dereferences the device structure
> pointer & segfaults.
> 
> The fix puts the ax25 device structure pointer back in the socket
> buffer struct after sock_queue_rcv_skb() is called.

You cannot do this.

We have no reference count held on the device object, therefore once
access to this SKB leaves the receive packet processing path and thus
the RCU protected region, we must set skb->dev to NULL.

Queueing the SKB to the socket causes the SKB to leave the receive
processing path.

You will have to find another way to propagate this device pointer
to the code that needs it.
