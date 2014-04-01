From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net-gro: restore frag0 optimization
Date: Tue, 01 Apr 2014 10:16:44 -0700
Message-ID: <1396372604.3989.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5334542F.1050702@redhat.com>
		 <1395938874.12610.306.camel@edumazet-glaptop2.roam.corp.google.com>
		 <53345A6C.5080008@redhat.com>
		 <1395940898.12610.307.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1396153701.29410.27.camel@edumazet-glaptop2.roam.corp.google.com>
	 <533AEBEB.5020400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jerry Chu <hkchu@google.com>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:39418 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751247AbaDARQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 13:16:46 -0400
Received: by mail-pa0-f43.google.com with SMTP id bj1so10177830pad.30
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2014 10:16:45 -0700 (PDT)
In-Reply-To: <533AEBEB.5020400@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-04-01 at 18:40 +0200, Michal Schmidt wrote:

> Eric,
> thank you. The patch improves the performance. Though it's still not as
> fast as it was before the commit "net-gro: Prepare GRO stack for the
> upcoming tunneling support". In repeated netperf runs my reporter now
> sees occasional results above 9 Gb/s, but on average it's only 7 Gb/s.
> 
> With your patch only Ethernet headers (and not other headers) are copied
> into skbs' heads, but this is done for all skbs. Previously (before
> Jerry's patch) no copying was needed for skbs that were GRO_MERGED.
> Is this correct?

Note that TCP performance of a single flow is very dependent from
various factors, especially on a NUMA platform.

For example, consuming less cpu can have a side effect because it allows
it to enter deeper wait states on idle periods.

If you see a problem doing the memcpy(xxx, yyy, 14) then it means
that we would have had the issue later anyway.

Thats why some drivers are doing a prefetch(frame) way before calling
napi_gro_frags()

Sure, GRO stack is a bit more complex because it now handles
encapsulation.

So is the GSO stack, and we are OK with that because
it improves general use cases in DC/virtualization world.

Make sure everything is setup properly (irq smp_affinity),
and try to use multiple TCP flows, or make sure this is not a sender
issue.
