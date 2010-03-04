From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Fix TX ring processing on SMP machines
Date: Thu, 04 Mar 2010 00:41:57 -0800 (PST)
Message-ID: <20100304.004157.18721737.davem@davemloft.net>
References: <20100303181858.GA458@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: martyn.welch@ge.com, paul.gortmaker@windriver.com,
	Sandeep.Kumar@freescale.com, galak@kernel.crashing.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36191
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754583Ab0CDIli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 03:41:38 -0500
In-Reply-To: <20100303181858.GA458@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Wed, 3 Mar 2010 21:18:58 +0300

> Starting with commit a3bc1f11e9b867a4f49505 ("gianfar: Revive SKB
> recycling") gianfar driver sooner or later stops transmitting any
> packets on SMP machines.
> 
> start_xmit() prepares new skb for transmitting, generally it does
> three things:
> 
> 1. sets up all BDs (marks them ready to send), except the first one.
> 2. stores skb into tx_queue->tx_skbuff so that clean_tx_ring()
>    would cleanup it later.
> 3. sets up the first BD, i.e. marks it ready.
> 
> Here is what clean_tx_ring() does:
> 
> 1. reads skbs from tx_queue->tx_skbuff
> 2. checks if the *last* BD is ready. If it's still ready [to send]
>    then it it isn't transmitted, so clean_tx_ring() returns.
>    Otherwise it actually cleanups BDs. All is OK.
> 
> Now, if there is just one BD, code flow:
> 
> - start_xmit(): stores skb into tx_skbuff. Note that the first BD
>   (which is also the last one) isn't marked as ready, yet.
> - clean_tx_ring(): sees that skb is not null, *and* its lstatus
>   says that it is NOT ready (like if BD was sent), so it cleans
>   it up (bad!)
> - start_xmit(): marks BD as ready [to send], but it's too late.
> 
> We can fix this simply by reordering lstatus/tx_skbuff writes.
> 
> Reported-by: Martyn Welch <martyn.welch@ge.com>
> Bisected-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> Tested-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> Tested-by: Martyn Welch <martyn.welch@ge.com>

Applied.
