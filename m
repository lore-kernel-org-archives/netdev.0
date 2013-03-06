From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: use the default NAPI weight
Date: Tue, 05 Mar 2013 19:28:29 -0800
Message-ID: <1362540509.15793.158.camel@edumazet-glaptop>
References: <1362535067.15793.146.camel@edumazet-glaptop>
	 <20130305.210909.1826827522208936437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f171.google.com ([209.85.210.171]:59911 "EHLO
	mail-ia0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755065Ab3CFD2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 22:28:32 -0500
Received: by mail-ia0-f171.google.com with SMTP id z13so6975188iaz.16
        for <netdev@vger.kernel.org>; Tue, 05 Mar 2013 19:28:31 -0800 (PST)
In-Reply-To: <20130305.210909.1826827522208936437.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-05 at 21:09 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 05 Mar 2013 17:57:47 -0800
> 
> > BQL (Byte Queue Limits) proper operation needs TX completion
> > being serviced in a timely fashion.
> > 
> > bnx2x uses a non standard NAPI poll weight, and thats not fair to other
> > napi poll handlers, and even not reasonable.
> 
> Can you give some details about the situation in which you noticed
> this?
> 
> It may be reason enough to target this for 'net' and -stable instead.

Sure :

We are facing a fanout/fanin problem for a given application.

What happens is that link is mostly idle, and every couple of minutes,
we receive a burst of messages, needing a burst of transmits.

BQL starts with a limit of 0, meaning it needs some TX completion runs
to be able to detect the sudden increase of TX need and reach line rate.

bnx2x is really unfair in this scenario, because the NAPI poll budget is
very high, and aggregated packets (by LRO) count for a single packet in
the budget. (or even 0, see the "goto next_cqe;" that avoids the rx_pkt
++; in drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c line 1007)

We probably have other issues in the stack, I am patiently finding all
of them. In the mean time we had to disable BQL :(
