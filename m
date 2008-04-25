From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Thu, 24 Apr 2008 23:46:28 -0700 (PDT)
Message-ID: <20080424.234628.170849475.davem@davemloft.net>
References: <d1c2719f0804231629p4536e98do668b812e34d2b92c@mail.gmail.com>
	<1e41a3230804240932u510609beh8fb577baaadeb9bd@mail.gmail.com>
	<d1c2719f0804241749p2c0dd7daofd343bc37a916247@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, netdev@vger.kernel.org, rick.jones2@hp.com
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53991
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755440AbYDYGq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 02:46:28 -0400
In-Reply-To: <d1c2719f0804241749p2c0dd7daofd343bc37a916247@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jerry Chu" <hkchu@google.com>
Date: Thu, 24 Apr 2008 17:49:33 -0700

> One question: I currently use skb_shinfo(skb)->dataref == 1 for skb's on the
> sk_write_queue list as the heuristic to determine if a packet has hit the wire.

This doesn't work for the reasons that you mention in detail next :-)

> Is there a better solution than checking against dataref to determine if a pkt
> has hit the wire?

Unfortunately, no there isn't.

Part of the issue is that the driver is only working with a clone, but
if a packet gets resent before the driver gives up it's reference,
we'll make a completely new copy.

But even assuming we could say that the driver gets a clone all the
time, the "sent" state would need to be in the shared data area.

> Also the code to determine when/how much to defer in the TSO path seems
> too aggressive. It's currently based on a percentage
> (sysctl_tcp_tso_win_divisor)
> of min(snd_wnd, snd_cwnd). Would it be too much if the value is large? E.g.,
> when I disable sysctl_tcp_tso_win_divisor, the cwnd of my simple netperf run
> drops exactly 1/3 from 1037 (segments) to 695. It seems to me the TSO
> defer factor should be based on an absolute count, e.g., 64KB.

This is one of the most difficult knobs to get right in the TSO code.

If the percentage is too low, you'll notice that cpu utilization
increases because you aren't accumulating enough data to send down the
largest possible TSO frames.

But yes you are absolutely right that we should have a hard limit
of 64K here, since we can't build a larger TSO frame anyways.

In fact I thought we had something like that here already :-/

Wait, in fact we do, it's just hidden behind a variable now:

	/* If a full-sized TSO skb can be sent, do it. */
	if (limit >= sk->sk_gso_max_size)
		goto send_now;

:-)
