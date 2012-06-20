From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 15:29:59 -0700 (PDT)
Message-ID: <20120620.152959.2146722628245186096.davem@davemloft.net>
References: <20120619.231412.1236237191660427779.davem@davemloft.net>
	<20120620.031543.1511134879638711616.davem@davemloft.net>
	<1340195920.4604.918.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46011 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757676Ab2FTWaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 18:30:00 -0400
In-Reply-To: <1340195920.4604.918.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Jun 2012 14:38:40 +0200

> Problem could happen if sk->sk_rx_dst is freed while some packets are
> still in napi or socket backlog (can happen with some network
> reordering)
> 
> 1) Socket backlog must be flushed before sk->sk_rx_dst freeing
> 
> 2) Even if we move rcu_read_lock() in net_rx_action(), we need some
> napi_gro_forcedstrefs() in case we sofnet_break
> 
> Or maybe just use napi_gro_flush() ?

Good catch, but I've just figured out a more fundamental issue
with doing this at the GRO layer.

The IPV4 input path is going to undo our early socket demux by
orphaning the SKB in ip_rcv().  So we'll end up looking up the
socket twice.
