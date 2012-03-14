From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/hyperv: fix erroneous NETDEV_TX_BUSY use
Date: Wed, 14 Mar 2012 12:17:12 -0700
Message-ID: <1331752632.6022.49.camel@edumazet-glaptop>
References: <1331751214.6022.47.camel@edumazet-glaptop>
	 <4F60E9F7.4000402@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:47347 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752106Ab2CNTRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 15:17:14 -0400
Received: by dadp12 with SMTP id p12so3386862dad.11
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2012 12:17:14 -0700 (PDT)
In-Reply-To: <4F60E9F7.4000402@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-03-14 at 11:56 -0700, Ben Greear wrote:
> On 03/14/2012 11:53 AM, Eric Dumazet wrote:
> > A driver start_xmit() method cannot free skb and return NETDEV_TX_BUSY,
> > since caller is going to reuse freed skb.
> >
> > This is mostly a revert of commit bf769375c (staging: hv: fix the return
> > status of netvsc_start_xmit())
> >
> > In fact netif_tx_stop_queue() / netif_stop_queue() is needed before
> > returning NETDEV_TX_BUSY or you can trigger a ksoftirqd fatal loop.
> >
> > In case of memory allocation error, only safe way is to drop the packet
> > and return NETDEV_TX_OK
> 
> Can you not just leave the skb alone, not bump any tx-dropped
> stats, and return NETDEV_TX_BUSY?
> 

Nope. Think about OOM.

If we do that, we requeue packet on qdisc, and schedule TX softirq.

-> loop

Really, NETDEV_TX_BUSY is not for this kind of situation.
