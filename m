From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] Failover-friendly TCP retransmission
Date: Tue, 5 Jun 2007 21:23:45 +0200
Message-ID: <20070605192345.GA28301@one.firstfloor.org>
References: <XNM1$2$0$3$$2$8$4$A$2004314U46640bd2@hitachi.com> <p738xazbwha.fsf@bingen.suse.de> <20070605.220536.73364034.noboru.obata.ar@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: noboru.obata.ar@hitachi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:56518 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762318AbXFETXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 15:23:50 -0400
Content-Disposition: inline
In-Reply-To: <20070605.220536.73364034.noboru.obata.ar@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Your suggestion, to utilize NET_XMIT_* code returned from an
> underlying layer, is done in tcp_transmit_skb.
> 
> But my problem is that tcp_transmit_skb is not called during a
> certain period of time.  So I'm suggesting to cap RTO value so
> that tcp_transmit_skb gets called more frequently.

The transmit code controls the transmission timeout. Or at least
it could change it if it really wanted.

What I wanted to say is: if the loss still happens under control
of the sending end device and TCP knows this then it could change
the retransmit timer to fire earlier or even just wait for an 
event from the device that tells it to retransmit early.

I admit I have not thought through all the implications of this,
but it would seem to me a better approach than capping RTO or
doing other intrusive TCP changes.

The problem with capping RTO is that when there is a loss
in the network for some other reasons (and there is no reason
bonding can't be used when talking to the internet) you
might be too aggressive or not aggressive enough anymore
to get the data through.

But if you only change behaviour when you detect a local
loss this cannot happen.

Just using a very short timeout of one jiffie on local loss might work 
(the stack already does this sometimes). Upcalls would be more 
complicated and might have some bad side effects (like not 
interacting well with qdiscs or possibly being unfair if there 
are a lot of sockets). But that might be solvable too. 

In a virtualized environments it might be also needed 
to pass NET_XMIT_* through the paravirtual driver interface.

-Andi

