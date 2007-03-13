From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [patch 12/19] fix irq problem with NAPI + NETPOLL
Date: Tue, 13 Mar 2007 17:14:27 +0900 (JST)
Message-ID: <20070313.171427.127590092.nemoto@toshiba-tops.co.jp>
References: <200703061041.l26AfusT019768@shell0.pdx.osdl.net>
	<20070307.151844.102573883.davem@davemloft.net>
	<20070308.103513.103776988.nemoto@toshiba-tops.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com, shemminger@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from topsns2.toshiba-tops.co.jp ([202.230.225.126]:2098 "EHLO
	topsns2.toshiba-tops.co.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965109AbXCMIOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2007 04:14:40 -0400
In-Reply-To: <20070308.103513.103776988.nemoto@toshiba-tops.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 08 Mar 2007 10:35:13 +0900 (JST), Atsushi Nemoto <anemo@mba.ocn.ne.jp> wrote:
> > netpoll_rx() should be invokable from hardware interrupt context.
> > What is the crash you are seeing?
> 
> The problem is not netpoll_rx().  It should be called from irq context.
> The problem is, netif_receive_skb() is called from irq context though
> it seems not designed to do so.

Unfortunately I could not reproduce the crash, but IIRC the crash was
happened at upper protocol layer on hardware interrupt context.

Anyway, I think main path of netif_receive_skb() should not be
executed in hardware interrupt context.  Is it wrong?

> > It looks like perhaps the kfree_skb() calls need to be modified
> > in __netpoll_rx().
> 
> Well, it seems an another netpoll bug.

I suppose these kfree_skb() in __netpoll_rx() should be
dev_kfree_skb_any().  And I found an another abuse which is irrelevant
to netpoll.  The netif_rx() calls kfree_skb() at its bottom.  The
netif_rx() should be callable from hardware interrupt context, so it
should be changed to dev_kfree_skb_any().  Is it right?

---
Atsushi Nemoto
