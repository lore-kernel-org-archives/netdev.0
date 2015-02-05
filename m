From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: do not pace pure ack packets
Date: Wed, 04 Feb 2015 20:36:58 -0800 (PST)
Message-ID: <20150204.203658.613727873443508787.davem@davemloft.net>
References: <1423017113.907.76.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kennetkl@ifi.uio.no
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41056 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933AbbBEEg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 23:36:59 -0500
In-Reply-To: <1423017113.907.76.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 03 Feb 2015 18:31:53 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> When we added pacing to TCP, we decided to let sch_fq take care
> of actual pacing.
> 
> All TCP had to do was to compute sk->pacing_rate using simple formula:
> 
> sk->pacing_rate = 2 * cwnd * mss / rtt
> 
> It works well for senders (bulk flows), but not very well for receivers
> or even RPC :
> 
> cwnd on the receiver can be less than 10, rtt can be around 100ms, so we
> can end up pacing ACK packets, slowing down the sender.
> 
> Really, only the sender should pace, according to its own logic.
> 
> Instead of adding a new bit in skb, or call yet another flow
> dissection, we tweak skb->truesize to a small value (2), and
> we instruct sch_fq to use new helper and not pace pure ack.
> 
> Note this also helps TCP small queue, as ack packets present
> in qdisc/NIC do not prevent sending a data packet (RPC workload)
> 
> This helps to reduce tx completion overhead, ack packets can use regular
> sock_wfree() instead of tcp_wfree() which is a bit more expensive.
> 
> This has no impact in the case packets are sent to loopback interface,
> as we do not coalesce ack packets (were we would detect skb->truesize
> lie)
> 
> In case netem (with a delay) is used, skb_orphan_partial() also sets
> skb->truesize to 1.
> 
> This patch is a combination of two patches we used for about one year at
> Google.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
