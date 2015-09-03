From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: eth: altera: fix napi poll_list corruption
Date: Wed, 02 Sep 2015 19:42:01 -0700
Message-ID: <1441248121.8932.217.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150902.174929.153474872.nemoto@toshiba-tops.co.jp>
	 <20150902.112500.2176991714061589322.davem@davemloft.net>
	 <20150903.095257.116214212.nemoto@toshiba-tops.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, vbridger@opensource.altera.com,
	netdev@vger.kernel.org
To: Atsushi Nemoto <nemoto@toshiba-tops.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33853 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627AbbICCmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 22:42:04 -0400
Received: by padhy1 with SMTP id hy1so30658659pad.1
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 19:42:03 -0700 (PDT)
In-Reply-To: <20150903.095257.116214212.nemoto@toshiba-tops.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-09-03 at 09:52 +0900, Atsushi Nemoto wrote:
> On Wed, 2 Sep 2015 11:25:00 -0700, David Miller <davem@davemloft.net> wrote:
> > Two lines below this change you are disabling interrupts anyways,
> > so I would suggest just moving the spin_lock_irqsave() before the
> > napi_gro_flush() to fix this.
> > 
> > Many of the checks done by napi_complete_done() (invoked by
> > napi_complete()) are completely redundant in this context.  For
> > example, the direct __napi_complete() call is a really nice
> > optimization because we know we are on the poll list and therefore
> > it is not empty.
> 
> Thank you for your suggestion.
> 
> I think napi_gro_flush() can be called with irq enabled, so moving the
> spin_lock_irqsave() just before the __napi_complete() (or moving the
> __napi_complete() just after the spin_lock_irqsave()) would be better,
> right?

Unless masking irqs are damn slow on hosts supporting this NIC,
I would rather use napi_complete_done() and add the possibility of
aggregating more frames per GRO packet, setting a non zero
gro_flush_timeout

Calling napi_gro_flush() and __napi_complete() looks error prone.
