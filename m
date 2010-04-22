From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Thu, 22 Apr 2010 09:21:17 +0200
Message-ID: <1271920877.7895.4757.camel@edumazet-laptop>
References: <1271915513-2966-1-git-send-email-xiaosuo@gmail.com>
	 <20100421231843.4c284991@nehalam>
	 <p2i412e6f7f1004212330y6f3e2a92oa295e528afde3cd4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:55508 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179Ab0DVHV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 03:21:27 -0400
Received: by bwz25 with SMTP id 25so9170536bwz.28
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 00:21:26 -0700 (PDT)
In-Reply-To: <p2i412e6f7f1004212330y6f3e2a92oa295e528afde3cd4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 avril 2010 =C3=A0 14:30 +0800, Changli Gao a =C3=A9crit :
> On Thu, Apr 22, 2010 at 2:18 PM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
> > On Thu, 22 Apr 2010 13:51:53 +0800
> > Changli Gao <xiaosuo@gmail.com> wrote:
> >
> >> +     struct sk_buff          *input_pkt_queue_head;
> >> +     struct sk_buff          **input_pkt_queue_tailp;
> >> +     unsigned int            input_pkt_queue_len;
> >> +     unsigned int            process_queue_len;
> >
> > Why is opencoding a skb queue a step forward?
> > Just keep using sk_queue routines, just not the locked variants.
> >
>=20
> I want to keep the critical section of rps_lock() as small as possibl=
e
> to reduce the potential lock contention, when RPS is used.
>=20

Jamal perf reports show lock contention but also cache line ping pongs.

Yet, you keep a process_queue_len shared by producers and consumer.

Producers want to read it, while consumer decrement it (dirtying its
cache line) every packet, slowing down the things.


The idea of batching is to let the consumer process its local queue wit=
h
no impact to producers.

Please remove it completely, or make the consumer zero it only at the
end of batch processing.

A cache line miss cost is about 120 cycles. Multiply it by 1 million
packet per second...



