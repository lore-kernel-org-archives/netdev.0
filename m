From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fix tcp fin memory accounting
Date: Thu, 23 Apr 2015 09:48:12 -0700
Message-ID: <1429807692.22254.59.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429661349.18561.23.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5538F821.6070503@akamai.com>
	 <1429797767.22254.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150423.115447.2163146250304402014.davem@davemloft.net>
	 <1429805815.22254.57.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: johunt@akamai.com, netdev@vger.kernel.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:33071 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966257AbbDWQsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 12:48:20 -0400
Received: by iecrt8 with SMTP id rt8so65184304iec.0
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 09:48:19 -0700 (PDT)
In-Reply-To: <1429805815.22254.57.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-23 at 09:16 -0700, Eric Dumazet wrote:
> On Thu, 2015-04-23 at 11:54 -0400, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Thu, 23 Apr 2015 07:02:47 -0700
> > 
> > > +		if (!tcp_send_head(sk)) {
> > > +			tp->snd_nxt++;
> > > +			return;
> > > +		}
> > 
> > I'm not so sure about this.  Why is this needed?
> > 
> > Otherwise patch looks fine to me.
> > 
> 
> I guess I need to add a comment then ;)
> 
> If we want to pretend FIN was sent, we also need to tweak tp->snd_nxt to
> match new tskb->end_seq (or tp->write_seq).
> 
> I tested following packetdrill script and confirmed that if I do not
> tweak snd_nxt, last packet sent is incorrect :
> 
> 	> . 5001:5001(0) ack 2
> 
> This might be because our stack relies that we never coalesce something
> on one already sent skb (we do this check in tcp_sendmsg() for example)

Well, real reason is that tp->snd_nxt is not touched in retransmit
paths, but when new data is sent (tcp_event_new_data_sent())
