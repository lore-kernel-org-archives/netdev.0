From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: fq_codel: Fix off-by-one error
Date: Sat, 30 Mar 2013 07:42:47 -0700
Message-ID: <1364654567.5113.85.camel@edumazet-glaptop>
References: <1364514720-20780-1-git-send-email-subramanian.vijay@gmail.com>
	 <1364569280.5113.21.camel@edumazet-glaptop> <20130330065345.GA23938@x4>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:38263 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756722Ab3C3Omt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 10:42:49 -0400
Received: by mail-pa0-f42.google.com with SMTP id kq13so720306pab.1
        for <netdev@vger.kernel.org>; Sat, 30 Mar 2013 07:42:49 -0700 (PDT)
In-Reply-To: <20130330065345.GA23938@x4>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-03-30 at 07:53 +0100, Markus Trippelsdorf wrote:
> On 2013.03.29 at 08:01 -0700, Eric Dumazet wrote:
> > 
> > Just curious, did you play changing the default limit (10240 packets) ?
> 
> I did some tests on my home router (running OpenWrt trunk) that is rate-
> limited with hfsc to the speed of the cable modem.
> 
> My tests seem to indicate that lowering the default limit to 1024
> packets results in much better latency behavior when using bittorrent.
> 
> With the default limit (10240 packets) I would get huge ping latencies
> from 600-1200ms when downloading e.g.:
> http://download.opensuse.org/distribution/12.3/iso/openSUSE-12.3-DVD-x86_64.iso.torrent
> with hundreds of peers.
> 
> Setting the limit to 1024 did get the latencies back in check (20-30ms
> with occasional spikes of ~100ms).

Hi Markus

I am very bored having to explain {fq_}codel principles each time
someone does this kind of experiments.

Codel principle is _allowing_ bursts, as long as the queue is
controlled. Read Codel paper for details. TCP can be slow to lower the
queues, it takes several RTT. So observing large queues is quite normal
in your case.

Bittorent uses its own rate limiting technique, defeating
current cwnd control done in the TCP stack, because of a very known
problem

( http://www.ietf.org/id/draft-ietf-tcpm-newcwv-00.txt )

So if your goal is reducing latencies for a _given_ class of flows, just
use prio + 3 fq_codel,  and classify your packets to make sure your
lovely ping packets are not dropped or behind long packets.

fq_codel by itself is not universal.

My question about fq_codel limit was related to something completely
different.

The default is 10240 packets. The logic behind is to control the queue
at dequeue, not enqueue. But we needed an safety limit to avoid OOM in
case rate of enqueue() is insane.

It could theoretically hurt a low end machine, in case a burst fills the
queue with big GSO packets. But then these low end machines should not
use GRO/TSO anyway (as this is against anti bufferbloat techniques)

Probably a better choice would have been to limit sum(skb->truesize), or
sum(skb->len) (aka current sch->qstats.backlog)
