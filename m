From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: fix possible deadlock in tcp_send_fin()
Date: Wed, 22 Apr 2015 12:12:20 -0700
Message-ID: <1429729940.18561.133.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429666344.18561.37.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150422.141534.1363191163633903371.davem@davemloft.net>
	 <1429727967.18561.129.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150422.145014.115419919912486761.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: johunt@akamai.com, netdev@vger.kernel.org, edumazet@google.com,
	gthelen@google.com, rientjes@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:32772 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966238AbbDVTMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 15:12:22 -0400
Received: by iecrt8 with SMTP id rt8so45072148iec.0
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 12:12:22 -0700 (PDT)
In-Reply-To: <20150422.145014.115419919912486761.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-22 at 14:50 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 22 Apr 2015 11:39:27 -0700
> 
> > Note that in the unlikely case skb can not be allocated,
> > if an already transmitted packet is in the write queue, we also can OR
> > the FIN flag on it, and rely on normal rtx to deliver this FIN later.
> > 
> > I'll cook a patch when net-next reopens.
> 
> Hmmm, we already check for something like this at the beginning of
> tcp_send_fin(), I know because I added that piece of code 15+ years
> ago :-)
> 
> Or are you suggesting something slightly different?


The existing test does the OR only if there is an unsent frame in the
write queue.

Because if the frame present in write queue was already sent, we prefer
cooking a fresh skb to be able to send it right now (disabling Nagle
checks)

So, in the case we cannot allocate the skb, we can still add the FIN
flag, but not push any frame right now.

FIN will be sent later, because incoming ACK or rtx will eventually send
it.

This sounds better than not sending FIN at all.
