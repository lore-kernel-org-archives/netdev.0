From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] rfc: ethtool: early-orphan control
Date: Sat, 11 Dec 2010 13:24:34 +0900
Message-ID: <20101211042434.GB32453@verge.net.au>
References: <1292040815-10439-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:34622 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753627Ab0LKEYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 23:24:40 -0500
Content-Disposition: inline
In-Reply-To: <1292040815-10439-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 11, 2010 at 01:13:35PM +0900, Simon Horman wrote:
> Early orphaning is an optimisation which avoids unnecessary cache misses by
> orphaning an skb just before it is handed to a device for transmit thus
> avoiding the case where the orphaning occurs on a different CPU.
> 
> In the case of bonded devices this has the unfortunate side-effect of
> breaking down flow control allowing a socket to send UDP packets as fast as
> the CPU will allow. This is particularly undesirable in virtualised
> network environments.
> 
> This patch introduces ethtool control of early orphaning.
> It remains on by default by it now may be disabled on a per-interface basis.
> 
> I have implemented this as a generic flag.
> As it seems to be the first generic flag that requires
> no driver awareness I also supplied a default flag handler.
> I am unsure if any aspect of this approach is acceptable.
> 
> I believe Eric has it in mind that some of the calls
> to skb_orphan() in drivers can be removed with the addition
> of this feature. I need to discuss that with him further.
> 
> A patch for the ethtool user-space utility accompanies this patch.

The following results were measured using kvm using virto without vhost net.
The virtio device is bridged to a bond device which has one gigabit slave.

bonding device with early-orphan on (default, current behaviour since 2.6.35)
# netperf -C -c -4 -t UDP_STREAM -H 172.17.60.216
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.17.60.216 (172.17.60.216) port 0 AF_INET
Socket  Message  Elapsed      Messages                   CPU      Service
Size    Size     Time         Okay Errors   Throughput   Util     Demand
bytes   bytes    secs            #      #   10^6bits/sec % SS     us/KB

114688   65507   10.01       42908      0     2247.0     94.11    51.186
116736           10.01        2876             150.6     0.17     0.761 

bonding device with early-orphan off (behaviour prior to 2.6.35)
# netperf -C -c -4 -t UDP_STREAM -H 172.17.60.216
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.17.60.216 (172.17.60.216) port 0 AF_INET
Socket  Message  Elapsed      Messages                   CPU      Service
Size    Size     Time         Okay Errors   Throughput   Util     Demand
bytes   bytes    secs            #      #   10^6bits/sec % SS     us/KB

114688   65507   10.02       18405      0      963.0     40.12    3.413 
116736           10.02       18405             963.0     0.78     0.528 
