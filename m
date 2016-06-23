From: Eric Dumazet <edumazet@google.com>
Subject: Re: [REGRESSION, bisect]cxgb4 port failure with TSO traffic after
 commit 10d3be569243def8("tcp-tso: do not split TSO packets at retransmit time")
Date: Thu, 23 Jun 2016 04:51:10 -0700
Message-ID: <CANn89iLpBC5tUqpdSE4jCMKFgUi=mg=2kPZtMaRh-cnBhvauNg@mail.gmail.com>
References: <6DE8042992C3D3488ACEF3F2607097E3C4A81CA5@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hariprasad S <hariprasad@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	Kumar A S <kumaras@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"ycheng@google.com" <ycheng@google.com>
To: "Arjun V." <arjun@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:33233 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbcFWLvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 07:51:12 -0400
Received: by mail-yw0-f169.google.com with SMTP id v77so68970231ywg.0
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 04:51:11 -0700 (PDT)
In-Reply-To: <6DE8042992C3D3488ACEF3F2607097E3C4A81CA5@nice.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 23, 2016 at 3:08 AM, Arjun V. <arjun@chelsio.com> wrote:
> Hi all,
>
> The following patch introduced a regression in Chelsio cxgb4 driver, causing port failure when running heavy TSO traffic:
>
> commit 10d3be569243def8d92ac3722395ef5a59c504e6
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Thu Apr 21 10:55:23 2016 -0700
>
>     tcp-tso: do not split TSO packets at retransmit time
>
>     Linux TCP stack painfully segments all TSO/GSO packets before retransmits.
>
>     This was fine back in the days when TSO/GSO were emerging, with their
>     bugs, but we believe the dark age is over.
>
>     Keeping big packets in write queues, but also in stack traversal
>     has a lot of benefits.
>      - Less memory overhead, because write queues have less skbs
>      - Less cpu overhead at ACK processing.
>      - Better SACK processing, as lot of studies mentioned how
>        awful linux was at this ;)
>      - Less cpu overhead to send the rtx packets
>        (IP stack traversal, netfilter traversal, drivers...)
>      - Better latencies in presence of losses.
>      - Smaller spikes in fq like packet schedulers, as retransmits
>        are not constrained by TCP Small Queues.
>
>     1 % packet losses are common today, and at 100Gbit speeds, this
>     translates to ~80,000 losses per second.
>     Losses are often correlated, and we see many retransmit events
>     leading to 1-MSS train of packets, at the time hosts are already
>     under stress.
>
>     Signed-off-by: Eric Dumazet <edumazet@google.com>
>     Acked-by: Yuchung Cheng <ycheng@google.com>
>     Signed-off-by: David S. Miller davem@davemloft.net
>
> When the number of TCP retransmissions are quite high, the packet length coming from stack does not seems to be proper, due to which our TSO module gets stuck.
> If I change segs back to 1 in __tcp_retransmit_skb(),  traffic is running fine. Please let us know if we are missing something.
>
> Thanks,
> Arjun.
>

Hmm... I see nothing wrong in TCP stack.

Can you give me more details on the wrong packet length you see ?
