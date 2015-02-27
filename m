From: Jaedon Shin <jaedon.shin@gmail.com>
Subject: Re: [PATCH] net: bcmgenet: fix throughtput regression with TSO autosizing
Date: Fri, 27 Feb 2015 23:33:37 +0900
Message-ID: <F8B81F3F-4E21-4468-8963-2A762AF9A7CC@gmail.com>
References: <1424948758-48244-1-git-send-email-jaedon.shin@gmail.com> <20150226.113650.2092516427472228316.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2087\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:37579 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbbB0Odq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 09:33:46 -0500
Received: by pdbfl12 with SMTP id fl12so21456880pdb.4
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 06:33:45 -0800 (PST)
In-Reply-To: <20150226.113650.2092516427472228316.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Feb 27, 2015, at 1:36 AM, David Miller <davem@davemloft.net> wrote:
> 
> From: Jaedon Shin <jaedon.shin@gmail.com>
> Date: Thu, 26 Feb 2015 20:05:58 +0900
> 
>> This patch prevents the performance degradation of xmit after
>> 605ad7f ("tcp: refine TSO autosizing").
>> 
>> Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
> 
> I doubt this is the correct way to fix this.
> 
> Also, you need to describe in detail what the actual problem
> is, how you evaluated the cause, and what made you think that
> your choosen solution is the proper one.

The bcmgenet_tx_reclaim() of tx_ring[{0,1,2,3}] process only under 18 
descriptors is too late reclaiming transmitted skb. Therefore, 
performance degradation of xmit after 605ad7f ("tcp: refine TSO autosizing").

# iperf -c 172.16.1.2 -i 1 
------------------------------------------------------------
Client connecting to 172.16.1.20, TCP port 5001
TCP window size: 45.0 KByte (default)
------------------------------------------------------------
[  3] local 172.16.1.101 port 44020 connected with 172.16.1.20 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 1.0 sec   512 KBytes  4.19 Mbits/sec
[  3]  1.0- 2.0 sec   384 KBytes  3.15 Mbits/sec
[  3]  2.0- 3.0 sec  0.00 Bytes  0.00 bits/sec
[  3]  3.0- 4.0 sec  0.00 Bytes  0.00 bits/sec
[  3]  4.0- 5.0 sec   128 KBytes  1.05 Mbits/sec
[  3]  5.0- 6.0 sec  0.00 Bytes  0.00 bits/sec
[  3]  6.0- 7.0 sec  5.75 MBytes  48.2 Mbits/sec
[  3]  7.0- 8.0 sec  11.1 MBytes  93.3 Mbits/sec
[  3]  8.0- 9.0 sec  11.2 MBytes  94.4 Mbits/sec
[  3]  9.0-10.0 sec  11.1 MBytes  93.3 Mbits/sec
[  3]  0.0-10.0 sec  40.5 MBytes  33.9 Mbits/sec

Considered as a way to avoid the two.

1. Using skb_orphan found previous mailing. This is reporting finish 
of xmit immediately.

2. Using bcmgenet_tx_reclaim_all instead of bcmgenet_tx_reclaim in 
bcmgenet_poll. But, it is not suitable to use because of bcmgenet_poll 
is connected with bcmgenet_isr0.

So, I had to use the shortest way. the result is as follows:

# iperf -c 172.16.1.20 -i 1
------------------------------------------------------------
Client connecting to 172.16.1.20, TCP port 5001
TCP window size: 45.0 KByte (default)
------------------------------------------------------------
[  3] local 172.16.1.101 port 50763 connected with 172.16.1.20 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 1.0 sec  11.2 MBytes  94.4 Mbits/sec
[  3]  1.0- 2.0 sec  11.2 MBytes  94.4 Mbits/sec
[  3]  2.0- 3.0 sec  11.1 MBytes  93.3 Mbits/sec
[  3]  3.0- 4.0 sec  11.2 MBytes  94.4 Mbits/sec
[  3]  4.0- 5.0 sec  11.1 MBytes  93.3 Mbits/sec
[  3]  5.0- 6.0 sec  11.2 MBytes  94.4 Mbits/sec
[  3]  6.0- 7.0 sec  11.1 MBytes  93.3 Mbits/sec
[  3]  7.0- 8.0 sec  11.2 MBytes  94.4 Mbits/sec
[  3]  8.0- 9.0 sec  11.2 MBytes  94.4 Mbits/sec
[  3]  9.0-10.0 sec  11.1 MBytes  93.3 Mbits/sec
[  3]  0.0-10.0 sec   112 MBytes  94.0 Mbits/sec

> Hmpff...
> 
> Can you elaborate on the regression ?
> 
> Is it because NIC delays TX completion irq or something ?
> 
> bcmgenet_poll() only drains TX packets on ring16 (DESC_INDEC)
> 
> Other tx completions seem to run from hard irq context (bcmgenet_isr1())
> 
> Your patch seems to imply a bug in hard irq signaling/handling.

Good point.

The use of skb_orphan is in hard irq. I had mistaken using hard irq 
in tx_ring[{0,1,2,3}].

The patch of v2 is to use tx_poll like bcmsysport. 
That too can get the good results.
