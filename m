From: Simon Horman <horms@verge.net.au>
Subject: bridging: flow control regression
Date: Mon, 1 Nov 2010 21:29:22 +0900
Message-ID: <20101101122920.GB10052@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:38625 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755898Ab0KAM3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 08:29:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have observed what appears to be a regression between 2.6.34 and
2.6.35-rc1. The behaviour described below is still present in Linus's
current tree (2.6.36+).

On 2.6.34 and earlier when sending a UDP stream to a bonded interface
the throughput is approximately equal to the available physical bandwidth.

# netperf -c -4 -t UDP_STREAM -H 172.17.50.253 -l 30 -- -m 1472
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
172.17.50.253 (172.17.50.253) port 0 AF_INET
Socket  Message  Elapsed      Messages                   CPU      Service
Size    Size     Time         Okay Errors   Throughput   Util     Demand
bytes   bytes    secs            #      #   10^6bits/sec % SU     us/KB

114688    1472   30.00     2438265      0      957.1     18.09    3.159 
109568           30.00     2389980             938.1     -1.00    -1.000

On 2.6.35-rc1 netpref sends~7Gbits/s.
Curiously it only consumes 50% CPU, I would expect this to be CPU bound.

# netperf -c -4 -t UDP_STREAM -H 172.17.50.253 -l 30 -- -m 1472
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
172.17.50.253 (172.17.50.253) port 0 AF_INET
Socket  Message  Elapsed      Messages                   CPU      Service
Size    Size     Time         Okay Errors   Throughput   Util     Demand
bytes   bytes    secs            #      #   10^6bits/sec % SU     us/KB

116736    1472   30.00     18064360      0     7090.8     50.62    8.665 
109568           30.00     2438090             957.0     -1.00    -1.000

In this case the bonding device has a single gitabit slave device
and is running in balance-rr mode. I have observed similar results
with two and three slave devices.

I have bisected the problem and the offending commit appears to be
"net: Introduce skb_orphan_try()". My tired eyes tell me that change
frees skb's earlier than they otherwise would be unless tx timestamping
is in effect. That does seem to make sense in relation to this problem,
though I am yet to dig into specifically why bonding is adversely affected.

