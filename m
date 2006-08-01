From: David Miller <davem@davemloft.net>
Subject: Re: FACK and CWND
Date: Mon, 31 Jul 2006 23:07:16 -0700 (PDT)
Message-ID: <20060731.230716.125566410.davem@davemloft.net>
References: <c583c3410607280337y5a9b1276gda0f00259ce1995f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6796
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161134AbWHAGH7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 02:07:59 -0400
To: gavin.malin@gmail.com
In-Reply-To: <c583c3410607280337y5a9b1276gda0f00259ce1995f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ma Lin" <gavin.malin@gmail.com>
Date: Fri, 28 Jul 2006 18:37:15 +0800

> In FACK, the holes between SACK blocks are considered as loss. To a
> sender, when SACK comes in, loss_out would be non-zero. According to
> linux-2.6.17.7/net/ipv4/tcp_input.c, function tcp_time_to_recover(),
> this non-zero loss_out will send the sender into "Recovery" state,
> in which, CWND could be reduced. In one word, it seems that, FACK
> would allow SACK holes to reduce CWND.

That's right, because when tp->lost_out is set we have some form
of absolute proof that packets were lost.

Note that even when not receiving SACK blocks, ie. pure Reno,
we emulate the SACK information the best we can.

So, if we have real SACK blocks, tcp_update_scoreboard() will
mark all packets in the retransmit queue up to "fackets_out"
minus "reordering" as lost.

Else, for non-SACK, only the head packet in the retransmit queue
will be marked as lost.

> However, in the paper "Congestion Control in Linux TCP", Section 3,
> subsection Recovery, it says that Recovery state is triggered by
> "sufficient amount of successive duplicate ACK", to my understand,
> that means 3-dup.

Under Linux it has more complicated definition.  We wait until
we see at least "tp->reordering" packets lost.

Dynamically we try to determine how deeply packets are being
reordered on the connection.

Using this value, we use "tp->fackets_out - tp->reordering"
as how many packets we think have been proven as lost.

You will note that any code path that falls through to to end
tcp_fastretrans_alert() will retransmit one packet using a call
to tcp_xmit_retransmit_queue().  And one such code path is the
transition to TCP_CA_Recovery which is guarded by the
tcp_time_to_recover() check, which encapsulates the two tests
we've discussed as:

	if (tp->lost_out)
		return 1;
	if (tcp_fackets_out(tp) > tp->reordering)
		return 1;

The next few checks try to handle some fringe cases, such as the head
packet in the retransmit queue having been sent more than an RTO ago,
and also having so few packets in the retransmit queue that normal
recovery mechanisms cannot function properly:

	if (tcp_head_timedout(sk, tp))
		return 1;
	packets_out = tp->packets_out;
	if (packets_out <= tp->reordering &&
	    tp->sacked_out >= max_t(__u32, packets_out/2, sysctl_tcp_reordering) &&
	    !tcp_may_send_now(sk, tp)) {
		return 1;
	}

Hope this helps.

