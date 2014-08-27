From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Wed, 27 Aug 2014 06:23:58 -0700
Message-ID: <1409145838.3173.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>
	 <1409142672.26515.24.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, jhs@mojatatu.com, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au,
	dborkman@redhat.com, brouer@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:62055 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933592AbaH0NYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 09:24:04 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so271848pab.28
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 06:24:00 -0700 (PDT)
In-Reply-To: <1409142672.26515.24.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-08-27 at 14:31 +0200, Hannes Frederic Sowa wrote:

> One thing one should keep in mind is, that there must be a skb available
> to trigger the flush, maybe this will hurt us one day.
> 
> Thinking more about it should we go with a coccinelle script and
> replace/extend ndo_start_xmit with an additional argument?

This will be a pain for backports and things like that.

skb->xmit_more is a bit annoying, because it consumes one bit in all
skbs, while it could be one byte per cpu as ndo_start_xmit() is called
while BH are disabled.

It also forces a cache line dirtying, that will hurt qdisc like HTB
where skbs can be cooked/enqueued by remote cpus.

Also, most drivers will never benefit from this new infra.

Mellanox mlx4 uses the Blue Frame trick to avoid the iowrite() cost.

I am afraid Jesper tests are not complete to truly have a picture of the
extra costs, because he made sure no false sharing was possible (A
single cpu does everything and keeps skb in its cache)
