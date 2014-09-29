From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv8 net-next 2/4] sunvnet: make transmit path zero-copy
 in the kernel
Date: Mon, 29 Sep 2014 16:29:50 -0400 (EDT)
Message-ID: <20140929.162950.1960056644564225055.davem@davemloft.net>
References: <5429B8E2.40204@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com,
	raghuram.kothakota@oracle.com
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbaI2U3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 16:29:53 -0400
In-Reply-To: <5429B8E2.40204@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Mon, 29 Sep 2014 15:54:10 -0400

> This patch removes pre-allocated transmit buffers and instead directly maps
> pending packets on demand. This saves O(n^2) maximum-sized transmit buffers,
> for n hosts on a vswitch, as well as a copy to those buffers.
> 
> Single-stream TCP throughput linux-solaris dropped ~5% for 1500-byte MTU,
> but linux-linux at 1500-bytes increased ~20%.
> 
> Signed-off-by: David L Stevens <david.stevens@oracle.com>

It doesn't work to liberate SKBs in the TX ring purely from the
->ndo_start_xmit() method.

All SKBs given to a device must be liberated in a finite, short,
amount of time.

This means that there must be an event which indicates TX completion
(either precisely, or at some small finite amount of time afterwards)
which will trigger kfree_skb().

Otherwise you can get a set of TX skbs in the TX queue, then if the
network goes quiet they are all stuck there indefinitely.

These SKBS hold onto resources such as sockets, netfilter state, etc.

Even if you apply a sledgehammer and skb_orphan() these packets, that
doesn't release the netfilter and other pieces of state.
