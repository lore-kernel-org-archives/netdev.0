From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] net: add accounting for socket backlog
Date: Fri, 26 Feb 2010 04:05:36 -0800 (PST)
Message-ID: <20100226.040536.247057194.davem@davemloft.net>
References: <1267176464-426-1-git-send-email-yi.zhu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: yi.zhu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49877
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935641Ab0BZMFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 07:05:17 -0500
In-Reply-To: <1267176464-426-1-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yi <yi.zhu@intel.com>
Date: Fri, 26 Feb 2010 17:27:44 +0800

> We got system OOM while running some UDP netperf testing on the loopback
> device. The case is multiple senders sent stream UDP packets to a single
> receiver via loopback on local host. Of course, the receiver is not able
> to handle all the packets in time. But we surprisingly found that these
> packets were not discarded due to the receiver's sk->sk_rcvbuf limit.
> Instead, they are kept queuing to sk->sk_backlog and finally ate up all
> the memory. We believe this is a secure hole that a none privileged user
> can crash the system.
> 
> The root cause for this problem is, when the receiver is doing
> __release_sock() (i.e. after userspace recv, kernel udp_recvmsg ->
> skb_free_datagram_locked -> release_sock), it moves skbs from backlog to
> sk_receive_queue with the softirq enabled. In the above case, multiple
> busy senders will almost make it an endless loop. The skbs in the
> backlog end up eat all the system memory.
> 
> The patch fixed this problem by adding accounting for the socket
> backlog. So that the backlog size can be restricted by protocol's choice
> (i.e. UDP).
> 
> Reported-by: Alex Shi <alex.shi@intel.com>
> Cc: David Miller <davem@davemloft.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>

So remind me why TCP, or any other non-UDP protocol, won't
intrinsically have this problem too?

It seems pretty trivial to do with any protocol, especially remotely,
with a packet generator.  The code in TCP, for example, which queues
to the backlog, doesn't care about sequence numbers or anything like
that.

So you could spray a machine with the same TCP frame over and over
again, as fast as possible, as long as it matches the socket identity.

And in this way fill up the backlog endlessly and OOM the system.
