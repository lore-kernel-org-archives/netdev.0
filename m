From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next PATCH] macvtap: Add packet capture support
Date: Wed, 20 Nov 2013 15:20:29 -0500 (EST)
Message-ID: <20131120.152029.1712178262809565940.davem@davemloft.net>
References: <20131120181949.GB25569@redhat.com>
	<20131120.145233.1158930529349207237.davem@davemloft.net>
	<528D173F.2060102@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754900Ab3KTUUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 15:20:31 -0500
In-Reply-To: <528D173F.2060102@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Wed, 20 Nov 2013 15:10:39 -0500

> I don't know if "better" is what I'd say here.  With the current code,
> if no-one is capturing, the cost is that of "if list_empty".  If
> I switch to rx_handler approach, the cost goes up on every packet even
> if no-one is capture.  The call stack ends up beeing really silly:
>   _netif_receive_skb_core()
>      macvlan_handle_frame()
>        macvtap_receive()
>          return RX_HANDLER_ANOTHER;
>      macvtap_handle_frame()
>          consume.
> 
> Yes, this approach seems to fit in better with the architecture of the
> stack, but boy, it looks inefficient.

It is cheaper than:

>      macvlan_handle_frame()
>        macvtap_receive()
>          netif_receive_skb()
>      ....
>      reprocess software interrupt

etc. etc.

With the rx_handler approach we're just iterating to a function call
which consumes the SKB, that whole code path is pretty much guarenteed
to be in the CPUs I-cache the second time.

I look forward to seeing your perf data :)
