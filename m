From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Tue, 13 Apr 2010 15:21:34 +0200
Message-ID: <1271164894.16881.342.camel@edumazet-laptop>
References: <1271173102-2980-1-git-send-email-xiaosuo@gmail.com>
	 <1271146112.16881.213.camel@edumazet-laptop>
	 <o2v412e6f7f1004130250rdbe17c5dr5c11c3cbbb2f6dbb@mail.gmail.com>
	 <1271153942.16881.233.camel@edumazet-laptop>
	 <n2t412e6f7f1004130553x85452fc0u22e512cad412abd3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:52670 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567Ab0DMNWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 09:22:19 -0400
Received: by bwz19 with SMTP id 19so417bwz.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 06:22:15 -0700 (PDT)
In-Reply-To: <n2t412e6f7f1004130553x85452fc0u22e512cad412abd3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 20:53 +0800, Changli Gao a =C3=A9crit :
> OK. If we make processing_queue is a stack variable. When quota or
> jiffies limit is reached, we have to splice processing_queue back to
> input_pkt_queue. If flush_backlog() is called before the
> processing_queue is spliced, there will still packets which refer to
> the NIC going. Then these packets are queued to input_pkt_queue. When
> process_backlog() is called again, the dev field of these skbs are
> wild...
>=20

This is a problem of cooperation between flush_backlog() and
process_backlog(). Dont allow flush_backlog() to return if
process_backlog() is running. Exactly as before, but lock acquisition
done in flush_backlog() should be a bit smarter.


> Oh, my GOD. When RPS is enabled, if flush_backlog(eth0) is called on
> CPU1 when a skb0(eth0) is dequeued from CPU0's softnet and isn't
> queued to CPU1's softnet, what will happen?
>=20

I am a bit lost here. flush_backlog() drops skbs, not requeue them.


> >
> > Absolutely not. You missed something apparently.
> >
> > You pay the price at each packet enqueue, because you have to compu=
te
> > the sum of two lengthes, and guess what, if you do this you have a =
cache
> > line miss in one of the operand. Your patch as is is suboptimal.
> >
> > Remember : this batch mode should not change packet queueing at all=
,
> > only speed it because of less cache line misses.
> >
>=20
> WoW, is it really so expensive?
>=20

Yes. Whole point of your idea is to remove cache line misses.

They cost much more than a spinlock/unlock pair


