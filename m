From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] ipv6: make inet6addr_chain blocking and always
 call with rtnl locked
Date: Sat, 16 May 2015 17:22:14 -0400 (EDT)
Message-ID: <20150516.172214.820543928532454603.davem@davemloft.net>
References: <20150514134657.14062.87579.stgit@buzz>
	<20150514135618.14062.1969.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com, jbenc@redhat.com,
	hannes@stressinduktion.org
To: khlebnikov@yandex-team.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980AbbEPVWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 17:22:16 -0400
In-Reply-To: <20150514135618.14062.1969.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Thu, 14 May 2015 16:56:18 +0300

> Unlike to inetaddr_chain inet6addr_chain is atomic and called from bh
> context without rtnl when ipv6 receives router advertisement packet.
> 
> Several drivers don't know about that: ipvlan thinks that it has rtnl
> here, ocrdma locks mutex inside callback. Probably there is more.
> 
> This patch makes it blocking and calls from first stage of DAD work.
> Looks like this is completely safe and rtnl already locked here.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

I don't see how you can make the inet6addr_chain blocking when it is
invoked from software interrupt context.

You also cannot try to defer these operations to a workqueue or
similar to get into a blockable context, because various ipv6
testsuites depend upon the addressing state change happening
when we process the packet that triggers that change.

Instead, I think you have to make the users of inet6addr_chain
aware of the context in which they execute.

Thanks.
