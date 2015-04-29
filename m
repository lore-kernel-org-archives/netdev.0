From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC net-next] pktgen: introduce 'rx' mode
Date: Wed, 29 Apr 2015 15:19:53 -0700
Message-ID: <1430345993.3711.59.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430273488-8403-1-git-send-email-ast@plumgrid.com>
	 <1430273488-8403-2-git-send-email-ast@plumgrid.com>
	 <1430280853.3711.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5541535E.1060908@plumgrid.com>
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
Received: from mail-ig0-f169.google.com ([209.85.213.169]:36853 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbbD2WT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 18:19:56 -0400
Received: by igblo3 with SMTP id lo3so130493087igb.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 15:19:55 -0700 (PDT)
In-Reply-To: <5541535E.1060908@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-29 at 14:55 -0700, Alexei Starovoitov wrote:
> On 4/28/15 9:14 PM, Eric Dumazet wrote:
> > On Tue, 2015-04-28 at 19:11 -0700, Alexei Starovoitov wrote:
> >
> >> +	if (pkt_dev->flags & F_DO_RX) {
> >> +		local_bh_disable();
> >> +		atomic_add(burst, &pkt_dev->skb->users);
> >> +		do {
> >> +			ret = netif_receive_skb(pkt_dev->skb);
> >> +			if (ret == NET_RX_DROP)
> >> +				pkt_dev->errors++;
> >> +			pkt_dev->last_ok = 1;
> >> +			pkt_dev->sofar++;
> >> +			pkt_dev->seq_num++;
> >> +		} while (--burst > 0);
> >> +		local_bh_enable();
> >> +		goto out;
> >> +	}
> >> +
> >
> > This looks buggy.
> >
> > skb can be put on a queue, so skb->next and skb->prev cannot be reused,
> > or queues will be corrupted.
> 
> don't see the bug yet.
> Any layer that wants to do such queueing should do skb_share_check
> first. Just like ip_rcv does. So everything in IP world should
> work fine, because it will be operating on clean cloned skb.

Really this is what _you_ think is needed, so that your patch can fly.

In current state of the stack, the skb_share_check() is done where we
know that packet _might_ be delivered to multiple end points
(deliver_skb() does atomic_inc(&skb->users) )

But RPS/RFS/GRO do not care of your new rule.

Yes, before reaching __netif_receive_skb_core(), packets are supposed to
belong to the stack. We are supposed to queue them, without adding a
check for skb->users being one or not, and eventually add an expensive
memory allocation/copy.

We are not going to add an extra check just to make pktgen rx fast.
pktgen will have to comply to existing rules.
