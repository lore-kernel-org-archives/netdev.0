From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC net-next] pktgen: introduce 'rx' mode
Date: Wed, 29 Apr 2015 16:39:46 -0700
Message-ID: <1430350786.3711.77.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430273488-8403-1-git-send-email-ast@plumgrid.com>
	 <1430273488-8403-2-git-send-email-ast@plumgrid.com>
	 <1430280853.3711.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5541535E.1060908@plumgrid.com>
	 <1430345993.3711.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55415D6B.7070009@plumgrid.com>
	 <1430348211.3711.66.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55416905.7070308@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:38457 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbbD2Xjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 19:39:48 -0400
Received: by igbhj9 with SMTP id hj9so63698325igb.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 16:39:48 -0700 (PDT)
In-Reply-To: <55416905.7070308@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-29 at 16:28 -0700, Alexei Starovoitov wrote:
> On 4/29/15 3:56 PM, Eric Dumazet wrote:
> >
> > So pktgen in RX mode MUST deliver skb with skb->users = 1, there is no
> > way around it.
> 
> if I only knew how to do it...
> The cost of continuously allocating skbs is way higher than
> netif_receive_skb itself. Such benchmarking tool would measure the
> speed of skb alloc/free instead of speed of netif_receive_skb.
> Are you suggesting to pre-allocate 10s of millions of skbs and
> then feed them in one go? The profile will be dominated by
> cache misses in the first few lines of __netif_receive_skb_core()
> where it accesses skb->dev,data,head. Doesn't sound too useful either.
> Other thoughts?

The code I copy pasted from your patch is buggy. Not the whole thing.

You have to replace it by something smarter.

This should not be hard really.

Zap the 'burst/clone' thing, this is not going to work for RX.
TX was okay, not RX. 

You could for instance do :

atomic_inc(&skb->users);
netif_receive_skb(skb);
if (atomic_read(skb->users) != 1) {
	/* This is too bad, I can not recycle this skb because it is still used */
	consume_skb(skb);
	/* allocate a fresh new skb */
	skb = ...
} else {
	/* Yeah ! Lets celebrate, cost of reusing this skb was one atomic op */
}
