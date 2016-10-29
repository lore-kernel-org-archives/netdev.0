From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] enic: fix rq disable
Date: Sat, 29 Oct 2016 17:25:38 -0400 (EDT)
Message-ID: <20161029.172538.2219365495759907566.davem@davemloft.net>
References: <20161027230103.35242-1-gvaradar@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benve@cisco.com, _govind@gmx.com
To: gvaradar@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53170 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751098AbcJ2VZk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 17:25:40 -0400
In-Reply-To: <20161027230103.35242-1-gvaradar@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Date: Thu, 27 Oct 2016 16:01:03 -0700

> When MTU is changed from 9000 to 1500 while there is burst of inbound 9000
> bytes packets, adaptor sometimes delivers 9000 bytes packets to 1500 bytes
> buffers. This causes memory corruption and sometimes crash.
> 
> This is because of a race condition in adaptor between "RQ disable"
> clearing descriptor mini-cache and mini-cache valid bit being set by
> completion of descriptor fetch. This can result in stale RQ desc being
> cached and used when packets arrive. In this case, the stale descriptor
> have old MTU value.
> 
> Solution is to write RQ->disable twice. The first write will stop any
> further desc fetches, allowing the second disable to clear the mini-cache
> valid bit without danger of a race.
> 
> Also, the check for rq->running becoming 0 after writing rq->enable to 0
> is not done properly. When incoming packets are flooding the interface,
> rq->running will pulse high for each dropped packet. Since the driver was
> waiting for 10us between each poll, it is possible to see rq->running = 1
> 1000 times in a row, even though it is not actually stuck running.
> This results in false failure of vnic_rq_disable(). Fix is to try more
> than 1000 time without delay between polls to ensure we do not miss when
> running goes low.
> 
> In old adaptors rq->enable needs to be re-written to 0 when posted_index
> is reset in vnic_rq_clean() in order to keep rq->prefetch_index in sync.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied.
